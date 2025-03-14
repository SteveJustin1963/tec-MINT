```
.engine mycomputer

    .include "constants.asm"
    .include "IOSerial.asm"

    .macro tec1Tables
        DB "\\["                            ; char to 7 segments
        ; sp ! " # $ % & ' ( ) * + , - . /
        DB "#00 #18 #00 #00 #00 #00 #00 #00 "
        DB "#00 #04 #10 #00 #00 #00 #00 #00 " 
        ; 0 1 2 3 4 5 6 7 8 9
        DB "#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F "
        ; : ; < = > ? @
        DB "#00 #00 #00 #00 #00 #00 #00 "
        ;  A B C D E F G H
        ;  I J K L M N O P  
        ;  Q R S T U V W X 
        ;  Y Z 
        DB " #6F #E6 #C3 #EC #C7 #47 #E3 #6E "
        DB " #28 #E8 #CE #C2 #6B #6B #EB #4F "
        DB " #2F #43 #A7 #46 #EA #E0 #EA #6E "
        DB " #AE #CD "           
        DB "]' c!"
        
        DB "\\[0 0 0 0 0 0]' d!"            ; display buffer  
    .endm  
    
    .macro tec1Defs
        DB ":A #20 - c@+ \\@;"              ; char -- seg           convert char to 7segments
        DB ":B \\@A$\\!;"                   ; buf str --            read char from string convert to seg and write to buffer
        DB ":C 1+$1+$;"                     ; buf str -- buf' str'  increment str ptr and buf ptr  
        DB ":D 6(%%B C)'';"                 ; buf str --            copy 6 chars from str to seg buffer

        DB ":E #40 |1\\O;"                  ; dig --                write digit bit, keep bit 6 high
        DB ":F \\@2\\O;"                    ; buf --                output segment + digit info to LEDs
        DB ":G }$1+$;"                      ; buf dig -- buf' dig'  move to next segment, inc buf ptr
        DB ":H \\d@ #20 6(%%EF G)'' ;"      ; --                    display scan 6 digits
        DB ":I 100(H) 0E;"                  ; --                    scan 255 times, then reset digit bit to 0
        DB ":J d@ ?X 3(%% \\i@+ DI)'';"    
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
    tec1Tables
    tec1Defs
    
    DB ":XHELLO THERE ITS ME AGAIN!              ;"
    tester "", "10000() #41 #20 - c@ + \\@", "#6F"
    tester "", "72A", "#6E"
    tester "", "?X\\@A", "#6E"    
    tester "", "d@ ?X D d@\\@", "#6E"    
    tester "", "d@ ?X DI", ""    
    tester "", "J\\P\\N", ""    

    .cstr "`Done!`"
    HALT

```
