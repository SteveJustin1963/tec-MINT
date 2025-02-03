# Code Extraction 

# Register usage

role of each Z80 register in the context of the Mint (Forth-like) language implementation:

AF (Accumulator and Flags):
- A is used for arithmetic, logic, and I/O operations related to Mint primitives.
- Flags in F are set based on results of Mint operations and used for conditional branching.

BC:
- BC holds the Interpretive Pointer (IP), which points to the next Mint word to interpret in the Text Input Buffer (TIB).
- B and C are sometimes used separately for loop counters and I/O port numbers in Mint primitives.

DE:
- Used to hold 16-bit values like addresses, often a destination address for memory operations in Mint primitives.
- E is used to track the nesting depth of Mint loops and conditional structures.

HL:
- The most frequently used register pair, used as a pointer to memory for Mint operations.
- Holds addresses of Mint variables, arrays, strings on the heap and stack.
- Used as the main register for 16-bit arithmetic in Mint primitives.
- L is used as an index into jump tables for Mint primitive dispatch.

SP (Stack Pointer):
- Manages the Mint data and return stacks, holding the address of the top of the stack.
- Manipulated with Mint primitives like DUP, DROP, >R, R> which translate to PUSH/POP, CALL/RET instructions.

IX (Index Register):
- Used as a pointer to the Mint return stack for easy access to return addresses and loop parameters.

IY (Index Register):
- Dedicated to holding the address of the NEXT routine, which is the heart of the Mint interpreter loop, allowing for faster jumps to this key routine.

The usage of registers is optimized for Mint's stack-based, interpretive model:

- BC always holds the interpretive pointer
- DE holds key Mint values and the nesting level 
- HL is the primary register for memory access and arithmetic
- SP manages Mint's two stacks
- IX points to the return stack for easy manipulation
- IY holds NEXT for fast interpreter dispatch

This register allocation allows for efficient implementation of the Mint virtual machine on the Z80 CPU. The registers are used in a coordinated way to interpret Mint code and manage Mint's key data structures like the stacks.

#### examples
These examples demonstrate how the Z80 registers are used in a coordinated fashion to efficiently implement the Mint Forth virtual machine, with each register having a specific role in the interpreter's operation. Here are code examples for each register's usage in the Mint implementation:

AF (Accumulator and Flags):
```
NESTING: 
  CP   "`"     ; Compare character to "`"
  JR   NZ,nesting1
  LD   a,$80   
  XOR  e       ; Toggle bit 7 of nesting level
  LD   e,a
  RET
```
Here, A is used to compare a character and manipulate the nesting level in E.

BC (Interpretive Pointer):
```
INTERPRET2:
  LD   E,0     ; Initialize nesting to 0
  PUSH bc      ; Save IP on stack
  LD   hl,TIB  ; HL = start of TIB
  JR   interpret4
  
NEXT:  
  INC  bc      ; Increment IP to next Mint word
  LD   a,(bc)  ; Fetch next character
  OR   a       ; Check if it's NUL (end of buffer)
  JR   z,exit
  ...
```
BC is used as the IP throughout the interpreter, incremented to fetch the next Mint word.

DE:
```
ARRDEF:
  LD   hl,0
  ADD  hl,sp   ; HL = current stack pointer
  CALL rpush   ; Save on return stack
  JP   (iy)    ; Continue interpreting
```
Here, DE is implicitly used to save the stack pointer on the return stack, as PUSH and RET use DE.

HL:
```
VAR1:  
  LD   (vPointer),hl  ; Save address of variable
  LD   d,0
  LD   e,(hl)         ; Fetch value into DE
  LD   a,(vByteMode)  
  INC  a              ; Check for byte mode
  JR   z,var2
  INC  hl
  LD   d,(hl)         ; Fetch high byte if word mode
```
HL extensively used for memory access, here to fetch a Mint variable's value.

SP (Stack Pointer):
```
DEPTH:
  LD   hl,0
  ADD  hl,SP   ; HL = current stack depth  
  EX   de,hl
  LD   hl,DSTACK
  OR   A       ; Clear carry
  SBC  hl,de   ; HL = depth in bytes
  JP   shr1    ; Shift right to get depth in cells
```
SP is used here to calculate the current stack depth.

IX (Return Stack Pointer):
```
LOOPSTART:
  LD   (vTemp1),bc  ; Save loop start
  LD   e,1          ; Nesting level = 1
LOOPSTART1:  
  INC  bc
  LD   a,(bc)
  CALL nesting        
  JR   nz,loopStart1 ; Find end of loop 
  POP  de            ; DE = loop limit
  ...  
  PUSH hl            ; Save loop params on return stack
  PUSH bc
  LD   hl,-1         ; Push initial index
  CALL rpush
```
IX is implicitly used here to save loop control parameters on the return stack via RPUSH.

IY (NEXT Pointer):
```
NEXT:  
  INC  bc    ; Increment IP
  LD   a,(bc)
  OR   a     
  JR   z,exit
  ...
exit:
  INC  bc
  LD   de,bc ; Save IP
  CALL rpop  ; Restore previous IP
  EX   de,hl ; HL = IP
  JP   (hl)  ; Jump to next Mint word

ENDLOOP:
  ...        ; Loop housekeeping
  JP   (iy)  ; Jump to NEXT to continue interpreting
```
IY always holds the address of NEXT, allowing for quick jumps back to the interpreter.





 
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

####  Rotate (a b c -- b c a)
not implemented, use other commands to construct


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

#### `;` End definition/return
Here's where end definition/return `;` is implemented in the code:

```assembly
; In the IOPCODES table:
01D8   80                     DB   lsb(semi_)   ;    ;

; The actual SEMI routine:
SEMI_:       
0480   CD AD 03               CALL   rpop        ; Restore Instruction pointer
0483   44 4D                  LD   bc,hl        ; Move return address to bc
0485   FD E9                  JP   (iy)         ; Next instruction

; Used in definition mode to detect end:
DEF1:        ; Store definition body
072D   0A                     LD   a,(bc)       ; Get next character
072E   03                     INC   bc          ; Point to next
072F   12                     LD   (de),A       ; Store character
0730   13                     INC   de   
0731   FE 3B                  CP   ";"          ; Is it semicolon?
0733   28 02                  JR   Z,def2       ; Yes, end definition
0735   18 F6                  JR   def1         ; No, continue definition
```

`;` has two roles:

1. In definitions (after `:`)
   - Marks end of definition
   - Ends storage of definition body
   - Saves final heap pointer

2. During execution
   - Acts as a return
   - Restores previous instruction pointer
   - Returns from called word

So:
```
: T 123 ;     ; ends definition of T
T             ; when T runs, ; returns to caller
```

It's both the definition terminator and the return instruction.

#### `(` Begin loop
Here's where begin loop `(` is implemented in the code:

```assembly
; In the IOPCODES table:
01CC   E9                     DB   lsb(lparen_)   ;   (

; The actual loop start code:
BEGIN:       
LOOPSTART:      
058A   ED 43 02 11            LD   (vTemp1),bc   ; save start
058E   1E 01                  LD   e,1           ; skip to loop end, nesting = 1
0590                LOOPSTART1:      
0590   03                     INC   bc   
0591   0A                     LD   a,(bc)   
0592   CD 5B 03               CALL   nesting      ; affects zero flag
0595   20 F9                  JR   nz,loopStart1   

0597   D1                     POP   de           ; de = limit
0598   7B                     LD   a,e           ; is it zero?
0599   B2                     OR   d   
059A   20 07                  JR   nz,loopStart2   
059C   1B                     DEC   de           ; de = TRUE
059D   ED 53 9E 13            LD   (vElse),de   
05A1   18 1F                  JR   loopStart4   ; yes continue after skip

05A3                LOOPSTART2:      
05A3   3E 02                  LD   a,2          ; is it TRUE
05A5   83                     ADD   a,e   
05A6   82                     ADD   a,d   
05A7   20 03                  JR   nz,loopStart3   
05A9   11 01 00               LD   de,1         ; yes make it 1

05AC                LOOPSTART3:      
05AC   60 69                  LD   hl,bc   
05AE   CD A2 03               CALL   rpush       ; rpush loop end
05B1   0B                     DEC   bc          ; IP points to ")"
05B2   2A 02 11               LD   hl,(vTemp1)  ; restore start
05B5   CD A2 03               CALL   rpush      ; rpush start
05B8   EB                     EX   de,hl       ; hl = limit
05B9   CD A2 03               CALL   rpush      ; rpush limit
05BC   21 FF FF               LD   hl,-1        ; hl = count = -1
05BF   CD A2 03               CALL   rpush      ; rpush count
```

When you use `(`, it:
1. Saves current location as loop start
2. Finds matching `)` taking nesting into account
3. Sets up loop control:
   - Pushes loop end address
   - Pushes loop start address
   - Pushes loop limit
   - Pushes initial counter (-1)

The loop stack frame looks like:
- counter (-1)
- limit
- start address
- end address

Example:
```
10 ( ... )    ; Loop 10 times
```

This works with the `)` command to create loops in MINT.

#### `)` End loop
Here's where end loop `)` is implemented in the code:

```assembly
; In the IOPCODES table:
01CD   E0                     DB   lsb(rparen_)   ;   )

; The actual loop end code:
AGAIN:       
LOOPEND:      
05C4   DD 5E 02               LD   e,(ix+2)     ; de = limit
05C7   DD 56 03               LD   d,(ix+3)     
05CA   7B                     LD   a,e          ; a = lsb(limit)
05CB   B2                     OR   d            ; if limit 0 exit loop
05CC   28 2B                  JR   z,loopEnd4   

05CE   13                     INC   de          ; is limit -2
05CF   13                     INC   de   
05D0   7B                     LD   a,e          ; a = lsb(limit)
05D1   B2                     OR   d            ; if limit 0 exit loop
05D2   28 09                  JR   z,loopEnd2   ; yes, loop again

05D4   1B                     DEC   de   
05D5   1B                     DEC   de   
05D6   1B                     DEC   de   
05D7   DD 73 02               LD   (ix+2),e     ; Store decremented limit
05DA   DD 72 03               LD   (ix+3),d   

05DD                LOOPEND2:      
05DD   DD 5E 00               LD   e,(ix+0)     ; inc counter
05E0   DD 56 01               LD   d,(ix+1)   
05E3   13                     INC   de   
05E4   DD 73 00               LD   (ix+0),e   
05E7   DD 72 01               LD   (ix+1),d   

05EA                LOOPEND3:      
05EA   11 00 00               LD   de,FALSE     ; if clause ran then vElse = FALSE
05ED   ED 53 9E 13            LD   (vElse),de   
05F1   DD 4E 04               LD   c,(ix+4)     ; IP = start
05F4   DD 46 05               LD   b,(ix+5)   
05F7   FD E9                  JP   (iy)         ; Next instruction

05F9                LOOPEND4:      
05F9   11 08 00               LD   de,2*4       ; rpop frame
05FC   DD 19                  ADD   ix,de   
05FE   FD E9                  JP   (iy)         ; Next instruction
```

When `)` is executed, it:
1. Checks loop limit:
   - If zero: exits loop
   - If -2: continues loop
   - Otherwise: decrements limit
2. Increments counter
3. Either:
   - Returns to loop start (IP = start)
   - Or exits loop by removing loop frame

So in a loop like:
```
10 ( ... )    ; Loop 10 times
```
The `)` will:
1. Track iterations
2. Jump back to code after `(` 
3. Exit when count reaches limit

The loop frame gets cleaned up when loop ends.

#### `/E` Else condition
Here's where else condition `/E` is implemented in the code:

```assembly
; In the IALTCODES table:
01F3   3B                     DB   lsb(else_)   ;E      else

; The actual ELSE routine:
ELSE_:       
063B   2A 9E 13               LD   hl,(vElse)    ; Get else flag
063E                ELSE1:       
063E   E5                     PUSH   hl          ; Push flag onto stack
063F   FD E9                  JP   (iy)          ; Next instruction

; vElse is set in various places, like during loops:
05EA                LOOPEND3:      
05EA   11 00 00               LD   de,FALSE     ; if clause ran then vElse = FALSE
05ED   ED 53 9E 13            LD   (vElse),de   
```

When you use `/E`, it:
1. Gets the current else flag value from vElse
2. Pushes that value onto stack

