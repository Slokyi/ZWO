# 定义远端分支
$branchA = "origin/BranchA"
$branchB = "origin/BranchB"

# 获取远端分支差异的提交列表（BranchB 有但 BranchA 没有）
$commits = git rev-list $branchB --not $branchA --no-merges

# 初始化哈希表存储贡献者数据
$contributors = @{}

foreach ($commit in $commits) {
    # 获取提交的 numstat 数据（强制 ASCII 输出以避免编码问题）
    $log = git log $commit --pretty="%aN" --numstat --encoding=ASCII

    $author = $null
    $log | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^\d+') {
            # 解析添加和删除的行数（格式：添加\t删除\t文件名）
            $fields = $line -split '\t'
            $add = [int]($fields[0] -replace '-', '0')  # 处理二进制文件标记"-"
            $sub = [int]($fields[1] -replace '-', '0')

            if ($author -and $contributors.ContainsKey($author)) {
                $contributors[$author].Added += $add
                $contributors[$author].Removed += $sub
            }
        } elseif (-not [string]::IsNullOrEmpty($line)) {
            # 更新作者
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

# 输出结果（确保列名和格式正确）
$results = $contributors.GetEnumerator() | ForEach-Object {
    $net = $_.Value.Added - $_.Value.Removed
    [PSCustomObject]@{
        Author   = $_.Key
        Added    = $_.Value.Added
        Removed  = $_.Value.Removed
        Net      = $net
    }
} | Sort-Object -Property Net -Descending

# 格式化输出
$results | Format-Table -AutoSize -Property Author, Added, Removed, Net
