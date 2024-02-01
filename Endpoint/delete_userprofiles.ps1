# Define the user profiles to exclude from deletion
$excludedUsers = @("EXCLUDE_USER")

$allUserProfiles = Get-WmiObject Win32_UserProfile

foreach ($profile in $allUserProfiles) {
    $username = $profile.LocalPath.Split('\')[-1]

    if ($excludedUsers -notcontains $username) {
        try {
            $profile.Delete()
            Write-Host "Deleted profile for user: $username"
        } catch {
            Write-Host "Error deleting profile for user: $username"
            Write-Host $_.Exception.Message
        }
    }
}

foreach ($user in $excludedUsers) {
    $userFolder = Join-Path -Path "C:\Users" -ChildPath $user

    if (Test-Path -Path $userFolder -PathType Container) {
        try {
            Remove-Item -Path $userFolder -Recurse -Force
            Write-Host "Deleted user folder and settings for: $user"
        } catch {
            Write-Host "Error deleting user folder and settings for: $user"
            Write-Host $_.Exception.Message
        }
    } else {
        Write-Host "User folder not found for: $user"
    }
}