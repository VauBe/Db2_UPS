$Cred = Get-Credential
$Url = "https://<db2-ip>:<db2-port>/services/IDUGSVC/REORGTS"
$Body = @{
    'I_DBNAME' = 'DBIDUG'
    'I_TSNAME' = 'TSIDUG01'
    'RETCODE' = ''
    'LFDNR' = ''
}
$Headers = @{
    'Content-Type' = 'application/json'
    Accept = 'application/json'
}
Invoke-RestMethod -Method 'Post' -Uri $url -Body ($body | ConvertTo-Json) -Headers $Headers -Credential $Cred



