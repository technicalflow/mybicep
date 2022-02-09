Add-WindowsFeature -Name AD-Domain-Services  
Install-ADDSDomainController -DomainName "lab.hinchley.net" -InstallDns:$true -Credential (Get-Credential) -Confirm:$false  
New-ADUser -Name phinchley -SamAccountName phinchley -DisplayName "Peter Hinchley" -GivenName Peter -Surname Hinchley -UserPrincipalName phinchley@lab.hinchley.net -Path "ou=User Accounts,dc=lab,dc=hinchley,dc=net" -AccountPassword (Read-Host "Password" -AsSecureString) -ChangePasswordAtLogon $false -Enabled $true  
new-aduser -name test.user -accountpassword test
Add-Computer -DomainName "lab.hinchley.net" -OUPath "ou=Servers,dc=lab,dc=hinchley,dc=net" -Credential (Get-Credential lab\administrator) -Restart -Force  
enable-adaccount -identity test.user
new-adgroup -name "testgroup" -samaccountname testgroup -groupcategory Security -groupscope global -path "cn=users,dc=local"
