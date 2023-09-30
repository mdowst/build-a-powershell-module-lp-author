BeforeAll {
    # Import the GitHub module
    $TopLevel = (Split-Path(Split-Path(Split-Path $PSScriptRoot)))
    $ModulePath = Get-ChildItem -Path (Join-Path $TopLevel 'Build\RocinanteGitHub') -Filter 'RocinanteGitHub.psd1' -Recurse | Select-Object -Last 1
    Import-Module $ModulePath.FullName -Force

    Mock -CommandName Invoke-GitHubApi -MockWith { return $Body } -ModuleName RocinanteGitHub
}


Describe 'New-GitHubUserRepo Tests' {

    It '<Name> Parameter Test' -ForEach @(
        @{Name = 'Name'; Mandatory = $true; Type = [string] }
        @{Name = 'Description'; Mandatory = $false; Type = [string] }
        @{Name = 'Private'; Mandatory = $false; Type = [boolean] }
    
    ) {
        (Get-Command New-GitHubUserRepo).Parameters[$Name].Attributes.Mandatory | Should -Be $Mandatory
        (Get-Command New-GitHubUserRepo).Parameters[$Name].ParameterType -eq $Type | Should -BeTrue
    }

    It 'New-GitHubUserRepo Api Call' {
        $test = New-GitHubUserRepo -Name 'NewRepoName'
        Assert-MockCalled Invoke-GitHubApi -Scope It -Times 1 -ModuleName RocinanteGitHub -ParameterFilter { $Path -eq '/user/repos' }
        Assert-MockCalled Invoke-GitHubApi -Scope It -Times 1 -ModuleName RocinanteGitHub -ParameterFilter { $Method -eq 'Post' }
        ($test | ConvertFrom-Json).name | Should -Be 'NewRepoName'
    }
}