The else flag (vElse) is used to track conditional execution:
- Set to TRUE (-1) if a condition was false
- Set to FALSE (0) if a condition was true
- Used with `(...)` constructs

Example usage:
```
condition ( do-if-true ) /E ( do-if-false )
```

If condition is:
- True: first part runs, vElse = FALSE
- False: second part runs, vElse = TRUE

This allows for conditional execution in MINT programs.

#### `/F` False condition
Here's where false condition `/F` is implemented in the code:

```assembly
; In the IALTCODES table:
01F4   31                     DB   lsb(falsex_)   ;F      false condition

; The actual FALSEX routine:
FALSEX_:      
0631   C3 DD 03               JP   false_      ; Jump to FALSE routine

FALSE_:      
03DD   21 00 00               LD   hl,FALSE    ; Load FALSE ($0000)
03E0   18 03                  JR   true1       ; Jump to push result

TRUE1:       
03E5   E5                     PUSH   hl        ; Push result onto stack
03E6   FD E9                  JP   (iy)        ; Next instruction
```

When you use `/F`, it:
1. Loads HL with FALSE (0000)
2. Pushes FALSE onto stack

This command is used to put a false condition on the stack, which can be used for:
- Conditional tests
- Logical operations
- Flow control

Example usage:
```
/F ( code )     ; Code won't execute because condition is false
```

The command provides a way to explicitly push a FALSE value onto the stack.

#### `/T` True condition
Here's where true condition `/T` is implemented in the code:

```assembly
; In the IALTCODES table:
0202   88                     DB   lsb(truex_)   ;T      true condition

; The actual TRUEX routine:
TRUEX_:      
0688   C3 E2 03               JP   true_      ; Jump to TRUE routine

TRUE_:       
03E2   21 FF FF               LD   hl,TRUE    ; Load TRUE ($FFFF)
03E5   E5                     PUSH   hl       ; Push result onto stack
03E6   FD E9                  JP   (iy)       ; Next instruction
```

When you use `/T`, it:
1. Loads HL with TRUE ($FFFF)
2. Pushes TRUE onto stack

This command is used to put a true condition on the stack, which can be used for:
- Conditional tests
- Logical operations
- Flow control

Example usage:
```
/T ( code )     ; Code will execute because condition is true
```

The command provides a way to explicitly push a TRUE value onto the stack.

#### `/U` Unlimited loop
Here's where unlimited loop `/U` is implemented in the code:

```assembly
; In the IALTCODES table:
0203   8B                     DB   lsb(unlimit_)   ;U      unlimited loop

; The actual UNLIMIT routine:
UNLIMIT_:      
068B   21 FE FF               LD   hl,-2        ; Load -2 (special loop value)
068E   18 AE                  JR   else1        ; Push onto stack

ELSE1:       
063E   E5                     PUSH   hl         ; Push value
063F   FD E9                  JP   (iy)         ; Next instruction
```

When you use `/U`, it:
1. Loads HL with -2 (special loop value)
2. Pushes -2 onto stack

When -2 is used as a loop count:
```assembly
05CE   13                     INC   de          ; is limit -2
05CF   13                     INC   de   
05D0   7B                     LD   a,e          ; a = lsb(limit)
05D1   B2                     OR   d            ; if limit 0 exit loop
05D2   28 09                  JR   z,loopEnd2   ; yes, loop again
```

It creates an infinite loop that can only be broken by a `/W` while command.

Example usage:
```
/U ( code )     ; Code will loop forever until broken by /W
```

#### `/W` While condition
Here's where while condition `/W` is implemented in the code:

```assembly
; In the IALTCODES table:
0205   13                     DB   lsb(while_)   ;W      conditional break from loop

; The actual WHILE routine:
BREAK_:      
WHILE_:      
WHILE:       
0613   E1                     POP   hl         ; Get test value
0614   7D                     LD   a,l   
0615   B4                     OR   h           ; Check if zero
0616   20 09                  JR   nz,while2   ; If not zero, continue
0618   DD 4E 06               LD   c,(ix+6)    ; IP = ) 
061B   DD 46 07               LD   b,(ix+7)   
061E   C3 F9 05               JP   loopEnd4    ; Break from loop

WHILE2:      
0621   FD E9                  JP   (iy)        ; Continue loop
```

When you use `/W`, it:
1. POPs a value from stack
2. Tests if value is zero
3. If zero:
   - Gets loop end address
   - Breaks out of loop
4. If non-zero:
   - Continues loop

Example usage:
```
/U ( condition /W code )  ; Loop while condition is true
```

This provides conditional loop exit:
- Tests top of stack
- Exits loop if zero (false)
- Continues if non-zero (true)

Often used with `/U` for while-style loops that continue until a condition becomes false.

#### `/G` Execute MINT code
Here's where execute MINT code `/G` is implemented in the code:

```assembly
; In the IALTCODES table:
01F5   53                     DB   lsb(go_)   ;G      go execute mint code

; The actual GO routines:
GO_:         
0653   D1                     POP   de         ; Get address to execute

GO1:         
0654   7A                     LD   a,D         ; Skip if destination address is null
0655   B3                     OR   E   
0656   28 0E                  JR   Z,go3       ; If zero, skip execution

0658   60 69                  LD   hl,bc       ; Save current instruction pointer
065A   03                     INC   bc         ; Read next char from source
065B   0A                     LD   a,(bc)      ; Check for semicolon
065C   FE 3B                  CP   ";"         ; If semicolon, optimize tail call
065E   28 03                  JR   Z,go2       ; by jumping rather than calling
0660   CD A2 03               CALL   rpush     ; Save Instruction Pointer

GO2:         
0663   42 4B                  LD   bc,de       ; Set new instruction pointer
0665   0B                     DEC   bc   

GO3:         
0666   FD E9                  JP   (iy)        ; Next instruction
```

When you use `/G`, it:
1. POPs execution address from stack
2. If address is not zero:
   - Saves current instruction pointer
   - Checks for tail-call optimization (;)
   - Sets new instruction pointer to target
3. If address is zero:
   - Skips execution
4. Continues execution at new location

Example usage:
```
someaddr /G    ; Execute MINT code at someaddr
```

This command is used to:
- Execute MINT code at a given address
- Implement function calls
- Support tail-call optimization (when followed by ;)

  
#### `/X` Execute machine code
Here's where execute machine code `/X` is implemented in the code:

```assembly
; In the IALTCODES table:
0206   41                     DB   lsb(exec_)   ;X      execute machine code

; The actual EXEC routines:
EXEC_:      
0641   CD 46 06               CALL   exec1   
0644   FD E9                  JP   (iy)   

EXEC1:       
0646   E1                     POP   hl         ; Get code address from stack
0647   E3                     EX   (SP),hl     ; Exchange return address with code address
0648   E9                     JP   (hl)        ; Jump to code
```

When you use `/X`, it:
1. POPs address from stack (where machine code is located)
2. Exchanges return address with code address
3. Jumps directly to the machine code

Example usage:
```
machine_code_addr /X    ; Execute Z80 code at this address
```

This command is used to:
- Execute raw Z80 machine code
- Call machine language routines
- Implement low-level operations

Important notes:
- Code being called must preserve registers properly
- Must end with RET instruction to return to MINT
- Is dangerous if address points to invalid code
- Executes Z80 instructions directly

This provides a way to extend MINT with native Z80 code when needed.

### 7. ARRAY OPERATIONS
#### `[` Begin array definition
Here's where begin array definition `[` is implemented in the code:

```assembly
; In the IOPCODES table:
01E1   D4                     DB   lsb(lbrack_)   ;    [

; The actual LBRACK/ARRDEF routine:
LBRACK_:      
ARRDEF:      
04D4   21 00 00               LD   hl,0         ; Push 0 on return stack
04D7   39                     ADD   hl,sp       ; Get current stack pointer
04D8   CD A2 03               CALL   rpush      ; Save it for array building
04DB   FD E9                  JP   (iy)         ; Next instruction

; Array completion happens in ARREND when ] is encountered:
ARREND:             ; This is the code that runs after [1 2 3]
076E   ED 43 02 11            LD   (vTemp1),bc   ; save IP
0772   CD AD 03               CALL   rpop   
0775   22 04 11               LD   (vTemp2),hl   ; save old SP
0778   54 5D                  LD   de,hl   ; de = hl = old SP
077A   B7                     OR   a   
077B   ED 72                  SBC   hl,sp   ; hl = array count (items on stack)
077D   CB 3C                  SRL   h   ; num items = num bytes / 2
077F   CB 1D                  RR   l   
0781   44 4D                  LD   bc,hl   ; bc = count
0783   2A 76 13               LD   hl,(vHeapPtr)   ; hl = array[-4]
```

When you use `[`, it:
1. Gets current stack pointer
2. Saves it on return stack
3. Continues execution, collecting array items

Then when `]` is encountered:
1. Calculates number of items
2. Allocates heap space
3. Copies items from stack to heap
4. Returns array address

Example usage:
```
[ 1 2 3 ]    ; Creates array with 3 elements
```

Arrays are stored on the heap with:
- Length word at start
- Elements following
- Elements can be bytes or words based on byte mode
  
#### `]` End array definition
Here's where end array definition `]` is implemented in the code:

```assembly
; In the IOPCODES table:
01E3   E3                     DB   lsb(rbrack_)   ;    ]

; The actual RBRACK/ARREND routine:
ARREND:      
076E   ED 43 02 11            LD   (vTemp1),bc   ; save IP
0772   CD AD 03               CALL   rpop   
0775   22 04 11               LD   (vTemp2),hl   ; save old SP
0778   54 5D                  LD   de,hl         ; de = hl = old SP
077A   B7                     OR   a   
077B   ED 72                  SBC   hl,sp        ; hl = array count (items on stack)
077D   CB 3C                  SRL   h            ; num items = num bytes / 2
077F   CB 1D                  RR   l   
0781   44 4D                  LD   bc,hl         ; bc = count
0783   2A 76 13               LD   hl,(vHeapPtr) ; hl = array[-4]
0786   71                     LD   (hl),c        ; write num items in length word
0787   23                     INC   hl   
0788   70                     LD   (hl),b   
0789   23                     INC   hl           ; hl = array[0], bc = count

ARRAYEND1:      
078C   0B                     DEC   bc           ; dec items count
078D   1B                     DEC   de   
078E   1B                     DEC   de   
078F   1A                     LD   a,(de)        ; Get values from stack
0790   77                     LD   (hl),a        ; Store in array
0791   23                     INC   hl   
...
07A1   EB                     EX   de,hl         ; de = end of array
07A2   2A 04 11               LD   hl,(vTemp2)   
07A5   F9                     LD   sp,hl         ; SP = old SP
07A6   2A 76 13               LD   hl,(vHeapPtr) ; de = array[-2]
07A9   23                     INC   hl   
07AA   23                     INC   hl   
07AB   E5                     PUSH   hl          ; return array[0]
07AC   ED 53 76 13            LD   (vHeapPtr),de ; move heap* to end of array
```

When `]` is executed, it:
1. Calculates number of items collected since `[`
2. Gets heap space for array
3. Stores array length at start
4. Copies items from stack to heap
5. Updates heap pointer
6. Pushes array start address onto stack

For example:
```
[ 1 2 3 ]
```
Creates an array:
- Length: 3
- Contents: 1,2,3
- Returns start address of array

The array can then be accessed using the `?` operator.

#### `/S` Get array size
Here's where get array size `/S` is implemented in the code:

```assembly
; In the IALTCODES table:
0201   0B                     DB   lsb(arrSize_)   ;S      array size

; The actual ARRSIZE routines:
ARRSIZE_:      
ARRSIZE:      
060B   E1                     POP   hl          ; Get array address
060C   2B                     DEC   hl          ; Point to msb size
060D   56                     LD   d,(hl)       ; Get msb size
060E   2B                     DEC   hl          ; Point to lsb size
060F   5E                     LD   e,(hl)       ; Get lsb size
0610   D5                     PUSH   de         ; Push size onto stack
0611   FD E9                  JP   (iy)         ; Next instruction
```

When you use `/S`, it:
1. POPs array address from stack
2. Gets size stored before array:
   - Points to size bytes (2 before array start)
   - Gets 16-bit size value
3. Pushes size onto stack

