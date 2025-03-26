<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root";
$password = "";

$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]);
    exit();
}

// Check if 'assignees' parameter is provided
if (!isset($_GET['assignees']) || empty(trim($_GET['assignees']))) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Missing or invalid assignees parameter"]);
    exit();
}

// Handle one or multiple assignees
$assignees = explode(',', $_GET['assignees']);
$assignees = array_map('trim', $assignees); // Trim spaces
$placeholders = implode(',', array_fill(0, count($assignees), '?'));

// SQL query with JOIN and filtering
$sql = "
    SELECT 
        o.team_name AS teamName,
        o.order_id AS orderId,
        o.order_type AS orderType,
        COALESCE(GROUP_CONCAT(od.description SEPARATOR ', '), 'N/A') AS itemType,
        COALESCE(SUM(od.qty), 'N/A') AS quantity,
        o.store AS branch,
        o.date_order AS dateOrder,
        o.delivery_date AS dueDate,
        'Active' AS status,
        o.customer_name AS customerName,
        o.contact_number AS phoneNumber,
        o.email AS emailAddress
    FROM orders o
    LEFT JOIN order_details od ON o.order_id = od.order_id
    WHERE o.assigned_to IN ($placeholders)
    GROUP BY o.order_id
    ORDER BY o.delivery_date ASC
";

// Prepare and bind the statement
$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Failed to prepare statement: " . $conn->error]);
    exit();
}

$stmt->bind_param(str_repeat('s', count($assignees)), ...$assignees);
$stmt->execute();
$result = $stmt->get_result();

// Fetch and return data
$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

echo json_encode([
    "status" => "success",
    "message" => count($tasks) > 0 ? "Tasks found" : "No tasks found",
    "data" => $tasks
]);

// Cleanup
$stmt->close();
$conn->close();
?>
