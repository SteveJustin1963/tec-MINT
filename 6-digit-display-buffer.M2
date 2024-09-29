Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice.
 

# Recipe 3: 6-Digit Display Buffer (Updated for MINT Version 2.0)

---

**Objective:**

Set up a region of memory to contain segment on/off information for the TEC-1's 6-digit 7-segment displays. Write routines to send this information to the displays by rapidly scanning the digits, activating each display for a short time before moving to the next, creating the illusion that all displays are lit simultaneously.

---

## Introduction

In this recipe, we'll create a display buffer in memory to hold the segment data for each of the six 7-segment displays. We'll write functions in **MINT Version 2.0** to scan this buffer and update the displays, effectively controlling what appears on each digit.

---

## Hardware Specifics

The TEC-1 controls its display using latches on two ports:

- **Port 1**: Controls which digit is illuminated.
- **Port 2**: Controls which segments of the digit are illuminated.

### Port 1 (Digit Selection)

- **Bits 0-5**: Select one of the six digits.
- **Bit 6 (`#40`)**: Must be kept high (`1`) to prevent interference with serial communication.
- **Bit 7**: Not used for digit selection.

**Digit Selection Bits:**

| Bit | Digit             | Hex Value |
|-----|-------------------|-----------|
| 0   | Digit 0 (Rightmost)| `#01`    |
| 1   | Digit 1            | `#02`    |
| 2   | Digit 2            | `#04`    |
| 3   | Digit 3            | `#08`    |
| 4   | Digit 4            | `#10`    |
| 5   | Digit 5 (Leftmost) | `#20`    |
| 6   | Serial Control     | `#40`    |
| 7   | Speaker/LED        | `#80`    |

### Port 2 (Segment Control)

**Segment Selection Bits:**

| Bit | Segment | Description     | Hex Value |
|-----|---------|-----------------|-----------|
| 0   | a       | Top             | `#01`     |
| 1   | f       | Top Left        | `#02`     |
| 2   | g       | Middle          | `#04`     |
| 3   | b       | Top Right       | `#08`     |
| 4   | dp      | Decimal Point   | `#10`     |
| 5   | c       | Bottom Right    | `#20`     |
| 6   | e       | Bottom Left     | `#40`     |
| 7   | d       | Bottom          | `#80`     |

---

## Solution

### Creating the Display Buffer

We need to declare a buffer of 6 bytes to hold the segment data for each digit.

**MINT Code:**

```mint
\[ 0 0 0 0 0 0 ] ' b !
```

**Explanation:**

