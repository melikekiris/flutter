<?php
$host = 'localhost';
$dbname = 'equihorizon'; 
$username = 'root';         
$password = '';             

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    // Activer les erreurs PDO
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Erreur de connexion à la base de données : " . $e->getMessage()
    ]);
    exit;
}
?>
