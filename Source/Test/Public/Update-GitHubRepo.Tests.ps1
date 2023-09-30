BeforeAll {
    # Import the GitHub module
    $TopLevel = (Split-Path(Split-Path(Split-Path $PSScriptRoot)))
    $ModulePath = Get-ChildItem -Path (Join-Path $TopLevel 'Build\RocinanteGitHub') -Filter 'RocinanteGitHub.psd1' -Recurse | Select-Object -Last 1
    Import-Module $ModulePath.FullName -Force

    Mock -CommandName Invoke-GitHubApi -MockWith { return $Body } -ModuleName RocinanteGitHub
}


Describe 'Update-GitHubRepo Tests' {

    It '<Name> Parameter Test' -ForEach @(
        @{Name = 'Owner'; Mandatory = $true; Type = [string] }
        @{Name = 'Repo'; Mandatory = $true; Type = [string] }
        @{Name = 'Description'; Mandatory = $false; Type = [string] }
        @{Name = 'Private'; Mandatory = $false; Type = [boolean] }
        @{Name = 'DefaultBranch'; Mandatory = $false; Type = [string] }
    ) {
        (Get-Command Update-GitHubRepo).Parameters[$Name].Attributes.Mandatory | Should -Be $Mandatory
        (Get-Command Update-GitHubRepo).Parameters[$Name].ParameterType -eq $Type | Should -BeTrue
    }

    It 'Update-GitHubRepo Api Call'{
        Update-GitHubRepo -Owner 'OwnerName' -Repo 'RepoName' -DefaultBranch 'main'
        Assert-MockCalled Invoke-GitHubApi -Scope It -Times 1 -ModuleName RocinanteGitHub -ParameterFilter { $Path -eq '/repos/OwnerName/RepoName' }
        Assert-MockCalled Invoke-GitHubApi -Scope It -Times 1 -ModuleName RocinanteGitHub -ParameterFilter { $Method -eq 'Patch' }
        Assert-MockCalled Invoke-GitHubApi -Scope It -Times 1 -ModuleName RocinanteGitHub -ParameterFilter { $Body -cmatch 'default_branch' }
    }
}

