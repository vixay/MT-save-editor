#Sample for this question on SO https://stackoverflow.com/questions/52405852/link-wpf-xaml-to-datagrid-in-powershell?sem=2
$inputXML = @"
<Window x:Class="WpfApp2.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp2"
        mc:Ignorable="d"
        Title="MainWindow">
    <TabControl Margin="0,0,0,0" Name="Artifacts">
        <TabItem Header="Artifacts">        
        <Grid>
            <DataGrid IsReadOnly="True" Name="DGSave" AutoGenerateColumns="False" HorizontalAlignment="Left" VerticalAlignment="Stretch" Width="320" Margin="0,0,0,0" HorizontalScrollBarVisibility="Hidden">
                <DataGrid.Columns>
                    <DataGridTextColumn IsReadOnly="True" Header="ID" Binding="{Binding Key}" Width="40" />
                    <DataGridTextColumn IsReadOnly="True" Header="Value" Binding="{Binding Value}" Width="280">
                            <DataGridTextColumn.ElementStyle>
                            <Style TargetType="TextBlock">
                                <Setter Property="TextBlock.TextWrapping" Value="Wrap" />
                            </Style>
                        </DataGridTextColumn.ElementStyle>
                    </DataGridTextColumn>
                </DataGrid.Columns>
            </DataGrid>
            <Button Content="Select" HorizontalAlignment="Left" VerticalAlignment="Center" Width="70" Margin="325,0,0,0" Name="bSelect"/>
            <DataGrid IsReadOnly="True" Name="DGArtifacts" AutoGenerateColumns="False" HorizontalAlignment="Left" VerticalAlignment="Stretch" Margin="400,0,0,0" HorizontalScrollBarVisibility="Hidden">
                <DataGrid.Columns>
                    <DataGridTextColumn IsReadOnly="True" Header="ID" Binding="{Binding relicDataID}" Width="40" />
                    <DataGridTextColumn IsReadOnly="True" Header="Name" Binding="{Binding Name}" Width="160" />
                    <DataGridTextColumn IsReadOnly="True" Header="Description" Binding="{Binding Description}">
                        <DataGridTextColumn.ElementStyle>
                            <Style TargetType="TextBlock">
                                <Setter Property="TextBlock.TextWrapping" Value="Wrap" />
                            </Style>
                        </DataGridTextColumn.ElementStyle>
                    </DataGridTextColumn>
                </DataGrid.Columns>
            </DataGrid>
            <Button Content="Reload" HorizontalAlignment="Left" VerticalAlignment="Bottom" Width="70" Margin="325,0,0,40" Name="bReload"/>
            <Button Content="Save" HorizontalAlignment="Left" VerticalAlignment="Bottom" Width="70" Margin="325,0,0,10" Name="bSave"/>
        </Grid>
        </TabItem>
        <TabItem Header="Cards">
            <Grid Background="#FF000095">
            </Grid>
        </TabItem>
        <TabItem Header="Bundles">
            <Grid Background="#FF009500">
                <Label> Double click a bundle name to add the list of artifacts to your save file </Label>
                <ListBox x:Name="lstBundles" Height="100"/>
            </Grid>
        </TabItem>
    </TabControl>
</Window>
"@ 
  
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
  
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    if ($error[0].Exception.Message -like "*button*"){
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"}
}
catch{#if it broke some other way <span class="wp-smiley wp-emoji wp-emoji-bigsmile" title=":D">:D</span>
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        }
  
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | ForEach-Object{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
  
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
  
Get-FormVariables

$WPFDGArtifacts.ItemsSource = $relicsCsv
$WPFDGSave.ItemsSource = $blessings #LookupRelics($snapshot.blessings)#[pscustomobject]$snapshot.blessings
# Format the GUI
$WPFDGSave.CanUserSortColumns = $WPFDGArtifacts.CanUserSortColumns = $true;  
# Handle doubleclick
$clickEvent = {
    #param ($sender,$e) #not needed because we access the datagrid directly
    Write-Host $WPFDGArtifacts.SelectedItems.count
    Write-Debug "Clicked row $($WPFDGArtifacts.SelectedItems)"
    $WPFDGArtifacts.SelectedItems | ForEach-Object {
            Write-Host $_.relicDataID
        }
    #ModifySaveFile($WPFDGArtifacts.SelectedItems.relicDataID) # load the selected objects into the save file view
    ModifySaveFile($WPFDGArtifacts.SelectedItems | Select-Object -Property relicDataID) # load the selected objects into the save file view
    $WPFDGSave.ItemsSource = $blessings
    #$WPFDGSave.Items.Refresh() #Source = $blessings # reload list of blessings
    #$Form.UpdateLayout
    }
$WPFDGArtifacts.add_MouseDoubleClick($clickEvent)
$WPFbSelect.add_Click($clickEvent)
$WPFbReload.add_Click({LoadSaveFile; $WPFDGSave.ItemsSource = $blessings})
$WPFbSave.add_Click({SaveFile})

#TODO: add function to add the selected items to the list of artifacts that we need to save. 
#  color the new rows
#  add a save Button - DONE
#  add a reload Button - DONE
# $WPFDGArtifacts.AddHandler([System.Windows.Controls.DataGrid]::ClickEvent,$clickEvent)
#$temp = $bundles| Select-Object -Property @{Name='CollectionName';Expression={$_.Keys}}
#$temp = $bundles.Keys | out-string
$loadbundle = {
    Write-Host $WPFlstBundles.SelectedItems.count
    Write-Debug "Clicked row $($WPFlstBundles.SelectedItems)"
    $WPFlstBundles.SelectedItems | ForEach-Object {
            Write-Host $_
            ModifySaveFile(FetchBundle($_))
        }
    $WPFDGSave.ItemsSource = $blessings
    #ModifySaveFile($WPFDGArtifacts.SelectedItems | Select-Object -Property relicDataID) # load the selected objects into the save file view
}
$WPFlstBundles.add_MouseDoubleClick($loadbundle)
foreach ($key in $bundles.Keys) {
    $WPFlstBundles.AddChild($key)
}
#$WPFlstBundles.ItemsSource = $temp

$Form.ShowDialog() | out-null