Function Update-GitHubRepo {
    <#
	.SYNOPSIS
	Create a repository for the authenticated user

	.DESCRIPTION
	Creates a new repository for the authenticated user.
	
	**OAuth scope requirements**
	
	When using [OAuth](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:
	
	*   `public_repo` scope or `repo` scope to create a public repository. Note: For GitHub AE, use `repo` scope to create an internal repository.
	*   `repo` scope to create a private repository.

    .PARAMETER Owner
    The owner of the repository
    
    .PARAMETER Repo
    The name of the repository

    .PARAMETER Name
    The name of the repository.,

    .PARAMETER Description
    A short description of the repository.,

    .PARAMETER Homepage
    A URL with more information about the repository.,

    .PARAMETER Private
    Either true to make the repository private or false to make it public. Default: false.
        **Note**: You will get a 422 error if the organization restricts [changing repository visibility](https://docs.github.com/articles/repository-permission-levels-for-an-organization#changing-the-visibility-of-repositories) to organization owners and a non-owner tries to change the value of private.,

    .PARAMETER Visibility
    The visibility of the repository.,

    .PARAMETER SecurityAndAnalysis
    Specify which security and analysis features to enable or disable for the repository.
        
        To use this parameter, you must have admin permissions for the repository or be an owner or security manager for the organization that owns the repository. For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."
        
        For example, to enable GitHub Advanced Security, use this data in the body of the PATCH request:
        { "security_and_analysis": {"advanced_security": { "status": "enabled" } } }.
        
        You can check which security and analysis features are currently enabled by using a GET /repos/{owner}/{repo} request.,

    .PARAMETER HasIssues
    Either true to enable issues for this repository or false to disable them.,

    .PARAMETER HasProjects
    Either true to enable projects for this repository or false to disable them. **Note:** If you're creating a repository in an organization that has disabled repository projects, the default is false, and if you pass true, the API returns an error.,

    .PARAMETER HasWiki
    Either true to enable the wiki for this repository or false to disable it.,

    .PARAMETER IsTemplate
    Either true to make this repo available as a template repository or false to prevent it.,

    .PARAMETER DefaultBranch
    Updates the default branch for this repository.,

    .PARAMETER AllowSquashMerge
    Either true to allow squash-merging pull requests, or false to prevent squash-merging.,

    .PARAMETER AllowMergeCommit
    Either true to allow merging pull requests with a merge commit, or false to prevent merging pull requests with merge commits.,

    .PARAMETER AllowRebaseMerge
    Either true to allow rebase-merging pull requests, or false to prevent rebase-merging.,

    .PARAMETER AllowAutoMerge
    Either true to allow auto-merge on pull requests, or false to disallow auto-merge.,

    .PARAMETER DeleteBranchOnMerge
    Either true to allow automatically deleting head branches when pull requests are merged, or false to prevent automatic deletion.,

    .PARAMETER AllowUpdateBranch
    Either true to always allow a pull request head branch that is behind its base branch to be updated even if it is not required to be up to date before merging, or false otherwise.,

    .PARAMETER UseSquashPrTitleAsDefault
    Either true to allow squash-merge commits to use pull request title, or false to use commit message. **This property has been deprecated. Please use squash_merge_commit_title instead.,

    .PARAMETER SquashMergeCommitTitle
    The default value for a squash merge commit title:
        
        - PR_TITLE - default to the pull request's title.
        - COMMIT_OR_PR_TITLE - default to the commit's title (if only one commit) or the pull request's title (when more than one commit).,

    .PARAMETER SquashMergeCommitMessage
    The default value for a squash merge commit message:
        
        - PR_BODY - default to the pull request's body.
        - COMMIT_MESSAGES - default to the branch's commit messages.
        - BLANK - default to a blank commit message.,

    .PARAMETER MergeCommitTitle
    The default value for a merge commit title.
        
        - PR_TITLE - default to the pull request's title.
        - MERGE_MESSAGE - default to the classic title for a merge message (e.g., Merge pull request #123 from branch-name).,

    .PARAMETER MergeCommitMessage
    The default value for a merge commit message.
        
        - PR_TITLE - default to the pull request's title.
        - PR_BODY - default to the pull request's body.
        - BLANK - default to a blank commit message.,

    .PARAMETER Archived
    Whether to archive this repository. false will unarchive a previously archived repository.,

    .PARAMETER AllowForking
    Either true to allow private forks, or false to prevent private forks.,

    .PARAMETER WebCommitSignoffRequired
    Either true to require contributors to sign off on web-based commits, or false to not require contributors to sign off on web-based commits.

	.EXAMPLE
    Update-GitHubRepo -Owner 'You' -Repo 'TestPoshV1' -Description "Test update function"
    
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]    
        $Owner,
        
        [Parameter(Mandatory = $true)]
        $Repo,
        
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [string]$Homepage,

        [Parameter(Mandatory = $false)]
        [boolean]$Private,

        [Parameter(Mandatory = $false)]
        [ValidateSet('public', 'private')]
        [string]$Visibility,

        [Parameter(Mandatory = $false)]
        [object]$SecurityAndAnalysis,

        [Parameter(Mandatory = $false)]
        [boolean]$HasIssues,

        [Parameter(Mandatory = $false)]
        [boolean]$HasProjects,

        [Parameter(Mandatory = $false)]
        [boolean]$HasWiki,

        [Parameter(Mandatory = $false)]
        [boolean]$IsTemplate,

        [Parameter(Mandatory = $false)]
        [string]$DefaultBranch,

        [Parameter(Mandatory = $false)]
        [boolean]$AllowSquashMerge,

        [Parameter(Mandatory = $false)]
        [boolean]$AllowMergeCommit,

        [Parameter(Mandatory = $false)]
        [boolean]$AllowRebaseMerge,

        [Parameter(Mandatory = $false)]
        [boolean]$AllowAutoMerge,

        [Parameter(Mandatory = $false)]
        [boolean]$DeleteBranchOnMerge,

        [Parameter(Mandatory = $false)]
        [boolean]$AllowUpdateBranch,

        [Parameter(Mandatory = $false)]
        [boolean]$UseSquashPrTitleAsDefault,

        [Parameter(Mandatory = $false)]
        [ValidateSet('PR_TITLE', 'COMMIT_OR_PR_TITLE')]
        [string]$SquashMergeCommitTitle,

        [Parameter(Mandatory = $false)]
        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [string]$SquashMergeCommitMessage,

        [Parameter(Mandatory = $false)]
        [ValidateSet('PR_TITLE', 'MERGE_MESSAGE')]
        [string]$MergeCommitTitle,

        [Parameter(Mandatory = $false)]
        [ValidateSet('PR_BODY', 'PR_TITLE', 'BLANK')]
        [string]$MergeCommitMessage,

        [Parameter(Mandatory = $false)]
        [boolean]$Archived,

        [Parameter(Mandatory = $false)]
        [boolean]$AllowForking,

        [Parameter(Mandatory = $false)]
        [boolean]$WebCommitSignoffRequired
    )

    $Body = $PSBoundParameters
    $Body.Remove('Owner') | Out-Null
    $Body.Remove('Repo') | Out-Null
    $BodyJson = ConvertTo-GitHubJsonBody -Body $PSBoundParameters
    $Path = "/repos/$($owner)/$($repo)"
    Invoke-GitHubApi -Path $Path -Method PATCH -Body $BodyJson
}