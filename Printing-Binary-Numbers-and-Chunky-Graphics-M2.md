Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice

# Printing Binary Numbers and Chunky Graphics in MINT Version 2.0

---

## Objective

- **Print the top element of the stack as an 8-bit binary number.**
- **Create functions to print letters in chunky graphics on the terminal.**

---

## Overview

We'll update the provided MINT code to Version 2.0, adding comments and explanations for each function:

1. **Function `C`**: Prints either `1` or `0` depending on the top of the stack.
2. **Function `B`**: Prints the binary representation of a byte.
3. **Function `G`**: Prints a block or space character for chunky graphics.
4. **Function `A`**: Prints a row of chunky pixels followed by a newline.
5. **Functions to print letters 'A', 'B', 'C' in chunky graphics.
6. **Code to print the message "BANANA BANDANA" in chunky graphics.

---

## Code Breakdown

### 1. Function `C`: Print `1` or `0`

**Purpose**: Prints `1` if the top of the stack is non-zero, otherwise prints `0`.

**MINT Code**:

```mint
// Function C: Print '1' or '0' based on the top of the stack
:C
  0 =                          // Compare top of stack with 0
  ( 48 /C )                    // If zero, print '0' (ASCII 48)
  /E ( 49 /C )                 // Else, print '1' (ASCII 49)
;
```

**Explanation**:

- `0 =`: Checks if the top of the stack is equal to 0.
- `( 48 /C )`: If true (zero), prints ASCII character 48 ('0').
- `/E ( 49 /C )`: Else, prints ASCII character 49 ('1').
- `/C`: Outputs the character to the terminal.

---

### 2. Function `B`: Print Byte as Binary

**Purpose**: Prints the binary representation of a byte (8 bits).

**MINT Code**:

```mint
// Function B: Print byte as binary
:B
  b !                          // Store the byte in variable 'b'
  8 (
    b @ 128 &                  // Bitwise AND with 128 to get the highest bit
    C                          // Call function 'C' to print '1' or '0'
    b @ { b !                  // Shift 'b' left by 1 bit
  )
;
```

**Explanation**:

- `b !`: Stores the byte to be printed in variable `b`.
- `8 (`: Loop 8 times, once for each bit.
- Inside the loop:
  - `b @ 128 &`: Gets the highest bit of `b`.
  - `C`: Calls function `C` to print '1' or '0' based on the bit.
  - `b @ { b !`: Shifts `b` left by 1 bit for the next iteration.

---

### 3. Function `G`: Print Chunky Graphics Character

**Purpose**: Prints either a whitespace character or a block character to create chunky graphics.

**MINT Code**:

```mint
// Function G: Print block or space for chunky graphics
:G
  0 =                          // Compare top of stack with 0
  ( 32 /C )                    // If zero, print space (ASCII 32)
  /E ( 219 /C )                // Else, print full block (ASCII 219)
;
```

**Explanation**:

- Similar to function `C`, but prints a space or block character.
- Used for creating chunky graphics by printing block characters where pixels are 'on'.

---

### 4. Function `A`: Print a Row of Chunky Pixels

**Purpose**: Prints a row of chunky pixels based on a byte, followed by a newline.

**MINT Code**:

```mint
// Function A: Print a row of chunky pixels
:A
  b !                          // Store the byte in variable 'b'
  8 (
    b @ 128 &                  // Get the highest bit
    G                          // Call function 'G' to print block or space
    b @ { b !                  // Shift 'b' left by 1 bit
  )
  /N                           // Print newline character
;
```

**Explanation**:

- Similar to function `B`, but uses `G` to print block or space characters.
- After printing the 8 pixels, prints a newline to move to the next row.

---

### 5. Printing Letters 'A', 'B', 'C' in Chunky Graphics

To print letters, we supply the pixel data for each row.

**Example to Print Letter 'A'**:

```mint
\N                          // Newline to start on a new line
#7E A                       // Row 1 data for 'A'
#81 A                       // Row 2 data for 'A'
#81 A                       // Row 3
#FF A                       // Row 4
#81 A                       // Row 5
#81 A                       // Row 6
#81 A                       // Row 7
#00 A                       // Row 8 (blank row)
```

