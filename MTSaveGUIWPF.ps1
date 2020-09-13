#-------------------------------------------------------------#
#----Initial Declarations-------------------------------------#
#-------------------------------------------------------------#

Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="800" Height="400">
<Grid>
 <TabControl Margin="0,0,0,0" Name="Artifacts"><TabItem Header="Artifacts"><Grid Background="#FFE5E5E5" Margin="0,0,0,0">
<DataGrid HorizontalAlignment="Left" VerticalAlignment="Top" Width="300" Height="300" Margin="0,0,0,0" Name="savefile"/>
<DataGrid HorizontalAlignment="Left" VerticalAlignment="Top" Width="300" Height="300" Margin="400,0,0,0" Name="available"/>
<ListView HorizontalAlignment="Left" BorderBrush="Black" BorderThickness="1" Height="253" VerticalAlignment="Top" Width="111" Margin="254,21,0,0"/>
</Grid>
</TabItem><TabItem Header="Cards"><Grid Background="#FFE5E5E5">
</Grid></TabItem></TabControl>
</Grid></Window>
"@

#-------------------------------------------------------------#
#----Control Event Handlers-----------------------------------#
#-------------------------------------------------------------#


#Write your code here
#endregion

#-------------------------------------------------------------#
#----Script Execution-----------------------------------------#
#-------------------------------------------------------------#

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }



$Window.ShowDialog()


