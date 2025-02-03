 

 
### 1. ARITHMETIC OPERATIONS
#### `+` Add top two stack values
Here's where the addition operation `+` is implemented in the code:

```assembly
; In the IOPCODES table, + is mapped:
01CF   4F                     DB   lsb(plus_)   ;   +

; The actual PLUS routine:
PLUS_:       ; add the top 2 members of the stack
044F   D1                     POP   de         ; Get first number
0450   E1                     POP   hl         ; Get second number
0451   19                     ADD   hl,de      ; Add them
0452   E5                     PUSH   hl        ; Push result
0453   C3 C6 03               JP   carry      ; Handle any carry
```

The operation:
1. POPs first value into DE register
2. POPs second value into HL register
3. Adds HL and DE together
4. Pushes result back onto stack
5. Checks for carry flag

So if you do:
```
3 4 +
```
It will:
1. Pop 4 into DE
2. Pop 3 into HL
3. Add them (HL = HL + DE)
4. Push result (7) back on stack

The carry jump at the end handles any overflow from the addition.


#### `-` Subtract top stack value from second value
Here's where subtraction `-` is implemented in the code:

```assembly
; In the IOPCODES table, - is mapped:
01D1   96                     DB   lsb(minus_)   ;   -

; The actual MINUS routine:
MINUS_:      ; Subtract the value 2nd on stack from top of stack
0496   03                     INC   bc   ; check if sign of a number
0497   0A                     LD   a,(bc)   
0498   0B                     DEC   bc   
0499   FE 30                  CP   "0"   
049B   38 05                  JR   c,sub1   
049D   FE 3A                  CP   "9"+1   
049F   DA 3E 07               JP   c,num   

SUB1:        
04A2   D1                     POP   de         ; Get first number
04A3   E1                     POP   hl         ; Get second number
04A4   SUB2:        
04A4   A7                     AND   A          ; Clear carry flag
04A5   ED 52                  SBC   hl,de      ; Subtract hl = hl - de
04A7   E5                     PUSH   hl        ; Push result
04A8   C3 C6 03               JP   carry       ; Handle carry flag
```

The operation:
1. Checks if it's part of a number input first
2. If not a number:
   - POPs first value into DE register
   - POPs second value into HL register
   - Clears carry flag
   - Subtracts DE from HL
   - Pushes result back onto stack
   - Updates carry flag

So if you do:
```
5 3 -
```
It will:
1. Pop 3 into DE
2. Pop 5 into HL
3. Subtract (HL = HL - DE)
4. Push result (2) back on stack

The initial number check is there because '-' can also be used for negative numbers.

#### `*` Multiply top two stack values
Here's where multiplication `*` is implemented in the code:

```assembly
; In the IOPCODES table, * is mapped:
01CE   F0                     DB   lsb(star_)   ;   *

; The actual multiplication code:
MUL:         ; Called by STAR_
056A   D1                     POP   de         ; de = 2nd arg
056B   E1                     POP   hl         ; hl = 1st arg
056C   C5                     PUSH   bc        ; save IP
056D   7D                     LD   a,l   
056E   4C                     LD   c,h   
056F   06 10                  LD   b,16        ; 16-bit multiplication
0571   21 00 00               LD   hl,0        ; clear result
0574                MUL1:        
0574   29                     ADD   hl,hl      ; shift left
0575   17                     RLA      
0576   CB 11                  RL   c   
0578   30 07                  JR   nc,mul2   
057A   19                     ADD   hl,de      ; add if bit was 1
057B   CE 00                  ADC   a,0   
057D   D2 81 05               JP   nc,mul2   
0580   0C                     INC   c   
0581                MUL2:        
0581   10 F1                  DJNZ   mul1      ; loop 16 times
0583   EB                     EX   de,hl       ; de = lsw result
0584   61                     LD   h,c   
0585   6F                     LD   l,a         ; hl = msw result
0586   C1                     POP   bc         ; restore IP
0587   C3 F8 07               JP   divExit     ; pushes lsw, puts msw in vRemain
```

This implements 16-bit multiplication. When you use `*`, it:

1. Pops two values from stack
2. Does 16-bit multiplication algorithm:
   - Uses shift and add method
   - Processes 16 bits
   - Handles overflow into 32-bit result
3. Pushes lower 16 bits of result onto stack
4. Stores upper 16 bits in remainder variable

So if you do:
```
4 5 *
```
It will:
1. Pop 5 and 4
2. Multiply them
3. Push 20 (result) onto stack

Note: This can handle 16-bit by 16-bit multiplication, producing up to 32-bit results.

#### `/` Divide second value by top value
Here's where division `/` is implemented in the code:

