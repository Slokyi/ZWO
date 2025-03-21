# 获取 git log 信息，格式为 --numstat，包含作者信息
$gitLog = git log --numstat --format="%an"

# 初始化变量
$currentAuthor = ""
$fileStats = @()

foreach ($line in $gitLog) {
    if ($line -notmatch '^\d+\s+\d+\s+') {
        # 如果行不匹配数字模式，说明是作者信息
        $currentAuthor = $line
    } else {
        # 匹配数字模式，说明是文件的统计信息
        $parts = $line -split '\s+'
        $insertions = [int]$parts[0]
        $deletions = [int]$parts[1]
        $file = $parts[2]

        $entry = [PSCustomObject]@{
            Author     = $currentAuthor
            File       = $file
            Insertions = $insertions
            Deletions  = $deletions
        }
        $fileStats += $entry
    }
}

# 对结果按文件进行汇总
$summary = $fileStats | Group-Object -Property File | ForEach-Object {
    [PSCustomObject]@{
        Author     = ($_.Group | Select-Object -First 1).Author
        File       = $_.Name
        Insertions = ($_.Group | Measure-Object -Property Insertions -Sum).Sum
        Deletions  = ($_.Group | Measure-Object -Property Deletions -Sum).Sum
    }
}

# 输出到 CSV 文件
$summary | Export-Csv -Path ".\git_log_stats.csv" -NoTypeInformation
    
