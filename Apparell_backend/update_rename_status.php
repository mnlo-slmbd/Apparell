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

// Check database connection
if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}

// Read input data from the POST request
$input = json_decode(file_get_contents("php://input"), true);

// Validate the input
if (!isset($input['order_id']) || !isset($input['rename_status'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing required parameters: order_id or rename_status"
    ]);
    exit();
}

$order_id = $conn->real_escape_string($input['order_id']);
$rename_status = $conn->real_escape_string($input['rename_status']);

// Validate the status value
$valid_statuses = ['pending', 'completed', 'ongoing'];
if (!in_array($rename_status, $valid_statuses)) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid status value. Allowed values are: pending, completed, ongoing"
    ]);
    exit();
}

// Update the rename_status in the database
$sql_update = "UPDATE orders SET rename_status = '$rename_status' WHERE order_id = '$order_id'";

if ($conn->query($sql_update) === TRUE) {
    // Fetch the updated order details
    $sql_select = "SELECT order_id, rename_status FROM orders WHERE order_id = '$order_id'";
    $result = $conn->query($sql_select);

    if ($result->num_rows > 0) {
        $order = $result->fetch_assoc();
        echo json_encode([
            "status" => "success",
            "message" => "Rename status updated successfully.",
            "updated_order" => $order
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Order not found after update."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to update the status: " . $conn->error
    ]);
}

// Close the database connection
$conn->close();
?>
