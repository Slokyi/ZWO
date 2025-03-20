# 定义远端分支
$branchA = "origin/BranchA"
$branchB = "origin/BranchB"

# 获取远端分支差异的提交列表
$commits = git rev-list $branchB --not $branchA --no-merges

# 初始化哈希表存储贡献者数据
$contributors = @{}

# 遍历每个提交
foreach ($commit in $commits) {
    $log = git log $commit --pretty="%aN" --numstat
    $author = $null

    foreach ($line in $log) {
        if ($line -match '^\d+') {
            $fields = $line -split '\t'
            $add = [int]$fields[0]
            $sub = [int]$fields[1]

            if ($author -and $contributors.ContainsKey($author)) {
                $contributors[$author].Added += $add
                $contributors[$author].Removed += $sub
            }
        } elseif (-not [string]::IsNullOrEmpty($line)) {
            $author = $line
            if (-not $contributors.ContainsKey($author)) {
                $contributors[$author] = [PSCustomObject]@{
                    Added = 0
                    Removed = 0
                }
            }
        }
    }
}

# 输出结果
$contributors.GetEnumerator() | ForEach-Object {
    $net = $_.Value.Added - $_.Value.Removed
    [PSCustomObject]@{
        Author = $_.Key
        Added = $_.Value.Added
        Removed = $_.Value.Removed
        Net = $net
    }
} | Sort-Object -Property Net -Descending | Format-Table -AutoSize