Example usage:
```
[ 1 2 3 ] /S    ; Creates array and gets its size (pushes 3)
```

Arrays are stored with size word before data:
```
[Size(2 bytes)][Data...]
      ↑          ↑
   Size bytes  Array pointer
```

So `/S` moves back 2 bytes from array start to read the size value.

#### `/A` Allocate heap memory
Here's where allocate heap memory `/A` is implemented in the code:

```assembly
; In the IALTCODES table:
01EF   00                     DB   lsb(alloc_)   ;A      allocate some heap memory

; The actual ALLOC routine:
ALLOC_:      ; allocates raw heap memory in bytes (ignores byte mode)
0600   D1                     POP   de          ; Get allocation size
0601   2A 76 13               LD   hl,(vHeapPtr) ; Get current heap pointer
0604   E5                     PUSH   hl          ; Save current pointer as return value
0605   19                     ADD   hl,de        ; Add allocation size
0606   22 76 13               LD   (vHeapPtr),hl ; Store new heap pointer
0609                ANOP_:       
0609   FD E9                  JP   (iy)          ; Next instruction
```

When you use `/A`, it:
1. POPs number of bytes to allocate from stack
2. Gets current heap pointer
3. Pushes current pointer as return value (start of allocated space)
4. Adds allocation size to pointer
5. Updates heap pointer to new position

Example usage:
```
100 /A    ; Allocate 100 bytes, returns start address
```

Important points:
- Allocates raw bytes (ignores byte mode)
- Returns start address of allocated space
- Just moves heap pointer, doesn't initialize memory
- No memory recovery (no free operation)

This provides basic memory allocation from the heap.


### 8. INPUT/OUTPUT OPERATIONS
#### `.` Print decimal number
Here's where print decimal number `.` is implemented in the code:

```assembly
; In the IOPCODES table:
01D2   60                     DB   lsb(dot_)   ;   .

; The actual DOT routine:
DOT_:        
0460   E1                     POP   hl         ; Get number to print
0461   CD C9 06               CALL   printDec   ; Print in decimal
0464                DOT2:        
0464   3E 20                  LD   a," "       ; Print space after
0466   CD 85 00               CALL   putChar   
0469   FD E9                  JP   (iy)   

; The decimal printing routine:
PRINTDEC:      
06C9   CB 7C                  BIT   7,h           ; Check if negative
06CB   28 0B                  JR   z,printDec2    ; If positive skip
06CD   3E 2D                  LD   a,"-"          ; Print minus
06CF   CD 85 00               CALL   putchar   
06D2   AF                     XOR   a             ; Make number
06D3   95                     SUB   l             ; positive by
06D4   6F                     LD   l,a            ; negating it
06D5   9F                     SBC   a,a   
06D6   94                     SUB   h   
06D7   67                     LD   h,a   

PRINTDEC2:      
06D8   C5                     PUSH   bc   
06D9   0E 00                  LD   c,0           ; Leading zeros flag = false
06DB   11 F0 D8               LD   de,-10000     ; Print 10000s
06DE   CD FA 06               CALL   printDec4   
06E1   11 18 FC               LD   de,-1000      ; Print 1000s
06E4   CD FA 06               CALL   printDec4   
06E7   11 9C FF               LD   de,-100       ; Print 100s
06EA   CD FA 06               CALL   printDec4   
06ED   1E F6                  LD   e,-10         ; Print 10s
06EF   CD FA 06               CALL   printDec4   
06F2   0C                     INC   c            ; Flag = true for at least digit
06F3   1E FF                  LD   e,-1          ; Print 1s
06F5   CD FA 06               CALL   printDec4   
```

When you use `.`, it:
1. POPs number from stack
2. If negative:
   - Prints minus sign
   - Converts to positive
3. Prints each digit:
   - 10000s place
   - 1000s place
   - 100s place
   - 10s place
   - 1s place
4. Prints space after number

Example usage:
```
123 .     ; Prints "123 "
-456 .    ; Prints "-456 "
```

The routine handles both positive and negative numbers and suppresses leading zeros.

#### `,` Print hexadecimal number
Here's where print hexadecimal number `,` is implemented in the code:

```assembly
; In the IOPCODES table:
01D0   6B                     DB   lsb(comma_)   ;   ,

; The actual COMMA routine:
COMMA_:      ; print hexadecimal
046B   E1                     POP   hl         ; Get number to print
046C   CD 3C 03               CALL   printhex  ; Print in hex
046F   18 F3                  JR   dot2        ; Print space after

; The hex printing routines:
PRINTHEX:      
033C   C5                     PUSH   bc        ; preserve the IP
033D   7C                     LD   a,H         ; Print high byte
033E   CD 47 03               CALL   printhex2   
0341   7D                     LD   a,L         ; Print low byte
0342   CD 47 03               CALL   printhex2   
0345   C1                     POP   bc   
0346   C9                     RET      

PRINTHEX2:      
0347   4F                     LD   C,A         ; Save byte
0348   1F                     RRA              ; Get high nibble
0349   1F                     RRA      
034A   1F                     RRA      
034B   1F                     RRA      
034C   CD 50 03               CALL   printhex3   ; Print high nibble
034F   79                     LD   a,C         ; Get original byte
0350                PRINTHEX3:      
0350   E6 0F                  AND   0x0F       ; Mask to nibble
0352   C6 90                  ADD   a,0x90     ; Convert to ASCII
0354   27                     DAA              ; Decimal adjust
0355   CE 40                  ADC   a,0x40   
0357   27                     DAA      
0358   C3 85 00               JP   putchar     ; Print character
```

When you use `,`, it:
1. POPs number from stack
2. Prints high byte in hex
   - High nibble
   - Low nibble
3. Prints low byte in hex
   - High nibble
   - Low nibble
4. Prints space after number

Example usage:
```
$FF ,      ; Prints "FF "
$1234 ,    ; Prints "1234 "
```

The routine:
- Prints all numbers in 4-digit hex format
- Uses leading zeros for hex display
- Always follows with a space
- Uses uppercase hex digits (0-9, A-F)
  
#### ``` ` ``` String delimiter/print
Here's where string delimiter/print ``` ` ``` (grave) is implemented in the code:

```assembly
; In the IOPCODES table:
01E6   C5                     DB   lsb(grave_)   ;    `   ; for printing `hello`

; The actual GRAVE/STR routine:
GRAVE_:      
STR:         
04C5   03                     INC   bc         ; Move past first `
04C6                STR1:        
04C6   0A                     LD   a,(bc)      ; Get character
04C7   03                     INC   bc         ; Point to next
04C8   FE 60                  CP   "`"         ; Is it ending `?
04CA   28 05                  JR   Z,str2      ; Yes, done
04CC   CD 85 00               CALL   putchar   ; No, print it
04CF   18 F5                  JR   str1        ; Get next char

STR1:        
04D1   0B                     DEC   bc         ; Back up one
04D2   FD E9                  JP   (IY)        ; Return
```

When you use ``` ` ```, it:
1. Starts string mode
2. For each character until next ``` ` ```:
   - Gets character
   - If it's ``` ` ```, ends string
   - Otherwise prints character
3. Continues until ending ``` ` ```

Example usage:
```
`Hello World`    ; Prints: Hello World
```

The grave accent (backtick) acts as a string delimiter, printing everything between pairs of backticks literally.

This provides a way to print text strings in MINT.

#### `/C` Print character
Here's where print character `/C` is implemented in the code:

```assembly
; In the IALTCODES table:
01F1   34                     DB   lsb(printChar_)   ;C      print a char

; The actual PRINTCHAR routine:
PRINTCHAR_:      
0634   E1                     POP   hl         ; Get character to print
0635   7D                     LD   a,L         ; Move to A register
0636   CD 85 00               CALL   putchar   ; Print it
0639   FD E9                  JP   (iy)        ; Next instruction
```

When you use `/C`, it:
1. POPs a value from stack
2. Takes low byte as ASCII character
3. Prints that character using putchar

Example usage:
```
65 /C     ; Prints "A" (ASCII 65)
33 /C     ; Prints "!" (ASCII 33)
```

The command prints a single ASCII character based on the numeric value on top of the stack.

All output goes through putchar which handles actual character output to the display/terminal.

#### `/K` Read character from input
Here's where read character from input `/K` is implemented in the code:

```assembly
; In the IALTCODES table:
01F9   68                     DB   lsb(key_)   ;K      read a char from input

; The actual KEY routine:
KEY_:        
0668   CD 81 00               CALL   getchar   ; Get a character
066B   26 00                  LD   H,0         ; Clear high byte
066D   6F                     LD   L,A         ; Put char in low byte
066E   18 CE                  JR   else1       ; Push onto stack

; The getchar routine it uses:
GETCHAR:      
0081   2A 18 11               LD   HL,(GETCVEC)  ; Get input vector
0084   E9                     JP   (hl)          ; Jump to input routine
```

When you use `/K`, it:
1. Calls getchar to get input character
2. Clears high byte (H=0)
3. Puts character in low byte (L=char)
4. Pushes result onto stack

Example usage:
```
/K      ; Waits for keypress, pushes ASCII value onto stack
```

The command:
- Waits for input
- Returns ASCII value
- Returns single character
- Normally used in input loops

Used for getting keyboard/serial input in MINT programs.

#### `/N` Print newline
Here's where print newline `/N` is implemented in the code:

```assembly
; In the IALTCODES table:
01FC   7A                     DB   lsb(newln_)   ;N      prints a newline to output

; The actual NEWLN routine:
NEWLN_:      
067A   CD 8B 03               CALL   crlf      ; Print CRLF
067D   FD E9                  JP   (iy)        ; Next instruction

; The CRLF routine it uses:
CRLF:        
038B   CD 92 03               CALL   printStr   
038E   0D 0A 00               .CSTR   "\r\n"   ; Carriage return + Line feed
0391   C9                     RET      
```

When you use `/N`, it:
1. Calls CRLF routine
2. Which prints:
   - Carriage Return (0D)
   - Line Feed (0A)

Example usage:
```
`Hello` /N    ; Prints "Hello" followed by newline
```

The command provides a way to start a new line in output. It uses both CR and LF for compatibility across systems.

#### `/P` Print MINT prompt
Here's where print MINT prompt `/P` is implemented in the code:

```assembly
; In the IALTCODES table:
01FE   4E                     DB   lsb(prompt_)   ;P      print MINT prompt

; The actual PROMPT routine:
PROMPT_:      
064E   CD 82 03               CALL   prompt    ; Print prompt
0651   FD E9                  JP   (iy)        ; Next instruction

; The prompt routine it uses:
PROMPT:      
0382   CD 92 03               CALL   printStr   
0385   0D 0A 3E 20 00         .CSTR   "\r\n> "  ; CR, LF, > and space
038A   C9                     RET      
```

When you use `/P`, it:
1. Calls prompt routine
2. Which prints:
   - Carriage Return (0D)
   - Line Feed (0A)
   - Greater than sign (>)
   - Space (20)

Example usage:
```
/P      ; Prints:
>       ; The MINT prompt on new line
```

This command prints the standard MINT prompt, which is:
- A newline
- The > character
- A space
- Ready for input

It's the same prompt you see when MINT starts up or after commands complete.

#### `/I` Input from port
Here's where input from port `/I` is implemented in the code:

```assembly
; In the IALTCODES table:
01F7   70                     DB   lsb(inPort_)   ;I      input from port

; The actual INPORT routine:
INPORT_:      
0670   E1                     POP   hl         ; Get port number
0671   79                     LD   a,C         ; Save C
0672   4D                     LD   C,L         ; Port number in C
0673   ED 68                  IN   L,(C)       ; Read from port
0675   26 00                  LD   H,0         ; Clear high byte
0677   4F                     LD   C,A         ; Restore C
0678   18 C4                  JR   else1       ; Push result onto stack
```

When you use `/I`, it:
1. POPs port number from stack
2. Saves C register
3. Puts port number in C
4. INputs from port into L
5. Clears high byte (H=0)
6. Restores C register
7. Pushes result onto stack

Example usage:
```
portnum /I    ; Read from port, push value onto stack
```

This command is used to read values from I/O ports on the Z80. Each port can be addressed with an 8-bit number (0-255).


#### `/O` Output to port
Here's where output to port `/O` is implemented in the code:

```assembly
; In the IALTCODES table:
01FD   7F                     DB   lsb(outPort_)   ;O      output to port

