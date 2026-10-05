<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$input = getJsonInput();
$mobile = trim($input['mobile_number'] ?? '');

$mobileClean = preg_replace('/[^0-9]/', '', $mobile);
if (strlen($mobileClean) > 10 && substr($mobileClean, 0, 2) === '91') {
    $mobileClean = substr($mobileClean, -10);
}

if (strlen($mobileClean) !== 10) {
    sendResponse(false, 'Please provide a valid 10-digit Indian mobile number.', null, 400);
}

$db = Database::getInstance()->getConnection();
$stmt = $db->prepare("SELECT * FROM users WHERE mobile_number = ? OR mobile_number = ? LIMIT 1");
$stmt->execute([$mobileClean, '+91' . $mobileClean]);
$user = $stmt->fetch();

if (!$user) {
    sendResponse(false, 'Mobile number not found. Please register first.', [
        'needs_registration' => true,
        'mobile_number' => $mobileClean
    ], 404);
}

// Generate token
$token = generateAuthToken($user['id']);
unset($user['password']);

// Calculate donor eligibility info
$eligibility = calculateDonorEligibility($user['last_donation_date']);
$user['eligibility'] = $eligibility;

sendResponse(true, 'Login successful! Welcome back, ' . $user['full_name'], [
    'token' => $token,
    'user' => $user
]);
