<?php
// ============================================================================
// BloodConnect - Official Privacy Policy & API Entrypoint
// Meets Google Play Store & Apple App Store Healthcare & Location Guidelines
// ============================================================================

// Detect if JSON output was requested
$isJson = false;
if (isset($_GET['format']) && strtolower($_GET['format']) === 'json') {
    $isJson = true;
} elseif (isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'application/json') !== false && !isset($_GET['html'])) {
    $isJson = true;
}

$policyData = [
    'app_name' => 'BloodConnect',
    'version' => '1.0.0',
    'last_updated' => 'October 09, 2026',
    'contact_email' => 'privacy@bloodconnect.org',
    'support_phone' => '+91 1800-BLOOD-HELP',
    'address' => 'BloodConnect Health Foundation, Tamil Nadu, India',
    'summary' => 'BloodConnect connects voluntary blood donors with patients and healthcare facilities during emergency shortages. We are strictly committed to safeguarding your personal identity, contact numbers, and location privacy.',
    'sections' => [
        [
            'id' => 'intro',
            'title' => '1. Introduction & Mission',
            'content' => 'BloodConnect ("we", "our", or "us") operates the BloodConnect mobile and web platform. Our primary mission is to save lives by bridging the gap between voluntary blood donors and emergency patients or blood banks. We treat your personal health and contact data with highest confidentiality and strictly follow data protection principles.'
        ],
        [
            'id' => 'info_collected',
            'title' => '2. Information We Collect',
            'content' => 'To facilitate blood donation searches, we collect the following user-provided information:',
            'bullets' => [
                'Account Information: Full name, mobile phone number, optional WhatsApp number, and encrypted authentication credentials.',
                'Donor Profile: Blood group (A+, A-, B+, B-, O+, O-, AB+, AB-, Bombay group), date of birth / age, gender, and last blood donation date.',
                'Location Information: State, district, area/landmark, 6-digit postal pincode, and optional GPS coordinates (latitude and longitude) provided during registration or search.',
                'Emergency Requests: Blood group required, units needed, hospital/patient details, contact person name, and urgency level.'
            ]
        ],
        [
            'id' => 'location_policy',
            'title' => '3. Location Data & Background/Foreground Tracking',
            'content' => 'Blood donation is time-critical. We utilize location data under strict parameters:',
            'bullets' => [
                'Purpose: To compute distance (in kilometers) and display nearby compatible donors on map searches.',
                'Explicit Consent: Location is accessed only when you grant runtime GPS permissions or manually select your state and district.',
                'Privacy Protection: We do not continuously broadcast your real-time GPS location in the background when the app is closed. Donors can also choose to display their general area/district instead of exact building addresses.',
                'Revocation: You may revoke location permissions at any time via your device settings or update your registered area directly in the app.'
            ]
        ],
        [
            'id' => 'data_usage',
            'title' => '4. How We Use Your Data',
            'content' => 'We use the collected information solely for genuine humanitarian and healthcare purposes:',
            'bullets' => [
                'Connecting urgent blood seekers with compatible donors in proximity.',
                'Determining donor donation eligibility (tracking the recommended 6-month resting interval).',
                'Enabling direct phone calls or WhatsApp messages between verified seekers and available donors.',
                'Sending push notifications or alerts regarding critical nearby blood shortages.',
                'Preventing spam, fake requests, and abusive registrations.'
            ]
        ],
        [
            'id' => 'data_sharing',
            'title' => '5. Data Sharing & Third-Party Disclosure',
            'content' => 'We maintain a strict NO-SALE policy regarding user data:',
            'bullets' => [
                'We NEVER sell, rent, monetize, or trade your personal or health data to commercial advertisers, data brokers, or marketing networks.',
                'Peer-to-Peer Visibility: When you register as an "Available" donor, your name, blood group, area/district, distance, and contact number are visible to registered app users looking for blood.',
                'Service Providers: We use secure infrastructure (e.g. Google Maps SDK for maps, SMS gateways for OTP verification). These vendors only process data necessary for core features.',
                'Legal Obligations: We may disclose information only if required by valid court orders, applicable law enforcement directives, or to prevent imminent physical harm.'
            ]
        ],
        [
            'id' => 'security',
            'title' => '6. Data Security & Storage Standards',
            'content' => 'Your information is protected using modern industry-grade safeguards:',
            'bullets' => [
                'Data in Transit: All API communications are encrypted using HTTPS / TLS protocol.',
                'Authentication: Passwords and security tokens are securely hashed and stored in isolated relational databases.',
                'Server Protection: SQL injection safeguards, prepared statements, and rate-limiting are enforced on backend endpoints.'
            ]
        ],
        [
            'id' => 'user_rights',
            'title' => '7. Your Rights & Account Deletion',
            'content' => 'You hold full control over your profile and availability:',
            'bullets' => [
                'Availability Status: You can set your status to "Unavailable" or "Busy" at any time to temporarily stop receiving donation calls.',
                'Edit Profile: You can update your phone number, location, address, or last donation date anytime in the app.',
                'Account & Data Deletion: You have the right to permanently delete your account and all associated personal data. Contact us at privacy@bloodconnect.org or use the in-app deletion option to erase your profile within 48 hours.'
            ]
        ],
        [
            'id' => 'medical_disclaimer',
            'title' => '8. Medical Disclaimer & Age Requirement (18+)',
            'content' => 'BloodConnect is a technological communication platform, not a certified clinical laboratory or hospital. Donors must be at least 18 years of age and meet official medical fitness guidelines prior to donating blood. Patients and blood seekers are strictly advised to follow authorized blood bank safety screening tests (such as cross-matching and disease screenings) before transfusion.'
        ],
        [
            'id' => 'grievance',
            'title' => '9. Grievance Officer & Contact Information',
            'content' => 'If you have any questions, privacy concerns, grievance requests, or desire data deletion, please contact our dedicated Grievance Officer:',
            'contact' => [
                'Title' => 'Data Protection & Grievance Officer',
                'Organization' => 'BloodConnect Team',
                'Email' => 'privacy@bloodconnect.org',
                'Phone' => '+91 1800-BLOOD-HELP',
                'Response Time' => 'Within 48 business hours'
            ]
        ]
    ]
];