- `\[ ... ]`: Defines a byte array.
- `0 0 0 0 0 0`: Initializes the array with six zeros.
- `]`: Ends the array definition, pushing the address and length onto the stack.
- `'`: Drops the length (we don't need it).
- `b !`: Stores the address of the array in variable `b`.

### Function `A`: Output Segments to a Digit

We need a function that takes the segment data and the digit selector, and updates the hardware display ports.

**MINT Code:**

```mint
:A
  2 /O                        // Output segments to port 2
  #40 | s !                   // Ensure bit 6 is high, store in 's'
  s @ 1 /O                    // Output selector to port 1
  10 ( )                      // Delay for about half a millisecond
  #40 1 /O                    // Turn off all digits, keep bit 6 high
;
```

**Explanation:**

- `:A`: Begin function definition `A`.
- `2 /O`: Outputs the top of the stack (segments data) to port 2.
- `#40 | s !`: Performs bitwise OR with `#40` (to set bit 6 high) on the selector byte (on top of the stack) and stores it in variable `s`.
- `s @ 1 /O`: Outputs the selector value in `s` to port 1.
- `10 ( )`: Delay loop.
- `#40 1 /O`: Outputs `#40` to port 1 to turn off all digits but keep bit 6 high.
- `;`: Ends function definition.

**Stack Effect:** Before calling `A`, the stack should have `segments selector` (segments data on top).

### Function `B`: Scan Digits to Display

We need a function to scan through the display buffer and update the displays.

**MINT Code:**

```mint
:B
  #20 a !                      // Initialize 'a' with #20 (leftmost digit selector)
  b @ ptr !                    // Store the buffer address in 'ptr'
  6 (
    ptr @ segments !           // Load segments data from buffer
    a @ #40 | s !              // Set bit 6 high on selector, store in 's'
    segments @ s @ A           // Call function 'A' with segments and selector
    ptr @ 1 + ptr !            // Increment buffer pointer
    a @ } a !                  // Shift selector right to select next digit
  )
;
```

**Explanation:**

- `:B`: Begin function definition `B`.
- `#20 a !`: Initialize variable `a` with `#20` (leftmost digit selector).
- `b @ ptr !`: Store the buffer address in `ptr`.
- `6 (`: Start a loop that runs 6 times.
- Inside the loop:
  - `ptr @ segments !`: Fetch the segment data from the buffer into `segments`.
  - `a @ #40 | s !`: Set bit 6 high on the selector and store in `s`.
  - `segments @ s @ A`: Call function `A` with `segments` and `selector`.
  - `ptr @ 1 + ptr !`: Increment the buffer pointer.
  - `a @ } a !`: Shift `a` right to move to the next digit.
- `;`: Ends function definition.

### Variables Used:

- `a`: Current digit selector.
- `ptr`: Pointer to the current position in the buffer.
- `segments`: Segments data for the current digit.
- `s`: Selector with bit 6 set high.

---

## Exercise 1: Fill Buffer with All "8."s and Display for 10 Seconds

We want to fill the display buffer with segment data corresponding to "8." (all segments on), and display it.

**MINT Code:**

```mint
:C
  b @ ptr !                    // Store buffer address in 'ptr'
  6 (
    #FF ptr @ \!               // Store #FF (all segments on) in buffer
    ptr @ 1 + ptr !            // Increment buffer pointer
  )
  1000 (
    B                          // Call function 'B' to scan the display
  )
;
```

**Explanation:**

- `:C`: Begin function definition `C`.
- `b @ ptr !`: Store buffer address in `ptr`.
- `6 (`: Loop 6 times.
- Inside the loop:
  - `#FF ptr @ \!`: Store `#FF` at the current buffer address.
  - `ptr @ 1 + ptr !`: Increment buffer pointer.
- `1000 (`: Loop 1000 times (approx. 10 seconds).
- Inside the loop:
  - `B`: Call function `B` to update the display.
- `;`: Ends function definition.

### Full Code for Exercise 1

```mint
// Define the display buffer
\[ 0 0 0 0 0 0 ] ' b !

// Function A: Output segments to a digit
:A
  2 /O                        // Output segments to port 2
  #40 | s !                   // Ensure bit 6 is high, store in 's'
  s @ 1 /O                    // Output selector to port 1
  10 ( )                      // Delay
  #40 1 /O                    // Turn off all digits, keep bit 6 high
;

// Function B: Scan digits to display
:B
  #20 a !                      // Initialize 'a' with #20
  b @ ptr !                    // Buffer address to 'ptr'
  6 (
    ptr @ segments !           // Fetch segments data from buffer
    a @ #40 | s !              // Set bit 6 high, store in 's'
    segments @ s @ A           // Call 'A' with segments and selector
    ptr @ 1 + ptr !            // Increment buffer pointer
    a @ } a !                  // Shift 'a' right
  )
;

// Function C: Fill buffer with all "8."s and display
:C
  b @ ptr !                    // Buffer address to 'ptr'
  6 (
    #FF ptr @ \!               // Store #FF in buffer
    ptr @ 1 + ptr !            // Increment buffer pointer
  )
  1000 (
    B                          // Scan the display
  )
;

// Execute function C
C
```

---

## Exercise 2: Display the Numbers 0 to 5 for 10 Seconds

We need to display the numbers 0 to 5 on the display. For this, we'll create a segment lookup table.

### Creating the Segment Lookup Table

**MINT Code:**

```mint
\[ #EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47 ] ' c !
```

**Explanation:**

- `\[ ... ]`: Defines a byte array containing segment data for digits 0-F.
- The hexadecimal values correspond to the segment patterns for each digit.
- `c !`: Stores the address of the array in variable `c`.

### Function `E`: Convert Number to Segment Data

**MINT Code:**

```mint
:E
  c @ + \@                    // Fetch segment data from table
;
```

**Explanation:**

- `:E`: Begin function definition `E`.
- `c @ +`: Adds the number (on top of the stack) to the base address of the segment table.
- `\@`: Fetches the segment data from that address.
- `;`: Ends function definition.

**Stack Effect:** `number -- segments`

### Main Program

We need a function to fill the display buffer with numbers 0 to 5, and then display it.

**MINT Code:**

```mint
:F
  b @ ptr !                    // Buffer address to 'ptr'
  6 (
    /i @ E segments !          // Get loop index, convert to segments, store in 'segments'
    segments @ ptr @ \!        // Store segments data in buffer
    ptr @ 1 + ptr !            // Increment buffer pointer
  )
  1000 (
    B                          // Scan the display
  )
;
```

**Explanation:**

- `:F`: Begin function definition `F`.
- `b @ ptr !`: Store buffer address in `ptr`.
- `6 (`: Loop 6 times.
- Inside the loop:
  - `/i @ E segments !`: Get the loop index (`/i @`), convert to segments (`E`), store in `segments`.
  - `segments @ ptr @ \!`: Store the segments data at the current buffer address.
  - `ptr @ 1 + ptr !`: Increment buffer pointer.
- `1000 (`: Loop 1000 times to display for approx. 10 seconds.
- Inside the loop:
  - `B`: Call function `B` to scan the display.
- `;`: Ends function definition.

### Full Code for Exercise 2

```mint
// Define the display buffer
\[ 0 0 0 0 0 0 ] ' b !

// Function A: Output segments to a digit
:A
  2 /O                        // Output segments to port 2
  #40 | s !                   // Ensure bit 6 is high, store in 's'
  s @ 1 /O                    // Output selector to port 1
  10 ( )                      // Delay
  #40 1 /O                    // Turn off all digits, keep bit 6 high
;

// Function B: Scan digits to display
:B
  #20 a !                      // Initialize 'a' with #20
  b @ ptr !                    // Buffer address to 'ptr'
  6 (
    ptr @ segments !           // Fetch segments data from buffer
    a @ #40 | s !              // Set bit 6 high, store in 's'
    segments @ s @ A           // Call 'A' with segments and selector
    ptr @ 1 + ptr !            // Increment buffer pointer
    a @ } a !                  // Shift 'a' right
  )
;

// Segment lookup table
\[ #EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47 ] ' c !

// Function E: Convert number to segment data
:E
  c @ + \@                    // Fetch segment data
;

// Function F: Display numbers 0 to 5
:F
  b @ ptr !                    // Buffer address to 'ptr'
  6 (
    /i @ E segments !          // Get segment data for index
    segments @ ptr @ \!        // Store in buffer
    ptr @ 1 + ptr !            // Increment buffer pointer
  )
  1000 (
    B                          // Scan the display
  )
;

// Execute function F
F
```

---

## Exercise 3: Count Up from 0 in Hex, Incrementing Once a Second

We want to display a hexadecimal counter from `0000` to `FFFF`, updating once per second.

### Function `G`: Convert Lower 4 Bits of Number to Segment Data

**MINT Code:**

```mint
:G
  $ #0F &                      // Mask lower 4 bits
  E                            // Convert to segments
  $ \!                         // Store segments data at address
;
```

**Explanation:**

- `:G`: Begin function definition `G`.
- `$`: Swap top two items (number, address).
- `#0F &`: Mask lower 4 bits of the number.
- `E`: Convert to segments.
- `$ \!`: Swap to get address on top, then store segments data at address.
- `;`: Ends function definition.

**Stack Effect:** `number address --`

### Function `H`: Convert Number to Segments and Store in Buffer

**MINT Code:**

```mint
:H
  b @ 3 + ptr !                // Set pointer to 4th digit from buffer start
  4 (
    %% G                       // Duplicate number and address, call G
    ptr @ 1 - ptr !            // Decrement pointer
    $ } } } } $                // Shift number right by 4 bits
  )
;
```

**Explanation:**

- `:H`: Begin function definition `H`.
- `b @ 3 + ptr !`: Set pointer to 4th digit (digits 3 to 0).
- `4 (`: Loop 4 times.
- Inside the loop:
  - `%% G`: Duplicate number and address, call `G`.
  - `ptr @ 1 - ptr !`: Decrement pointer to move to the previous digit.
  - `$ } } } } $`: Shift number right by 4 bits (4 times), swap back.
- `;`: Ends function definition.

**Variables Used:**

- `ptr`: Pointer to current digit in buffer.

### Main Program

**MINT Code:**

```mint
:I
  #FFFF (
    /i @ H                     // Get loop counter, call H
    100 ( B )                  // Scan display for approx. 1 second
  )
;
```

**Explanation:**

- `:I`: Begin function definition `I`.
- `#FFFF (`: Loop from 0 to `#FFFF`.
- Inside the loop:
  - `/i @ H`: Get loop counter, call `H` to update buffer.
  - `100 ( B )`: Call `B` 100 times to scan display for approx. 1 second.
- `;`: Ends function definition.

### Full Code for Exercise 3

```mint
// Define the display buffer
\[ 0 0 0 0 0 0 ] ' b !

// Function A: Output segments to a digit
:A
  2 /O                        // Output segments to port 2
  #40 | s !                   // Ensure bit 6 is high, store in 's'
  s @ 1 /O                    // Output selector to port 1
  10 ( )                      // Delay
  #40 1 /O                    // Turn off all digits, keep bit 6 high
;

// Function B: Scan digits to display
:B
  #20 a !                      // Initialize 'a' with #20
  b @ ptr !                    // Buffer address to 'ptr'
  6 (
    ptr @ segments !           // Fetch segments data from buffer
    a @ #40 | s !              // Set bit 6 high, store in 's'
    segments @ s @ A           // Call 'A' with segments and selector
    ptr @ 1 + ptr !            // Increment buffer pointer
    a @ } a !                  // Shift 'a' right
  )
;

// Segment lookup table
\[ #EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47 ] ' c !

// Function E: Convert number to segment data
:E
  c @ + \@                    // Fetch segment data
;

// Function G: Convert lower 4 bits to segments and store
:G
  $ #0F &                     // Mask lower 4 bits
  E                           // Convert to segments
  $ \!                        // Store segments data at address
;

// Function H: Convert number to segments and store in buffer
:H
  b @ 3 + ptr !               // Start at digit 3
  4 (
    %% G                      // Call G with number and address
    ptr @ 1 - ptr !           // Decrement pointer
    $ } } } } $               // Shift number right by 4 bits
  )
;

// Function I: Count up from 0 to #FFFF, incrementing once per second
:I
  #FFFF (
    /i @ H                    // Get loop counter, update buffer
    100 ( B )                 // Scan display for approx. 1 second
  )
;

// Execute function I
I
```

---

**Note:** Adjust the delay loops (`10 ( )`, `100 ( B )`, etc.) as necessary based on the actual processor speed to achieve the desired timing (e.g., 1-second increments).

---

## Conclusion

By updating the code to **MINT Version 2.0**, we've utilized the latest syntax and features to manage a display buffer for the TEC-1's 6-digit 7-segment displays. The program demonstrates how to:

- Create and manipulate a display buffer.
- Use functions to output segment data to the hardware.
- Implement lookup tables for segment patterns.
- Use loops and functions to update the display dynamically.

---

**Feel free to experiment with the code, modify the segment patterns, or create new display effects. Happy coding with MINT Version 2.0!**
