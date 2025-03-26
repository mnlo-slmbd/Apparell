<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root"; // Replace with your DB username
$password = "";     // Replace with your DB password

$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]));
}

// Retrieve JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($data["order_id"])) {
    echo json_encode(["status" => "error", "message" => "Invalid input: order_id is required"]);
    exit();
}

$order_id = $conn->real_escape_string($data["order_id"]);

// Begin transaction
$conn->begin_transaction();

try {
    // Delete from order_details table
    $delete_details_query = "DELETE FROM order_details WHERE order_id = '$order_id'";
    if (!$conn->query($delete_details_query)) {
        throw new Exception("Failed to delete order details: " . $conn->error);
    }

    // Delete from orders table
    $delete_order_query = "DELETE FROM orders WHERE order_id = '$order_id'";
    if (!$conn->query($delete_order_query)) {
        throw new Exception("Failed to delete order: " . $conn->error);
    }

    // Commit transaction
    $conn->commit();
    echo json_encode(["status" => "success", "message" => "Order and associated details deleted successfully"]);
} catch (Exception $e) {
    // Rollback transaction on error
    $conn->rollback();
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}

$conn->close();
?>