; The actual OUTPORT routine:
OUTPORT_:      
067F   E1                     POP   hl         ; Get port value
0680   59                     LD   E,C         ; Save C
0681   4D                     LD   C,L         ; Port number in C
0682   E1                     POP   hl         ; Get value to output
0683   ED 69                  OUT   (C),L      ; Output to port
0685   4B                     LD   C,E         ; Restore C
0686   FD E9                  JP   (iy)        ; Next instruction
```

When you use `/O`, it:
1. POPs port number from stack
2. Saves C register
3. Puts port number in C
4. POPs value to output from stack
5. OUTputs value to port
6. Restores C register

Example usage:
```
value portnum /O    ; Output value to specified port
```

This command is used to write values to I/O ports on the Z80. Each port can be addressed with an 8-bit number (0-255).


#### `/D` Print stack depth
Here's where print stack depth `/D` is implemented in the code:

```assembly
; In the IALTCODES table:
01F2   23                     DB   lsb(depth_)   ;D      depth of stack

; The actual DEPTH routines:
DEPTH_:      
DEPTH:       
0623   21 00 00               LD   hl,0         ; Clear HL
0626   39                     ADD   hl,SP        ; Get current stack pointer
0627   EB                     EX   de,hl        ; Save in DE
0628   21 00 11               LD   hl,DSTACK    ; Get stack start address
062B   B7                     OR   A            ; Clear carry
062C   ED 52                  SBC   hl,de       ; Calculate items on stack
062E   C3 8C 04               JP   shr1         ; Divide by 2 (2 bytes per item)
```

When you use `/D`, it:
1. Gets current stack pointer
2. Gets stack start address (DSTACK)
3. Subtracts to get number of bytes used
4. Divides by 2 (since each stack item is 2 bytes)
5. Pushes result onto stack

Example usage:
```
/D .     ; Print current stack depth
```

The command tells you how many items are currently on the stack by:
- Calculating bytes between stack start and current position
- Dividing by 2 (each item uses 2 bytes)
- Result is number of items on stack


### 9. FUNCTION CALLS
#### `A-Z` Call defined functions (26 possible functions)
Here's where calling defined functions (A-Z) is implemented in the code:

```assembly
; In the IOPCODES table:
01DE   9A                     DB   (26 | $80)   ; call a command a, B ....Z
01DF   56                     DB   lsb(call_)   

; The actual CALL routine:
CALL_:       
0456   0A                     LD   a,(bc)       ; Get function name (A-Z)
0457   CD 29 03               CALL   lookupRef0  ; Find function address
045A   5E                     LD   E,(hl)       ; Get low byte of address
045B   23                     INC   hl   
045C   56                     LD   D,(hl)       ; Get high byte of address
045D   C3 54 06               JP   go1          ; Execute the function

; Function addresses stored in DEFS:
1334                DEFS:     DS   VARS_SIZE    ; 26*2 bytes for A-Z
```

When you use an uppercase letter (A-Z), it:
1. Gets letter as function name
2. Looks up function in DEFS table
3. Gets stored function address
4. Jumps to execute that function

Example usage:
```
: T 123 ;    ; Define function T
T           ; Call function T (puts 123 on stack)
```

There's space for 26 functions (A to Z). Each one stores a pointer to its MINT code in the DEFS table. When you use a letter, it looks up and executes that code.

This provides the ability to define and call named functions in MINT.

**extra question**

To modify MINT to accept two-letter function names, we'd need to change several parts of the code:

1. The DEFS table would need to be expanded:
```assembly
; Currently:
1334    DEFS:     DS   VARS_SIZE    ; 26*2 bytes for A-Z

; Would need:
1334    DEFS:     DS   26*26*2      ; 1352 bytes for AA-ZZ
```

2. Modify the CALL_ routine:
```assembly
CALL_:       
0456   0A                     LD   a,(bc)       ; Get first letter
0457   03                     INC   bc          ; Point to second letter
0458   47                     LD   b,a          ; Save first letter
0459   0A                     LD   a,(bc)       ; Get second letter
; Would need new code to:
; - Convert AA-ZZ to 0-675 index (26*26 combinations)
; - Use that to look up function address
```

3. Modify definition code:
```assembly
DEF0:        
071F   32 9A 13               LD   (vLastDef),a   ; Currently stores one letter
; Would need to store both letters
```

The main challenges would be:
1. Code to convert two letters to a unique index
2. Larger memory requirement for function table
3. Changes to all code that handles function names

It's doable but would require careful modifications to maintain compatibility with existing MINT code.

 




#### `/Z` Edit line definition

Here's where edit line `/Z` is implemented in the code:

```assembly
; In the IALTCODES table:
0208   49                     DB   lsb(editDef_)   ;Z      edit line

; The actual EDITDEF routines:
EDITDEF_:      
0649   CD 99 06               CALL   editDef    ; Edit the definition
064C   FD E9                  JP   (iy)         ; Next instruction

EDITDEF:       ; lookup up def based on number
0699   E1                     POP   hl         ; pop ret address
069A   E3                     EX   (SP),hl     ; swap with TOS
069B   7D                     LD   a,L         ; Get definition number
069C   08                     EX   AF,AF'      ; Save it
069D   7D                     LD   a,l         
069E   CD 29 03               CALL   lookupRef0 ; Find definition
06A1   5E                     LD   E,(hl)      ; Get address low byte
06A2   23                     INC   hl   
06A3   56                     LD   D,(hl)      ; Get address high byte
06A4   7A                     LD   a,D   
06A5   B3                     OR   E           ; Check if definition exists
06A6   21 00 08               LD   hl,TIB      ; Point to text buffer
06A9   28 14                  JR   Z,editDef3  ; If no definition, done

06AB   3E 3A                  LD   a,":"       ; Start with colon
06AD   CD B8 03               CALL   writeChar  ; Write to buffer
06B0   08                     EX   AF,AF'      ; Get definition name back
06B1   CD B8 03               CALL   writeChar  ; Write name to buffer
06B4   18 01                  JR   editDef2    ; Copy definition

06B6                EDITDEF1:      
06B6   13                     INC   de         ; Next character

06B7                EDITDEF2:      
06B7   1A                     LD   a,(de)      ; Get character from definition
06B8   CD B8 03               CALL   writeChar  ; Write to buffer
06BB   FE 3B                  CP   ";"         ; Until semicolon
06BD   20 F7                  JR   NZ,editDef1   

06BF                EDITDEF3:      
06BF   11 00 08               LD   de,TIB      ; Calculate 
06C2   B7                     OR   A           ; number of
06C3   ED 52                  SBC   hl,de      ; characters written
06C5   22 7C 13               LD   (vTIBPtr),hl ; Save count
06C8   C9                     RET      
```

When you use `/Z`, it:
1. Gets definition letter
2. Looks up definition in DEFS
3. If found:
   - Writes ':' to text buffer
   - Writes definition letter
   - Copies definition code until ';'
4. Updates text buffer pointer
5. Ready for editing

Example usage:
```
: T 123 ;    ; Define T
/Z T         ; Edit definition of T
```

This command allows you to pull a function definition back into the text buffer for editing.

 


### 10. NUMBER INPUT
#### `0-9` Decimal number input
Here's where decimal number input (0-9) is implemented in the code:

```assembly
; In the IOPCODES table for 0-9:
01D4   8A                     DB   (10 | $80)   ; 10 x repeat lsb of add to the num routine
01D5   DD                     DB   lsb(num_)   

; The actual number parsing routine:
NUM:         
073E   21 00 00               LD   hl,$0000    ; Clear hl to accept the number
0741   0A                     LD   a,(bc)      ; Get numeral or -
0742   FE 2D                  CP   "-"         ; Check for minus sign
0744   20 01                  JR   nz,num0     
0746   03                     INC   bc         ; Move past minus

NUM0:        
0747   08                     EX   af,af'      ; Save zero flag for later

NUM1:        
0748   0A                     LD   a,(bc)      ; Read digit
0749   D6 30                  SUB   "0"        ; Less than 0?
074B   38 13                  JR   c,num2      ; Not a digit, exit
074D   FE 0A                  CP   10          ; Greater than 9?
074F   30 0F                  JR   nc,num2     ; Not a digit, exit
0751   03                     INC   bc         ; Inc IP
0752   54 5D                  LD   de,hl       ; Multiply hl * 10
0754   29                     ADD   hl,hl   
0755   29                     ADD   hl,hl   
0756   19                     ADD   hl,de   
0757   29                     ADD   hl,hl   
0758   85                     ADD   a,l        ; Add digit
0759   6F                     LD   l,a   
075A   3E 00                  LD   a,0   
075C   8C                     ADC   a,h   
075D   67                     LD   h,a   
075E   18 E8                  JR   num1        ; Get next digit
```

When a digit (0-9) is encountered:
1. Starts building a number
2. Checks for minus sign
3. For each digit:
   - Converts ASCII to value (0-9)
   - Multiplies current value by 10
   - Adds new digit
4. Handles negative numbers
5. Pushes final value onto stack

Example usage:
```
123     ; Pushes decimal 123 onto stack
-456    ; Pushes decimal -456 onto stack
```

The routine:
- Accepts multiple digits
- Handles negative numbers
- Accumulates value digit by digit
- Stops at non-digit character


#### `#` Begin hexadecimal number input
Here's where hexadecimal number input `#` is implemented in the code:

```assembly
; In the IOPCODES table:
01C7   EE                     DB   lsb(hash_)   ;   #

; The actual HEX input routine:
HEX:         
054B   21 00 00               LD   hl,0         ; Clear hl to accept the number

HEX1:        
054E   03                     INC   bc   
054F   0A                     LD   a,(bc)       ; Get the character 
0550   CB 77                  BIT   6,A         ; Is it uppercase alpha?
0552   CA 57 05               JP   Z,hex2       ; No a decimal
0555   D6 07                  SUB   7           ; Sub 7 to make $A - $F

HEX2:        
0557   D6 30                  SUB   $30         ; Form decimal digit
0559   DA 60 07               JP   C,num2       ; Exit if not hex digit
055C   FE 10                  CP   $0F+1   
055E   D2 60 07               JP   NC,num2      ; Exit if not hex digit
0561   29                     ADD   hl,hl       ; Multiply previous value by 16
0562   29                     ADD   hl,hl   
0563   29                     ADD   hl,hl   
0564   29                     ADD   hl,hl   
0565   85                     ADD   a,L         ; Add in new digit
0566   6F                     LD   L,A   
0567   C3 4E 05               JP   hex1         ; Get next digit
```

When you use `#`, it:
1. Starts hex number mode
2. For each character:
   - If A-F, adjusts value (minus 7)
   - Subtracts $30 to get value
   - Checks if valid hex digit
   - Shifts previous value left 4 bits (*16)
   - Adds new digit
3. Continues until non-hex character

Example usage:
```
#FF      ; Puts 255 on stack
#1234    ; Puts 4660 on stack
```

The routine:
- Accepts 0-9 and A-F
- Builds number in base 16
- Shifts and adds each digit
- Stops at non-hex character

  
### 11. NO OPERATION COMMANDS
#### `@` No operation
Here's where no operation `@` is implemented in the code:

```assembly
; In the IOPCODES table:
01DD   01                     DB   lsb(at_)   ;    @

; The actual AT routine:
AT_:         
UNDERSCORE_:      
0401   FD E9                  JP   (iy)        ; Just skip to next instruction
```

When you use `@`, it:
1. Simply jumps to next instruction (does nothing)

In MINT, `@` and `_` (underscore) both do exactly the same thing - they are no-operation commands that just continue to the next instruction without doing anything.

The code combines the AT (@) and UNDERSCORE (_) routines since they both do the same thing: nothing.



#### `_` No operation

Here's where no operation `_` (underscore) is implemented in the code:

```assembly
; In the IOPCODES table:
01E5   01                     DB   lsb(underscore_)   ;    _

; The actual UNDERSCORE routine (combined with AT_):
UNDERSCORE_:      
AT_:         
0401   FD E9                  JP   (iy)        ; Just skip to next instruction
```

When you use `_`, it:
1. Simply jumps to next instruction (does nothing)

The underscore shares the same code as the `@` command since they both do exactly the same thing - nothing.

Both `_` and `@` are no-operation commands that just continue to the next instruction without performing any action.

