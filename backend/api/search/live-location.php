<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setCorsHeaders();

$input = getJsonInput();

$lat = isset($input['latitude']) ? (float)$input['latitude'] : null;
$lng = isset($input['longitude']) ? (float)$input['longitude'] : null;
$radiusKm = isset($input['radius']) ? (float)$input['radius'] : 5.0; // Default 5 KM
$bloodGroup = trim($input['blood_group'] ?? '');
$availability = trim($input['availability'] ?? '');

if ($lat === null || $lng === null) {
    sendResponse(false, 'Live latitude and longitude coordinates are required.', null, 400);
}

$db = Database::getInstance()->getConnection();

$where = ["latitude IS NOT NULL AND longitude IS NOT NULL"];
$params = [];

if (!empty($bloodGroup) && $bloodGroup !== 'ALL') {
    $where[] = "blood_group = ?";
    $params[] = $bloodGroup;
}

if (!empty($availability) && $availability !== 'ALL') {
    $where[] = "availability_status = ?";
    $params[] = $availability;
}

$whereClause = implode(" AND ", $where);
$sql = "SELECT id, full_name, mobile_number, email, gender, blood_group, address, 
               state, district, area, pincode, latitude, longitude, whatsapp_number, 
               last_donation_date, availability_status, is_verified 
        FROM users 
        WHERE $whereClause";

$stmt = $db->prepare($sql);
$stmt->execute($params);
$candidates = $stmt->fetchAll();

$matches = [];
foreach ($candidates as $donor) {
    $dist = haversineGreatCircleDistance($lat, $lng, $donor['latitude'], $donor['longitude']);
    if ($dist !== null && $dist <= $radiusKm) {
        $donor['distance_km'] = $dist;
        $eligibility = calculateDonorEligibility($donor['last_donation_date']);
        $donor['eligibility'] = $eligibility;
        $donor['marker_color'] = $eligibility['marker_color'];
        $donor['status_label'] = $eligibility['status_label'];
        $matches[] = $donor;
    }
}

usort($matches, function($a, $b) {
    return $a['distance_km'] <=> $b['distance_km'];
});

sendResponse(true, count($matches) . ' donors found near you (within ' . $radiusKm . ' KM)', [
    'user_location' => ['latitude' => $lat, 'longitude' => $lng],
    'radius_km' => $radiusKm,
    'total_count' => count($matches),
    'donors' => $matches
]);
