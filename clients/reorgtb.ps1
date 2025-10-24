$Cred = Get-Credential
$Url = "https://<db2-ip>:<db2-port>/services/IDUGSVC/REORGTB"
$Body = @{
    'I_SCHEMA' = 'IDUG'
    'I_TBNAME' = 'PROCPROT'
    'RETCODE' = ''
    'LFDNR' = ''
}
$Headers = @{
    'Content-Type' = 'application/json'
    Accept = 'application/json'
}
Invoke-RestMethod -Method 'Post' -Uri $url -Body ($body | ConvertTo-Json) -Headers $Headers -Credential $Cred



