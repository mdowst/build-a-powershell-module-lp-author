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

