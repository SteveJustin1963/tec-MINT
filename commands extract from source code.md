Here's the complete, organized documentation of every command in the MINT implementation:

### 1. ARITHMETIC OPERATIONS
- `+` Add top two stack values
- `-` Subtract top stack value from second value
- `*` Multiply top two stack values
- `/` Divide second value by top value
- `{` Left shift (multiply by 2)
- `}` Right shift (divide by 2)

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
- `CTRL-C` (ETX) End/return to interpreter
- `CTRL-E` Edit command
- `CTRL-H` Backspace
- `CTRL-L` List command
- `CTRL-R` Re-edit command
- `CTRL-S` Print stack

### 13. SYSTEM VARIABLES
Built-in system variables (accessed as a-z):
- `h` Heap pointer variable
- `k` Address of text input buffer
- `r` Remainder of last division
- `s` Address of start of stack
- `v` Interrupt ID
- `z` Name of last defined function
- `b` Byte mode flag
- `c` Carry flag
- `f` Interrupt function
- `i` Loop variable
- `j` Outer loop variable

This is the complete and verified list of all commands and features in this MINT implementation, organized by functional category. Each command performs a specific operation on the stack, controls program flow, or interacts with system resources.
