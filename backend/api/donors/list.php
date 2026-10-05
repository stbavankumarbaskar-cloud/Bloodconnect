<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setCorsHeaders();

$db = Database::getInstance()->getConnection();

$bloodGroup = $_GET['blood_group'] ?? null;
$availability = $_GET['availability'] ?? null;
$district = $_GET['district'] ?? null;
$state = $_GET['state'] ?? null;
$userLat = isset($_GET['latitude']) && $_GET['latitude'] !== '' ? (float)$_GET['latitude'] : null;
$userLng = isset($_GET['longitude']) && $_GET['longitude'] !== '' ? (float)$_GET['longitude'] : null;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;

$where = ["1=1"];
$params = [];

if (!empty($bloodGroup) && $bloodGroup !== 'ALL') {
    $where[] = "blood_group = ?";
    $params[] = $bloodGroup;
}

if (!empty($availability)) {
    $where[] = "availability_status = ?";
    $params[] = $availability;
}

if (!empty($district)) {
    $where[] = "district LIKE ?";
    $params[] = "%$district%";
}

if (!empty($state)) {
    $where[] = "state LIKE ?";
    $params[] = "%$state%";
}

$whereClause = implode(" AND ", $where);
$sql = "SELECT id, full_name, mobile_number, email, gender, blood_group, state, district, area, pincode, 
               latitude, longitude, whatsapp_number, last_donation_date, availability_status, is_verified, created_at 
        FROM users 
        WHERE $whereClause 
        ORDER BY last_donation_date ASC, created_at DESC 
        LIMIT " . $limit;

$stmt = $db->prepare($sql);
$stmt->execute($params);
$donors = $stmt->fetchAll();

foreach ($donors as &$donor) {
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
    usort($donors, function($a, $b) {
        if ($a['distance_km'] === null) return 1;
        if ($b['distance_km'] === null) return -1;
        return $a['distance_km'] <=> $b['distance_km'];
    });
}

sendResponse(true, 'Donors fetched successfully', $donors);