// If JSON was requested, output JSON and exit
if ($isJson) {
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    echo json_encode([
        'success' => true,
        'message' => 'Privacy policy retrieved successfully',
        'data' => $policyData
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

// Otherwise render the full responsive HTML page
header("Content-Type: text/html; charset=UTF-8");
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Official Privacy Policy and Terms for BloodConnect - Blood Donor Search Platform. Learn how we safeguard donor and patient data.">
    <meta name="author" content="BloodConnect Team">
    <meta name="theme-color" content="#D32F2F">
    <title>Privacy Policy - BloodConnect</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #D32F2F;
            --primary-dark: #B71C1C;
            --primary-light: #FFCDD2;
            --primary-soft: #FFF5F5;
            --secondary: #1E293B;
            --text-primary: #0F172A;
            --text-secondary: #475569;
            --text-muted: #64748B;
            --bg: #F8FAFC;
            --card-bg: #FFFFFF;
            --border: #E2E8F0;
            --green-badge: #10B981;
            --green-badge-bg: #ECFDF5;
            --blue-badge: #2563EB;
            --blue-badge-bg: #EFF6FF;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
            --shadow-md: 0 4px 6px -1px rgba(0,0,0,0.07), 0 2px 4px -1px rgba(0,0,0,0.04);
            --shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.08), 0 4px 6px -2px rgba(0,0,0,0.04);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Plus Jakarta Sans', 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background-color: var(--bg);
            color: var(--text-primary);
            line-height: 1.65;
            -webkit-font-smoothing: antialiased;
        }

        /* Top Navbar */
        .navbar {
            background-color: #FFFFFF;
            border-bottom: 1px solid var(--border);
            position: sticky;
            top: 0;
            z-index: 50;
            box-shadow: var(--shadow-sm);
        }

        .nav-container {
            max-width: 1040px;
            margin: 0 auto;
            padding: 14px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .brand-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            color: var(--text-primary);
        }

        .brand-icon {
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, #FF1744 0%, #D32F2F 100%);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            box-shadow: 0 4px 10px rgba(211, 47, 47, 0.35);
        }

        .brand-title {
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .brand-title span {
            color: var(--primary);
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-outline {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            background: #FFFFFF;
            border: 1px solid var(--border);
            border-radius: 8px;
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .btn-outline:hover {
            color: var(--primary);
            border-color: var(--primary-light);
            background: var(--primary-soft);
        }

        /* Hero Header */
        .hero {
            background: linear-gradient(180deg, #FFFFFF 0%, #FFF5F5 100%);
            border-bottom: 1px solid var(--border);
            padding: 48px 24px 36px;
            text-align: center;
        }

        .hero-container {
            max-width: 800px;
            margin: 0 auto;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 14px;
            border-radius: 9999px;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.3px;
            text-transform: uppercase;
            margin-bottom: 14px;
        }

        .badge-red {
            background-color: var(--primary-soft);
            color: var(--primary);
            border: 1px solid var(--primary-light);
        }

        .badge-green {
            background-color: var(--green-badge-bg);
            color: var(--green-badge);
            border: 1px solid #A7F3D0;
        }

        .hero h1 {
            font-size: 36px;
            font-weight: 800;
            letter-spacing: -0.8px;
            color: var(--secondary);
            margin-bottom: 12px;
        }

        .hero p {
            font-size: 16px;
            color: var(--text-secondary);
            max-width: 650px;
            margin: 0 auto 16px;
        }

        .meta-info {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 20px;
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 500;
            flex-wrap: wrap;
        }

        /* Main Content Container */
        .main-container {
            max-width: 1040px;
            margin: 36px auto 60px;
            padding: 0 24px;
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 32px;
        }

        /* Quick Navigation Sidebar */
        .sidebar {
            position: sticky;
            top: 86px;
            align-self: start;
        }

        .sidebar-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            box-shadow: var(--shadow-sm);
        }

        .sidebar-title {
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: var(--text-muted);
            margin-bottom: 14px;
        }

        .sidebar-nav {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .sidebar-nav a {
            display: block;
            padding: 8px 12px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            text-decoration: none;
            transition: all 0.15s ease;
        }

        .sidebar-nav a:hover {
            color: var(--primary);
            background: var(--primary-soft);
        }

        /* Highlights Card */
        .highlights-card {
            background: linear-gradient(135deg, #FEF2F2 0%, #FFFFFF 100%);
            border: 1px solid var(--primary-light);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 28px;
            box-shadow: var(--shadow-sm);
        }

        .highlights-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 16px;
        }

        .highlights-header h3 {
            font-size: 17px;
            font-weight: 800;
            color: var(--primary);
        }

        .highlights-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 14px;
        }

        .highlight-item {
            background: #FFFFFF;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px;
            display: flex;
            gap: 12px;
            align-items: flex-start;
        }

        .highlight-icon {
            font-size: 20px;
            flex-shrink: 0;
        }

        .highlight-item h4 {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 2px;
        }

        .highlight-item p {
            font-size: 12px;
            color: var(--text-secondary);
            line-height: 1.4;
        }

        /* Content Sections */
        .content-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 28px;
            margin-bottom: 24px;
            box-shadow: var(--shadow-sm);
            scroll-margin-top: 96px;
        }

        .section-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 14px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border);
        }

        .section-number {
            width: 32px;
            height: 32px;
            background: var(--primary-soft);
            color: var(--primary);
            font-weight: 800;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
        }

        .section-header h2 {
            font-size: 19px;
            font-weight: 800;
            color: var(--secondary);
            letter-spacing: -0.3px;
        }

        .content-card p {
            font-size: 14.5px;
            color: var(--text-secondary);
            margin-bottom: 12px;
        }

        .content-card ul {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin: 14px 0;
        }

        .content-card ul li {
            font-size: 14px;
            color: var(--text-secondary);
            position: relative;
            padding-left: 24px;
        }

        .content-card ul li::before {
            content: "✓";
            position: absolute;
            left: 0;
            top: 1px;
            color: var(--primary);
            font-weight: 800;
            font-size: 14px;
        }

        /* Contact Table */
        .contact-box {
            background: #F8FAFC;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 16px 20px;
            margin-top: 16px;
        }

        .contact-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid var(--border);
            font-size: 13.5px;
        }

        .contact-row:last-child {
            border-bottom: none;
        }

        .contact-label {
            font-weight: 600;
            color: var(--text-muted);
        }

        .contact-val {
            font-weight: 700;
            color: var(--text-primary);
        }

        .contact-val a {
            color: var(--primary);
            text-decoration: none;
        }

        /* Footer */
        .footer {
            background: #FFFFFF;
            border-top: 1px solid var(--border);
            padding: 36px 24px;
            text-align: center;
            font-size: 13px;
            color: var(--text-muted);
        }

        .footer-links {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 14px;
        }

        .footer-links a {
            color: var(--text-secondary);
            text-decoration: none;
            font-weight: 600;
        }

        .footer-links a:hover {
            color: var(--primary);
        }

        /* Responsive */
        @media (max-width: 860px) {
            .main-container {
                grid-template-columns: 1fr;
            }

            .sidebar {
                display: none;
            }

            .hero h1 {
                font-size: 28px;
            }

            .content-card {
                padding: 20px;
            }
        }

        @media print {
            .navbar, .sidebar, .btn-outline, .footer-links {
                display: none !important;
            }
            .main-container {
                display: block;
                margin: 0;
                padding: 0;
            }
            .content-card {
                border: 1px solid #ccc;
                box-shadow: none;
                page-break-inside: avoid;
            }
        }
    </style>
