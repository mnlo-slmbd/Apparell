<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$db = 'apparel';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Decode JSON payload
    $input = json_decode(file_get_contents('php://input'), true);

    // Log incoming data for debugging
    error_log("INPUT: " . json_encode($input));

    // Validate ID
    if (!isset($input['id']) || empty($input['id']) || !is_numeric($input['id'])) {
        throw new Exception("Invalid or missing ID provided.");
    }

    $id = intval($input['id']);

    // Check if customer exists
    $checkStmt = $pdo->prepare("SELECT * FROM customers WHERE id = :id");
    $checkStmt->execute([':id' => $id]);
    $customer = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$customer) {
        throw new Exception("Customer not found with ID: $id.");
    }

    // Prepare input values
    $name = isset($input['name']) && $input['name'] !== "" ? $input['name'] : $customer['name'];
    $phone = isset($input['phone']) && $input['phone'] !== "" ? $input['phone'] : $customer['contact_number'];
    $email = isset($input['email']) && $input['email'] !== "" ? $input['email'] : $customer['email'];
    $address = isset($input['address']) && $input['address'] !== "" ? $input['address'] : $customer['address'];

    // Update query
    $stmt = $pdo->prepare("
        UPDATE customers
        SET 
            name = :name,
            contact_number = :phone,
            email = :email,
            address = :address
        WHERE id = :id
    ");
    $stmt->execute([
        ':name' => $name,
        ':phone' => $phone,
        ':email' => $email,
        ':address' => $address,
        ':id' => $id,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Customer updated successfully.',
    ]);
} catch (Exception $e) {
    // Log the error to the PHP error log
    error_log("Error: " . $e->getMessage());

    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
    ]);
}
