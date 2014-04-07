#!/bin/bash
if [ -t 1 ]; then
    c_red=$(tput setaf 1)
    c_green=$(tput setaf 2)
    c_normal=$(tput sgr0)
fi
msg()
{
    rcode=$?
    if [ "$rcode" -eq 0 ]; then
        printf "%-60s ${c_green}OK$c_normal\n" "$*"
    else
        printf "%-60s ${c_red}FAIL$c_normal\n" "$*"
    fi
    return $rcode
}
smoke_test()
{
    [ -x "./$1" ]
    msg "smoke test ./$1"
}
genoutput()
{
    ./$1 < ./files/file1> ./files/$1.test1 
    ./$1 -w 4 ./files/file1> ./files/$1.test2
    ./$1 -w 5 -c  <./files/file1> ./files/$1.test3
    ./$1 < ./files/file2> ./files/$1.test4
    ./$1 -w 1 < ./files/file2> ./files/$1.test5
    ./$1 -w 1 -c ./files/file2> ./files/$1.test6
    ./$1 ./files/file3> ./files/$1.test7
    ./$1 -w 2 < ./files/file3 > ./files/$1.test8
    ./$1 -c -w 2 < ./files/file3 > ./files/$1.test9
    ./$1 < ./files/file4 > ./files/$1.test10
    ./$1 ./files/file5 1>./files/$1.test11 2> ./files/$1.err
}
testdiff()
{
    prefix="C"
    number=11;
    if [ "$1" = "fold2" ]; then
        prefix="C++"
        number=10;    
    fi
    for i in $(seq 1 $number); do
    diff ./files/correct.test$i ./files/$1.test$i > /dev/null
    msg "$prefix Test$i ${tests[$(($i-1))]}"
    done
    if [ "$1" = "fold" ]; then
       [ -s "./files/fold.err" ]
    else
       ! [ -s "./files/fold2.err" ]
    fi
    msg "$prefix Test$(($number+1)) testovanie stderr"
}
tests=("< ./files/file1" "-w 4 ./files/file1" "-w 5 -c <./files/file1" "< ./files/file2" "-w 1 < ./files/file2" "-w 1 -c ./files/file2" "./files/file3" "-w 2 < ./files/file3" "-c -w 2 < ./files/file3" "< ./files/file4" "./files/file5")
smoke_test fold && genoutput fold && testdiff fold
smoke_test fold2 && genoutput fold2 && testdiff fold2
