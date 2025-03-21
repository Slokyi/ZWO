git log --pretty=format:"%an" --numstat | awk '
    BEGIN { author=""; add=0; del=0 }
    /^[0-9-]/ { add += $1 == "-" ? 0 : $1; del += $2 == "-" ? 0 : $2 }
    /^[^0-9]/ { 
        if (author != "") print author, add, del; 
        author=$0; add=0; del=0 
    }
    END { print author, add, del }
' | grep -v " 0 0$"




git log --pretty=format:"%an" --numstat | awk '
    /^[0-9-]/ { add[$author] += $1 == "-" ? 0 : $1; del[$author] += $2 == "-" ? 0 : $2 }
    /^[^0-9]/ { author=$0 }
    END { for (a in add) print a, add[a], del[a] }
'
