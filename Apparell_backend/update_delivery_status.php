<?php
// Set response headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Database connection details
$host = "localhost";
$db_name = "apparel"; // Replace with your database name
$username = "root"; // Replace with your database username
$password = ""; // Replace with your database password

// Establish the database connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check if the connection is successful
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
if (!isset($input['order_id']) || !isset($input['delivery_status'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing required parameters: order_id or delivery_status"
    ]);
    exit();
}

$order_id = $conn->real_escape_string($input['order_id']);
$delivery_status = $conn->real_escape_string($input['delivery_status']);

// Validate the status value
$valid_statuses = ['pending', 'ongoing', 'completed'];
if (!in_array($delivery_status, $valid_statuses)) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid status value. Allowed values are: pending, ongoing, completed"
    ]);
    exit();
}

// Determine the production_status based on delivery_status
$production_status = null;
if ($delivery_status === 'completed') {
    $production_status = 'Ready for Delivery';
} elseif (in_array($delivery_status, ['pending', 'ongoing'])) {
    $production_status = 'In Progress';
}

// Update the delivery_status and production_status in the database
$sql_update = "UPDATE orders SET delivery_status = '$delivery_status'";

if ($production_status !== null) {
    $sql_update .= ", production_status = '$production_status'";
}

$sql_update .= " WHERE order_id = '$order_id'";

if ($conn->query($sql_update) === TRUE) {
    // Fetch the updated order details
    $sql_select = "SELECT order_id, delivery_status, production_status FROM orders WHERE order_id = '$order_id'";
    $result = $conn->query($sql_select);

    if ($result->num_rows > 0) {
        $order = $result->fetch_assoc();
        echo json_encode([
            "status" => "success",
            "message" => "Delivery status updated successfully.",
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
