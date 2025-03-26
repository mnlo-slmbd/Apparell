<?php
header("Access-Control-Allow-Origin: *"); // Allow from any domain
header("Content-Type: application/json; charset=UTF-8");
header('Content-Type: application/json');
$conn = new mysqli('localhost', 'root', '', 'apparel');

$result = $conn->query("SELECT * FROM provinces ORDER BY name ASC");
$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}
echo json_encode($data);
