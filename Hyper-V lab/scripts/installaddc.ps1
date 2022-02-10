Add-WindowsFeature -Name AD-Domain-Services  
Install-ADDSDomainController -DomainName "lab.test.com" -InstallDns:$true -Credential (Get-Credential) -Confirm:$false  
New-ADUser -Name phinchley -SamAccountName phinchley -DisplayName "Peter Hinchley" -GivenName Peter -Surname Hinchley -UserPrincipalName user@test.com -Path "ou=User Accounts,dc=lab,dc=test,dc=com" -AccountPassword (Read-Host "Password" -AsSecureString) -ChangePasswordAtLogon $false -Enabled $true  
new-aduser -name test.user -accountpassword test
Add-Computer -DomainName "lab.test.com" -OUPath "ou=Servers,dc=lab,dc=test,dc=com" -Credential (Get-Credential lab\administrator) -Restart -Force  
enable-adaccount -identity test.user
new-adgroup -name "testgroup" -samaccountname testgroup -groupcategory Security -groupscope global -path "cn=users,dc=local"
