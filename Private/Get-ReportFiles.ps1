﻿function Get-ReportFiles {
    [CmdletBinding()]
    param(
        [string] $Path
    )
    $Files = Get-ChildItem -LiteralPath $Path -Filter '*.sql'
    $Reports = [ordered] @{ }
    foreach ($_ in $Files ) {
        $Name = $_.Name.Replace(' ', '').Replace('.sql', '')
        $Reports[$Name] = [ordered] @{
            Name        = $Name
            DisplayName = ($_.Name).Replace('.sql', '')
            FullPath    = $_.FullName
        }
    }
    $Reports
}