Example usage:
```
_ 1 2 3    ; The _ does nothing, same as just writing: 1 2 3
```

The underscore provides a way to add a visible "do nothing" in MINT code, which can be useful for readability or placeholders.


#### `/B` No operation
Here's where no operation `/B` is implemented in the code:

```assembly
; In the IALTCODES table:
01F0   09     DB   lsb(aNop_)   ;B

; The actual ANOP routine:
ANOP_:       
0609   FD E9                  JP   (iy)        ; Just skip to next instruction
```

When you use `/B`, it:
1. Simply jumps to next instruction (does nothing)

This is one of several "no operation" alternate commands. Others include:
- `/H`
- `/J`
- `/L`
- `/M`
- `/Q`
- `/R`
- `/Y`

All of these use the same ANOP_ routine that does nothing but continue to the next instruction.

Example usage:
```
/B 1 2 3    ; The /B does nothing, same as just writing: 1 2 3
```

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

So when you press CTRL-C, it forces a return to the main MINT interpreter, effectively ending whatever was being processed while taking input.

Lets explain how CTRL-C works (and doesn't work) in this MINT implementation:

How it works:
1. CTRL-C is only checked during input processing
2. When detected:
   - Checks and fixes stack if needed
   - Returns to MINT interpreter

Why it doesn't work during execution:
- MINT is only checking for CTRL-C during input
- Once code starts executing, there's no check for CTRL-C
- The system is busy executing code and not monitoring input

The code would need to be modified to check for CTRL-C during execution if you wanted to be able to interrupt running code. This would require adding input checks in the main execution loop.

Let me propose a modification to implement proper CTRL-C handling during execution. We need to:
1. Check for CTRL-C during the main execution loop
2. Make sure the check is fast so it doesn't slow down execution

Here's how we **could** modify the code:

```assembly
; Add interrupt check to NEXT routine where every instruction goes through:
NEXT:        
02B4   03                     INC   bc         ; Increment the IP
02B5   0A                     LD   a,(bc)      ; Get the next character
; Add CTRL-C Check here:
02B6   F5                     PUSH   af        ; Save next character
02B7   DB 80                  IN   a,(STATUS)  ; Check ACIA status
02B9   CB 47                  BIT   0,a        ; Data ready?
02BB   28 06                  JR   z,next1     ; No data, continue
02BD   DB 81                  IN   a,(RDR)     ; Get character
02BF   FE 03                  CP   CTRL_C      ; Is it CTRL-C?
02C1   28 0E                  JR   z,next_etx  ; Yes, handle it
02C3   F1                     next1: POP   af  ; Restore next character
02C4   B7                     OR   a           ; Continue normal NEXT...
; Rest of NEXT routine...

; Add new ETX handler for execution break
next_etx:
02D0   F1                     POP   af         ; Clean up stack
02D1   21 00 EF               LD   hl,-DSTACK  ; Check stack health
02D4   39                     ADD   hl,SP   
02D5   30 03                  JR   NC,next_etx1
02D7   31 00 11               LD   SP,DSTACK   ; Reset if needed
02DA   next_etx1:
02DA   C3 2B 02               JP   interpret   ; Return to interpreter
```

This modification:
1. Checks input port at each instruction
2. Only reads input if data is ready (fast check)
3. Checks for CTRL-C and breaks if found
4. Cleans up and returns to interpreter




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

Ah, looking at where forward slash `/` leads to in the code:

```assembly
; In the IOPCODES table:
01D3   F2                     DB   lsb(slash_)   ;   /

; The actual SLASH/ALT routine:
SLASH_:      
ALT_:        
04F2   03                     INC   bc          ; Point to next character
04F3   0A                     LD   a,(bc)       ; Get character after /
04F4   FE 7B                  CP   "z"+1        ; Compare with 'z'+1
04F6   30 0C                  JR   nc,alt1      ; If > 'z', not variable
04F8   FE 61                  CP   "a"          ; Compare with 'a'
04FA   30 0C                  JR   nc,altVar    ; If >= 'a', it's variable
04FC   FE 5B                  CP   "Z"+1        ; Compare with 'Z'+1
04FE   30 04                  JR   nc,alt1      ; If > 'Z', not command
0500   FE 41                  CP   "A"          ; Compare with 'A'
0502   30 2D                  JR   nc,altCode   ; If >= 'A', it's command

ALTVAR:      
0508   FE 69                  CP   "i"          ; Check for 'i'
050A   2E 00                  LD   l,0   
050C   CA 1E 05               JP   z,loopVar   
050F   FE 6A                  CP   "j"          ; Check for 'j'
0511   2E 08                  LD   l,8   
0513   28 09                  JR   z,loopVar   
0515   21 68 13               LD   hl,altVars   ; Point to alt variables
0518   CD 30 03               CALL   lookupRef   ; Get variable address
051B   C3 0C 04               JP   var1         ; Handle variable
```

When you use `/r`, it's actually accessing the remainder through the alternate variables space (altVars), not the normal variables space. That's why it's `/r` instead of just `r`.

This also explains why other system variables like the remainder are accessed with a forward slash - they're in the alternate variables space rather than the normal variables space.

Let's look at how the two variable spaces are set up in the code:

```assembly
; Normal variables (a-z):
1300                VARS:     DS   VARS_SIZE   ; Regular variables

; Alternate variables:
1368                ALTVARS:      
1368                          DS   2   ; a
136A                VBYTEMODE:   DS   2   ; b
136C                VCARRY:   DS   2   ; c carry variable
136E                          DS   2   ; d
1370                          DS   2   ; e
1372                VINTFUNC:   DS   2   ; f interrupt func
1374                          DS   2   ; g
1376                VHEAPPTR:   DS   2   ; h heap pointer variable
1378                          DS   2   ; i loop variable
137A                          DS   2   ; j outer loop variable
137C                VTIBPTR:   DS   2   ; k address of text input buffer
...
138A                VREMAIN:   DS   2   ; r remainder of last division
```

The code paths for accessing each:

1. Regular variable (a-z):
```assembly
VAR_:        
0405   0A                     LD   a,(bc)      ; Get variable name (a-z)
0406   21 00 13               LD   hl,vars     ; Point to variables area
0409   CD 30 03               CALL   lookupRef  ; Calculate variable address
```

2. Alternate variable (/a-/z):
```assembly
ALT_:        
04F2   03                     INC   bc         ; Next char after /
04F3   0A                     LD   a,(bc)      ; Get variable name
...
ALTVAR:      
0515   21 68 13               LD   hl,altVars  ; Point to alt variables
0518   CD 30 03               CALL   lookupRef  ; Get variable address
051B   C3 0C 04               JP   var1        ; Handle variable
```

So:
- Normal variables (like `r`) access VARS space
- Alt variables (like `/r`) access ALTVARS space
- Both use similar lookup but different base addresses
- System variables like remainder are in ALTVARS space

That's why remainder must be accessed as `/r` - it's in the alternate variables area.

#### `/h` Heap pointer variable
Looking at the code again, you are correct in questioning `/h` - there is no `/h` command in the MINT implementation.

Let's look at the variable 'h':

```assembly
; VHEAPPTR:           1376 DEFINED AT LINE 51 IN ram.asm
; In the variables section:
1376                VHEAPPTR:   DS   2   ; h heap pointer variable
```

'h' is just a regular variable accessed like any other a-z variable, not an alternate command with '/'.

So to use the heap pointer:
```
/h      ; Get heap pointer value
/h !    ; Store to heap pointer, you can do this but you should not as its internaly managed
/h .    ; display it
```

There is no special `/h` command. I apologize for any confusion in my earlier responses. The 'h' variable is used internally by the system to track heap allocation, but it's accessed just like any other MINT variable.

Let me trace all internal uses of the heap pointer (VHEAPPTR) in the code:

1. Initialization:
```assembly
INIT:        
...
02FF   21 A0 13               LD   hl,HEAP      ; Point to start of heap
0302   22 76 13               LD   (vHeapPtr),hl ; Initialize heap pointer
```

2. Array Creation (`]` command):
```assembly
ARREND:      
...
0783   2A 76 13               LD   hl,(vHeapPtr)  ; Get space for array
...
07AC   ED 53 76 13            LD   (vHeapPtr),de  ; Update after array
```

3. Memory Allocation (`/A` command):
```assembly
ALLOC_:      
0601   2A 76 13               LD   hl,(vHeapPtr)  ; Get current pointer
...
0606   22 76 13               LD   (vHeapPtr),hl  ; Update after allocation
```

4. Definition Creation (`:` command):
```assembly
DEF:         
...
0718   ED 5B 76 13            LD   de,(vHeapPtr)  ; Get space for definition
...
0738   ED 53 76 13            LD   (vHeapPtr),de  ; Update after definition
```

So the heap pointer is used internally for:
- Array storage
- Memory allocation
- Function definitions
- Initial heap setup

The system maintains the heap pointer automatically during these operations, even though we can access it as variable 'h'.


#### `/k` Address of text input buffer
Looking at the code, `k` is actually a variable, not a `/k` command. Here's how it's defined and used:

```assembly
; In the variables section:
137C                VTIBPTR:   DS   2   ; k address of text input buffer

; The Text Input Buffer itself:
0800                TIB:      DS   TIBSIZE   ; Text Input Buffer

; When TIB pointer is used:
022B                INTERPRET:      
022B   CD 82 03               CALL   prompt   
022E   01 00 00               LD   bc,0        ; load bc with offset into TIB
0231   ED 43 7C 13            LD   (vTIBPtr),bc  ; Store in k (VTIBPTR)
```

There is no `/k` command. Instead:
1. 'k' is a variable that holds TIB pointer
2. TIB starts at $0800
3. 'k' tracks where we are in the buffer

You access it like any other variable:
```
k      ; Get current TIB pointer
k !    ; Set TIB pointer
```

The TIB and its pointer (k) are used internally by MINT to handle text input.

#### `/r` Remainder of last division

Looking at the code, `r` is actually a variable, and /r is a special viable that stores the remainder 
and is not a `/r` command. Here's how it's defined and used:

```assembly
; In the variables section:
138A                VREMAIN:   DS   2   ; r remainder of last division

; Where remainder is stored after division:
DIV:
...
07F8                DIVEXIT:      
07F8   D5                     PUSH   de         ; quotient
07F9   22 8A 13               LD   (vRemain),hl ; remainder
07FC   FD E9                  JP   (iy)   
```

There is no `/r` command. Instead:
1. '/r' is a variable that contains remainder after division
2. It's automatically set after division operations
3. You access it like any variable

Example usage:
```
5 2 /    ; Divide 5 by 2, quotient (2) goes on stack
/r       ; Get remainder (1) from variable r
/r.      ; display it
1

```

The '/r' variable is updated after any division operation to hold the remainder.


#### `/s` Address of start of stack
Here's where `/s` (address of start of stack) is implemented in the code:

```assembly
; In the variables section (alt vars):
138C                VSTKSTART:   DS   2   ; s address of start of stack

; Initialized in INIT:
02DE                INIT:        
...
02F3   21 00 11               LD   hl,dStack   ; Load stack start address
02F6   22 8C 13               LD   (vStkStart),hl   ; Set 's' variable

; The dStack is defined at:
1100                DSTACK:      ; Start of data stack
```

When you use `/s`, it:
1. Accesses VSTKSTART variable through alt variable access
2. Returns the start address of the data stack ($1100)

This is used in some MINT macros, like print stack:
```assembly
PRINTSTACK_:      
; `=> `/s2- /D1-(",$22",2-)'/N/P;"   
;      ^-- Gets stack start address
```

`/s` is useful when you need to know where the stack starts in memory, especially for stack manipulation operations.

Example usage:
```
/s    ; Pushes stack start address ($1100)
```

Like `/r`, this is an alternate variable accessed with forward slash because it's in the ALTVARS space.

////   redo from here as answers are sus --------------////////////////////////////////////////////////////////////////////////////////////////////

#### `/v` Interrupt ID
Here's where `/v` (interrupt ID) is implemented in the code:

```assembly
; In the variables section (alt vars):
1392                VINTID:   DS   2   ; v interrupt id

; Set during interrupt handling:
ISR:         
008B   26 00                  LD   h,0   
008D   22 92 13               LD   (vIntID),hl   ; Store interrupt ID
0090   CD BD 03               CALL   enter   
0093   5A 00                  .CSTR   "Z"   
0095   C9                     RET      
```

When `/v` is used:
1. Accesses VINTID through alt variable access
2. Returns the ID of the last interrupt that occurred

The interrupt handling:
1. H is cleared to 0
2. L contains the interrupt ID (from RST handling)
3. This is stored in vIntID

The RST (interrupt) vectors set different IDs:
```assembly
RST1:        
0008   2E 01                  LD   l,1   
000A   C3 8B 00               JP   ISR   

RST2:        
0010   2E 02                  LD   l,2   
0012   C3 8B 00               JP   ISR   
...
```

Like `/r` and `/s`, this is an alternate variable accessed with forward slash because it's in the ALTVARS space.

//


In the listing, the interrupt ID is managed through the variable `VINTID` located at memory address `0x1392`. This is part of the MINT (Minimal Interpreter) system for the Z80 microprocessor.

The interrupt ID is set in the `ISR` (Interrupt Service Routine) function at address `0x008B`:

```assembly
ISR:         
    LD h,0           ; Clear the high byte of HL
    LD (vIntID),hl   ; Store the interrupt ID (low byte of L) in memory
    CALL enter       ; Call the enter routine
    .CSTR   "Z"      ; Output the character "Z"
    RET              ; Return from the interrupt
```

Here's what's happening:
1. `LD h,0` sets the high byte of HL to zero
2. `LD (vIntID),hl` stores the value in the `VINTID` memory location
3. The low byte of L contains the interrupt ID (which seems to be passed in before calling this routine)

In the code, you can see interrupt IDs are set when various RST (Restart) vectors are called. For example:

```assembly
RST1:        
    LD l,1   ; Set interrupt ID to 1
    JP ISR   

RST2:        
    LD l,2   ; Set interrupt ID to 2
    JP ISR   
```

Each restart vector sets a different interrupt ID (1, 2, 3, 4, 5, 6, 7, 8) before jumping to the common ISR routine.

The purpose seems to be to provide a way to track and potentially handle different types of interrupts in a generic manner, with the ability to distinguish between them using the `VINTID` variable.

To use the interrupt ID mechanism in this Z80 MINT system, you would typically follow these steps:

1. Define an Interrupt Handler
First, create a function that will handle specific interrupt types. For example:

```assembly
handle_interrupt:
    ; Check the interrupt ID
    LD A, (VINTID)   ; Load the interrupt ID
    CP 1             ; Compare with specific interrupt type
    JR Z, interrupt_type_1
    CP 2             ; Check for another type
    JR Z, interrupt_type_2
    ; ... handle other types
    RET

interrupt_type_1:
    ; Specific handling for interrupt type 1
    ; For example, toggle a flag, read a sensor, etc.
    RET

interrupt_type_2:
    ; Specific handling for interrupt type 2
    RET
```

2. Set Up Interrupt Vectors
The code already sets up interrupt vectors at specific memory locations (RST1, RST2, etc.). These automatically call the ISR routine with different interrupt IDs:

- RST1 sets interrupt ID to 1
- RST2 sets interrupt ID to 2
- And so on...

3. Enable Interrupts
In the RESET routine, interrupts are enabled:

```assembly
RESET:       
    ; ... other initialization
    IM 1     ; Set Interrupt Mode 1
    EI       ; Enable Interrupts
```

4. Practical Example
Let's say you want to handle a timer interrupt (ID 1) and a serial receive interrupt (ID 2):

```assembly
RST1:   ; Timer Interrupt
    LD l,1   ; Set interrupt ID to 1
    JP ISR   

RST2:   ; Serial Receive Interrupt
    LD l,2   ; Set interrupt ID to 2
    JP ISR   

handle_interrupt:
    LD A, (VINTID)
    CP 1
    JR Z, timer_interrupt
    CP 2
    JR Z, serial_interrupt
    RET

timer_interrupt:
    ; Increment a timer variable
    LD HL, (timer_count)
    INC HL
    LD (timer_count), HL
    RET

serial_interrupt:
    ; Read a character from serial port
    CALL RXCHAR   ; Receive character
    LD (last_received_char), A
    RET
```

5. In Your Main Program
You could then check or use these interrupt-driven values:

```assembly
main_loop:
    ; Check timer count
    LD HL, (timer_count)
    ; Do something based on timer
    
    ; Check last received character
    LD A, (last_received_char)
    ; Process character
    
    JR main_loop
```

Key Points:
- The interrupt ID is stored in `VINTID` at memory location `0x1392`
- Each restart vector (RST1-RST8) can trigger a different interrupt type
- The ISR routine stores the interrupt ID
- You can create a handler to process different interrupt types
- The system uses Interrupt Mode 1 (IM 1)

Limitations in This Implementation:
- The current ISR just prints "Z" and returns
- You'll need to expand the interrupt handling to do meaningful work
- This is a minimal implementation, so you might need to add more robust interrupt management

The beauty of this design is its simplicity and extensibility. You can easily add new interrupt types by adding more RST vectors and handling logic.





#### `/z` Name of last defined function
Here's where `/z` (name of last defined function) is implemented in the code:

```assembly
; In the variables section (alt vars):
139A                VLASTDEF:   DS   2   ; z name of last defined function

; Set during function definition:
DEF0:        
071F   32 9A 13               LD   (vLastDef),a   ; Save name of last defined function

; Used in the REEDIT macro:
REEDIT_:      
0180   2F 7A 2F 5A 3B         DB   "/z/Z;"   ; remembers last line edited
```

When `/z` is used:
1. Accesses VLASTDEF through alt variable access
2. Returns the letter (A-Z) of the last function defined

The system uses this to remember:
- What function was last defined
- What function to edit when CTRL-R is pressed

For example:
```
: T 123 ;    ; Define function T
/z          ; Will return 'T'
```

Like other system variables (`/r`, `/s`, `/v`), this is an alternate variable accessed with forward slash because it's in the ALTVARS space.

/////


In the MINT system, `/z` is a system variable that represents the name (single character) of the last defined function.

Key Details:
- Memory Address: `0x139A`
- Variable Name: `VLASTDEF`
- Type: 2-byte memory location storing the name of the last defined function

How it Works:
1. When you define a new function using the `:` (colon) command, the system stores the function's name in `VLASTDEF`.

Example in the Code:
```assembly
DEF:    ; Create a colon definition
    INC BC   ; Move to next character
    LD A,(BC)  ; Get the next character (function name)
    CP "@"    ; Check if it's an anonymous function
    JR NZ, def0   

def0:
    LD (vLastDef),A  ; Store the function name
```

Practical Usage:
: B `test` ;
```
After these definitions, `VLASTDEF` would contain the name of the most recently defined function ('cube').

Practical Example:
```forth
: G `Hello, World!` ;   

> /z.    ; get ascii of last function letter
71
>

```
the is no ctrl-Z to edit last function letter



The `/z` mechanism provides a quick way to review and modify the most recently defined function, supporting an interactive and iterative programming style in this minimal Forth-like language.


#### `/b` Byte mode flag
Here's where `/b` (byte mode flag) is implemented in the code:

```assembly
; In the variables section (alt vars):
136A                VBYTEMODE:   DS   2   ; b byte mode flag

; Used when checking byte mode:
VAR2:        
041A   D5                     PUSH   de   
041B   18 B7                  JR   resetByteMode   

SETBYTEMODE:      
03D0   3E FF                  LD   a,$FF       ; Set byte mode
03D2   18 01                  JR   assignByteMode  

RESETBYTEMODE:      
03D4   AF                     XOR   a          ; Clear to 0
03D5                ASSIGNBYTEMODE:      
03D5   32 6A 13               LD   (vByteMode),a   ; Store byte mode flag
03D8   32 6B 13               LD   (vByteMode+1),a   
03DB   FD E9                  JP   (iy)   
```

When `/b` is used:
1. Accesses VBYTEMODE through alt variable access
2. Returns current byte mode status:
   - $FF = byte mode on
   - $00 = byte mode off

Byte mode affects:
- Variable access (1 vs 2 bytes)
- Array operations
- It's set by the `\` command
- Reset by many operations

Example usage:
```
/b    ; Get current byte mode status
```

Like other system variables, this is an alternate variable accessed with forward slash because it's in the ALTVARS space.

//////


In the MINT system, `/b` (actually `vByteMode`) is a system variable that controls whether the interpreter is in byte mode or word mode.

Location and Details:
- Memory Address: `0x136A`
- Variable Name: `VBYTEMODE`
- Type: 2-byte memory location storing the byte mode flag

Key Characteristics:
- When the flag is set to `-1` (all bits set), the system operates in byte mode
- When the flag is set to `0`, the system operates in standard 16-bit word mode

How Byte Mode is Used:
1. Declaring Byte Arrays:
```forth
\ [1 2 3] a!   // Declare a byte array using '\' 
```

2. Accessing Byte Arrays:
```forth
\[1 2 3] 1\?   // Access a specific byte in the array
```

Implementation in Code:
```assembly
SETBYTEMODE:      
    LD a,$FF   ; Set byte mode flag to all bits set (-1)
    JR assignByteMode

RESETBYTEMODE:    
    XOR a      ; Clear byte mode flag (set to 0)

ASSIGNBYTEMODE:   
    LD (vByteMode),a    ; Store the byte mode flag
    LD (vByteMode+1),a  ; Ensure full 16-bit setting
    JP (iy)             ; Continue execution
```

Mode Transition:
- Entering Byte Mode: Use `\` before array declaration
- Leaving Byte Mode: Automatically occurs when executing `]`, `?`, or `!`

Example Interactions:
```forth
// Standard 16-bit word mode (default)
[1 2 3] a!   // Creates a 16-bit word array

