Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice.


# Recipe 2: 6-Digit Display Light Chaser (Updated for MINT Version 2.0)

---

**Objective:**

Create a program in MINT to control the TEC-1's 6-digit 7-segment display, making a single segment appear to move from right to left and back again, creating a light chaser effect.

---

## Introduction

We will use MINT Version 2.0 to program the TEC-1 microcomputer to manipulate its 6-digit 7-segment display. By controlling the individual segments and digits, we can create animations such as a segment moving across the display.

---

## Hardware Specifics

The TEC-1 controls its display using latches on two ports:

- **Port 1**: Controls which digit is illuminated.
- **Port 2**: Controls which segments of the digit are illuminated.

### Port 1 (Digit Selection)

- **Lower 6 bits (bits 0-5)**: Select one of the 6 digits.
- **Bit 6 (bit 6)**: Controls serial communication; must be kept high (`1`) to prevent interference with serial output.

**Digit Selection Bits:**

| Bit | Digit   | Hex Value |
|-----|---------|-----------|
| 0   | Digit 0 (Rightmost) | `#01`    |
| 1   | Digit 1             | `#02`    |
| 2   | Digit 2             | `#04`    |
| 3   | Digit 3             | `#08`    |
| 4   | Digit 4             | `#10`    |
| 5   | Digit 5 (Leftmost)  | `#20`    |
| 6   | Serial Control      | `#40`    |
| 7   | N/A                 | `#80`    |

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

## Exercise 1: Move a Segment Rightwards and Then Leftwards

**Goal:** Light up the middle segment (`g`) of the leftmost digit and move it across to the rightmost digit, then back to the leftmost digit, creating a back-and-forth motion.

---

### Video Demonstration

*Click the image to watch the video demonstration of the effect:*

[![Watch the video](main1.png)](movie1.mp4)

---

### Command `R` (Left to Right)

We will define a function `R` that moves the middle segment from the leftmost digit to the rightmost digit.

**MINT Code:**

```mint
:R
  #04 2 /O                       // Turn on the middle segment (segment 'g')
  #20 a !                        // Initialize 'a' with hex value #20 (leftmost digit)
  6 (
    a @ #40 | b !                // Ensure bit 6 is high, store in 'b'
    b @ 1 /O                     // Output to port 1 to select the digit
    a @ } a !                    // Shift 'a' right by one bit for next digit
    3500 ( )                     // Delay loop
  )
; // Move segment from left to right
```

**Explanation:**

- `:R`: Begin function definition named `R`.
- `#04 2 /O`: Output hex `#04` to port 2 to turn on the middle segment (`g`).
- `#20 a !`: Store hex `#20` (leftmost digit) in variable `a`.
- `6 (`: Start a loop that iterates 6 times (for 6 digits).
- Inside the loop:
  - `a @ #40 | b !`: Set bit 6 high by performing bitwise OR with `#40`, store result in `b`.
  - `b @ 1 /O`: Output the value in `b` to port 1 to select the current digit.
  - `a @ } a !`: Shift `a` right by one bit to move to the next digit on the right.
    - `}` is the **shift right** operator.
  - `3500 ( )`: Delay loop to control the speed of the animation.
- `;`: End function definition.

---

### Command `L` (Right to Left)

Define a function `L` that moves the middle segment from the rightmost digit to the leftmost digit.

**MINT Code:**

```mint
:L
  #04 2 /O                       // Turn on the middle segment (segment 'g')
  #01 a !                        // Initialize 'a' with hex value #01 (rightmost digit)
  6 (
    a @ #40 | b !                // Ensure bit 6 is high, store in 'b'
    b @ 1 /O                     // Output to port 1 to select the digit
    a @ { a !                    // Shift 'a' left by one bit for next digit
    3500 ( )                     // Delay loop
  )
; // Move segment from right to left
```

**Explanation:**

- `:L`: Begin function definition named `L`.
- `#04 2 /O`: Output hex `#04` to port 2 to turn on the middle segment (`g`).
- `#01 a !`: Store hex `#01` (rightmost digit) in variable `a`.
- `6 (`: Start a loop that iterates 6 times.
- Inside the loop:
  - `a @ #40 | b !`: Set bit 6 high and store in `b`.
  - `b @ 1 /O`: Output the value in `b` to port 1.
  - `a @ { a !`: Shift `a` left by one bit to move to the next digit on the left.
    - `{` is the **shift left** operator.
  - `3500 ( )`: Delay loop.