```assembly
; In the IOPCODES table, / can map to division or alternate command:
01D3   F2                     DB   lsb(slash_)   ;   /  

; The actual division code:
DIV:                ; Called if not alternate command
07B7   60 69                  LD   hl,bc   ; hl = IP
07B9   C1                     POP   bc   ; bc = denominator
07BA   E3                     EX   (sp),hl   ; save IP, hl = numerator
07BB   7C                     LD   a,h   
07BC   A8                     XOR   b   
07BD   F5                     PUSH   af   
07BE   A8                     XOR   b   
07BF   F2 C8 07               JP   p,absbc   
07C2                             ;absHL
07C2   AF                     XOR   a   
07C3   95                     SUB   l   
07C4   6F                     LD   l,a   
07C5   9F                     SBC   a,a   
07C6   94                     SUB   h   
07C7   67                     LD   h,a   

; Division loop:
07DB                LOOP1:       
07DB   09                     ADD   hl,bc   ;--
07DC                LOOP2:       
07DC   3D                     DEC   a   ;4
07DD   28 0E                  JR   z,EndSDiv   ;12|7
...
07F8                DIVEXIT:      
07F8   D5                     PUSH   de   ; quotient
07F9   22 8A 13               LD   (vRemain),hl   ; remainder
07FC   FD E9                  JP   (iy)   
```

When you use `/` for division, it:
1. Gets two values from stack (dividend and divisor)
2. Performs division using a shift and subtract algorithm 
3. Pushes quotient onto stack
4. Stores remainder in vRemain variable

So if you do:
```
20 5 /
```
It will:
1. Pop 5 (divisor)
2. Pop 20 (dividend)
3. Divide: 20 ÷ 5
4. Push 4 (quotient) onto stack
5. Store 0 (remainder) in vRemain

The code handles:
- Sign of result based on operands
- Division by converting to positive numbers first
- Stores both quotient and remainder

If it's not a division operation (starts with / but followed by letter), it becomes an alternate command instead.


#### `{` Left shift (multiply by 2)
Here's where left shift `{` is implemented in the code:

```assembly
; In the IOPCODES table:
01EA   87                     DB   lsb(lbrace_)   ;    {

; The actual LBRACE routine:
LBRACE_:      ;  Left shift { is multiply by 2	
0487   E1                     POP   hl         ; Get number from stack
0488   29                     ADD   hl,hl      ; Shift left (multiply by 2)
0489   18 AA                  JR   and2        ; Jump to push result back

AND2:        
0435   E5                     PUSH   hl        ; Push result onto stack
0436   FD E9                  JP   (iy)        ; Next instruction
```

When you use `{`, it:
1. Pops a value from stack into HL
2. Shifts it left (ADD HL,HL = multiply by 2)
3. Pushes result back onto stack

So if you do:
```
5 {
```
It will:
1. Pop 5
2. Multiply by 2 (shift left)
3. Push 10 back onto stack

This is a fast way to multiply by 2 using a left shift operation rather than full multiplication.

#### `}` Right shift (divide by 2)
Here's where right shift `}` is implemented in the code:

```assembly
; In the IOPCODES table:
01EC   8B                     DB   lsb(rbrace_)   ;    }

; The actual RBRACE routine:
RBRACE_:      ;  Right shift } is a divide by 2		
048B   E1                     POP   hl         ; Get the top member of the stack
048C                SHR1:        
048C   CB 3C                  SRL   H          ; Shift right H register
048E   CB 1D                  RR   L           ; Rotate right L register
0490   18 A3                  JR   and2        ; Jump to push result

AND2:        
0435   E5                     PUSH   hl        ; Push result back onto stack
0436   FD E9                  JP   (iy)        ; Next instruction
```

When you use `}`, it:
1. Pops a value from stack into HL
2. Shifts H register right (SRL H)
3. Rotates L register right (RR L)
4. Pushes result back onto stack

So if you do:
```
10 }
```
It will:
1. Pop 10
2. Divide by 2 (shift right)
3. Push 5 back onto stack

This is a fast way to divide by 2 using a right shift operation rather than full division.




### 2. STACK MANIPULATION

#### `"` Duplicate top stack value
Here's where duplicate `"` is implemented in the code:

```assembly
; In the IOPCODES table:
01C6   71                     DB   lsb(dquote_)   ;   "

; The actual DQUOTE routine:
DQUOTE_:      
0471   E1                     POP   hl         ; Duplicate the top member of the stack
0472   E5                     PUSH   hl        ; Push it back
0473   E5                     PUSH   hl        ; Push it again
0474   FD E9                  JP   (iy)        ; Next instruction
```

When you use `"`, it:
1. POPs top value into HL
2. PUSHes it back twice

So if you do:
```
5 "
```
The stack will contain:
```
5 5
```

It's a simple way to duplicate the top value on the stack. The sequence:
1. Pop top value (5) into HL
2. Push HL (5) back
3. Push HL (5) again
4. Result is two copies of the value on stack

#### `%` Duplicate second stack element
Here's where duplicate second element `%` is implemented in the code:

```assembly
; In the IOPCODES table:
01C9   79                     DB   lsb(percent_)   ;   %

; The actual PERCENT routine:
PERCENT_:      
0479   E1                     POP   hl         ; Pop top value
047A   D1                     POP   de         ; Pop second value
047B   D5                     PUSH   de        ; Push second value back
047C   E5                     PUSH   hl        ; Push top value back
047D   D5                     PUSH   de        ; Push second value again
047E   FD E9                  JP   (iy)        ; Next instruction
```

