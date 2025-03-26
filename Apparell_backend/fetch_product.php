<?php
// Enable CORS for cross-origin requests
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

// Database connection
$conn = new mysqli("localhost", "root", "", "apparel");

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Query to fetch published products
$sql = "SELECT name, price FROM products WHERE status = 'Published'";
$result = $conn->query($sql);

// Check if results exist
if ($result->num_rows > 0) {
    $products = [];
    while ($row = $result->fetch_assoc()) {
        $products[] = [
            "name" => $row["name"],
            "price" => (float)$row["price"]
        ];
    }

    // Return products as JSON
    echo json_encode(["status" => "success", "products" => $products]);
} else {
    // No products found
    echo json_encode(["status" => "error", "message" => "No published products found."]);
}

// Close connection
$conn->close();
?>
