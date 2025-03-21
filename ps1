# 获取 git log 信息，格式为 --numstat，包含作者信息
$gitLog = git log --numstat --format="%an"

# 初始化变量
$currentAuthor = ""
$fileStats = @{}

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

        if (-not $fileStats.ContainsKey($file)) {
            $fileStats[$file] = @{
                Author       = $currentAuthor
                Insertions   = 0
                Deletions    = 0
            }
        }

        $fileStats[$file].Author = $currentAuthor
        $fileStats[$file].Insertions += $insertions
        $fileStats[$file].Deletions += $deletions
    }
}

# 输出结果
Write-Output "作者-文件-新增行-删除行"
foreach ($file in $fileStats.Keys) {
    $author = $fileStats[$file].Author
    $insertions = $fileStats[$file].Insertions
    $deletions = $fileStats[$file].Deletions
    Write-Output "$author-$file-$insertions-$deletions"
}    
