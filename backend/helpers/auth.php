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
    $headers = getallheaders();
    $token = null;

    if (isset($headers['Authorization'])) {
        $matches = [];
        if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
            $token = $matches[1];
        }
    }

    if (!$token && isset($_GET['token'])) {
        $token = $_GET['token'];
    }

    if (!$token && isset($_POST['token'])) {
        $token = $_POST['token'];
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
