#---------------------------------------------------------------
# Script: Security | IP-Check Tool
# Author: FKA, Baggenstos AG
# Date: Dec 02, 2024
# Description: Pull IPs from Redmine ticket system or a Txt input file and get results in txt output file, formatted in textile markup for easy Ticket insert.
# Version: 2.2
# Recent Changes:
# - Dec 02, 2024: Ensured each row appears on its own line in the output file (Textile format).
# - Dec 02, 2024: Removed comments for a cleaner script layout.
# - Dec 02, 2024: Integrated Redmine ticket system to fetch IPs directly from a ticket description.
# - Dec 02, 2024: Added fallback to use an IP input file if no ticket is provided or if fetching fails.
# - Dec 02, 2024: Updated regex to support both IPv4 and IPv6 addresses.
# - Dec 03, 2024: Added functionality to Posts the processed results back to the ticket as a comment.
# - Dec 03, 2024: Added functionality to manually set Spent Time with a default of 0.25 if not specified.
#---------------------------------------------------------------

# Define Redmine API variables
$RedmineUrl = "https://tickets.baggenstos.ch/"  # Replace with your actual Redmine URL
$ApiKey = "your-ts-api-key"  # Replace with your actual API key

# Prompt for Ticket ID
$IssueId = Read-Host -Prompt "Enter the Ticket-ID (Exp. '123456' - no Hashtag!) or press Enter to skip"

# Prompt for Spent Time with default value of 0.25
$TimeSpent = Read-Host -Prompt "Enter the time spent (default is 0.25)" 
if (-not $TimeSpent) {
    $TimeSpent = 0.25
}

$IpAddresses = @()

if (-not [string]::IsNullOrEmpty($IssueId)) {
    $ApiEndpoint = "$RedmineUrl/issues/$IssueId.json"
    $Headers = @{ "X-Redmine-API-Key" = $ApiKey }

    try {
        $Response = Invoke-RestMethod -Uri $ApiEndpoint -Method Get -Headers $Headers
        $Description = $Response.issue.description

        # Extract IPv4 and IPv6 addresses
        $IpAddresses = [regex]::Matches($Description, '((([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4})|(([0-9a-fA-F]{1,4}:){1,7}:)|(([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})|(([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2})|(([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3})|(([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4})|(([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5})|(([0-9a-fA-F]{1,4}:){1,1}(:[0-9a-fA-F]{1,4}){1,6})|(:((:[0-9a-fA-F]{1,4}){1,7}|:))|(((2(5[0-5]|[0-4][0-9])|1[0-9]{2}|[1-9]?[0-9])\.){3,3}(2(5[0-5]|[0-4][0-9])|1[0-9]{2}|[1-9]?[0-9])))(%[0-9a-zA-Z]{1,})?') | ForEach-Object { $_.Value }
        if ($IpAddresses.Count -eq 0) {
            Write-Host "No IP addresses found in the ticket description. Falling back to IP input file..." -ForegroundColor Yellow
        } else {
            Write-Host "Extracted $($IpAddresses.Count) IP addresses from the ticket." -ForegroundColor Green
        }
    } catch {
        Write-Error "Failed to fetch or parse ticket information. Falling back to IP input file. $_"
    }
}

if ($IpAddresses.Count -eq 0) {
    $InputFile = "ips.txt"

    if (!(Test-Path $InputFile)) {
        Write-Error "No IPs found in ticket and input file '$InputFile' not found. Exiting..."
        exit
    }

    $IpAddresses = Get-Content -Path $InputFile

    if ($IpAddresses.Count -eq 0) {
        Write-Error "No IP addresses found in the input file. Exiting..."
        exit
    }

    Write-Host "Loaded $($IpAddresses.Count) IP addresses from the input file." -ForegroundColor Green
}

$OutputFile = "ip_results.txt"
$Results = @()

foreach ($Ip in $IpAddresses) {
    try {
        $Response = Invoke-RestMethod -Uri "http://ip-api.com/json/$Ip" -Method Get

        if ($Response.status -eq "success") {
            $Result = @{
                IP = $Ip
                Country = $Response.country
                Region = $Response.regionName
                City = $Response.city
                Latitude = $Response.lat
                Longitude = $Response.lon
                ISP = $Response.isp
            }
            Write-Host "Processed IP: $Ip - Country: $($Response.country)" -ForegroundColor Cyan
        } else {
            $Result = @{
                IP = $Ip
                Country = "Error"
                Region = "Error"
                City = "Error"
                Latitude = "Error"
                Longitude = "Error"
                ISP = "Error"
            }
            Write-Host "Failed to process IP: $Ip" -ForegroundColor Yellow
        }

        $Results += $Result
    } catch {
        Write-Host "Failed to process IP: $Ip" -ForegroundColor Red
        $Results += @{
            IP = $Ip
            Country = "Error"
            Region = "Error"
            City = "Error"
            Latitude = "Error"
            Longitude = "Error"
            ISP = "Error"
        }
    }
}


Write-Host "Review the IPs above." -ForegroundColor Yellow
$IPSecCheck = Read-Host -Prompt "Enter your comment about the IPs (e.g., 'Looks good' or 'Suspicious activity detected')"

$TextileHeader = "* IP-Check: $IPSecCheck 
|_.IP|_.Country|_.Region|_.City|_.Latitude|_.Longitude|_.ISP|"
Set-Content -Path $OutputFile -Value $TextileHeader -Encoding UTF8

foreach ($Result in $Results) {
    $TextileRow = "| $($Result.IP) | $($Result.Country) | $($Result.Region) | $($Result.City) | $($Result.Latitude) | $($Result.Longitude) | $($Result.ISP) |"
    Add-Content -Path $OutputFile -Value $TextileRow -Encoding UTF8
}

Write-Host "Results saved to '$OutputFile'. Script completed!" -ForegroundColor Green

if (-not [string]::IsNullOrEmpty($IssueId)) {
    $TextileContent = Get-Content -Path $OutputFile -Raw

    $Body = @{
        issue = @{
            notes = $TextileContent
        }
        time_entry = @{
            hours = $TimeSpent
        }
    } | ConvertTo-Json -Depth 10

    try {
        $Response = Invoke-RestMethod -Uri "$RedmineUrl/issues/$IssueId.json" -Method Put -ContentType "application/json" `
            -Headers @{ "X-Redmine-API-Key" = $ApiKey } `
            -Body $Body -Verbose

        Write-Host "Results added successfully to Ticket ID: $IssueId with $TimeSpent hours spent." -ForegroundColor Green
    } catch {
        Write-Error "Failed to add results to Ticket ID: $IssueId. $_"
    }
}