<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "apparel";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit();
}

// Get storeCode from GET parameter (from frontend: storeCode=CFL)
$storeCode = isset($_GET['storeCode']) ? strtoupper(trim($_GET['storeCode'])) : '';

if (empty($storeCode)) {
    echo json_encode(["status" => "error", "message" => "Missing storeCode"]);
    exit();
}

// Fetch last used order_id for that store prefix
$sql = "SELECT order_id FROM orders 
        WHERE order_id LIKE '$storeCode-%' 
        ORDER BY CAST(SUBSTRING_INDEX(order_id, '-', -1) AS UNSIGNED) DESC 
        LIMIT 1";

$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $lastOrderId = $row["order_id"]; // e.g., CFL-005
} else {
    $lastOrderId = "$storeCode-000"; // No existing orders found
}

$conn->close();

// Return as JSON
echo json_encode([
    "status" => "success",
    "last_order_id" => $lastOrderId
]);
?>