- Each `#xx A` line supplies a byte to function `A` to print a row.
- The bytes represent the pixel data for each row of the letter.

**Similarly for Letters 'B' and 'C'**.

---

### 6. Printing "BANANA BANDANA" in Chunky Graphics

We define arrays with the pixel patterns for each letter.

**Defining the Pixel Patterns**:

```mint
\[ #7E #81 #81 #FF #81 #81 #81 #00 ] ' a !    // Letter 'A'
\[ #FE #81 #81 #FE #81 #81 #FE #00 ] ' b !    // Letter 'B'
\[ #7E #81 #80 #80 #80 #81 #7E #00 ] ' c !    // Letter 'C'
\[ #FE #81 #81 #81 #81 #81 #FE #00 ] ' d !    // Letter 'D'
\[ #FC #80 #80 #F8 #80 #80 #FC #00 ] ' e !    // Letter 'E'
\[ #FC #80 #80 #F8 #80 #80 #80 #00 ] ' f !    // Letter 'F'
\[ #FE #10 #10 #10 #10 #10 #FE #00 ] ' i !    // Letter 'I'
\[ #3C #42 #20 #18 #04 #42 #3C #00 ] ' s !    // Letter 'S'
\[ #FE #10 #10 #10 #10 #10 #10 #00 ] ' t !    // Letter 'T'
\[ #C3 #A5 #99 #81 #81 #81 #81 #00 ] ' m !    // Letter 'M'
\[ #C1 #A1 #91 #89 #85 #83 #81 #00 ] ' n !    // Letter 'N'
\[ #00 #00 #00 #00 #00 #00 #00 #00 ] ' s !    // Space character
```

---

**Function `P`: Print a Character from Pixel Data**

```mint
// Function P: Print character from array
:P
  @ + \@ z !                   // Get address of the array, store in 'z'
  8 (
    z @ \@ b !                 // Fetch byte from array, store in 'b'
    b @                        // Push 'b' onto stack
    A                          // Call function 'A' to print the row
    z @ 1 + z !                // Increment array pointer
  )
;
```

**Explanation**:

- `@ + \@`: Fetches the address of the character array.
- `z !`: Stores the current position in the array.
- Loops over 8 rows, fetching each byte and printing the row using `A`.

---

**Function `K`: Print "BANANA BANDANA"**

```mint
// Function K: Print "BANANA BANDANA"
:K
  b P a P n P a P n P a P s P b P a P n P d P a P n P a P /N
;
```

**Explanation**:

- Calls function `P` for each character in the message.
- `s P` is used for space between words.
- `/N`: Prints a newline at the end.

---

**Function `B`: Print the Message Over 8 Rows**

```mint
// Function B: Print message over 8 rows
:B
  8 (
    /i @                    // Get current row number
    K                       // Call function 'K' to print the row
  )
;
```

**Explanation**:

- Loops over 8 rows (since characters are 8 pixels high).
- Calls `K` in each iteration to print the message row by row.

---

**Executing the Code**

```mint
B
```

---

## Complete Updated Code

