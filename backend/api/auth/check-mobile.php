<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setCorsHeaders();

$input = getJsonInput();
$mobile = trim($input['mobile_number'] ?? '');

// Strip leading +91 or spaces
$mobileClean = preg_replace('/[^0-9]/', '', $mobile);
if (strlen($mobileClean) > 10 && substr($mobileClean, 0, 2) === '91') {
    $mobileClean = substr($mobileClean, -10);
}

if (strlen($mobileClean) !== 10) {
    sendResponse(false, 'Please provide a valid 10-digit Indian mobile number.', null, 400);
}

$db = Database::getInstance()->getConnection();
$stmt = $db->prepare("SELECT id, full_name, mobile_number, blood_group, profile_photo, state, district, area, pincode 
                      FROM users 
                      WHERE mobile_number = ? OR mobile_number = ? 
                      LIMIT 1");
$stmt->execute([$mobileClean, '+91' . $mobileClean]);
$user = $stmt->fetch();

if ($user) {
    sendResponse(true, 'Mobile number found. Existing user.', [
        'is_registered' => true,
        'user' => $user
    ]);
} else {
    sendResponse(true, 'Mobile number not registered. Please complete registration.', [
        'is_registered' => false,
        'mobile_number' => $mobileClean
    ]);
}
