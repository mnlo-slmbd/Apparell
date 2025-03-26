<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root"; // Replace with your DB username
$password = "";     // Replace with your DB password

$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]));
}

// Fetch orders with details and assigned_to
$sql = "
    SELECT 
        o.order_id,
        o.team_name,
        DATE_FORMAT(o.delivery_date, '%M %d, %Y') AS delivery_date,
        o.store AS branch,
        o.order_type AS category,
        o.assigned_to, -- Include the assigned_to field
        od.description,
        od.qty,
        od.unit_price,
        od.total
    FROM orders o
    LEFT JOIN order_details od ON o.order_id = od.order_id
    ORDER BY o.delivery_date ASC
";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $orders = [];

    while ($row = $result->fetch_assoc()) {
        $orderId = $row["order_id"];
        if (!isset($orders[$orderId])) {
            $orders[$orderId] = [
                "orderId" => $orderId,
                "teamName" => $row["team_name"],
                "deliveryDate" => $row["delivery_date"],
                "branch" => $row["branch"],
                "category" => $row["category"],
                "assigned_to" => $row["assigned_to"], // Add assigned_to to the response
                "details" => [],
            ];
        }

        if (!is_null($row["description"])) {
            $orders[$orderId]["details"][] = [
                "description" => $row["description"],
                "qty" => intval($row["qty"]),
                "unitPrice" => floatval($row["unit_price"]),
                "total" => floatval($row["total"]),
            ];
        }
    }

    // Reset array keys and return data
    echo json_encode(array_values($orders));
} else {
    echo json_encode(["status" => "success", "data" => []]);
}

$conn->close();
?>
