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

```mint
\[ #EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47 ] ' c !
```

**Explanation:**

- `\[ ... ]`: Defines a byte array.
- The hexadecimal values represent the segment data for digits `0` to `F`.
- `]`: Ends the array definition, pushing the address and length onto the stack.
- `'`: Drops the length (we don't need it).
- `c !`: Stores the address of the array in variable `c`.

---

## Function `A`: Convert a Nibble to 7-Segment Display Representation

We need a function that takes a 4-bit value (nibble) and returns the corresponding segment data from the lookup table.

**MINT Code:**

```mint
:A
  #0F &        // Mask lower 4 bits
  c @ + \@     // Fetch segment data from table
;
```

**Explanation:**

- `:A`: Begin function definition named `A`.
- `#0F &`: Bitwise AND with `#0F` to mask the lower 4 bits.
- `c @ +`: Add the nibble value to the base address of the segment table.
- `\@`: Fetch the segment data from the calculated address.
- `;`: Ends function definition.

**Stack Effect:** `value -- segment_data`

---

## Function `B`: Output a Nibble to an Active Digit

This function outputs a nibble (lower 4 bits of a number) to a specific active digit.

**MINT Code:**

```mint
:B
  $            // Swap number and scan
  A            // Convert nibble to segment data
  2 /O         // Output segment data to port 2 (DISPLAY)
  #40 | s !    // Ensure bit 6 is high, store in 's'
  s @ 1 /O     // Output selector to port 1 (SCAN)
  10 ( )       // Delay for about half a millisecond
  #40 1 /O     // Turn off all digits, keep bit 6 high
;
```

**Explanation:**

- `:B`: Begin function definition named `B`.
- `$`: Swap the top two stack items (`number` and `scan`).
- `A`: Convert the lower 4 bits of `number` to segment data.
- `2 /O`: Output segment data to port 2.
- `#40 | s !`: Bitwise OR `scan` with `#40` to set bit 6 high, store in `s`.
- `s @ 1 /O`: Output the selector value in `s` to port 1.
- `10 ( )`: Delay loop.
- `#40 1 /O`: Output `#40` to port 1 to turn off all digits but keep bit 6 high.
- `;`: Ends function definition.

**Stack Effect:** `number scan --`

---

## Function `C`: Scan Number to Display

This function takes a 16-bit number and displays it on the upper 4 digits of the 7-segment display.

**MINT Code:**

```mint
:C
  #04 scan !                        // Initialize 'scan' with #04 (digit 2)
  4 (
    %% B                            // Duplicate number and scan, call B
    scan @ { scan !                 // Shift scan left to select next digit
    $ } } } } $                     // Shift number right by 4 bits (nibble)
  )
  ''                                // Drop top two items
;
```

**Explanation:**

- `:C`: Begin function definition named `C`.
- `#04 scan !`: Initialize `scan` with `#04`, which selects digit 2.
- `4 (`: Start a loop that runs 4 times (for 4 digits).
- Inside the loop:
  - `%%`: Duplicate the top two items (`number`, `scan`).
  - `B`: Call function `B` with `number` and `scan`.
  - `scan @ { scan !`: Shift `scan` left by one bit to move to the next digit on the left.
  - `$`: Swap `number` to the top of the stack.
  - `} } } }`: Shift `number` right by 4 bits (one nibble).
  - `$`: Swap `scan` back to the top.
- `)` Ends the loop.
- `''`: Drop the top two items from the stack.
- `;`: Ends function definition.

**Variables Used:**

- `scan`: Current digit selector.

---

## Function `E`: Main Program to Count and Display

This is the main program that counts from `0` to `FFFF`, updating the display.

**MINT Code:**

```mint
:E
  #FFFF (
    100 (
      /j @ C                        // Get outer loop counter, call C
    )
  )
  0 0 1 /O                          // Turn off Ports 1 & 2, keep bit 6 high
;
```

**Explanation:**

- `:E`: Begin function definition named `E`.
- `#FFFF (`: Outer loop counts from `0` to `#FFFF`.
- `100 (`: Inner loop to scan the display 100 times per increment.
- Inside the inner loop:
  - `/j @`: Get the value of the outer loop counter (`/j @` refers to the outer loop counter).
  - `C`: Call function `C` to display the current number.
- `)` Ends the inner loop.
- `)` Ends the outer loop.
- `0 0 1 /O`: Output `0` to port 2 (DISPLAY), and `0` to port 1 (SCAN) with bit 6 high (`#40`), effectively turning off the display.
- `;`: Ends function definition.

**Note:** The variable `/j` refers to the outer loop's counter variable in MINT Version 2.0.

---

## Full Code Listing

```mint
// Segment lookup table
\[ #EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47 ] ' c !

// Function A: Convert nibble to segment data
:A
  #0F &        // Mask lower 4 bits
  c @ + \@     // Fetch segment data
;

// Function B: Output nibble to active digit
:B
  $            // Swap number and scan
  A            // Convert nibble to segment data
  2 /O         // Output to port 2 (DISPLAY)
  #40 | s !    // Ensure bit 6 is high, store in 's'
  s @ 1 /O     // Output to port 1 (SCAN)
  10 ( )       // Delay
  #40 1 /O     // Turn off digits, keep bit 6 high
;

// Function C: Scan number to display
:C
  #04 scan !                        // Initialize 'scan' with #04
  4 (
    %% B                            // Duplicate number and scan, call B
    scan @ { scan !                 // Shift scan left
    $ } } } } $                     // Shift number right by 4 bits
  )
  ''                                // Drop top two items
;

// Function E: Main program to count and display
:E
  #FFFF (
    100 (
      /j @ C                        // Get outer loop counter, call C
    )
  )
  0 0 1 /O                          // Turn off display, keep bit 6 high
;

// Execute function E
E
```

---

## Execution Flow

1. **Initialize Segment Table:**
   - The segment lookup table is created and stored in variable `c`.

2. **Function Definitions:**
   - Functions `A`, `B`, `C`, and `E` are defined.

3. **Run Main Program:**
   - Calling `E` starts the main program.

4. **Counting Loop (`E`):**
   - The outer loop counts from `0` to `#FFFF`.
   - For each count:
     - The inner loop scans the display 100 times to maintain the display without flickering.
     - In each scan, the current count value is displayed by calling function `C`.

5. **Displaying Number (`C`):**
   - For each of the 4 digits:
     - The corresponding nibble of the number is extracted.
     - Function `B` is called to output the nibble to the active digit.

6. **Converting Nibble to Segment Data (`A`):**
   - The nibble is masked and used to fetch the corresponding segment data from the lookup table.

7. **Output to Hardware (`B`):**
   - The segment data is output to port 2.
   - The digit selector is output to port 1 with bit 6 high.
   - A delay is added to ensure the digit is visible.
   - The digit is then turned off before moving to the next digit.

8. **Loop Continuation:**
   - The process repeats for all digits and increments the count until `#FFFF` is reached.

---

## Understanding Key MINT Commands and Syntax

- **Variables:**
  - Variables `c`, `s`, `scan` are used to store addresses and values.

- **Bitwise Operations:**
  - `&`: Bitwise AND.
  - `|`: Bitwise OR.

- **Shift Operators:**
  - `{`: Shift left (multiply by 2).
  - `}`: Shift right (divide by 2).

- **Stack Manipulation:**
  - `$`: Swap the top two items on the stack.
  - `%%`: Duplicate the top two items on the stack.
  - `''`: Drop the top two items from the stack.

- **Loops:**
  - `n (` and `)`: Loop that runs `n` times.
  - `/i @`: Access the current loop counter.
  - `/j @`: Access the outer loop counter when loops are nested.

- **I/O Operations:**
  - `/O`: Output to an I/O port (`value port /O`).
  - `\@`: Fetch a byte from memory (`address \@`).

- **Comments:**
  - `//`: Single-line comments.

---

## Notes and Adjustments

- **Timing Delays:**
  - The delay loops (`10 ( )`) may need adjustment based on the actual processor speed to achieve the desired timing (e.g., 1-second increments).

- **Variable Names:**
  - MINT uses single-letter variables; use consistent names to avoid confusion.

- **Hardware Considerations:**
  - Ensure that the hardware ports correspond to the ones used in the code.

- **Display Flicker:**
  - The inner loop in function `E` ensures the display is refreshed frequently to prevent flickering.

---

## Conclusion

By updating the code to **MINT Version 2.0**, we've created a program that counts up in hexadecimal from `0000` to `FFFF` on the TEC-1's 7-segment display. The program demonstrates how to:

- Use lookup tables for segment data.
- Convert nibbles to segment representations.
- Control hardware ports to manage the display.
- Use loops and functions to create dynamic and efficient code.

---

```
// Segment lookup table
\[ #EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47 ] ' c !

// Function A: Convert nibble to segment data
:A
  #0F &        // Mask lower 4 bits
  c @ + \@     // Fetch segment data
;
  
// Function B: Output nibble to active digit
:B
  $            // Swap number and scan
  A            // Convert nibble to segment data
  2 /O         // Output to port 2 (DISPLAY)
  #40 | d !    // Ensure bit 6 is high, store in 'd'
  d @ 1 /O     // Output selector value in 'd' to port 1 (SCAN)
  10 ( )       // Delay
  #40 1 /O     // Turn off digits, keep bit 6 high
;

// Function C: Scan number to display
:C
  #04 d !                        // Initialize 'd' with #04 (digit 2)
  4 (
    %% B                          // Duplicate number and scan, call B
    d @ { d !                     // Shift 'd' left to select next digit
    $ } } } } $                   // Shift number right by 4 bits (nibble)
  )
  ''                            // Drop top two items
;

// Function E: Main program to count and display
:E
  #FFFF (
    100 (
      /j @ C                      // Get outer loop counter, call C
    )
  )
  0 0 1 /O                        // Turn off Ports 1 & 2, keep bit 6 high
;

// Execute function E
E
```


---
