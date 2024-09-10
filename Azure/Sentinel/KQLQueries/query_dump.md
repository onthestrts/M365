# Show if the Sign-Ins were Interactive:

	´´´bash
	SigninLogs
	| where TimeGenerated > ago(14d)
	| where UserId contains "57aab58f-d0bf-4604-86b4-24bcccdb3867" 
	| where IsInteractive == "true" 
	| project TimeGenerated, UserPrincipalName, IPAddress, Location, AuthenticationDetails, DeviceDetail
 
# Show if the Authentification were made from IOS Devices:
	
	´´´bash
	SigninLogs
	| where TimeGenerated > ago(14d)
	| where UserPrincipalName contains "c.foehr@filtrox.ch"
	| extend DeviceDetail = parse_json(DeviceDetail)
	| where DeviceDetail.operatingSystem contains "Ios" or DeviceDetail.operatingSystem contains "ios" or DeviceDetail.operatingSystem contains "IOS"
	| project TimeGenerated, UserPrincipalName, IPAddress, Location, AuthenticationDetails, DeviceDetail, OperatingSystem = tostring(DeviceDetail.operatingSystem)
