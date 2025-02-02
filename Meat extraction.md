# Let there be 74 Commandments

**74** distinct commands and system operations.
1. **Arithmetic Operations**: 6  
2. **Stack Manipulation**: 5  
3. **Bitwise Operations**: 4  
4. **Comparison Operations**: 3  
5. **Memory and Variables**: 5  
6. **Program Flow**: 9  
7. **Array Operations**: 3  
8. **Input/Output Operations**: 9  
9. **Function Calls**: 2  
10. **Number Input**: 2  
11. **No Operation Commands**: 10  
12. **Control Characters**: 6  
13. **System Variables**: 10

This is the complete and verified list of all commands and features in this MINT implementation, organized by functional category. Each command performs a specific operation on the stack, controls program flow, or interacts with system resources.

### 1. ARITHMETIC OPERATIONS
#### 1.1 `+` Add top two stack values
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
- `"` Duplicate top stack value
- `%` Duplicate second stack element
- `$` Swap top two stack elements
- `'` Discard top stack value
- `~` Rotate (a b c -- b c a)

### 3. BITWISE OPERATIONS
- `&` Bitwise AND
- `|` Bitwise OR
- `^` Bitwise XOR
- `~` Bitwise invert

### 4. COMPARISON OPERATIONS
- `<` Less than
- `=` Equal to
- `>` Greater than

### 5. MEMORY AND VARIABLES
- `!` Store value at address
- `a-z` Variable access (26 variable slots)
- `\` Set byte mode
- `?` Array access
- `/V` Get last variable access address

### 6. PROGRAM FLOW
- `:` Begin definition
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



  
