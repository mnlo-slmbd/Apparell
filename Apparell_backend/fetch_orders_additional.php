<?php
// Set response headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database connection details
$host = "localhost";
$db_name = "apparel"; // Replace with your database name
$username = "root";   // Replace with your database username
$password = "";       // Replace with your database password

// Create a new connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}

// SQL query to fetch orders where store is 'Zus Customs'
$sql = "
    SELECT 
        team_name, 
        order_id, 
        order_type, 
        date_order, 
        delivery_date, 
        store
    FROM orders
    WHERE store = 'Zus Customs'
    ORDER BY delivery_date ASC
";

$result = $conn->query($sql);

if ($result) {
    $orders = [];
    while ($row = $result->fetch_assoc()) {
        $orders[] = $row;
    }

    echo json_encode([
        "status" => "success",
        "orders" => $orders
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch orders: " . $conn->error
    ]);
}

// Close the connection
$conn->close();
?>
