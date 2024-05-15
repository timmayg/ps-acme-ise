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
$fqdn = 'ise1.theglens.net'



$node_list_uri = 'https://' + $fqdn + '/api/v1/deployment/node'
$node_list_response = Invoke-RestMethod -Uri $node_list_uri -Method Get -Headers $headers

$all_certificates = @()
foreach ($node in $node_list_response.response) {
    $sys_certs_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/' + $node.hostname + '?sort=asc&sortBy=friendlyName'
    $sys_certs_response = Invoke-WebRequest -Uri $sys_certs_uri -Method Get -Headers $headers
    $sys_certs_response_content_json = $sys_certs_response.Content | ConvertFrom-Json
    $all_certificates += $sys_certs_response_content_json
}
clear
Write-Host -ForegroundColor DarkMagenta 'This is the beginning of the Certificates found on this ISE cube'
$all_certificates.response | Format-List friendlyName, subject, issuedTo, expirationDate, usedBy


$count_system_certs = $all_certificates.response.Count
Write-Host -ForegroundColor DarkMagenta 'The System Certificate List Starts Here.'
$all_certificates.response | Format-List friendlyName, subject, issuedTo, usedBy, expirationDate
Write-Host -ForegroundColor DarkMagenta 'There are' $count_system_certs 'System Certificates.'

# Prompt the user to paste the friendly name
$user_select_update_cert = Read-Host "Paste the friendlyName of the certificate that you want updated."

# Find the certificate based on the pasted friendly name
$system_cert_to_update = $all_certificates.response | Where-Object { $_.friendlyName -eq $user_select_update_cert }

Exit



$put_cert_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/' + $hostname + '/' + $post_cert_response.response.id
$put_cert_response = Invoke-RestMethod -Uri $post_cert_uri -Method Put -Headers $headers -Body $jsonString

$put_cert_response.response | Format-List





<#
{
  "admin": false,
  "allowPortalTagTransferForSameSubject": true,
  "allowReplacementOfPortalGroupTag": true,
  "allowRoleTransferForSameSubject": true,
  "description": "Description of certificate",
  "eap": false,
  "expirationTTLPeriod": 36,
  "expirationTTLUnits": "days",
  "ims": false,
  "name": "System Certificate",
  "portal": false,
  "portalGroupTag": "Default Portal Certificate Group",
  "pxgrid": false,
  "radius": false,
  "renewSelfSignedCertificate": false,
  "saml": false
}

#>