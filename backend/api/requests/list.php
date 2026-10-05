<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$db = Database::getInstance()->getConnection();

$status = $_GET['status'] ?? null;
$bloodGroup = $_GET['blood_group'] ?? null;
$myRequests = isset($_GET['my_requests']) && $_GET['my_requests'] == '1';

$where = ["1=1"];
$params = [];

if ($myRequests) {
    $user = getAuthenticatedUser(true);
    $where[] = "r.request_user_id = ?";
    $params[] = $user['id'];
}

if (!empty($status) && $status !== 'ALL') {
    $where[] = "r.status = ?";
    $params[] = $status;
}

if (!empty($bloodGroup) && $bloodGroup !== 'ALL') {
    $where[] = "r.blood_group = ?";
    $params[] = $bloodGroup;
}

$whereClause = implode(" AND ", $where);
$sql = "SELECT r.*, u.full_name as requester_name, u.mobile_number as requester_mobile 
        FROM blood_requests r 
        LEFT JOIN users u ON r.request_user_id = u.id 
        WHERE $whereClause 
        ORDER BY 
            CASE r.urgency 
                WHEN 'Critical' THEN 1 
                WHEN 'Urgent' THEN 2 
                ELSE 3 
            END, 
            r.created_at DESC";

$stmt = $db->prepare($sql);
$stmt->execute($params);
$requests = $stmt->fetchAll();

sendResponse(true, 'Blood requests fetched successfully', $requests);