When you use `%`, it:
1. POPs top value into HL
2. POPs second value into DE
3. PUSHes second value (DE)
4. PUSHes top value (HL)
5. PUSHes second value again (DE)

So if you do:
```
3 5 %
```
The stack will become:
```
3 5 3
```

The sequence:
1. Pop 5 into HL
2. Pop 3 into DE
3. Push DE (3)
4. Push HL (5)
5. Push DE (3) again
6. Result is original second value duplicated on top

#### `$` Swap top two stack elements
Here's where swap `$` is implemented in the code:

```assembly
; In the IOPCODES table:
01C8   92                     DB   lsb(dollar_)   ;   $

; The actual DOLLAR routine:
DOLLAR_:      ; $ swap                    ; a b -- b a Swap the top 2 elements of the stack
0492   E1                     POP   hl         ; Get first value
0493   E3                     EX   (SP),hl     ; Swap with second value
0494   18 9F                  JR   and2        ; Jump to push first value back

AND2:        
0435   E5                     PUSH   hl        ; Push result back onto stack
0436   FD E9                  JP   (iy)        ; Next instruction
```

When you use `$`, it:
1. POPs top value into HL
2. EXchanges HL with value at top of stack
3. PUSHes HL back

So if you do:
```
3 5 $
```
The stack will become:
```
5 3
```

The sequence:
1. Pop 5 into HL
2. Exchange HL with 3 on stack
3. Push HL (which now has 3)
4. Result is values swapped

#### `'` Discard top stack value
Here's where discard `'` (quote) is implemented in the code:

```assembly
; In the IOPCODES table:
01CB   00                     DB   lsb(quote_)   ;   '

; The actual QUOTE routine:
QUOTE_:      ; Discard the top member of the stack
0400   E1                     POP   hl         ; Remove top value
0401                AT_:         
0401                UNDERSCORE_:      
0401   FD E9                  JP   (iy)        ; Next instruction
```

When you use `'`, it:
1. POPs top value into HL (discarding it)
2. Goes to next instruction without pushing anything back

So if you do:
```
3 5 '
```
The stack will become:
```
3
```

The sequence:
1. Pop 5 into HL
2. Don't push anything back
3. Result is top value removed from stack

It's a simple way to drop/discard the top value from the stack.

#### `??????` Rotate (a b c -- b c a)
use other commands to construct


### 3. BITWISE OPERATIONS

#### `&` Bitwise AND
Here's where bitwise AND `&` is implemented in the code:

```assembly
; In the IOPCODES table:
01CA   2D                     DB   lsb(amper_)   ;   &

; The actual AMPER routine:
AMPER_:      ;     Bitwise and the top 2 elements of the stack
042D   D1                     POP   de         ; Get first value
042E   E1                     POP   hl         ; Get second value
042F   7B                     LD   a,E         ; Get low byte of first
0430   A5                     AND   L          ; AND with low byte of second
0431   6F                     LD   L,A         ; Store result in L
0432   7A                     LD   a,D         ; Get high byte of first
0433   A4                     AND   H          ; AND with high byte of second
0434                AND1:        
0434   67                     LD   h,a         ; Store result in H
0435                AND2:        
0435   E5                     PUSH   hl        ; Push result onto stack
0436   FD E9                  JP   (iy)        ; Next instruction
```

When you use `&`, it:
1. POPs first value into DE
2. POPs second value into HL
3. ANDs the lower bytes together
4. ANDs the upper bytes together
5. PUSHes combined 16-bit result back onto stack

So if you do:
```
%1111 %1010 &
```
It will AND the bits together:
```
1111 & 1010 = 1010
```

Performs a 16-bit bitwise AND between the top two stack values.

#### `|` Bitwise OR
Here's where bitwise OR `|` is implemented in the code:

```assembly
; In the IOPCODES table:
01EB   38                     DB   lsb(pipe_)   ;    |

; The actual PIPE routine:
PIPE_:       ; Bitwise or the top 2 elements of the stack
0438   D1                     POP   de         ; Get first value
0439   E1                     POP   hl         ; Get second value
043A   7B                     LD   a,E         ; Get low byte of first
043B   B5                     OR   L           ; OR with low byte of second
043C   6F                     LD   L,A         ; Store result in L
043D   7A                     LD   a,D         ; Get high byte of first
043E   B4                     OR   h           ; OR with high byte of second
043F   18 F3                  JR   and1        ; Jump to store H and push result

AND1:        
0434   67                     LD   h,a         ; Store result in H
0435                AND2:        
0435   E5                     PUSH   hl        ; Push result onto stack
0436   FD E9                  JP   (iy)        ; Next instruction
```

When you use `|`, it:
1. POPs first value into DE
2. POPs second value into HL
3. ORs the lower bytes together
4. ORs the upper bytes together
5. PUSHes combined 16-bit result back onto stack

So if you do:
```
%1010 %0101 |
```
It will OR the bits together:
```
1010 | 0101 = 1111
```

