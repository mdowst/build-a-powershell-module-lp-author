param(
    [Parameter(Mandatory = $false)]    
    [string]$Version = 'v1.2.3'
)

$VersionNumber = [version]::parse($Version.Split('/')[-1].TrimStart('v'))
Set-Location $PSScriptRoot

Get-ChildItem -Path .\Build -Exclude 'nuget.exe' | Remove-Item -Recurse -Force

$linter = . '.\Source\Test\ScriptAnalyzer\ScriptAnalyzer.Linter.ps1'
if ($linter) {
    throw "Failed linter tests"
}

Build-Module -SourcePath .\Source -OutputDirectory ..\Build -Version $VersionNumber

$config = New-PesterConfiguration
$config.Output.Verbosity = 'Detailed'
$config.Run.Path = (Join-Path $PSScriptRoot 'Source\Test')
$config.Run.Throw = $true
Invoke-Pester -Configuration $config


$psd1 = Get-ChildItem .\Build -Filter 'RocinanteGitHub.psd1' -Recurse | Select-Object -Last 1 
$nuspec = Copy-Item -Path .\Source\RocinanteGitHub.nuspec -Destination $psd1.DirectoryName -PassThru

Set-Location .\Build 

.'nuget.exe' pack "$($nuspec.FullName)" -OutputDirectory ..\PSRepo -Version "$($VersionNumber)"

Set-Location $PSScriptRoot