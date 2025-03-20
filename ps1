param(
    [string]$branch1 = "master",
    [string]$branch2 = "feature"
)

$contributors = @{}

git log --pretty="%an" --numstat --no-merges "$branch1...$branch2" | ForEach-Object {
    $line = $_.Trim()
    
    if (-not $line) {
        $currentAuthor = $null
    }
    elseif (-not $currentAuthor) {
        $currentAuthor = $line
        if (-not $contributors.ContainsKey($currentAuthor)) {
            $contributors[$currentAuthor] = [PSCustomObject]@{
                Additions    = 0
                Deletions    = 0
                Modifications = 0
            }
        }
    }
    else {
        $parts = $line -split '\s+'
        if ($parts.Length -ge 2) {
            $add = $parts[0]
            $del = $parts[1]
            
            $addVal = if ($add -match '^\d+$') { [int]$add } else { 0 }
            $delVal = if ($del -match '^\d+$') { [int]$del } else { 0 }
            
            $mod = [Math]::Min($addVal, $delVal)
            $pureAdd = $addVal - $mod
            $pureDel = $delVal - $mod
            
            $contributors[$currentAuthor].Additions += $pureAdd
            $contributors[$currentAuthor].Deletions += $pureDel
            $contributors[$currentAuthor].Modifications += $mod
        }
    }
}

$results = $contributors.GetEnumerator() | ForEach-Object {
    [PSCustomObject]@{
        Author        = $_.Key
        Additions     = $_.Value.Additions
        Deletions     = $_.Value.Deletions
        Modifications = $_.Value.Modifications
        TotalChanges = $_.Value.Additions + $_.Value.Deletions + $_.Value.Modifications
    }
} | Sort-Object Author

$results | Format-Table -AutoSize
