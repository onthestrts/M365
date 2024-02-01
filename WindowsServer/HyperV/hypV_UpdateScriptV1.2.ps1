#---------------------------------------------------------------
# Script: HypV_Update.ps1
# Author: FKA, Baggenstos AG
# Date: May 15, 2023
# Description: Allows to Update the Surber Hyper-V standalone Server.
# Version: 1.2
# 
#---------------------------------------------------------------


# Define Variables
$vms = get-vm
$date = get-date
$module = 'PSWindowsUpdate'
$pkg = Get-Package -name $module

# Creating Function
function WriteLog {
    
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,        
        [string]$global:LogFilePath = "C:\temp\$(Get-Date -Format 'yyyyMMdd')_WindowsUpdateLog_$(hostname).txt"
    )
    
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    
    try {
        Add-Content -Path $LogFilePath -Value $logEntry -ErrorAction Stop
    }
    catch {
        Write-Host "Error writing to log file: $_" -ForegroundColor Red
    }
}


# Script Start
WriteLog -Message "[Info] Starting Windows update Script for Surber Hyper-V Server"

WriteLog -Message "[Info] Gather status of Hyper-V VMs"

foreach ($computer in $vms){
    
    if ($computer.state -eq "running"){
        WriteLog -Message "[Info] $computer is running"
        write-host $computer.Name 'is running' -ForegroundColor red

        WriteLog -Message "[Info] Start Stopping $computer"
        stop-vm -Name $computer.Name | Out-Null 
        
        WriteLog -Message "[Info] Check if stopping process was successfull"
        if ($computer.state -eq "running"){
            WriteLog -Message "[Info] Stopping was successfull"
        }
        else{
            WriteLog -Message "[Error] Stopping was unsuccessfull, skipping host!"
            WriteLog -Message "[Info] Note: Try to stop ma $computer manually"
        }       

    }
    else {
        write-host $computer.Name 'is stopped' -ForegroundColor green
        Writelog -Message "[Info] $computer is stopped"
    }

}

# Check if Windows Update PS Module exists
WriteLog -Message "[Info] Check if the PS-Module $module exists"

if (Get-Module -Name $module -ListAvailable) {
    Write-Host "$module is already installed."
	WriteLog -Message "[Info] $module is already installed."
	
	WriteLog -Message "[Info] Importing $module for Windows Updates"
	Import-Module -Name $module
	WriteLog -Message "[Info] Finished importing $module"
}
else {
    $retryCount = 3
    $moduleInstalled = $false
	
	WriteLog -Message "[Info] $module is not installed/not found"
    write-host $module 'not found' -ForegroundColor Red
	
    for ($attempt = 1; $attempt -le $retryCount; $attempt++) {
        try {
           
			WriteLog -Message "[Info] Start installing $module"
            Install-Module -Name $module -Force -ErrorAction Stop
            WriteLog -Message "[Info] $module successfully installed!"
            
            $moduleInstalled = $true
            break
        }
        catch {            
            Write-Host "Failed to install $module on attempt $attempt : $_"
			WriteLog -Message "[Error] Failed to install $module on attempt $attempt : $_"
        }
    }

    if (-not $moduleInstalled) {
        # If installation fails after all attempts, display an error message and continue with the script
        Write-Host "$module installation failed after $retryCount attempts."
		WriteLog -Message "[Error] $module installation failed after $retryCount attempts."
		WriteLog -Message "[Error] $module was not installed Successfully, Windows updates can not be made - exiting Script!"
		WriteLog -Message "[Info] Note: Try to install $module manually with 'Install-Module -Name PSWindowsUpdate -Force'"
		WriteLog -Message "[Info] Terminating Script"
		exit
    }
}

# Updating Host

WriteLog -Message "[Info] Start updating $host"

$wu = Get-WindowsUpdate
$wuoutput = $wu | Out-String
add-content -path $global:logfilepath -value $wuoutput

if(-not $wu){

    Write-Host "No Updates avaiable!"
    Write-Host "Exit script!"

    WriteLog -Message "[Info] No Updates avaiable!"
    WriteLog -Message "[Info] Exit script!"

}
else{
    WriteLog -Message "[Info] System will reboot automatically after installing Updates!"
    $output = Install-WindowsUpdate -AcceptAll -AutoReboot
    $outputstring = $output | Out-String
    add-content -path $global:logfilepath -value $outputstring 
    
    WriteLog -Message "[Info] Finished installing updates!"
	Write-Host "Finished installing updates!"  
    
    WriteLog -Message "[Info] System will now reboot!"
	Write-Host "System will now reboot!"
    
    WriteLog -Message "[Info] Script successfully finished!"
}