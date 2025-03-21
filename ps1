git log --pretty=format:"%an" --numstat | ForEach-Object {
    if ($_ -match '^(\d+|-)\s+(\d+|-)\s+') {
        # 处理数字行（新增/删除行）
        $add = [int]($Matches[1] -replace '-', '0')
        $del = [int]($Matches[2] -replace '-', '0')
        $script:currentAdd += $add
        $script:currentDel += $del
    } else {
        # 处理作者行
        if ($script:currentAuthor) {
            [PSCustomObject]@{
                Author = $script:currentAuthor
                Add    = $script:currentAdd
                Delete = $script:currentDel
            }
        }
        $script:currentAuthor = $_
        $script:currentAdd = 0
        $script:currentDel = 0
    }
} -End {
    if ($script:currentAuthor) {
        [PSCustomObject]@{
            Author = $script:currentAuthor
            Add    = $script:currentAdd
            Delete = $script:currentDel
        }
    }
} | Where-Object { $_.Add -ne 0 -or $_.Delete -ne 0 }
