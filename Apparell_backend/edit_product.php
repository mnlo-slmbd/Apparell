<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "apparel";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Database connection failed."]);
    exit();
}

// Retrieve POST data
$id = $_POST['id'];
$name = $_POST['name'];
$price = $_POST['price'];
$status = $_POST['status'];

// Update details if published
$details = ($status == 'Published') ? date('M. d, Y H:i') : '';

$sql = "UPDATE products SET name='$name', price='$price', status='$status', details='$details' WHERE id=$id";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Product updated successfully."]);
} else {
    echo json_encode(["success" => false, "message" => "Error updating product: " . $conn->error]);
}

$conn->close();
?>
