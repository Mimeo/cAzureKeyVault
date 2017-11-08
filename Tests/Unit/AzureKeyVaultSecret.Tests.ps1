<#
    Pester unit tests for the cAzureKeyVault DSC module.
#>
using module "..\..\cAzureKeyVault.psm1"
$scriptPath = $MyInvocation.MyCommand.Path

Describe "AzureKeyVaultSecret" {
    
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