<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);
$input = getJsonInput();

$db = Database::getInstance()->getConnection();

$allowedFields = [
    'full_name', 'email', 'date_of_birth', 'gender', 'blood_group',
    'address', 'state', 'district', 'area', 'pincode', 'whatsapp_number',
    'last_donation_date', 'availability_status', 'latitude', 'longitude'
];

$updates = [];
$params = [];

foreach ($allowedFields as $field) {
    if (isset($input[$field])) {
        $updates[] = "`$field` = ?";
        $params[] = $input[$field];
    }
}

if (empty($updates)) {
    sendResponse(false, 'No fields provided for update.', null, 400);
}

$params[] = $user['id'];
$sql = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = ?";
$stmt = $db->prepare($sql);
$stmt->execute($params);

// Fetch updated profile
$fetchStmt = $db->prepare("SELECT id, full_name, mobile_number, email, date_of_birth, gender, profile_photo, 
                                  blood_group, address, state, district, area, pincode, latitude, longitude, 
                                  whatsapp_number, last_donation_date, availability_status, is_verified 
                           FROM users WHERE id = ?");
$fetchStmt->execute([$user['id']]);
$updated = $fetchStmt->fetch();
$updated['eligibility'] = calculateDonorEligibility($updated['last_donation_date']);

sendResponse(true, 'Profile updated successfully!', $updated);
