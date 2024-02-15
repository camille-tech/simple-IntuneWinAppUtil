# encoding: UTF-8

# Chemin des dossiers à verifier et a creer si necessaire
$Folder1 = ".\apps"
$Folder2 = ".\packages"
$Folder3 = ".\outil"
$FileUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe"

function floder {              #verifie si les dossiers existent
    # Verifier si le premier dossier existe
    if (-not (Test-Path $Folder1)) {
        New-Item -ItemType Directory -Path $Folder1 -ErrorAction SilentlyContinue
        Write-Host "Le dossier 'apps' a ete cree."
        Write-Host "Merci de mettre votre application dans le dossier 'apps' qui vient d'etre cree."
    }
    if (-not (Test-Path $Folder2)) {
        New-Item -ItemType Directory -Path $Folder2 -ErrorAction SilentlyContinue
        Write-Host "Le dossier 'packages' a ete cree."
    } 
    if (-not (Test-Path $Folder3)) {
        New-Item -ItemType Directory -Path $Folder3 -ErrorAction SilentlyContinue
        Write-Host "Le dossier 'outil' a ete cree."
    } 
    else {
        Write-Host "Les dossiers existent deja."
    }
}

function instal.Ipu {
    if (-not (Test-Path "$Folder3\IntuneWinAppUtil.exe")) {

        Invoke-WebRequest -Uri $FileUrl -OutFile "$Folder3\IntuneWinAppUtil.exe"
        Write-Host "Installation du programme IntuneWinAppUtil.exe"

    } 
    else {
        Write-Host "Le programme IntuneWinAppUtil.exe existe deja."
    }

   
}

function menu {
    $tampo = $true
    Clear-Host
    :myLabel while ($tampo) {
        Write-Host "
    ------menu-----
    1. Toutes les applications
    2. Selectionner une application
    3. Fermer
    ---------------"

        $choix = Read-Host "Entrez le numero souhaite "
        switch ($choix) {
            1 {all}
            2 {one}
            3 {$tampo = $false; break}
            Default {
                Clear-Host
                Write-Host "Veuillez entrer un numero entre 1 et 3."
            }
        }
    }
}

function creat {
    param(
        [string]$tampo
    )
    Write-Host $tampo
    $IntuneWinAppUtilPath = Join-Path -Path $PSScriptRoot -ChildPath "\outil\IntuneWinAppUtil.exe"
    $Folder1v2 = Join-Path -Path $PSScriptRoot -ChildPath "\apps"
    $Folder2v2 = Join-Path -Path $PSScriptRoot -ChildPath "\packages"

    $Folder1v2 = "`"$Folder1v2`""  # Ajout de guillemets autour du chemin
    $Folder2v2 = "`"$Folder2v2`""  # Ajout de guillemets autour du chemin
    $IntuneWinAppUtilPath = "`"$IntuneWinAppUtilPath`""

    $Arguments = "-c $Folder1v2 -s `"$tampo`" -o $Folder2v2"

    Start-Process $IntuneWinAppUtilPath $Arguments

    Write-Host "$IntuneWinAppUtilPath $Arguments"
}

function all {
    $Files = Get-ChildItem -Path $Folder1 -File
    $FileCount = $Files.Count

    $choix = Read-Host "Il y a $FileCount de fichiers, etes-vous sur ? (Y/n)"
    switch ($choix){
        Y { break }
        y { break }
        N { menu; break }
        n { menu; break }
        Default { break }
    }
    Write-Host "---------------"

    $Files = Get-ChildItem -Path $Folder1 -File -Filter "*.exe"
    foreach ($File in $Files) {
        $cfile = $File.Name 
        creat -tampo $cfile
    }
    Clear-Host 
    $Files = Get-ChildItem -Path $Folder1 -File -Filter "*.exe"
    foreach ($File in $Files) {
        $tampo = $File.Name
        Write-Host "$tampo a ete cree."
    }
        
    Write-Host "Appuyez sur n'importe quelle touche pour fermer le programme..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Break myLabel
}

function one {
    Clear-Host
    Write-Host "-----------------"
    Write-Host "Fichiers disponibles:"

    $Files = Get-ChildItem -Path $Folder1 -File -Filter "*.exe"
    $filetotal = $Files.Count
    for ($i = 0; $i -lt $filetotal; $i++) {
        Write-Host "$($i + 1) - $($Files[$i].Name)"
    }

    $tampo = Read-Host "Entrez le numero du programme qui vous interesse (1-$filetotal)"

    if ($tampo -match '^\d+$' -and $tampo -ge 1 -and $tampo -le $filetotal) {
        $selectedFile = $Files[$tampo - 1]
        $cfile = $selectedFile.Name
        creat -tampo $cfile
        Write-Host "Vous avez converti : $($selectedFile.Name)"
        Write-Host "Appuyez sur n'importe quelle touche pour fermer le programme..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Break myLabel
    } else {
        one
    }
}

floder
instal.Ipu
menu
