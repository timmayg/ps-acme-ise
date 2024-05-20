# ps-acme-ise
 PowerShell ACME and ISE

<div style="display: flex; justify-content: space-around;">
  <img src="images/ps.jpeg" alt="PowerShell logo" style="width: 150px; height: 150px;"/>
  <img src="images/acme.png" alt="ACME logo" style="width: 150px; height: 150px;"/>
  <img src="images/cisco-ise.jpeg" alt="Cisco ISE logo" style="width: 150px; height: 150px;"/>
</div>


This repo contains some PoV code that I've written to show how to do some basic certificate management with PowerShell Let's Encrypt and Cisco ISE. 

I've decided to use PowerShell for this since Posh-ACME is a very mature method for interacting with ACME based Certificate Authorities. 

Here is a short description of some of the files in this Repo...

00-Create-BasicAuthString.ps1 - This will create a Basic Authentication string.  Basic Auth strings are insecure and should not be stored in the clear

00-Create-SecureFile.ps1 - This is used to encrypt the Basic Authentication string in a separate file. According to my testing this file will only open on the computer that created it. You can see how I use this file in the header of all the PS scripts in this repo. 

01-Get-ISENodes.ps1 - Retrieve a list of ISE nodes, their roles and their services and print it to the screen. 

02a-Get-ISETrustedCerts.ps1 - Retrieve a list of the Trusted Certs (typically CA certs) and print them to the screen. 

02b-Get-ISESystemCerts.ps1 - Retrieve a list of the System Certs on all the ISE Nodes and print them to the screen. 

03-Validate-ISESystemCerts.ps1 - THIS FILE NEEDS WORK - This will compare the current date \ time vs the date on the certificate. 
NOTE: We will need to determine how to ID 'close to expiring certs' before Updating the Cert in the next step. 


