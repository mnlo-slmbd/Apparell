<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection
$host = 'localhost';
$db = 'apparel';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Fetch customers
    $stmt = $pdo->query("SELECT * FROM customers");
    $customers = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $customers[] = [
            'name' => $row['name'] ?? '',
            'phone' => $row['phone'] ?? '',
            'email' => $row['email'] ?? '',
            'address' => $row['address'] ?? '',
        ];
    }

    // Fetch customer order history
    $stmt = $pdo->query("SELECT * FROM orders");
    $customerOrderHistory = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $customerName = $row['customer_name'] ?? 'Unknown Customer';
        if (!isset($customerOrderHistory[$customerName])) {
            $customerOrderHistory[$customerName] = [];
        }
        $customerOrderHistory[$customerName][] = [
            'team' => $row['team_name'] ?? '',
            'ordered' => $row['date_ordered'] ?? null,
            'delivered' => $row['date_delivered'] ?? null,
            'status' => $row['status'] ?? 'Unknown',
        ];
    }

    // Send response
    echo json_encode([
        'success' => true,
        'customers' => $customers,
        'customerOrderHistory' => $customerOrderHistory,
    ]);
} catch (PDOException $e) {
    // Catch and display database connection or query errors
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage(),
    ]);
} catch (Exception $e) {
    // Catch any other exceptions
    echo json_encode([
        'success' => false,
        'message' => 'General error: ' . $e->getMessage(),
    ]);
}
?>
