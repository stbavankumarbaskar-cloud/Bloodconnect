<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setCorsHeaders();

$user = getAuthenticatedUser(true);

if (!isset($_FILES['photo']) || $_FILES['photo']['error'] !== UPLOAD_ERR_OK) {
    sendResponse(false, 'No image file uploaded or upload error.', null, 400);
}

$file = $_FILES['photo'];
$allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
if (!in_array($file['type'], $allowedTypes)) {
    sendResponse(false, 'Invalid file type. Only JPG, PNG, and WebP are allowed.', null, 400);
}

// Max 5MB
if ($file['size'] > 5 * 1024 * 1024) {
    sendResponse(false, 'Image size exceeds maximum limit of 5MB.', null, 400);
}

$uploadDir = __DIR__ . '/../../uploads/profiles/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$extension = pathinfo($file['name'], PATHINFO_EXTENSION);
$filename = 'profile_' . $user['id'] . '_' . time() . '.' . $extension;
$targetPath = $uploadDir . $filename;

if (!move_uploaded_file($file['tmp_name'], $targetPath)) {
    sendResponse(false, 'Failed to save uploaded image.', null, 500);
}

$photoUrl = 'uploads/profiles/' . $filename;

$db = Database::getInstance()->getConnection();
$stmt = $db->prepare("UPDATE users SET profile_photo = ? WHERE id = ?");
$stmt->execute([$photoUrl, $user['id']]);

sendResponse(true, 'Profile photo uploaded successfully', [
    'photo_url' => $photoUrl
]);
