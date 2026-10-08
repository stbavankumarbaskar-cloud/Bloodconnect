<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);
$input = getJsonInput();

$requestId = (int)($input['request_id'] ?? 0);
if ($requestId <= 0) {
    sendResponse(false, 'Valid request ID is required.', null, 400);
}

$db = Database::getInstance()->getConnection();

// Verify ownership
$check = $db->prepare("SELECT * FROM blood_requests WHERE id = ? AND request_user_id = ?");
$check->execute([$requestId, $user['id']]);
$existing = $check->fetch();
if (!$existing) {
    sendResponse(false, 'Request not found or you are not authorized to edit it.', null, 403);
}

$fieldsToUpdate = [];
$params = [];

// Status update
if (isset($input['status'])) {
    $status = trim($input['status']);
    if (in_array($status, ['Active', 'Fulfilled', 'Cancelled'])) {
        $fieldsToUpdate[] = "status = ?";
        $params[] = $status;
    } else {
        sendResponse(false, 'Invalid status. Must be Active, Fulfilled, or Cancelled.', null, 400);
    }
}

// Optional field updates
if (isset($input['required_units'])) {
    $units = (int)$input['required_units'];
    if ($units > 0) {
        $fieldsToUpdate[] = "required_units = ?";
        $params[] = $units;
    }
}

if (!empty($input['patient_name'])) {
    $fieldsToUpdate[] = "patient_name = ?";
    $params[] = trim($input['patient_name']);
}

if (!empty($input['blood_group'])) {
    $fieldsToUpdate[] = "blood_group = ?";
    $params[] = trim($input['blood_group']);
}

if (!empty($input['hospital_name'])) {
    $fieldsToUpdate[] = "hospital_name = ?";
    $params[] = trim($input['hospital_name']);
}

if (!empty($input['hospital_address'])) {
    $fieldsToUpdate[] = "hospital_address = ?";
    $params[] = trim($input['hospital_address']);
}

if (!empty($input['urgency']) && in_array($input['urgency'], ['Critical', 'Urgent', 'Standard'])) {
    $fieldsToUpdate[] = "urgency = ?";
    $params[] = trim($input['urgency']);
}

if (isset($input['description'])) {
    $fieldsToUpdate[] = "description = ?";
    $params[] = trim($input['description']);
}

if (!empty($input['area'])) {
    $fieldsToUpdate[] = "area = ?";
    $params[] = trim($input['area']);
}

if (!empty($input['district'])) {
    $fieldsToUpdate[] = "district = ?";
    $params[] = trim($input['district']);
}

if (empty($fieldsToUpdate)) {
    sendResponse(false, 'No fields provided to update.', null, 400);
}

$params[] = $requestId;
$sql = "UPDATE blood_requests SET " . implode(", ", $fieldsToUpdate) . " WHERE id = ?";
$stmt = $db->prepare($sql);
$stmt->execute($params);

// Fetch updated record
$fetchStmt = $db->prepare("SELECT * FROM blood_requests WHERE id = ?");
$fetchStmt->execute([$requestId]);
$updatedRecord = $fetchStmt->fetch();

sendResponse(true, 'Request updated successfully.', $updatedRecord);
