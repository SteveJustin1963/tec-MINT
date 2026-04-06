  
# Recipe 2: 4 digit counter
- https://github.com/tec1group/MINT-cookbook/tree/main/misc/4-digit-counter
- using ver1 of mint


## The Problem

make a counter which counts up in hexadecimal from 0 to FFFF on the TEC-1's 7 segment display.

## The Solution

The TEC-1 controls it's 7-segment display with two ports 1 & 2.

- Port 1 (SCAN) that turns on one or more of the digits. Bit 0 turns on the rightmost digit. Bit 5 turns on the leftmost digit. One additional complication: we need to keep the 6th bit of Port 1 high at all times.
- Port 2 (DISPLAY) turns on and off segments and the decimal point of the currently active display(s).

The numbers we want to display only take 4 digits so we want to display them on digits 5 to 2 with digits 1 and 0 and turned off. The TEC-1 displays have to be cannot be controlled simultaneously. Each display needs to be activated in turn, first digit 0, then digit 1 etc in a scanning process. The speed this is done needs to be so rapid that it can't be perceived by the the human eye.

One extra complication: Bit 6 of port 1 need to be keep high at all times. This is to ensure that the bit-banged serial does not send any noise while running this program.

The numbers `0` - `F` are represented in 7 segments by the following table:

```
DB $EB $28 $CD $AD $2E $A7 $E7 $29 $EF $2F $6F $E6 $C3 $EC $C7 $47
```

The displays need to be scanned rapidly to prevent the perception of flickering. Every second or so the counter is incremented

## Byte array

The first step is to declare a nibble-to-7segments table as a one dimensional byte array

```
\[#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47]' c!
```

- `\[` indicates that the numbers following are byte values which will be stored in a byte array allocated on the heap.
- `#EB` is an example of a hexadecimal byte value.
- `]` indicates the end of the array. This pushes the address of the array on the stack followed by its length.
- `'` we don't need the length so we drop it.
- `c!` we store the 16-bit address of the array in the variable `c` so we can access it later.

## Definition A: convert a nibble to 7 segment display representation

```
value -- DISPLAY
```

Write a definition which takes a value in the lower 4 bits 0 - F and converts it to 7 segment display representation

```
:A #0F& c@+ \@;
```

Where:

- `:A` declare a definition called A
- `#0F&` bitwise-AND the top of the stack with the hexadecimal value 0F, this mask everything except the bottom 4 bits
- `c@+` get the address of the byte array and add it to the masked nibble value, this is the address of the 7 segment value
- `\@` read a byte from the address
- `;` end of definition

## Definition B: output a nibble to an active digit

Write a definition which takes a 16-bit number value and an 8-bit value representing the currently active digit. We are only interested in the lowest 4 bit of the number value. The digit is selected by a 1 in Bit 5 to Bit 0. Bit 6 is kept at 1 at all times.

```
number scan --
```

```
:B $ A 2\> #40 | 1\> 10() #40 1\>;
```

Where:

- `:B` declare a definition called B
- `$` swap `number` with `scan`
- `A` convert the lower 4 bits of `number` into 7 segment representation
- `2\>` write the 7 segments data out to Port 2 (DISPLAY)
- `#40 |` bitwise-OR `scan` value with hex 40 to keep bit 6 high
- `1\>` write digit selector value to Port 1 (SCAN)
- `10()` delay for about half a millisecond
- `#40` output all 0s to the digits but bit 6 kept high
- `1\>` write digit selector value to Port 1 (SCAN)
- `;` end of definition

## Definition C: scan number to display

Take a 16-bit number and display it on the upper 4 7-segment displays.

```
number --
```

```
:C #04 4( %%B {$ }}}}$ ) '' ;
```

Where:

- `:C` declare a definition called C
- `#04` push the first digit to scan, 4 is the third-last digit
- `4(` start a loop which will iterate 4 times
- `%%` duplicate the top two stack items
- `B` output the lowest 4 bits of number to active segment
- `{` shift `scan` to one bit to left
- `$` swap `number` to top of stack
- `}}}}` shift `number` one nibble right
- `$` swap new `scan` to top of stack
- `)` end loop
- `''` drop the top two stack items
- `;` end of definition

## Count and display

This is the entry point of the program

Count up from zero

Create a loop for counting up from 0 to FFFF. Inside this loop add another loop which which scans the displays 100 times before moving on. We use the loop counter variable \i6+@ to access the value of the outer loops variable. We pass that value to command E.

To run type:

```
:E #FFFF( 100( \j@ C ) ) 0 0B ;
```

Where:

- `:E` declare a definition called E
- `#FFFF(` loop FFFF times
- `100(`
- `\j@` read the value of outer loop variable
- `C` scan number to display
- `)` end of inner loop
- `)` end of outer loop
- `0 0B` turn off Ports 1 & 2 but keeping bit 6 of Port 1 high
- `;` end of definition

## Complete listing

```
:A #0F& c@+ \@;
:B $ A 2\> #40 | 1\> 10() #40 1\>;
:C #04 4( %%B {$ }}}}$ ) '' ;
:E #FFFF( 100( \j@ C ) ) 0 0B ;
```


//////////////////////////////////////////////////////////////////////////////////////





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
