# Show if the Sign-Ins were Interactive:
	```Bash
	SigninLogs
	| where TimeGenerated > ago(14d)
	| where UserId contains "EmailAddress" 
	| where IsInteractive == "true" 
	| project TimeGenerated, UserPrincipalName, IPAddress, Location, AuthenticationDetails, DeviceDetail
 
# Show if the Authentification were made from IOS Devices:
	```Bash
	SigninLogs
	| where TimeGenerated > ago(14d)
	| where UserPrincipalName contains "EmailAddress"
	| extend DeviceDetail = parse_json(DeviceDetail)
	| where DeviceDetail.operatingSystem contains "Ios" or DeviceDetail.operatingSystem contains "ios" or DeviceDetail.operatingSystem contains "IOS"
	| project TimeGenerated, UserPrincipalName, IPAddress, Location, AuthenticationDetails, DeviceDetail, OperatingSystem = tostring(DeviceDetail.operatingSystem)

# Check if the Device is Compliant:
	```Bash
	SigninLogs
	| where TimeGenerated > ago(14d)
	| where UserId contains "5b0d45949-4b18-4f26-a688-ad9f0c514d49"
	| extend DeviceDetail = parse_json(DeviceDetail) 
	| where DeviceDetail.isManaged == "false" 
	| where DeviceDetail.isCompliant == "false"
	| project TimeGenerated, UserPrincipalName, IPAddress, Location, AuthenticationDetails, DeviceDetail

