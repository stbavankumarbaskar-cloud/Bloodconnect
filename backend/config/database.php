<?php
// ======================================================
// BloodConnect - Database Configuration
// ======================================================

class Database {
    private static $instance = null;
    private $conn = null;

    private $host;
    private $port;
    private $db_name;
    private $username;
    private $password;

    private function __construct() {
        // Automatically load environment variables from backend/.env if available
        self::loadEnv();

        // Read from environment if set, else sensible defaults
        $this->host = self::getEnvVar('DB_HOST', '127.0.0.1');
        $this->port = self::getEnvVar('DB_PORT', '3305');
        $this->db_name = self::getEnvVar('DB_NAME', 'bloodconnect_db');
        $this->username = self::getEnvVar('DB_USER', 'root');
        $this->password = self::getEnvVar('DB_PASSWORD', '');

        // Try primary port, with fallback to 3305 and 3306 if needed
        $ports = array_unique([$this->port, '3305', '3306']);
        $lastError = null;

        foreach ($ports as $tryPort) {
            try {
                $dsn = "mysql:host={$this->host};port={$tryPort};dbname={$this->db_name};charset=utf8mb4";
                $options = [
                    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES   => false,
                ];
                $this->conn = new PDO($dsn, $this->username, $this->password, $options);
                $this->port = $tryPort;
                break;
            } catch (PDOException $e) {
                $lastError = $e->getMessage();
            }
        }

        if (!$this->conn) {
            http_response_code(500);
            header('Content-Type: application/json');
            echo json_encode([
                'success' => false,
                'message' => 'Database connection failed: ' . $lastError
            ]);
            exit;
        }
    }

    /**
     * Load environment variables from backend/.env or root .env file
     */
    public static function loadEnv($envPath = null) {
        static $loaded = false;
        if ($loaded && $envPath === null) {
            return;
        }

        if ($envPath === null) {
            $backendEnv = dirname(__DIR__) . '/.env';
            $rootEnv = dirname(dirname(__DIR__)) . '/.env';

            if (file_exists($backendEnv)) {
                $envPath = $backendEnv;
            } elseif (file_exists($rootEnv)) {
                $envPath = $rootEnv;
            } else {
                return;
            }
        }

        if (!file_exists($envPath) || !is_readable($envPath)) {
            return;
        }

        $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            // Ignore empty lines and comments
            if ($line === '' || $line[0] === '#' || $line[0] === ';') {
                continue;
            }

            if (strpos($line, '=') !== false) {
                list($key, $val) = explode('=', $line, 2);
                $key = trim($key);
                $val = trim($val);

                // Strip outer quotes if present
                if (strlen($val) >= 2 && (
                    ($val[0] === '"' && substr($val, -1) === '"') ||
                    ($val[0] === "'" && substr($val, -1) === "'")
                )) {
                    $val = substr($val, 1, -1);
                }

                putenv("{$key}={$val}");
                $_ENV[$key] = $val;
                $_SERVER[$key] = $val;
            }
        }

        $loaded = true;
    }

    /**
     * Helper to read environment variable with fallback default
     */
    public static function getEnvVar($key, $default = '') {
        $val = getenv($key);
        if ($val !== false) {
            return $val;
        }
        if (isset($_ENV[$key])) {
            return $_ENV[$key];
        }
        if (isset($_SERVER[$key])) {
            return $_SERVER[$key];
        }
        return $default;
    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new Database();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->conn;
    }
}
