mint1
  
  ```
  .engine mycomputer

    .include "constants.asm"
    .include "IOSerial.asm"

    .macro testDefs
        ; 0 1 2 3 4 5 6 7 8 9 A B C D E F   ; hex digit to 7 segments stored in c
        DB "\\[#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47]' c!"
        DB "\\[0 0 0 0 0 0]' d!"                ; display buffer  

        DB ":A c@+ \\@;"                    ; char -- seg           convert char to 7segments
        DB ":B #0F& A $\\!;"                ; buf val --            read char from string convert to seg and write to buffer
        DB ":C }}}} $ 1- $;"                ; buf val -- buf' val'  rshift val 4 bits -- decrement buf ptr  
        DB ":D d@3+ $ 4(%%B C)'';"          ; val --                write 4 hex digits from val to buf

        DB ":E #40 | 1\\O;"                 ; dig --                write digit bit, keep bit 6 high
        DB ":F \\@ 2\\O;"                   ; buf --                output segment + digit info to LEDs
        DB ":G }$ 1+$;"                     ; buf dig -- buf' dig'  move to next segment, inc buf ptr
        DB ":H \\d@ #20 6(%%EF G)'' ;"      ; --                    display scan 6 digits

        DB ":J 10(\\i@ D 100(H)) 0E;"       ; --                    count to 10, convert, scan 100 times
    .endm
    
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
    testDefs
    
    tester "", "0 A", "#EB"
    tester "", "15 A", "#47"

    ; tester "", "?X\\@A", "#6E"    
    ; tester "", "d@ ?X D d@\\@", "#6E"    
    ; tester "", "d@ ?X DI", ""    

    ; tester "", "J\\P\\N", ""    

    .cstr "`Done!`"
    HALT
```
 