// Byte mode
\[1 2 3] a!  // Creates an 8-bit byte array
\a 1\?       // Access second byte of the array
```

Important Nuances:
- Byte mode affects how arrays are stored and accessed
- Limited to 8-bit values when in byte mode
- Automatically returns to word mode after certain operations

Limitations:
- Only 8-bit values can be stored in byte mode
- Primarily useful for compact memory representation or working with byte-level data

The `/b` byte mode flag provides flexibility in data storage and manipulation, allowing developers to switch between 16-bit and 8-bit representations as needed.\\



#### `/c` Carry flag
Here's where `/c` (carry flag) is implemented in the code:

```assembly
; In the variables section (alt vars):
136C                VCARRY:   DS   2   ; c carry variable

; Carry flag is set after arithmetic:
CARRY:       
03C6   21 00 00               LD   hl,0   
03C9   CB 15                  RL   l           ; Move carry into L
03CB   22 6C 13               LD   (vCarry),hl ; Store carry flag

; Used after operations like plus:
PLUS_:       ; add the top 2 members of the stack
044F   D1                     POP   de   
0450   E1                     POP   hl   
0451   19                     ADD   hl,de   
0452   E5                     PUSH   hl   
0453   C3 C6 03               JP   carry       ; Update carry flag
```

When `/c` is used:
1. Accesses VCARRY through alt variable access
2. Returns carry flag state after last arithmetic:
   - Non-zero if carry occurred
   - Zero if no carry

Used to check for:
- Overflow in addition
- Borrow in subtraction
- Results of comparisons

Like other system variables, this is an alternate variable accessed with forward slash because it's in the ALTVARS space.

////
Here's a practical example of using `/c` to check the carry flag:

For addition overflow:
```
32767 1 +    ; Try to add 1 to max positive number
/c .         ; Print carry flag - will be non-zero due to overflow
```

For checking borrow in subtraction:
```
5 10 -       ; Subtract 10 from 5
/c .         ; Print carry flag - will be non-zero due to borrow
```

For comparisons:
```
10 5 -       ; 10 minus 5
/c .         ; No borrow, carry will be 0

5 10 -       ; 5 minus 10
/c .         ; Borrow occurred, carry will be non-zero
```

You can store the carry result:
```
5 10 -       ; Do subtraction
/c c !       ; Store carry flag in variable c
c .          ; Print the stored carry
```

The carry flag gets updated after arithmetic operations, and `/c` lets you access that flag to check what happened in the operation.

#### `/f` Interrupt function
Here's where `/f` (interrupt function) is implemented in the code:

```assembly
; In the variables section (alt vars):
1372                VINTFUNC:   DS   2   ; f interrupt func

