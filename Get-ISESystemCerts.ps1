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
$date = Get-Date
$fqdn = 'ise1.theglens.net'


#
# Each ISE Node will have different Certificates so 
#    first we will retrieve all the ISE Nodes
# https://ise1.theglens.net/api/swagger-ui/index.html?urls.primaryName=Deployment#/
#
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
Write-Host -ForegroundColor DarkMagenta  'The variable $allCertificates will contain an object for each node.' 
Write-Host -ForegroundColor DarkMagenta  'That object will contain all the certificates.'
Write-Host -ForegroundColor DarkMagenta  'There is a lot more details but a summary is above.'
Write-Host -ForegroundColor DarkMagenta 'To see more info check out this variable $all_certificates.response'


