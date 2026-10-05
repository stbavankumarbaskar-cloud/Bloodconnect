-- ======================================================
-- BloodConnect Donor App - MySQL Database Schema
-- Database: bloodconnect_db
-- ======================================================

CREATE DATABASE IF NOT EXISTS `bloodconnect_db` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `bloodconnect_db`;

-- 1. Table: users
DROP TABLE IF EXISTS `user_sessions`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `donation_history`;
DROP TABLE IF EXISTS `blood_requests`;
DROP TABLE IF EXISTS `donor_status`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `full_name` VARCHAR(150) NOT NULL,
  `mobile_number` VARCHAR(15) NOT NULL UNIQUE,
  `email` VARCHAR(150) DEFAULT NULL,
  `password` VARCHAR(255) DEFAULT NULL,
  `date_of_birth` DATE DEFAULT NULL,
  `gender` ENUM('Male', 'Female', 'Other') DEFAULT 'Male',
  `profile_photo` VARCHAR(255) DEFAULT NULL,
  `blood_group` VARCHAR(5) NOT NULL,
  `address` TEXT DEFAULT NULL,
  `state` VARCHAR(100) NOT NULL,
  `district` VARCHAR(100) NOT NULL,
  `area` VARCHAR(100) NOT NULL,
  `pincode` VARCHAR(10) NOT NULL,
  `latitude` DECIMAL(10, 8) DEFAULT NULL,
  `longitude` DECIMAL(11, 8) DEFAULT NULL,
  `whatsapp_number` VARCHAR(15) DEFAULT NULL,
  `last_donation_date` DATE DEFAULT NULL,
  `availability_status` ENUM('Available', 'Busy', 'Unavailable') DEFAULT 'Available',
  `is_verified` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_users_mobile` (`mobile_number`),
  INDEX `idx_users_blood_group` (`blood_group`),
  INDEX `idx_users_pincode` (`pincode`),
  INDEX `idx_users_state_district` (`state`, `district`),
  INDEX `idx_users_location` (`latitude`, `longitude`),
  INDEX `idx_users_last_donation` (`last_donation_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Table: donor_status
CREATE TABLE `donor_status` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `is_available` TINYINT(1) DEFAULT 1,
  `last_donation_date` DATE DEFAULT NULL,
  `eligible_date` DATE DEFAULT NULL,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_donor_status_avail` (`is_available`),
  INDEX `idx_donor_status_eligible` (`eligible_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Table: blood_requests
