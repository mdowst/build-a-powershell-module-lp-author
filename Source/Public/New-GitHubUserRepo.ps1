Function New-GitHubUserRepo {
    <#
	.SYNOPSIS
	Create a repository for the authenticated user

	.DESCRIPTION
	Creates a new repository for the authenticated user.
	
	**OAuth scope requirements**
	
	When using [OAuth](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:
	
	*   `public_repo` scope or `repo` scope to create a public repository. Note: For GitHub AE, use `repo` scope to create an internal repository.
	*   `repo` scope to create a private repository.

    .PARAMETER Name
    The name of the repository.,

    .PARAMETER Description
    A short description of the repository.,

    .PARAMETER Homepage
    A URL with more information about the repository.,

    .PARAMETER Private
    Whether the repository is private.,

    .PARAMETER HasIssues
    Whether issues are enabled.,

    .PARAMETER HasProjects
    Whether projects are enabled.,

    .PARAMETER HasWiki
    Whether the wiki is enabled.,

    .PARAMETER HasDiscussions
    Whether discussions are enabled.,

    .PARAMETER TeamId
    The id of the team that will be granted access to this repository. This is only valid when creating a repository in an organization.,

    .PARAMETER AutoInit
    Whether the repository is initialized with a minimal README.,

    .PARAMETER GitignoreTemplate
    The desired language or platform to apply to the .gitignore.,

    .PARAMETER LicenseTemplate
    The license keyword of the open source license for this repository.,

    .PARAMETER AllowSquashMerge
    Whether to allow squash merges for pull requests.,

    .PARAMETER AllowMergeCommit
    Whether to allow merge commits for pull requests.,

    .PARAMETER AllowRebaseMerge
    Whether to allow rebase merges for pull requests.,

    .PARAMETER AllowAutoMerge
    Whether to allow Auto-merge to be used on pull requests.,

    .PARAMETER DeleteBranchOnMerge
    Whether to delete head branches when pull requests are merged,

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

    .PARAMETER HasDownloads
    Whether downloads are enabled.,

    .PARAMETER IsTemplate
    Whether this repository acts as a template that can be used to generate new repositories.

	.EXAMPLE
    New-GitHubUserRepo -Owner 'You' -Name 'TestPoshV1' -Private $true
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [string]$Homepage,

        [Parameter(Mandatory = $false)]
        [boolean]$Private,

        [Parameter(Mandatory = $false)]
        [boolean]$HasIssues,

        [Parameter(Mandatory = $false)]
        [boolean]$HasProjects,

        [Parameter(Mandatory = $false)]
        [boolean]$HasWiki,

        [Parameter(Mandatory = $false)]
        [boolean]$HasDiscussions,

        [Parameter(Mandatory = $false)]
        [int]$TeamId,

        [Parameter(Mandatory = $false)]
        [boolean]$AutoInit,

        [Parameter(Mandatory = $false)]
        [string]$GitignoreTemplate,

        [Parameter(Mandatory = $false)]
        [string]$LicenseTemplate,

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
        [boolean]$HasDownloads,

        [Parameter(Mandatory = $false)]
        [boolean]$IsTemplate
    )

    $BodyJson = ConvertTo-GitHubJsonBody -Body $PSBoundParameters
    $Path = "/user/repos"
    Invoke-GitHubApi -Path $Path -Method POST -Body $BodyJson

}