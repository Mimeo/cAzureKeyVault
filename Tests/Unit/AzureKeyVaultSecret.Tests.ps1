<#
    Pester unit tests for the cAzureKeyVault DSC module.
#>
using module "..\..\cAzureKeyVault.psm1"
$scriptPath = $MyInvocation.MyCommand.Path
$testResultsPath = Join-Path -Path (Split-Path $scriptPath) -ChildPath "TestResults"
if (Test-Path $testResultsPath) {
    Remove-Item $testResultsPath -Recurse -Force
}

New-Item -Type Directory $testResultsPath | Out-Null

Describe "AzureKeyVaultSecret" {
    Context "[AzureKeyVaultSecret]::Set()" {

        It "Should successfully retrieve a key vault secret value" {
            Mock LoginAzureRmAccount -Verifiable -ModuleName cAzureKeyVault -MockWith { return $null }
            Mock GetAzureKeyVaultSecret -Verifiable -ModuleName cAzureKeyVault -MockWith { 
                return @{
                    SecretValueText = "Set() successfully retrieve a key vault secret value"
                }
            }

            Mock Remove-Item -MockWith {return $null}
            $sut = [AzureKeyVaultSecret]::new()
            $sut.SecretName = "someSecret"
            $sut.VaultName = "someVault"
            $sut.Path = Join-Path -Path $testResultsPath -ChildPath "SetShouldSuccessfullyRetrieveAKeyVaultSecretValue"
            $sut.Ensure = "Present"
            $sut.Base64Decode = $false
            $sut.Credential = New-Object PSCredential("testAccount", ("testing" | ConvertTo-SecureString -AsPlainText -Force))
            $sut.TenantId = "some id"

            {$sut.Set()} | Should not throw
            Test-Path $sut.Path | Should Be $true
            $sut.Path | Should FileContentMatch "successfully retrieve a key vault secret value"
            Assert-VerifiableMocks
        }

        It "Should successfully retrieve and Base64 decode a Base64 encoded key vault secret" {
            Mock LoginAzureRmAccount -Verifiable -ModuleName cAzureKeyVault -MockWith { return $null }
            Mock GetAzureKeyVaultSecret -Verifiable -ModuleName cAzureKeyVault -MockWith { 
                $decodedText = "Set() successfully retrieve and base64 decode a base64 encoded key vault secret value"
                $encodedText = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($decodedText))
                return @{
                    SecretValueText = $encodedText
                }
            }

            Mock Remove-Item -MockWith {return $null}
            $sut = [AzureKeyVaultSecret]::new()
            $sut.SecretName = "someSecret"
            $sut.VaultName = "someVault"
            $sut.Path = Join-Path -Path $testResultsPath -ChildPath "SetShouldSuccessfullyRetrieveAndDecodeEncodedKeyVaultSecretValue"
            $sut.Ensure = "Present"
            $sut.Base64Decode = $true
            $sut.Credential = New-Object PSCredential("testAccount", ("testing" | ConvertTo-SecureString -AsPlainText -Force))
            $sut.TenantId = "some id"

            {$sut.Set()} | Should not throw
            Test-Path $sut.Path | Should Be $true
            $sut.Path | Should FileContentMatch "successfully retrieve and base64 decode a base64 encoded key vault secret value"
            Assert-VerifiableMocks
        }

        It "Should not persist file if exception is thrown" {
            Mock LoginAzureRmAccount -Verifiable -ModuleName cAzureKeyVault -MockWith { throw "Fake Exception" }
            Mock GetAzureKeyVaultSecret -ModuleName cAzureKeyVault -MockWith { 
                return @{
                    SecretValueText = "some text"
                }
            }

            Mock Remove-Item -MockWith {return $null}
            $sut = [AzureKeyVaultSecret]::new()
            $sut.SecretName = "someSecret"
            $sut.VaultName = "someVault"
            $sut.Path = Join-Path -Path $testResultsPath -ChildPath "SetShouldThrowAndNotPersistFile"
            $sut.Ensure = "Present"
            $sut.Base64Decode = $false
            $sut.Credential = New-Object PSCredential("testAccount", ("testing" | ConvertTo-SecureString -AsPlainText -Force))
            $sut.TenantId = "some id"

            {$sut.Set()} | Should throw
            Test-Path $sut.Path | Should Be $false
            Assert-VerifiableMocks
            Assert-MockCalled GetAzureKeyVaultSecret -ModuleName cAzureKeyVault -Exactly 0 -Scope It
        }

        It "Should delete file if Ensure is Absent" {
            Mock LoginAzureRmAccount -ModuleName cAzureKeyVault -MockWith { return $null }
            Mock GetAzureKeyVaultSecret -ModuleName cAzureKeyVault -MockWith { 
                return @{
                    SecretValueText = "some text"
                }
            }
            Mock Remove-Item { } -Verifiable

            $sut = [AzureKeyVaultSecret]::new()
            $sut.SecretName = "someSecret"
            $sut.VaultName = "someVault"
            $sut.Path = Join-Path -Path $testResultsPath -ChildPath "SetShouldDeleteThisFileIfEnsureIsAbsent"
            $sut.Ensure = "Absent"
            $sut.Base64Decode = $false
            $sut.Credential = New-Object PSCredential("testAccount", ("testing" | ConvertTo-SecureString -AsPlainText -Force))
            $sut.TenantId = "some id"

            Set-Content -Path $sut.Path -Value "delete me"            

            {$sut.Set()} | Should not throw
            Test-Path $sut.Path | Should Be $false
            Assert-MockCalled LoginAzureRmAccount -ModuleName cAzureKeyVault -Exactly 0 -Scope It
            Assert-MockCalled GetAzureKeyVaultSecret -ModuleName cAzureKeyVault -Exactly 0 -Scope It
            Assert-VerifiableMocks
        }
    }

    Context "[AzureKeyVaultSecret]::Test()" {

        It "Should return `$false if file not present and Ensure is Present" {
            $sut = [AzureKeyVaultSecret]::new()
            $sut.Path = "fileNotPresent"
            $sut.Ensure = "Present"

            $sut.Test() | Should be $false
        }

        It "Should return `$true if file not present and Ensure is Absent" {
            $sut = [AzureKeyVaultSecret]::new()
            $sut.Path = "fileNotPresent"
            $sut.Ensure = "Absent"

            $sut.Test() | Should be $true
        }

        It "Should return `$true if file is present and Ensure is Present" {
            $sut = [AzureKeyVaultSecret]::new()
            $sut.Path = $scriptPath
            $sut.Ensure = "Present"

            $sut.Test() | Should be $true
        }

        It "Should return `$false if file is present and Ensure is Absent" {
            $sut = [AzureKeyVaultSecret]::new()
            $sut.Path = $scriptPath
            $sut.Ensure = "Absent"

            $sut.Test() | Should be $false
        }
    }
}
Describe "AzureKeyVaultSecret.Helpers" {
        
    Context "[AzureKeyVaultSecret]::TestFilePath()" {
        It "Should return $true if the file is present" {
            $sut = [AzureKeyVaultSecret]::new()
            $sut.TestFilePath($scriptPath) | Should be $true
        }

        It "Should return `$false if file not present" {
            $sut = [AzureKeyVaultSecret]::new()
            Mock Get-ChildItem {return $null}

            $sut.TestFilePath("notexists") | Should be $false
        }

        It "Should return `$false if location is a directory" {
            $sut = [AzureKeyVaultSecret]::new()
            Mock Get-ChildItem {return (New-Object System.IO.FileInfo(Split-Path -Parent $MyInvocation.MyCommand.Path))}

            $sut.TestFilePath("notAFile") | Should be $false
        }      

        It "Should return `$false if location is a container" {
            $sut = [AzureKeyVaultSecret]::new()
            Mock Get-ChildItem {return (New-Object System.IO.FileInfo("Cert:\LocalMachine"))}

            $sut.TestFilePath("notValid") | Should be $false
        }      
    }

    Context "[AzureKeyVaultSecret]::VerifyModuleDependencies()" {    
        BeforeAll {
            $testModulesPath = Join-Path -Path (Split-Path $scriptPath) -ChildPath "TestModules"
            $env:PSModulePath += ";$testModulesPath"
            
            Import-Module -Name TestModule1
            Import-Module -Name TestModule2
        }
        AfterAll {
            Remove-Module TestModule1
            Remove-Module TestModule2
        }

        It "Should not throw if the modules are present" {
            $sut = [AzureKeyVaultSecret]::new()
            $modules = @("TestModule1", "TestModule2")
            {$sut.VerifyModuleDependencies($modules)} | Should not throw
        }

        It "Should throw if the modules are not present" {
            $sut = [AzureKeyVaultSecret]::new()
            $modules = @("TestModuleX", "TestModuleY")
            {$sut.VerifyModuleDependencies($modules)} | Should throw
        }

        It "Should throw if one of the modules are not present" {
            $sut = [AzureKeyVaultSecret]::new()
            $modules = @("TestModule1", "TestModuleZ")
            {$sut.VerifyModuleDependencies($modules)} | Should throw
        }
    }        
}