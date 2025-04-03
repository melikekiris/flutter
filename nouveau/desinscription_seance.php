<?php
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 0);
require 'bdd_pdo.php';

$response = ['success' => false, 'message' => ''];

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
    exit;
}

$idcava = $_POST['idcava'] ?? null;
$idcoursseance = $_POST['idcoursseance'] ?? null;

if (!$idcava || !$idcoursseance) {
    echo json_encode(['success' => false, 'message' => 'Données manquantes']);
    exit;
}

// Vérifie si la ligne existe dans participe
$stmt = $pdo->prepare("SELECT * FROM participe WHERE refidcava = ? AND refidcoursseance = ?");
$stmt->execute([$idcava, $idcoursseance]);

if ($stmt->rowCount() > 0) {
    // Mise à jour à 0
    $pdo->prepare("UPDATE participe SET participe = 0 WHERE refidcava = ? AND refidcoursseance = ?")
        ->execute([$idcava, $idcoursseance]);

    echo json_encode(['success' => true, 'message' => 'Désinscription réussie']);
} else {
    echo json_encode(['success' => false, 'message' => 'Séance introuvable']);
}
