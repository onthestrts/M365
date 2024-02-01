
$PublicFolder = "MailPublicFolder" # replace with desired public folder name
$Folders = Get-MailPublicFolder
foreach ($Folder in $Folders) {
    #Write-Host $Folder.Name
    #Get-PublicFolder -identity "\$Folders" -recurse | Format-List Identity,Name
    Get-PublicFolder -Identity "\$Folder" -Recurse | Where-Object {$_.Name -eq "Data Quality"}
    }











    