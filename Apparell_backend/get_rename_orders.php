<?php
// Set response headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database connection details
$host = "localhost";
$db_name = "apparel";
$username = "root"; // Replace with your DB username
$password = "";     // Replace with your DB password

// Establish the database connection
$conn = new mysqli($host, $username, $password, $db_name);

// Check if the connection is successful
if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}

// Fetch orders where test_print_stage_status is completed
$sql = "
    SELECT 
        o.order_id,
        o.team_name,
        o.order_type,
        SUM(od.qty) AS total_quantity,
        GROUP_CONCAT(od.description SEPARATOR ', ') AS items,
        o.store,
        o.date_order,
        o.delivery_date,
        o.rename_status
    FROM orders o
    LEFT JOIN order_details od ON o.order_id = od.order_id
    WHERE o.test_print_stage_status = 'completed'
    GROUP BY 
        o.order_id, 
        o.team_name, 
        o.order_type, 
        o.store, 
        o.date_order, 
        o.delivery_date, 
        o.rename_status
    ORDER BY o.delivery_date ASC
";

$result = $conn->query($sql);

// Check if the query execution was successful
if ($result) {
    if ($result->num_rows > 0) {
        $orders = [];
        while ($row = $result->fetch_assoc()) {
            $orders[] = [
                "order_id" => $row["order_id"],
                "team_name" => $row["team_name"],
                "order_type" => $row["order_type"],
                "total_quantity" => $row["total_quantity"],
                "items" => $row["items"],
                "store" => $row["store"],
                "date_order" => $row["date_order"],
                "delivery_date" => $row["delivery_date"],
                "rename_status" => $row["rename_status"] ?? "Pending"
            ];
        }
        echo json_encode([
            "status" => "success",
            "orders" => $orders
        ]);
    } else {
        echo json_encode([
            "status" => "success",
            "orders" => [],
            "message" => "No orders found with test_print_stage_status = 'completed'."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Query failed: " . $conn->error
    ]);
}

// Close the database connection
$conn->close();
?>
