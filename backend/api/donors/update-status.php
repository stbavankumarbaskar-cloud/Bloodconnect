<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);
$input = getJsonInput();

$availability = $input['availability_status'] ?? null;
$lastDonationDate = $input['last_donation_date'] ?? null;

if (!$availability && !$lastDonationDate) {
    sendResponse(false, 'Nothing to update.', null, 400);
}

$db = Database::getInstance()->getConnection();
$updates = [];
$params = [];

if ($availability && in_array($availability, ['Available', 'Busy', 'Unavailable'])) {
    $updates[] = "availability_status = ?";
    $params[] = $availability;
}

if ($lastDonationDate) {
    $updates[] = "last_donation_date = ?";
    $params[] = $lastDonationDate;
}

$params[] = $user['id'];
$sql = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = ?";
$stmt = $db->prepare($sql);
$stmt->execute($params);

// Also sync with donor_status table
if ($availability) {
    $isAvail = ($availability === 'Available') ? 1 : 0;
    $syncStmt = $db->prepare("UPDATE donor_status SET is_available = ? WHERE user_id = ?");
    $syncStmt->execute([$isAvail, $user['id']]);
}

sendResponse(true, 'Donor availability status updated successfully.');