</head>
<body>

    <!-- Top Navigation -->
    <header class="navbar">
        <div class="nav-container">
            <a href="index.php" class="brand-logo">
                <div class="brand-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/>
                    </svg>
                </div>
                <div class="brand-title">Blood<span>Connect</span></div>
            </a>
            <div class="nav-actions">
                <a href="?format=json" class="btn-outline" target="_blank" title="View Machine-Readable JSON API">
                    <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"/>
                    </svg>
                    API JSON
                </a>
                <button onclick="window.print()" class="btn-outline">
                    <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4H7v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                    </svg>
                    Print
                </button>
            </div>
        </div>
    </header>

    <!-- Hero Header -->
    <section class="hero">
        <div class="hero-container">
            <div class="badge badge-red">Emergency Healthcare Platform</div>
            <div class="badge badge-green">Google Play & Health Compliant</div>
            <h1>Privacy Policy & Data Protection</h1>
            <p>Your privacy is as critical as saving lives. Here is how BloodConnect collects, protects, and strictly respects donor and recipient information.</p>
            <div class="meta-info">
                <span><strong>Effective Date:</strong> <?php echo htmlspecialchars($policyData['last_updated']); ?></span>
                <span>•</span>
                <span><strong>Platform Version:</strong> <?php echo htmlspecialchars($policyData['version']); ?></span>
                <span>•</span>
                <span><strong>Scope:</strong> Mobile App (Android/iOS) & REST API</span>
            </div>
        </div>
    </section>

    <!-- Main Content -->
    <main class="main-container">

        <!-- Sidebar Navigation -->
        <aside class="sidebar">
            <div class="sidebar-card">
                <div class="sidebar-title">Table of Contents</div>
                <ul class="sidebar-nav">
                    <li><a href="#intro">1. Introduction & Mission</a></li>
                    <li><a href="#info_collected">2. Information We Collect</a></li>
                    <li><a href="#location_policy">3. Location & GPS Tracking</a></li>
                    <li><a href="#data_usage">4. How We Use Data</a></li>
                    <li><a href="#data_sharing">5. Zero Data-Sale Policy</a></li>
                    <li><a href="#security">6. Data Security & Storage</a></li>
                    <li><a href="#user_rights">7. Your Rights & Deletion</a></li>
                    <li><a href="#medical_disclaimer">8. Medical Disclaimer (18+)</a></li>
                    <li><a href="#grievance">9. Grievance & Support</a></li>
                </ul>
            </div>
        </aside>

        <!-- Body Content -->
        <div class="content-area">

            <!-- Summary at a Glance -->
            <div class="highlights-card">
                <div class="highlights-header">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="#D32F2F">
                        <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/>
                    </svg>
                    <h3>Privacy Commitments at a Glance</h3>
                </div>
                <div class="highlights-grid">
                    <div class="highlight-item">
                        <div class="highlight-icon">🚫</div>
                        <div>
                            <h4>No Data Selling</h4>
                            <p>We never sell, trade, or monetize your contact or health records with marketing companies.</p>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="highlight-icon">📍</div>
                        <div>
                            <h4>Location Transparency</h4>
                            <p>GPS is accessed solely to calculate distance to patients in need, with no background spying.</p>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="highlight-icon">🔒</div>
                        <div>
                            <h4>Full Control</h4>
                            <p>Toggle availability anytime to stop calls, or request complete account & data deletion.</p>
                        </div>
                    </div>
                    <div class="highlight-item">
                        <div class="highlight-icon">🩸</div>
                        <div>
                            <h4>100% Volunteer</h4>
                            <p>Non-commercial platform built exclusively to support voluntary, unpaid blood donations.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section 1 -->
            <article class="content-card" id="intro">
                <div class="section-header">
                    <div class="section-number">1</div>
                    <h2>Introduction & Mission</h2>
                </div>
                <p>BloodConnect ("we", "our", or "us") operates the BloodConnect mobile and web applications. Our primary mission is to save lives during critical medical shortages by bridging the communication gap between voluntary blood donors and emergency patients, hospitals, or blood banks.</p>
                <p>We treat your personal health, contact, and location information with the utmost integrity and strict confidentiality in adherence to relevant digital data privacy regulations and store policies.</p>
            </article>

            <!-- Section 2 -->
            <article class="content-card" id="info_collected">
                <div class="section-header">
                    <div class="section-number">2</div>
                    <h2>Information We Collect</h2>
                </div>
                <p>To enable fast, accurate matching during medical emergencies, we collect only necessary information that you voluntarily provide:</p>
                <ul>
                    <li><strong>Account & Identity:</strong> Full Name, mobile phone number, optional WhatsApp contact, and secure hashed authentication credentials.</li>
                    <li><strong>Donor Profile Details:</strong> Blood Group (A+, A-, B+, B-, O+, O-, AB+, AB-, Bombay group), Date of Birth / Age, Gender, and Last Blood Donation Date (to compute 6-month clinical eligibility).</li>
                    <li><strong>Location Information:</strong> State, District, Area / Landmark, 6-digit Pincode, and optional GPS coordinates (latitude & longitude) captured during location-based searches.</li>
                    <li><strong>Emergency Blood Requests:</strong> Required blood group, units requested, patient/hospital name, contact person details, and urgency status.</li>
                </ul>
            </article>

            <!-- Section 3 -->
            <article class="content-card" id="location_policy">
                <div class="section-header">
                    <div class="section-number">3</div>
                    <h2>Location Data & GPS Tracking Disclosures</h2>
                </div>
                <p>Because blood donations are inherently time-sensitive, location services are integral to finding immediate assistance. We disclose the following location practices in full compliance with Google Play Developer Policy:</p>
                <ul>
                    <li><strong>Purpose of Access:</strong> Location coordinates are used exclusively to calculate physical distance (in kilometers using Haversine algorithm) between the requester's hospital and nearby registered donors.</li>
                    <li><strong>Foreground / User-Initiated:</strong> Location coordinates are retrieved only when you actively trigger the "Use Current Location" or "Nearby Map Search" features in the app.</li>
                    <li><strong>No Continuous Background Tracking:</strong> The application does NOT run background location tracking or continuously log your geographic trajectory when the app is closed.</li>
                    <li><strong>Address Protection:</strong> Exact residential street names and house numbers are never publicly broadcast on public maps. Only the general area/district and calculated distance are displayed.</li>
                    <li><strong>User Control:</strong> You can revoke location permissions at any time via Android / iOS device settings without losing access to manual state/district searches.</li>
                </ul>
            </article>

            <!-- Section 4 -->
            <article class="content-card" id="data_usage">
                <div class="section-header">
                    <div class="section-number">4</div>
                    <h2>How We Use Your Data</h2>
                </div>
                <p>Your data is used strictly to facilitate life-saving donor connections:</p>
                <ul>
                    <li>Matching urgent patient blood requests with compatible, nearby donors.</li>
                    <li>Determining medical donation eligibility based on the minimum 6-month interval from the donor's previous donation.</li>
                    <li>Enabling direct calling and messaging via phone or WhatsApp when a patient is in immediate need.</li>
                    <li>Sending critical emergency alerts and blood request notifications.</li>
                    <li>Verifying phone numbers and mitigating spam or false requests.</li>
                </ul>
            </article>

            <!-- Section 5 -->
            <article class="content-card" id="data_sharing">
                <div class="section-header">
                    <div class="section-number">5</div>
                    <h2>Strict Zero Data-Sale Policy & Peer Visibility</h2>
                </div>
                <p><strong>We will never sell, lease, or monetize your personal, contact, or health data to advertisers, commercial brokers, or marketing third parties.</strong></p>
                <ul>
                    <li><strong>Peer-to-Peer Visibility:</strong> When you register as an available donor, your donor card (displaying your Name, Blood Group, District/Area, Distance, and Phone Number) is visible to registered users searching for compatible donors in your vicinity.</li>
                    <li><strong>Infrastructure Partners:</strong> We utilize trusted platform service providers (such as Google Maps API for map rendering and SMS gateways for OTPs). These entities process data solely on our behalf under strict confidentiality.</li>
                    <li><strong>Legal & Emergency Disclosures:</strong> We will disclose records only if strictly mandated by court subpoenas, applicable government regulations, or to prevent imminent danger to life or safety.</li>
                </ul>
            </article>

            <!-- Section 6 -->
            <article class="content-card" id="security">
                <div class="section-header">
                    <div class="section-number">6</div>
                    <h2>Data Security & Encryption Standards</h2>
                </div>
                <p>We implement robust technical and organizational security measures to protect your sensitive records:</p>
                <ul>
                    <li><strong>Encryption in Transit:</strong> All communications between the mobile application and our backend server are protected by industry-standard HTTPS / TLS 1.3 encryption.</li>
                    <li><strong>Credential Protection:</strong> Passwords and authorization tokens are hashed using secure cryptographic algorithms.</li>
                    <li><strong>Database Safeguards:</strong> All queries use parameterized prepared statements to eliminate SQL injection vulnerabilities, with strict access control firewalls.</li>
                </ul>
            </article>

            <!-- Section 7 -->
            <article class="content-card" id="user_rights">
                <div class="section-header">
                    <div class="section-number">7</div>
                    <h2>Your Rights & Account Deletion</h2>
                </div>
                <p>You maintain complete control over your participation and information in BloodConnect:</p>
                <ul>
                    <li><strong>Availability Toggle:</strong> If you are busy, traveling, unwell, or recently donated, you can switch your availability status to "Unavailable" or "Busy" with one tap in your profile. You will not receive emergency alerts during this period.</li>
                    <li><strong>Profile Modification:</strong> You can edit your phone number, area, district, and donation history at any time.</li>
                    <li><strong>Account & Data Deletion:</strong> You have the absolute right to permanently delete your account and remove all personal information from our database. To request immediate deletion, email <a href="mailto:privacy@bloodconnect.org" style="color:var(--primary); font-weight:700;">privacy@bloodconnect.org</a> with your registered phone number, and records will be expunged within 48 business hours.</li>
                </ul>
            </article>

            <!-- Section 8 -->
            <article class="content-card" id="medical_disclaimer">
                <div class="section-header">
                    <div class="section-number">8</div>
                    <h2>Medical Disclaimer & Age Requirement (18+)</h2>
                </div>
                <p>BloodConnect is an informational technological platform connecting voluntary donors and patients. We are not a medical testing facility, healthcare provider, or clinical diagnostic laboratory.</p>
                <ul>
                    <li><strong>Age Requirement:</strong> All registered donors must be at least 18 years of age in compliance with standard national transfusion guidelines.</li>
                    <li><strong>Clinical Verification:</strong> Blood recipients and hospital blood banks must conduct all mandatory medical safety screenings (e.g. cross-matching, blood grouping confirmation, HIV, Hepatitis, and infectious disease screenings) before proceeding with transfusion.</li>
                    <li><strong>Voluntary & Unpaid:</strong> Blood donation on BloodConnect is 100% voluntary. Buying or selling human blood is illegal and strictly prohibited on our platform.</li>
                </ul>
            </article>

            <!-- Section 9 -->
            <article class="content-card" id="grievance">
                <div class="section-header">
                    <div class="section-number">9</div>
                    <h2>Grievance Officer & Contact Information</h2>
                </div>
                <p>For inquiries, clarification, feedback, or grievance redressal regarding your privacy, please reach out to our designated Data Protection & Grievance team:</p>
                <div class="contact-box">
                    <div class="contact-row">
                        <span class="contact-label">Designation</span>
                        <span class="contact-val">Grievance & Privacy Officer</span>
                    </div>
                    <div class="contact-row">
                        <span class="contact-label">Organization</span>
                        <span class="contact-val">BloodConnect Foundation</span>
                    </div>
                    <div class="contact-row">
                        <span class="contact-label">Official Email</span>
                        <span class="contact-val"><a href="mailto:privacy@bloodconnect.org">privacy@bloodconnect.org</a></span>
                    </div>
                    <div class="contact-row">
                        <span class="contact-label">Helpline</span>
                        <span class="contact-val"><a href="tel:+911800256634">+91 1800-BLOOD-HELP</a></span>
                    </div>
                    <div class="contact-row">
                        <span class="contact-label">Expected Resolution</span>
                        <span class="contact-val">Within 48 hours</span>
                    </div>
                </div>
            </article>

        </div>
    </main>

    <!-- Footer -->
    <footer class="footer">
        <div class="footer-links">
            <a href="index.php">Privacy Policy</a>
            <span>•</span>
            <a href="?format=json">API Specification</a>
            <span>•</span>
            <a href="mailto:support@bloodconnect.org">Support</a>
        </div>
        <p>&copy; <?php echo date('Y'); ?> BloodConnect Platform. All rights reserved. Built with care for life-saving donor connections.</p>
    </footer>

</body>
</html>
