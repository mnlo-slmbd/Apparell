<?php
// Set response headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root"; // Replace with your DB username
$password = "";     // Replace with your DB password

$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]));
}

// Read input data
$input = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($input["order_id"]) || empty($input["order_id"])) {
    echo json_encode(["status" => "error", "message" => "Missing or invalid order_id"]);
    exit();
}

$order_id = $conn->real_escape_string($input["order_id"]);

// Update the test_print_status in the orders table
$update_query = "UPDATE orders SET test_print_status = 'sent', layout_status = 'completed' WHERE order_id = '$order_id'";

if ($conn->query($update_query) === TRUE) {
    echo json_encode([
        "status" => "success",
        "message" => "Order successfully sent to Test Print and layout status updated to completed."
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to update order: " . $conn->error
    ]);
}

$conn->close();
?>
