<?php
// get_cours.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once "bdd_pdo.php";

try {
    $stmt = $pdo->query("SELECT * FROM cours");
    $cours = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($cours);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Erreur serveur : " . $e->getMessage()]);
}
?>
