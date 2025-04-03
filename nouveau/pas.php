<?php
// Hachage du mot de passe pour l'utilisateur de test
$hashedPasswordFromDb = '$2y$10$IZRZrlyWC9PvvPnJKrmTcOj1sXlCPP.K1yasyZZLYy63Eg9Gz80Me';

// Mot de passe en clair à vérifier
$plainPassword = '1234';

if (password_verify($plainPassword, $hashedPasswordFromDb)) {
    echo "Le mot de passe est correct.";
} else {
    echo "Le mot de passe est incorrect.";
}
?>
