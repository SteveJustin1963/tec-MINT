# MINT-Octave User Manual
**Version 2.5 - Multi-line Function Definition Support**  
*A 64-bit Floating Point Implementation of MINT in GNU Octave*

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Installation and Starting](#2-installation-and-starting)
3. [Key Differences from Original MINT](#3-key-differences-from-original-mint)
4. [Basic Concepts](#4-basic-concepts)
5. [Number Formats](#5-number-formats)
6. [Stack Operations](#6-stack-operations)
7. [Arithmetic Operations](#7-arithmetic-operations)
8. [Comparison and Logical Operations](#8-comparison-and-logical-operations)
9. [Variables](#9-variables)
10. [Arrays](#10-arrays)
11. [Control Flow](#11-control-flow)
12. [Functions](#12-functions)
13. [Input and Output](#13-input-and-output)
14. [Debug Mode](#14-debug-mode)
15. [Complete Examples](#15-complete-examples)
16. [Operator Reference](#16-operator-reference)
17. [Troubleshooting](#17-troubleshooting)

---

## 1. Introduction

MINT-Octave is a Forth-like concatenative language interpreter implemented in GNU Octave/MATLAB. It provides a minimalist, stack-based programming environment suitable for scientific computing, mathematical exploration, and learning about concatenative programming paradigms.

### What is MINT?

MINT (Minimal Interpreter) was originally designed as a compact, byte-code interpreter for Z80-based systems. This Octave implementation maintains the spirit and syntax of MINT while leveraging modern 64-bit floating-point arithmetic for scientific computation.

### Features

- **Reverse Polish Notation (RPN)** - Natural expression of mathematical operations
- **64-bit Floating Point** - Scientific-grade precision (±1.8e308 range)
- **Stack-Based Architecture** - Efficient manipulation of data
- **Function Definitions** - Reusable code with uppercase letter names (A-Z)
- **Arrays** - Dynamic array creation and manipulation
- **Control Flow** - Loops, conditionals, and break statements
- **Debug Mode** - Comprehensive execution tracing
- **Multi-line Functions** - Write complex functions across multiple lines

---

## 2. Installation and Starting

### Prerequisites

- GNU Octave 4.0 or later (or MATLAB with minor modifications)
- Basic understanding of command-line interfaces

### Starting MINT-Octave

1. Save the `mint_octave.m` file to your working directory
2. Launch Octave
3. Run the interpreter:

```octave
mint_octave()
```

4. You'll be prompted to enable debug mode:

```
MINT-Octave REPL v2.5 (2025-10-01). Type 'bye' to quit.
Enable debug mode? (y/n): 
```

5. The REPL prompt appears:

```
> 
```

### Exiting

Type `bye` at the prompt:

```
> bye
```

---

## 3. Key Differences from Original MINT

### Enhanced Features

| Feature | Original MINT | MINT-Octave |
|---------|---------------|-------------|
| **Number Type** | 16-bit signed integers | 64-bit floating point |
| **Number Range** | -32768 to 32767 | ±1.8e308 |
| **Decimal Precision** | Integer only | 15-16 significant digits |
| **Arrays** | 16-bit integers | 64-bit floats |
| **Scientific Notation** | Not supported | Supported (1.23e+36) |
| **Multi-line Functions** | Not applicable | Supported |
| **Debug Mode** | Not available | Interactive toggle |
| **Comments** | End of line only | Anywhere in immediate mode |

### Syntax Compatibility

✅ **Fully Compatible:**
- RPN notation
- Stack operations (`'`, `"`, `$`, `%`)
- Arithmetic operators (`+`, `-`, `*`, `/`)
- Comparison operators (`>`, `<`, `=`)
- Bitwise operators (`&`, `|`, `^`, `~`, `{`, `}`)
- Variable syntax (`a` through `z`)
- Function definitions (`:A` ... `;`)
- Loop syntax (`n(...)`)
- Conditional syntax (`condition (...) /E (...)`)
- Array syntax (`[1 2 3]`)

⚠️ **Modified Behavior:**
- Division produces floating-point results
- No 16-bit overflow wrapping
- Carry flag `/c` behavior simplified
- Hex numbers display with 4 digits minimum

❌ **Not Yet Implemented:**
- Byte mode (`\`, `\!`, `\[`, `\?`)
- Anonymous functions (`:@`)
- Port I/O (`/I`, `/O`)
- Machine code execution (`/X`, `/G`)
- Some system variables (`/h`, `/k`, `/s`, `/z`, `/V`)

---

## 4. Basic Concepts

### Reverse Polish Notation (RPN)

MINT uses RPN, where operators follow their operands:

**Traditional Math:**
```
(3 + 4) * 5 = 35
```

**RPN in MINT:**
```
> 3 4 + 5 *
```

### The Stack

The stack is a Last-In-First-Out (LIFO) data structure where:
- Numbers are **pushed** onto the top
- Operations **pop** values from the top
- Results are **pushed** back

**Example:**
```
> 10 20 30
```
Stack state: `[10 20 30]` (30 is on top)

```
> +
```
Pops 30 and 20, pushes 50  
Stack state: `[10 50]`

```
> .
```
Pops and prints 50  
Stack state: `[10]`

### Prompt System

- **Normal mode:** `> ` - Ready for immediate execution
- **Capture mode:** `... ` - Accumulating multi-line function definition

---

## 5. Number Formats

### Decimal Numbers

Standard decimal notation with full floating-point support:

```
> 123 .
   123
> -456 .
  -456
> 3.14159 .
   3.1415900000000002
> 1.23e+36 .
   1.2300000000000000e+36
```

### Scientific Notation

For very large or small numbers:

```
> 6.022e23 .          # Avogadro's number
   6.0220000000000000e+23
> 1.602e-19 .         # Electron charge
   1.6020000000000001e-19
```

### Hexadecimal Numbers

Prefix with `#` for hex input:

```
> #FF .               # Decimal output
   255
> #FF ,               # Hex output
00FF 
> #1F3A ,
1F3A 
```

### Display Format

MINT-Octave uses `format long` for scientific precision:

```
> 355 113 / .
   3.1415929203539825
```

To see full precision, the number is displayed with 16 significant digits.

---

## 6. Stack Operations

### Drop (`'`)

Removes the top item from the stack:

```
> 10 20 30
> '                   # Drop 30
> . .
   20
   10
```

**Effect:** `m n -- m`

### Duplicate (`"`)

Copies the top item:

```
> 5
> "                   # Duplicate 5
> . .
   5
   5
```

**Effect:** `n -- n n`

### Swap (`$`)

Exchanges the top two items:

```
> 10 20
> $                   # Swap positions
> . .
   10
   20
```

**Effect:** `m n -- n m`

### Over (`%`)

Copies the second item to the top:

```
> 10 20
> %                   # Copy 10 to top
> . . .
   10
   20
   10
```

**Effect:** `m n -- m n m`

### Stack Depth (`/D`)

Returns the number of items on the stack:

```
> 1 2 3 4 5
> /D .
   5
```

**Effect:** `-- n`

---

## 7. Arithmetic Operations

### Addition (`+`)

```
> 10 20 + .
   30
> 3.5 2.7 + .
   6.2000000000000002
```

Sets `/c` carry flag (always 0 in 64-bit mode).

### Subtraction (`-`)

```
> 50 30 - .
   20
> 10 20 - .
  -10
```

### Multiplication (`*`)

```
> 5 6 * .
   30
> 2.5 4.0 * .
   10
```

Sets `/r` overflow flag (always 0 in 64-bit mode).

### Division (`/`)

Integer division with remainder stored in `/r`:

```
> 17 5 / .
   3
> /r .
   2
```

For true floating-point division, use variables:

```
> 17 a ! 5 b ! a b / .
   3.3999999999999999
```

### Using System Variables

```
> 100 7 / .           # Quotient
   14
> /r .                # Remainder
   2
```

---

## 8. Comparison and Logical Operations

### Comparison Operators

MINT uses **-1** for TRUE and **0** for FALSE.

#### Greater Than (`>`)

```
> 10 5 > .
  -1                  # True
> 5 10 > .
   0                  # False
```

#### Less Than (`<`)

```
> 5 10 < .
  -1                  # True
> 10 5 < .
   0                  # False
```

#### Equal (`=`)

```
> 10 10 = .
  -1                  # True
> 10 5 = .
   0                  # False
```

### Boolean Constants

```
> /T .                # True constant
  -1
> /F .                # False constant
   0
```

### Bitwise Operations

#### AND (`&`)

```
> #FF #0F & ,
000F 
> 12 7 & .            # Binary: 1100 & 0111 = 0100
   4
```

#### OR (`|`)

```
> #F0 #0F | ,
00FF 
> 12 3 | .            # Binary: 1100 | 0011 = 1111
   15
```

#### XOR (`^`)

```
> #FF #AA ^ ,
0055 
> 12 10 ^ .           # Binary: 1100 ^ 1010 = 0110
   6
```

#### NOT (`~`)

```
> #00FF ~ ,
FF00 
> 0 ~ ,
FFFF 
```

#### Shift Left (`{`)

```
> 1 { ,               # Multiply by 2
0002 
> 1 { { { ,           # Multiply by 8
0008 
```

#### Shift Right (`}`)

```
> #10 } ,             # Divide by 2
0008 
```

---

## 9. Variables

### Single-Letter Variables

MINT provides 26 global variables named `a` through `z`.

### Storing Values

Use the `!` operator after pushing a value and specifying a variable:

```
> 42 x !              # Store 42 in x
> x .                 # Retrieve and print
   42
```

**Syntax:** `value variable !`

### Using Variables

Simply reference the variable name:

```
> 10 a !
> 20 b !
> a b + .
   30
```

### Variable Operations

```
> 100 count !
> count 1 + count !   # Increment count
> count .
   101
```

### Multiple Assignments

```
> 5 x ! 10 y ! 15 z !
> x y z + + .
   30
```

---

## 10. Arrays

### Creating Arrays

Use square brackets with space-separated values:

```
> [1 2 3 4 5] arr !
```

**Important:** Spaces are required around brackets and between elements.

### Array Elements

Arrays can contain:
- Decimal numbers: `[1 2 3]`
- Hex numbers: `[#FF #AA #55]`
- Variables: `[a b c]`
- Mixed: `[1 x #FF]`

### Accessing Array Elements

Use `?` with array address and index:

```
> [10 20 30 40] data !
> data 0 ? .          # First element (index 0)
   10
> data 2 ? .          # Third element
   30
```

**Syntax:** `array index ?`

### Modifying Array Elements

Use `?!` to set an element:

```
> [0 0 0] nums !
> 42 nums 1 ?!        # Set nums[1] = 42
> nums 1 ? .
   42
```

**Syntax:** `value array index ?!`

### Array Size

Use `/S` to get the number of elements:

```
> [1 2 3 4 5] /S .
   5
```

### Array Examples

#### Initialize and fill:
```
> [0 0 0 0 0] data !
> 10 data 0 ?!
> 20 data 1 ?!
> 30 data 2 ?!
> data 0 ? data 1 ? data 2 ? + + .
   60
```

#### Using variables in arrays:
```
> 5 a ! 10 b ! 15 c !
> [a b c] nums !
> nums 0 ? .
   5
```

#### Floating-point arrays:
```
> [3.14159 2.71828 1.41421] constants !
> constants 0 ? .
   3.1415900000000002
```

---

## 11. Control Flow

### Loops

#### Basic Loop Syntax

Execute code `n` times:

```
> 5 ( `Hello ` )
Hello Hello Hello Hello Hello 
```

**Syntax:** `count ( code )`

#### Loop Counter (`/i`)

Access the current iteration (0-based):

```
> 5 ( /i . )
   0
   1
   2
   3
   4
```

#### Nested Loops

Inner loop uses `/i`, outer loop uses `/j`:

```
> 3 ( /j . `: ` 2 ( /i . ) /N )
   0: 0 1
   1: 0 1
   2: 0 1
```

#### Unlimited Loops (`/U`)

Loop forever (until broken by `/W`):

```
> 0 count !
> /U (
  count .
  count 1 + count !
  count 5 = /W        # Break when count equals 5
)
   0
   1
   2
   3
   4
```

#### While Break (`/W`)

Break out of loop if top of stack is FALSE (0):

```
> 0 i !
> /U (
  i .
  i 1 + i !
  i 10 < /W           # Continue while i < 10
)
```

### Conditionals (If-Then-Else)

#### Basic Syntax

```
condition ( then-code ) /E ( else-code )
```

#### Examples

```
> 10 5 > ( `Greater` ) /E ( `Not greater` )
Greater

> 3 x !
> x 5 < ( `Less than 5` ) /E ( `5 or more` )
Less than 5
```

#### Nested Conditionals

```
> 15 age !
> age 18 >= ( 
  `Adult` 
) /E (
  age 13 >= (
    `Teenager`
  ) /E (
    `Child`
  )
)
Teenager
```

#### Boolean Logic

```
> 10 x !
> x 5 > x 15 < & (    # If x > 5 AND x < 15
  `In range`
) /E (
  `Out of range`
)
In range
```

---

## 12. Functions

### Defining Functions

Functions are named with single uppercase letters (A through Z).

#### Single-Line Functions

```
> :F " * ;            # Square function
> 5 F .
   25
```

#### Multi-Line Functions

MINT-Octave supports multi-line function definitions:

```
> :G
... 10 (
...   /i .
... )
... ;
> G
   0 1 2 3 4 5 6 7 8 9
```

When you type `:G`, the prompt changes to `...` indicating capture mode. Type `;` to complete the definition.

### Calling Functions

Simply use the function name:

```
> :A 2 * ;            # Double function
> 21 A .
   42
```

### Function Examples

#### Factorial Function

```
> :F
... n !               
... n 0 = (           
...   1               
... ) /E (            
...   0 /c !          
...   1 r !           
...   n 1 + i !       
...   /U (            
...     i 1 - i !     
...     i 1 > /W      
...     r i * r !     
...   )
...   r
... )
... ;
> 5 F .
   120
```

#### Fibonacci Function

```
> :F
... n !
... 0 a ! 1 b !
... n (
...   a .
...   32 /C
...   a b + c !
...   b a !
...   c b !
... )
... /N
... ;
> 10 F
   0 1 1 2 3 5 8 13 21 34
```

#### Array Sum Function

```
> :S
... arr ! arr /S n !
... 0 sum !
... n (
...   arr /i ? sum + sum !
... )
... sum .
... ;
> [1 2 3 4 5] S
   15
```

### Function Composition

Functions can call other functions:

```
> :A 2 * ;            # Double
> :B 3 + ;            # Add 3
> :C A B ;            # Double then add 3
> 10 C .
   23
```

### Listing Functions

```
> list
Defined functions:
  :F n ! n 0 = ( 1 ) /E ( 0 /c ! 1 r ! n 1 + i ! /U ( i 1 - i ! i 1 > /W r i * r ! ) r ) ;
  :S arr ! arr /S n ! 0 sum ! n ( arr /i ? sum + sum ! ) sum . ;
```

---

## 13. Input and Output

### Printing Numbers

#### Print Decimal (`.`)

```
> 42 .
   42
> 3.14159 .
   3.1415900000000002
```

#### Print Hexadecimal (`,`)

```
> 255 ,
00FF 
> #ABCD ,
ABCD 
```

### Printing Text

Use backticks for literal strings:

```
> `Hello, World!`
Hello, World!
```

Strings don't need `.` to print:

```
> `Result: ` 42 .
Result:    42
```

### Printing Characters

Use `/C` with ASCII code:

```
> 65 /C               # Prints 'A'
A
> 72 101 108 108 111 /C /C /C /C /C
Hello
```

### Newlines

Use `/N` for line breaks:

```
> `Line 1` /N `Line 2` /N
Line 1
Line 2
```

### Reading Input

#### Read Character (`/K`)

Waits for single character input:

```
> /K 
a                     # User types 'a'
> .
   97                 # ASCII code for 'a'
```

#### Read String (`/KS`) - Extension

Reads entire string and pushes all ASCII codes plus length:

```
> /KS
Hello                 # User types 'Hello'
> .                   # Print length
   5
> . . . . .           # Print characters in reverse
   111 108 108 101 72
```

### Formatted Output Examples

```
> :P                  # Print formatted number
... `Value: ` . /N
... ;
> 42 P
Value:    42

> :T                  # Print table row
... `| ` . ` | ` . ` | ` . ` |` /N
... ;
> 1 2 3 T
| 1 | 2 | 3 |
```

---

## 14. Debug Mode

### Enabling Debug Mode

#### At Startup

```
Enable debug mode? (y/n): y

*** DEBUG MODE ENABLED ***
```

#### Toggle During Session

```
> debug

*** DEBUG MODE ENABLED ***
```

### Debug Output

When enabled, debug mode shows:

1. **Token Processing**
```
[DEBUG] Processing token #1: '10'
[DEBUG] NUMBER: 10
```

2. **Stack State**
```
[DEBUG] STACK: [10 20]
```

3. **Variable Changes**
```
[DEBUG] STORE: x = 42 (was 0)
```

4. **Function Calls**
```
[DEBUG] FUNCTION CALL: F
```

5. **Operations**
```
[DEBUG] BEFORE +: stack=[10 20]
[DEBUG] AFTER +: 10 + 20 = 30, stack=[30]
```

6. **Loop Iterations**
```
[DEBUG] LOOP START: count=5, stack_depth=0
[DEBUG] LOOP ITERATION: i=0, j=0
```

7. **Array Operations**
```
[DEBUG] ARRAY CREATE: addr=1, size=3, elements=[1 2 3]
[DEBUG] ARRAY GET: addr=1, idx=0 -> value=1
```

### Debug Example Session

```
> debug

*** DEBUG MODE ENABLED ***

> 10 20 + .

=== EXECUTING LINE: 10 20 + . ===
[DEBUG] TOKENS: '10' '20' '+' '.' 
[DEBUG] Processing token #1: '10'
[DEBUG] NUMBER: 10
[DEBUG] Processing token #2: '20'
[DEBUG] NUMBER: 20
[DEBUG] Processing token #3: '+'
[DEBUG] BUILTIN: +
[DEBUG] BEFORE +: stack=[10 20]
[DEBUG] AFTER +: 10 + 20 = 30, stack=[30]
[DEBUG] Processing token #4: '.'
[DEBUG] BUILTIN: .
   30

[DEBUG] === FINAL STATE ===
[DEBUG] STACK: (empty)
[DEBUG] VARIABLES:
[DEBUG] SYSTEM: /c=0, /r=0, /i=0, /j=0
[DEBUG] ====================
```

### Disabling Debug Mode

```
> debug

*** DEBUG MODE DISABLED ***
```

---

## 15. Complete Examples

### Example 1: Temperature Converter

```
> :C                  # Celsius to Fahrenheit
... c !
... c 9 * 5 / 32 + f !
... `C: ` c . /N
... `F: ` f . /N
... ;
> 25 C
C:    25
F:    77
```

### Example 2: Array Statistics

```
> :M                  # Mean of array
... arr ! arr /S n !
... 0 sum !
... n ( arr /i ? sum + sum ! )
... sum n / .
... ;
> [10 20 30 40 50] M
   30
```

### Example 3: Prime Checker

```
> :P                  # Check if prime
... n !
... n 2 < (
...   /F              # Not prime if < 2
... ) /E (
...   /T isprime !    # Assume prime
...   2 i !
...   /U (
...     i i * n > /W  # Break when i² > n
...     n i % 0 = (   # If divisible
...       /F isprime !
...       999 i !      # Force break
...     )
...     i 1 + i !
...   )
...   isprime
... )
... . /N
... ;
> 17 P
  -1                  # True - 17 is prime
> 15 P
   0                  # False - 15 is not prime
```

### Example 4: Bubble Sort

```
> :S                  # Bubble sort array
... arr ! arr /S n !
... /U (
...   /F swapped !
...   n 1 - (
...     arr /i ? curr !
...     arr /i 1 + ? next !
...     curr next > (
...       next arr /i ?!
...       curr arr /i 1 + ?!
...       /T swapped !
...     )
...   )
...   swapped /W
... )
... ;
> [5 2 8 1 9] arr !
> arr S
> arr /S ( arr /i ? . )
   1   2   5   8   9
```

### Example 5: Matrix Operations

```
> :A                  # Add two 2x2 matrices
... [1 2 3 4] m1 !
... [5 6 7 8] m2 !
... [0 0 0 0] result !
... 4 (
...   m1 /i ? m2 /i ? + result /i ?!
... )
... result
... ;
> A /S ( " /i ? . )
   6   8   10   12
```

### Example 6: Recursive GCD

```
> :G                  # Greatest Common Divisor
... b ! a !
... b 0 = (
...   a
... ) /E (
...   a b % b G
... )
... ;
> 48 18 G .
   6
```

### Example 7: Number Guessing Game

```
> :N
... 42 secret !       # Secret number
... /T playing !
... /U (
...   `Guess: ` /K 48 - guess !
...   guess secret = (
...     `Correct!` /N
...     /F playing !
...   ) /E (
...     guess secret < (
...       `Too low` /N
...     ) /E (
...       `Too high` /N
...     )
...   )
...   playing /W
... )
... ;
```

### Example 8: Stack Calculator

```
> :R                  # RPN calculator
... `Enter operation (+,-,*,/,=): `
... /K op !
... op 43 = ( + )    # +
... op 45 = ( - )    # -
... op 42 = ( * )    # *
... op 47 = ( / )    # /
... op 61 = ( . )    # =
... ;
> 10 20 R
Enter operation (+,-,*,/,=): +
> R
Enter operation (+,-,*,/,=): =
   30
```

---

## 16. Operator Reference

### Complete Operator Table

| Category | Operator | Description | Stack Effect | Status |
|----------|----------|-------------|--------------|--------|
| **Numbers** | `123` | Decimal number | `-- n` | ✅ |
| | `-456` | Negative number | `-- n` | ✅ |
| | `3.14` | Floating point | `-- n` | ✅ |
| | `1e+36` | Scientific notation | `-- n` | ✅ |
| | `#FF` | Hexadecimal | `-- n` | ✅ |
| **Arithmetic** | `+` | Addition | `n n -- n` | ✅ |
| | `-` | Subtraction | `n n -- n` | ✅ |
| | `*` | Multiplication | `n n -- n` | ✅ |
| | `/` | Division | `n n -- n` | ✅ |
| **Stack** | `'` | Drop | `n --` | ✅ |
| | `"` | Duplicate | `n -- n n` | ✅ |
| | `$` | Swap | `m n -- n m` | ✅ |
| | `%` | Over | `m n -- m n m` | ✅ |
| | `/D` | Depth | `-- n` | ✅ |
| **Comparison** | `>` | Greater than | `n n -- b` | ✅ |
| | `<` | Less than | `n n -- b` | ✅ |
| | `=` | Equal | `n n -- b` | ✅ |
| **Bitwise** | `&` | AND | `n n -- n` | ✅ |
| | `\|` | OR | `n n -- n` | ✅ |
| | `^` | XOR | `n n -- n` | ✅ |
| | `~` | NOT | `n -- n` | ✅ |
| | `{` | Shift left | `n -- n` | ✅ |
| | `}` | Shift right | `n -- n` | ✅ |
| **Variables** | `a-z` | Variable access | `-- n` | ✅ |
| | `!` | Store | `n v --` | ✅ |
| **Arrays** | `[...]` | Create array | `-- a` | ✅ |
| | `?` | Get element | `a n -- n` | ✅ |
| | `?!` | Set element | `n a n --` | ✅ |
| | `/S` | Size | `a -- n` | ✅ |
| **Control** | `(` | Begin loop | `n --` | ✅ |
| | `)` | End loop | `--` | ✅ |
| | `/E` | Else | `--` | ✅ |
| | `/W` | While | `b --` | ✅ |
| | `/U` | Unlimited | `-- -1` | ✅ |
| | `/T` | True | `-- -1` | ✅ |
| | `/F` | False | `-- 0` | ✅ |
| | `/i` | Loop counter | `-- n` | ✅ |
| | `/j` | Outer counter | `-- n` | ✅ |
| **Functions** | `:A...;` | Define function | `--` | ✅ |
| **System** | `/c` | Carry flag | `-- n` | ✅ |
| | `/r` | Remainder | `-- n` | ✅ |
| **I/O** | `.` | Print decimal | `n --` | ✅ |
| | `,` | Print hex | `n --` | ✅ |
| | `` ` `` | Print string | `--` | ✅ |
| | `/C` | Print char | `n --` | ✅ |
| | `/N` | Print newline | `--` | ✅ |
| | `/K` | Read char | `-- n` | ✅ |
| | `/KS` | Read string | `-- n...n` | ✅ |
| **Utility** | `//` | Comment | `--` | ✅ |
| | `help` | Show help | `--` | ✅ |
| | `list` | List functions | `--` | ✅ |
| | `debug` | Toggle debug | `--` | ✅ |
| | `bye` | Exit REPL | `--` | ✅ |

### System Variables

| Variable | Description | Access |
|----------|-------------|--------|
| `/c` | Carry flag (from +/-) | Read |
| `/r` | Remainder (from /) or overflow (from *) | Read |
| `/i` | Inner loop counter (0-based) | Read |
| `/j` | Outer loop counter (0-based) | Read |

---

## 17. Troubleshooting

### Common Errors

#### Stack Underflow

**Error:** `STACK UNDERFLOW`

**Cause:** Trying to pop from empty stack

**Solution:**
```
> + .                 # ERROR - no operands!
ERROR: STACK UNDERFLOW

> 10 20 + .           # Correct
   30
```

#### Division by Zero

**Error:** `DIVISION BY ZERO`

**Cause:** Dividing by 0

**Solution:**
```
> 10 0 /              # ERROR!
ERROR: DIVISION BY ZERO

> 10 5 / .            # Correct
   2
```

#### Unknown Word

**Error:** `Unknown word: xyz`

**Cause:** Undefined function or typo

**Solution:**
```
> XYZ                 # ERROR - function not defined!
ERROR: Unknown word: XYZ

> :X 42 . ;           # Define it first
> X
   42
```

#### Array Index Out of Bounds

**Error:** `Array index out of bounds`

**Cause:** Accessing invalid array index

**Solution:**
```
> [1 2 3] arr !
> arr 5 ? .           # ERROR - only indices 0-2 exist!
ERROR: Array index out of bounds: 5 (size=3)

> arr 2 ? .           # Correct
   3
```

#### Unclosed Array

**Error:** `Unclosed array - missing ]`

**Cause:** Missing closing bracket

**Solution:**
```
> [1 2 3              # ERROR!
ERROR: Unclosed array - missing ]

> [1 2 3] arr !       # Correct
```

#### Store Without Variable

**Error:** `! requires a variable before it`

**Cause:** Using `!` without specifying variable

**Solution:**
```
> 10 !                # ERROR!
ERROR: ! requires a variable before it (e.g., 10 x !)

> 10 x !              # Correct
```

### Tips and Best Practices

1. **Use Debug Mode** when learning or troubleshooting:
   ```
   > debug
   ```

2. **Check Stack State** with `/D`:
   ```
   > /D .              # How many items?
   ```

3. **Test Functions** incrementally:
   ```
   > :T 1 2 + . ;      # Simple test
   > T
      3
   ```

4. **Use Comments** in multi-line functions:
   ```
   > :F                # Only in multi-line mode!
   ... // This is safe
   ... ;
   ```

5. **Clear Stack** if needed:
   ```
   > /D ( ' )          # Drop all items
   ```

6. **Save Work** by copying function definitions:
   ```
   > list              # Shows all functions
   ```

7. **Array Spacing** is critical:
   ```
   > [1 2 3]           # ✅ Correct
   > [1  2  3]         # ✅ Also correct
   > [123]             # ✅ Single element
   ```

8. **Variable Names** are case-sensitive:
   ```
   > 10 x !            # lowercase variable
   > :X . ;            # uppercase function
   ```

### Performance Considerations

1. **Floating Point Precision**: Results may have small rounding errors:
   ```
   > 0.1 0.2 + .
      0.30000000000000004
   ```

2. **Large Numbers**: No integer overflow like original MINT:
   ```
   > 1e100 1e100 * .
      1.0000000000000000e+200
   ```

3. **Array Size**: Limited by Octave's memory:
   ```
   > 1000000 /A        # Not implemented yet
   ```

---

## Appendix A: Quick Reference Card

```
NUMBERS           STACK OPS       ARITHMETIC      COMPARISON
123    decimal    '   drop        +   add         >   greater
-456   negative   "   dup         -   subtract    <   less
3.14   float      $   swap        *   multiply    =   equal
#FF    hex        %   over        /   divide
1e+36  scientific /D  depth

BITWISE           VARIABLES       ARRAYS          CONTROL FLOW
&   AND           a-z  vars       [...]  create   n(...)    loop
|   OR            !    store      ?      get      /U        unlimited
^   XOR                           ?!     set      /W        while break
~   NOT                           /S     size     /E        else
{   shift left                                    /T /F     true/false
}   shift right                                   /i /j     counters

FUNCTIONS         I/O             SYSTEM          UTILITY
:A...;  define    .   print dec   /c  carry      help   show help
A       call      ,   print hex   /r  remainder  list   list funcs
                  `   string                     debug  toggle debug
                  /C  print char                 bye    exit
                  /N  newline
                  /K  read char
```

---

## Appendix B: Differences from Forth

While MINT shares many concepts with Forth, there are key differences:

| Feature | MINT | Forth |
|---------|------|-------|
| Function names | Single uppercase letter | Multi-character words |
| Loop syntax | `n(...)` | `DO...LOOP` |
| Conditional | `(...)/E(...)` | `IF...ELSE...THEN` |
| Variables | Single lowercase letter | Named with `VARIABLE` |
| Comments | `//` | `( comment )` or `\ comment` |
| String literals | `` `text` `` | `." text"` or `S" text"` |
| Array syntax | `[1 2 3]` | Not built-in |
| True/False | -1/0 | -1/0 or 1/0 (varies) |

---

## Appendix C: ASCII Table Reference

For use with `/C` and `/K`:

```
32 = space    48-57 = 0-9      65-90  = A-Z     97-122 = a-z
10 = newline  33 = !  43 = +   91 = [  93 = ]   123 = { 125 = }
13 = return   34 = "  45 = -   40 = (  41 = )   126 = ~
```

---

## Conclusion

MINT-Octave provides a powerful yet minimalist environment for stack-based programming with scientific computing capabilities. Its simple syntax, combined with 64-bit floating-point precision, makes it suitable for:

- Learning concatenative programming concepts
- Quick mathematical calculations
- Algorithm prototyping
- Educational demonstrations
- Stack-based problem solving

**Happy MINTing!** 🚀

For questions, issues, or contributions, refer to the source code comments or create your own extensions to the interpreter.

---

*Manual Version 2.5 - Updated for multi-line function support and enhanced debugging*
