#
#  !!! THIS IS STILL THROWING SOME ERRORS WHEN TRYING TO CONVERT
#         THE CERTS EXPIRATION DATE TO A PS OBJECT     !!!
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
$date = Get-Date
$fqdn = 'ise1.theglens.net'


#
# Each ISE Node will have different Certificates so 
#    first we will retrieve all the ISE Nodes
# https://ise1.theglens.net/api/swagger-ui/index.html?urls.primaryName=Deployment#/
#
$node_list_uri = 'https://' + $fqdn + '/api/v1/deployment/node'
$node_list_response = Invoke-RestMethod -Uri $node_list_uri -Method Get -Headers $headers


#
#  Here we will gather a list of all the System Certificates on all the ISE Nodes
#
$all_certificates = @()
foreach ($node in $node_list_response.response) {
    $sys_certs_uri = 'https://' + $fqdn + '/api/v1/certs/system-certificate/' + $node.hostname
    $sys_certs_response = Invoke-WebRequest -Uri $sys_certs_uri -Method Get -Headers $headers
    $sys_certs_response_content_json = $sys_certs_response.Content | ConvertFrom-Json
    $all_certificates += $sys_certs_response_content_json
}
$all_certificates.response.count
#$all_certificates.response | Format-List
#$all_certificates.response | Format-List friendlyName, subject, issuedTo, expirationDate


# Initialize an empty array to hold the new certificates
$new_all_certificates = @()

foreach ($cert in $all_certificates.response) {
    # Convert the validFrom and expirationDate to DateTime objects
    $validFrom = [datetime]::ParseExact($cert.validFrom, "ddd MMM dd HH:mm:ss 'EDT' yyyy", $null)
    $expiryDate = [datetime]::ParseExact($cert.expirationDate, "ddd MMM dd HH:mm:ss 'EDT' yyyy", $null)

    # Create a new PS object with the same properties, replacing validFrom and expirationDate with DateTime objects
    $new_cert = [PSCustomObject]@{
        id                        = $cert.id
        friendlyName              = $cert.friendlyName
        serialNumberDecimalFormat = $cert.serialNumberDecimalFormat
        issuedTo                  = $cert.issuedTo
        issuedBy                  = $cert.issuedBy
        validFrom                 = $validFrom
        expirationDate            = $expiryDate
        usedBy                    = $cert.usedBy
        keySize                   = $cert.keySize
        groupTag                  = $cert.groupTag
        selfSigned                = $cert.selfSigned
        signatureAlgorithm        = $cert.signatureAlgorithm
        portalsUsingTheTag        = $cert.portalsUsingTheTag
        sha256Fingerprint         = $cert.sha256Fingerprint
        link                      = $cert.link
    }

    # Add the new object to the array
    $new_all_certificates += $new_cert
}

# Output the new array to verify the changes
$new_all_certificates






$dateString = $all_certificates.response.expirationDate[0]


###########################################################################
###########################################################################
###########################################################################



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






###########################################################################
###########################################################################
###########################################################################