CREATE TABLE `blood_requests` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `request_user_id` INT NOT NULL,
  `patient_name` VARCHAR(150) NOT NULL,
  `blood_group` VARCHAR(5) NOT NULL,
  `required_units` INT DEFAULT 1,
  `hospital_name` VARCHAR(200) NOT NULL,
  `hospital_address` TEXT NOT NULL,
  `state` VARCHAR(100) NOT NULL,
  `district` VARCHAR(100) NOT NULL,
  `area` VARCHAR(100) NOT NULL,
  `pincode` VARCHAR(10) NOT NULL,
  `latitude` DECIMAL(10, 8) DEFAULT NULL,
  `longitude` DECIMAL(11, 8) DEFAULT NULL,
  `urgency` ENUM('Critical', 'Urgent', 'Standard') DEFAULT 'Urgent',
  `description` TEXT DEFAULT NULL,
  `status` ENUM('Active', 'Fulfilled', 'Cancelled') DEFAULT 'Active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`request_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_requests_blood` (`blood_group`),
  INDEX `idx_requests_status` (`status`),
  INDEX `idx_requests_urgency` (`urgency`),
  INDEX `idx_requests_pincode` (`pincode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Table: donation_history
CREATE TABLE `donation_history` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `donor_id` INT NOT NULL,
  `donation_date` DATE NOT NULL,
  `hospital_name` VARCHAR(200) NOT NULL,
  `location` VARCHAR(200) NOT NULL,
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`donor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_history_donor` (`donor_id`),
  INDEX `idx_history_date` (`donation_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Table: notifications
CREATE TABLE `notifications` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `message` TEXT NOT NULL,
  `type` VARCHAR(50) DEFAULT 'general',
  `is_read` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_notifications_user` (`user_id`, `is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Table: user_sessions
CREATE TABLE `user_sessions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `token` VARCHAR(255) NOT NULL UNIQUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `expires_at` DATETIME NOT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_sessions_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ======================================================
-- SAMPLE SEED DATA
-- ======================================================

-- Donors in and around Madurai, Tamil Nadu (Center approx 9.9252, 78.1198)
-- Some with recent donations (< 6 months -> Red Pin)
-- Some with donations >= 6 months or never (>= 6 months -> Green Pin)
INSERT INTO `users` 
(`id`, `full_name`, `mobile_number`, `email`, `date_of_birth`, `gender`, `blood_group`, `address`, `state`, `district`, `area`, `pincode`, `latitude`, `longitude`, `whatsapp_number`, `last_donation_date`, `availability_status`, `is_verified`)
VALUES
(1, 'Karthik Raja', '9876543210', 'karthik@gmail.com', '1995-04-12', 'Male', 'O+', '12 Cross Street, Anna Nagar', 'Tamil Nadu', 'Madurai', 'Anna Nagar', '625020', 9.92750000, 78.14200000, '9876543210', '2026-08-15', 'Available', 1),
(2, 'Priya Dharshini', '9876543211', 'priya@gmail.com', '1998-08-23', 'Female', 'A+', '45 West Veli Street, Simmakkal', 'Tamil Nadu', 'Madurai', 'Simmakkal', '625001', 9.92380000, 78.12150000, '9876543211', '2026-01-10', 'Available', 1),
(3, 'Senthil Kumar', '9876543212', 'senthil@gmail.com', '1992-11-05', 'Male', 'B+', '88 Bypass Road, Ponmeni', 'Tamil Nadu', 'Madurai', 'Ponmeni', '625016', 9.91420000, 78.09850000, '9876543212', '2026-09-02', 'Available', 1),
(4, 'Ananya Sharma', '9876543213', 'ananya@gmail.com', '2000-01-18', 'Female', 'AB+', '33 Ring Road, KK Nagar', 'Tamil Nadu', 'Madurai', 'KK Nagar', '625020', 9.93400000, 78.14800000, '9876543213', '2025-10-15', 'Available', 1),
(5, 'Vignesh Murugan', '9876543214', 'vignesh@gmail.com', '1994-06-30', 'Male', 'O-', '15 Goripalayam High Road', 'Tamil Nadu', 'Madurai', 'Goripalayam', '625002', 9.93250000, 78.13100000, '9876543214', '2026-02-20', 'Available', 1),
(6, 'Deepak Chandran', '9876543215', 'deepak@gmail.com', '1996-03-14', 'Male', 'A-', '72 Alagar Kovil Road, Tallakulam', 'Tamil Nadu', 'Madurai', 'Tallakulam', '625002', 9.93850000, 78.13600000, '9876543215', '2026-08-28', 'Available', 1),
(7, 'Meenakshi Sundaram', '9876543216', 'meena@gmail.com', '1991-09-09', 'Female', 'B-', '102 Melur Main Road, Othakadai', 'Tamil Nadu', 'Madurai', 'Othakadai', '625107', 9.96500000, 78.18800000, '9876543216', '2025-08-10', 'Available', 1),
(8, 'Rajesh Kannan', '9876543217', 'rajesh@gmail.com', '1993-12-25', 'Male', 'AB-', '5 Main Bazaar, Thirunagar', 'Tamil Nadu', 'Madurai', 'Thirunagar', '625006', 9.87800000, 78.07200000, '9876543217', '2026-07-12', 'Available', 1),
(9, 'Rahul Verma', '9876543218', 'rahul@gmail.com', '1997-05-19', 'Male', 'O+', '44 South Gate', 'Tamil Nadu', 'Madurai', 'South Gate', '625001', 9.91600000, 78.11800000, '9876543218', '2025-11-20', 'Available', 1),
(10, 'Divya Ramesh', '9876543219', 'divya@gmail.com', '1999-07-07', 'Female', 'A+', '18 Villapuram Housing Board', 'Tamil Nadu', 'Madurai', 'Villapuram', '625012', 9.89700000, 78.12500000, '9876543219', '2026-03-01', 'Available', 1);

-- Donor Status
INSERT INTO `donor_status` (`user_id`, `is_available`, `last_donation_date`, `eligible_date`) VALUES
(1, 1, '2026-08-15', '2026-11-15'),
(2, 1, '2026-01-10', '2026-04-10'),
(3, 1, '2026-09-02', '2026-12-02'),
(4, 1, '2025-10-15', '2026-01-15'),
(5, 1, '2026-02-20', '2026-05-20'),
(6, 1, '2026-08-28', '2026-11-28'),
(7, 1, '2025-08-10', '2025-11-10'),
(8, 1, '2026-07-12', '2026-10-12'),
(9, 1, '2025-11-20', '2026-02-20'),
(10, 1, '2026-03-01', '2026-06-01');

-- Donation History
INSERT INTO `donation_history` (`donor_id`, `donation_date`, `hospital_name`, `location`, `notes`) VALUES
(1, '2026-08-15', 'Government Rajaji Hospital', 'Madurai', 'Regular voluntary blood donation drive on Independence Day.'),
(1, '2026-03-10', 'Apollo Speciality Hospitals', 'Madurai', 'Emergency replacement for cardiac surgery.'),
(2, '2026-01-10', 'Meenakshi Mission Hospital', 'Madurai', 'Donated 1 unit whole blood.'),
(3, '2026-09-02', 'Vadamalayan Hospital', 'Madurai', 'Platelet apheresis donation.'),
(4, '2025-10-15', 'Government Rajaji Hospital', 'Madurai', 'Youth Blood Donation Camp.');

-- Sample Blood Requests
INSERT INTO `blood_requests` 
(`id`, `request_user_id`, `patient_name`, `blood_group`, `required_units`, `hospital_name`, `hospital_address`, `state`, `district`, `area`, `pincode`, `latitude`, `longitude`, `urgency`, `description`, `status`)
VALUES
(1, 1, 'Murugesan S.', 'O+', 2, 'Apollo Speciality Hospitals', 'Lake View Road, K.K. Nagar, Madurai', 'Tamil Nadu', 'Madurai', 'KK Nagar', '625020', 9.93200000, 78.14500000, 'Critical', 'Urgent need for open heart surgery tomorrow morning. Contact family directly.', 'Active'),
(2, 2, 'Kavitha R.', 'B+', 3, 'Government Rajaji Hospital', 'Panagal Road, Shenoy Nagar, Madurai', 'Tamil Nadu', 'Madurai', 'Shenoy Nagar', '625020', 9.92900000, 78.13200000, 'Urgent', 'Accident emergency case admitted in ICU Ward 4. Immediate donors required.', 'Active'),
(3, 3, 'Baby of Lakshmi', 'O-', 1, 'Meenakshi Mission Hospital', 'Melur Road, Madurai', 'Tamil Nadu', 'Madurai', 'Melur Road', '625107', 9.96100000, 78.17500000, 'Critical', 'Neonatal jaundice and anemia. Rare O- donor required urgently within 6 hours.', 'Active'),
(4, 4, 'Ramaswamy N.', 'A+', 2, 'Devadoss Multi-Speciality Hospital', '75/1, Surveyor Colony, Madurai', 'Tamil Nadu', 'Madurai', 'Surveyor Colony', '625007', 9.94800000, 78.15200000, 'Standard', 'Scheduled hip replacement surgery on Friday morning.', 'Active');

-- Sample Notifications
INSERT INTO `notifications` (`user_id`, `title`, `message`, `type`, `is_read`, `created_at`) VALUES
(1, 'Urgent O+ Needed Nearby', 'Apollo Hospital Madurai needs 2 units of O+ blood within 3 km of your location.', 'urgent_request', 0, NOW()),
(1, 'Welcome to BloodConnect!', 'Thank you for registering as a life saver. Keep your availability status up to date.', 'welcome', 1, NOW()),
(2, 'Emergency Blood Request', 'B+ blood needed urgently at Government Rajaji Hospital, Madurai.', 'urgent_request', 0, NOW());
