# Function to get a list of all files in a directory and subdirectories
# Example: Get-DirectoryFiles -Path "C:\Temp" -Recurse

function Get-DirectoryFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Path = (Get-Item -Path $Path).FullName
    $subDirectories = @()
    $searchedFiles = @()

    $files = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue -Recurse
    
    for ($i = 0; $i -lt $files.Count; $i++) {
        # Project path is the path relative to the project root
        $fullPath = $files[$i].FullName
        $relativePath = $fullPath.Replace($Path, "").TrimStart('\')
        $searchedFiles += [PSCustomObject]@{
            Name         = $files[$i].Name
            RelativePath = $relativePath
            FullName     = $files[$i].FullName
            Size         = $files[$i].Length
            LastModified = $files[$i].LastWriteTime
            IsDirectory  = $files[$i].PSIsContainer
        }
        if ($files[$i].PSIsContainer) {
            $subDirectories += $files[$i].FullName
        }
    }

    return $searchedFiles
}

function Show-SearchedObjects {
    param (
        [Parameter(Mandatory = $true)]
        [array]$CopyObjects
    )
    $CopyObjects | Format-Table -Property FullName, Size, LastModified, IsDirectory, RelativePath -AutoSize
}

function Show-Results {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Results
    )
    $Results | Format-Table -Property Name, Success, RelativePath, FullName, Size, LastModified, IsDirectory -AutoSize
}

function Get-DirectoryFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Path = (Get-Item -Path $Path).FullName
    $subDirectories = @()
    $searchedFiles = @()

    $files = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue -Recurse
    
    for ($i = 0; $i -lt $files.Count; $i++) {
        # Project path is the path relative to the project root
        $fullPath = $files[$i].FullName
        $relativePath = $fullPath.Replace($Path, "").TrimStart('\')
        $searchedFiles += [PSCustomObject]@{
            Name         = $files[$i].Name
            RelativePath = $relativePath
            FullName     = $files[$i].FullName
            Size         = $files[$i].Length
            LastModified = $files[$i].LastWriteTime
            IsDirectory  = $files[$i].PSIsContainer
        }
        if ($files[$i].PSIsContainer) {
            $subDirectories += $files[$i].FullName
        }
    }

    return $searchedFiles
}

function Show-Results {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Results
    )
    $Results | Format-Table -Property RelativePath, Success, IsDirectory, FullName, Hash -AutoSize
}

function Copy-Objects {
    param (
        [Parameter(Mandatory = $true)]
        [array]$CopyObjects,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    if (-not (Test-Path -Path $Destination)) {
        New-Item -Path $Destination -ItemType Directory -ErrorAction Stop | Out-Null
    }

    $resultObjects = @()
    $successCopiesCount = 0

    $SortedObjects = $CopyObjects | Sort-Object -Property RelativePath, IsDirectory
    foreach ($CopyObject in $SortedObjects) {
        if ($CopyObject.IsDirectory) {
            $destinationPath = Join-Path -Path $Destination -ChildPath $CopyObject.RelativePath
            if (-not (Test-Path -Path $destinationPath)) {
                try {
                    New-Item -Path $destinationPath -ItemType Directory -ErrorAction Stop | Out-Null
                    $resultObjects += [PSCustomObject]@{
                        Name         = $CopyObject.Name
                        RelativePath = $CopyObject.RelativePath
                        FullName     = $CopyObject.FullName
                        Size         = $CopyObject.Size
                        LastModified = $CopyObject.LastModified
                        IsDirectory  = $CopyObject.IsDirectory
                        Success      = $true
                    }
                    $successCopiesCount++
                }
                catch {
                    Write-Host $_.Exception.Message
                    $resultObjects += [PSCustomObject]@{
                        Name         = $CopyObject.Name
                        RelativePath = $CopyObject.RelativePath
                        FullName     = $CopyObject.FullName
                        Size         = $CopyObject.Size
                        LastModified = $CopyObject.LastModified
                        IsDirectory  = $CopyObject.IsDirectory
                        Success      = $false
                    }
                }
            } else {
                $resultObjects += [PSCustomObject]@{
                    Name         = $CopyObject.Name
                    RelativePath = $CopyObject.RelativePath
                    FullName     = $CopyObject.FullName
                    Size         = $CopyObject.Size
                    LastModified = $CopyObject.LastModified
                    IsDirectory  = $CopyObject.IsDirectory
                    Success      = $false
                }
                $successCopiesCount++
            }
        }
        else {
            $destinationPath = Join-Path -Path $Destination -ChildPath $CopyObject.RelativePath
            if (-not (Test-Path -Path $destinationPath)) {
                try {
                    # Get hash of the file
                    $hash = Get-FileHash -Path $CopyObject.FullName -Algorithm SHA256
                    Copy-Item -Path $CopyObject.FullName -Destination $destinationPath -ErrorAction Stop
                    $resultObjects += [PSCustomObject]@{
                        Name         = $CopyObject.Name
                        RelativePath = $CopyObject.RelativePath
                        FullName     = $CopyObject.FullName
                        Size         = $CopyObject.Size
                        LastModified = $CopyObject.LastModified
                        IsDirectory  = $CopyObject.IsDirectory
                        Success      = $true
                        Hash         = $hash.Hash
                    }
                    $successCopiesCount++
                }
                catch {
                    Write-Host $_.Exception.Message
                    $resultObjects += [PSCustomObject]@{
                        Name         = $CopyObject.Name
                        RelativePath = $CopyObject.RelativePath
                        FullName     = $CopyObject.FullName
                        Size         = $CopyObject.Size
                        LastModified = $CopyObject.LastModified
                        IsDirectory  = $CopyObject.IsDirectory
                        Success      = $false
                    }
                }
            } else {
                $resultObjects += [PSCustomObject]@{
                    Name         = $CopyObject.Name
                    RelativePath = $CopyObject.RelativePath
                    FullName     = $CopyObject.FullName
                    Size         = $CopyObject.Size
                    LastModified = $CopyObject.LastModified
                    IsDirectory  = $CopyObject.IsDirectory
                    Success      = $false
                }
            }
        }
    }

    return $resultObjects
}

Export-ModuleMember -Function Get-DirectoryFiles, Show-SearchedObjects, Show-Results, Copy-Objects