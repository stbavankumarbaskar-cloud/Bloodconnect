<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);
$db = Database::getInstance()->getConnection();

$stmt = $db->prepare("SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50");
$stmt->execute([$user['id']]);
$notifs = $stmt->fetchAll();

$countStmt = $db->prepare("SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0");
$countStmt->execute([$user['id']]);
$unreadCount = (int)$countStmt->fetchColumn();

sendResponse(true, 'Notifications fetched successfully', [
    'unread_count' => $unreadCount,
    'notifications' => $notifs
]);
