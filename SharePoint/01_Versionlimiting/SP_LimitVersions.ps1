# Parameters
$siteUrl = "https://<tenant>.sharepoint.com/sites/<SharePointSite>" 
$libraryName = "Dokumente" 
$logPath = "C:\temp\SPOCleanup" 
$logFile = "$logPath\LogFile.txt" 

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
    $logMessage = "$timestamp - $message" 
    Write-Output $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Ensure the log directory exists
if (-not (Test-Path -Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory
    Log-Message "Created log directory at $logPath" 
}

# Connect to SharePoint site
Connect-PnPOnline -Url $siteUrl -UseWebLogin
Log-Message "Connected to SharePoint site $siteUrl" 

# Get all items in the document library
$items = Get-PnPListItem -List $libraryName -PageSize 2000
Log-Message "Retrieved $($items.Count) items from library $libraryName" 

foreach ($item in $items) {
    $file = Get-PnPFile -Url $item.FieldValues.FileRef -AsListItem
    $versions = Get-PnPFileVersion -Url $file["FileRef"]

    if ($versions.Count -gt 5) {
        $versionsToDelete = $versions | Select-Object -SkipLast 5
        foreach ($version in $versionsToDelete) {
            Remove-PnPFileVersion -Url $file["FileRef"] -Identity $version.ID -Force
            Log-Message "Deleted version $($version.ID) of file $($file['FileRef'])" 
        }
    }
}

Log-Message "Version cleanup completed." 