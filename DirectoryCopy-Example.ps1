Import-Module -Name ./modules/DirectoryCopy/DirectoryCopy.psm1

$Destination = "destination"
Start-DRPDirectoryCopy -Source "../source" -Destination $Destination -SubDirectoryByDate