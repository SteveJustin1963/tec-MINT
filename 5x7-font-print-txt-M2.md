Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice.

# Printing ASCII Characters Using MINT Version 2.0

---

## Objective

Print out 21 characters between ASCII codes **33** and **53** using MINT Version 2.0. The program will access each character's font data from a font table starting at address `#E000` and display the characters line by line, simulating their appearance.

---

## Overview

- **Define an array** containing the ASCII codes from 33 to 53.
- **Access font data** for each character from the font table.
- **Print each character** line by line, handling individual pixels.
- **Use loops and functions** to iterate over characters and rows.

---

## Code Breakdown

### 1. Defining the Character Array

We create an array `a` containing the ASCII codes of the characters we want to print.

```mint
// Define array 'a' with ASCII codes from 33 to 53
\[ 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 ] ' a !
```

- `\[ ... ]`: Defines a byte array.
- `'`: Drops the length (we only need the address).
- `a !`: Stores the array's address in variable `a`.

### 2. Function `P`: Printing a Single Character Line

**Purpose:** Print a single line (row) of a character specified by its index in the array `a`.

**Stack Effect:** `index row --`

```mint
// Function P: Print character at given index and row
:P
  a @ + \@               // Get ASCII code from array 'a' at position 'index'
  32 -                   // Adjust for font table offset (assuming font starts at ASCII 32)
  8 *                    // Each character occupies 8 bytes in the font table
  #E000 +                // Base address of the font table
  swap +                 // Add 'row' to get the specific byte for the character's row
  \@                     // Fetch the font data byte
  z !                    // Store in variable 'z'
  5 (                    // Loop over 5 pixels (character width)
    z @ 128 & 0 =        // Check if the highest bit is zero (pixel off)
    ( 32 /C )            // If zero, print space character (ASCII 32)
    /E ( 219 /C )        // Else, print full block character (ASCII 219)
    z @ { z !            // Shift 'z' left by 1 bit for the next pixel
  )
  32 /C                  // Print a space after the character for spacing
;
```

**Explanation:**

- **Fetching Character Data:**
  - `a @ + \@`: Accesses the ASCII code from the array `a` at the given `index`.
  - `32 -`: Adjusts the ASCII code to align with the font table indexing.
  - `8 *`: Calculates the offset in the font table (each character has 8 bytes).
  - `#E000 +`: Adds the base address of the font table.
  - `swap +`: Adds the `row` number to get the specific byte address for that row.
  - `\@`: Fetches the font data byte for the character at the specified row.
  - `z !`: Stores the font data byte in variable `z`.

- **Printing Pixels:**
  - `5 (`: Starts a loop to process 5 pixels (width of the character).
  - Inside the loop:
    - `z @ 128 & 0 =`: Checks if the highest bit is zero (pixel is off).
    - `( 32 /C )`: If true, prints a space character.
    - `/E ( 219 /C )`: Else, prints a full block character.
    - `z @ { z !`: Shifts `z` left by 1 bit to process the next pixel.
  - `)`: Ends the loop.
  - `32 /C`: Prints a space after the character for spacing.

### 3. Function `Y`: Printing All Characters Line by Line

**Purpose:** Iterate over each row of the characters and print them line by line.

```mint
// Function Y: For each row, print all characters
:Y
  8 (                    // Loop over 8 rows (from 0 to 7)
    /i @                 // Get current row number, store in loop counter '/i'
    21 (                 // Loop over 21 characters (indices 0 to 20)
      /j @               // Get current character index, store in loop counter '/j'
      /j @ /i @          // Push 'index' and 'row' onto the stack
      P                  // Call function 'P' to print the character line
    )
    /N                   // Print a newline after each row
  )
;
```

**Explanation:**

- **Outer Loop (`8 (`):** Iterates over each of the 8 rows of the characters.
  - `/i @`: Retrieves the current row number from the loop counter `/i`.
- **Inner Loop (`21 (`):** Iterates over each character in the array `a`.
  - `/j @`: Retrieves the current character index from the loop counter `/j`.
  - `/j @ /i @`: Pushes the `index` and `row` onto the stack for function `P`.
  - `P`: Calls function `P` to print the specified character at the current row.
- `/N`: Prints a newline character after each row to move to the next line.

### 4. Executing the Program

To run the program and print the characters, simply call function `Y`:

```mint
Y
```

---

## Complete Program

Putting it all together:

