Function Get-DependencyState {
    param (
        $Dependencies
    )

    try { 
        $MissingDependencies = @()

        # Check each dependenciy for installation status
        ForEach($PoshDep in $Dependencies) {
            if (Get-Module -ListAvailable -Name $PoshDep ) {
                Write-Information "   Dependency is installed: $PoshDep."
            } else {
                Write-Information "   Depend is not installed: $PoshDep."
                $MissingDependencies += $PoshDep
            }
        }

        # Return missing dependencies
        return $MissingDependencies

    } catch {
        # Clearly that did not go well.
        throw " Could not check dependencies. `r`n $_"
    }
}

Function Install-Dependency {
    param (
        $Dependencies
    )
    
    try {
        # ForEach dependency, install
        ForEach($Dep in $Dependencies) {
            Write-Host " Installing module: $Dep"
            Install-Module -Name $Dep -Scope CurrentUser -Force -Confirm:$False
        }
    } catch {
        throw " Unable to install dependencies. `r`n $_"
    }
}

Function Get-AppsWithNoCreds {
    param (
        $AppRegistrations
    )

    try {
        $NoCredApps = @()

        # Find applications for no valid credentials
        $Count = 1
        ForEach($App in $AppRegistrations) {            
            Write-Progress `
                -Id 1 `
                -Activity "Checking for apps without recent access history" `
                -Status "App: $($App.DisplayName)" `
                -PercentComplete ($Count * 100 / $AppRegistrations.count)

            $Keys = $App.KeyCredentials | Where-Object { $_.EndDateTime -gt (Get-Date)}
            $Passwords = $App.PasswordCredentials | Where-Object { $_.EndDateTime -gt (Get-Date)}

            if ( $Keys.count + $Passwords.count -eq 0) {
                $NoCredApps += $App
            }

            $Count += 1
        }

        # End write-progress
        Write-Progress `
        -Id 1 `
        -Activity "Checking for apps without valid credentials." `
        -Status "Complete" `
        -Completed

        # Return the guilty parties
        return $NoCredApps
    } catch {
        throw " Could not get credential information. `r`n $_ "
    }
}

Function Get-AppsWithNoAccessHistory {
    param (
        $AppRegistrations
    )

    try { 
        $NoAuditLogApps = @()

        # Search through all the log types for the entity.
        $Count = 1
        ForEach($App in $AppRegistrations) { 
            Write-Progress `
                -Id 1 `
                -Activity "Checking for apps without recent access history" `
                -Status "App: $($App.DisplayName)" `
                -PercentComplete ($Count * 100 / $AppRegistrations.count)

            # Filter for audit log events pertaining to service principal signin
            $Filter+= "appId eq '$($App.AppId)'"
            $AuditLogs = Get-MgBetaAuditLogSignIn -Filter $Filter -Top 1

            if ( $AuditLogs.count -eq 0) {
                $NoAuditLogApps += $App
            }

            $Count += 1
        }

        # End write-progress
        Write-Progress `
            -Id 1 `
            -Activity "Checking for apps without recent access history." `
            -Status "Complete" `
            -Completed

        # Return apps with no audit logs
        return $NoAuditLogApps
    } catch { 
        throw " Could not get audit information. `r`n $_ "
    }
}