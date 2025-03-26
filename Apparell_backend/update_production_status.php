<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root";
$password = "";
$conn = new mysqli($host, $username, $password, $db_name);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]);
    exit();
}

// Update `production_status` based on `delivery_status`
$updateQuery = "
    UPDATE orders
    SET production_status = CASE
        WHEN delivery_status = 'completed' THEN 'Ready for Delivery'
        WHEN delivery_status IN ('ongoing', 'pending') THEN 'In Progress'
        ELSE 'Unknown'
    END
";

if ($conn->query($updateQuery)) {
    echo json_encode(["status" => "success", "message" => "Production status updated successfully."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update production status: " . $conn->error]);
}

$conn->close();
?>
