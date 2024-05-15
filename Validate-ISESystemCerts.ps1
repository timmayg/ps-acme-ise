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
    $sys_certs_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/' + $node.hostname
    $sys_certs_response = Invoke-WebRequest -Uri $sys_certs_uri -Method Get -Headers $headers
    $sys_certs_response_content_json = $sys_certs_response.Content | ConvertFrom-Json
    $all_certificates += $sys_certs_response_content_json
}
$all_certificates.response | Format-List friendlyName, subject, issuedTo, expirationDate


foreach ($cert in $all_certificates.response) {
    $dateString = $cert.expirationDate
    $dateObject = [DateTime]::ParseExact($dateString, "ddd MMM dd HH:mm:ss EDT yyyy", [CultureInfo]::InvariantCulture)

    if ($dateObject -lt (Get-Date)) {
        Write-Host "Certificate ID: $($cert.id) is expired."
        Write-Host "Friendly Name: $($cert.friendlyName)"
        Write-Host "Expiration Date: $($cert.expirationDate)"
        Write-Host ""
    }
}












$dateString = $all_certificates.response.expirationDate[0]

# Define an array of potential timezone formats
$timezones = @("zzz", "zz", "K", "GMT", "UTC", "Z")

# Iterate through the timezones and try parsing the date string
foreach ($timezone in $timezones) {
    $format = "ddd MMM dd HH:mm:ss $timezone yyyy"
    if ([DateTime]::TryParseExact($dateString, $format, [CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$dateObject)) {
        break
    }
}

if ($dateObject -ne $null) {
    Write-Host "Parsed date: $dateObject"
} else {
    Write-Host "Failed to parse date."
}

###########################################################################
###########################################################################
###########################################################################


# This works for $dateStrings that are EDT but not any other timezone. 
# In $dateObject we are hardcoding the timezone. 
$dateString = $all_certificates.response.expirationDate[0]
$dateObject = [DateTime]::ParseExact($dateString, "ddd MMM dd HH:mm:ss EDT yyyy", [CultureInfo]::InvariantCulture)



###########################################################################
###########################################################################
###########################################################################



clear
$all_certificates.response | ForEach-Object {
    $cert = $_
    $dateString = $cert.expirationDate
    $formats = @("ddd MMM dd HH:mm:ss EDT yyyy", "ddd MMM dd HH:mm:ss zzz yyyy", "ddd MMM dd HH:mm:ss yyyy")

    $expirationDate = $null
    foreach ($format in $formats) {
        if ([DateTime]::TryParseExact($dateString, $format, [CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$expirationDate)) {
            break
        }
    }

    if ($expirationDate -ne $null) {
        if ($expirationDate -lt (Get-Date)) {
            Write-Host "Certificate ID: $($cert.id) is expired."
            Write-Host "Friendly Name: $($cert.friendlyName)"
            Write-Host "Expiration Date: $($cert.expirationDate)"
            Write-Host ""
        }
    } else {
        Write-Host "Error parsing date for Certificate ID: $($cert.id)"
    }
}



###########################################################################
###########################################################################
###########################################################################


# This kinda worked... 
clear
foreach ($cert in $all_certificates.response) {
    $dateString = $cert.expirationDate
    $format = "ddd MMM dd HH:mm:ss EDT yyyy"
    
    try {
        $expirationDate = [DateTime]::ParseExact($dateString, $format, [CultureInfo]::InvariantCulture)
        
        if ($expirationDate -lt (Get-Date)) {
            Write-Host "Certificate ID: $($cert.id) is expired."
            Write-Host "Friendly Name: $($cert.friendlyName)"
            Write-Host "Expiration Date: $($cert.expirationDate)"
            Write-Host ""
        }
    } catch {
        Write-Host "Error parsing date for Certificate ID: $($cert.id)"
    }
}


###########################################################################
###########################################################################
###########################################################################


clear 
foreach ($cert in $all_certificates.response) {
    $dateString = $cert.expirationDate
    $format = "ddd MMM dd HH:mm:ss EDT yyyy"
    $null = $null
    $parsed = [DateTime]::TryParseExact($dateString, $format, [CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$null)

    if ($parsed) {
        $expirationDate = $null
        [DateTime]::TryParseExact($dateString, $format, [CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$expirationDate)
        if ($expirationDate -lt (Get-Date)) {
            Write-Host "Certificate ID: $($cert.id) is expired."
            Write-Host "Friendly Name: $($cert.friendlyName)"
            Write-Host "Expiration Date: $($cert.expirationDate)"
            Write-Host ""
        }
    } else {
        Write-Host "Error parsing date for Certificate ID: $($cert.id)"
    }
}


###########################################################################
###########################################################################
###########################################################################


clear
foreach ($cert in $all_certificates.response) {
    $dateString = $cert.expirationDate
    $expirationDate = [DateTime]::ParseExact($dateString, "ddd MMM dd HH:mm:ss EST yyyy", $null)
    if ($expirationDate -lt (Get-Date)) {
        Write-Host "Certificate ID: $($cert.id) is expired."
        Write-Host "Friendly Name: $($cert.friendlyName)"
        Write-Host "Expiration Date: $($cert.expirationDate)"
        Write-Host ""
    }
}





Write-Host -ForegroundColor DarkMagenta  'The variable $allCertificates will contain an object for each node.' 
Write-Host -ForegroundColor DarkMagenta  'That object will contain all the certificates.'
Write-Host -ForegroundColor DarkMagenta  'There is a lot more details but a summary is above.'
Write-Host -ForegroundColor DarkMagenta 'To see more info check out this variable $all_certificates.response'



###########################################################################
###########################################################################
###########################################################################






$string_dates = @(
    "Fri Jun 13 14:44:59 EDT 2025",
    "Tue Dec 10 21:03:12 EST 2024",
    "Thu Jun 15 15:58:38 EDT 2028",
    "Thu Jun 15 15:58:39 MST 2028",
    "Mon Jan 08 21:47:23 EST 2024",
    "Fri Jun 14 12:47:08 IST 2024",
    "Thu Jun 15 00:00:04 PST 2028",
    "Thu Jun 15 14:46:17 EDT 2028",
    "Tue Dec 10 21:05:14 EST 2024",
    "Wed Jun 14 23:54:15 PDT 2028",
    "Thu Jun 15 14:46:19 EDT 2028",
    "Thu Jun 13 20:11:23 CET 2024",
    "Wed Jun 14 21:52:20 EDT 2028",
    "Tue Jun 16 23:16:17 AEST 2026",
    "Tue Dec 10 21:16:37 EST 2024",
    "Tue Jun 13 15:59:23 GMT 2028",
    "Fri Jun 16 08:49:17 EDT 2028",
    "Fri Jun 16 08:49:18 NZST 2028"
)



###########################################################################
###########################################################################
###########################################################################





# Define the array of date strings
$string_dates1 = @(
    "Fri Jun 13 14:44:59 EDT 2025",
    "Tue Dec 10 21:03:12 EST 2024",
    "Thu Jun 15 15:58:38 EDT 2028",
    "Thu Jun 15 15:58:39 MST 2028",
    "Mon Jan 08 21:47:23 EST 2024",
    "Fri Jun 14 12:47:08 IST 2024",
    "Thu Jun 15 00:00:04 PST 2028",
    "Thu Jun 15 14:46:17 EDT 2028",
    "Tue Dec 10 21:05:14 EST 2024",
    "Wed Jun 14 23:54:15 PDT 2028",
    "Thu Jun 15 14:46:19 EDT 2028",
    "Thu Jun 13 20:11:23 CET 2024",
    "Wed Jun 14 21:52:20 EDT 2028",
    "Tue Jun 16 23:16:17 AEST 2026",
    "Tue Dec 10 21:16:37 EST 2024",
    "Tue Jun 13 15:59:23 GMT 2028",
    "Fri Jun 16 08:49:17 EDT 2028",
    "Fri Jun 16 08:49:18 NZST 2028"
)

# Initialize an empty array to store DateTime objects
$datetime_array = @()

# Iterate through each date string and convert it to DateTime object
foreach ($dateString in $string_dates1) {
    $dateTimeObject = [DateTime]::ParseExact($dateString, "ddd MMM dd HH:mm:ss zzz yyyy", [CultureInfo]::InvariantCulture)
    $datetime_array += $dateTimeObject
}

# Display the DateTime objects in the array
$datetime_array


