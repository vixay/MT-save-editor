<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    MTArtifacts
.SYNOPSIS
    Monster Train Save Editor
.DESCRIPTION
    Monster Train Save Game Editor that allows you to edit your artifacts (aka relics), and cards
.NOTES
            Author: Veejs7er         Last Update: 2020-09-13 v1.0 - Basic text version works
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(683,586)
$Form.text                       = "Form"
$Form.TopMost                    = $false

$DGSave                          = New-Object system.Windows.Forms.DataGridView
$DGSave.width                    = 300
$DGSave.height                   = 483
$DGSave.location                 = New-Object System.Drawing.Point(14,24)

$DGRelics                        = New-Object system.Windows.Forms.DataGridView
$DGRelics.width                  = 305
$DGRelics.height                 = 488
$DGRelics.location               = New-Object System.Drawing.Point(335,23)

$bSave                           = New-Object system.Windows.Forms.Button
$bSave.text                      = "Save"
$bSave.width                     = 60
$bSave.height                    = 30
$bSave.location                  = New-Object System.Drawing.Point(581,529)
$bSave.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)

$bReload                         = New-Object system.Windows.Forms.Button
$bReload.text                    = "Reload"
$bReload.width                   = 60
$bReload.height                  = 30
$bReload.location                = New-Object System.Drawing.Point(17,531)
$bReload.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)

$ListView1                       = New-Object system.Windows.Forms.ListView
$ListView1.text                  = "listView"
$ListView1.width                 = 274
$ListView1.height                = 361
$ListView1.location              = New-Object System.Drawing.Point(88,191)

$bAdd                            = New-Object system.Windows.Forms.Button
$bAdd.text                       = "<--"
$bAdd.width                      = 60
$bAdd.height                     = 30
$bAdd.location                   = New-Object System.Drawing.Point(293,77)
$bAdd.Font                       = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)

$bRemove                         = New-Object system.Windows.Forms.Button
$bRemove.text                    = "-->"
$bRemove.width                   = 60
$bRemove.height                  = 30
$bRemove.location                = New-Object System.Drawing.Point(291,118)
$bRemove.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)

$Form.controls.AddRange(@($DGSave,$DGRelics,$bSave,$bReload,$ListView1,$bAdd,$bRemove))

$Form.Show()