Performs a 16-bit bitwise OR between the top two stack values.


#### `^` Bitwise XOR
Here's where bitwise XOR `^` is implemented in the code:

```assembly
; In the IOPCODES table:
01E4   41                     DB   lsb(caret_)   ;    ^

; The actual CARET routine:
CARET_:      ; Bitwise XOR the top 2 elements of the stack
0441   D1                     POP   de         ; Get first value
0442                XOR1:        
0442   E1                     POP   hl         ; Get second value
0443   7B                     LD   a,E         ; Get low byte of first
0444   AD                     XOR   L          ; XOR with low byte of second
0445   6F                     LD   L,A         ; Store result in L
0446   7A                     LD   a,D         ; Get high byte of first
0447   AC                     XOR   H          ; XOR with high byte of second
0448   18 EA                  JR   and1        ; Jump to store H and push result

AND1:        
0434   67                     LD   h,a         ; Store result in H
0435                AND2:        
0435   E5                     PUSH   hl        ; Push result onto stack
0436   FD E9                  JP   (iy)        ; Next instruction
```

When you use `^`, it:
1. POPs first value into DE
2. POPs second value into HL
3. XORs the lower bytes together
4. XORs the upper bytes together
5. PUSHes combined 16-bit result back onto stack

So if you do:
```
%1111 %1010 ^
```
It will XOR the bits together:
```
1111 ^ 1010 = 0101
```

Performs a 16-bit bitwise XOR between the top two stack values.

#### `~` Bitwise invert
Here's where bitwise invert `~` is implemented in the code:

```assembly
; In the IOPCODES table:
01ED   4A                     DB   lsb(tilde_)   ;    ~

; The actual TILDE/INVERT routine:
TILDE_:      
INVERT:      ; Bitwise INVert the top member of the stack
044A   11 FF FF               LD   de,$FFFF    ; Load $FFFF for XOR
044D   18 F3                  JR   xor1        ; Jump to XOR routine

XOR1:        ; The XOR routine used to invert
0442   E1                     POP   hl         ; Get value to invert
0443   7B                     LD   a,E         ; Get $FF
0444   AD                     XOR   L          ; XOR low byte with $FF
0445   6F                     LD   L,A         ; Store result in L
0446   7A                     LD   a,D         ; Get $FF
0447   AC                     XOR   H          ; XOR high byte with $FF
0448   18 EA                  JR   and1        ; Jump to store and push result
```

When you use `~`, it:
1. POPs value to invert from stack into HL
2. XORs with $FFFF (which inverts all bits)
3. PUSHes inverted result back onto stack

So if you do:
```
%1010 ~
```
It will invert all bits:
```
1010 inverted becomes 0101
```

Performs a 16-bit bitwise inversion (NOT) of the top stack value.

### 4. COMPARISON OPERATIONS
#### `<` Less than
Here's where less than `<` is implemented in the code:

```assembly
; In the IOPCODES table:
01D9   BA                     DB   lsb(lt_)   ;    

; The actual LT (less than) routine:
LT_:         
04BA   D1                     POP   de         ; Get first number
04BB   E1                     POP   hl         ; Get second number
04BC                LT1_:        
04BC   B7                     OR   a           ; Reset carry flag
04BD   ED 52                  SBC   hl,de      ; Subtract DE from HL
04BF   DA E2 03               JP   c,true_     ; If carry (HL < DE) then true
04C2   C3 DD 03               JP   false_      ; Otherwise false

TRUE_:       
03E2   21 FF FF               LD   hl,TRUE     ; Load TRUE ($FFFF)
03E5   E5                     PUSH   hl        ; Push result
03E6   FD E9                  JP   (iy)        ; Next instruction

FALSE_:      
03DD   21 00 00               LD   hl,FALSE    ; Load FALSE ($0000)
03E0   18 03                  JR   true1       ; Jump to push result
```

When you use `<`, it:
1. POPs first value into DE
2. POPs second value into HL
3. Subtracts DE from HL
4. If result has carry (HL < DE):
   - Pushes TRUE ($FFFF)
5. Otherwise:
   - Pushes FALSE ($0000)

So if you do:
```
3 5 
```
It will:
1. Pop 5 into DE
2. Pop 3 into HL
3. 3 < 5 is true, so pushes $FFFF (TRUE)

The operation performs a signed 16-bit comparison, returning TRUE if second value is less than first value.

#### `=` Equal to
Here's where equal to `=` is implemented in the code:

```assembly
; In the IOPCODES table:
01DA   AB                     DB   lsb(eq_)   ;    =

; The actual EQ routine:
EQ_:         
04AB   E1                     POP   hl         ; Get first number
04AC   D1                     POP   de         ; Get second number
04AD   B7                     OR   a           ; Reset carry flag
04AE   ED 52                  SBC   hl,de      ; Subtract HL = HL - DE
04B0   CA E2 03               JP   z,true_     ; If zero (equal) then true
04B3   C3 DD 03               JP   false_      ; Otherwise false

TRUE_:       
03E2   21 FF FF               LD   hl,TRUE     ; Load TRUE ($FFFF)
03E5   E5                     PUSH   hl        ; Push result
03E6   FD E9                  JP   (iy)        ; Next instruction

FALSE_:      
03DD   21 00 00               LD   hl,FALSE    ; Load FALSE ($0000)
03E0   18 03                  JR   true1       ; Jump to push result
```

