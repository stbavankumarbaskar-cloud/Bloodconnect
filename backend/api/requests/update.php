<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);
$input = getJsonInput();

$requestId = (int)($input['request_id'] ?? 0);
$status = $input['status'] ?? null;

if ($requestId <= 0 || !in_array($status, ['Active', 'Fulfilled', 'Cancelled'])) {
    sendResponse(false, 'Valid request ID and status (Active, Fulfilled, Cancelled) required.', null, 400);
}

$db = Database::getInstance()->getConnection();

// Verify ownership
$check = $db->prepare("SELECT id FROM blood_requests WHERE id = ? AND request_user_id = ?");
$check->execute([$requestId, $user['id']]);
if (!$check->fetch()) {
    sendResponse(false, 'Request not found or you are not authorized to edit it.', null, 403);
}

$stmt = $db->prepare("UPDATE blood_requests SET status = ? WHERE id = ?");
$stmt->execute([$status, $requestId]);

sendResponse(true, "Request status updated to $status successfully.");
