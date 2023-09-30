#Region '.\Private\ConvertTo-GitHubParams.ps1' 0
Function ConvertTo-GitHubJsonBody{
    <#
    .SYNOPSIS
    Converts a hashtable to JSON
    
    .DESCRIPTION
    When building the functions to make them more "PowerShell" like the underscores where removed. When an underscore was
    removed the next letter was capitalized. This function reverses that to put map it back to the GitHub format
    
    .PARAMETER Body
    A hashtable with the parameters to pass to the GitHub API
    
    .PARAMETER Depth
    The depth required for your JSON object
    
    .EXAMPLE
    ConvertTo-GitHubJsonBody -Body $PSBoundParameters
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]    
        [hashtable]$Body,

        [Parameter(Mandatory = $false)]    
        [int]$Depth = 2
    )

    $ParsedBody = [ordered]@{}
    $Body.GetEnumerator() | Where-Object { $_.Key -notin 
        [System.Management.Automation.Cmdlet]::CommonParameters } | ForEach-Object{
        $key = [string]::Empty
        $ka = $_.Key.ToCharArray()
        for($i = 0; $i - $ka.Count; $i++){
            if([int]$ka[$i] -lt 97){
                if($i -gt 0){
                    $key += '_'
                }
                $key += $ka[$i].ToString().ToLower()
            }
            else{
                $key += $ka[$i]
            }
        }
        $ParsedBody.Add($key, $_.Value)
    }

    $ConvertedJson = $ParsedBody | ConvertTo-Json -Depth $Depth

    Write-Verbose "Converted Body :`n$ConvertedJson"

    $ConvertedJson
}

#EndRegion '.\Private\ConvertTo-GitHubParams.ps1' 55
#Region '.\Private\Invoke-GitHubApi.ps1' 0
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

#EndRegion '.\Private\Invoke-GitHubApi.ps1' 61
#Region '.\Public\Connect-GitHub.ps1' 0
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
#EndRegion '.\Public\Connect-GitHub.ps1' 62
#Region '.\Public\Get-GitHubRepo.ps1' 0
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
#EndRegion '.\Public\Get-GitHubRepo.ps1' 38
#Region '.\Public\New-GitHubUserRepo.ps1' 0
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
#EndRegion '.\Public\New-GitHubUserRepo.ps1' 183
#Region '.\Public\Remove-GitHubRepo.ps1' 0
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
#EndRegion '.\Public\Remove-GitHubRepo.ps1' 33
#Region '.\Public\Update-GitHubRepo.ps1' 0
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
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$Repo,
        
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
#EndRegion '.\Public\Update-GitHubRepo.ps1' 219
