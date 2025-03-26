<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight requests
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit;
}

try {
    // Database connection
    $host = "localhost";
    $username = "root";
    $password = "";
    $db_name = "apparel";

    $conn = new mysqli($host, $username, $password, $db_name);

    if ($conn->connect_error) {
        throw new Exception("Database connection failed: " . $conn->connect_error);
    }

    // Read and decode input data
    $input = json_decode(file_get_contents("php://input"), true);

    if (!$input) {
        http_response_code(400);
        echo json_encode(["status" => "error", "message" => "Invalid input data format"]);
        exit;
    }

    // Validate input fields
    if (
        empty(trim($input["name"])) || empty(trim($input["description"])) || 
        !isset($input["price"]) || !is_numeric($input["price"]) ||
        empty(trim($input["unit"])) || !isset($input["stock"]) || !is_numeric($input["stock"]) ||
        empty(trim($input["supplier"])) || empty(trim($input["category"]))
    ) {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Invalid input data. Ensure all fields are properly filled.",
            "data" => $input
        ]);
        exit;
    }

    // Prepare SQL statement
    $stmt = $conn->prepare("INSERT INTO inventory (name, description, price, unit, stock, value, supplier, category, date_added) 
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        throw new Exception("Failed to prepare SQL statement: " . $conn->error);
    }

    // Bind parameters
    $name = trim($input["name"]);
    $description = trim($input["description"]);
    $price = floatval($input["price"]);
    $unit = trim($input["unit"]);
    $stock = intval($input["stock"]); // Use 'stock' for quantity
    $value = $price * $stock; // Calculate value
    $supplier = trim($input["supplier"]);
    $category = trim($input["category"]);
    $date_added = date("Y-m-d");

    $stmt->bind_param("ssdsiisss", $name, $description, $price, $unit, $stock, $value, $supplier, $category, $date_added);

    // Execute statement
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Product added successfully"]);
    } else {
        throw new Exception("Failed to execute SQL statement: " . $stmt->error);
    }
} catch (Exception $e) {
    error_log($e->getMessage());
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
} finally {
    // Close database connection
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?>
