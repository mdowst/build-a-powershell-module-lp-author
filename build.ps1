Set-Location $PSScriptRoot

Get-ChildItem -Path .\Build -Exclude 'nuget.exe' | Remove-Item -Recurse -Force

$linter = . '.\Source\Test\ScriptAnalyzer\ScriptAnalyzer.Linter.ps1'
if($linter){
    throw "Failed linter tests"
}

Build-Module -SourcePath .\Source -OutputDirectory ..\Build 

$config = New-PesterConfiguration
$config.Output.Verbosity = 'Detailed'
$config.Run.Path = (Join-Path $PSScriptRoot 'Source\Test')
$config.Run.Throw = $true
Invoke-Pester -Configuration $config


$psd1 = Get-ChildItem .\Build -Filter 'RocinanteGitHub.psd1' -Recurse | Select-Object -Last 1 
$nuspec = Copy-Item -Path .\Source\RocinanteGitHub.nuspec -Destination $psd1.DirectoryName -PassThru

$moduleData = Import-PowerShellDataFile -Path $psd1.FullName

Set-Location .\Build 

.'nuget.exe' pack "$($nuspec.FullName)" -OutputDirectory ..\PSRepo -Version "$($moduleData.ModuleVersion)"

Set-Location $PSScriptRoot