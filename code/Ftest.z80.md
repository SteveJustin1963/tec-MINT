mint v1

```
 .engine mycomputer

    .include "constants.asm"
    .include "IOSerial.asm"
    
    LD SP,DSTACK
    CALL initialize
    JP testsStart
    
    .include "MINT.asm"
    .include "ram.asm"
    .include "ftest.mac.asm"
    
    .org $4000
    
    testsStart:
    
    CALL enter
    utilDefs
    arrayDefs
    
    ; tester "", "0t! 10(\\i@ 4>\\B 1t\\+) t@","5"
    ; .cstr "`Done!`"
    ; HALT

    tester "odd",       ":O2/$ '; [1 2 3 4 5 6] ?O F H", "[1 3 5] H"
    tester "dup",       "1Q", "1 1"
    tester "nums",      "1 2 3", "1 2 3"
    tester "TE11p20",   "25(\\i@ 2\\O 1 30(Q #40 | 1\\O { #3F & Q0=('1))') #40 1\\O", ""
    tester "max",       ":G %%> \\(')($ '); 5 2 G", "5"
    tester "count",     ":C'1+; 0 [1 4 3 6 2] ?C R", "5"
    tester "sum",       ":P+; 0 [1 4 3 6 2] ?P R", "16"
    tester "greatest",  ":G %%> \\(')($ ') ; 1 [1 4 3 6 2] ?G R", "6"
    tester "least",     ":L %%< \\(')($ ') ; 1 [1 4 3 6 2] ?L R", "1"
    tester "double",    ":D {; [1 2 3] ?D M H", "[2 4 6] H"
    
    tester "", "#1#12#123#1234", "1 18 291 4660"
    tester "", "2 3<", "1"
    tester "", "3 3<", "0"
    tester "", "3 3>", "0"
    tester "", "4 3>", "1"

    tester "", "0","0"
    tester "", "1","1"
    tester "", "1 2+", "3"
    tester "", "123 456+", "579"
    tester "", "1_ 2+","1"
    ; tester "", "1_\\_","1"
    tester "", "1 2+","3"
    tester "", "1_ 2+","1"
    tester "", "1_~","0"

    tester "", "1 2 3 \\R'' ", "2"
    tester "", "\\^A","65"

    tester "", "3x! 1 x\\+ x@", "4"
    tester "", "3x! 1_ x\\+ x@", "2"
    tester "", ":X1; X", "1"
    tester "", "2x! x@", "2"
    tester "", ":Aa!; 3A a@", "3"
    tester "", ":Aa!; :Ba@; 4AB", "4"

    tester "", "100 0(6)", "100"
    tester "", "100 1(6)$ '", "6"
    tester "", "2(6)+", "12"
    tester "", "1(\\i@)", "0"
    tester "", "1(1(\\i@ \\j@+))", "0"
    tester "", "2(2(\\i@ \\j@))+++++++", "4"
    tester "", "0\\(100)(200)", "200"
    tester "", "1\\(100)(200)", "100"

    tester "", "0t! 10(1t\\+) t@", "10"
    tester "", "0t! 10(\\i@ 4>\\B 1t\\+) t@","5"
    tester "", "100a! 1 a\\+ a@", "101"

    tester "", "[3] '@", "3"
    tester "", "[3] $ ' ", "1"
    tester "", "[1 2 3] ' @ ", "1"
    tester "", "[]$ '", "0"
    tester "", "0t! [1 2 3] $ a! ( a@ \\i@ {+ @ t\\+ ) t@", "6"
    tester "", "\\h@ [1 2 3]'' \\h@ $ - ", "6"

    tester "", "\\[3] ' \\@", "3"
    tester "", "\\[3] $ ' ", "1"
    tester "", "\\[1 2 3] ' \\@ ", "1"
    tester "", "\\[]$ '", "0"
    tester "", "\\h@ \\[1 2 3]'' \\h@ $ - ", "3"

    DB ":A 0 t!"                           ; total = 0
    DB "[1 2 3 4 5]"                    ; declare array, returns address length
    DB "$ a!"                           ; store address in a, leave length
    DB "("                              ; loop
    DB      "a@ \\i@ {+ @"              ; access nth element
    DB      "t\\+"                         ; add to total
    DB ")"                              ; end loop
    DB "t@;"                             ; print total
    tester "", "A", "15"

    .cstr "`Done!`"
    HALT
```
    
