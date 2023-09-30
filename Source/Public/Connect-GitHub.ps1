Function Connect-GitHub {
    <#
    .SYNOPSIS
    Creates a prebuilt header and URI builder for communicating with the GitHub API

    .DESCRIPTION
    Creates a prebuilt header and URI builder for communicating with the GitHub API

    .PARAMETER Token
    A secure string with your personal access token

    https://github.com/settings/tokens?type=beta

    .EXAMPLE
    $token = ConvertTo-SecureString 'github_pat_hkalsdkasdkasdkjahskdjhaksdjhajksdhksdh' -AsPlainText -Force
    Connect-GitHub -Token $token

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [securestring]$Token
    )

    $UriHost = "api.github.com"
    $Api = "2022-11-28"

    $Uri = [System.UriBuilder]::new("https", $UriHost, 443)

    $PAT = ConvertFrom-SecureString -SecureString $Token -AsPlainText
    $headers = @{
        "X-GitHub-Api-Version" = $Api
        "Authorization"        = "Bearer $($PAT)"
    }

    $RestMethod = @{
        Uri     = $Uri.Uri
        Headers = $headers
        Method  = "Get"
    }
    try {
        $request = Invoke-RestMethod @RestMethod -ErrorAction Stop
    }
    catch {
        $request = $null
        $failure = $_.Exception.Message
    }

    if ($request) {
        $script:__GitHubAuth = [pscustomobject]@{
            Headers = $Headers
            UriHost = $UriHost
            Api     = $Api
        }
        Write-Output "Connected to GitHub"
    }
    else {
        Write-Error "Failed to connect to GitHub $($failure)"
    }
}