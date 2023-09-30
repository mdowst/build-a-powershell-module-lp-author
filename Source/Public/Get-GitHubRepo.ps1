Function Get-GitHubRepo{
    <#
    .SYNOPSIS
    Get a repository
    
    .DESCRIPTION
    The `parent` and `source` objects are present when the repository is a fork. `parent` is the repository this repository was forked   
    from, `source` is the ultimate source for the network.

    **Note:** In order to see the `security_and_analysis` block for a repository you must have admin permissions for the repository or   
    be an owner or security manager for the organization that owns the repository. For more information, see "[Managing security
    managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managin 
    g-security-managers-in-your-organization)."
    
    .PARAMETER Owner
    The owner of the repository
    
    .PARAMETER Repo
    The name of the repository
    
    .EXAMPLE
    Get-GitHubRepo -Owner 'you' -Repo 'YourRepo'
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]    
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$Repo
    )

    $Path = "/repos/$($Owner)/$($Repo)"
    Invoke-GitHubApi -Path $Path -Method Get
    
}