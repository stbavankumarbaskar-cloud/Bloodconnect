<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);
$input = getJsonInput();

$patientName = trim($input['patient_name'] ?? '');
$bloodGroup = trim($input['blood_group'] ?? '');
$requiredUnits = (int)($input['required_units'] ?? 1);
$hospitalName = trim($input['hospital_name'] ?? '');
$hospitalAddress = trim($input['hospital_address'] ?? '');
$state = trim($input['state'] ?? 'Tamil Nadu');
$district = trim($input['district'] ?? 'Madurai');
$area = trim($input['area'] ?? '');
$pincode = trim($input['pincode'] ?? '');
$latitude = !empty($input['latitude']) ? (float)$input['latitude'] : 9.9252;
$longitude = !empty($input['longitude']) ? (float)$input['longitude'] : 78.1198;
$urgency = in_array($input['urgency'] ?? '', ['Critical', 'Urgent', 'Standard']) ? $input['urgency'] : 'Urgent';
$description = trim($input['description'] ?? '');

if (empty($patientName) || empty($bloodGroup) || empty($hospitalName)) {
    sendResponse(false, 'Patient name, blood group, and hospital name are required.', null, 400);
}

$db = Database::getInstance()->getConnection();

try {
    $db->beginTransaction();

    $stmt = $db->prepare("INSERT INTO blood_requests 
        (request_user_id, patient_name, blood_group, required_units, hospital_name, hospital_address, 
         state, district, area, pincode, latitude, longitude, urgency, description, status) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Active')");

    $stmt->execute([
        $user['id'],
        $patientName,
        $bloodGroup,
        $requiredUnits,
        $hospitalName,
        $hospitalAddress,
        $state,
        $district,
        $area,
        $pincode,
        $latitude,
        $longitude,
        $urgency,
        $description
    ]);

    $requestId = $db->lastInsertId();

    // Broadcast notification to matching blood donors in the district
    $notifStmt = $db->prepare("INSERT INTO notifications (user_id, title, message, type) 
                              SELECT id, ?, ?, 'emergency_request' 
                              FROM users 
                              WHERE blood_group = ? AND id != ? AND district = ? 
                              LIMIT 20");
    $title = "EMERGENCY: $bloodGroup Needed at $hospitalName";
    $msg = "$requiredUnits unit(s) of $bloodGroup blood needed urgently for $patientName at $hospitalName, $area.";
    $notifStmt->execute([$title, $msg, $bloodGroup, $user['id'], $district]);

    $db->commit();

    sendResponse(true, 'Blood request posted successfully! Nearby donors will be alerted.', [
        'request_id' => $requestId
    ], 201);

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendResponse(false, 'Failed to post blood request: ' . $e->getMessage(), null, 500);
}
