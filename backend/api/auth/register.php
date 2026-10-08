<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$input = getJsonInput();

$fullName = trim($input['full_name'] ?? '');
$mobileNumber = trim($input['mobile_number'] ?? '');
$bloodGroup = trim($input['blood_group'] ?? '');
$state = trim($input['state'] ?? 'Tamil Nadu');
$district = trim($input['district'] ?? 'Madurai');
$area = trim($input['area'] ?? '');
$pincode = trim($input['pincode'] ?? '');
$email = trim($input['email'] ?? '');
$dateOfBirth = !empty($input['date_of_birth']) ? $input['date_of_birth'] : null;
$gender = in_array($input['gender'] ?? '', ['Male', 'Female', 'Other']) ? $input['gender'] : 'Male';
$address = trim($input['address'] ?? '');
$latitude = !empty($input['latitude']) ? (float)$input['latitude'] : 9.9252;
$longitude = !empty($input['longitude']) ? (float)$input['longitude'] : 78.1198;
$whatsappNumber = trim($input['whatsapp_number'] ?? $mobileNumber);
$lastDonationDate = !empty($input['last_donation_date']) ? $input['last_donation_date'] : null;
$availabilityStatus = in_array($input['availability_status'] ?? '', ['Available', 'Busy', 'Unavailable']) ? $input['availability_status'] : 'Available';

$mobileClean = preg_replace('/[^0-9]/', '', $mobileNumber);
if (strlen($mobileClean) > 10 && substr($mobileClean, 0, 2) === '91') {
    $mobileClean = substr($mobileClean, -10);
}

if (empty($fullName)) {
    sendResponse(false, 'Full name is required.', null, 400);
}
if (strlen($mobileClean) !== 10) {
    sendResponse(false, 'Valid 10-digit mobile number is required.', null, 400);
}
if (empty($bloodGroup)) {
    sendResponse(false, 'Blood group is required.', null, 400);
}

$db = Database::getInstance()->getConnection();

// Check if user already exists
$stmt = $db->prepare("SELECT id FROM users WHERE mobile_number = ? LIMIT 1");
$stmt->execute([$mobileClean]);
if ($stmt->fetch()) {
    sendResponse(false, 'Mobile number is already registered. Please login.', null, 409);
}

try {
    $db->beginTransaction();

    $insertUser = $db->prepare("INSERT INTO users 
        (full_name, mobile_number, email, date_of_birth, gender, blood_group, address, state, district, area, pincode, latitude, longitude, whatsapp_number, last_donation_date, availability_status, is_verified) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)");
    
    $insertUser->execute([
        $fullName,
        $mobileClean,
        $email ?: null,
        $dateOfBirth,
        $gender,
        $bloodGroup,
        $address ?: null,
        $state,
        $district,
        $area,
        $pincode,
        $latitude,
        $longitude,
        $whatsappNumber,
        $lastDonationDate,
        $availabilityStatus
    ]);

    $userId = $db->lastInsertId();

    // Create donor status record
    $eligibleDate = $lastDonationDate ? date('Y-m-d', strtotime($lastDonationDate . ' + 3 months')) : date('Y-m-d');
    $insertStatus = $db->prepare("INSERT INTO donor_status (user_id, is_available, last_donation_date, eligible_date) VALUES (?, 1, ?, ?)");
    $insertStatus->execute([$userId, $lastDonationDate, $eligibleDate]);

    // Create welcome notification
    $insertNotif = $db->prepare("INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)");
    $insertNotif->execute([
        $userId,
        'Welcome to BloodBridge!',
        'Thank you for registering as a blood donor. Together we save lives!',
        'welcome'
    ]);

    $db->commit();

    // Generate token
    $token = generateAuthToken($userId);

    // Fetch created user
    $getUser = $db->prepare("SELECT * FROM users WHERE id = ?");
    $getUser->execute([$userId]);
    $user = $getUser->fetch();
    unset($user['password']);

    $user['eligibility'] = calculateDonorEligibility($user['last_donation_date']);

    sendResponse(true, 'Registration successful! You are now part of BloodBridge.', [
        'token' => $token,
        'user' => $user
    ], 201);

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendResponse(false, 'Registration failed: ' . $e->getMessage(), null, 500);
}