When you use `=`, it:
1. POPs first value into HL
2. POPs second value into DE
3. Subtracts DE from HL
4. If result is zero (values were equal):
   - Pushes TRUE ($FFFF)
5. Otherwise:
   - Pushes FALSE ($0000)

So if you do:
```
5 5 =
```
It will:
1. Pop 5 into HL
2. Pop 5 into DE
3. 5 = 5 is true, so pushes $FFFF (TRUE)

The operation performs a 16-bit comparison, returning TRUE if the values are equal.

#### `>` Greater than
Here's where greater than `>` is implemented in the code:

```assembly
; In the IOPCODES table:
01DB   B6                     DB   lsb(gt_)   ;    >

; The actual GT routine:
GT_:         
04B6   E1                     POP   hl         ; Get first number
04B7   D1                     POP   de         ; Get second number
04B8   18 02                  JR   lt1_        ; Jump to comparison

LT1_:        
04BC   B7                     OR   a           ; Reset carry flag
04BD   ED 52                  SBC   hl,de      ; Subtract DE from HL
04BF   DA E2 03               JP   c,true_     ; If carry then true
04C2   C3 DD 03               JP   false_      ; Otherwise false

TRUE_:       
03E2   21 FF FF               LD   hl,TRUE     ; Load TRUE ($FFFF)
03E5   E5                     PUSH   hl        ; Push result
03E6   FD E9                  JP   (iy)        ; Next instruction

FALSE_:      
03DD   21 00 00               LD   hl,FALSE    ; Load FALSE ($0000)
03E0   18 03                  JR   true1       ; Jump to push result
```

When you use `>`, it:
1. POPs first value into HL
2. POPs second value into DE
3. Uses same comparison code as `<` but with operands swapped
4. If result has carry:
   - Pushes TRUE ($FFFF)
5. Otherwise:
   - Pushes FALSE ($0000)

So if you do:
```
5 3 >
```
It will:
1. Pop 3 into HL
2. Pop 5 into DE
3. 5 > 3 is true, so pushes $FFFF (TRUE)

The operation performs a signed 16-bit comparison, returning TRUE if second value is greater than first value.

### 5. MEMORY AND VARIABLES

#### `!` Store value at address
Here's where store value `!` (bang) is implemented in the code:

```assembly
; In the IOPCODES table:
01C5   1D                     DB   lsb(bang_)   ;   !

; The actual BANG/ASSIGN routine:
BANG_:       ; Store the value at the address placed on the top of the stack
ASSIGN:      
041D   E1                     POP   hl         ; Discard value of last accessed variable
041E   D1                     POP   de         ; Get new value
041F   2A 9C 13               LD   hl,(vPointer)  ; Get variable address
0422   73                     LD   (hl),e      ; Store low byte
0423   3A 6A 13               LD   a,(vByteMode)  ; Check if byte mode
0426   3C                     INC   a          ; Is it byte?
0427   28 02                  JR   z,assign1   ; If byte mode, skip high byte
0429   23                     INC   hl         ; Point to high byte
042A   72                     LD   (hl),d      ; Store high byte
042B                ASSIGN1:      
042B   18 A7                  JR   resetByteMode  ; Reset byte mode and return
```

When you use `!`, it:
1. POPs address from stack
2. POPs value to store from stack
3. Checks byte mode:
   - If byte mode: stores only low byte
   - If word mode: stores both bytes
4. Resets byte mode

So if you do:
```
42 x !    ( Store 42 in variable x )
```
It will:
1. Pop address of x
2. Pop value 42
3. Store 42 at x's address

The operation handles both byte and word storage based on byte mode setting.


#### `a-z` Variable access (26 variable slots)
Here's where variable access (a-z) is implemented in the code:

```assembly
; In the IOPCODES table:
01E7   9A                     DB   (26 | $80)   ; a b c .....z
01E8   05                     DB   lsb(var_)   

; The actual VAR routine:
VAR_:        
0405   0A                     LD   a,(bc)      ; Get variable name (a-z)
0406   21 00 13               LD   hl,vars     ; Point to variables area
0409   CD 30 03               CALL   lookupRef  ; Calculate variable address

VAR1:        
040C   22 9C 13               LD   (vPointer),hl   ; Save var address for later
040F   16 00                  LD   d,0   
0411   5E                     LD   e,(hl)      ; Get low byte
0412   3A 6A 13               LD   a,(vByteMode)  ; Check byte mode
0415   3C                     INC   a          ; Is it byte mode?
0416   28 02                  JR   z,var2      ; If yes, skip high byte
0418   23                     INC   hl         ; Point to high byte
0419   56                     LD   d,(hl)      ; Get high byte

VAR2:        
041A   D5                     PUSH   de        ; Push value onto stack
041B   18 B7                  JR   resetByteMode  ; Reset byte mode and return
```

