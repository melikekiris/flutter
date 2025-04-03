<?php
require_once 'bdd_pdo.php';
header('Content-Type: application/json');

$response = ['success' => false, 'message' => ''];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $idcours = $_POST['idcours'] ?? null;
    $idcava = $_POST['idcava'] ?? null;

    if (!$idcours || !$idcava) {
        $response['message'] = 'Données manquantes';
        echo json_encode($response);
        exit;
    }

    try {
        // Vérifier si déjà inscrit
        $stmt = $pdo->prepare("SELECT * FROM inscrit WHERE refidcours = ? AND refidcava = ? AND supprime = 0");
        $stmt->execute([$idcours, $idcava]);

        if ($stmt->rowCount() > 0) {
            $response['message'] = "Déjà inscrit à ce cours.";
            $response['success'] = true;
            echo json_encode($response);
            exit;
        }

        // Inscription au cours
        $stmt = $pdo->prepare("INSERT INTO inscrit (refidcours, refidcava) VALUES (?, ?)");
        $stmt->execute([$idcours, $idcava]);

        // Récupérer infos du cours
        $stmtCours = $pdo->prepare("SELECT jour FROM cours WHERE idcours = ?");
        $stmtCours->execute([$idcours]);
        $cours = $stmtCours->fetch();

        if ($cours) {
            $jour = $cours['jour'];

            $jours = [
                'Dimanche' => 0, 'Lundi' => 1, 'Mardi' => 2, 'Mercredi' => 3,
                'Jeudi' => 4, 'Vendredi' => 5, 'Samedi' => 6
            ];
            $numJour = $jours[$jour] ?? null;

            if ($numJour !== null) {
                $date = new DateTime();
                if ((int)$date->format('w') === $numJour && $date->format('H:i') > '23:59') {
                    $date->modify('+1 week');
                } else {
                    $date->modify("next $jour");
                }

                $stmtInsert = $pdo->prepare("INSERT INTO calendrier (idcoursbase, datecours) VALUES (?, ?)");
                $stmtParticipe = $pdo->prepare("INSERT INTO participe (refidcava, refidcoursbase, refidcoursseance, participe)
                                                VALUES (:idcava, :idcours, :idseance, 1)
                                                ON DUPLICATE KEY UPDATE participe = 1");

                for ($i = 0; $i < 52; $i++) {
                    $dateStr = $date->format('Y-m-d');
                    $stmtInsert->execute([$idcours, $dateStr]);
                    $idSeance = $pdo->lastInsertId();

                    $stmtParticipe->execute([
                        ':idcava' => $idcava,
                        ':idcours' => $idcours,
                        ':idseance' => $idSeance,
                    ]);

                    $date->modify('+1 week');
                }
            }
        }

        $response['success'] = true;
        $response['message'] = "Inscription réussie et séances générées.";
    } catch (PDOException $e) {
        $response['message'] = "Erreur : " . $e->getMessage();
    }
} else {
    $response['message'] = "Méthode non autorisée";
}

echo json_encode($response);
