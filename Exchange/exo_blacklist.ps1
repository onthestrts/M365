$x = Get-HostedContentFilterPolicy default

$x | foreach {write-host ("`r`n"*3)$_.Name,`r`n,("="*79),`r`n,"Allowed Senders"`r`n,("-"*79),`r`n,$_.AllowedSenders,("`r`n"*2),"Allowed Sender Domains",`r`n,("-"*79),`r`n,$_.AllowedSenderDomains,("`r`n"*2),"Blocked Senders"`r`n,("-"*79),`r`n,$_.BlockedSenders,("`r`n"*2),"Blocked Sender Domains",`r`n,("-"*79),`r`n,$_.BlockedSenderDomains}