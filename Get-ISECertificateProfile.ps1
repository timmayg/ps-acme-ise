#
#  !!! This still needs to be validated !!!
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

$fqdn = 'ise1.theglens.net:9060'
$uri = 'https://' + $fqdn + '/ers/config/certificateprofile'


$cert_profile_response = Invoke-WebRequest -Uri $uri -Method Get -Headers $headers

$cert_profile_rest = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers





#
# API: ers/config/systemcertificate/versioninfo