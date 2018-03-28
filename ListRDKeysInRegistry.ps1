# TO-DO: - Write two New-PSDrive -Name HKLM (Local machine) and HKCU (Current User)
# - then figure out how to get /Classes  CLID's, etc.
# If you have a dev build, unregister it < specifly if I find any assemblies
#If you have a installed release, uninstall it
#Review your registry (regedit.exe) to ensure you do not have any reference to Rubberduck in those following keys:
#  .\CLSID
#  .\Interface
#  .\Rubberduck.<name of classes>
#  .\TypeLib

#HKLM\Wow6432Node\Classes
#  .\CLSID
#  .\Interface

Write-Host "Rubberduck version installed on current system"
$InstalledKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
Get-ChildItem -Path $InstalledKeys | Where-Object -FilterScript { $_.GetValue("DisplayName") -like "Rubberduck*"}
#New-PSDrive -Name Classes -PSProvider Registry -Root HKEY_CLASSES_ROOT
#Get-ChildItem -Path $HKCUKeys | Where-Object -FilterScript { $_.GetValue("DisplayName") -like "Rubberduck*"}
#Get-ChildItem -Recurse -Path $Keys | Get-ItemProperty 
#Get-ChildItem -Path Classes: -Recurse | Get-ItemProperty
#Get-ChildItem -Path $HKCUKeys | Get-ItemProperty 
#Get-ChildItem -Path Classes -Recurse | Where-Object -FilterScript { $_.PSPath -like "Rubberduck*"}