<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "apparel";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed: " . $conn->connect_error
    ]);
    exit();
}

// Decode JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($data['email']) || !isset($data['password'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Email and password are required"
    ]);
    exit();
}

// Sanitize input
$email = htmlspecialchars(trim($data['email']));
$passwordInput = trim($data['password']);

// Prepare and execute query
$sql = "SELECT name, position, store_name, email, password FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

// Check if user exists
if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    $storedPassword = $user['password'];

    // Check hashed or plain password
    if (password_verify($passwordInput, $storedPassword) || $passwordInput === $storedPassword) {
        // Success response
        echo json_encode([
            "status" => "success",
            "message" => "Login successful",
            "user" => [
                "name" => $user['name'],
                "email" => $user['email'],
                "position" => $user['position'],
                "store_name" => $user['store_name'],
                "role" => $user['position'] // Same as role
            ]
        ]);
    } else {
        // Wrong password
        echo json_encode([
            "status" => "error",
            "message" => "Incorrect password"
        ]);
    }
} else {
    // User not found
    echo json_encode([
        "status" => "error",
        "message" => "User not found"
    ]);
}

$stmt->close();
$conn->close();
?>