Variables are allocated in memory:
```assembly
; Variable storage area:
1300                VARS:     DS   VARS_SIZE   ; 26*2 bytes for a-z
```

When you use a variable (a-z), it:
1. Gets the variable letter (a-z)
2. Calculates offset in VARS area
3. Retrieves value:
   - In byte mode: gets one byte
   - In word mode: gets two bytes
4. Pushes value onto stack
5. Saves variable address for potential later store (!)

So if you do:
```
42 a !    ( Store 42 in a )
a        ( Get value of a - pushes 42 )
```

Each variable (a-z) has a 2-byte slot available for storage, and the byte/word mode affects how many bytes are accessed.

#### `\` Set byte mode

Here's where set byte mode `\` (backslash) is implemented in the code:

```assembly
; In the IOPCODES table:
01E2   03                     DB   lsb(bslash_)   ;    \

; The actual BSLASH routine:
BSLASH_:      
0403   18 CB                  JR   setByteMode   ; Jump to set byte mode

SETBYTEMODE:      
03D0   3E FF                  LD   a,$FF       ; Load $FF for true
03D2   18 01                  JR   assignByteMode  

ASSIGNBYTEMODE:      
03D5   32 6A 13               LD   (vByteMode),a   ; Store byte mode flag
03D8   32 6B 13               LD   (vByteMode+1),a   
03DB   FD E9                  JP   (iy)        ; Next instruction
```

When you use `\`, it:
1. Sets vByteMode flag to $FF (TRUE)
2. This affects subsequent variable operations:
   - Variable access will only read/write single bytes
   - Stays in effect until reset

vByteMode is reset by many operations including:
```assembly
RESETBYTEMODE:      
03D4   AF                     XOR   a          ; Clear A to 0
03D5   32 6A 13               LD   (vByteMode),a   ; Reset byte mode flag
```

So if you do:
```
\ 42 a !   ( Store byte 42 in a )
```
Only one byte will be stored instead of two.

This allows you to switch between byte and word operations for variable access.

#### `?` Array access
Here's where array access `?` is implemented in the code:

```assembly
; In the IOPCODES table:
01DC   EC                     DB   lsb(question_)   ;    ?

; The actual ARRACCESS routine:
ARRACCESS:      
053E   E1                     POP   hl         ; hl = index
053F   D1                     POP   de         ; de = array address
0540   3A 6A 13               LD   a,(vByteMode)  ; Check byte/word mode
0543   3C                     INC   a   
0544   28 01                  JR   z,arrAccess1   ; If byte mode, skip index doubling
0546   29                     ADD   hl,hl      ; If word mode, double index (2 bytes per element)

ARRACCESS1:      
0547   19                     ADD   hl,de      ; hl = addr + index
0548   C3 0C 04               JP   var1        ; Get value at calculated address
```

When you use `?`, it:
1. POPs index value
2. POPs array base address
3. Checks byte/word mode:
   - In word mode: doubles index (2 bytes per element)
   - In byte mode: uses index as-is
4. Adds index to base address
5. Gets value at calculated address

So if you do:
```
arr 5 ?    ( Get 5th element from array 'arr' )
```
It will:
1. Calculate address = array_base + (index * element_size)
2. Push value at that address

The byte/word mode affects whether it treats array elements as 1 or 2 bytes.

#### `/V` Get last variable access address
Here's where get last variable access `/V` is implemented in the code:

```assembly
; In the IALTCODES table:
0204   90     DB   lsb(varAccess_)   ;V      address of last access

; The actual VARACCESS routine:
VARACCESS_:      
0690   21 9C 13               LD   hl,vPointer  ; Point to last accessed variable address
0693   5E                     LD   e,(hl)       ; Get low byte
0694   23                     INC   hl   
0695   56                     LD   d,(hl)       ; Get high byte
0696   D5                     PUSH   de         ; Push address onto stack
0697   FD E9                  JP   (iy)         ; Next instruction
```

When you use `/V`, it:
1. Gets address stored in vPointer (set by last variable access)
2. Pushes that address onto stack

vPointer is updated whenever you access a variable:
```assembly
VAR1:        
040C   22 9C 13               LD   (vPointer),hl   ; Save var address when accessing variable
```

So if you do:
```
a           ( Access variable 'a' )
/V          ( Get address where 'a' is stored )
```

This is useful when you need to know where a variable is stored in memory. The returned address can be used with `!` to store values directly to that location.


### 6. PROGRAM FLOW
#### `:` Begin definition
Here's where begin definition `:` is implemented in the code:

```assembly
; In the IOPCODES table:
01D7   E6                     DB   lsb(colon_)   ;    :

; The actual DEF (definition) routine:
DEF:         ; Create a colon definition
0711   03                     INC   bc          ; Next character
0712   0A                     LD   a,(bc)       ; Get the next character
0713   FE 40                  CP   "@"          ; Is it anonymous (@)?
0715   20 08                  JR   nz,def0      ; No, normal named definition
0717   03                     INC   bc   
0718   ED 5B 76 13            LD   de,(vHeapPtr)  ; Return start of definition
071C   D5                     PUSH   de   
071D   18 0E                  JR   def1   

