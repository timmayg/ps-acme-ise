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



# Each ISE Node will have different Certificates so 
#    first we will retrieve all the ISE Nodes
# https://ise1.theglens.net/api/swagger-ui/index.html?urls.primaryName=Deployment#/
# 
$node_list_uri = 'https://' + $fqdn + '/api/v1/deployment/node'
$node_list_response = Invoke-RestMethod -Uri $node_list_uri -Method Get -Headers $headers
$node_list_response.response


$fqdn = Read-Host "What is the FQDN of the ISE Node that will hold the Certificate?"




Set-PAServer GOOGLE_PROD
$cert = Get-PACertificate -List | Where-Object {$_.Subject -like '*ise1-cert-test*'}

$cert_cer = Get-Content $cert.CertFile -Raw
$cert_key = Get-Content $cert.KeyFile -Raw

# Create a PowerShell hashtable with the desired properties
$jsonObject = @{
    "allowExtendedValidity" = $false
    "allowOutOfDateCert" = $true
    "allowPortalTagTransferForSameSubject" = $true
    "allowReplacementOfPortalGroupTag" = $true
    "allowReplacementOfCertificates" = $true
    "allowRoleTransferForSameSubject" = $true
    "allowSHA1Certificates" = $false
    "data" = $cert_cer
    "name" = "PS Test Cert Import"
    "privateKeyData" = $cert_key
}
$jsonString = $jsonObject | ConvertTo-Json

$post_cert_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/import'
$post_cert_response = Invoke-RestMethod -Uri $post_cert_uri -Method Post -Headers $headers -Body $jsonString

$post_cert_response.response | Format-List

exit

#################################################################
#################################################################
#################################################################


$put_cert_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/' + $hostname + '/' + $post_cert_response.response.id
$put_cert_response = Invoke-RestMethod -Uri $post_cert_uri -Method Put -Headers $headers -Body $jsonString

$put_cert_response.response | Format-List

#################################################################
#################################################################
#################################################################



<#

$cert_cer = Get-Content $cert.CertFile -
$cert_key = Get-Content $cert.KeyFile

{
    "allowExtendedValidity": false,
    "allowOutOfDateCert": true,
    "allowPortalTagTransferForSameSubject": true,
    "allowReplacementOfPortalGroupTag": true,
    "allowReplacementOfCertificates": true,
    "allowRoleTransferForSameSubject": true,
    "allowSHA1Certificates": false,
    "data": $cert_cer,
    "name": "PS Test Cert Import",
    #"password": "cisco123",
    "privateKeyData": $cert_key,
}

#>


#################################################################
#################################################################
#################################################################

<#

#
#  Required Post Variables are below...
#

{
    "allowExtendedValidity": false,
    "allowOutOfDateCert": true,
    "allowPortalTagTransferForSameSubject": true,
    "allowReplacementOfPortalGroupTag": true,
    "allowRoleTransferForSameSubject": true,
    "allowSHA1Certificates": false,
    "data": $cert_cer,
    "name": "PS Test Cert Import",
    "password": "cisco123",
    "privateKeyData": $cert_key,
  }
  
#>

#################################################################
#################################################################
#################################################################

<#
#
#  All Possible Post Variables are below...
#

{
    "admin": false,
    "allowExtendedValidity": true,
    "allowOutOfDateCert": true,
    "allowPortalTagTransferForSameSubject": true,
    "allowReplacementOfCertificates": true,
    "allowReplacementOfPortalGroupTag": true,
    "allowRoleTransferForSameSubject": true,
    "allowSHA1Certificates": true,
    "allowWildCardCertificates": false,
    "data": "Plain-text contents of the certificate file.",
    "eap": false,
    "ims": false,
    "name": "System Certificate",
    "password": "Certificate Password",
    "portal": false,
    "portalGroupTag": "Default Portal Certificate Group",
    "privateKeyData": "Plain-text contents of the certificate private key file.",
    "pxgrid": false,
    "radius": false,
    "saml": false,
    "validateCertificateExtensions": false
  }
  
#>
