Function Invoke-GitHubApi {
    <#
    .SYNOPSIS
    Internal function to invoke the GitHub API
    
    .DESCRIPTION
    Internal function to invoke the GitHub API
    
    .PARAMETER Path
    The Path portion of the URI
    
    .PARAMETER Body
    A JSON formated string with the required body values
    
    .PARAMETER Method
    The Http method to use
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateScript({
            try{
                $_ | ConvertFrom-Json -ErrorAction Stop
                $true
            }
            catch{
                throw "Body must be a valid JSON"
            }
        })]
        [string]$Body,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Default','Get','Head','Post','Put','Delete','Trace','Options','Merge','Patch')]
        [string]$Method = "Get"
    )

    if (-not $script:__GitHubAuth) {
        throw "Run 'Connect-GitHub' to establish a connection"
    }

    $Uri = [System.UriBuilder]::new("https",$script:__GitHubAuth.UriHost,443,$Path)
    Write-Verbose "Uri : $($Uri.Uri)"
    $params = @{
        Uri         = $Uri.Uri
        Method      = $Method
        ContentType = 'application/json'
        Headers     = $script:__GitHubAuth.Headers
    }

    if ($PSBoundParameters['Body']) {
        $params.Add('Body', $Body)
    }

    Invoke-RestMethod @params
}

