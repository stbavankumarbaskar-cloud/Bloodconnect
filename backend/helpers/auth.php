<?php
// ======================================================
// BloodConnect - Authentication Helper
// ======================================================

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/response.php';

function generateAuthToken($userId) {
    $db = Database::getInstance()->getConnection();
    $token = bin2hex(random_bytes(32));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

    $stmt = $db->prepare("INSERT INTO user_sessions (user_id, token, expires_at) VALUES (?, ?, ?)");
    $stmt->execute([$userId, $token, $expiresAt]);

    return $token;
}

function getAuthenticatedUser($requireAuth = true) {
    $token = null;

    // 1. Check getallheaders() case-insensitively
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    if (!empty($headers)) {
        foreach ($headers as $key => $val) {
            if (strcasecmp($key, 'Authorization') === 0) {
                if (preg_match('/Bearer\s+(\S+)/i', $val, $matches)) {
                    $token = $matches[1];
                    break;
                }
            } elseif (strcasecmp($key, 'X-Auth-Token') === 0 || strcasecmp($key, 'X-Token') === 0) {
                $token = trim($val);
                break;
            }
        }
    }

    // 2. Check apache_request_headers() if available
    if (!$token && function_exists('apache_request_headers')) {
        $apacheHeaders = apache_request_headers();
        if (is_array($apacheHeaders)) {
            foreach ($apacheHeaders as $key => $val) {
                if (strcasecmp($key, 'Authorization') === 0) {
                    if (preg_match('/Bearer\s+(\S+)/i', $val, $matches)) {
                        $token = $matches[1];
                        break;
                    }
                } elseif (strcasecmp($key, 'X-Auth-Token') === 0 || strcasecmp($key, 'X-Token') === 0) {
                    $token = trim($val);
                    break;
                }
            }
        }
    }

    // 3. Check $_SERVER environment variables (populated by mod_rewrite or FastCGI/CGI)
    if (!$token) {
        $authServer = $_SERVER['HTTP_AUTHORIZATION']
                   ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
                   ?? $_SERVER['HTTP_X_AUTH_TOKEN']
                   ?? $_SERVER['Authorization']
                   ?? null;
        if ($authServer) {
            if (preg_match('/Bearer\s+(\S+)/i', $authServer, $matches)) {
                $token = $matches[1];
            } else {
                $token = trim($authServer);
            }
        }
    }

    // 4. Check query string ($_GET)
    if (!$token && isset($_GET['token'])) {
        $token = trim($_GET['token']);
    }
    if (!$token && isset($_GET['auth_token'])) {
        $token = trim($_GET['auth_token']);
    }

    // 5. Check JSON payload / request body
    if (!$token) {
        $input = getJsonInput();
        if (!empty($input['token'])) {
            $token = trim($input['token']);
        } elseif (!empty($input['auth_token'])) {
            $token = trim($input['auth_token']);
        }
    }

    // 6. Check $_POST
    if (!$token && isset($_POST['token'])) {
        $token = trim($_POST['token']);
    }

    if (!$token) {
        if ($requireAuth) {
            sendResponse(false, 'Unauthorized. Authentication token is missing.', null, 401);
        }
        return null;
    }

    $db = Database::getInstance()->getConnection();
    $stmt = $db->prepare("SELECT s.*, u.* 
                          FROM user_sessions s 
                          JOIN users u ON s.user_id = u.id 
                          WHERE s.token = ? AND s.expires_at > NOW() 
                          LIMIT 1");
    $stmt->execute([$token]);
    $user = $stmt->fetch();

    if (!$user) {
        if ($requireAuth) {
            sendResponse(false, 'Session expired or invalid token. Please log in again.', null, 401);
        }
        return null;
    }

    unset($user['password']);
    return $user;
}
