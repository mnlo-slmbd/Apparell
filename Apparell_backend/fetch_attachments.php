<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");


// Database connection
$conn = new mysqli("localhost", "root", "", "apparel");

if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to connect to the database."
    ]);
    exit;
}

// Validate input
if (!isset($_GET['order_id']) || empty(trim($_GET['order_id']))) {
    echo json_encode([
        "status" => "error",
        "message" => "Order ID is required."
    ]);
    exit;
}

$order_id = $conn->real_escape_string(trim($_GET['order_id']));

// Fetch attachments for the given order ID
$query = "SELECT id, order_id, attachment_path, uploaded_at FROM order_attachments WHERE TRIM(order_id) = ?";
$stmt = $conn->prepare($query);

if (!$stmt) {
    echo json_encode([
        "status" => "error",
        "message" => "Database error while preparing query."
    ]);
    exit;
}

$stmt->bind_param("s", $order_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $attachments = [];
    while ($row = $result->fetch_assoc()) {
        $attachments[] = [
            "id" => $row["id"],
            "order_id" => $row["order_id"],
            "file_name" => basename($row["attachment_path"]),
            "attachment_path" => $row["attachment_path"],
            "uploaded_at" => $row["uploaded_at"]
        ];
    }
    echo json_encode([
        "status" => "success",
        "attachments" => $attachments
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "No attachments found for the given order ID."
    ]);
}

$stmt->close();
$conn->close();
