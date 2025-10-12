# MINT-Octave Complete User Manual
## Version 2.7 (2025-10-13)

---

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Core Concepts](#core-concepts)
4. [Number Formats](#number-formats)
5. [Stack Operations](#stack-operations)
6. [Arithmetic Operations](#arithmetic-operations)
7. [Trigonometric Functions](#trigonometric-functions)
8. [Comparison and Logical Operations](#comparison-and-logical-operations)
9. [Variables](#variables)
10. [Arrays](#arrays)
11. [Control Flow](#control-flow)
12. [Functions](#functions)
13. [Temporary Blocks](#temporary-blocks)
14. [Multi-Line Input](#multi-line-input)
15. [Input/Output](#inputoutput)
16. [System Variables](#system-variables)
17. [Processor Flags](#processor-flags)
18. [Debug Mode](#debug-mode)
19. [Complete Command Reference](#complete-command-reference)
20. [Examples](#examples)
21. [Tips and Tricks](#tips-and-tricks)
22. [Common Pitfalls](#common-pitfalls)
23. [Quick Reference Card](#quick-reference-card)
24. [Differences from Original MINT](#differences-from-original-mint)
25. [Credits and License](#credits-and-license)
26. [Appendix: ASCII Reference](#appendix-ascii-reference)
27. [Appendix: Error Messages](#appendix-error-messages)

---

## Introduction

MINT-Octave is a stack-based programming language interpreter inspired by Forth and MINT. It uses Reverse Polish Notation (RPN) and operates on a stack data structure. This Octave implementation extends the original MINT with 64-bit floating-point arithmetic, trigonometric functions, and enhanced debugging capabilities.

**Key Features:**
- Stack-based computation (RPN)
- 64-bit floating-point arithmetic
- Integer modes (8, 16, 32, 64-bit) for hardware compatibility
- Processor flags (/c, /v, /z, /n) for overflow detection
- 26 variables (a-z)
- User-defined functions (A-Z)
- Temporary execution blocks (:_)
- Multi-line function definitions with continuation prompts
- Arrays with heap storage (4096 locations)
- Loops and conditionals
- Comprehensive trigonometric functions
- Debug mode with file logging
- Inline comments with //

---

## Getting Started

### Running MINT-Octave

1. Load the program in Octave:
   ```octave
   mint_octave_15
   ```

2. Choose debug mode when prompted:
   ```
   Enable debug mode? (y/n): n
   ```

3. You'll see the MINT prompt:
   ```
   > 
   ```

4. Exit by typing:
   ```
   bye
   ```

### Your First MINT Program

```mint
5 3 + .
8 
```

This pushes 5 and 3 onto the stack, adds them, and prints the result.

---

## Core Concepts

### The Stack

MINT uses a **stack** - a Last-In-First-Out (LIFO) data structure. Operations typically:
1. Pop operands from the stack
2. Perform computation
3. Push results back onto the stack

**Example:**
```mint
10
// Stack: [10]
20
// Stack: [10, 20]
+
// Stack: [30]
.
// Print: 30, Stack: []
```

### Reverse Polish Notation (RPN)

Instead of `3 + 4`, you write `3 4 +`. Operands come first, operators follow.

**Traditional:** `(5 + 3) * 2`  
**MINT:** `5 3 + 2 *`

### Stack Effect Notation

Documentation uses this notation:
- `n n -- n` means: takes two numbers, returns one number
- `-- n` means: takes nothing, returns one number
- `n --` means: takes one number, returns nothing

---

## Number Formats

### Decimal Numbers

MINT-Octave uses **64-bit floating-point** numbers by default, with optional integer modes:

```mint
42 .
// 42 

3.14159 .
// 3.14159 

-273.15 .
// -273.15 

1.23e+36 .
// 1.23e+36 

-5.67e-12 .
// -5.67e-12 
```

**Range:** ±1.8e308 (much larger than original MINT's 16-bit limit)

**Precision:** 15-16 significant digits (format long)

### Integer Modes

MINT-Octave supports multiple integer modes for hardware compatibility:

```mint
int8      // 8-bit signed: -128 to 127
int16     // 16-bit signed: -32,768 to 32,767 (MINT 2/TEC-1 compatible)
int32     // 32-bit signed: -2.1 billion to 2.1 billion
int64     // 64-bit signed: ±9.2 quintillion
fp        // Floating-point mode (default)
mode      // Show current mode
```

**Example:**
```mint
int8
127 1 + .    // -128 (8-bit overflow)
fp
127 1 + .    // 128 (no overflow)
```

### Hexadecimal Numbers

Prefix with `#` for hexadecimal:

```mint
#FF .
// 255 

#1A2B .
// 6699 

#FFFF .
// 65535 
```

**Note:** Hex display (`,` operator) masks to 16-bit (0000-FFFF)

---

## Stack Operations

### ' (Drop)
**Effect:** `n -- `  
Removes the top item from the stack.

```mint
10 20 30 '
// Stack: [10, 20]
.
// Prints: 20 
```

### " (Dup)
**Effect:** `n -- n n`  
Duplicates the top item.

```mint
5 " . .
// Prints: 5 5 
```

### $ (Swap)
**Effect:** `n m -- m n`  
Swaps the top two items.

```mint
10 20 $ . .
// Prints: 20 10 
```

### % (Over)
**Effect:** `n m -- n m n`  
Copies the second item to the top.

```mint
10 20 % . . .
// Prints: 10 20 10 
```

### /D (Stack Depth)
**Effect:** `-- n`  
Pushes the current stack depth.

```mint
1 2 3 /D .
// 3 
```

### /CS (Clear Stack)
**Effect:** `... -- `  
Clears the entire stack.

```mint
1 2 3 4 5 /CS
// Stack is now empty
/D .
// 0 
```

---

## Arithmetic Operations

### Basic Arithmetic

**Addition: +**  
Effect: `n m -- result`

```mint
15 27 + .
// 42 
```

**Subtraction: -**  
Effect: `n m -- result`

```mint
50 8 - .
// 42 
```

**Multiplication: ***  
Effect: `n m -- result`

```mint
6 7 * .
// 42 
```

**Division: /**  
Effect: `n m -- result`

```mint
84 2 / .
// 42 
10 3 / .
// 3.33333 (floating-point mode)

int16
10 3 / .
// 3 (integer mode)
/r .
// 1 (remainder)
```

**Important:** Division behavior depends on mode:
- **Floating-point mode (fp):** True division with decimals
- **Integer modes (int8/16/32/64):** Integer division with remainder in `/r`

**Power: ****  
Effect: `base exponent -- result`

```mint
2 8 ** .
// 256 
5 3 ** .
// 125 
2 0.5 ** .
// 1.41421 
```

**Error handling:**
```mint
-4 0.5 **
// ERROR: Cannot raise negative to fractional power
```

### Advanced Math Functions

**Square Root: /sqrt**  
Effect: `n -- result`

```mint
144 /sqrt .
// 12 
2 /sqrt .
// 1.41421 
```

**Domain:** x ≥ 0 (error for negative numbers)

**Absolute Value: /abs**  
Effect: `n -- result`

```mint
-42 /abs .
// 42 
17 /abs .
// 17 
```

**Natural Logarithm: /ln**  
Effect: `n -- result`

```mint
/e /ln .
// 1 
2.71828 /ln .
// 1 
```

**Domain:** x > 0 (error for zero or negative)

**Base-10 Logarithm: /log**  
Effect: `n -- result`

```mint
100 /log .
// 2 
1000 /log .
// 3 
```

**Domain:** x > 0 (error for zero or negative)

**Exponential: /exp**  
Effect: `n -- result`

```mint
1 /exp .
// 2.71828 
0 /exp .
// 1 
```

### Rounding Functions

**Floor: /floor**  
Rounds down to nearest integer.

```mint
3.7 /floor .
// 3 
-2.3 /floor .
// -3 
```

**Ceiling: /ceil**  
Rounds up to nearest integer.

```mint
3.2 /ceil .
// 4 
-2.7 /ceil .
// -2 
```

**Round: /round**  
Rounds to nearest integer.

```mint
3.5 /round .
// 4 
3.4 /round .
// 3 
-2.5 /round .
// -2 
```

**Truncate: /trunc**  
Truncates toward zero.

```mint
3.9 /trunc .
// 3 
-3.9 /trunc .
// -3 
```

### Other Math Operations

**Modulo: /mod**  
Effect: `a b -- remainder`

```mint
17 5 /mod .
// 2 
100 7 /mod .
// 2 
```

**Error:** Division by zero

**Minimum: /min**  
Effect: `a b -- min`

```mint
5 3 /min .
// 3 
-10 -20 /min .
// -20 
```

**Maximum: /max**  
Effect: `a b -- max`

```mint
5 3 /max .
// 5 
-10 -20 /max .
// -10 
```

**Sign: /sign**  
Returns -1, 0, or 1.

```mint
42 /sign .
// 1 
-17 /sign .
// -1 
0 /sign .
// 0 
```

---

## Trigonometric Functions

All trig functions use **radians** by default.

### Basic Trigonometry

**Sine: /sin**  
Effect: `radians -- result`

```mint
0 /sin .
// 0 
/pi 2 / /sin .
// 1 
```

**Cosine: /cos**  
Effect: `radians -- result`

```mint
0 /cos .
// 1 
/pi /cos .
// -1 
```

**Tangent: /tan**  
Effect: `radians -- result`

```mint
0 /tan .
// 0 
/pi 4 / /tan .
// 1 
```

### Inverse Trigonometry

**Arcsine: /asin**  
Returns radians. Domain: [-1, 1]

```mint
0.5 /asin /deg .
// 30 
1 /asin .
// 1.5708 
```

**Error:** Input must be in [-1, 1]

**Arccosine: /acos**  
Returns radians. Domain: [-1, 1]

```mint
0 /acos .
// 1.5708 
1 /acos .
// 0 
```

**Error:** Input must be in [-1, 1]

**Arctangent: /atan**  
Returns radians.

```mint
1 /atan .
// 0.785398 
0 /atan .
// 0 
```

**Two-argument Arctangent: /atan2**  
Effect: `y x -- radians`

```mint
1 1 /atan2 /deg .
// 45 
1 0 /atan2 /deg .
// 90 
1 -1 /atan2 /deg .
// 135 
```

**Note:** Stack order is y (first), then x (second), matching mathematical convention atan2(y, x)

### Hyperbolic Functions

**Hyperbolic Sine: /sinh**

```mint
0 /sinh .
// 0 
1 /sinh .
// 1.1752 
```

**Hyperbolic Cosine: /cosh**

```mint
0 /cosh .
// 1 
1 /cosh .
// 1.54308 
```

**Hyperbolic Tangent: /tanh**

```mint
0 /tanh .
// 0 
1 /tanh .
// 0.761594 
```

### Inverse Hyperbolic Functions

**Inverse Hyperbolic Sine: /asinh**

```mint
1 /asinh .
// 0.881374 
```

**Inverse Hyperbolic Cosine: /acosh**  
Domain: x ≥ 1

```mint
1 /acosh .
// 0 
2 /acosh .
// 1.31696 
```

**Error:** Input must be ≥ 1

**Inverse Hyperbolic Tangent: /atanh**  
Domain: -1 < x < 1

```mint
0.5 /atanh .
// 0.549306 
```

**Error:** Input must be strictly between -1 and 1

### Angle Conversion

**Degrees to Radians: /rad**

```mint
180 /rad .
// 3.14159 
90 /rad .
// 1.5708 
45 /rad .
// 0.785398 
```

**Radians to Degrees: /deg**

```mint
/pi /deg .
// 180 
/pi 2 / /deg .
// 90 
```

### Constants

**/pi** - Push π (3.14159265...)

```mint
/pi .
// 3.14159 
/pi 2 * .
// 6.28319 
```

**/e** - Push e (2.71828...)

```mint
/e .
// 2.71828 
/e /ln .
// 1 
```

### Example: Calculate Angle

```mint
// Calculate sin(45°)
45 /rad /sin .
// 0.707107 

// Calculate angle from opposite and adjacent sides
3 4 /atan2 /deg .
// 36.8699 
```

---

## Comparison and Logical Operations

### Comparison Operators

Boolean values in MINT:
- **True:** -1
- **False:** 0

**Greater Than: >**  
Effect: `a b -- bool`

```mint
10 5 > .
// -1 

3 7 > .
// 0 
```

**Less Than: <**  
Effect: `a b -- bool`

```mint
5 10 < .
// -1 

7 3 < .
// 0 
```

**Equal: =**  
Effect: `a b -- bool`

```mint
5 5 = .
// -1 

5 6 = .
// 0 
```

### Bitwise Operations

All bitwise operations are masked to 16 bits (0-65535).

**Bitwise AND: &**  
Effect: `a b -- result`

```mint
#FF #0F & , /N
// 000F 
```

**Bitwise OR: |**  
Effect: `a b -- result`

```mint
#F0 #0F | , /N
// 00FF 
```

**Bitwise XOR: ^**  
Effect: `a b -- result`

```mint
#FF #AA ^ , /N
// 0055 
```

**Bitwise NOT: ~**  
Effect: `a -- result`

```mint
#00FF ~ , /N
// FF00 
0 ~ , /N
// FFFF 
```

**Shift Left: {**  
Effect: `n -- result`

```mint
1 { .
// 2 

5 { .
// 10 
```

**Shift Right: }**  
Effect: `n -- result`

```mint
8 } .
// 4 

5 } .
// 2 
```

---

## Variables

MINT provides 26 variables named **a** through **z**.

### Storing Values

Syntax: `value variable !`

```mint
42 x !
// Store 42 in variable x

x .
// 42 
```

**Important:** The variable must come immediately before the `!` operator. The following will cause an error:

```mint
42 ! x
// ERROR: ! requires a variable before it

x 42 !
// WRONG: stores to address 42, not variable x
```

### Using Variables

Simply type the variable name to push its value:

```mint
10 a !
// a = 10

20 b !
// b = 20

a b + .
// 30 
```

### Examples

```mint
// Calculate circle area: A = πr²
5 r !
// radius = 5
/pi r r * * .
// 78.5398 

// Temperature conversion: F = C * 9/5 + 32
25 c !
// Celsius = 25

c 9 * 5 / 32 + .
// 77 

// Quadratic formula component
3 a ! 4 b ! 2 c !
// Coefficients

b b * 4 a * c * - /sqrt .
// √(b²-4ac) 
```

---

## Arrays

Arrays are stored in heap memory and can contain 64-bit floating-point numbers.

**Heap Storage:** MINT-Octave provides 4096 heap locations for array storage.

### Creating Arrays

Syntax: `[ element1 element2 ... ]`

```mint
[ 10 20 30 40 50 ] arr !
```

This creates an array and stores its address in variable `arr`.

**Array Format in Heap:** `[size, elem1, elem2, ...]`

### Accessing Array Elements

**Get Element: ?**  
Effect: `array_addr index -- value`

```mint
arr 0 ? .
// 10 

arr 2 ? .
// 30 

arr 4 ? .
// 50 
```

**Note:** Arrays use 0-based indexing

**Set Element: ?!**  
Effect: `value array_addr index -- `

```mint
99 arr 2 ?!
// Set arr[2] = 99

arr 2 ? .
// 99 
```

### Array Size

**Get Size: /S**  
Effect: `array_addr -- size`

```mint
arr /S .
// 5 
```

### Array Examples

```mint
// Sum array elements
[ 1 2 3 4 5 ] arr !
0 sum !
// Initialize sum
arr /S ( arr /i ? sum + sum ! )
// Loop through array
sum .
// 15 

// Find maximum in array
[ 23 17 42 8 31 ] data !
data 0 ? max !
// Initialize with first element
data /S ( data /i ? max > ( data /i ? max ! ) )
// Update max
max .
// 42 

// Array with variables
10 a ! 20 b ! 30 c !
[ a b c ] vals !
vals 1 ? .
// 20 
```

---

## Control Flow

### Loops

**Basic Loop Syntax:**

```mint
count ( body )
```

Executes `body` `count` times.

**Examples:**

```mint
// Print numbers 0-4
5 ( /i . 32 /C )
// 0 1 2 3 4 

// Calculate factorial of 5
1 result !
5 ( /i 1 + result * result ! )
result .
// 120 

// Print squares
10 ( /i " * . 32 /C )
// 0 1 4 9 16 25 36 49 64 81 
```

### Loop Variables

**/i** - Inner loop counter (0-based)

```mint
3 ( /i . 32 /C )
// 0 1 2 
```

**/j** - Outer loop counter (for nested loops)

```mint
3 ( 3 ( /i /j + . 32 /C ) /N )
// 0 1 2 
// 1 2 3 
// 2 3 4 
```

### While Loops

**/W** - Break if top of stack is false (0)

```mint
// Count down from 10
10 counter !
/U (
    counter .
    counter 1 - counter !
    counter /W
  )
```

**/U** - Unlimited loop constant

The combination of `/U` with `/W` creates a while-loop pattern. `/U` pushes -1 to the stack, and when used as a loop count with a `/W` inside the loop body, creates an effectively unlimited loop that breaks on a condition.

```mint
// Infinite loop with condition
0 i !
/U (
    i .
    i 1 + i !
    i 5 > /W
  )
// Break when i > 5
```

**Note:** A negative loop count without `/W` runs exactly once (treating it as a boolean "true").

### Conditionals (If-Then-Else)

**Syntax:**

```mint
condition ( then_body ) /E ( else_body )
```

**Examples:**

```mint
// Simple if-then-else
10 x !
x 5 > ( `x is large` ) /E ( `x is small` )

// Check even or odd
7 n !
n 2 /mod 0 = ( `even` ) /E ( `odd` )

// Absolute value
-42 n !
n 0 < ( n -1 * ) /E ( n ) .
```

### Boolean Constants

**/T** - True (-1)  
**/F** - False (0)

```mint
/T .
// -1 
/F .
// 0 
5 3 > /T = .
// -1 
```

---

## Functions

Define reusable functions with letters **A** through **Z**.

### Single-Line Functions

**Syntax:** `:Name body ;`

```mint
:D " * ;
// D = square function
5 D .
// 25 
```

**Note:** The semicolon `;` is only meaningful for ending function definitions. Standalone semicolons outside function definitions are ignored.

### Multi-Line Functions

MINT-Octave supports multi-line function definitions with continuation prompts:

```mint
> :F
... 2 (
...   3 (
...     /j /i + . 32 /C
...   )
...   /N
... )
... ;
> F
0 1 2 
1 2 3 
```

**How it works:**
1. Type `:F` and press Enter - **immediately enters capture mode**
2. You'll see the `...` continuation prompt
3. Type your function body across multiple lines
4. End with `;` - function is saved
5. Call it by typing `F`

### Inline Comments

You can add comments using `//` - they are automatically stripped when the function is saved:

```mint
> :CALC
... 10 x !        // store 10 in x
... 20 y !        // store 20 in y
... x y + .       // add and print
... ;
> CALC
30 
> list
Defined functions:
==================
:CALC 10 x ! 20 y ! x y + . ;
==================
```

**Notice:** The comments are gone in the `list` output!

### Function Examples

**Square function:**
```mint
:S " * ;
7 S .
// 49 
```

**Cube function:**
```mint
:C " " * * ;
4 C .
// 64 
```

**Factorial:**
```mint
:F 1 result ! $ 1 + ( /i 1 + result * result ! ) result ;
5 F .
// 120 
```

**Fibonacci:**
```mint
:FIB
... 1 a ! 1 b !
... 2 - (
...   a b + c !
...   b a !
...   c b !
... )
... b
... ;
10 FIB .
// 55 
```

**Hypotenuse:**
```mint
:H " * $ " * + /sqrt ;
3 4 H .
// 5 
```

**Average:**
```mint
:AVG + 2 / ;
10 20 AVG .
// 15 
```

### List All Functions

```mint
list
```

Shows all defined functions with their bodies (comments stripped).

---

## Temporary Blocks

### What is `:_` ?

`:_` is a **temporary execution block** that allows you to write and execute multi-line code immediately without saving it as a permanent function.

### Purpose

**Temporary blocks solve this problem:**
- You want to test multi-line code
- You don't want to clutter your function list (A-Z)
- You need a "scratch pad" for experimentation

### How It Works

1. **Type `:_`** - Enters capture mode (just like `:A` through `:Z`)
2. **Write your code** across multiple lines with `...` prompts
3. **End with `;`** - The code executes immediately
4. **Automatically deleted** - The `_` function is removed after execution

### Example Usage

**Testing a nested loop:**
```mint
> :_
... 3 (
...   5 (
...     /i . 32 /C
...   )
...   /N
... )
... ;
0 1 2 3 4 
0 1 2 3 4 
0 1 2 3 4 
> list
No functions defined.
```

**The same code as a permanent function:**
```mint
> :T
... 3 (
...   5 (
...     /i . 32 /C
...   )
...   /N
... )
... ;
> T
0 1 2 3 4 
0 1 2 3 4 
0 1 2 3 4 
> list
Defined functions:
==================
:T 3 ( 5 ( /i . 32 /C ) /N ) ;
==================
```

### When To Use Temporary Blocks

**Use `:_` for:**
- Testing and debugging multi-line code
- Quick experiments with loops and conditionals
- Trying out algorithms before saving them
- Running one-time calculations

**Use `:A` to `:Z` for:**
- Functions you want to reuse
- Permanent parts of your program
- Functions you'll call multiple times

### Comparison

| Feature | `:A` to `:Z` | `:_` |
|---------|-------------|------|
| **Saves Function** | ✓ Yes | ✗ No (auto-deleted) |
| **Shows in `list`** | ✓ Yes | ✗ No |
| **Multi-line** | ✓ Yes | ✓ Yes |
| **Inline comments** | ✓ Yes | ✓ Yes |
| **Reusable** | ✓ Yes | ✗ No (runs once) |
| **Use Case** | Permanent code | Testing/experiments |

### Think of It As...

- **`:A` to `:Z`** = Saved functions (26 available)
- **`:_`** = Scratch pad / temporary execution (runs once and disappears)

### Error Handling

If an error occurs in a temporary block, it's still cleaned up:

```mint
> :_
... 0 0 /
... ;
ERROR in temporary block: DIVISION BY ZERO
> list
No functions defined.
```

### Is It Required?

**No!** It's completely optional. You can:
- Continue using `:A` to `:Z` for everything
- Use `:_` only when you want throwaway test code
- Ignore it completely if you prefer

It's just a convenience feature for experimentation and testing.

---

## Multi-Line Input

### How Multi-Line Input Works

MINT-Octave now supports **true multi-line input** for function definitions and temporary blocks.

### Entering Multi-Line Mode

**Automatic Entry:** As soon as you type `:` followed by a letter (A-Z) or underscore (_), you immediately enter capture mode.

```mint
> :F
... 
```

The `...` prompt indicates you're in **continuation mode**.

### What Works in Multi-Line Mode

✓ **Function Definitions (`:A` to `:Z`)**
```mint
> :DEMO
... 5 (
...   /i . 32 /C
... )
... ;
```

✓ **Temporary Blocks (`:_`)**
```mint
> :_
... 10 ( /i . 32 /C )
... ;
0 1 2 3 4 5 6 7 8 9 
```

✓ **Nested Loops**
```mint
> :NESTED
... 3 (
...   4 (
...     /j /i + . 32 /C
...   )
...   /N
... )
... ;
```

✓ **Inline Comments**
```mint
> :CALC
... 10 x !     // store value
... 20 y !     // another value
... x y + .    // print sum
... ;
```

### Exiting Multi-Line Mode

Multi-line mode ends when you type `;` (semicolon).

```mint
> :F
... code here
... more code
... ;
> 
```

You return to the normal `>` prompt.

### Important Notes

**Comments Are Stripped:**
When you use `list` to view functions, all `//` comments are removed:

```mint
> :F
... 10 x !  // comment here
... x .
... ;
> list
Defined functions:
==================
:F 10 x ! x . ;
==================
```

**Single-Line Still Works:**
You can still define functions on one line:

```mint
> :SQ " * ;
> 5 SQ .
25 
```

**No Line Limit:**
You can use as many lines as needed until you type `;`

**Cannot Edit Previous Lines:**
Once you press Enter, that line is added to the buffer. You cannot edit it. If you make a mistake, either:
- Finish with `;` and redefine the function
- Use Ctrl+C to cancel (if your terminal supports it)

### Comparison: Before vs After

**Before (Version 2.5 and earlier):**
- Had to write loops on one line
- `)` on separate lines caused errors
- Multi-line only worked if you avoided pressing Enter mid-structure

**Now (Version 2.7):**
- Enter capture mode immediately with `:`
- Type across multiple lines naturally
- End with `;` whenever you're done
- Works exactly like typing in a text editor

### Quick Summary

| Action | Result | Prompt |
|--------|--------|--------|
| Type `:F` | Enter capture mode for function F | `...` |
| Type `:_` | Enter capture mode for temp block | `...` |
| Type `;` | Exit capture mode, save function | `>` |
| Type `list` | View all saved functions | `>` |

---

## Input/Output

### Print Operations

**Print Number: .**  
Effect: `n -- `

```mint
42 .
// 42 
```

**Print Hexadecimal: ,**  
Effect: `n -- `

```mint
255 , /N
// 00FF 
#DEAD , /N
// DEAD 
-1 , /N
// FFFF 
-256 , /N
// FF00 
```

**Note:** Hex output displays numbers as 16-bit unsigned values (0000-FFFF). Negative numbers are shown in two's complement representation.

**Print Newline: /N**

```mint
1 . 2 . 3 .
// 1 2 3 
1 . /N 2 . /N
// 1 
// 2 
```

**Print Character: /C**  
Effect: `ascii -- `

```mint
65 /C
// A
72 /C 105 /C
// Hi
```

**Print String: `text`**

```mint
`Hello, World!` /N
// Hello, World!

`Result: ` 42 . /N
// Result: 42 
```

### Input Operations

**Read Character: /K**  
Effect: `-- ascii`

Reads one character and pushes its ASCII code.

```mint
/K .
// Type 'A' → prints: 65
```

**Read String: /KS**  
Effect: `-- char1 char2 ... charN count`

Reads a string and pushes ASCII codes plus count.

```mint
/KS
// Type "Hi"
.
// 2 
/C /C
// Prints: iH 
```

---

## System Variables

### /c (Carry Flag)

Set by arithmetic operations to indicate unsigned overflow.

```mint
int8
200 100 + .    // 44 (wrapped)
/c .           // 1 (carry occurred)
```

See [Processor Flags](#processor-flags) for complete details.

### /v (Overflow Flag)

Set by arithmetic operations to indicate signed overflow.

```mint
int8
127 1 + .      // -128 (overflow)
/v .           // 1 (signed overflow occurred)
```

See [Processor Flags](#processor-flags) for complete details.

### /z (Zero Flag)

Set when result of an operation is zero.

```mint
10 10 - .      // 0
/z .           // 1 (result is zero)
```

See [Processor Flags](#processor-flags) for complete details.

### /n (Negative Flag)

Set when result of an operation is negative.

```mint
10 20 - .      // -10
/n .           // 1 (result is negative)
```

See [Processor Flags](#processor-flags) for complete details.

### /r (Remainder)

Set by integer division operations.

```mint
int16
10 3 / .       // 3
/r .           // 1 (remainder)
```

### /i (Loop Counter)

Current inner loop iteration (0-based).

```mint
5 ( /i . 32 /C )
// 0 1 2 3 4 
```

### /j (Outer Loop Counter)

Outer loop counter for nested loops.

```mint
2 ( 3 ( /i /j + . 32 /C ) /N )
// 0 1 2 
// 1 2 3 
```

---

## Processor Flags

### Overview

MINT-Octave implements four processor flags that track the results of arithmetic operations:
- `/c` - Carry flag (unsigned overflow)
- `/v` - Overflow flag (signed overflow)  
- `/z` - Zero flag (result is zero)
- `/n` - Negative flag (result is negative)

These flags are automatically set after addition, subtraction, and multiplication operations in integer modes.

### Flag Descriptions

#### `/c` - Carry Flag (Unsigned Overflow)
Set to `1` when an unsigned arithmetic operation overflows or underflows.

**Examples (int8 mode):**
```mint
int8
200 100 + .    // Result: 44 (wrapped)
/c .           // Shows: 1 (carry occurred)

100 50 + .     // Result: 150 (no wrap)
/c .           // Shows: 0 (no carry)
```

#### `/v` - Overflow Flag (Signed Overflow)
Set to `1` when a signed arithmetic operation produces an invalid result (e.g., positive + positive = negative).

**Examples (int8 mode):**
```mint
int8
127 1 + .      // Result: -128 (overflow!)
/v .           // Shows: 1 (signed overflow)

50 30 + .      // Result: 80
/v .           // Shows: 0 (no overflow)
```

**Important:** `/c` and `/v` detect different types of overflow:
- Use `/c` for unsigned arithmetic (0 to 255 in 8-bit)
- Use `/v` for signed arithmetic (-128 to 127 in 8-bit)

#### `/z` - Zero Flag
Set to `1` when the result of an operation is zero.

**Examples:**
```mint
int16
10 10 - .      // Result: 0
/z .           // Shows: 1 (zero)

10 5 - .       // Result: 5
/z .           // Shows: 0 (not zero)
```

#### `/n` - Negative Flag
Set to `1` when the result of an operation is negative.

**Examples:**
```mint
int16
10 20 - .      // Result: -10
/n .           // Shows: 1 (negative)

20 10 - .      // Result: 10
/n .           // Shows: 0 (positive)
```

### Flag Behavior by Mode

#### Integer Modes (int8, int16, int32, int64)
All four flags are active and updated after each arithmetic operation:
- **Addition (+)**: Sets all flags based on result
- **Subtraction (-)**: Sets all flags based on result
- **Multiplication (*)**: Sets all flags based on result
- **Division (/)**: Flags NOT updated (only `/r` remainder is set)

#### Floating-Point Mode (fp)
All flags are cleared (set to 0) in floating-point mode, as overflow behavior is different.

```mint
fp
127 1 + .      // 128
/c . /v . /z . /n .    // 0 0 0 0 (all cleared)
```

### Compatibility with Real MINT 2 Hardware

**IMPORTANT:** MINT-Octave includes enhanced flag support not present in original MINT 2 hardware.

| Flag | MINT-Octave | Real MINT 2 (TEC-1) |
|------|-------------|---------------------|
| `/c` | ✅ Fully implemented | ✅ Implemented |
| `/v` | ✅ Fully implemented | ❌ Not implemented (returns 0) |
| `/z` | ✅ Fully implemented | ❌ Not implemented (undefined) |
| `/n` | ✅ Fully implemented | ❌ Not implemented (returns 0) |

**Why the difference?**
- Real MINT 2 on TEC-1 hardware only implements the carry flag (`/c`)
- MINT-Octave adds modern CPU-like flags for enhanced debugging and learning
- Programs using only `/c` will work identically on both platforms
- Programs using `/v`, `/z`, or `/n` are simulator-only features

### Practical Usage Examples

#### Example 1: Detecting Overflow
```mint
int8
127 1 + .           // -128
/v .                // 1 (overflow detected)
( `Overflow!` /N )  // Conditional message
/E
( `OK` /N )
```

#### Example 2: Multi-Precision Addition
```mint
int16
50000 20000 + .     // Result with possible carry
/c .                // Check if carry occurred
```

#### Example 3: Loop Until Zero
```mint
10 ( 
  " . /N           // Print current value
  1 -              // Decrement
  " /z /W          // Break if zero
)
```

#### Example 4: Sign Detection
```mint
:ABS               // Absolute value function
  " /n             // Check if negative
  ( -1 * )         // If negative, multiply by -1
  /E               // Else
  ( )              // Do nothing
;

-42 ABS .          // 42
```

### Technical Details

#### Flag Setting Logic

**Carry Flag (/c):**
- **Addition**: Set if unsigned result > max_unsigned
- **Subtraction**: Set if result < 0 (borrow occurred)  
- **Multiplication**: Set if unsigned result > max_unsigned

**Overflow Flag (/v):**
- **Addition**: Set if same signs produce opposite sign
- **Subtraction**: Set if different signs produce wrong sign
- **Multiplication**: Set if result outside signed range

**Zero Flag (/z):**
- Set if final result == 0

**Negative Flag (/n):**
- Set if final result < 0

#### Bit-Width Specific Ranges

| Mode | Signed Range | Unsigned Range |
|------|--------------|----------------|
| int8 | -128 to 127 | 0 to 255 |
| int16 | -32,768 to 32,767 | 0 to 65,535 |
| int32 | -2.1B to 2.1B | 0 to 4.3B |
| int64 | ±9.2 quintillion | 0 to 18.4 quintillion |

### Best Practices

1. **Check flags immediately** after arithmetic operations
2. **Use `/v` for signed** arithmetic overflow detection
3. **Use `/c` for unsigned** arithmetic and multi-precision math
4. **Use `/z` for loop termination** and zero-detection
5. **Use `/n` for sign checking** instead of comparisons with zero
6. **Remember:** Flags are only updated by `+`, `-`, `*` operations

### Migration from Real MINT 2

If porting code FROM real MINT 2 hardware TO MINT-Octave:
- ✅ Code using `/c` will work identically
- ✅ You can add `/v`, `/z`, `/n` for enhanced functionality

If porting code FROM MINT-Octave TO real MINT 2 hardware:
- ⚠️ Remove all uses of `/v`, `/z`, `/n` 
- ⚠️ Replace with manual comparisons where needed
- ✅ Keep all uses of `/c` (fully compatible)

---

## Debug Mode

### Enabling Debug Mode

At startup:
```
Enable debug mode? (y/n): y
```

Or toggle during session:
```mint
debug
```

### Debug Output Shows

- Token processing
- Stack state before/after operations
- Variable changes
- Function calls
- Loop iterations
- Array operations
- Capture mode status
- Processor flags (/c, /v, /z, /n)

### Debug Log File

When enabled, debug output is saved to:
```
mint_debug_YYYYMMDD_HHMMSS.log
```

### Example Debug Output

```mint
int8
127 1 + .

[DEBUG] Processing token: '127'
[DEBUG] NUMBER: 127
[DEBUG] STACK: [127]
[DEBUG] Processing token: '1'
[DEBUG] NUMBER: 1
[DEBUG] STACK: [127, 1]
[DEBUG] Processing token: '+'
[DEBUG] BEFORE +: stack=[127, 1]
[DEBUG] AFTER +: 127 + 1 = -128 (c=0 v=1 z=0 n=1), stack=[-128]
[DEBUG] FLAGS: /c=0, /v=1, /z=0, /n=1, /r=0
-128 
```

---

## Complete Command Reference

### Arithmetic (18 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `+` | `a b -- sum` | Addition |
| `-` | `a b -- diff` | Subtraction |
| `*` | `a b -- prod` | Multiplication |
| `/` | `a b -- quot` | Division (mode-dependent) |
| `**` | `base exp -- result` | Exponentiation |
| `/sqrt` | `n -- result` | Square root |
| `/abs` | `n -- result` | Absolute value |
| `/ln` | `n -- result` | Natural logarithm |
| `/log` | `n -- result` | Base-10 logarithm |
| `/exp` | `n -- result` | e^x |
| `/floor` | `n -- result` | Round down |
| `/ceil` | `n -- result` | Round up |
| `/round` | `n -- result` | Round to nearest |
| `/mod` | `a b -- rem` | Modulo |
| `/min` | `a b -- min` | Minimum |
| `/max` | `a b -- max` | Maximum |
| `/sign` | `n -- sign` | Sign (-1, 0, 1) |
| `/trunc` | `n -- result` | Truncate to integer |

### Trigonometry (17 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `/sin` | `rad -- result` | Sine |
| `/cos` | `rad -- result` | Cosine |
| `/tan` | `rad -- result` | Tangent |
| `/asin` | `n -- rad` | Arcsine |
| `/acos` | `n -- rad` | Arccosine |
| `/atan` | `n -- rad` | Arctangent |
| `/atan2` | `y x -- rad` | Two-arg arctangent |
| `/sinh` | `n -- result` | Hyperbolic sine |
| `/cosh` | `n -- result` | Hyperbolic cosine |
| `/tanh` | `n -- result` | Hyperbolic tangent |
| `/asinh` | `n -- result` | Inverse hyperbolic sine |
| `/acosh` | `n -- result` | Inverse hyperbolic cosine |
| `/atanh` | `n -- result` | Inverse hyperbolic tangent |
| `/pi` | `-- pi` | Push π constant |
| `/e` | `-- e` | Push e constant |
| `/deg` | `rad -- deg` | Radians to degrees |
| `/rad` | `deg -- rad` | Degrees to radians |

### Stack Operations (6 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `'` | `n -- ` | Drop top item |
| `"` | `n -- n n` | Duplicate top item |
| `$` | `a b -- b a` | Swap top two items |
| `%` | `a b -- a b a` | Copy second to top |
| `/D` | `-- n` | Push stack depth |
| `/CS` | `... -- ` | Clear stack |

### Comparison (3 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `>` | `a b -- bool` | Greater than |
| `<` | `a b -- bool` | Less than |
| `=` | `a b -- bool` | Equal |

### Bitwise (6 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `&` | `a b -- result` | Bitwise AND |
| `\|` | `a b -- result` | Bitwise OR |
| `^` | `a b -- result` | Bitwise XOR |
| `~` | `n -- result` | Bitwise NOT |
| `{` | `n -- result` | Shift left |
| `}` | `n -- result` | Shift right |

### Variables (2 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `a-z` | `-- value` | Push variable value |
| `!` | `val var -- ` | Store to variable |

### Arrays (4 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `[...]` | `-- addr` | Create array |
| `?` | `addr idx -- val` | Get array element |
| `?!` | `val addr idx -- ` | Set array element |
| `/S` | `addr -- size` | Get array size |

### Control Flow (6 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `(...)` | `count -- ` | Loop n times |
| `/U` | `-- -1` | Unlimited loop constant |
| `/W` | `bool -- ` | Break if false |
| `/E` | Separator | Else (in conditionals) |
| `/T` | `-- -1` | True constant |
| `/F` | `-- 0` | False constant |

### Functions (3 commands)

| Command | Description |
|---------|-------------|
| `:A ... ;` | Define function A-Z (multi-line) |
| `:_ ... ;` | Define temporary block (auto-deleted) |
| `list` | List all functions |

### System Variables & Flags (7 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `/c` | `-- flag` | Carry flag (unsigned overflow) |
| `/v` | `-- flag` | Overflow flag (signed overflow) |
| `/z` | `-- flag` | Zero flag (result is zero) |
| `/n` | `-- flag` | Negative flag (result is negative) |
| `/r` | `-- value` | Remainder from division |
| `/i` | `-- counter` | Inner loop counter |
| `/j` | `-- counter` | Outer loop counter |

### Input/Output (7 commands)

| Command | Stack Effect | Description |
|---------|--------------|-------------|
| `.` | `n -- ` | Print number |
| `,` | `n -- ` | Print hex |
| `/N` | ` -- ` | Print newline |
| `/C` | `ascii -- ` | Print character |
| `/K` | `-- ascii` | Read character |
| `/KS` | `-- chars... count` | Read string |
| \`text\` | ` -- ` | Print literal string |

### Mode Control (5 commands)

| Command | Description |
|---------|-------------|
| `int8` | 8-bit integer mode (-128 to 127) |
| `int16` | 16-bit integer mode (MINT 2 compatible) |
| `int32` | 32-bit integer mode |
| `int64` | 64-bit integer mode |
| `fp` | Floating-point mode (default) |
| `mode` | Show current mode |

### Miscellaneous (4 commands)

| Command | Description |
|---------|-------------|
| `//` | Comment (to end of line) |
| `help` | Show help |
| `debug` | Toggle debug mode |
| `bye` | Exit MINT |

---

## Examples

### Example 1: Basic Arithmetic

```mint
// Calculate: (5 + 3) × (10 - 2)
5 3 + 10 2 - * .
// 64 
```

### Example 2: Variables and Formulas

```mint
// Distance formula: d = √((x₂-x₁)² + (y₂-y₁)²)
0 x1 ! 0 y1 !
// Point 1: (0,0)
3 x2 ! 4 y2 !
// Point 2: (3,4)
x2 x1 - " *
// (x₂-x₁)²
y2 y1 - " * +
// + (y₂-y₁)²
/sqrt .
// 5 
```

### Example 3: Trigonometry

```mint
// Calculate height of building from angle and distance
// h = distance × tan(angle)
100 distance !
// 100m from building
30 angle !
// 30° angle of elevation
distance angle /rad /tan * .
// 57.735 
```

### Example 4: Arrays

```mint
// Calculate average of array
[ 10 20 30 40 50 ] data !
0 sum !
data /S count !
count ( data /i ? sum + sum ! )
sum count / .
// 30 
```

### Example 5: Multi-Line Loop

```mint
:EVENS
... // Print even numbers from 0-10
... 11 (
...   /i 2 /mod 0 = (
...     /i . 32 /C
...   )
... )
... /N
... ;
EVENS
// 0 2 4 6 8 10 
```

### Example 6: Temporary Block Testing

```mint
:_
... 5 (
...   /i " * . 32 /C
... )
... /N
... ;
// 0 1 4 9 16 
list
// No functions defined.
```

### Example 7: Nested Loops

```mint
:TABLE
... // Multiplication table
... 5 ( 
...   5 (
...     /j 1 + /i 1 + * . 32 /C
...   )
...   /N
... )
... ;
TABLE
// 1 2 3 4 5 
// 2 4 6 8 10 
// 3 6 9 12 15 
// 4 8 12 16 20 
// 5 10 15 20 25 
```

### Example 8: Fibonacci with Comments

```mint
:FIB
... 0 a ! 1 b !           // Initialize first two numbers
... a . 32 /C b . 32 /C   // Print them
... 8 (                   // Generate next 8 numbers
...   a b + c !           // Calculate next number
...   b a !               // Shift: old b becomes new a
...   c b !               // Shift: new c becomes new b
...   c . 32 /C           // Print new number
... )
... /N
... ;
FIB
// 0 1 1 2 3 5 8 13 21 34 
```

### Example 9: Using /atan2 for Angle

```mint
// Find angle of point (3, 4) from origin
4 3 /atan2 /deg .
// 53.1301 

// Find angle of point (-1, 1) from origin  
1 -1 /atan2 /deg .
// 135 
```

### Example 10: Temperature Converter

```mint
:C2F 9 * 5 / 32 + ;
:F2C 32 - 5 * 9 / ;

100 C2F .
// 212 

32 F2C .
// 0 
```

### Example 11: Using Processor Flags

```mint
int8
127 1 + .              // -128 (overflow)
/v .                   // 1 (signed overflow detected)

200 100 + .            // 44 (wrapped)
/c .                   // 1 (unsigned carry detected)

10 10 - .              // 0
/z .                   // 1 (zero flag set)

-42 /abs .             // 42
/n .                   // 0 (not negative)
```

---

## Tips and Tricks

### Stack Visualization

Enable debug mode to see stack changes:
```mint
debug
5 3 + 2 *
[DEBUG] STACK: [5]
[DEBUG] STACK: [5, 3]
[DEBUG] STACK: [8]
[DEBUG] STACK: [8, 2]
[DEBUG] STACK: [16]
```

### Common Patterns

**Duplicate and use:**
```mint
5 " * .
// Square: x × x
```

**Keep copy for later:**
```mint
10 " 5 + $ .
// Add 5, then print original
```

**Three-way comparison:**
```mint
5 " 3 > $ 7 < & .
// Check if 3 < 5 < 7
```

### Using Temporary Blocks

Test complex logic before making it permanent:

```mint
:_
... // Test nested loops
... 3 ( 3 ( /i /j * . 32 /C ) /N )
... ;
0 0 0 
0 1 2 
0 2 4 
```

If it works, save as a real function:

```mint
:MULT
... 3 ( 3 ( /i /j * . 32 /C ) /N )
... ;
```

### Using Processor Flags

**Check for overflow:**
```mint
int16
30000 5000 + .         // -30536 (overflow!)
/v ( `Overflow detected!` /N )
```

**Zero detection in loops:**
```mint
10 ( " 1 - " /z /W " . 32 /C )
// Count down, break at zero
```

### Error Handling

MINT will show errors for:
- Stack underflow
- Division by zero
- Array out of bounds
- Invalid domain (sqrt of negative, etc.)
- Undefined functions
- Complex number results

### Performance Tips

1. Use functions for repeated code
2. Clear stack with `/CS` when needed
3. Use variables to avoid stack juggling
4. Comment your code with `//`
5. Enable debug mode only when troubleshooting
6. Use `:_` for testing before creating permanent functions
7. Use appropriate integer mode for hardware compatibility

---

## Common Pitfalls

### Stack Order

Remember RPN order:
```mint
10 5 - .
// Correct: 10 - 5 = 5 
5 10 - .
// Wrong order: 5 - 10 = -5 
```

### Variable Storage

Variable must come BEFORE `!`:
```mint
42 x !
// Correct
x 42 !
// Wrong - stores 42's value to location 42
42 ! x
// ERROR - ! requires variable before it
```

### Loop Counters

Loop counters are 0-based:
```mint
3 ( /i . 32 /C )
// Prints: 0 1 2 (not 1, 2, 3)
```

### Angle Units

Trig functions use radians:
```mint
90 /sin .
// Wrong - sin(90 radians)
90 /rad /sin .
// Correct - sin(90°) = 1
```

### Array Indexing

Arrays use 0-based indexing:
```mint
[ 10 20 30 ] arr !
arr 0 ? .
// 10 (first element)
arr 1 ? .
// 20 (second element)
```

### Division Type

Division behavior depends on mode:
```mint
fp
10 3 / .
// 3.33333 (floating-point)

int16
10 3 / .
// 3 (integer division)
/r .
// 1 (remainder)
```

### Multi-Line Input

Cannot enter loops line-by-line in immediate mode:
```mint
// WRONG (immediate mode):
> 3 (
>   /i .
> )
ERROR: Unknown word: )

// CORRECT (function definition):
> :TEST
... 3 (
...   /i .
... )
... ;
> TEST
0 1 2
```

**Solution:** Always use function definitions (`:A`-`:Z` or `:_`) for multi-line code.

### Processor Flags

Flags only work in integer modes:
```mint
fp
127 1 + .
/v .           // 0 (flags disabled in fp mode)

int8
127 1 + .
/v .           // 1 (overflow detected)
```

---

## Quick Reference Card

```
=== MINT-Octave Quick Reference ===

NUMBERS:  123  3.14  -42  1e6  #FF
MODES:    int8 int16 int32 int64 fp mode
STACK:    ' " $ % /D /CS
MATH:     + - * / ** /sqrt /abs /ln /log /exp
ROUND:    /floor /ceil /round /trunc /mod
MINMAX:   /min /max /sign
TRIG:     /sin /cos /tan /asin /acos /atan /atan2
HYPER:    /sinh /cosh /tanh /asinh /acosh /atanh
CONST:    /pi /e
CONVERT:  /deg /rad
COMPARE:  > < =
BITWISE:  & | ^ ~ { }
VARS:     a-z !
ARRAYS:   [...] ? ?! /S
LOOPS:    count ( body )  /U /W /i /j
COND:     cond ( then ) /E ( else )
BOOL:     /T /F
FUNC:     :A ... ;  :_ ... ;  list
I/O:      . , /N /C /K /KS `text`
FLAGS:    /c /v /z /n /r
MISC:     // help debug bye

BOOLEAN VALUES:
  True:  -1    False: 0

PROCESSOR FLAGS (int modes only):
  /c  Carry (unsigned overflow)
  /v  Overflow (signed overflow)
  /z  Zero (result is zero)
  /n  Negative (result is negative)
  /r  Remainder (from division)

STACK EFFECTS:
  n n -- n    Two inputs, one output
  n --        One input, no output
  -- n        No input, one output
  
SPECIAL NOTES:
  • Division: fp=decimal, int=quotient+remainder
  • Trig functions use radians (use /rad to convert)
  • Arrays are 0-indexed
  • Loop counters (/i, /j) are 0-based
  • Hex output shows 16-bit values with two's complement
  • Variable must precede ! operator
  • Multi-line code requires :A-:Z or :_ (not immediate mode)
  • :_ = temporary block (runs once, auto-deleted)
  • Comments with // are stripped from saved functions
  • Flags /v /z /n only in MINT-Octave (not real MINT 2)
```

---

## Differences from Original MINT

This Octave implementation differs from original MINT:

### Enhancements

1. **64-bit floating-point** instead of 16-bit integers
   - Range: ±1.8e308 (vs. -32768 to 32767)
   - Precision: 15-16 significant digits
   - Scientific notation: 1.23e+36

2. **Integer modes** for hardware compatibility
   - int8: 8-bit signed (-128 to 127)
   - int16: 16-bit signed (MINT 2/TEC-1 compatible)
   - int32: 32-bit signed
   - int64: 64-bit signed
   - Proper overflow/wraparound behavior

3. **Enhanced processor flags** (simulator-only)
   - `/c` - Carry flag (present in real MINT 2)
   - `/v` - Overflow flag (simulator enhancement)
   - `/z` - Zero flag (simulator enhancement)
   - `/n` - Negative flag (simulator enhancement)
   - Note: Only `/c` exists on real TEC-1 hardware

4. **Expanded trigonometry** (17 functions)
   - Basic: sin, cos, tan
   - Inverse: asin, acos, atan, atan2
   - Hyperbolic: sinh, cosh, tanh
   - Inverse hyperbolic: asinh, acosh, atanh
   - Conversions: /rad, /deg
   - Constants: /pi, /e

5. **Advanced math** (18 arithmetic functions)
   - Power: **
   - Roots: /sqrt
   - Logarithms: /ln, /log
   - Exponential: /exp
   - Rounding: /floor, /ceil, /round, /trunc
   - Other: /abs, /mod, /min, /max, /sign

6. **Debug mode** with file logging
   - Toggle on/off with `debug` command
   - Logs to timestamped file
   - Shows stack state, variable changes, function calls, flags

7. **Multi-line function definitions**
   - Uses `...` continuation prompt
   - Capture mode for complex functions
   - Inline comments with `//` (auto-stripped)

8. **Temporary blocks** (`:_`)
   - Execute multi-line code without saving
   - Perfect for testing and experimentation
   - Automatically deleted after execution

9. **Extended I/O**
   - String literals with backticks: \`text\`
   - Read string: /KS

10. **Array support** for floating-point numbers
    - 4096 heap locations
    - Mixed integers and floats

11. **Mode-dependent division**
    - Floating-point: decimal results
    - Integer: quotient + remainder

### Not Implemented

- **Byte mode** (`\`, `\!`, `\[`, `\?`)
- **I/O ports** (`/O`, `/I`) - Simulated via files
- **Some system variables** (`/h`, `/k`, `/s`, `/z`, `/V`)
- **Machine code execution** (`/X`, `/G`)
- **Anonymous functions** (`:@`)
- **Memory allocation** (`/A`)
- **Print prompt** (`/P`)

---

## Credits and License

**MINT-Octave v2.7 (2025)**  
Based on MINT by Ken Boak  
Implemented in GNU Octave

**New Features in v2.7:**
- Integer modes (int8, int16, int32, int64) with proper overflow
- Processor flags (/c, /v, /z, /n) for overflow detection
- Enhanced compatibility with MINT 2/TEC-1 hardware
- Documentation of flag differences between simulator and hardware

**Previous Features (v2.6):**
- Multi-line function capture mode
- Temporary execution blocks (`:_`)
- Inline comment support (`//`)
- Enhanced list output
- Fixed print number formatting

This implementation extends the original MINT language with modern floating-point arithmetic, hardware-compatible integer modes, comprehensive mathematical functions, and enhanced debugging capabilities while maintaining the simplicity and elegance of the stack-based paradigm.

---

## Appendix: ASCII Reference

Common ASCII codes for use with `/C` and `/K`:

```
32  Space    48-57  0-9      65-90  A-Z      97-122 a-z
10  \n       33  !       58  :       91  [       123  {
13  \r       34  "       59  ;       92  \       124  |
9   \t       35  #       60  <       93  ]       125  }
             36  $       61  =       94  ^       126  ~
             37  %       62  >       95  _
             38  &       63  ?       96  `
             39  '       64  @
```

---

## Appendix: Error Messages

### Common Errors

**STACK UNDERFLOW**
- Cause: Trying to pop from empty stack
- Solution: Ensure enough values on stack before operations

**DIVISION BY ZERO**
- Cause: Dividing by zero or using /mod with zero divisor
- Solution: Check divisor before operation

**Array index out of bounds**
- Cause: Accessing array element outside valid range
- Solution: Check array size with /S before access

**Domain errors**
- `/sqrt`: Negative input
- `/ln`, `/log`: Zero or negative input
- `/asin`, `/acos`: Input outside [-1, 1]
- `/acosh`: Input < 1
- `/atanh`: Input outside (-1, 1)
- `**`: Negative base with fractional exponent

**Unknown word**
- Cause: Using undefined function or misspelled command
- Solution: Check spelling, use `list` to see defined functions

**! requires a variable before it**
- Cause: Using ! without variable immediately before
- Solution: Use pattern `value variable !`

**Unknown word: )**
- Cause: Trying to use multi-line loops in immediate mode
- Solution: Use function definition (`:A`-`:Z` or `:_`) for multi-line code

---

**End of Manual**

---

*This manual covers all implemented commands in MINT-Octave v2.7, including enhanced processor flags for overflow detection. For questions or issues, enable debug mode to trace execution step-by-step.*
