Import-AzureRmContext -Path "$env:HOMEPATH/azureprofile.json"

Write-Output "create automation account"
New-AzureRmAutomationAccount -ResourceGroupName $env:GROUP -Name $env:AUTOMATION -Location $env:LOCATION -Plan Free

Write-Output "upload powershell modules"
New-AzureRmAutomationModule -AutomationAccountName $env:AUTOMATION -ResourceGroupName $env:GROUP -Name xNetworking -ContentLink "https://www.powershellgallery.com/api/v2/package/xNetworking/5.1.0.0"
New-AzureRmAutomationModule -AutomationAccountName $env:AUTOMATION -ResourceGroupName $env:GROUP -Name xPSDesiredStateConfiguration -ContentLink "https://www.powershellgallery.com/api/v2/package/xPSDesiredStateConfiguration/7.0.0.0"
New-AzureRmAutomationModule -AutomationAccountName $env:AUTOMATION -ResourceGroupName $env:GROUP -Name xStorage -ContentLink "https://www.powershellgallery.com/api/v2/package/xStorage/3.2.0.0"
Start-Sleep -Seconds 60

Write-Output "upload minecraft server powershell DSC configuration"
Import-AzureRmAutomationDscConfiguration -AutomationAccountName $env:AUTOMATION -ResourceGroupName $env:GROUP -SourcePath "$env:CONFIG_NAME.ps1" -Force -Published

Write-Output "compile DSC configuration"
$Params = @{"minecraftVersion"="$env:MVERSION";"accountName"="$env:STORAGE_ACCOUNT";"containerName"="$env:STORAGE_CONTAINER";"vmName"="$env:VM_NAME"}
$CompilationJob = Start-AzureRmAutomationDscCompilationJob -AutomationAccountName $env:AUTOMATION -ConfigurationName $env:CONFIG_NAME -Parameters $Params -ResourceGroupName $env:GROUP

while($CompilationJob.EndTime -eq $null -and $CompilationJob.Exception -eq $null)
{
    $CompilationJob = $CompilationJob | Get-AzureRmAutomationDscCompilationJob
    Start-Sleep -Seconds 3
}

Register-AzureRmAutomationDscNode -AzureVMName $env:VM_NAME `
                                    -AzureVMResourceGroup $env:GROUP `
                                    -AzureVMLocation $env:LOCATION `
                                    -ResourceGroupName $env:GROUP -AutomationAccountName $env:AUTOMATION `
                                    -NodeConfigurationName "$env:CONFIG_NAME.$env:VM_NAME" `
                                    -ConfigurationMode ApplyAndAutocorrect `
                                    -ActionAfterReboot ContinueConfiguration `
                                    -RebootNodeIfNeeded $true `
                                    -AllowModuleOverwrite $true