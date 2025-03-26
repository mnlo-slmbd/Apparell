<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$host = "localhost";
$db_name = "apparel";
$username = "root";
$password = "";

$conn = new mysqli($host, $username, $password, $db_name);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => $conn->connect_error]);
    exit();
}

$input = json_decode(file_get_contents("php://input"), true);

if (!isset($input['order_id']) || !isset($input['step']) || !isset($input['status'])) {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
    exit();
}

$order_id = $conn->real_escape_string($input['order_id']);
$step = $conn->real_escape_string($input['step']);
$status = $conn->real_escape_string($input['status']);

$sql = "UPDATE orders SET $step = '$status' WHERE order_id = '$order_id'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Step status updated successfully"]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
