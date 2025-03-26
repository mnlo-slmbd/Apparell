<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database connection
$host = "localhost";
$db_name = "apparel";
$username = "root"; // Replace with your DB username
$password = "";     // Replace with your DB password

$conn = new mysqli($host, $username, $password, $db_name);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]));
}

// Retrieve JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!$data || !isset($data["order_id"]) || !isset($data["order_details"]) || !is_array($data["order_details"])) {
    echo json_encode(["status" => "error", "message" => "Invalid input data"]);
    exit();
}

$order_id = $conn->real_escape_string($data["order_id"]);
$customer_name = $conn->real_escape_string($data["customer_name"]);
$contact_number = $conn->real_escape_string($data["contact_number"]);
$address = $conn->real_escape_string($data["address"]);
$email = $conn->real_escape_string($data["email"]);
$order_type = $conn->real_escape_string($data["order_type"]);
$total_sale = floatval($data["total_sale"]);
$balance = floatval($data["balance"]);
$mop = $conn->real_escape_string($data["mop"]);
$downpayment = floatval($data["downpayment"]);
$date_order = $conn->real_escape_string($data["date_order"]);
$store = $conn->real_escape_string($data["store"]);
$team_name = $conn->real_escape_string($data["team_name"]);
$is_new_order = intval($data["is_new_order"]);
$is_additional_order = intval($data["is_additional_order"]);
$delivery_date = date('Y-m-d', strtotime($data["delivery_date"]));

// Check if the order_id already exists
$check_query = "SELECT * FROM orders WHERE order_id = '$order_id'";
$check_result = $conn->query($check_query);

if ($check_result->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Duplicate order_id: Order already exists"]);
    exit();
}

// Insert into orders table
$order_query = "
    INSERT INTO orders (
        order_id, customer_name, contact_number, address, email, order_type, 
        total_sale, balance, mop, downpayment, date_order, store, 
        team_name, delivery_date, is_new_order, is_additional_order
    ) VALUES (
        '$order_id', '$customer_name', '$contact_number', '$address', '$email', '$order_type', 
        $total_sale, $balance, '$mop', $downpayment, '$date_order', '$store', 
        '$team_name', '$delivery_date', $is_new_order, $is_additional_order
    )
";

if ($conn->query($order_query) === TRUE) {
    $order_details = $data["order_details"];
    $details_success = true;

    foreach ($order_details as $detail) {
        // Map `unitPrice` to `unit_price`
        if (
            !isset($detail["description"]) ||
            !isset($detail["qty"]) ||
            !isset($detail["unitPrice"]) || // Change here to `unitPrice`
            !isset($detail["total"])
        ) {
            echo json_encode(["status" => "error", "message" => "Invalid order details data"]);
            exit();
        }

        $description = $conn->real_escape_string($detail["description"]);
        $qty = intval($detail["qty"]);
        $unit_price = floatval($detail["unitPrice"]); // Change here to `unitPrice`
        $total = floatval($detail["total"]);

        $detail_query = "
            INSERT INTO order_details (order_id, description, qty, unit_price, total) 
            VALUES ('$order_id', '$description', $qty, $unit_price, $total)
        ";
        
        if (!$conn->query($detail_query)) {
            $details_success = false;
            error_log("Error inserting order detail: " . $conn->error);
            break;
        }
    }

    if ($details_success) {
        echo json_encode(["status" => "success", "message" => "Order saved successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to save order details"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Failed to save order: " . $conn->error]);
}

$conn->close();
?>
