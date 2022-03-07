#Ajout d'utilisateurs dans l'AD via Powershell et fichier CSV.
#Ajout d'utilisateurs dans une UO et un groupe.
#V1.2


# Import du module AD
Import-Module ActiveDirectory
  
# Stockage du .CSV dans la variable UtilisateursAD
$UtilisateursAD = Import-Csv C:\AjoutUtilisateurs\NouveauxUtilisateursFinal.csv 

# Definition de l'UPN
$UPN = "galaxy-swiss.com"

# Loop dans le CSV
foreach ($User in $UtilisateursAD) {

    #Ajout des informations
    $username = $User.username
    $password = $User.password
    $prenom = $User.prenom
    $nom = $User.nom
    $initiales = $User.initiales
    $OU = $User.ou
    $position = $User.position
    $service = $User.service
    $email = $User.email
    # Verification doublon
    if (Get-ADUser -F { SamAccountName -eq $username }) {
        
        # Avertissement
        Write-Warning "Un compte d'utilisateur avec le nom $username existe déjà dans l'annuaire."
    }
    else {

        # L'utilisateur n'existe pas. Création du compte.
        # Le compte sera créé dans l'unité d'organisation indiqué dans le champ OU.
        New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$UPN" `
            -Name "$prenom $nom" `
            -GivenName $prenom `
            -Surname $nom `
            -Initials $initiales `
            -Enabled $True `
            -DisplayName "$nom, $prenom" `
            -Path $OU `
            -EmailAddress $email `
            -Title $position `
            -Department $service `
            -AccountPassword (ConvertTo-secureString $password -AsPlainText -Force) -ChangePasswordAtLogon $True
        # Ajout de l'utilisateur dans groupe
        Add-ADGroupMember -Identity service_$service -Members $username       
        # Affichage message de confirmation
        Write-Host "Le compte $username a été cree." -ForegroundColor Cyan
        Write-Host "Le compte $username a ete ajoute au groupe"
        
    }
}
Read-Host -Prompt "Appuyez sur entrée pour quitter."