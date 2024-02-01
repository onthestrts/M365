$PublicFolder = "MailPublicFolder" # replace with desired public folder name
$Folders = (Get-MailPublicFolder).Folders
foreach ($Folder in $Folders) {
    Get-PublicFolder -identity $Folders -recursive | Format-List Identity,Name
