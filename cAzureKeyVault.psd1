@{
    
    # Script module or binary module file associated with this manifest.
    RootModule           = 'cAzureKeyVault.psm1'
    
    DscResourcesToExport = @('AzureKeyVaultSecret')
    
    # Version number of this module.
    ModuleVersion        = '1.0'
    
    # ID used to uniquely identify this module
    GUID                 = '27d57ce5-c886-4095-94bf-1095763c84ea'
    
    # Author of this module
    Author               = 'nshenoy@mimeo.com'
    
    # Company or vendor of this module
    CompanyName          = 'Mimeo, Inc.'
    
    # Description of the functionality provided by this module
    Description = 'Community Azure Key Vault DSC resource for retrieving Key Vault secrets.'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.0'
    
    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''
} 