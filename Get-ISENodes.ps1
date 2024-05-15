#
#
#

#
# Retrieve the Basic AuthZ String
#
Write-Host -ForegroundColor Red 'Decrypting AuthZ Creds'
Write-Host -ForegroundColor Red 'Building Headers'
$retrievedSecurePassword = Get-Content /users/tiglen/usr-iseapi_admin.sec | ConvertTo-SecureString
$plainTextPassword = [System.Net.NetworkCredential]::new("", $retrievedSecurePassword).Password
$headers = @{
    'Authorization' = $plainTextPassword
    'Content-Type' = 'application/json'
    'Accept' = 'application/json'    
}

#
# https://ise1.theglens.net/api/swagger-ui/index.html?urls.primaryName=Deployment#/
#

$fqdn = 'ise1.theglens.net'
$uri = 'https://' + $fqdn + '/api/v1/deployment/node'

$nodes_response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
$nodes_response

