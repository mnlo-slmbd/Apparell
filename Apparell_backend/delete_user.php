<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Database configuration
$servername = "localhost";
$username = "root";
$password = ""; // Replace with your DB password
$dbname = "apparel"; // Replace with your DB name

// Establish connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Get request body
$data = json_decode(file_get_contents("php://input"), true);
$email = isset($data['email']) ? $data['email'] : null;

if (!$email) {
    echo json_encode(["status" => "error", "message" => "Email is required"]);
    exit();
}

// Delete the user
$sql = "DELETE FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "User deleted successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to delete user: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
