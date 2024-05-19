# Define the secure string
clear
$user_input = Read-Host 'Enter a string to be encrypted...'
$secure_password = ConvertTo-SecureString -String $user_input -AsPlainText -Force
Start-Sleep -Seconds 1

# Save the secure string to a file
Write-Host ''
Write-Host ''
$file_name = Read-Host 'Enter a filename to store the encrypted string. Paths are NOT supported...'
$file_path = '/users/tiglen/secs/' + $file_name
$secure_password | ConvertFrom-SecureString | Out-File $file_path -Force



Write-Host -ForegroundColor Red 'Copy and Paste the Following Code into the Script for Decryption'
Write-Host '$retrievedSecurePassword = Get-Content' $file_path '| ConvertTo-SecureString'
Write-Host '$plainTextPassword = [System.Net.NetworkCredential]::new("", $retrievedSecurePassword).Password'
Write-Host 'Use the string $plainTextPassword in the script.'







# Output the plain text password
# Write-Host "Plain text password:" $plainTextPassword

















#
#  This works just fine. 
#
# Create a SecureString
# $securePassword = ConvertTo-SecureString -String "abcde" -AsPlainText -Force
# Convert the SecureString to plain text
# $plainTextPassword = [System.Net.NetworkCredential]::new("", $securePassword).Password
# Output the plain text password
# Write-Host "Plain text password:" $plainTextPassword


