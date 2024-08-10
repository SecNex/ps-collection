<#
.SYNOPSIS
    Module to copy directories and files.
.DESCRIPTION
    This module provides functions to copy directories and files.
    The functions Get-DirectoryFiles, Show-SearchedObjects, Show-Results, and Copy-Objects are exported.

    Get-DirectoryFiles: Get a list of all files in a directory and subdirectories.
    Show-SearchedObjects: Show the searched objects.
    Show-Results: Show the results.
    Copy-Objects: Copy objects.
#>
<#
.SYNOPSIS
    Get a list of all files in a directory and subdirectories.
.DESCRIPTION
    This function gets a list of all files in a directory and subdirectories.
    It returns an array of objects with the properties Name, RelativePath, FullName, Size, LastModified, and IsDirectory.

    Name:         The name of the file or directory.
    RelativePath: The path relative to the project root.
    FullName:     The full path of the file or directory.
    Size:         The size of the file in bytes.
    LastModified: The last modified date of the file or directory.
    IsDirectory:  Indicates whether the object is a directory.
.PARAMETER Path
    The path of the directory to search for files.
.EXAMPLE
    Get-DirectoryFiles -Path "C:\Temp"
    This example gets a list of all files in the directory "C:\Temp".

    Name         RelativePath FullName                     Size LastModified         IsDirectory
    ----         ------------ --------                     ---- ------------         -----------
    file1.txt    file1.txt    C:\Temp\file1.txt            0    01.01.2021 00:00:00 False
    file2.txt    file2.txt    C:\Temp\file2.txt            0    01.01.2021 00:00:00 False
    subfolder1   subfolder1   C:\Temp\subfolder1           0    01.01.2021 00:00:00 True
    subfolder2   subfolder2   C:\Temp\subfolder2           0    01.01.2021 00:00:00 True
#>
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

<#
.SYNOPSIS
    Show the searched objects.
.DESCRIPTION
    This function shows the searched objects.
.PARAMETER CopyObjects
    The objects to show.
.EXAMPLE
    Show-SearchedObjects -CopyObjects $searchedFiles
    This example shows the searched objects.

    Name         RelativePath FullName                     Size LastModified         IsDirectory
    ----         ------------ --------                     ---- ------------         -----------
    file1.txt    file1.txt    C:\Temp\file1.txt            0    01.01.2021 00:00:00 False
    file2.txt    file2.txt    C:\Temp\file2.txt            0    01.01.2021 00:00:00 False
    subfolder1   subfolder1   C:\Temp\subfolder1           0    01.01.2021 00:00:00 True
    subfolder2   subfolder2   C:\Temp\subfolder2           0    01.01.2021 00:00:00 True
#>
function Show-SearchedObjects {
    param (
        [Parameter(Mandatory = $true)]
        [array]$CopyObjects
    )
    $CopyObjects | Format-Table -Property FullName, Size, LastModified, IsDirectory, RelativePath -AutoSize
}

<#
.SYNOPSIS
    Show the results.
.DESCRIPTION
    This function shows the results.
.PARAMETER Results
    The results to show.
.EXAMPLE
    Show-Results -Results $resultObjects
    This example shows the results.

    RelativePath FullName                     Size LastModified         IsDirectory Success Hash
    ------------ --------                     ---- ------------         ----------- ------- ------------------
    file1.txt    C:\Temp\file1.txt            0    01.01.2021 00:00:00  False       True    1234567890
    file2.txt    C:\Temp\file2.txt            0    01.01.2021 00:00:00  False       True    1234567890
    subfolder1   C:\Temp\subfolder1           0    01.01.2021 00:00:00  True        True
    subfolder2   C:\Temp\subfolder2           0    01.01.2021 00:00:00  True        True
#>
function Show-Results {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Results,
        [Parameter(Mandatory = $false)]
        [switch]$FailedOnly
    )
    if ($FailedOnly) {
        $Results = $Results | Where-Object { $_.Success -eq $false }
    }
    $Results | Format-Table -Property RelativePath, Success, IsDirectory, FullName, Hash -AutoSize
}

<#
.SYNOPSIS
    Copy objects.
.DESCRIPTION
    This function copies objects.
.PARAMETER CopyObjects
    The objects to copy.
.PARAMETER Destination
    The destination path.
.EXAMPLE
    Copy-Objects -CopyObjects $searchedFiles -Destination "C:\Temp\Copy"
    This example copies the objects to the destination path.
#>
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

<#
.SYNOPSIS
    Copy objects.
.DESCRIPTION
    This function copies objects.
.PARAMETER CopyObjects
    The objects to copy.
.PARAMETER Destination
    The destination path.
.EXAMPLE
    Copy-Objects -CopyObjects $searchedFiles -Destination "C:\Temp\Copy"
    This example copies the objects to the destination path.
#>
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

function Start-DRPDirectoryCopy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Source,
        [Parameter(Mandatory = $true)]
        [string]$Destination,
        [Parameter(Mandatory = $false)]
        [switch]$SubDirectoryByDate
    )

    if ($SubDirectoryByDate) {
        $Date = Get-Date -Format "yyyy-MM-dd"
        $Destination = Join-Path -Path $Destination -ChildPath $Date
    }

    $files = Get-DirectoryFiles -Path $Source
    Write-Host "Found $($files.Count) objects to copy!"
    $result = Copy-Objects -CopyObjects $files -Destination $Destination
    $failed = $result | Where-Object { $_.Success -eq $false }
    Show-Results -Results $result -FailedOnly

    Write-Host "Failed to copy $($failed.Count) objects!"

    return $failed
}

Export-ModuleMember -Function Get-DirectoryFiles, Show-SearchedObjects, Show-Results, Copy-Objects, Start-DRPDirectoryCopy