function Connect-EntraID {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ClientId,
        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,
        [Parameter(Mandatory = $true)]
        [string]$TenantId
    )

    # Check if a token is already available
    if ($global:EntraIDSession -and $global:EntraIDSession.Expires -and $global:EntraIDSession.ExpiresIn) {
        if ($global:EntraIDSession.Expires -lt (Get-Date)) {
            Write-Host "Token expired. Reconnecting to EntraID."
        } else {
            Write-Host "Token still valid. Skipping connection."
            return $global:EntraIDSession
        }
    } else {
        Write-Host "No token found. Connecting to EntraID."
    }

    $body = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        grant_type    = 'client_credentials'
        scope         = 'api://<app_id>/access_as_user'
    }

    $response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $body

    $session = [PSCustomObject]@{
        Token        = $response.access_token
        Expires      = (Get-Date).AddSeconds($response.expires_in)
        ExpiresIn    = $response.expires_in
    }

    $global:EntraIDSession = $session

    return $global:EntraIDSession
}
