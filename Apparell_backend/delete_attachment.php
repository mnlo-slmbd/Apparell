<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// DB connection
$host = "localhost";
$db_name = "apparel";
$username = "root";
$password = "";

$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit();
}

// Get JSON input
$data = json_decode(file_get_contents("php://input"), true);
$attachment_id = $data['attachment_id'] ?? '';

if (empty($attachment_id)) {
    echo json_encode(["status" => "error", "message" => "Missing attachment ID"]);
    exit();
}

// Get file path first
$sql = "SELECT attachment_path FROM order_attachments WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $attachment_id); // Note: ID is integer
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

if (!$row) {
    echo json_encode(["status" => "error", "message" => "Attachment not found"]);
    exit();
}

// Delete the file from server
$filePath = $row['attachment_path'];
if (file_exists($filePath)) {
    unlink($filePath); // Remove file
}

// Delete from database
$sql = "DELETE FROM order_attachments WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $attachment_id);
$stmt->execute();

if ($stmt->affected_rows > 0) {
    echo json_encode(["status" => "success", "message" => "Attachment deleted"]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to delete"]);
}

$stmt->close();
$conn->close();
?>
