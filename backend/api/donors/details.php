<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setCorsHeaders();

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if ($id <= 0) {
    sendResponse(false, 'Donor ID is required.', null, 400);
}

$db = Database::getInstance()->getConnection();
$stmt = $db->prepare("SELECT id, full_name, mobile_number, email, date_of_birth, gender, profile_photo, 
                             blood_group, address, state, district, area, pincode, latitude, longitude, 
                             whatsapp_number, last_donation_date, availability_status, is_verified, created_at 
                      FROM users 
                      WHERE id = ? 
                      LIMIT 1");
$stmt->execute([$id]);
$donor = $stmt->fetch();

if (!$donor) {
    sendResponse(false, 'Donor not found.', null, 404);
}

$eligibility = calculateDonorEligibility($donor['last_donation_date']);
$donor['eligibility'] = $eligibility;
$donor['marker_color'] = $eligibility['marker_color'];
$donor['status_label'] = $eligibility['status_label'];

// Fetch donation history
$histStmt = $db->prepare("SELECT id, donation_date, hospital_name, location, notes, created_at 
                          FROM donation_history 
                          WHERE donor_id = ? 
                          ORDER BY donation_date DESC");
$histStmt->execute([$id]);
$donor['history'] = $histStmt->fetchAll();

sendResponse(true, 'Donor details retrieved', $donor);
