<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$dbname = 'apparel';
$username = 'root';
$password = '';

try {
    // Database connection
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(["status" => "error", "message" => "Database connection failed: " . $e->getMessage()]));
}

// Get view/action
$view = $_GET['view'] ?? '';
$storeName = $_GET['store'] ?? ''; // Get store name for filtering

if ($view === 'all') {
    // ✅ Fetch all expenses filtered by store (if provided)
    if (!empty($storeName)) {
        $stmt = $pdo->prepare("SELECT * FROM expenses WHERE store_name = ? ORDER BY doet DESC");
        $stmt->execute([$storeName]);
    } else {
        $stmt = $pdo->query("SELECT * FROM expenses ORDER BY doet DESC");
    }

    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));

} elseif ($view === 'add') {
    // ✅ Add a new expense
    $data = json_decode(file_get_contents('php://input'), true);

    if (!isset($data['store_name'], $data['doet'], $data['type'], $data['description'], $data['amount'])) {
        echo json_encode(["status" => "error", "message" => "Missing required fields."]);
        exit;
    }

    $stmt = $pdo->prepare("INSERT INTO expenses (doet, type, description, amount, store_name) VALUES (?, ?, ?, ?, ?)");
    $stmt->execute([
        $data['doet'],
        $data['type'],
        $data['description'],
        $data['amount'],
        $data['store_name']
    ]);

    echo json_encode(["status" => "success", "message" => "Expense added successfully."]);

} elseif ($view === 'edit') {
    // ✅ Edit existing expense
    $id = $_GET['id'] ?? '';
    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($id) || !isset($data['doet'], $data['type'], $data['description'], $data['amount'], $data['store_name'])) {
        echo json_encode(["status" => "error", "message" => "Missing ID or required fields."]);
        exit;
    }

    $stmt = $pdo->prepare("UPDATE expenses SET doet = ?, type = ?, description = ?, amount = ?, store_name = ? WHERE id = ?");
    $stmt->execute([
        $data['doet'],
        $data['type'],
        $data['description'],
        $data['amount'],
        $data['store_name'],
        $id
    ]);

    echo json_encode(["status" => "success", "message" => "Expense updated successfully."]);

} elseif ($view === 'delete') {
    // ✅ Delete expense
    $id = $_GET['id'] ?? '';
    if (empty($id)) {
        echo json_encode(["status" => "error", "message" => "Missing ID for deletion."]);
        exit;
    }

    $stmt = $pdo->prepare("DELETE FROM expenses WHERE id = ?");
    $stmt->execute([$id]);

    echo json_encode(["status" => "success", "message" => "Expense deleted successfully."]);

} else {
    // Invalid view/action
    echo json_encode(["status" => "error", "message" => "Invalid view parameter."]);
}
