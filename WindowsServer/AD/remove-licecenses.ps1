# Import the Active Directory module
Import-Module ActiveDirectory

# Define the group to remove
$group = "GG_Liz_ProjectOnlinePro" 

# Define the path to the text file containing the email addresses
$emailFile = "C:\temp\project_remove.txt" 

# Get the email addresses from the text file
$emails = Get-Content $emailFile

# Loop through each email address and remove the group from the corresponding user
foreach ($email in $emails) {
    $user = Get-ADUser -Filter "EmailAddress -eq '$email'" -Properties EmailAddress

    if ($user) {
        try {
            Remove-ADGroupMember -Identity $group -Members $user.SamAccountName -Confirm:$false
            Write-Host "Successfully removed $($user.SamAccountName) from $group." 
        } catch {
            Write-Host "Failed to remove $($user.SamAccountName) from $group. Error: $_" 
        }
    } else {
        Write-Host "No user found with email: $email" 
    }
}