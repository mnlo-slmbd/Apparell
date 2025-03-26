<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

// Connect to the database
$conn = new mysqli("localhost", "root", "", "apparel");

// Check for connection error
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Decode the JSON request body
$data = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($data['name']) || !isset($data['price']) || !isset($data['status'])) {
    echo json_encode(["status" => "error", "message" => "Invalid input."]);
    exit;
}

$name = $data['name'];
$price = $data['price'];
$status = $data['status'];

// Insert into the database and set the current date
$sql = "INSERT INTO products (name, price, status, date) VALUES (?, ?, ?, NOW())";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sds", $name, $price, $status);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Product added successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
