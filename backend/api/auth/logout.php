<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$headers = getallheaders();
$token = null;
if (isset($headers['Authorization']) && preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
    $token = $matches[1];
}

$input = getJsonInput();
if (!$token && !empty($input['token'])) {
    $token = $input['token'];
}

if ($token) {
    $db = Database::getInstance()->getConnection();
    $stmt = $db->prepare("DELETE FROM user_sessions WHERE token = ?");
    $stmt->execute([$token]);
}

sendResponse(true, 'Logged out successfully.');