DEF0:        ; Named definition
071F   32 9A 13               LD   (vLastDef),a   ; Save name of definition
0722   CD 29 03               CALL   lookupRef0   ; Get definition address
0725   ED 5B 76 13            LD   de,(vHeapPtr)  ; Start of definition
0729   73                     LD   (hl),E         ; Save low byte of address
072A   23                     INC   hl   
072B   72                     LD   (hl),D         ; Save high byte of address
072C   03                     INC   bc   

DEF1:        ; Store definition body
072D   0A                     LD   a,(bc)         ; Get the next character
072E   03                     INC   bc            ; Point to next character
072F   12                     LD   (de),A         ; Store character
0730   13                     INC   de   
0731   FE 3B                  CP   ";"            ; Is it a semicolon?
0733   28 02                  JR   Z,def2         ; End the definition
0735   18 F6                  JR   def1           ; Get the next element
```

When you use `:`, it:
1. Checks next character:
   - If '@': makes anonymous definition
   - Otherwise: uses character as definition name
2. Stores definition start address
3. Copies definition body into heap until ';' is found

So if you do:
```
: T 123 ;     ( Define T to put 123 on stack )
```
It will:
1. Store 'T' as name
2. Store code "123" in heap
3. End definition at ';'

After this you can use 'T' as a command which will put 123 on the stack.

- `;` End definition/return
- `(` Begin loop
- `)` End loop
- `/E` Else condition
- `/F` False condition
- `/T` True condition
- `/U` Unlimited loop
- `/W` While condition
- `/G` Execute MINT code
- `/X` Execute machine code

### 7. ARRAY OPERATIONS
- `[` Begin array definition
- `]` End array definition
- `/S` Get array size
- `/A` Allocate heap memory

### 8. INPUT/OUTPUT OPERATIONS
- `.` Print decimal number
- `,` Print hexadecimal number
- ``` ` ``` String delimiter/print
- `/C` Print character
- `/K` Read character from input
- `/N` Print newline
- `/P` Print MINT prompt
- `/I` Input from port
- `/O` Output to port
- `/D` Print stack depth

### 9. FUNCTION CALLS
- `A-Z` Call defined functions (26 possible functions)
- `/Z` Edit line definition

### 10. NUMBER INPUT
- `0-9` Decimal number input
- `#` Begin hexadecimal number input

### 11. NO OPERATION COMMANDS
- `@` No operation
- `_` No operation
- `/B` No operation
- `/H` No operation
- `/J` No operation
- `/L` No operation
- `/M` No operation
- `/Q` No operation
- `/R` No operation
- `/Y` No operation

### 12. CONTROL CHARACTERS
#### `CTRL-C` (ETX) End/return to interpreter

Looking in the code for CTRL-C (ETX) handling:

```assembly
ETX:         
02D2   21 00 EF               LD   hl,-DSTACK   ; check if stack pointer is underwater
02D5   39                     ADD   hl,SP   
02D6   30 03                  JR   NC,etx1   
02D8   31 00 11               LD   SP,DSTACK   
02DB                ETX1:        
02DB   C3 2B 02               JP   interpret   

; And where it's checked during input processing:
02B5   0A                     LD   a,(bc)   ; Get the next character and dispatch
02B6   B7                     OR   a   ; is it NUL?
02B7   28 0F                  JR   z,exit   
02B9   FE 03                  CP   CTRL_C   
02BB   28 15                  JR   z,etx   ; Jump to ETX handler if CTRL-C
```

The code shows that CTRL-C (value 3 or ETX) does two things:
1. Checks and resets the stack if needed 
2. Returns to the interpreter loop

And we can see CTRL-C is defined as:
```assembly
CTRL_C:   EQU   3   
```

So when you press CTRL-C, it forces a return to the main MINT interpreter, effectively ending whatever was being processed.




#### `CTRL-E` Edit command
Here's where CTRL-E is defined and handled in the code:

First, the definition:
```assembly
CTRL_E:   EQU   5   ; defined near start of code
```

The handling check in the input routine:
```assembly
FE 05                  CP   CTRL_E   
1E 85                  LD   e,lsb(edit_)   
28 14                  JR   z,macro   
```

And the actual edit macro that gets executed:
```assembly
EDIT_:       
0185   60 3F 60 2F 4B 2F 50 2F 5A 3B 00 .CSTR   "`?`/K/P/Z;"   
```

This is a MINT macro that:
1. `60` - Print backtick
2. `3F` - Print "?"
3. `60` - Print backtick
4. `/K` - Read a key
5. `/P` - Print prompt
6. `/Z` - Edit line
7. `;` - End macro

So when you press CTRL-E:
1. It's detected in the input routine
2. It loads the edit_ macro address
3. Jumps to execute this macro
4. The macro prompts for and handles line editing






#### `CTRL-H` Backspace
Looking in the code, here's where CTRL-H (Backspace) is handled:

