<#
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

# $DebugPreference = "Continue" #"SilentlyContinue"

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
    $global:MyScriptRoot = Split-Path -Parent $PSCommandPath
    Write-Debug "Script Path: $MyScriptRoot"
    if (Test-Debug) {
        $global:sf = Join-Path $MyScriptRoot -ChildPath "save-singlePlayer.json"
    }
    else {
        $global:sf = Join-Path $env:LocalAPPDATA"Low" -ChildPath "Shiny Shoe\MonsterTrain\saves\save-singlePlayer.json"
        #"Shiny Shoe\MonsterTrain\sync\saves\save-singlePlayer.json" #for GOG version
    }
    $global:relicscsvfile = Join-Path $MyScriptRoot -ChildPath "MT_Relics.csv"
    $global:cardscsvfile = Join-Path $MyScriptRoot -ChildPath "MT_Cards.csv"
    $global:jsonf = Join-Path $MyScriptRoot -ChildPath "*-bundle.json"
    $global:guif = Join-Path $MyScriptRoot -ChildPath "MTSaveGuiWork.ps1"
    Write-Debug "Savefile: $sf"
    #Write-Debug $relicscsvfile
    Write-Debug "JSON location: $jsonf"

    #setup lookup for the relic ids from the CSV
    $global:relicsTable = @{} 
    $global:relicsCsv = Import-Csv $relicscsvfile
    $relicsCsv | ForEach-Object { $relicsTable[$_.relicDataID] = $_.Name + " - " + $_.Description }

    #setup cards csv
    $global:cardsCsv = Import-Csv $cardscsvfile
    $global:cardsTable = $cardsCsv | Group-Object -AsHashTable -Property ID

    LoadJsonBundles
    if (Test-Debug) {
        #$cardsCsv | Out-GridView
        #$cardsTable | Out-GridView
    }
}
Function LookupRelics ($relicids) {
    $datasrc = @{}
    foreach ($bless in $relicids) {
        #Write-Debug $bless.relicDataID
        #$datasrc[$bless.relicDataID] = @{Description = $relicsTable[$bless.relicDataID] }
        $datasrc[$bless.relicDataID] = $relicsTable[$bless.relicDataID]
        #$datasrc+= $relicsCsv| Where {$_.relicDataID -eq $bless.relicDataID};
        Write-Debug($relicsTable[$bless.relicDataID] | Out-String)
    }
    return $datasrc
    #if (Test-Debug) { $datasrc | Out-GridView }
}

Function LookupCards($cards) {
    $datasrc = @{}
    foreach ($card in $cards) {
        if ($cardsTable[$card.cardDataID].Name) {
            $datasrc[$card.cardDataID] = $cardsTable[$card.cardDataID].Name
        }
        else {
            $datasrc[$card.cardDataID] = "#Not in CSV"
        }
        Write-Debug $datasrc[$card.cardDataID]
    }
    #if (Test-Debug) {$datasrc | Out-GridView}
    return $datasrc
}

Function FetchBundle($bname) {
    if ($bname -and $bundles[$bname]) {
        return $bundles[$bname]
    }
    else {
        $choice = $bundles | Out-GridView -OutputMode Single -Title "Choose a bundle and click ok"
        return $choice.Value
    }
}
Function LoadJsonBundles($bname) {
    $files = Get-ChildItem $jsonf
    $global:bundles = @{}
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
    # if ($bname -and $bundles[$bname]) {
    #     return $bundles[$bname]
    # }
    # else {
    #     $choice = $bundles | Out-GridView -OutputMode Single -Title "Choose a bundle and click ok"
    #     return $choice.Value
    # }
}

#Process save file
Function LoadSaveFile() {
    $global:snapshot = (Get-Content ($sf) | ConvertFrom-Json)
    Write-Debug "=== Existing Artifacts ===" #$snapshot.blessings
    $global:blessings = LookupRelics($snapshot.blessings) #for use in GUI 
    # add the new relics from the list above
    #$snapshot.blessings+=$artifacts
    #$snapshot.blessings | Out-GridView
    #$datasrc | Out-GridView
    #$relicsTable | Out-GridView
    #$relicsCsv | Out-GridView
    #$playerblessings | Out-GridView

    #show cards list
    #if (Test-Debug) {$snapshot.deckState | Out-GridView}
    Write-Debug "== Cards List in Deck =="
    $global:cards = LookupCards($snapshot.deckState)
    Return $snapshot
}
Function ModifySaveFile($bundle) {
    if ($bundle) {
        $snapshot.blessings += $bundle
        Write-Debug "=== Modified Artifacts ===" #+ $snapshot.blessings
        $global:blessings = LookupRelics($snapshot.blessings) #for use in GUI #LookupRelics($snapshot.blessings)
        Return $true
    }
    Return $false
}

Function SaveFile() {
    # SAVE THE FILE
    Copy-Item $sf $sf".old" #backup the save file
    # The -replace is a workaround for the convertto-json converting the > to unicode
    if (Test-Debug) { $sf += ".json" } #don't overwrite the actual save file
    $snapshot | ConvertTo-Json -Depth 10 -Compress | ForEach-Object { $_ -replace "\\u003e", ">" } | Set-Content $sf
    #can use the following more general case, from : https://stackoverflow.com/questions/15573415/json-encoding-html-string
    #[regex]::replace($json,'\\u[a-fA-F0-9]{4}',{[char]::ConvertFromUtf32(($args[0].Value -replace '\\u','0x'))})
    
    # or from https://stackoverflow.com/questions/29306439/powershell-convertto-json-problem-containing-special-characters
    #% { [System.Text.RegularExpressions.Regex]::Unescape($_) } 
    # but apparently that has sideeffects, have to test both and see which works better
}
Init
$mtsave = LoadSaveFile
#### USE THE GUI instead
# $bundle = LoadJsonBundles("ember") #freestuff , OP, ember
# if (!(Test-Debug)) {
#     if (ModifySaveFile($bundle)) { SaveFile }
# }
# else {
#     #Write-Debug "Artifacts to add: ${$bundle | out-string}"
#     $bundle | out-string | Write-Debug
# }
#include the GUI
. $guif

