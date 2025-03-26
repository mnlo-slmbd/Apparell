<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

// Database connection
$host = "localhost";
$username = "root";
$password = "";
$database = "apparel";

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode(['error' => $conn->connect_error]));
}

// Query to combine items and quantities into a single row per order_id
$sql = "
    SELECT 
        o.date_order AS date_order, 
        o.store AS store, 
        o.team_name AS team_name, 
        GROUP_CONCAT(od.description SEPARATOR ', ') AS items, 
        GROUP_CONCAT(od.qty SEPARATOR ', ') AS quantities
    FROM 
        orders o
    INNER JOIN 
        order_details od ON o.order_id = od.order_id
    WHERE 
        o.qc_status = 'completed'
    GROUP BY 
        o.order_id
";

$result = $conn->query($sql);

if (!$result) {
    error_log('SQL Error: ' . $conn->error);
    die(json_encode(['error' => 'Failed to execute query']));
}

$data = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

// Send JSON response
echo json_encode($data);

$conn->close();
?>
