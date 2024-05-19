#
#
#

#
# Retrieve the Basic AuthZ String
#
Write-Host -ForegroundColor Red 'Decrypting AuthZ Creds'
Write-Host -ForegroundColor Red 'Building Headers'
$retrievedSecurePassword = Get-Content /users/tiglen/secs/usr-iseapi_admin.sec | ConvertTo-SecureString
$plainTextPassword = [System.Net.NetworkCredential]::new("", $retrievedSecurePassword).Password
$headers = @{
    'Authorization' = $plainTextPassword
    'Content-Type' = 'application/json'
    'Accept' = 'application/json'    
}

$fqdn = 'ise1.theglens.net'
$uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/ise1'
$certs_response = Invoke-WebRequest -Uri $uri -Method Get -Headers $headers
#$certs_response
#$certs_hash = $nodes_response.content | ConvertFrom-Json





$certs_rest = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
#$certs_rest




#
# API: ers/config/systemcertificate/versioninfo