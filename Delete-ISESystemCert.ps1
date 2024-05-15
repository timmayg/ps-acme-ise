#
#   This CmdLet will 
#      get and display all the system Certificates from the ISE PAN
#      ask the user which system Certificate to delete
#      delete the system Certificate th user selected
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

#$system_certs_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate?size=100&sort=asc'
#$system_certs_response = Invoke-RestMethod -Uri $system_certs_uri -Method Get -Headers $headers

###########
###########

$node_list_uri = 'https://' + $fqdn + '/api/v1/deployment/node'
$node_list_response = Invoke-RestMethod -Uri $node_list_uri -Method Get -Headers $headers
$node_list_response.response

# Prompt the user to enter the hostname
$hostname = Read-Host -Prompt "Enter the hostname you want to query"
# Check if the entered hostname is valid and exists in the node list
$node = $node_list_response.response | Where-Object { $_.hostname -eq $hostname }


if ($node) {
    Write-Host "Hostname: $($node.hostname)"
    Write-Host "FQDN: $($node.fqdn)"
    Write-Host "IP Address: $($node.ipAddress)"
    Write-Host "Roles: $($node.roles -join ', ')"
    Write-Host "Services: $($node.services -join ', ')"
    Write-Host "Node Status: $($node.nodeStatus)"
} else {
    Write-Host "Hostname '$hostname' not found in the node list."
}




$sys_certs_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/' + $node.hostname + '?sort=asc&sortBy=friendlyName'
$sys_certs_response = Invoke-WebRequest -Uri $sys_certs_uri -Method Get -Headers $headers
$sys_certs_response_content_json = $sys_certs_response.Content | ConvertFrom-Json




$count_system_certs = $sys_certs_response_content_json.response.Count
Write-Host -ForegroundColor DarkMagenta 'The System Certificate List Starts Here.'
$sys_certs_response_content_json.response | Format-List friendlyName, subject, issuedTo, usedBy, expirationDate
Write-Host -ForegroundColor DarkMagenta 'There are' $count_system_certs 'System Certificates.'



# Prompt the user to paste the friendly name
$user_select_delete_cert = Read-Host "Paste the friendlyName of the certificate that you want deleted."



# Find the certificate based on the pasted friendly name
$system_cert_to_delete = $sys_certs_response_content_json.response | Where-Object { $_.friendlyName -eq $user_select_delete_cert }




Write-Host ""
Write-Host ""
Write-Host "Warning: Deleting a certificate is a permanent action."
$r_u_sure1 = Read-Host "Are you sure you want to continue? (Yes/No)"
if ($r_u_sure1 -eq 'Yes' -or $r_u_sure1 -eq 'yes') {
    Write-Host -ForegroundColor Yellow "Ok, moving on to next and final confirmation"
} elseif ($r_u_sure1 -eq 'N' -or $r_u_sure1 -eq 'n' -or $r_u_sure1 -eq 'no') {
    Write-Host "Operation aborted by user."
    return 
} else {
    Write-Host "Invalid choice. Please enter Yes or No."
    return 
}



clear
Write-Host ""
Write-Host ""
Write-Host "You've opted to continue."
$r_u_sure2 = Read-Host "Are you SURE? (Yes/No)"
if ($r_u_sure2 -eq 'Yes' -or $r_u_sure2 -eq 'yes') {
    Write-Host -ForegroundColor DarkBlue "You are about to delete"
} else {
    Write-Host "Final Confirmation hasn't been received. Exiting..."
    return 
}















# Display certificate information if found
if ($system_cert_to_delete) { 
    #clear
    Write-Host -ForegroundColor DarkMagenta "Friendly Name: $($system_cert_to_delete.id)"
    Write-Host -ForegroundColor DarkMagenta "Friendly Name: $($system_cert_to_delete.friendlyName)"
    Write-Host  -ForegroundColor DarkMagenta "Subject: $($system_cert_to_delete.subject)"
    Write-Host  -ForegroundColor DarkMagenta "Issued To: $($system_cert_to_delete.issuedTo)"
    Write-Host  -ForegroundColor DarkMagenta "Issued To: $($system_cert_to_delete.issuedBy)"
    Write-Host  -ForegroundColor DarkMagenta "Expiration Date: $($system_cert_to_delete.validFrom)"
    Write-Host  -ForegroundColor DarkMagenta "Expiration Date: $($system_cert_to_delete.expirationDate)"
    Write-Host  -ForegroundColor DarkMagenta "Expiration Date: $($system_cert_to_delete.serialNumberDecimalFormat)"
    Write-Host  -ForegroundColor DarkMagenta "Expiration Date: $($system_cert_to_delete.sha256Fingerprint)"


    $delete_data = @{
        'allowWildcardDelete' = $false  
    }
    $delete_data_json = $delete_data | ConvertTo-Json

    $delete_system_certs_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/' + $node.hostname + '/' + $system_cert_to_delete.id
    $delete_system_certs_response = Invoke-RestMethod -Uri $delete_system_certs_uri -Method Delete -Headers $headers -Body $delete_data_json
    
    Write-Host ""
    Write-Host  -ForegroundColor Green 'The' $delete_system_certs_response.response.message 
    Write-Host ""
    
} else {
    Write-Host  -ForegroundColor Red "Certificate not found with the provided friendly name."
}


