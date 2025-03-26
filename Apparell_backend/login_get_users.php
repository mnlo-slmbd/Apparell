<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Database configuration
$servername = "localhost";
$username = "root";
$password = ""; // Your database password
$dbname = "apparel"; // Replace with your database name

// Establish connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Retrieve and decode JSON body
$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    echo json_encode(["status" => "error", "message" => "Invalid JSON format"]);
    exit();
}

// Extract fields
$email = isset($data['email']) ? $data['email'] : null;
$password = isset($data['password']) ? $data['password'] : null;
$position = isset($data['position']) ? $data['position'] : null;

// Validate required fields
if ($email === null || $password === null || $position === null) {
    echo json_encode(["status" => "error", "message" => "Email, password, and position are required"]);
    exit();
}

// Prepare and execute SQL query to fetch user
$stmt = $conn->prepare("SELECT password FROM users WHERE email = ? AND position = ?");
$stmt->bind_param("ss", $email, $position);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    // Verify password
    if (password_verify($password, $user['password'])) {
        echo json_encode(["status" => "success", "message" => "Login successful"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid email or password"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid email, password, or position"]);
}

$stmt->close();
$conn->close();
?>
