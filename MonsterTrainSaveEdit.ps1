﻿<#
    .SYNOPSIS
        Monster Train Save Game Editor

    .DESCRIPTION
        Monster Train Save Game Editor that allows you to edit your artifacts (aka relics), and cards

    .EXAMPLE
        Just run the script
    .NOTES
        Author: Veejs7er
        Last Update: 2020-09-13 v1.0 - Basic text version works
        TO DO:
        ADD GUI for easy usability
        READ cards list and show that
        Need to generate upgrades CSV as well then
        Enable preview and save
        Allow bundles of artifacts/cards

#>

$DebugPreference = "Continue"

function Test-Debug {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$IgnorePSBoundParameters
        ,
        [Parameter(Mandatory = $false)]
        [switch]$IgnoreDebugPreference
        ,
        [Parameter(Mandatory = $false)]
        [switch]$IgnorePSDebugContext
    )
    process {
        ((-not $IgnoreDebugPreference.IsPresent) -and ($DebugPreference -ne "SilentlyContinue")) -or
        ((-not $IgnorePSBoundParameters.IsPresent) -and $PSBoundParameters.Debug.IsPresent) -or
        ((-not $IgnorePSDebugContext.IsPresent) -and ($PSDebugContext))
    }
}

Function Init() {
    #$MyScriptRoot = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
    #$MyScriptRoot = split-path -parent $MyInvocation.MyCommand.Definition
    #$PSScriptRoot wasn't working for some reason in VSCODE
    $MyScriptRoot = Split-Path -Parent $PSCommandPath
    Write-Debug "Script Path: $MyScriptRoot"
    if (Test-Debug) {
        $files = Join-Path $MyScriptRoot -ChildPath "save-singlePlayer.json"
    }
    else {
        $files = Join-Path $env:LocalAPPDATA"Low" -ChildPath "Shiny Shoe\MonsterTrain\saves\save-singlePlayer.json"
    }
    $relicscsvfile = Join-Path $MyScriptRoot -ChildPath "MT_Relics.csv"
    $cardscsvfile = Join-Path $MyScriptRoot -ChildPath "MT_Cards.csv"
    $jsonfiles = Join-Path $MyScriptRoot -ChildPath "*-bundle.json"
    Write-Debug "Savefile: $files"
    #Write-Debug $relicscsvfile
    Write-Debug "JSON location: $jsonfiles"

    #setup lookup for the relic ids from the CSV
    $relicsTable = @{} 
    $relicsCsv = Import-Csv $relicscsvfile
    $relicsCsv | ForEach-Object{ $relicsTable[$_.relicDataID]=$_.Name + " - " + $_.Description}

    #setup cards csv
    $cardsCsv = Import-Csv $cardscsvfile
    $cardsTable = $cardsCsv | Group-Object -AsHashTable -Property ID
    if (Test-Debug) {
        #$cardsCsv | Out-GridView
        #$cardsTable | Out-GridView
    }
}
Function LookupRelics ($relicids) {
    $datasrc = @{}
    foreach($bless in $relicids) {
        #Write-Debug $bless.relicDataID
        #$datasrc[$bless.relicDataID] = @{Description = $relicsTable[$bless.relicDataID] }
        $datasrc[$bless.relicDataID] = $relicsTable[$bless.relicDataID]
        #$datasrc+= $relicsCsv| Where {$_.relicDataID -eq $bless.relicDataID};
        Write-Debug $relicsTable[$bless.relicDataID]
    }
    return $datasrc
    #if (Test-Debug) { $datasrc | Out-GridView }
}

Function LookupCards($cards) {
    $datasrc = @{}
    foreach ($card in $cards) {
        if ($cardsTable[$card.cardDataID].Name) {
            $datasrc[$card.cardDataID] = $cardsTable[$card.cardDataID].Name
        } else {
            $datasrc[$card.cardDataID] = "#Not in CSV"
        }
        Write-Debug $datasrc[$card.cardDataID]
    }
    #if (Test-Debug) {$datasrc | Out-GridView}
}

Function LoadJsonBundles($bname) {
    $files = Get-ChildItem $jsonfiles
    $bundles = @{}
    foreach ($file in $files) {
        $name = Split-Path $file -leaf 
        $name = ($name -split "-bundle.json")[0]
        #Write-Debug $name
        $c = Get-Content $file | ConvertFrom-Json
        #$c | Out-GridView
        #$c | ForEach-Object {$_ | Add-Member -Name "Description" -MemberType NoteProperty -Value {$relicsTable[$_]}}
        #$c | Out-GridView
        $bundles[$name] = $c
        #LookupRelics($c) | Out-GridView
        #write-host $c | ConvertTo-Json
    }
    if ($bname -and $bundles[$bname]) {
        return $bundles[$bname]}
    else {
        $choice = $bundles | Out-GridView -OutputMode Single -Title "Choose a bundle and click ok"
        return $choice.Value
    }
}

#Process save file
Function LoadSaveFile() {
    $save = $false
    $snapshot = (Get-Content ($files) | ConvertFrom-Json)
    Write-Debug "=== Existing Artifacts ===" #$snapshot.blessings
    LookupRelics($snapshot.blessings)
    # add the new relics from the list above
    #$snapshot.blessings+=$artifacts
    $bundle = LoadJsonBundles("freestuff")
    if ($bundle) {
        $snapshot.blessings+=$bundle
        Write-Debug "=== Modified Artifacts ===" #+ $snapshot.blessings
        LookupRelics($snapshot.blessings)
        $save=$true
    }
    #$snapshot.blessings | Out-GridView
    #$datasrc | Out-GridView
    #$relicsTable | Out-GridView
    #$relicsCsv | Out-GridView
    #$playerblessings | Out-GridView

    #show cards list
    #if (Test-Debug) {$snapshot.deckState | Out-GridView}
    Write-Debug "== Cards List in Deck =="
    LookupCards($snapshot.deckState)

    # SAVE THE FILE
    if ($save) {
        Copy-Item $files $files".old" #backup the save file
        # The -replace is a workaround for the convertto-json converting the > to unicode
        if (Test-Debug) {$files+=".json"} #don't overwrite the actual save file
        $snapshot | ConvertTo-Json -Depth 10 -Compress| ForEach-Object {$_ -replace "\\u003e",">"}| Set-Content $files
        #can use the following more general case, from : https://stackoverflow.com/questions/15573415/json-encoding-html-string
        #[regex]::replace($json,'\\u[a-fA-F0-9]{4}',{[char]::ConvertFromUtf32(($args[0].Value -replace '\\u','0x'))})
        
        # or from https://stackoverflow.com/questions/29306439/powershell-convertto-json-problem-containing-special-characters
        #% { [System.Text.RegularExpressions.Regex]::Unescape($_) } 
        # but apparently that has sideeffects, have to test both and see which works better
    }

}
Init
LoadSaveFile