<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

// Database connection
$conn = new mysqli("localhost", "root", "", "apparel");

if ($conn->connect_error) {
    error_log("Database Connection Error: " . $conn->connect_error);
    die(json_encode([
        "status" => "error",
        "message" => "Failed to connect to the database."
    ]));
}

// Debugging: Log POST and FILES data
error_log("POST Data: " . json_encode($_POST));
error_log("FILES Data: " . json_encode($_FILES));

// Validate input data
if (!isset($_POST['order_id']) || empty(trim($_POST['order_id'])) || !isset($_FILES['attachment'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Order ID and file are required."
    ]);
    exit;
}

$order_id = $conn->real_escape_string(trim($_POST['order_id']));
$file = $_FILES['attachment'];

// Validate file extension
$allowedExtensions = ['png', 'jpg', 'jpeg', 'pdf', 'cdr'];
$fileExtension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));

if (!in_array($fileExtension, $allowedExtensions)) {
    error_log("Invalid File Extension: " . $fileExtension);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid file type. Only PNG, JPG, JPEG, PDF, and CDR are allowed."
    ]);
    exit;
}

// Validate file size (max 10MB for CDR, 5MB for others)
$maxFileSize = ($fileExtension === 'cdr') ? (10 * 1024 * 1024) : (5 * 1024 * 1024);
if ($file['size'] > $maxFileSize) {
    error_log("File Too Large: " . $file['size']);
    echo json_encode([
        "status" => "error",
        "message" => "File size exceeds the allowed limit (5MB for images/PDFs, 10MB for CDR)."
    ]);
    exit;
}

// Check the actual MIME type of the file
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mimeType = finfo_file($finfo, $file['tmp_name']);
finfo_close($finfo);

$allowedMimeTypes = ['image/png', 'image/jpeg', 'application/pdf', 'application/x-cdr'];

if (!in_array($mimeType, $allowedMimeTypes) && $fileExtension !== 'cdr') {
    error_log("Invalid MIME Type: " . $mimeType);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid file type detected."
    ]);
    exit;
}

// Check if order ID exists
$orderCheckQuery = "SELECT order_id FROM orders WHERE order_id = ?";
$stmt = $conn->prepare($orderCheckQuery);
if (!$stmt) {
    error_log("Order Check Query Error: " . $conn->error);
    echo json_encode([
        "status" => "error",
        "message" => "Database error while verifying order ID."
    ]);
    exit;
}

$stmt->bind_param("s", $order_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    error_log("Invalid Order ID: " . $order_id);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid Order ID."
    ]);
    $stmt->close();
    exit;
}

$stmt->close();

// Ensure the upload directory exists
$uploadDir = "uploads/";
if (!file_exists($uploadDir) && !mkdir($uploadDir, 0777, true)) {
    error_log("Failed to Create Upload Directory: " . $uploadDir);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to create upload directory."
    ]);
    exit;
}

// Generate a unique file name to avoid conflicts
$fileName = time() . "_" . preg_replace("/[^a-zA-Z0-9.\-_]/", "_", basename($file['name']));
$targetFilePath = $uploadDir . $fileName;

// Move the uploaded file to the server directory
if (move_uploaded_file($file['tmp_name'], $targetFilePath)) {
    // Insert attachment record into the database
    $sql = "INSERT INTO order_attachments (order_id, attachment_path, uploaded_at) VALUES (?, ?, NOW())";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        error_log("Database Insert Error: " . $conn->error);
        echo json_encode([
            "status" => "error",
            "message" => "Database error while inserting attachment record."
        ]);
        exit;
    }

    $stmt->bind_param("ss", $order_id, $targetFilePath);

    if ($stmt->execute()) {
        echo json_encode([
            "status" => "success",
            "message" => "Attachment uploaded successfully.",
            "file_path" => $targetFilePath
        ]);
    } else {
        error_log("Database Execution Error: " . $stmt->error);
        echo json_encode([
            "status" => "error",
            "message" => "Failed to save attachment in the database."
        ]);
    }

    $stmt->close();
} else {
    error_log("Failed to Move Uploaded File: " . $file['tmp_name']);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to upload file."
    ]);
}

$conn->close();

?>
