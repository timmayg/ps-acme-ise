#
#   This CmdLet will 
#      get and display all the Trusted Certificates from the ISE PAN
#      ask the user which Trusted Certificate to delete
#      delete the Trusted Certificate th user selected
#


#
# Retrieve the Basic AuthZ String
#
Write-Host -ForegroundColor Red 'Decrypting AuthZ Creds'
Write-Host -ForegroundColor Red 'Building Headers'
clear
$retrievedSecurePassword = Get-Content /users/tiglen/usr-iseapi_admin.sec | ConvertTo-SecureString
$plainTextPassword = [System.Net.NetworkCredential]::new("", $retrievedSecurePassword).Password
$headers = @{
    'Authorization' = $plainTextPassword
    'Content-Type' = 'application/json'
    'Accept' = 'application/json'    
}
$fqdn = 'ise1.theglens.net'

$trusted_certs_uri = 'https://' + $fqdn + '/api/v1/certs/trusted-certificate?size=100&sort=asc'
$trusted_certs_response = Invoke-RestMethod -Uri $trusted_certs_uri -Method Get -Headers $headers



$count_trusted_cert = $trusted_certs_response.response.Count
Write-Host -ForegroundColor DarkMagenta 'The Trusted Certificate List Starts Here.'
$trusted_certs_response.response | Format-List friendlyName, subject, issuedTo, expirationDate
Write-Host -ForegroundColor DarkMagenta 'There are' $count_trusted_cert 'Trusted Certificates.'



# Prompt the user to paste the friendly name
$user_select_delete_cert = Read-Host "Paste the friendlyName of the certificate that you want deleted."
# Find the certificate based on the pasted friendly name
$trusted_cert_to_delete = $trusted_certs_response.response | Where-Object { $_.friendlyName -eq $user_select_delete_cert }


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
if ($trusted_cert_to_delete) { 
    #clear
    Write-Host -ForegroundColor DarkMagenta "Friendly Name: $($trusted_cert_to_delete.id)"
    Write-Host -ForegroundColor DarkMagenta "Friendly Name: $($trusted_cert_to_delete.friendlyName)"
    Write-Host  -ForegroundColor DarkMagenta "Subject: $($trusted_cert_to_delete.subject)"
    Write-Host  -ForegroundColor DarkMagenta "Issued To: $($trusted_cert_to_delete.issuedTo)"
    Write-Host  -ForegroundColor DarkMagenta "Issued To: $($trusted_cert_to_delete.issuedBy)"
    Write-Host  -ForegroundColor DarkMagenta "Expiration Date: $($trusted_cert_to_delete.validFrom)"
    Write-Host  -ForegroundColor DarkMagenta "Expiration Date: $($trusted_cert_to_delete.expirationDate)"
    Write-Host  -ForegroundColor DarkMagenta "Expiration Date: $($trusted_cert_to_delete.serialNumberDecimalFormat)"
    Write-Host  -ForegroundColor DarkMagenta "Expiration Date: $($trusted_cert_to_delete.sha256Fingerprint)"

    $delete_trusted_certs_uri = 'https://' + $fqdn + '/api/v1/certs/trusted-certificate/' + $trusted_cert_to_delete.id
    $delete_trusted_certs_response = Invoke-RestMethod -Uri $delete_trusted_certs_uri -Method Delete -Headers $headers
    
    Write-Host ""
    Write-Host  -ForegroundColor Green 'The' $delete_trusted_certs_response.response.message 
    Write-Host ""
    
} else {
    Write-Host  -ForegroundColor Red "Certificate not found with the provided friendly name."
}


