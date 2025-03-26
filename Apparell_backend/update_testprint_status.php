<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root";
$password = "";

$conn = new mysqli($host, $username, $password, $db_name);

// Check database connection
if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}

// Read input data
$input = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($input['order_id']) || !isset($input['test_print_stage_status'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing required parameters: order_id or test_print_stage_status"
    ]);
    exit();
}

$order_id = $conn->real_escape_string($input['order_id']);
$test_print_stage_status = $conn->real_escape_string($input['test_print_stage_status']);

// Validate status
$valid_statuses = ['pending', 'completed', 'ongoing'];
if (!in_array($test_print_stage_status, $valid_statuses)) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid status value. Allowed values are: pending, completed, ongoing"
    ]);
    exit();
}

// Update the database
$sql_update = "UPDATE orders SET test_print_stage_status = '$test_print_stage_status' WHERE order_id = '$order_id'";
if ($conn->query($sql_update) === TRUE) {
    // Fetch updated data
    $sql_select = "SELECT order_id, test_print_stage_status FROM orders WHERE order_id = '$order_id'";
    $result = $conn->query($sql_select);

    if ($result && $result->num_rows > 0) {
        $order = $result->fetch_assoc();
        echo json_encode([
            "status" => "success",
            "message" => "Status updated successfully.",
            "updated_order" => $order
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Failed to fetch the updated order."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to update the status: " . $conn->error
    ]);
}

$conn->close();
?>
