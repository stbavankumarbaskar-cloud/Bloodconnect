<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);

$db = Database::getInstance()->getConnection();

$stmt = $db->prepare("SELECT id, full_name, mobile_number, email, date_of_birth, gender, profile_photo, 
                             blood_group, address, state, district, area, pincode, latitude, longitude, 
                             whatsapp_number, last_donation_date, availability_status, is_verified, created_at 
                      FROM users WHERE id = ?");
$stmt->execute([$user['id']]);
$userData = $stmt->fetch();

$eligibility = calculateDonorEligibility($userData['last_donation_date']);
$userData['eligibility'] = $eligibility;

// Fetch history
$histStmt = $db->prepare("SELECT * FROM donation_history WHERE donor_id = ? ORDER BY donation_date DESC");
$histStmt->execute([$user['id']]);
$userData['history'] = $histStmt->fetchAll();

sendResponse(true, 'Profile fetched successfully', $userData);
