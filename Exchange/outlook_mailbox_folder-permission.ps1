ForEach($f in (Get-MailboxFolderStatistics jobs@enkom.com | Where { $_.FolderPath -like ("/Posteingang/Vakanzen*") -eq $True } ) ) {
    $fname = "jobs@enkom.com:" + $f.FolderPath.Replace("/","\"); Add-MailboxFolderPermission $fname -User tamara.vuellers@enkom.com -AccessRights Editor -SendNotificationToUser $true
    Write-Host $fname
    Start-Sleep -Milliseconds 1000
}