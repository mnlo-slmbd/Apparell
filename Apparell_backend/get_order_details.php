<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Origin: *");


// Database connection
$host = "localhost";
$db_name = "apparel"; // Replace with your database name
$username = "root"; // Replace with your database username
$password = ""; // Replace with your database password

$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed",
        "error" => $conn->connect_error
    ]);
    exit();
}

// Check if 'order_id' is provided in the GET request
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Missing or invalid order_id",
        "received_data" => $_GET // Include received data for debugging
    ]);
    exit();
}

$order_id = $conn->real_escape_string($_GET['order_id']);

// Fetch order details from 'orders' table
$order_query = "
    SELECT 
        order_id,
        customer_name,
        contact_number,
        address,
        email,
        order_type,
        total_sale,
        balance,
        mop,
        downpayment,
        date_order,
        store,
        team_name,
        delivery_date,
        is_new_order,
        is_additional_order
    FROM orders
    WHERE order_id = '$order_id'
";

$order_result = $conn->query($order_query);

if (!$order_result) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to execute order query",
        "error" => $conn->error
    ]);
    exit();
}

if ($order_result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "Order not found"]);
    exit();
}

$order_data = $order_result->fetch_assoc();

// Fetch associated items from 'order_details' table
$items_query = "
    SELECT 
        description,
        qty,
        unit_price AS unitPrice,
        total
    FROM order_details
    WHERE order_id = '$order_id'
";

$items_result = $conn->query($items_query);

if (!$items_result) {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to execute items query",
        "error" => $conn->error
    ]);
    exit();
}

$order_items = [];
if ($items_result->num_rows > 0) {
    while ($row = $items_result->fetch_assoc()) {
        $order_items[] = $row;
    }
}

// Combine order data and items into a single response
$response = [
    "status" => "success",
    "data" => [
        "order" => $order_data,
        "items" => $order_items
    ]
];

// Return JSON response
echo json_encode($response);

// Close connection
$conn->close();
?>
