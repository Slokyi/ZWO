# 定义 Git 仓库地址
$repoUrl = "your_git_repository_url"

# 拉取 Reg 分支到目录 a
if (-not (Test-Path -Path "a")) {
    New-Item -ItemType Directory -Path "a"
}
Set-Location -Path "a"
git init
git remote add origin $repoUrl
git fetch origin Reg
git checkout Reg
Set-Location -Path ..

# 拉取 master 分支到目录 b
if (-not (Test-Path -Path "b")) {
    New-Item -ItemType Directory -Path "b"
}
Set-Location -Path "b"
git init
git remote add origin $repoUrl
git fetch origin master
git checkout master
Set-Location -Path ..

# 统计文件差异
$filesA = Get-ChildItem -Path "a" -File -Recurse | Select-Object -ExpandProperty FullName
$filesB = Get-ChildItem -Path "b" -File -Recurse | Select-Object -ExpandProperty FullName

# 目录 a 有而目录 b 没有的文件
$filesOnlyInA = Compare-Object -ReferenceObject $filesA -DifferenceObject $filesB -PassThru | Where-Object { $_.SideIndicator -eq "<=" }
Write-Host "目录 a 有而目录 b 没有的文件:"
$filesOnlyInA

# 目录 b 有而目录 a 没有的文件
$filesOnlyInB = Compare-Object -ReferenceObject $filesA -DifferenceObject $filesB -PassThru | Where-Object { $_.SideIndicator -eq "=>" }
Write-Host "目录 b 有而目录 a 没有的文件:"
$filesOnlyInB

# 目录 a 和目录 b 都有但内容不一样的文件
$commonFiles = Compare-Object -ReferenceObject $filesA -DifferenceObject $filesB -ExcludeDifferent -IncludeEqual | Select-Object -ExpandProperty InputObject
$filesWithDifferentContent = @()
foreach ($file in $commonFiles) {
    $relativePath = $file.Replace("a\", "")
    $fileA = Join-Path -Path "a" -ChildPath $relativePath
    $fileB = Join-Path -Path "b" -ChildPath $relativePath
    if ((Get-Content -Path $fileA -Raw) -ne (Get-Content -Path $fileB -Raw)) {
        $filesWithDifferentContent += $fileA
    }
}
Write-Host "目录 a 和目录 b 都有但内容不一样的文件:"
$filesWithDifferentContent
