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
        // Read from environment if set, else sensible defaults
        $this->host = getenv('DB_HOST') ?: '127.0.0.1';
        $this->port = getenv('DB_PORT') ?: '3305';
        $this->db_name = getenv('DB_NAME') ?: 'bloodconnect_db';
        $this->username = getenv('DB_USER') ?: 'root';
        $this->password = getenv('DB_PASSWORD') !== false ? getenv('DB_PASSWORD') : '';

        // Try primary port (3305), with fallback to 3306 if needed
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
