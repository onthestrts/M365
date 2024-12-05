#Define Parameters
$SiteURL = "https://<tenant>.sharepoint.com/sites/<StiteName>"
$FileRelativePath = "/sites/ProductManagemetn/Dokumente/"

#Connect to PnP Online
Connect-PnPOnline -interactive -Url $SiteURL 

#Get all versions
$FileVersions = Get-PnPFileVersion -Url $FileRelativePath

#If there are more than 5 versions
if ($FileVersions.Count -gt 5) {
    #Sort versions by version label and select all but the latest 5
    $VersionsToDelete = $FileVersions | Sort-Object VersionLabel -Descending | Select-Object -Skip 5

    #Loop through each version to delete
    foreach ($Version in $VersionsToDelete) {
        #Remove version
        Remove-PnPFileVersion -Url $FileRelativePath -Identity $Version.ID -Force
    }
}