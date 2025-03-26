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

// Define the query to fetch orders based on test_print_status (could be 'sent', 'completed', 'pending', etc.)
$status_filter = 'sent'; // You can adjust this or make it dynamic based on the input

$sql = "
    SELECT 
        o.order_id,
        o.customer_name,
        o.contact_number,
        o.address,
        o.email,
        o.order_type,
        o.date_order,
        o.store,
        o.team_name,
        o.delivery_date,
        o.test_print_status,
        GROUP_CONCAT(od.description SEPARATOR ', ') AS items,
        SUM(od.qty) AS total_quantity
    FROM orders o
    LEFT JOIN order_details od ON o.order_id = od.order_id
    WHERE o.test_print_status = ? 
    GROUP BY o.order_id, o.customer_name, o.contact_number, o.address, 
             o.email, o.order_type, o.date_order, o.store, 
             o.team_name, o.delivery_date, o.test_print_status
    ORDER BY o.delivery_date ASC
";

// Prepare statement to prevent SQL injection
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $status_filter); // Bind the status parameter to the query
$stmt->execute();

// Get the result
$result = $stmt->get_result();

// Check if the query execution was successful
if ($result) {
    if ($result->num_rows > 0) {
        $orders = [];
        while ($row = $result->fetch_assoc()) {
            // Format the fetched data into a structured array
            $orders[] = [
                "order_id" => $row["order_id"],
                "customer_name" => $row["customer_name"],
                "contact_number" => $row["contact_number"],
                "address" => $row["address"],
                "email" => $row["email"],
                "order_type" => $row["order_type"],
                "date_order" => $row["date_order"],
                "store" => $row["store"],
                "team_name" => $row["team_name"],
                "delivery_date" => $row["delivery_date"],
                "test_print_status" => $row["test_print_status"],
                "items" => $row["items"] ?? "N/A", // Handle null values
                "total_quantity" => $row["total_quantity"] ?? 0 // Handle null values
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
            "message" => "No orders found with test_print_status = '$status_filter'"
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
