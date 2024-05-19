#
#   Lets create a Basic Authentication String and the associated Headers
#
#

$u = Read-Host 'Enter the Username'
$p = Read-Host 'Enter the Password'
$cred = "$($u):$($p)"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($cred))
$basicAuthString = 'Basic ' + $base64AuthInfo

Write-Output $basicAuthString
