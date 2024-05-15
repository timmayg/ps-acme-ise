#
#
#
#




#
# Retrieve the Basic AuthZ String
#
$retrievedSecurePassword = Get-Content /users/tiglen/usr-iseapi_admin.sec | ConvertTo-SecureString
$plainTextPassword = [System.Net.NetworkCredential]::new("", $retrievedSecurePassword).Password
#
#  Create Auth Token and Obtain Domain UUID
#
$headers = @{
    'Authorization' = $plainTextPassword
    'Content-Type' = 'application/json'
    'Accept' = 'application/json'    
}



$fqdn = 'ise1.theglens.net:9060'
$uri = 'https://' + $fqdn + '/ers/config/node/name/'


$auth_response = Invoke-WebRequest -Uri $uri -Method Post -Headers $headers


#
#
#
# API: ers/config/systemcertificate/versioninfo


