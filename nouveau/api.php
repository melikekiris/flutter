<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "success" => false,
        "message" => "Méthode non autorisée"
    ]);
    exit;
}

require_once 'bdd_pdo.php';

$email = trim($_POST['username'] ?? '');
$password = trim($_POST['password'] ?? '');

if (empty($email) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "Champs requis manquants"
    ]);
    exit;
}

try {
    // Récupérer le cavalier par email
    $stmt = $pdo->prepare("SELECT * FROM cavaliers WHERE emailcava = :email");
    $stmt->execute(['email' => $email]);

    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    // Vérification du mot de passe hashé
    if ($user && password_verify($password, $user['password'])) {
        echo json_encode([
            "success" => true,
            "message" => "Connexion réussie",
            "user" => [
                "id" => $user['idcava'],
                "nom" => $user['nomcava'],
                "prenom" => $user['prenomcava'],
                "email" => $user['emailcava']
            ]
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Identifiants incorrects"
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Erreur serveur : " . $e->getMessage()
    ]);
}