```mint
// Function C: Print '1' or '0'
:C
  0 =                          // Compare with zero
  ( 48 /C )                    // If zero, print '0'
  /E ( 49 /C )                 // Else, print '1'
;

// Function B: Print byte as binary
:B
  b !                          // Store byte in 'b'
  8 (
    b @ 128 &                  // Get highest bit
    C                          // Print '1' or '0'
    b @ { b !                  // Shift 'b' left
  )
;

// Function G: Print block or space
:G
  0 =                          // Compare with zero
  ( 32 /C )                    // If zero, print space
  /E ( 219 /C )                // Else, print block
;

// Function A: Print chunky pixel row
:A
  b !                          // Store byte in 'b'
  8 (
    b @ 128 &                  // Get highest bit
    G                          // Print block or space
    b @ { b !                  // Shift 'b' left
  )
;

// Print letters 'A', 'B', 'C'
\N                              // Newline
#7E A                           // Letter 'A' Row 1
#81 A                           // Row 2
#81 A                           // Row 3
#FF A                           // Row 4
#81 A                           // Row 5
#81 A                           // Row 6
#81 A                           // Row 7
#00 A                           // Row 8
\N                              // Newline
#FE A                           // Letter 'B' Row 1
#81 A                           // Row 2
#81 A                           // Row 3
#FE A                           // Row 4
#81 A                           // Row 5
#81 A                           // Row 6
#FE A                           // Row 7
#00 A                           // Row 8
\N                              // Newline
#7E A                           // Letter 'C' Row 1
#81 A                           // Row 2
#80 A                           // Row 3
#80 A                           // Row 4
#80 A                           // Row 5
#81 A                           // Row 6
#7E A                           // Row 7
#00 A                           // Row 8

// Define pixel patterns for letters
\[ #7E #81 #81 #FF #81 #81 #81 #00 ] ' a !    // Letter 'A'
\[ #FE #81 #81 #FE #81 #81 #FE #00 ] ' b !    // Letter 'B'
\[ #7E #81 #80 #80 #80 #81 #7E #00 ] ' c !    // Letter 'C'
\[ #FE #81 #81 #81 #81 #81 #FE #00 ] ' d !    // Letter 'D'
\[ #FC #80 #80 #F8 #80 #80 #FC #00 ] ' e !    // Letter 'E'
\[ #FC #80 #80 #F8 #80 #80 #80 #00 ] ' f !    // Letter 'F'
\[ #FE #10 #10 #10 #10 #10 #FE #00 ] ' i !    // Letter 'I'
\[ #3C #42 #20 #18 #04 #42 #3C #00 ] ' s !    // Letter 'S'
\[ #FE #10 #10 #10 #10 #10 #10 #00 ] ' t !    // Letter 'T'
\[ #C3 #A5 #99 #81 #81 #81 #81 #00 ] ' m !    // Letter 'M'
\[ #C1 #A1 #91 #89 #85 #83 #81 #00 ] ' n !    // Letter 'N'
\[ #00 #00 #00 #00 #00 #00 #00 #00 ] ' s !    // Space character

// Function P: Print character from array
:P
  @ + \@ z !                   // Get array address, store in 'z'
  8 (
    z @ \@                     // Fetch byte from array
    b !                        // Store in 'b'
    b @                        // Push 'b' onto stack
    A                          // Call function 'A' to print row
    z @ 1 + z !                // Increment 'z' to next byte
  )
;

// Function K: Print "BANANA BANDANA"
:K
  b P a P n P a P n P a P s P b P a P n P d P a P n P a P /N
;

// Function B: Print message over 8 rows
:B
  8 (
    /i @                        // Get current row number
    K                           // Call function 'K' to print the row
  )
;

// Execute to print the message
B
```

---

## Additional Notes

- **Variables Used**:
  - `b`: Used to store bytes during printing.
  - `z`: Pointer to current position in character array.
  - `a`, `b`, `c`, etc.: Variables storing addresses of character pixel data.
  - `/i`: Loop counter for rows.

- **Character Arrays**:
  - Each character is represented by an array of 8 bytes.
  - Each byte represents one row of pixels.
  - The arrays are stored in variables named after the letters.

- **Control Characters**:
  - `/C`: Outputs a character to the terminal.
  - `/N`: Outputs a newline character.

- **ASCII Codes**:
  - Space character: ASCII 32.
  - Full block character: ASCII 219.

- **Usage of Functions**:
  - Functions can be called within loops and other functions.
  - Stack management is crucial to ensure correct parameters are used.

- **How It Works**:
  - **Function `B`** prints the binary representation of a byte.
  - **Function `A`** prints a row of chunky pixels based on the byte provided.
  - **Function `P`** prints a character by calling `A` for each byte in its pixel data.
  - **Function `K`** constructs the message "BANANA BANDANA" by calling `P` for each character.
  - **Function `B`** loops over 8 rows to print the entire message in chunky graphics.

---

## Conclusion

By updating the code to **MINT Version 2.0** and adding detailed comments and explanations, we've created functions to:

- **Print numbers in binary.**
- **Print chunky graphics letters on the terminal.**
- **Use arrays and functions to manage and display character graphics.**

This demonstrates how MINT can be used for creative terminal outputs and how to manipulate data structures and loops effectively.

---

**Feel free to experiment with the code, add more letters, or create new messages. Happy coding with MINT Version 2.0!**

---
.
