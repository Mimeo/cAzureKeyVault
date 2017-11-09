@{
    RootModule           = 'cAzureKeyVault.psm1'
    DscResourcesToExport = @('AzureKeyVaultSecret')
    FunctionsToExport = ''
    ModuleVersion        = '1.0.2'
    GUID                 = '27d57ce5-c886-4095-94bf-1095763c84ea'
    Author               = 'nshenoy@mimeo.com'
    CompanyName          = 'Mimeo, Inc.'
    Description = 'Community Azure Key Vault DSC resource for retrieving Key Vault secrets.'
    PowerShellVersion    = '5.0'
    
} 