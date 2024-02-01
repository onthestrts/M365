# Uninstalls Software using Powershell
#
# Note: You can bulk-uninstall programs from the same vendor (hersteller) or with the same wording:
# Example:
#
# $Apps = Get-WmiObject -Class Win32_Product | Where-Object{$_.vendor -eq "Autodesk"}
# $Apps.Uninstall()
#
# Or:
# $Apps = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Microsoft 365*"}
# $Apps.Uninstall()

$Apps = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name/vendor -eq "n"}
$Apps.Uninstall()