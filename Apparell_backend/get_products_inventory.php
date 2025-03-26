<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Database connection
$host = "localhost";
$username = "root";
$password = "";
$db_name = "apparel";

$conn = new mysqli($host, $username, $password, $db_name);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

// Query to fetch all products
$sql = "SELECT id, name, description, price, unit, stock, value, supplier, category, date_added FROM inventory ORDER BY date_added DESC";
$result = $conn->query($sql);

$products = [];
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $products[] = [
            "id" => (int)$row["id"],
            "name" => $row["name"],
            "description" => $row["description"],
            "price" => (float)$row["price"],
            "unit" => $row["unit"],
            "stock" => (int)$row["stock"],
            "value" => (float)$row["value"],
            "supplier" => $row["supplier"],
            "category" => $row["category"],
            "date_added" => $row["date_added"]
        ];
    }
    echo json_encode($products);
} else {
    http_response_code(404);
    echo json_encode(["status" => "error", "message" => "No products found"]);
}

$conn->close();
?>
