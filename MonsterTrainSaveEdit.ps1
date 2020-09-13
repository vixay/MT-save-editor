function ConvertTo-Object($hashtable) 
{
   $object = New-Object PSObject
   $hashtable.GetEnumerator() | 
      ForEach-Object { Add-Member -inputObject $object `
	  	-memberType NoteProperty -name $_.Name -value $_.Value }
   $object
}
#Credit: SAPIEN

function ConvertTo-DataTable
{
	<#
		.SYNOPSIS
			Converts objects into a DataTable.
	
		.DESCRIPTION
			Converts objects into a DataTable, which are used for DataBinding.
	
		.PARAMETER  InputObject
			The input to convert into a DataTable.
	
		.PARAMETER  Table
			The DataTable you wish to load the input into.
	
		.PARAMETER RetainColumns
			This switch tells the function to keep the DataTable's existing columns.
		
		.PARAMETER FilterWMIProperties
			This switch removes WMI properties that start with an underline.
	
		.EXAMPLE
			$DataTable = ConvertTo-DataTable -InputObject (Get-Process)
	#>
	[OutputType([System.Data.DataTable])]
	param(
	[ValidateNotNull()]
	$InputObject, 
	[ValidateNotNull()]
	[System.Data.DataTable]$Table,
	[switch]$RetainColumns,
	[switch]$FilterWMIProperties)
	
	if($Table -eq $null)
	{
		$Table = New-Object System.Data.DataTable
	}

	if($InputObject-is [System.Data.DataTable])
	{
		$Table = $InputObject
	}
	else
	{
		if(-not $RetainColumns -or $Table.Columns.Count -eq 0)
		{
			#Clear out the Table Contents
			$Table.Clear()

			if($InputObject -eq $null){ return } #Empty Data
			
			$object = $null
			#find the first non null value
			foreach($item in $InputObject)
			{
				if($item -ne $null)
				{
					$object = $item
					break	
				}
			}

			if($object -eq $null) { return } #All null then empty
			
			#Get all the properties in order to create the columns
			foreach ($prop in $object.PSObject.Get_Properties())
			{
				if(-not $FilterWMIProperties -or -not $prop.Name.StartsWith('__'))#filter out WMI properties
				{
					#Get the type from the Definition string
					$type = $null
					
					if($prop.Value -ne $null)
					{
						try{ $type = $prop.Value.GetType() } catch {}
					}

					if($type -ne $null) # -and [System.Type]::GetTypeCode($type) -ne 'Object')
					{
		      			[void]$table.Columns.Add($prop.Name, $type) 
					}
					else #Type info not found
					{ 
						[void]$table.Columns.Add($prop.Name) 	
					}
				}
		    }
			
			if($object -is [System.Data.DataRow])
			{
				foreach($item in $InputObject)
				{	
					$Table.Rows.Add($item)
				}
				return  @(,$Table)
			}
		}
		else
		{
			$Table.Rows.Clear()	
		}
		
		foreach($item in $InputObject)
		{		
			$row = $table.NewRow()
			
			if($item)
			{
				foreach ($prop in $item.PSObject.Get_Properties())
				{
					if($table.Columns.Contains($prop.Name))
					{
						$row.Item($prop.Name) = $prop.Value
					}
				}
			}
			[void]$table.Rows.Add($row)
		}
	}

	return @(,$Table)	
}

$files = "save-singlePlayer.json"

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

#setup lookup for the relic ids from the CSV
$relicsTable = @{} 
$relicsCsv = Import-Csv '.\MT RELIC.csv' 
$relicsCsv | %{ $relicsTable[$_.relicDataID]=$_.Name + " - " + $_.Description}

#Go through all the arrays (files)
Foreach($file in $files)
{
    $snapshot = (Get-Content ("./" + $file) | ConvertFrom-Json)
    Write-Host "before: " $snapshot.blessings
    $datasrc = @{}
    foreach($bless in $snapshot.blessings) {
        #Write-Host $bless.relicDataID
        #$datasrc = @{ID = $bless; Description = $relicsTable[$bless.relicDataID]}
        $datasrc+= $relicsCsv| Where {$_.relicDataID -eq $bless.relicDataID} | ConvertTo-Object
        #Write-Host $relicsTable[$bless.relicDataID]
    }



    $snapshot.blessings+=$blessingstoadd
    $snapshot.blessings+=$blessingstoadd
    $snapshot.blessings+=$artifacts
    Write-Host "after: " + $snapshot.blessings
    $datasrc = @{}
    foreach($bless in $snapshot.blessings) {
        #Write-Host $bless.relicDataID
        #$datasrc = @{ID = $bless; Description = $relicsTable[$bless.relicDataID]}
        #$datasrc+= $relicsCsv| Where {$_.relicDataID -eq $bless.relicDataID};
        #Write-Host $relicsTable[$bless.relicDataID]
    }
    #$snapshot.blessings | Out-GridView
    $datasrc | Out-GridView
    #$relicsTable | Out-GridView
    #$relicsCsv | Out-GridView
    #$playerblessings | Out-GridView
    #Write-Host "new file:"
    # The -replace is a workaround for the convertto-json converting the > to unicode
    $snapshot | ConvertTo-Json -Depth 10 -Compress| % {$_ -replace "\\u003e",">"}| Set-Content $files".json"
    
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