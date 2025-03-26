<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root";
$password = "";

$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}

// Get required query parameters
$month = $_GET['month'] ?? null;
$store = $_GET['store'] ?? null;

if (!$month || !$store) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing required parameters: month and/or store"
    ]);
    exit();
}

// Escape the store name for safety
$store = $conn->real_escape_string($store);

// Fetch monthly sales data
$sql = "
    SELECT 
        DATE(o.date_order) AS date_order,
        o.team_name,
        od.description AS item,
        od.qty,
        (od.qty * od.unit_price) AS total_sale
    FROM orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    WHERE DATE_FORMAT(o.date_order, '%Y-%m') = ? AND o.store = ?
    ORDER BY o.date_order ASC
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $month, $store);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "status" => "success",
    "data" => $data
]);

$stmt->close();
$conn->close();
?>
