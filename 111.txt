@echo off

REM 第一步: 调用 sqlcmd 执行 SELECT 查询并保存结果到变量
for /f "tokens=1,2 delims= " %%a in ('sqlcmd -S YourServerName -d YourDatabaseName -Q "select fieldA, fieldB from table1" -h -1 -s " "') do (
    set "originalFieldA=%%a"
    set "originalFieldB=%%b"
)

REM 第二步: 执行 UPDATE 操作
sqlcmd -S YourServerName -d YourDatabaseName -Q "update table1 set fieldA=1, fieldB=10"

REM 第三步: 调用 7-Zip 压缩目录 D:\abc
"C:\Program Files\7-Zip\7z.exe" a -tzip "D:\abc.zip" "D:\abc"

REM 第四步: 恢复原始值
sqlcmd -S YourServerName -d YourDatabaseName -Q "update table1 set fieldA=%originalFieldA%, fieldB=%originalFieldB%"

echo 操作完成
