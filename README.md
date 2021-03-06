# cAzureKeyVault
Community Azure Key Vault DSC resource for retrieving Key Vault secrets. 

![Build Badge](https://mimeo.visualstudio.com/_apis/public/build/definitions/191e3dff-b5d1-4cb2-bf19-4764893e734a/339/badge)

The **cAzureKeyVault** module contains the following resource:

### AzureKeyVaultSecret 

The **AzureKeyVaultSecret** DSC resource is Used to retrieve a secret from the Key Vault.

* **Ensure**: Indicates if the secret has been retrieved with the value saved in the specified path. Set this property to `Present` (the default value) to ensure that the file is present in the Path. Set this property to `Absent` to remove the file from the Path.
* **SecretName**: The secret name to retrieve from Azure Key Vault.
* **Base64Decode**: Set this property to `$true` to Base64 decode the secret value when saving to a file. This is required if the secret value is a base64 encoded value like a file or certificate, for example. Set this property to `$false` (the default value) if the secret is a simple value type.
* **Path**: The fully qualified file location where the retrieved secret will be persisted to disk.
* **VaultName**: The Azure Key Vault name from where to retrieve secrets.
* **Credential**: The PSCredential object with GET permissions to the Azure Key Vault secret. Consider using a service principal account credential.
* **TenantId**: The Azure tenant Id associated with the Azure Key Vault and credential.

For more information on creating a PSCredential object for an Azure service principal account, refer to the ["Create service principal" documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal).

## Examples 

### Retrieve a Key Vault secret value 

This example shows how to retrieve a simple key vault secret value type.

```powershell
Configuration AzureKeyVaultSecretFeatures {
    Import-DscResource -ModuleName cAzureKeyVault
    $azureServicePrincipalAppId = "xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx"
    $azureServicePrincipalKey = ConvertTo-SecureString "password1234!" -AsPlainText -Force
    $cred = New-Object PsCredential($azureServicePrincipalAppId, $azureServicePrincipalKey)

    Node "localhost" {
        AzureKeyVaultSecret RetrieveSecretValue {
            SecretName = "some-azure-keyvault-secret"
            VaultName = "mycompany-keyvault"
            Path = "X:\secrets\some-azure-keyvault-secret.txt"
            Credential = $cred
            TenantId = "zzzzzzzz-zzzz-zzzz-zzzzzzzzzz"
            Ensure = "Present"
            Base64Decode = $false        
        }

        Script ViewSecretValue {
            Set {
                $encryptedValue = Get-Content "X:\secrets\some-azure-keyvault-secret.txt" | ConvertTo-SecureString
                $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encryptedValue)
                
                $secretValuePlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

                # Now do something with the $secretValuePlainText
                # ...
            }
            DependsOn = "[AzureKeyVaultSecret]RetrieveSecretValue"
        }
    }
}

AzureKeyVaultSecretFeatures

Start-DscConfiguration .\AzureKeyVaultSecretFeatures -Wait -Verbose -Force

```


### Retrieve a Key Vault secret p12 file 

This example shows how to retrieve a p12 file secret.

```powershell
Configuration AzureKeyVaultSecretFeatures {
    Import-DscResource -ModuleName cAzureKeyVault
    $azureServicePrincipalAppId = "xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx"
    $azureServicePrincipalKey = ConvertTo-SecureString "password1234!" -AsPlainText -Force
    $cred = New-Object PsCredential($azureServicePrincipalAppId, $azureServicePrincipalKey)

    Node "localhost" {
        AzureKeyVaultSecret RetrieveSecretP12 {
            SecretName = "some-azure-keyvault-p12-file"
            VaultName = "mycompany-keyvault"
            Path = "X:\secrets\some-azure-keyvault-p12-file.p12"
            Credential = $cred
            TenantId = "zzzzzzzz-zzzz-zzzz-zzzzzzzzzz"
            Ensure = "Present"
            Base64Decode = $true
        }
    }
}

AzureKeyVaultSecretFeatures

Start-DscConfiguration .\AzureKeyVaultSecretFeatures -Wait -Verbose -Force
```