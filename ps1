git log --pretty=format:"%an" --numstat | ForEach-Object -Begin {
    $authorStats = @{}
    $currentAuthor = $null
    $currentAdd = 0
    $currentDel = 0
} -Process {
    if ($_ -match '^(\d+|-)\s+(\d+|-)\s+') {
        # 处理文件变更行（累加当前提交的行数）
        $add = [int]($Matches[1] -replace '-', '0')
        $del = [int]($Matches[2] -replace '-', '0')
        $currentAdd += $add
        $currentDel += $del
    } else {
        # 处理作者行（保存当前提交的统计，并重置计数器）
        if ($currentAuthor) {
            if (-not $authorStats.ContainsKey($currentAuthor)) {
                $authorStats[$currentAuthor] = @{ Add = 0; Del = 0 }
            }
            $authorStats[$currentAuthor].Add += $currentAdd
            $authorStats[$currentAuthor].Del += $currentDel
        }
        $currentAuthor = $_
        $currentAdd = 0
        $currentDel = 0
    }
} -End {
    # 处理最后一个作者的统计
    if ($currentAuthor) {
        if (-not $authorStats.ContainsKey($currentAuthor)) {
            $authorStats[$currentAuthor] = @{ Add = 0; Del = 0 }
        }
        $authorStats[$currentAuthor].Add += $currentAdd
        $authorStats[$currentAuthor].Del += $currentDel
    }
    # 输出结果
    $authorStats.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Author = $_.Key
            Add    = $_.Value.Add
            Delete = $_.Value.Del
        }
    } | Sort-Object Author
}