; The variable stores the address of function to call on interrupt

; Example usage would be:
; Store interrupt handler address:
handler_addr /f !    ; Set interrupt function address

; When interrupt occurs:
ISR:         
008B   26 00                  LD   h,0         ; clear h
008D   22 92 13               LD   (vIntID),hl  ; store interrupt id
0090   CD BD 03               CALL   enter     ; Call function
```

When `/f` is used:
1. Accesses VINTFUNC through alt variable access
2. Gets/sets the address of interrupt handler function

Like other system variables, this is an alternate variable accessed with forward slash because it's in the ALTVARS space.

Would you like me to show an example of how to set up an interrupt handler using `/f`?

Here's an example of how to use `/f` with interrupt handling:

```
; Define an interrupt handler
: H                ; Define handler function
  /v .            ; Print interrupt ID that occurred
  /N              ; Print newline
;

; Set up the handler
H /f !             ; Store address of H in interrupt function variable
```

Now when an interrupt occurs:
1. System stores interrupt ID in `/v`
2. Calls function whose address is in `/f`
3. Our handler H prints which interrupt occurred

For RST (restart) interrupts:
```
RST 08: ID = 1
RST 10: ID = 2
RST 18: ID = 3
RST 20: ID = 4
RST 28: ID = 5
RST 30: ID = 6
RST 38: ID = 7
NMI:    ID = 8
```

We can see this in the code:
```assembly
RST1:        
0008   2E 01                  LD   l,1   ; Set ID 1
000A   C3 8B 00               JP   ISR   

RST2:        
0010   2E 02                  LD   l,2   ; Set ID 2
0012   C3 8B 00               JP   ISR   
```

Would you like me to show how to handle specific types of interrupts?

Let me show you how to handle specific interrupts with examples:

```
; Handler for all interrupts - print ID and type
: H 
  `RST `         ; Print "RST "
  /v .           ; Print interrupt ID
  /v 1 = (       ; If ID = 1
    ` - Clock`   ; Print type
  ) /v 2 = (
    ` - Keyboard`
  ) /v 7 = (
    ` - Serial`
  )
  /N
;

; Install handler
H /f !
```

More specific handlers:

```
; Keyboard handler (RST 10)
: KEY
  /v 2 = (       ; If it's RST 10 (ID 2)
    /K .         ; Read and print key
    /N
  )
;

; Serial handler (RST 38)
: SER
  /v 7 = (       ; If it's RST 38 (ID 7)
    /I .         ; Read and print serial input
    /N
  )
;

; Clock tick handler (RST 08)
: TICK
  /v 1 = (       ; If it's RST 08 (ID 1)
    `.`          ; Print dot for each tick
  )
;
```

To change handlers:
```
H /f !     ; General handler
KEY /f !   ; Just keyboard
SER /f !   ; Just serial
TICK /f !  ; Just clock
```

Would you like me to explain the interrupt vector setup as well?

Let me show the complete interrupt setup in the code:

```assembly
; Reset/NMI vectors
0000                RSTVEC:      
0000   C3 96 00               JP   RESET   

; RST 08 (ID=1)
0008                          .ORG   ROMSTART+$08   
0008   2E 01                  LD   l,1   
000A   C3 8B 00               JP   ISR   

; RST 10 (ID=2)
0010                          .ORG   ROMSTART+$10   
0010   2E 02                  LD   l,2   
0012   C3 8B 00               JP   ISR   

; RST 18 (ID=3)
0018                          .ORG   ROMSTART+$18   
0018   2E 03                  LD   l,3   
001A   C3 8B 00               JP   ISR   

; RST 20 (ID=4)
0020                          .ORG   ROMSTART+$20   
0020   2E 04                  LD   l,4   
0022   C3 8B 00               JP   ISR   

; RST 28 (ID=5)
0028                          .ORG   ROMSTART+$28   
0028   2E 05                  LD   l,5   
002A   C3 8B 00               JP   ISR   

; RST 30 (ID=6)
0030                          .ORG   ROMSTART+$30   
0030   2E 06                  LD   l,6   
0032   C3 8B 00               JP   ISR   

; RST 38 (ID=7)
0038                          .ORG   ROMSTART+$38   
; Masked interrupt handler...

; NMI (ID=8)
0066                          .ORG   ROMSTART+$66   
0066   2E 08                  LD   l,8   
0068   C3 8B 00               JP   ISR   

; Main ISR that all interrupts jump to:
ISR:         
008B   26 00                  LD   h,0         ; Clear high byte
008D   22 92 13               LD   (vIntID),hl ; Store interrupt ID
0090   CD BD 03               CALL   enter     ; Enter MINT
0093   5A 00                  .CSTR   "Z"      
0095   C9                     RET      
```

When an interrupt occurs:
1. CPU jumps to appropriate RST vector
2. Vector loads interrupt ID into L
3. Jumps to ISR
4. ISR:
   - Clears H
   - Stores ID in `/v`
   - Gets handler from `/f`
   - Calls handler
   - Returns to interrupted code

You can see how each interrupt has:
- Fixed address in low memory
- Unique ID loaded into L
- Common path through ISR
- Access to handler via `/f`

Would you like me to explain how to enable/disable specific interrupts?

Let's look at how to enable/disable interrupts in the code. First, the initialization:

```assembly
RESET:       
0096   31 00 11               LD   SP,stack   
...
00C7   ED 56                  IM   1           ; Set Interrupt Mode 1
00C9   FB                     EI               ; Enable interrupts globally

; For serial interrupts (6850 ACIA):
00CA                          IF   TEC_1   
00CA                          IF   BITBANG = 0   
00CA   3E 03                  LD   a,MRESET      ; Reset ACIA
00CC   D3 80                  OUT   (CONTROL),a   
00CE   3E 12                  LD   a,RTSLID+F8N2+DIV_64  ; Initialize ACIA
00CC   D3 80                  OUT   (CONTROL),a   ; 8N2, /64 for 115200 baud
```

To control interrupts in MINT code:

```
: DI      ; Disable all interrupts
  #F3 /X  ; Execute DI instruction
;

: EI      ; Enable all interrupts
  #FB /X  ; Execute EI instruction
;

; For serial interrupts:
; Get control register current value
#80 /I    ; Read ACIA control
#80 /O    ; Write back to control to disable interrupts

; To enable serial interrupts:
MRESET RTSLIE + F8N1 + DIV_64 + ; Build control value
#80 /O    ; Write to ACIA control
```

The hardware supports:
- Global enable/disable (EI/DI)
- RST vector interrupts (always enabled if EI)
- Serial interrupts (controlled by ACIA)
- NMI (cannot be disabled)

Would you like me to explain more about the ACIA interrupt control bits?

Let's look at the ACIA (6850) interrupt control bits in the code:

```assembly
; 6850 ACIA control register bits
; Control bits for interrupts:
0000                RTSLID:   EQU   $00   ;RTS LOW, transmit interrupt disabled
0000                RTSLIE:   EQU   $20   ;RTS LOW, transmit interrupt enabled
0000                RTSHID:   EQU   $40   ;RTS HIGH, transmit interrupt disabled
0000                RTSLIDB:   EQU   $60   ;RTS LOW, transmit interrupt disabled and "break"
0000                RIE:      EQU   $80   ;receiver interrupt enabled

; Status register bits to check interrupts:
0000                RDRF:     EQU   0   ;receive data register full
0000                TDRE:     EQU   1   ;transmit data register empty
0000                DCD:      EQU   2   ;data carrier detect
0000                CTS:      EQU   3   ;clear to send
0000                FE:       EQU   4   ;framing error
0000                OVRN:     EQU   5   ;overrun
0000                PE:       EQU   6   ;parity error
0000                IRQ:      EQU   7   ;interrupt request
```

Example MINT code to control ACIA interrupts:

```
; Enable receiver interrupts only
MRESET RIE + F8N1 + DIV_64 +    ; Master reset + Receive interrupts + 8N1 + /64
#80 /O                          ; Write to control register

; Enable transmit interrupts
MRESET RTSLIE + F8N1 + DIV_64 + ; Master reset + Transmit interrupts + 8N1 + /64
#80 /O                          ; Write to control register

; Check interrupt status
#80 /I                          ; Read status register
1 AND                           ; Mask TDRE bit
```

Would you like me to show how to write an interrupt handler for serial I/O?

Here's how to write a serial interrupt handler in MINT:

```
; Define serial handler
: SER
  /v 7 = (           ; If RST 38 (serial interrupt)
    #80 /I           ; Read ACIA status
    1 AND (          ; Check TDRE (transmit ready)
      `T`            ; Print T if transmit ready
    ) 
    RDRF AND (       ; Check RDRF (receive ready)
      #81 /I         ; Read received character
      /C             ; Print it
    )
    /N
  )
;

; Install handler
SER /f !             ; Set as interrupt handler

; Enable serial interrupts in ACIA
MRESET              ; Reset ACIA first
RIE RTSLIE + +      ; Enable RX and TX interrupts
F8N1 + DIV_64 +     ; 8N1 format, divide by 64
#80 /O              ; Write to control register

EI                  ; Enable interrupts globally
```

This handler:
1. Checks if it's serial interrupt
2. Tests transmit ready flag
   - Prints 'T' if ready to transmit
3. Tests receive ready flag
   - Gets and prints character if received
4. Returns to main code

The serial port runs at:
```
4MHz / 64 = 62.5KHz base rate
÷16 = 3906.25 baud
```

Would you like me to explain how to modify the baud rate or add buffer handling?

Let's look at how to modify baud rate and add buffer handling:

```assembly
; Baud rate control via divider:
0000                DIV_64:   EQU   $02   ;CLOCK/64
```

First, let's create a circular buffer for RX:
```
; Define RX buffer
100 /A              ; Allocate 256 bytes
DUP rx_buf !        ; Save buffer start
0 rx_in !           ; Input pointer
0 rx_out !          ; Output pointer

; Improved serial handler with buffering
: SER               ; Serial interrupt handler
  /v 7 = (          ; If serial interrupt
    #80 /I          ; Read status
    RDRF AND (      ; If receive data ready
      #81 /I        ; Get character
      rx_buf @      ; Get buffer base
      rx_in @  +    ; Add input pointer
      !             ; Store character
      rx_in @       ; Get input pointer
      1 +           ; Increment
      255 AND       ; Keep in range 0-255
      rx_in !       ; Save new pointer
    )
  )
;

; Get character from buffer
: GETC             ; Get buffered character
  rx_in @ rx_out @ = ( ; If buffer empty
    0              ; Return 0
  ) (              ; Else
    rx_buf @       ; Get buffer base
    rx_out @ +     ; Add output pointer
    @              ; Get character
    rx_out @       ; Get output pointer
    1 +           ; Increment
    255 AND       ; Keep in range 0-255
    rx_out !      ; Save new pointer
  )
;

; Change baud rate
: SETBAUD         ; Set new baud rate
  MRESET          ; Reset ACIA
  RIE +           ; Enable RX interrupt
  F8N1 +          ; 8N1 format
  SWAP +          ; Add divider
  #80 /O          ; Write to control
;
```

Usage:
```
; Set different baud rates
DIV_64 SETBAUD    ; 3906.25 baud at 4MHz
DIV_16 SETBAUD    ; 15625 baud at 4MHz

; Read characters
GETC /C           ; Get and print buffered character
```

Would you like me to explain more about the buffer management or add transmit buffering as well?

Let's add transmit buffering. Here's the complete buffered serial I/O system:

```
; Allocate RX and TX buffers
: BUFINIT
  100 /A          ; 256 bytes for RX
  DUP rx_buf !    ; Save RX buffer address
  100 /A          ; 256 bytes for TX
  DUP tx_buf !    ; Save TX buffer address
  0 rx_in !       ; RX input pointer
  0 rx_out !      ; RX output pointer
  0 tx_in !       ; TX input pointer
  0 tx_out !      ; TX output pointer
;

