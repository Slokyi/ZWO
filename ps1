# 获取 git log 信息，格式为 --numstat，包含作者信息
$gitLog = git log --numstat --format="%an"

# 初始化变量
$currentAuthor = ""
$fileStats = @()

foreach ($line in $gitLog) {
    if ($line.StartsWith('-')) {
        continue
    }

    if ($line -notmatch '^\d+\s+\d+\s+(?!- - )' -and -not [string]::IsNullOrWhiteSpace($line)) {
        # 如果行不匹配数字模式且不为空，说明是作者信息
        $currentAuthor = $line
    } elseif ($line -match '^\d+\s+\d+\s+(?!- - )') {
        # 匹配数字模式，说明是文件的统计信息
        $parts = $line -split '\s+'
        $insertions = [int]$parts[0]
        $deletions = [int]$parts[1]
        $file = $parts[2]

        # 排除 .xlsx 和 .xls 文件
        if ($file -notlike "*.xlsx" -and $file -notlike "*.xls") {
            $entry = [PSCustomObject]@{
                Author     = $currentAuthor
                File       = $file
                Insertions = $insertions
                Deletions  = $deletions
            }
            $fileStats += $entry
        }
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

$csvFilePath = ".\git_log_stats.csv"
# 判断文件是否存在，如果存在则删除
if (Test-Path -Path $csvFilePath) {
    Remove-Item -Path $csvFilePath -Force
}

# 输出到 CSV 文件
$summary | Export-Csv -Path $csvFilePath -NoTypeInformation

# 统计每个作者的新增总行数和删除行总数
$authorStats = $fileStats | Group-Object -Property Author | ForEach-Object {
    [PSCustomObject]@{
        Author = $_.Name
        TotalInsertions = ($_.Group | Measure-Object -Property Insertions -Sum).Sum
        TotalDeletions = ($_.Group | Measure-Object -Property Deletions -Sum).Sum
    }
}

# 在文件末尾逐行添加每个作者的统计信息
foreach ($authorStat in $authorStats) {
    $line = "作者: $($authorStat.Author), 新增行总数: $($authorStat.TotalInsertions), 删除行总数: $($authorStat.TotalDeletions)"
    Add-Content -Path $csvFilePath -Value $line
}
    
