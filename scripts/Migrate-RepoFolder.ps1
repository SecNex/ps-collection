# Define variables
$oldRepoPath = "C:\Temp\old-repo"
$newRepoUrl = "https://dev.azure.com/deinProjektName/deinRepoName/_git/neuesRepository"
$newRepoLocalPath = "C:\Temp\repo"
$targetFolderInNewRepo = "scripts"

# Clone the new repository from Azure DevOps
git clone $newRepoUrl $newRepoLocalPath

# Navigate to the old repository
Set-Location $oldRepoPath

# Verify that the current directory is a Git repository
if (!(Test-Path -Path ".git")) {
    Write-Error "Der angegebene Ordner ist kein Git-Repository"
    exit
}

# Copy the contents of the old repository to the target folder in the new repository
$destinationPath = Join-Path $newRepoLocalPath $targetFolderInNewRepo

if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# Exclude the .git directory and copy other files
Get-ChildItem -Path $oldRepoPath -Recurse -Exclude ".git*" | Copy-Item -Destination $destinationPath -Recurse -Force

# Navigate to the new repository's local path
Set-Location $newRepoLocalPath

# Add and commit the copied files
git add .
git commit -m "Moved old repository files to $targetFolderInNewRepo"

# Push the changes to the new repository
git push origin main

Write-Host "Das alte Repository wurde erfolgreich in den Zielordner '$targetFolderInNewRepo' im neuen Repository verschoben und gepusht."