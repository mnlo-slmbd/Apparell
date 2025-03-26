<?php
// Set response headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database connection details
$host = "localhost";
$db_name = "apparel"; // Replace with your database name
$username = "root"; // Replace with your database username
$password = ""; // Replace with your database password

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

// Query to fetch orders where rename_status = 'completed'
$sql = "
    SELECT 
        o.order_id,
        o.team_name,
        o.order_type,
        o.date_order,
        o.delivery_date,
        o.store,
        o.rename_status,
        o.printing_status,
        GROUP_CONCAT(od.description SEPARATOR ', ') AS items,
        SUM(od.qty) AS total_quantity
    FROM orders o
    LEFT JOIN order_details od ON o.order_id = od.order_id
    WHERE o.rename_status = 'completed'
    GROUP BY 
        o.order_id, 
        o.team_name, 
        o.order_type, 
        o.date_order, 
        o.delivery_date, 
        o.store, 
        o.rename_status, 
        o.printing_status
    ORDER BY o.delivery_date ASC
";

// Execute the query
$result = $conn->query($sql);

// Check if the query execution was successful
if ($result) {
    if ($result->num_rows > 0) {
        $orders = [];
        while ($row = $result->fetch_assoc()) {
            // Format the fetched data into a structured array
            $orders[] = [
                "order_id" => $row["order_id"],
                "team_name" => $row["team_name"],
                "order_type" => $row["order_type"],
                "date_order" => $row["date_order"],
                "delivery_date" => $row["delivery_date"],
                "store" => $row["store"],
                "rename_status" => $row["rename_status"],
                "printing_status" => $row["printing_status"] ?? "Pending",
                "items" => $row["items"],
                "total_quantity" => $row["total_quantity"] ?? 0
            ];
        }
        // Return orders in JSON format
        echo json_encode([
            "status" => "success",
            "orders" => $orders
        ]);
    } else {
        // No orders found
        echo json_encode([
            "status" => "success",
            "orders" => [],
            "message" => "No orders found with rename_status = 'completed'."
        ]);
    }
} else {
    // Query execution failed
    echo json_encode([
        "status" => "error",
        "message" => "Query failed: " . $conn->error
    ]);
}

// Close the database connection
$conn->close();
?>
