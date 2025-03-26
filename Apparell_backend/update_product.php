<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$input = json_decode(file_get_contents("php://input"), true);

if (isset($input['id'], $input['name'], $input['price'], $input['status'])) {
    $id = intval($input['id']);
    $name = $input['name'];
    $price = floatval($input['price']);
    $status = $input['status'];

    $conn = new mysqli("localhost", "root", "", "apparel");

    if ($conn->connect_error) {
        echo json_encode(["status" => "error", "message" => "Database connection failed"]);
        exit;
    }

    $stmt = $conn->prepare("UPDATE products SET name=?, price=?, status=? WHERE id=?");
    $stmt->bind_param("sdsi", $name, $price, $status, $id);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Product updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to update product"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
?>
