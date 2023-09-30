BeforeAll {
    # Import the GitHub module
    $TopLevel = (Split-Path(Split-Path(Split-Path $PSScriptRoot)))
    $ModulePath = Get-ChildItem -Path (Join-Path $TopLevel 'Build\RocinanteGitHub') -Filter 'RocinanteGitHub.psd1' -Recurse | Select-Object -Last 1
    Import-Module $ModulePath.FullName -Force

    Mock -CommandName Invoke-GitHubApi -MockWith { return $null } -ModuleName RocinanteGitHub
}


Describe 'Get-GitHubRepo Tests' {

    It '<Name> Parameter Test' -ForEach @(
        @{Name = 'Owner' }
        @{Name = 'Repo' }
    ) {
        (Get-Command Get-GitHubRepo).Parameters[$Name].Attributes.Mandatory | Should -BeTrue
        (Get-Command Get-GitHubRepo).Parameters[$Name].ParameterType -eq [string] | Should -BeTrue
    }

    It 'Get-GitHubRepo Api Call'{
        Get-GitHubRepo -Owner 'OwnerName' -Repo 'RepoName'
        Assert-MockCalled Invoke-GitHubApi -Scope It -Times 1 -ModuleName RocinanteGitHub -ParameterFilter { $Path -eq '/repos/OwnerName/RepoName' }
        Assert-MockCalled Invoke-GitHubApi -Scope It -Times 1 -ModuleName RocinanteGitHub -ParameterFilter { $Method -eq 'Get' }
    }
}

