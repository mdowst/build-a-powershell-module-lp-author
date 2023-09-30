Function Remove-GitHubRepo{
    <#
    .SYNOPSIS
    Delete a repository

    .DESCRIPTION
    Deleting a repository requires admin access. If OAuth is used, the delete_repo scope is required.

    If an organization owner has configured the organization to prevent members from deleting organization-owned repositories, you will get a 403 Forbidden response.

    .PARAMETER Owner
    The owner of the repository

    .PARAMETER Repo
    The name of the repository

    .EXAMPLE
    Remove-GitHubRepo -Owner 'you' -Repo 'YourRepo'

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        [Parameter(Mandatory = $true)]
        [string]$Repo
    )

    $Path = "/repos/$($Owner)/$($Repo)"
    Invoke-GitHubApi -Path $Path -Method DELETE

}