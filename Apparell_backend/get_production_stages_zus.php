<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root";
$password = "";

// Connect to the database
$conn = new mysqli($host, $username, $password, $db_name);

// Check for connection errors
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]);
    exit();
}

// ✅ Get store name from query parameter
$storeName = isset($_GET['store']) ? trim($_GET['store']) : '';

if (empty($storeName)) {
    echo json_encode(["status" => "error", "message" => "Missing store name."]);
    exit();
}

// Fetch orders for the specific store
$sql = "
    SELECT 
        order_id, 
        team_name, 
        delivery_date, 
        order_type AS category,
        COALESCE(layout_status, 'Pending') AS layout_status,
        COALESCE(test_print_stage_status, 'Pending') AS test_print_status,
        COALESCE(rename_status, 'Pending') AS rename_status,
        COALESCE(printing_status, 'Pending') AS printing_status,
        COALESCE(tailoring_status, 'Pending') AS tailoring_status,
        COALESCE(qc_status, 'Pending') AS qc_status,
        COALESCE(delivery_status, 'Pending') AS delivery_status
    FROM orders
    WHERE store = ?
    ORDER BY delivery_date ASC
";

// Use prepared statement for security
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $storeName);
$stmt->execute();
$result = $stmt->get_result();

// Process the results
if ($result) {
    if ($result->num_rows > 0) {
        $orders = [];
        while ($row = $result->fetch_assoc()) {
            $orders[] = $row;
        }
        echo json_encode(["status" => "success", "data" => $orders]);
    } else {
        echo json_encode(["status" => "success", "data" => [], "message" => "No orders found for store: $storeName"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Query failed: " . $conn->error]);
}

$conn->close();
?>
