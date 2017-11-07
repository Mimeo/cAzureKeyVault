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