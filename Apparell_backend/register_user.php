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
$name = isset($data['name']) ? $data['name'] : null;
$store_name = isset($data['store_name']) ? $data['store_name'] : null;
$date_of_birth = isset($data['date_of_birth']) ? $data['date_of_birth'] : null;
$province = isset($data['province']) ? $data['province'] : null;
$email = isset($data['email']) ? $data['email'] : null;
$position = isset($data['position']) ? $data['position'] : null;
$mobile = isset($data['mobile']) ? $data['mobile'] : null;
$date_employed = isset($data['date_employed']) ? $data['date_employed'] : null;
$city = isset($data['city']) ? $data['city'] : null;
$password = isset($data['password']) ? $data['password'] : null; // ✅ No more hashing here

// Validate required fields
if ($name === null || $email === null || $password === null) {
    echo json_encode(["status" => "error", "message" => "Name, email, and password are required"]);
    exit();
}

// Prepare and execute SQL query
$stmt = $conn->prepare("INSERT INTO users (name, store_name, date_of_birth, province, email, position, mobile, date_employed, city, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssssssss", $name, $store_name, $date_of_birth, $province, $email, $position, $mobile, $date_employed, $city, $password);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "User added successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to add user: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