```assembly
CTRL_H:   EQU   8   ; First defined as constant

; Then checked during input:
0257   FE 08                  CP   CTRL_H   
0259   28 AF                  JR   z,backSpace   

; The actual backspace routine:
BACKSPACE:      
020A   79                     LD   a,c   
020B   B0                     OR   b   
020C   28 27                  JR   z,interpret2   
020E   0B                     DEC   bc   ; decrement buffer pointer
020F   CD 92 03               CALL   printStr   
0212   08 20 08 00            .CSTR   "\b \b"   ; print backspace, space, backspace
0216   18 1D                  JR   interpret2   
```

What this does:
1. When CTRL-H is detected
2. Checks if we're at start of buffer (if so, return to interpret)
3. Decrements the buffer pointer
4. Prints "\b \b" (backspace, space, backspace) to erase character
5. Returns to interpreter

The "\b \b" sequence:
- First \b moves cursor back
- Space overwrites the character
- Second \b moves cursor back again

So CTRL-H provides the basic backspace editing functionality in the MINT system.

#### `CTRL-L` List command
Here's how CTRL-L is implemented in the code:

```assembly
; First defined as constant:
CTRL_L:   EQU   12   

; Checked during input processing:
0269   FE 0C                  CP   CTRL_L   
026B   1E 90                  LD   e,lsb(list_)   
026D   28 08                  JR   z,macro   

; The actual LIST macro:
LIST_:       
0190   2F 4E 32 36 28 2F 69 36 35 2B 2F 5A 2F 6B 30 3E 28 2F 4E 29 29 2F 50 3B 00 
.CSTR   "/N26(/i65+/Z/k0>(/N))/P;"   
```

Let's break down that LIST macro:
- `/N` - New line
- `26` - Push 26 (for A-Z)
- `(` - Start loop
- `/i` - Get loop counter
- `65+` - Add 65 (to get ASCII 'A'-'Z')
- `/Z` - Edit/show definition
- `/k0>` - If buffer pointer > 0
- `(/N)` - Print newline if condition true
- `)` - End loop
- `/P` - Print prompt
- `;` - End macro

So when you press CTRL-L it:
1. Loops through A-Z
2. For each letter, tries to show its definition
3. Prints newlines between definitions
4. Finally shows the prompt

This provides a way to list all defined words in your MINT system.

#### `CTRL-R` Re-edit command
Here's the CTRL-R implementation in the code:

```assembly
; Defined as constant:
CTRL_R:   EQU   18   

; Checked in input processing:
0263   FE 12                  CP   CTRL_R   
0265   1E 80                  LD   e,lsb(reedit_)   
0267   28 0E                  JR   z,macro   

; The actual REEDIT macro:
REEDIT_:      
0180   2F 7A 2F 5A 3B         DB   "/z/Z;"   ; remembers last line edited
```

Let's break down the REEDIT macro:
- `/z` - Get last defined function (z variable)
- `/Z` - Edit that definition
- `;` - End macro

So when you press CTRL-R:
1. Gets last function name from 'z' variable
2. Calls edit on that function
3. Allows you to re-edit your last edited definition

It's a quick way to get back to editing your most recent function definition.

#### `CTRL-S` Print stack
Here's the CTRL-S (Print Stack) implementation in the code:

```assembly
; Defined as constant:
CTRL_S:   EQU   19   

; Checked in input processing:
026F   FE 13                  CP   CTRL_S   
0271   1E A9                  LD   e,lsb(printStack_)   
0273   28 02                  JR   z,macro   

; The actual PRINTSTACK macro:
PRINTSTACK_:      
01A9   60 3D 3E 20 60 2F 73 32 2D 20 2F 44 31 2D 28 22 2C 32 2D 29 27 2F 4E 2F 50 3B 00 
.CSTR   "`=> `/s2- /D1-(",$22",2-)'/N/P;"   
```

Let's break down the PRINTSTACK macro:
- ``` ` ``` - Start string print
- `=> ` - Print "=> "
- ``` ` ``` - End string print
- `/s` - Get stack start address
- `2-` - Subtract 2 (move to previous stack item)
- `/D` - Get stack depth
- `1-` - Subtract 1
- `(` - Start loop
- `"` - Duplicate
- `,` - Print hex
- `2-` - Move to next stack item
- `)` - End loop
- `'` - Drop
- `/N` - New line
- `/P` - Print prompt
- `;` - End macro

This macro prints each value on the stack in hexadecimal, starting with "=> " and separating values with commas.

That's why when you enter numbers and press CTRL-S, you see something like:
```
> => 09FE 09FC 09FA
```
showing the stack contents in hex.

### 13. SYSTEM VARIABLES
Built-in system variables (accessed as a-z):
- `/h` Heap pointer variable
- `/k` Address of text input buffer
- `/r` Remainder of last division
- `/s` Address of start of stack
- `/v` Interrupt ID
- `/z` Name of last defined function
- `/b` Byte mode flag
- `/c` Carry flag
- `/f` Interrupt function
- `/i` Loop variable
- `/j` Outer loop variable



  
