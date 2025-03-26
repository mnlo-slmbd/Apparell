<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

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
        "message" => "Connection failed: " . $conn->connect_error
    ]);
    exit;
}

// Query users
$sql = "SELECT name, store_name, position, email, mobile, password, date_of_birth, date_employed FROM users";
$result = $conn->query($sql);

$users = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $users[] = [
            "name" => $row['name'],
            "store_name" => $row['store_name'],
            "position" => $row['position'],
            "email" => $row['email'],
            "mobile" => $row['mobile'],
            "password" => $row['password'], // ✅ Plain password (if saved as plain in DB)
            "date_of_birth" => $row['date_of_birth'],
            "date_employed" => $row['date_employed'],
        ];
    }

    echo json_encode([
        "status" => "success",
        "users" => $users
    ], JSON_PRETTY_PRINT);
} else {
    echo json_encode([
        "status" => "success",
        "message" => "No users found.",
        "users" => []
    ], JSON_PRETTY_PRINT);
}

$conn->close();
?>
