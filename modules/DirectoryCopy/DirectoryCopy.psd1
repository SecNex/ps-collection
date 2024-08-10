@{
    ModuleVersion = '0.1.0'
    GUID = 'df8c3dab-73f0-4117-b47d-91a592a651a3'
    Author = 'Björn Benouarets'
    CompanyName = 'SecNex.io'
    Copyright = '(c) SecNex. All rights reserved.'
    Description = 'This module provides functions to copy directories and files.'
    FunctionsToExport = @(
        'Get-DirectoryFiles',
        'Show-SearchedObjects',
        'Show-Results',
        'Copy-Objects',
        'Start-DRPDirectoryCopy'
    )
    RequiredModules = @()
    RequiredAssemblies = @()
    FileList = @('DirectoryCopy.psm1')
    ModuleList = @()
    NestedModules = @()
    FormatsToProcess = @()
    TypesToProcess = @()
    ScriptsToProcess = @()
    AliasesToExport = @()
    VariablesToExport = @()
    CmdletsToExport = @(
        'Get-DirectoryFiles',
        'Show-SearchedObjects',
        'Show-Results',
        'Copy-Objects',
        'Start-DRPDirectoryCopy'
    )
    PrivateData = @{}
}