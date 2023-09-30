BeforeAll {
    # Import the GitHub module
    $TopLevel = (Split-Path(Split-Path(Split-Path $PSScriptRoot)))
    $ModulePath = Get-ChildItem -Path (Join-Path $TopLevel 'Build\RocinanteGitHub') -Filter 'RocinanteGitHub.psd1' -Recurse | Select-Object -Last 1
    Import-Module $ModulePath.FullName -Force

    # Authenticate to GitHub
    Connect-GitHub -Token ($Env:GITHUBTOKEN | ConvertTo-SecureString -Force -AsPlainText)
}

Describe "Integration Tests" {
    BeforeAll {
        # Generate a new name for the repo
        $repoName = "Pester-$(New-Guid)"
    }
    
    It "Create a repo" {
        # Test if the repo with such a name doesn’t exist
        { Get-GitHubRepo -Owner $Env:TOKENOWNER -Repo $repoName } | Should -Throw
        # Create a repo
        $repo = New-GitHubUserRepo -Name $repoName -Private $true
        $repo.name | Should -Be $repoName
        $repo.full_name | Should -Be "$($Env:TOKENOWNER)/$($repoName)"
        $repo.private | Should -BeTrue
    } 

    It "Get a repo" {
        # Retrieve the repo, and confirm that, e.g., name and privacy settings match what was requested
        $repo = Get-GitHubRepo -Owner $Env:TOKENOWNER -Repo $repoName
        $repo.name | Should -Be $repoName
        $repo.private | Should -BeTrue
    } 

    It "Update a repo" {
        # Update, e.g., description in the repo
        $repo = Update-GitHubRepo -Owner $Env:TOKENOWNER -Repo $repoName -Description 'Pester Testing'
        $repo.name | Should -Be $repoName
        $repo.Description | Should -Be 'Pester Testing'
        $repo.private | Should -BeTrue
    } 

    It "Confirm repo update" {
        # Retrieve the repo once again, and confirm the description actually got updated
        $repo = Get-GitHubRepo -Owner $Env:TOKENOWNER -Repo $repoName
        $repo.Description | Should -Be 'Pester Testing'
    } 

    It "Delete a repo" {
        # Delete the repo
        Remove-GitHubRepo -Owner $Env:TOKENOWNER -Repo $repoName
        # Confirm the repository doesn’t exist
        { Get-GitHubRepo -Owner $Env:TOKENOWNER -Repo $repoName } | Should -Throw
    }
}