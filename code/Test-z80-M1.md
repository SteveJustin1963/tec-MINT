```
.engine mycomputer

    .include "constants.asm"
    .include "test.mac.asm"
    
    .include "IOSerial.asm"
    
    LD SP,DSTACK
    CALL initialize
    JP testsStart
    
    .include "MINT.asm"
    .include "ram.asm"
    
    .org $4000

testsStart:
    test "0\\(100)(200)",200
    test "1\\(100)(200)",100

    ; CALL enter
    ; .cstr "`Done!!`"
    ; HALT
    
    test "2 3<", 1
    test "3 3<", 0
    test "3 3>", 0
    test "4 3>", 1

    test "0",0
    test "1",1
    test "1 2+", 3
    test "123 456+", 579
    test "1_ 2+",1
    ; test "1_\\_",1
    test "1 2+",3
    test "1_ 2+",1
    test "1_~",0

    test "1 2 3 \\R'' ", 2
    test "\\^A",65

    test "3x! 1 x\\+ x@", 4
    test "3x! 1_ x\\+ x@", 2
    test ":X1; X", 1
    test "2x! x@", 2
    test ":Aa!; 3A a@", 3
    test ":Aa!; :Ba@; 4AB", 4

    test "100 0(6)", 100
    test "100 1(6)", 6
    test "2(6)+", 12
    test "1(\\i@)", 0
    test "1(1(\\i@ \\j@+))", 0
    test "2(2(\\i@ \\j@))+++++++", 4

    test "0\\(100)(200)",200
    test "1\\(100)(200)",100

    test "0t! 10(1t\\+) t@",10
    test "0t! 10(\\i@ 4>\\B \\i@ 1t\\+) t@",5
    test "100a! 1 a\\+ a@", 101

    test "[3] '@", 3
    test "[3] $ ' ", 1
    test "[1 2 3] $ @ ", 1
    test "[]", 0
    test "0t! [1 2 3] $ a! ( a@ \\i@ {+ @ t\\+ ) t@", 6
    test "\\h@ [1 2 3]'' \\h@ $ - ", 6

    test "\\[3] ' \\@", 3
    test "\\[3] $ ' ", 1
    test "\\[1 2 3] $ \\@ ", 1
    test "\\[]", 0
    test "\\h@ \\[1 2 3]'' \\h@ $ - ", 3
    
    CALL enter
    DB "0 t!"                           ; total = 0
    DB "[1 2 3 4 5]"                    ; declare array, returns address length
    DB "$ a!"                           ; store address in a, leave length
    DB "("                              ; loop
    DB      "a@ \\i@ {+ @"              ; access nth element
    DB      "t\\+"                         ; add to total
    DB ")"                              ; end loop
    DB "t@"                             ; print total
    DB 0
    expect "sum over array",15
    
    CALL enter
    .cstr "`Done!`"
    HALT
```
