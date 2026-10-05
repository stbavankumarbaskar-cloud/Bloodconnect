<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);
$input = getJsonInput();

$donationDate = trim($input['donation_date'] ?? date('Y-m-d'));
$hospitalName = trim($input['hospital_name'] ?? '');
$location = trim($input['location'] ?? '');
$notes = trim($input['notes'] ?? '');

if (empty($hospitalName)) {
    sendResponse(false, 'Hospital name is required.', null, 400);
}

$db = Database::getInstance()->getConnection();

try {
    $db->beginTransaction();

    $stmt = $db->prepare("INSERT INTO donation_history (donor_id, donation_date, hospital_name, location, notes) 
                          VALUES (?, ?, ?, ?, ?)");
    $stmt->execute([$user['id'], $donationDate, $hospitalName, $location, $notes]);

    // Update user's last_donation_date if this is newer
    $userUpdate = $db->prepare("UPDATE users 
                                SET last_donation_date = GREATEST(COALESCE(last_donation_date, ?), ?) 
                                WHERE id = ?");
    $userUpdate->execute([$donationDate, $donationDate, $user['id']]);

    // Update donor_status eligible_date (+3 months)
    $eligibleDate = date('Y-m-d', strtotime($donationDate . ' + 3 months'));
    $statusUpdate = $db->prepare("UPDATE donor_status 
                                  SET last_donation_date = GREATEST(COALESCE(last_donation_date, ?), ?), 
                                      eligible_date = ? 
                                  WHERE user_id = ?");
    $statusUpdate->execute([$donationDate, $donationDate, $eligibleDate, $user['id']]);

    $db->commit();

    sendResponse(true, 'Donation record added successfully! Thank you for donating blood.', [
        'donation_date' => $donationDate,
        'eligible_date' => $eligibleDate
    ], 201);

} catch (Exception $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    sendResponse(false, 'Failed to save donation record: ' . $e->getMessage(), null, 500);
}
