# StaleAppRegistrationCheck

## Overview

This simple powershell script pulls a list of all application registrations and
checks for signs of stale service principals. Namely it checks for three things:

1. Any service principal that has no valid credentials
1. That has not signed in as a service principal
1. And no user has signed in to

With these three checks in place, we can have a high degree of certainty that 
the found service principals are not in active use within the organization.

## Dependencies

- PowerShell 7+
- Microsoft.Graph PowerShell Module
- Microosft.Graph.Beta PowerShell Module

> PowerShell 5.1 _should_ work, but is not tested.

## Permissions

A user running this script must have the following graph permissions:

- Applications.Read.All
- AuditLog.Read.All

## Running the script

1. Clone or download the repository.
1. Unzip in an easy to get location.
1. Open terminal/powershell and navigate to the folder.
1. Run the script with `./StaleAppRegChecker.ps1`
1. Sign on when prompted with an appropriately permissioned account.
1. Review the results in the file `./StaleAppRegistrations.csv`

## Interpeting results

While I've added in the minimum checks required to assess whether or not an app
registration is in use, please don't remove them on the scripts suggestion. Try
to meet with the registering owner and validate before removal. 

## Suggestions / Feedback / Support

Contact me at: connor@nouseless.tech