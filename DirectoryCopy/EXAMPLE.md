# DirectoryCopy

This is an example file that will be copied to the output directory.

## Installation

```powershell
Import-Module -Name /path/to/DirectoryCopy
```

## Usage

```powershell
$files = Get-DirectoryFiles -Path "..\source"
Write-Host "Found $($files.Count) objects to copy!"
$result = Copy-Objects -CopyObjects $files -Destination "destination"
$failed = $result | Where-Object { $_.Success -eq $false }
$success = $result | Where-Object { $_.Success -eq $true }
Show-Results -Results $result
if ($failed.Count -gt 0) {
    Write-Host "Failed to copy $($failed.Count) objects!"
}
if ($success.Count -gt 0) {
    Write-Host "Successfully copied $($success.Count) objects!"
}
```