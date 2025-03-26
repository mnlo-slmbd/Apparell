<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

// Database connection details
$host = "localhost";
$db_name = "apparel";
$username = "root";
$password = "";

// Connect to the database
$conn = new mysqli($host, $username, $password, $db_name);

// Check for connection errors
if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}

// Fetch orders with all stages, including delivery_status and production_status
$sql = "
    SELECT 
        order_id, 
        team_name, 
        delivery_date, 
        order_type AS category, -- Aliased as category
        COALESCE(layout_status, 'Pending') AS layout_status,
        COALESCE(test_print_stage_status, 'Pending') AS test_print_status,
        COALESCE(rename_status, 'Pending') AS rename_status,
        COALESCE(printing_status, 'Pending') AS printing_status,
        COALESCE(tailoring_status, 'Pending') AS tailoring_status,
        COALESCE(qc_status, 'Pending') AS qc_status,
        COALESCE(delivery_status, 'Pending') AS delivery_status,
        CASE 
            WHEN delivery_status = 'completed' THEN 'Completed'
            ELSE 'In Progress'
        END AS production_status -- Automatically set production_status
    FROM orders
    WHERE test_print_stage_status IN ('completed', 'ongoing')
    ORDER BY delivery_date ASC
";

$result = $conn->query($sql);

// Process the results
if ($result) {
    if ($result->num_rows > 0) {
        $orders = [];
        while ($row = $result->fetch_assoc()) {
            $orders[] = [
                "order_id" => $row["order_id"],
                "team_name" => $row["team_name"],
                "delivery_date" => $row["delivery_date"],
                "category" => $row["category"],
                "layout_status" => $row["layout_status"],
                "test_print_status" => $row["test_print_status"],
                "rename_status" => $row["rename_status"],
                "printing_status" => $row["printing_status"],
                "tailoring_status" => $row["tailoring_status"],
                "qc_status" => $row["qc_status"],
                "delivery_status" => $row["delivery_status"],
                "production_status" => $row["production_status"] // Include production_status in the response
            ];
        }
        echo json_encode(["status" => "success", "data" => $orders]);
    } else {
        echo json_encode([
            "status" => "success",
            "data" => [],
            "message" => "No data found with test_print_stage_status IN ('completed', 'ongoing')."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Query failed: " . $conn->error
    ]);
}

// Close the connection
$conn->close();
?>
