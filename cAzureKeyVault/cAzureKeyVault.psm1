enum Ensure {
    Absent
    Present
}

<#
    This resource retrieves an Azure Key Vault secret and saves it to a specified file
#>

[DscResource()]
class AzureKeyVaultSecret {

    <# 
        Key Vault secret name to retrieve
    #>
    [DscProperty(Key)]
    [string] $SecretName

    <# 
        Whether or not to Base64 decode the contents before serializing to a file
    #>
    [DscProperty()]
    [bool] $Base64Decode = $false

    <#
        Fully qualified path to the file that is expected to be present or absent.
    #>
    [DscProperty(Mandatory)]
    [string] $Path

    <# 
        Key Vault secret name to retrieve
    #>
    [DscProperty(Mandatory)]
    [string] $VaultName

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <# 
        Azure Resource Manager account credentials with GET access to the Key Vault
    #>
    [DscProperty(Mandatory)]
    [PSCredential] $Credential

    <# 
        Azure Resource Manager account tenant Id used for logging in
    #>
    [DscProperty(Mandatory)]
    [string] $TenantId
  
    [DscProperty(NotConfigurable)]
    [Nullable[datetime]] $CreationTime

    [DscProperty(NotConfigurable)]
    [string] $FileSize

    [void] Set() {
        $this.VerifyModuleDependencies

        $fileExists = $this.TestFilePath($this.Path)
        if ($this.Ensure -eq [Ensure]::Present) {
            if (-not $fileExists) {
                try {
                    Login-AzureRmAccount -ServicePrincipal -Credential $this.Credential -TenantId $this.TenantId
                    $keyVaultSecret = Get-AzureKeyVaultSecret -VaultName $this.VaultName -Name $this.SecretName
                    if ($this.Base64Decode) {
                        $bytes = [System.Convert]::FromBase64String($keyVaultSecret.SecretValueText)
                        [System.IO.File]::WriteAllBytes($this.Path, $bytes)
                    }
                    else {
                        Set-Content -Path $this.Path -Value $keyVaultSecret.SecretValueText
                    }
                }
                catch {
                    if($this.TestFilePath($this.Path)) {
                        Remove-Item -LiteralPath $this.Path -Force
                    }
                    throw $_
                }
            }
        }
        else {
            if ($fileExists) {
                Write-Verbose -Message "Deleting the file $($this.Path)"
                Remove-Item -LiteralPath $this.Path -Force
            }
        }
    }

    [bool] Test() {
        $present = $this.TestFilePath($this.Path)

        if ($this.Ensure -eq [Ensure]::Present) {
            return $present
        }
        else {
            return -not $present
        }
    }

    [AzureKeyVaultSecret] Get() {
        $present = $this.TestFilePath($this.Path)

        if ($present) {
            $file = Get-ChildItem -LiteralPath $this.Path
            $this.CreationTime = $file.CreationTime
            $this.FileSize = $file.Length
            $this.Ensure = [Ensure]::Present
        }
        else {
            $this.CreationTime = $null
            $this.FileSize = $null
            $this.Ensure = [Ensure]::Absent
        }

        return $this 
    }

    <#
        .SYNOPSIS
            Helper function to check if file exists

        .PARAMETER location
            Fully qualified path to file
    #>
    [bool] TestFilePath([string] $location) {
        $present = $true
        $item = Get-ChildItem -LiteralPath $location -ErrorAction Ignore
        if ($item -eq $null) {
            $present = $false
        }
        elseif ($item.PSProvider.Name -ne "FileSystem") {
            throw "Path $($location) is not a file path."
        }
        elseif ($item.PSIsContainer) {
            throw "Path $($location) is a directory path."
        }

        return $present
    }

    <#
        .SYNOPSIS
            Helper function to validate dependent modules exist
    #>
    [void] VerifyModuleDependencies() {
        $dependentModules = @(
            "AzureRM.profile",
            "AzureRM.KeyVault"
        )

        $dependentModules | % {
            if (-not(Get-Module -Name $_ -ListAvailable)) {
                $exception = New-Object System.InvalidOperationException "Please ensure that the $_ Powershell module is installed"
                $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, "ModuleNotFound", [System.Management.Automation.ErrorCategory]::ObjectNotFound, $null
                throw $errorRecord
            }
        }
    }

}