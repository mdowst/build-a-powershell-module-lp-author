param(
    [Parameter(Mandatory = $false)]    
    [string]$Version = 'v1.2.3'
)

$VersionNumber = [version]::parse($Version.Split('/')[-1].TrimStart('v'))
Set-Location $PSScriptRoot

Get-ChildItem -Path .\Build | Remove-Item -Recurse -Force

$linter = . '.\Source\Test\ScriptAnalyzer\ScriptAnalyzer.Linter.ps1'
if ($linter) {
    throw "Failed linter tests"
}

Build-Module -SourcePath .\Source -OutputDirectory ..\Build -Version $VersionNumber

$psd1 = Get-ChildItem .\Build -Filter 'RocinanteGitHub.psd1' -Recurse | Select-Object -Last 1 
$nuspec = Copy-Item -Path .\Source\RocinanteGitHub.nuspec -Destination $psd1.DirectoryName -PassThru

.'nuget.exe' pack "$($nuspec.FullName)" -OutputDirectory ..\PSRepo -Version "$($VersionNumber)"