; Enhanced serial handler
: SER
  /v 7 = (         ; If serial interrupt
    #80 /I         ; Read status

    RDRF AND (     ; If receive ready
      #81 /I       ; Get character
      rx_buf @     ; Buffer base
      rx_in @ +    ; Add input pointer
      !            ; Store character
      rx_in @      ; Update
      1 +          ; input
      255 AND      ; pointer
      rx_in !      
    )

    1 AND (        ; If transmit ready
      tx_in @ tx_out @ = NOT ( ; If TX data available
        tx_buf @   ; Get buffer base
        tx_out @ + ; Add output pointer
        @          ; Get character
        #81 /O     ; Send it
        tx_out @   ; Update
        1 +        ; output
        255 AND    ; pointer
        tx_out !
      )
    )
  )
;

; Put character in TX buffer
: PUTC            ; ( char -- )
  tx_buf @        ; Get buffer base
  tx_in @ +       ; Add input pointer
  !               ; Store character
  tx_in @         ; Update
  1 +             ; input
  255 AND         ; pointer
  tx_in !         
  RTSLIE #80 /O   ; Enable TX interrupt
;

; Get character from RX buffer
: GETC            ; ( -- char )
  rx_in @ rx_out @ = ( ; If empty
    0             ; Return 0
  ) (             ; Else
    rx_buf @      ; Get buffer base
    rx_out @ +    ; Add output pointer
    @             ; Get character
    rx_out @      ; Update
    1 +           ; output
    255 AND       ; pointer
    rx_out !
  )
;

; Initialize everything
: INIT
  BUFINIT         ; Setup buffers
  SER /f !        ; Install handler
  MRESET          ; Reset ACIA
  RIE RTSLIE + +  ; Enable RX & TX interrupts
  F8N1 + DIV_64 + ; 8N1 format, /64 divider
  #80 /O          ; Set ACIA control
  EI              ; Enable interrupts
;
```

Usage:
```
INIT             ; Setup system

; Send string
: STR
  /K DUP 13 = NOT (  ; Until CR
    DUP PUTC         ; Buffer character
    /C               ; Echo it
    STR              ; Recurse
  ) DROP
;

; Echo received chars
: ECHO
  GETC DUP (        ; Get char, if non-zero
    /C              ; Print it
    ECHO            ; Recurse
  ) DROP
;
```

This provides:
1. 256-byte circular buffers for RX and TX
2. Interrupt-driven I/O
3. Buffer overflow protection
4. Easy high-level interface (GETC/PUTC)

Would you like me to explain more about the circular buffer logic or add error handling?

#### `/i` Loop variable

Here's where loop variable `/i` (i) is implemented in the code:

```assembly
; In the variables section (alt vars):
1378                          DS   2   ; i loop variable

; Used in loop processing:
ALTVAR:      
0508   FE 69                  CP   "i"          ; Check for 'i'
050A   2E 00                  LD   l,0   
050C   CA 1E 05               JP   z,loopVar    ; Handle i variable

LOOPVAR:      
051E   26 00                  LD   h,0          ; Clear H
0520   DD 54                  LD   d,ixh        ; Get loop frame pointer
0522   DD 5D                  LD   e,ixl
0524   19                     ADD   hl,de       ; Add offset (0 for i)
0525   C3 0C 04               JP   var1         ; Handle as variable
```

The `/i` variable holds current loop counter. Example usage:

```
10 (           ; Start loop 0 to 9
  /i .         ; Print current counter
) 

5 (            ; Loop 5 times
  `Count: ` /i . ; Print: Count: 0,1,2,3,4
  /N
)
```

The loop counter `/i`:
- Starts at 0
- Increments each loop
- Accessed via `/i`
- Is part of loop stack frame

It's accessed through the alternate variable system like other system variables.

Here are practical examples of using `/i` in MINT:

```
; Simple counting example
10 (           ; Loop 10 times
  `Loop # ` /i . /N  ; Will print: Loop # 0, Loop # 1, etc
)

; Making a multiplication table
10 (           ; Outer loop 0-9
  10 (         ; Inner loop 0-9
    /i .       ; Print row number
    ` x `      ; Print x
    /j .       ; Print column number (outer loop counter)
    ` = `      ; Print =
    /i /j * .  ; Print product
    /N         ; New line
  )
)

; Creating an array with index values
[ 
  5 (          ; Loop 5 times
    /i         ; Push loop counter
  )            ; Creates array [0,1,2,3,4]
]

; Selective processing
10 (
  /i 2 MOD 0 = (  ; If counter is even
    /i .          ; Print it
  )
)

; Countdown
10 (
  9 /i - .     ; Print 9,8,7,6,5,4,3,2,1,0
  /N
)
```

Would you like me to show more complex examples using `/i` with arrays or nested loops?

Here are more complex examples using `/i` with arrays and nested loops:

```
; Create 2D array [row,col] using nested loops
[
  5 (          ; 5 rows
    [          ; Create row array
      3 (      ; 3 columns
        /i 10 * /j +  ; Row*10 + Col
      )
    ]
  )
]              ; Creates: [[0,1,2],[10,11,12],[20,21,22],[30,31,32],[40,41,42]]

; Print a box using nested loops
10 (           ; Height
  10 (         ; Width
    /i 0 = /i 9 = OR    ; If first or last row
    /j 0 = /j 9 = OR OR ; Or first or last column
    ( `*` ) ( ` ` ) /C  ; Print * or space
  )
  /N           ; New line at end of each row
)

; Fill array with pattern based on index
[
  16 (         ; 16 elements
    /i DUP * ; Square of index
  )
]              ; Creates: [0,1,4,9,16,25,36,49,64,81,100,121,144,169,196,225]

; Process array with index
: SHOWARRAY    ; ( array -- )
  DUP /S (     ; Get size and loop that many times
    DUP /i ?   ; Get element at index i
    ` Element ` /i . ` is: ` . /N  ; Print with index
  ) DROP
;
```

The patterns shown above demonstrate:
1. Nested loops with `/i` and `/j`
2. Array creation with computed values
3. Index-based pattern generation
4. Array processing using index

Would you like me to show more examples of specific patterns or techniques?

Here are more advanced patterns and techniques using `/i` and arrays:

```
; Create a triangular number sequence
[
  8 (          ; First 8 triangular numbers
    /i 1 +     ; n = i + 1
    DUP        ; Duplicate n
    1 + *      ; Multiply by (n+1)
    2 /        ; Divide by 2
  )            ; Creates [1,3,6,10,15,21,28,36]
]

; Pascal's triangle row generator
: PASCAL       ; ( row# -- )
  DUP 1 + [    ; Create array size row#+1
    DUP (      ; For each position
      /i DUP   ; Get current position
      ROT      ; Get row number to top
      OVER     ; Copy position
      - DUP    ; Position from end
      0 < NOT  ; Check if valid
      SWAP 0 = OR ( ; Or if first position
        1       ; Edge is 1
      ) (       ; Else
        0       ; Fill with 0
      )
    ) DROP
  ]
;

; Multiplication table as array of arrays
[
  10 (         ; 10 rows
    [          ; Create row array
      10 (     ; 10 columns
        /i 1 + /j 1 + *  ; (row+1)*(col+1)
      )
    ]
  )
]

; Print array with formatting
: PRINTARRAY   ; ( array -- )
  DUP /S (     ; For each element
    /i 4 MOD 0 = /i 0 = NOT AND ( ; Every 4 items except first
      /N       ; New line
    )
    DUP /i ?   ; Get element
    5 SPACES   ; Pad with spaces
    .          ; Print number
  ) DROP
  /N
;
```

These examples show:
1. Mathematical sequence generation
2. Complex array building
3. Nested array structures
4. Matrix-like operations
5. Formatted output using indices

Would you like to see more examples of specific mathematical patterns or data structures?

Here are more advanced mathematical patterns and data structures using `/i`:

```
; Fibonacci sequence in array
[
  10 (                    ; First 10 Fibonacci numbers
    /i 2 < (              ; If index < 2
      1                   ; Push 1 for first two numbers
    ) (                   ; Else
      DUP /i 1 - ?       ; Get F(n-1)
      OVER /i 2 - ?      ; Get F(n-2)
      +                   ; Add them
    )
  )
]                        ; Creates [1,1,2,3,5,8,13,21,34,55]

; Prime number sieve
: SIEVE                 ; ( size -- array )
  [                     ; Create initial array
    OVER (              ; Loop size times
      /i 2 <  (         ; If index < 2
        0               ; Not prime
      ) (               ; Else
        1               ; Potentially prime
      )
    )
  ]
  DUP ROT (            ; For each number up to size
    /i 2 >= (          ; If index >= 2
      DUP /i ?         ; Check if still marked prime
      (                ; If it is
        /i DUP +       ; Start at i*2
        ROT DUP ROT (  ; Up to size
          OVER OVER    ; Get array and index
          0 SWAP       ; Mark as not prime
          !            ; Store it
          OVER +       ; Next multiple
        ) DROP DROP
      ) DROP
    )
  ) 
;

; Create a spiral array pattern
: SPIRAL                ; ( size -- array )
  DUP DUP * [          ; Create square array
    OVER (             ; For each row
      OVER (           ; For each column
        /i /j          ; Get coordinates
        2DUP           ; Calculate spiral value
        MIN OVER
        MIN ROT ROT
        OVER OVER -
        ROT ROT -
        MIN 4 *
        OVER OVER 
        SWAP - SWAP
        OVER - +
      )
    )
  ]
;
```

Would you like me to:
1. Explain how any of these patterns work in detail?
2. Show more mathematical sequences?
3. Show how to manipulate these structures once created?


#### `/j` Outer loop variable

Here's where outer loop variable `/j` is implemented in the code:

```assembly
; In the variables section (alt vars):
137A                          DS   2   ; j outer loop variable

; Used in loop processing:
ALTVAR:      
050F   FE 6A                  CP   "j"          ; Check for 'j'
0511   2E 08                  LD   l,8          ; Offset 8 for outer loop
0513   28 09                  JR   z,loopVar    ; Handle j variable

LOOPVAR:      
051E   26 00                  LD   h,0          ; Clear H
0520   DD 54                  LD   d,ixh        ; Get loop frame pointer
0522   DD 5D                  LD   e,ixl
0524   19                     ADD   hl,de       ; Add offset (8 for j)
0525   C3 0C 04               JP   var1         ; Handle as variable
```

Example usage in nested loops:
```
5 (            ; Outer loop - j
  3 (          ; Inner loop - i
    `/j=/i: `  ; Print label
    /j .       ; Print outer counter
    ` `       ; Space
    /i .       ; Print inner counter
    /N         ; Newline
  )
)
```

This will print:
```
/j=/i: 0 0
/j=/i: 0 1
/j=/i: 0 2
/j=/i: 1 0
/j=/i: 1 1
/j=/i: 1 2
...etc
```

Would you like me to show more examples of using `/j` with `/i` in nested loops?

Here are more examples of using `/j` with `/i` in nested loops:

```
; Multiplication table with formatting
10 (                   ; Outer loop (j) - rows
  /j 0 = (            ; If first row, print header
    `   `             ; Space for alignment
    10 (              ; Print column headers
      /i 1 + 3 .R     ; Right-aligned numbers
    ) /N
    `   `             ; Separator line
    30 (              ; Print 30 dashes
      `-`
    ) /N
  )
  /j 1 + 2 .R ` |`    ; Print row number and separator
  10 (                ; Inner loop (i) - columns
    /j 1 + /i 1 + *   ; Multiply (row+1)*(col+1)
    4 .R              ; Print right-aligned
  )
  /N                  ; New line after each row
)

; Create checkerboard pattern
8 (                    ; 8 rows
  8 (                  ; 8 columns
    /i /j + 1 AND     ; If sum of indices is odd
    ( `▓` ) ( `░` )   ; Print dark or light square
  )
  /N
)

; Create pyramid pattern
10 (                   ; Height
  /j 9 SWAP - (       ; Spaces before stars
    ` `
  )
  /j 1 + 2 * (        ; Stars (2n+1 per row)
    `*`
  )
  /N
)
```

More complex example using arrays:
```
; Create 2D array with row/column sums
: MATRIX
  5 (                  ; 5 rows
    [                  ; Create row array
      5 (              ; 5 columns
        /i /j +        ; Value is sum of indices
      )
      DUP /S          ; Get size
      0 SWAP (        ; Sum all elements
        DUP ROT +     ; Add to sum
      ) SWAP DROP     ; Keep sum
    ]                 ; Push row with sum
  )
;
```

Would you like to see:
1. More pattern examples?
2. How to process these 2D structures?
3. Different mathematical patterns using both indices?

   



  
