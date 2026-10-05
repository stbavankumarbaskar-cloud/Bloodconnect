<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);
$db = Database::getInstance()->getConnection();

$stmt = $db->prepare("SELECT * FROM donation_history WHERE donor_id = ? ORDER BY donation_date DESC");
$stmt->execute([$user['id']]);
$history = $stmt->fetchAll();

sendResponse(true, 'Donation history retrieved', $history);
