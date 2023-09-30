Set-Location $PSScriptRoot

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