```mint
// Define array 'a' with ASCII codes from 33 to 53
\[ 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 ] ' a !

// Function P: Print character at given index and row
:P
  a @ + \@               // Fetch ASCII code from array 'a' at 'index'
  32 -                   // Adjust for font table offset
  8 *                    // Calculate character offset in font table
  #E000 +                // Base address of font table
  swap +                 // Add 'row' to get the font data address
  \@                     // Fetch the font data byte
  z !                    // Store in variable 'z'
  5 (                    // Loop over 5 pixels (character width)
    z @ 128 & 0 =        // Check if highest bit is zero (pixel off)
    ( 32 /C )            // Print space if pixel is off
    /E ( 219 /C )        // Else, print full block
    z @ { z !            // Shift 'z' left by 1 bit for next pixel
  )
  32 /C                  // Print space after the character
;

// Function Y: For each row, print all characters
:Y
  8 (                    // Loop over rows 0 to 7
    /i @                 // Get current row number
    21 (                 // Loop over character indices 0 to 20
      /j @               // Get current character index
      /j @ /i @          // Push 'index' and 'row' onto stack
      P                  // Call function 'P' to print character line
    )
    /N                   // Newline after each row
  )
;

// Execute the program
Y
```

---

## Additional Notes

- **Variables Used:**
  - `a`: Holds the address of the array containing ASCII codes.
  - `z`: Used to store the font data byte for a character at a specific row.

- **Font Table Address:**
  - Assumed to be at `#E000`.
  - Each character occupies 8 bytes in the font table.
  - Characters are indexed starting from ASCII code 32.

- **Characters Printed:**
  - ASCII codes from **33** to **53**.
  - Includes characters like `! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5`.

- **Character Width:**
  - Each character is **5 pixels** wide, with an additional space for separation.

- **Pixel Representation:**
  - **Full Block (ASCII 219):** Represents a pixel that is "on".
  - **Space (ASCII 32):** Represents a pixel that is "off".

- **Loop Counters:**
  - `/i`: Outer loop counter for rows.
  - `/j`: Inner loop counter for character indices.

---

## How the Program Works

1. **Initialization:**
   - An array `a` is created with the ASCII codes of the desired characters.
   - The font table is assumed to be located at `#E000`.

2. **Function `Y`:**
   - Starts by looping over each row (0 to 7).
   - For each row, it loops over each character index (0 to 20).
   - Calls function `P` with the current character index and row number.

3. **Function `P`:**
   - Fetches the ASCII code of the character from the array `a`.
   - Calculates the address of the font data byte for the character at the specified row.
   - Stores the font data byte in variable `z`.
   - Loops over 5 pixels (bits) of the font data byte.
     - Checks each bit to determine if the pixel is "on" or "off".
     - Prints a full block or space accordingly.
     - Shifts `z` left by 1 bit to process the next pixel.
   - Prints a space after the character for separation.

4. **Output:**
   - The program outputs the characters line by line, creating a visual representation of the characters.

---

## Example Output

The program will produce an output similar to the following (simplified representation):

```
 ███  █  █ ███ ███ █   █ ███ ███ ███ ███ █   █ ███ ███ ███ █   █ ███ ███ ███ ███ ███ ███
█   █ █  █   █   █ █   █   █   █ █   █   █ █  █ █     █ █   █ █   █ █ █ █ █ █ █   █ █ █
█   █ █  █   █   █ █   █   █   █ █   █   █ █  █ █     █ █   █ █   █ █ █ █ █ █ █   █ █ █
█   █ ████  █   █  █   █ ███ ███ ███ ███ ████ ███   ██  ███ ███   ████ █ █ █ ███ ███ ███
█   █    █ █   █   █   █ █     █   █   █ █  █ █     █     █   █   █ █   █ █ █   █ █ █ █
█   █    █ █   █   █   █ █     █   █   █ █  █ █     █     █   █   █ █   █ █ █   █ █ █ █
 ███     █ ███ ███  ███  ███ ███ ███ ███ █  █ ███ ███  ███ ███   █  ███ █ █ ███ ███ ███
```

---

## Conclusion

By updating the code to **MINT Version 2.0** and including detailed comments, we've created a program that:

- Defines an array of ASCII characters.
- Accesses font data to render characters.
- Uses loops and functions to iterate over characters and rows.
- Prints a visual representation of the characters using ASCII art.

This program demonstrates advanced features of MINT, such as array manipulation, function definitions, and loop constructs.

---

**Feel free to experiment with the code, modify the character range, or adjust the pixel representation to create different outputs. Happy coding with MINT Version 2.0!**

---
