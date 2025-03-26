<?php
header("Access-Control-Allow-Origin: *"); // Allow from any domain
header("Content-Type: application/json; charset=UTF-8");
header('Content-Type: application/json');

// Database connection
$conn = new mysqli('localhost', 'root', '', 'apparel');

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]);
    exit;
}

// Check if province_id is set
if (!isset($_GET['province_id'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing province_id parameter'
    ]);
    exit;
}

$provinceId = intval($_GET['province_id']); // Sanitize input

// Prepare SQL statement
$stmt = $conn->prepare("SELECT id, name FROM cities WHERE province_id = ? ORDER BY name ASC");
if (!$stmt) {
    echo json_encode([
        'success' => false,
        'message' => 'SQL prepare failed: ' . $conn->error
    ]);
    exit;
}

$stmt->bind_param("i", $provinceId);
$stmt->execute();

$result = $stmt->get_result();
$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

// Return result
echo json_encode($data);

// Close connections
$stmt->close();
$conn->close();
?>
