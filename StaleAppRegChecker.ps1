using module './Functions.psm1'

try {
    # Simple bootstrap
    $InformationPreference = 'Continue'
    $Version = "2023.11.30.02"
    Write-Information " Stale App Registration Check (v: $Version)."

    # Check for and install dependencies
    Write-Information " Checking for dependencies."
    $Dependencies = @('Microsoft.Graph', 'Microsoft.Graph.Beta')
    $MissingDependencies = Get-DependencyState -Dependencies $Dependencies

    if ($DependencyCheck.count -gt 0) {
        Write-Information " Installing dependencies."
        Install-Dependency -Dependencies $MissingDependencies
    }

    # Connect to Microsoft Graph
    # -- Scopes 
    # -- -- Application.Read.All: To see all application and related data
    # -- -- AuditLog.Read.All: To read the audit logs
    Write-Information " Connecting to Microsoft Graph."
    Connect-MgGraph `
        -NoWelcome `
        -Scopes "Application.Read.All", "AuditLog.Read.All"

    # Get all applications
    Write-Information " Getting App Registrations."
    $AppRegistrations = Get-MgApplication -All -Property *  

    # Credential check
    Write-Information " Checking for applications with no valid credentials."
    $NoCredApps = Get-AppsWithNoCreds -AppRegistrations $AppRegistrations

    # Audit Log Check
    Write-Information " Checking for last access by users or identity."
    $NoAccessApps = Get-AppsWithNoAccessHistory -AppRegistrations $NoCredApps

    # Export Naughty Service Principals
    Write-Information " Exporting stale service principals."
    $Export = $NoAccessApps | Select-Object DisplayName, Id, AppId
    $Export | Export-Csv -NoTypeInformation 'StaleAppRegistrations.csv'

} catch {
    # Very basic error handling
    Write-Error " Unable to complete the scan. `r`n $_"

} finally {
    # Close and clean up modules 
    Write-Information " Script execution completed."
    Disconnect-Graph
    Remove-Module -Name Enums
    Remove-Module -Name Classes
    Remove-Module -Name Functions
}