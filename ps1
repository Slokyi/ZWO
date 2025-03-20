1.根据用户名时间段统计

git log --author="username" --since=2018-01-01 --until=2019-12-31 --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -

2.查看提交者排名前N位

git log --pretty='%aN' | sort | uniq -c | sort -k1 -n -r | head -n 5

3.提交数统计

git log --oneline | wc -l

4.根据用户名统计

git log --author="username" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -

5.根据时间段统计

git log --since=2020-01-01 --until=2021-02-04 --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }'

6.统计每个人的增删行数

git log --format='%aN' | sort -u | while read name; do echo -en "$name\t"; git log --author="$name" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s ", add, subs, loc }' -; done

7.贡献者统计

git log --pretty='%aN' | sort -u | wc -l

8.根据时间段排除文件夹统计

git log --since=2021-01-28 --until=2021-02-03 --pretty=tformat: --numstat -- . ":(exclude)src/test" | awk '{ add += $1; subs += $2; loc += $1 + $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }'

-- . ":(exclude)folderName"  folderName指src/test文件夹，这里是相对路径

-- . ":(exclude)folderName1"  ":(exclude)folderName2"  排除多个文件夹

-- . ":(exclude)folderName"也 可以用在其他的统计中；--前只能有一个空格，有多个空格识别不了

 9.根据指定文件夹统计

git log --since=2021-06-24 --until=2021-06-30 --pretty=tformat: --numstat | grep src/test | gawk '{ add += $1; subs += $2; loc += $1 + $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }'

src/test 指定src的test目录下

注意：增删也算统计的代码量就修改loc += $1 + $2

10.代码存量
find . -name *\.java  -exec wc -l  {} \; | awk '{s+=$1}END{print s}'
