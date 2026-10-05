<?php
// ======================================================
// BloodConnect - JSON Response Helper & CORS
// ======================================================

function setCorsHeaders() {
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
    header("Content-Type: application/json; charset=UTF-8");

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

function sendResponse($success, $message, $data = null, $statusCode = 200) {
    http_response_code($statusCode);
    $response = [
        'success' => $success,
        'message' => $message,
    ];
    if ($data !== null) {
        $response['data'] = $data;
    }
    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

function getJsonInput() {
    $raw = file_get_contents('php://input');
    if (empty($raw)) {
        return $_POST;
    }
    $decoded = json_decode($raw, true);
    return is_array($decoded) ? array_merge($_POST, $decoded) : $_POST;
}

// Calculate distance using Haversine formula in KM
function haversineGreatCircleDistance($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo, $earthRadius = 6371) {
    if ($latitudeFrom === null || $longitudeFrom === null || $latitudeTo === null || $longitudeTo === null) {
        return null;
    }
    $latFrom = deg2rad((float)$latitudeFrom);
    $lonFrom = deg2rad((float)$longitudeFrom);
    $latTo = deg2rad((float)$latitudeTo);
    $lonTo = deg2rad((float)$longitudeTo);

    $latDelta = $latTo - $latFrom;
    $lonDelta = $lonTo - $lonFrom;

    $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
        cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
    return round($angle * $earthRadius, 2);
}

// Determine donor color / status based on last donation date (< 6 months = red, >= 6 months = green)
function calculateDonorEligibility($lastDonationDate, $thresholdMonths = 6) {
    if (empty($lastDonationDate) || $lastDonationDate === '0000-00-00') {
        return [
            'is_eligible' => true,
            'marker_color' => 'green',
            'status_label' => 'Potentially Available',
            'months_since' => null
        ];
    }
    try {
        $lastDate = new DateTime($lastDonationDate);
        $today = new DateTime();
        $diff = $today->diff($lastDate);
        $monthsSince = ($diff->y * 12) + $diff->m;

        if ($today < $lastDate) {
            $monthsSince = 0;
        }

        if ($monthsSince < $thresholdMonths) {
            return [
                'is_eligible' => false,
                'marker_color' => 'red',
                'status_label' => 'Recently Donated',
                'months_since' => $monthsSince
            ];
        } else {
            return [
                'is_eligible' => true,
                'marker_color' => 'green',
                'status_label' => 'Potentially Available',
                'months_since' => $monthsSince
            ];
        }
    } catch (Exception $e) {
        return [
            'is_eligible' => true,
            'marker_color' => 'green',
            'status_label' => 'Potentially Available',
            'months_since' => null
        ];
    }
}
