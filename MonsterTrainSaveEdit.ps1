<#
    .SYNOPSIS
        Monster Train Save Game Editor

    .DESCRIPTION
        Monster Train Save Game Editor that allows you to edit your artifacts (aka relics), and cards

    .EXAMPLE
        Just run the script
    .AUTHOR
        Veejs7er
    .UPDATE
        2020-09-13 v1.0 - Basic text version works
    .TO DO
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

#$MyScriptRoot = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
#$MyScriptRoot = split-path -parent $MyInvocation.MyCommand.Definition
$MyScriptRoot = Split-Path -Parent $PSCommandPath
Write-Debug $MyScriptRoot
$files = Join-Path $MyScriptRoot -ChildPath "save-singlePlayer.json"
$relicscsvfile = Join-Path $MyScriptRoot -ChildPath "MT_Relics.csv"
$cardscsvfile = Join-Path $MyScriptRoot -ChildPath "MT_Cards.csv"
Write-Debug $files 
Write-Debug $relicscsvfile


#setup lookup for the relic ids from the CSV
$relicsTable = @{} 
$relicsCsv = Import-Csv $relicscsvfile
$relicsCsv | ForEach-Object{ $relicsTable[$_.relicDataID]=$_.Name + " - " + $_.Description}

#setup cards csv
$cardsCsv = Import-Csv $cardscsvfile
if (Test-Debug) {
    #$cardsCsv | Out-GridView
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
    if (Test-Debug) { $datasrc | Out-GridView }
}

$blessingstoadd = '{"relicDataID":"ffcb6931-e45e-4e27-bacf-4c649779c2be"} ' | ConvertFrom-Json
$artifacts = @'
[{"relicDataID":"b8071ec7-60b6-4526-bd2e-877ba90310d0"}, 
{"relicDataID":"18217b11-1a34-436c-9c5a-7326c5b655a0"},
{"relicDataID":"18217b11-1a34-436c-9c5a-7326c5b655a0"},
{"relicDataID":"18217b11-1a34-436c-9c5a-7326c5b655a0"},
{"relicDataID":"18217b11-1a34-436c-9c5a-7326c5b655a0"},
{"relicDataID":"51d95691-d59e-42f1-84ba-8c530743df69"},
{"relicDataID":"51d95691-d59e-42f1-84ba-8c530743df69"},
{"relicDataID":"f3f07b9b-1349-41d0-abab-bd5ec04d81e4"},
{"relicDataID":"b7822614-96ec-4ace-9029-6efc8adef374"},
{"relicDataID":"ba26070b-4f6b-4af0-a1ec-2af024b6af87"},
{"relicDataID":"68ef2523-5c2e-4660-b96d-00b1c0485f54"},
{"relicDataID":"55ca34e9-047b-4b93-b390-d8d228a43261"},
{"relicDataID":"775d24d8-98eb-4f22-ae50-d7069bf05757"},
{"relicDataID":"22f5ff29-69be-4043-9fe1-245392ea3c95"},
{"relicDataID":"ba36ec3c-9bb8-4428-b15b-d989cf70216b"},
{"relicDataID":"32634a16-f477-463d-b697-e814197da535"}]
'@ | ConvertFrom-Json


#Go through all the arrays (files)
Foreach($file in $files)
{
    $snapshot = (Get-Content ($file) | ConvertFrom-Json)
    Write-Debug "before: " #$snapshot.blessings
    LookupRelics($snapshot.blessings)

    $snapshot.blessings+=$blessingstoadd
    $snapshot.blessings+=$blessingstoadd
    $snapshot.blessings+=$artifacts
    Write-Debug "after: " #+ $snapshot.blessings
    LookupRelics($snapshot.blessings)

    #$snapshot.blessings | Out-GridView
    #$datasrc | Out-GridView
    #$relicsTable | Out-GridView
    #$relicsCsv | Out-GridView
    #$playerblessings | Out-GridView

    #show cards list
    #if (Test-Debug) {$snapshot.deckState | Out-GridView}

    # SAVE THE SAVE FILE
    #Write-Host "new file:"
    # The -replace is a workaround for the convertto-json converting the > to unicode
    $snapshot | ConvertTo-Json -Depth 10 -Compress| ForEach-Object {$_ -replace "\\u003e",">"}| Set-Content $files".json"
    
    #can use the following more general case, from : https://stackoverflow.com/questions/15573415/json-encoding-html-string
    #[regex]::replace($json,'\\u[a-fA-F0-9]{4}',{[char]::ConvertFromUtf32(($args[0].Value -replace '\\u','0x'))})
    
    # or from https://stackoverflow.com/questions/29306439/powershell-convertto-json-problem-containing-special-characters
    #% { [System.Text.RegularExpressions.Regex]::Unescape($_) } 
    # but apparently that has sideeffects, have to test both and see which works better

    # get config corresponds to the $file
    #$config = Invoke-Expression ('$json.' + $file)

    # set value according to the config
    #Invoke-Expression ('$snapshot.' + $config.name + "='" + $config.value + "'")

    # $snapshot.properties.availability.frequency
    # -> $Frequency$
}

