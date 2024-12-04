Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice.


# Recipe 2: 4-Digit Counter (Updated for MINT Version 2.0)

---

**Objective:**

Create a counter that counts up in hexadecimal from `0000` to `FFFF` on the TEC-1's 7-segment display.

---

## Introduction

In this recipe, we'll use **MINT Version 2.0** to program the TEC-1 microcomputer to display a hexadecimal counter on its 7-segment displays. The counter will increment from `0000` to `FFFF`, updating the display once every second.

---

## Hardware Specifics

The TEC-1 controls its 7-segment display using two ports:

- **Port 1 (SCAN):** Controls which digits are active.
  - **Bits 0-5:** Selects the digits. Bit 0 activates the rightmost digit, and Bit 5 activates the leftmost digit.
  - **Bit 6 (`#40`):** Must be kept high (`1`) at all times to prevent interference with serial communication.
- **Port 2 (DISPLAY):** Controls which segments are lit on the active digit(s).

**Important Note:** The displays cannot be controlled simultaneously; they need to be scanned rapidly one after another to give the illusion that all digits are lit continuously.

---

## Segment Data for Hexadecimal Digits

The hexadecimal digits `0` to `F` correspond to specific segment patterns on a 7-segment display. We need to create a lookup table containing the segment data for each hexadecimal digit.

**Segment Data Table:**

| Hex Digit | Segment Data (Hex) |
|-----------|--------------------|
| 0         | `#EB`              |
| 1         | `#28`              |
| 2         | `#CD`              |
| 3         | `#AD`              |
| 4         | `#2E`              |
| 5         | `#A7`              |
| 6         | `#E7`              |
| 7         | `#29`              |
| 8         | `#EF`              |
| 9         | `#2F`              |
| A         | `#6F`              |
| B         | `#E6`              |
| C         | `#C3`              |
| D         | `#EC`              |
| E         | `#C7`              |
| F         | `#47`              |

---

## Creating the Segment Lookup Table

We will define a byte array containing the segment data for digits `0` to `F`.

**MINT Code:**

```mint2
\[ #EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47 ] c!
```

**Explanation:**

- `\[ ... ]`: Defines a byte array.
- The hexadecimal values represent the segment data for digits `0` to `F`.
- `]`: Ends the array definition, pushing the address and length onto the stack.
- `c !`: Stores the address of the array in variable `c`.

---

## Function `A`: Convert a Nibble to 7-Segment Display Representation

We need a function that takes a 4-bit value (nibble) and returns the corresponding segment data from the lookup table.

**MINT Code:**

```mint2
:A
  #0F &        
  c + \? 
;
```

**Explanation:**
- :A Begin function definition named A (must not have space between : and A per manual)
- #0F & Bitwise AND with #0F to mask the lower 4 bits of input number
- c + Add the masked value to the base address stored in c (pointer to segment lookup table)
- \? Fetch byte from the array at calculated index (correct operator for byte array access)
- ; End function definition


**Stack Effect:** `value -- segment_data`

---

## Function `B`: Output a Nibble to an Active Digit

This function outputs a nibble (lower 4 bits of a number) to a specific active digit.

**MINT Code:**

```mint
:B
  $           
  A           
  2 /O        
  #40 | s !   
  s 1 /O      
  10()        
  #40 1 /O    
;
```

**Explanation:**

- :B: Begin function definition named B (no space after : per manual)
- $: Swap number and scan values on stack (uses SWAP operator)
- A: Call function A to convert nibble to segment pattern
- 2 /O: Output segment pattern to port 2 (display segments)
- #40 | s !: OR with #40 to set bit 6 high, store in variable s
- s 1 /O: Output value from s to port 1 (digit select) - removed @ since it's not used in MINT
- 10(): Create delay loop (no spaces between number and parentheses per manual)
- #40 1 /O: Write #40 to port 1 to disable all digits while keeping bit 6 high
- ;: End function definition

This function appears to be a multiplexed 7-segment display driver that:
- Takes a digit value and scan position
- Converts digit to segment pattern using function A
- Outputs segment pattern
- Outputs digit select with bit 6 set
- Delays briefly
- Turns off all digits but keeps bit 6 high



**Stack Effect:** `number scan --`

---

## Function `C`: Scan Number to Display

This function takes a 16-bit number and displays it on the upper 4 digits of the 7-segment display.

**MINT Code:**

Looking at the MINT manual more carefully, let me fix this code:

```
:C
  #04 scan!                      
  4(
    " " B                          
    scan { scan!                 
    $ } } } } $                    
  )
  ' '                             
;
```

Key corrections:
1. Changed `scan !` to `scan!` (no space needed for store operation)
2. Changed `% %` to `" "` since `"` is the correct operator for duplicating top stack element (DUP)
3. Kept the spacing clean and minimal
4. Maintained `' '` for two separate drop operations

The function works by:
1. Setting initial scan value to #04 (digit 2)
2. Looping 4 times:
   - Duplicates number and scan value on stack
   - Calls B to display current digit
   - Shifts scan left for next digit
   - Shifts number right by 4 bits for next digit value
3. Cleans up stack at end

 


 

** Variables Used: ** - scan: Current digit selector.
---
## Function E: Main Program to Count and Display
This is the main program that counts from 0 to FFFF, updating the display.

```
:E
  #FFFF(
    100(
      /j C                       
    )
  )
  0 2 /O 0 1 /O                 
;
```

Key corrections:
1. Removed `@` operator since it's not used in MINT
2. Fixed parentheses spacing by removing spaces before `(`
3. Simplified `/j` access - the value is directly available without `@`
4. Fixed final port writes to properly turn off display:
   - `0 2 /O` turns off segments (port 2)
   - `0 1 /O` turns off digit select (port 1)

Function operation:
1. Outer loop counts from 0 to #FFFF
2. For each count:
   - Inner loop refreshes display 100 times 
   - Gets current count from /j variable
   - Calls C to handle display multiplexing
3. At end, turns off all segments and digit select signals

Variables used:
- `/j`: Built-in outer loop counter variable (no need to declare)

 
 
## Full Code Listing
```
// Segment lookup table for digits 0-F
\[ #EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47 ] c!

// Function A - convert nibble to segments
:A
#0F &
c + \?
;

// Function B - output to active digit
:B
$
A
2 /O
#40 | s!
s 1 /O
10()
#40 1 /O
;

// Function C - scan all 4 digits
:C
#04 n!
4(
" " B
n { n!
$ } } } } $
)
' '
;

// Function E - main counter loop
:E
#FFFF(
100(
/j C
)
)
0 2 /O 0 1 /O
;

// Start program
E
```
