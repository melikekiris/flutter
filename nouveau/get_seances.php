<?php
require 'bdd_pdo.php';
header('Content-Type: application/json');

if (!isset($_GET['idcours'])) {
    echo json_encode(['success' => false, 'message' => 'Paramètre idcours manquant']);
    exit;
}

$idcours = $_GET['idcours'];

try {
    // Récupère les infos du cours depuis la table cours
    $stmt = $pdo->prepare("SELECT * FROM cours WHERE idcours = ?");
    $stmt->execute([$idcours]);
    $cours = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$cours) {
        echo json_encode(['success' => false, 'message' => 'Cours introuvable']);
        exit;
    }

    $jours = [
        'lundi' => 'Monday',
        'mardi' => 'Tuesday',
        'mercredi' => 'Wednesday',
        'jeudi' => 'Thursday',
        'vendredi' => 'Friday',
        'samedi' => 'Saturday',
        'dimanche' => 'Sunday'
    ];

    $jourCours = strtolower($cours['jour']);
    $jourEn = $jours[$jourCours] ?? 'Monday';
    $hdebut = $cours['hdebut'];
    $hfin = $cours['hfin'];

    $start = new DateTime(); // aujourd'hui
    $end = (clone $start)->modify('+1 year'); // jusqu'à dans un an

    $seances = [];
    $current = clone $start;

    while ($current <= $end) {
        if ($current->format('l') === $jourEn) {
            $seances[] = [
                'datecours' => $current->format('Y-m-d'),
                'heure_debut' => $hdebut,
                'heure_fin' => $hfin,
                'present' => 1, // Valeur par défaut
                'commentaire' => null
            ];
        }
        $current->modify('+1 day');
    }

    echo json_encode(['success' => true, 'sessions' => $seances]);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur base de données : ' . $e->getMessage()]);
}
