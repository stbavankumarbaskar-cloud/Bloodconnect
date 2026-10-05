<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setCorsHeaders();

$lat = isset($_GET['latitude']) ? (float)$_GET['latitude'] : null;
$lng = isset($_GET['longitude']) ? (float)$_GET['longitude'] : null;
$radiusKm = isset($_GET['radius']) ? (float)$_GET['radius'] : 5.0; // Default 5 KM
$bloodGroup = isset($_GET['blood_group']) && $_GET['blood_group'] !== 'ALL' ? $_GET['blood_group'] : null;

if ($lat === null || $lng === null) {
    sendResponse(false, 'Latitude and longitude coordinates are required.', null, 400);
}

$db = Database::getInstance()->getConnection();

$where = ["latitude IS NOT NULL AND longitude IS NOT NULL"];
$params = [];

if (!empty($bloodGroup)) {
    $where[] = "blood_group = ?";
    $params[] = $bloodGroup;
}

$whereClause = implode(" AND ", $where);
$sql = "SELECT id, full_name, mobile_number, email, gender, blood_group, state, district, area, pincode, 
               latitude, longitude, whatsapp_number, last_donation_date, availability_status, is_verified 
        FROM users 
        WHERE $whereClause";

$stmt = $db->prepare($sql);
$stmt->execute($params);
$allDonors = $stmt->fetchAll();

$nearbyDonors = [];
foreach ($allDonors as $donor) {
    $distance = haversineGreatCircleDistance($lat, $lng, $donor['latitude'], $donor['longitude']);
    
    // Check if within radius
    if ($distance !== null && $distance <= $radiusKm) {
        $donor['distance_km'] = $distance;
        $eligibility = calculateDonorEligibility($donor['last_donation_date']);
        $donor['eligibility'] = $eligibility;
        $donor['marker_color'] = $eligibility['marker_color'];
        $donor['status_label'] = $eligibility['status_label'];
        $nearbyDonors[] = $donor;
    }
}

// Sort by distance ascending
usort($nearbyDonors, function($a, $b) {
    return $a['distance_km'] <=> $b['distance_km'];
});

sendResponse(true, count($nearbyDonors) . ' donors found within ' . $radiusKm . ' KM', [
    'center' => ['latitude' => $lat, 'longitude' => $lng],
    'radius_km' => $radiusKm,
    'total_count' => count($nearbyDonors),
    'donors' => $nearbyDonors
]);
