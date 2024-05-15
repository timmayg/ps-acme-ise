#
#   This CmdLet will Retrieve all the Trusted Certificates from Cisco ISE
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
$fqdn = 'ise1.theglens.net'

$trusted_certs_uri = 'https://' + $fqdn + '/api/v1/certs/trusted-certificate'
$trusted_certs_response = Invoke-RestMethod -Uri $trusted_certs_uri -Method Get -Headers $headers

$trusted_certs_response.response | Format-List friendlyName, subject, issuedTo, expirationDate
Write-Host -ForegroundColor DarkMagenta  'There is a lot more details but a summary is above.'
Write-Host -ForegroundColor DarkMagenta 'To see more info check out this variable $trusted_certs_response.response'
