<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setCorsHeaders();

$input = getJsonInput();

$state = trim($input['state'] ?? '');
$district = trim($input['district'] ?? '');
$area = trim($input['area'] ?? '');
$pincode = trim($input['pincode'] ?? '');
$bloodGroup = trim($input['blood_group'] ?? '');
$gender = trim($input['gender'] ?? '');
$availability = trim($input['availability'] ?? '');

$userLat = isset($input['latitude']) && $input['latitude'] !== '' ? (float)$input['latitude'] : null;
$userLng = isset($input['longitude']) && $input['longitude'] !== '' ? (float)$input['longitude'] : null;

$db = Database::getInstance()->getConnection();

$where = ["1=1"];
$params = [];

if (!empty($bloodGroup) && $bloodGroup !== 'ALL') {
    $where[] = "blood_group = ?";
    $params[] = $bloodGroup;
}

if (!empty($pincode)) {
    $where[] = "pincode LIKE ?";
    $params[] = "%$pincode%";
}

if (!empty($area)) {
    $where[] = "area LIKE ?";
    $params[] = "%$area%";
}

if (!empty($district) && $district !== 'ALL') {
    $where[] = "district LIKE ?";
    $params[] = "%$district%";
}

if (!empty($state) && $state !== 'ALL') {
    $where[] = "state LIKE ?";
    $params[] = "%$state%";
}

if (!empty($gender) && $gender !== 'ALL') {
    $where[] = "gender = ?";
    $params[] = $gender;
}

if (!empty($availability) && $availability !== 'ALL') {
    $where[] = "availability_status = ?";
    $params[] = $availability;
}

$whereClause = implode(" AND ", $where);
$sql = "SELECT id, full_name, mobile_number, email, gender, blood_group, address, 
               state, district, area, pincode, latitude, longitude, whatsapp_number, 
               last_donation_date, availability_status, is_verified, created_at 
        FROM users 
        WHERE $whereClause 
        ORDER BY availability_status ASC, last_donation_date ASC, created_at DESC 
        LIMIT 100";

$stmt = $db->prepare($sql);
$stmt->execute($params);
$results = $stmt->fetchAll();

foreach ($results as &$donor) {
    $eligibility = calculateDonorEligibility($donor['last_donation_date']);
    $donor['eligibility'] = $eligibility;
    $donor['marker_color'] = $eligibility['marker_color'];
    $donor['status_label'] = $eligibility['status_label'];

    if ($userLat !== null && $userLng !== null && $donor['latitude'] && $donor['longitude']) {
        $donor['distance_km'] = haversineGreatCircleDistance($userLat, $userLng, $donor['latitude'], $donor['longitude']);
    } else {
        $donor['distance_km'] = null;
    }
}

if ($userLat !== null && $userLng !== null) {
    usort($results, function($a, $b) {
        if ($a['distance_km'] === null) return 1;
        if ($b['distance_km'] === null) return -1;
        return $a['distance_km'] <=> $b['distance_km'];
    });
}

sendResponse(true, count($results) . ' donors found for your criteria.', [
    'total_count' => count($results),
    'donors' => $results
]);
