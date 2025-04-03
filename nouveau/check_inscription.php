<?php
require 'bdd_pdo.php';
header('Content-Type: application/json');

if (!isset($_GET['idcava']) || !isset($_GET['idcours'])) {
    echo json_encode(['success' => false, 'message' => 'Paramètres manquants']);
    exit;
}

$idcava = $_GET['idcava'];
$idcours = $_GET['idcours'];

$stmt = $pdo->prepare("SELECT 1 FROM participe WHERE refidcava = ? AND refidcoursbase = ?");
$stmt->execute([$idcava, $idcours]);

$isInscrit = $stmt->fetchColumn() ? true : false;

echo json_encode(['success' => true, 'inscrit' => $isInscrit]);
