<?php
header("Content-Type: application/json");
require_once "bdd_pdo.php";

$input = json_decode(file_get_contents("php://input"), true);

if (!isset($input["commande"])) {
    echo json_encode(["error" => "Commande non spécifiée"]);
    exit;
}

$commande = intval($input["commande"]);

switch ($commande) {
    case 1:
        GetCours($pdo);
        break;
    case 2:
        GetInscription($pdo, $input);
        break;
    case 3:
        GetParticipation($pdo, $input);
        break;
    case 4:
        UpdateParticipation($pdo, $input);
        break;
    case 5:
        CreatePartcipation($pdo, $input);
        break;
    case 6:
        CreateInscription($pdo, $input);
        break;
    case 7:
        DeleteInscription($pdo, $input);
        break;
    case 8:
        auth($pdo, $input);
        break;
    default:
        echo json_encode(["error" => "Commande invalide"]);
        break;
}

function GetCours($pdo) {
    $stmt = $pdo->query("SELECT * FROM cours");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function GetInscription($pdo, $input) {
    $stmt = $pdo->query("SELECT * FROM inscrit WHERE idcavalier =".$input['id'].";");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}
function GetParticipation($pdo, $input) {
    $stmt = $pdo->query("SELECT * FROM participe WHERE idcavalier =".$input['id'].";");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}


function UpdateParticipation($pdo, $input) {
    if (!isset($input['id']) || !isset($input['data'])) {
        echo json_encode(["error" => "Données incomplètes"]);
        return;
    }
    $stmt = $pdo->prepare("UPDATE ma_table SET valeur = :valeur WHERE id = :id");
    $stmt->execute(["id" => $input["id"], "valeur" => $input["data"]]);
    echo json_encode(["success" => "Données mises à jour"]);
}

function CreatePartcipation($pdo, $input) {
    if (!isset($input['data'])) {
        echo json_encode(["error" => "Données incomplètes"]);
        return;
    }
    $stmt = $pdo->prepare("INSERT INTO ma_table (valeur) VALUES (:valeur)");
    $stmt->execute(["valeur" => $input["data"]]);
    echo json_encode(["success" => "Données insérées"]);
}

function CreateInscription($pdo, $input) {
    if (!isset($input['data'])) {
        echo json_encode(["error" => "Données incomplètes"]);
        return;
    }
    $stmt = $pdo->prepare("INSERT INTO ma_table (valeur) VALUES (:valeur)");
    $stmt->execute(["valeur" => $input["data"]]);
    echo json_encode(["success" => "Données insérées"]);
}

function DeleteInscription($pdo, $input) {
    if (!isset($input['data'])) {
        echo json_encode(["error" => "Données incomplètes"]);
        return;
    }
    $stmt = $pdo->prepare("DELETE FROM ma_table WHERE id = :id");
    $stmt->execute(["id" => $input["id"]]);
    echo json_encode(["success" => "Données supprimées"]);
}

function Auth($pdo, $input) {
    $stmt = $pdo->query("SELECT EXISTS (
                        SELECT 1 FROM cavalier WHERE nomcav =".$input["login"]." AND mdp = ".$input["mdp"]."
                        ) AS existe; ");
    $stmt->fetchAll(PDO::FETCH_ASSOC);
    if($stmt['existe'] == 1){
        $stmt = $pdo->query("SELECT id FROM cavalier WHERE nomcav =".$input["login"]." AND mdp = ".$input["mdp"].";");
        $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($stmt['id']);
    }else{
        echo json_encode('refuser');
    }
}