- `;`: End function definition.

---

### Bringing It Together

Define a function `I` to run the sequences `R` and `L` repeatedly.

**MINT Code:**

```mint
:I
  1000 (
    R L
  )
; // Run R and L in a loop 1000 times
```

**Explanation:**

- `:I`: Begin function definition named `I`.
- `1000 (`: Start a loop that iterates 1000 times.
- Inside the loop:
  - `R L`: Call functions `R` and `L` to move the segment back and forth.
- `;`: End function definition.

---

### Full Code for Exercise 1

```mint
// Move a segment rightwards and then leftwards

:R
  #04 2 /O                       // Turn on middle segment
  #20 a !                        // Initialize 'a' with #20 (leftmost digit)
  6 (
    a @ #40 | b !                // Set bit 6 high, store in 'b'
    b @ 1 /O                     // Output to port 1
    a @ } a !                    // Shift 'a' right
    3500 ( )                     // Delay
  )
; // Move segment from left to right

:L
  #04 2 /O                       // Turn on middle segment
  #01 a !                        // Initialize 'a' with #01 (rightmost digit)
  6 (
    a @ #40 | b !                // Set bit 6 high, store in 'b'
    b @ 1 /O                     // Output to port 1
    a @ { a !                    // Shift 'a' left
    3500 ( )                     // Delay
  )
; // Move segment from right to left

:I
  1000 (
    R L
  )
; // Run R and L 1000 times

// Execute the sequence by calling I
I
```

---

## Exercise 2: Circumnavigate the Display

**Goal:** Create a light chaser where a segment moves around the outer edge of the display, starting from the bottom of the leftmost digit, moving right, up, left, and down, returning to the starting point.

---

### Video Demonstration

*Click the image to watch the video demonstration of the effect:*

[![Watch the video](main2.png)](movie2.mp4)

---

### Command `E` (Bottom Segment Moving Right)

Define function `E` to move the bottom segment from the leftmost digit to the rightmost digit.

**MINT Code:**

```mint
:E
  #80 2 /O                       // Turn on bottom segment (segment 'd')
  #20 a !                        // Initialize 'a' with #20 (leftmost digit)
  6 (
    a @ #40 | b !                // Set bit 6 high, store in 'b'
    b @ 1 /O                     // Output to port 1
    a @ } a !                    // Shift 'a' right
    3500 ( )                     // Delay
  )
; // Move bottom segment rightwards
```

**Explanation:**

- `#80 2 /O`: Turn on the bottom segment (`d`).
- The rest is similar to function `R`.

---

### Command `N` (Right Segment Moving Up)

Define function `N` to move from the bottom right segment to the top right segment on the rightmost digit.

**MINT Code:**

```mint
:N
  #01 #40 | 1 /O                 // Select rightmost digit with bit 6 high
  #20 2 /O                       // Turn on bottom right segment ('c')
  3500 ( )                       // Delay
  #08 2 /O                       // Turn on top right segment ('b')
  3500 ( )                       // Delay
; // Move up on the rightmost digit
```

**Explanation:**

- `#01 #40 | 1 /O`: Select the rightmost digit.
- `#20 2 /O`: Turn on bottom right segment (`c`).
- Delay.
- `#08 2 /O`: Turn on top right segment (`b`).
- Delay.

---

### Command `W` (Top Segment Moving Left)

Define function `W` to move the top segment from the rightmost digit to the leftmost digit.

**MINT Code:**

```mint
:W
  #01 a !                        // Initialize 'a' with #01 (rightmost digit)
  #01 2 /O                       // Turn on top segment ('a')
  6 (
    a @ #40 | b !                // Set bit 6 high, store in 'b'
    b @ 1 /O                     // Output to port 1
    a @ { a !                    // Shift 'a' left
    3500 ( )                     // Delay
  )
; // Move top segment leftwards
```

**Explanation:**

- `#01 2 /O`: Turn on the top segment (`a`).
- The rest is similar to function `L`.

---

### Command `S` (Left Segment Moving Down)

Define function `S` to move from the top left segment to the bottom left segment on the leftmost digit.

**MINT Code:**

```mint
:S
  #20 #40 | 1 /O                 // Select leftmost digit with bit 6 high
  #02 2 /O                       // Turn on top left segment ('f')
  3500 ( )                       // Delay
  #40 2 /O                       // Turn on bottom left segment ('e')
  3500 ( )                       // Delay
; // Move down on the leftmost digit
```

**Explanation:**

- `#20 #40 | 1 /O`: Select the leftmost digit.
- `#02 2 /O`: Turn on top left segment (`f`).
- Delay.
- `#40 2 /O`: Turn on bottom left segment (`e`).
- Delay.

---

### Bringing It Together

Define function `J` to run the sequence `E`, `N`, `W`, `S` repeatedly.

**MINT Code:**

```mint
:J
  1000 (
    E N W S
  )
; // Run E, N, W, S in a loop 1000 times

// Execute the sequence by calling J
J
```

---

### Full Code for Exercise 2

```mint
// Circumnavigate the display with a moving segment

:E
  #80 2 /O                       // Turn on bottom segment
  #20 a !                        // Initialize 'a' with #20 (leftmost digit)
  6 (
    a @ #40 | b !                // Set bit 6 high, store in 'b'
    b @ 1 /O                     // Output to port 1
    a @ } a !                    // Shift 'a' right
    3500 ( )                     // Delay
  )
; // Move bottom segment rightwards

:N
  #01 #40 | 1 /O                 // Select rightmost digit with bit 6 high
  #20 2 /O                       // Turn on bottom right segment
  3500 ( )                       // Delay
  #08 2 /O                       // Turn on top right segment
  3500 ( )                       // Delay
; // Move up on the rightmost digit

:W
  #01 a !                        // Initialize 'a' with #01 (rightmost digit)
  #01 2 /O                       // Turn on top segment
  6 (
    a @ #40 | b !                // Set bit 6 high, store in 'b'
    b @ 1 /O                     // Output to port 1
    a @ { a !                    // Shift 'a' left
    3500 ( )                     // Delay
  )
; // Move top segment leftwards

:S
  #20 #40 | 1 /O                 // Select leftmost digit with bit 6 high
  #02 2 /O                       // Turn on top left segment
  3500 ( )                       // Delay
  #40 2 /O                       // Turn on bottom left segment
  3500 ( )                       // Delay
; // Move down on the leftmost digit

:J
  1000 (
    E N W S
  )
; // Run E, N, W, S 1000 times

// Execute the sequence by calling J
J
```

---

## Explanation of Key MINT Syntax and Commands

- **Variables:**
  - `a`, `b`: Variables used to store intermediate values.
- **Bitwise Operators:**
  - `|`: Bitwise OR.
- **Shift Operators:**
  - `{`: Shift left (multiply by 2).
  - `}`: Shift right (divide by 2).
- **I/O Operations:**
  - `/O`: Output to an I/O port (`value port /O`).
- **Loops:**
  - `n (` and `)`: Loop that runs `n` times.
- **Comments:**
  - `//`: Single-line comments.
- **Function Definitions:**
  - `:` and `;`: Begin and end function definitions.

---

## Running the Programs

To execute the programs:

- For **Exercise 1**, after entering the code, call function `I`:

  ```mint
  I
  ```

- For **Exercise 2**, after entering the code, call function `J`:

  ```mint
  J
  ```

---

## Conclusion

By updating the MINT code to Version 2.0, we have utilized the latest syntax and features to control the TEC-1's 6-digit 7-segment display, creating dynamic visual effects. The use of functions, loops, variables, and I/O operations demonstrates MINT's capability to interact with hardware effectively.

---

**Note:** Ensure that your hardware setup matches the port and bit configurations specified. Adjustments may be necessary if your TEC-1 or similar device has different configurations.

---

Feel free to experiment with the code, modify the delays, or create new patterns by combining different segments and movements.

Happy coding with MINT Version 2.0!
