Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice.


# Recipe 1: 8 LED Light Chaser (Updated for MINT Version 2.0)

The problem to be solved is how to control a latched group of 8 LEDs to create a classic light chaser using MINT. In this case, the 8 LEDs are connected to a latch on port `3` of the TEC-1.

---

**Note:** This recipe has been updated to reflect the syntax and features of **MINT Version 2.0**.

---

## Introduction

We aim to create a light chaser effect by sequentially turning on and off LEDs connected to a latch. We'll define user commands in MINT to control the LEDs moving left and right, creating the chasing effect.

---

## MINT Code Explanation

### Initial Comment

```mint
// Back and forward LEDs
```

In MINT Version 2.0, comments start with `//` and continue to the end of the line.

### Defining the Command to Move LEDs Left (`D`)

```mint
:D
  #01 a !                      // Initialize variable 'a' with 0x01
  7(
    a @ { a !                  // Shift 'a' left by one bit and store back in 'a'
    a @ 3 /O                   // Output the value of 'a' to port 3
    2000 ( )                   // Delay loop
  )
;

// go left
```

**Explanation:**

- `:D` begins the definition of a new function named `D`. Functions are stored in uppercase variables `A` to `Z`.
- `#01 a !` stores the hexadecimal value `0x01` in variable `a`.
  - **Variables:** MINT provides variables named `a` to `z`.
- The loop `7( ... )` repeats the code inside the parentheses **7 times**.
- Inside the loop:
  - `a @ { a !` shifts the value in `a` **left by one bit** and stores it back in `a`.
    - `{` is the **shift left** operator.
  - `a @ 3 /O` outputs the current value of `a` to **port 3**, turning on the corresponding LED.
    - `/O` outputs a value to an I/O port: `value port /O`.
  - `2000 ( )` is a delay loop that iterates 2000 times. Each iteration does nothing, effectively creating a delay.
- `;` ends the function definition.
- `// go left` is a comment indicating the purpose of the function.

### Defining the Command to Move LEDs Right (`E`)

```mint
:E
  #80 a !                      // Initialize 'a' with 0x80
  7(
    a @ } a !                  // Shift 'a' right by one bit and store back in 'a'
    a @ 3 /O                   // Output 'a' to port 3
    2000 ( )                   // Delay loop
  )
; // go right
```

**Explanation:**

- `:E` begins the definition of a new function named `E`.
- `#80 a !` stores the hexadecimal value `0x80` in variable `a`, representing the leftmost LED being on.
- The loop `7( ... )` repeats the code inside the parentheses **7 times**.
- Inside the loop:
  - `a @ } a !` shifts the value in `a` **right by one bit** and stores it back in `a`.
    - `}` is the **shift right** operator.
  - `a @ 3 /O` outputs the current value of `a` to **port 3**.
  - `2000 ( )` is the delay loop for timing.
- `;` ends the function definition.
- `// go right` is a comment.

### Running the Light Chaser Sequence

```mint
25( D E )                      // Repeat the sequence 25 times
```

**Explanation:**

- `25( D E )` repeats the sequence of commands `D E` **25 times**.
  - This means the LEDs will move left and then right, 25 times in total.

---

## Full MINT Program

Putting it all together, here's the complete MINT program:

```mint
// Back and forward LEDs

:D
  #01 a !                      // Initialize variable 'a' with 0x01
  7(
    a @ { a !                  // Shift 'a' left by one bit
    a @ 3 /O                   // Output to port 3
    2000 ( )                   // Delay
  )
; // go left

:E
  #80 a !                      // Initialize 'a' with 0x80
  7(
    a @ } a !                  // Shift 'a' right by one bit
    a @ 3 /O                   // Output to port 3
    2000 ( )                   // Delay
  )
; // go right

25( D E )                      // Repeat the sequence 25 times
```

---

## Step-by-Step Breakdown

1. **Initialize the Program:**

   - Add a comment to describe the program's purpose.
     ```mint
     // Back and forward LEDs
     ```

2. **Define Function `D` (Move LEDs Left):**

   - Begin function definition.
     ```mint
     :D
     ```
   - Initialize variable `a` with `0x01`.
     ```mint
     #01 a !
     ```
   - Start a loop that runs 7 times.
     ```mint
     7(
     ```
   - Inside the loop:
     - Shift `a` left by one bit.
       ```mint
       a @ { a !
       ```
     - Output `a` to port 3.
       ```mint
       a @ 3 /O
       ```
     - Delay.
       ```mint
       2000 ( )
       ```
   - Close the loop and end the function.
     ```mint
     )
     ;
     ```
   - Add a comment.
     ```mint
     // go left
     ```

3. **Define Function `E` (Move LEDs Right):**

   - Begin function definition.
     ```mint
     :E
     ```
   - Initialize variable `a` with `0x80`.
     ```mint
     #80 a !
     ```
   - Start a loop that runs 7 times.
     ```mint
     7(
     ```
   - Inside the loop:
     - Shift `a` right by one bit.
       ```mint
       a @ } a !
       ```
     - Output `a` to port 3.
       ```mint
       a @ 3 /O
       ```
     - Delay.
       ```mint
       2000 ( )
       ```
   - Close the loop and end the function.
     ```mint
     )
     ;
     ```
   - Add a comment.
     ```mint
     // go right
     ```

4. **Execute the Sequence:**

   - Repeat the sequence `D E` 25 times.
     ```mint
     25( D E )
     ```

---

## Understanding the Delay Loop

```mint
2000 ( )
```

- This creates a delay by looping 2000 times.
- Each loop iteration does nothing (`( )` is an empty loop).
- The actual delay duration depends on the processor speed.
- On a 4MHz Z80, each loop might take approximately 65 microseconds.
- The total delay per `2000 ( )` loop is roughly 130 milliseconds.

---

## Execution Flow

1. The program starts and executes `25( D E )`.
2. In each iteration of the outer loop:
   - Function `D` is called:
     - LEDs move from right to left.
   - Function `E` is called:
     - LEDs move from left to right.
3. This creates the effect of LEDs moving back and forth, resembling a light chaser.
4. The sequence repeats 25 times.

---

## Conclusion

This MINT program demonstrates how to control hardware (LEDs connected to a latch) using MINT's updated syntax and features. By defining functions and using loops, we can create complex behaviors with concise code.

---

## Additional Notes

- **Port Operations:**
  - In MINT Version 2.0, output to an I/O port is done using `/O`.
    - Syntax: `value port /O`
- **Shift Operators:**
  - `{` shifts bits left (equivalent to multiplying by 2).
  - `}` shifts bits right (equivalent to dividing by 2).
- **Variables:**
  - MINT provides variables `a` to `z` for storing values.
- **Comments:**
  - Use `//` to add comments in your code.
- **Loops:**
  - Loops are defined using `(` and `)`, with the number of iterations specified before the `(`.

---

By following this guide, you can recreate the classic 8 LED light chaser using MINT Version 2.0, and understand the updated syntax and operations used in the language.

25.2.2025 //////////////////////////////////
```
:R #04 2\O #20 a! 6( a@ #40| 1\O a@}a! 3500());
:L #04 2\O #01 a! 6( a@ #40| 1\O a@{a! 3500());
:I 1000(RL);
```

#### commented version
```
// Rotate Right function - segments rotate right
:R
#04 2 /O      // Output 0x04 to segment port 2 (middle segment)
#20 a!        // Initialize a with 0x20 (bit pattern)
6(            // Loop 6 times
  a #40 | 1 /O // Output (a | 0x40) to digit port 1
  a } a!      // Shift a right, store in a
  3500()      // Delay
)
;

// Rotate Left function - segments rotate left
:L
#04 2 /O      // Output 0x04 to segment port 2 (middle segment)
#01 a!        // Initialize a with 0x01 (bit pattern)
6(            // Loop 6 times
  a #40 | 1 /O // Output (a | 0x40) to digit port 1
  a { a!      // Shift a left, store in a
  3500()      // Delay
)
;

// Main loop function - alternates between right and left rotation
:I
1000(         // Loop 1000 times
  R L         // Call R then L
)
;
```

#### TEC-1's segment display patterns 
from the assembly listing at line 142 (SEVSEGDATA section), here are the bit patterns for hexadecimal characters 0-F:

```
0: #EB (11101011) - Segments ABCDEF 
1: #28 (00101000) - Segments BC
2: #CD (11001101) - Segments ABDEG
3: #AD (10101101) - Segments ABCDG
4: #2E (00101110) - Segments BCFG
5: #A7 (10100111) - Segments ACDFG
6: #E7 (11100111) - Segments ACDEFG
7: #29 (00101001) - Segments ABC
8: #EF (11101111) - Segments ABCDEFG
9: #2F (00101111) - Segments ABCFG
A: #6F (01101111) - Segments ABCEFG
B: #E6 (11100110) - Segments CDEFG
C: #C3 (11000011) - Segments ADEF
D: #EC (11101100) - Segments BCDEG
E: #C7 (11000111) - Segments ADEFG
F: #47 (01000111) - Segments AEFG
```

The segment arrangement on the TEC-1 is (from the manual):
```
   A
  ---
F|   |B
  -G-
E|   |C
  ---
   D   .DP
```

Each bit in the pattern corresponds to a segment:
- Bit 0: Segment A (top)
- Bit 1: Segment B (top right)
- Bit 2: Segment C (bottom right)
- Bit 3: Segment D (bottom)
- Bit 4: Segment E (bottom left)
- Bit 5: Segment F (top left)
- Bit 6: Segment G (middle)
- Bit 7: Segment DP (decimal point)

This information can be used to construct custom patterns or modify existing ones for your MINT code.

#### Display multiple 7-segment digits simultaneously 
on the TEC-1, we need to modify our code to implement multiplexing. 
The TEC-1's display is multiplexed, meaning we need to rapidly cycle through all digits to create the illusion that they're all on at once.

Here's a simplified version for entering directly into MINT (without comments):

```
:P[#EB#28#CD#AD#2E#A7#E7#29#EF#2F#6F#E6#C3#EC#C7#47]p!
:D[#20#10#08#04#02#01]d!
:V[0 0 0 0 0 0]v!
:W b!a!a v b?!;
:R 6(v/i?a!p a?b!b 2/O d/i?1/O 50()0 1/O 0 2/O);
:M 20(R);
:T 0 1W 1 2W 2 3W 3 4W 4 5W 5 6W;
:C 0a!/U(a 10%0W a 10/10%1W a 100/10%2W a 1000/10%3W a 10000/10%4W a 100000/10%5W M a 1+a!a 1000000=(0a!));
```

Here's how to use this code:

1. Enter each function as shown above.

2. To set values for specific positions:
   ```
   pos value W
   ```
   For example: `0 3 W` sets position 0 (leftmost) to show "3"

3. To display a test pattern showing "123456":
   ```
   T
   ```

4. To refresh the display (must be called repeatedly):
   ```
   M
   ```

5. To run a continuous counter (0-999999):
   ```
   C
   ```

How this works:

1. The key is the `R` function that quickly cycles through all 6 positions
2. For each position, it:
   - Gets the value to display
   - Converts it to segment pattern
   - Outputs the pattern and selects the digit
   - Keeps the digit on briefly
   - Moves to the next digit

3. This happens fast enough that persistence of vision makes all digits appear to be on simultaneously.

4. The `M` function calls `R` multiple times to maintain the display longer.

This approach is much more flexible than the previous single-digit display, as it allows you to:
- Set and update specific positions
- Show different values on each digit
- Create animations across the entire display

  #### with comments
  ```
  // Segment patterns for hex digits 0-F
:P [#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47] p!

// Digit select patterns
:D [#20 #10 #08 #04 #02 #01] d!

// Store the digit values in an array
// We'll store what to show in each position
:V [0 0 0 0 0 0] v!

// Set display value for a position
// Arguments: position, value
:W b! a!
a v b ? !
;

// Main display refresh function - call in a loop
:R
6(
  // Get digit value for current position
  v /i ? a!
  // Convert to segment pattern
  p a ? b!
  // Output segment pattern
  b 2 /O
  // Select digit
  d /i ? 1 /O
  // Small delay for persistence
  50()
  // Clear outputs
  0 1 /O
  0 2 /O
)
;

// Display function - refresh multiple times
// for visible persistence
:M
20(R)
;

// Example: show "123456" on display
:T
0 1 W
1 2 W
2 3 W
3 4 W
4 5 W
5 6 W
;

// Example: counter
:C
0 a!
/U(
  a 10 % 0 W
  a 10 / 10 % 1 W
  a 100 / 10 % 2 W
  a 1000 / 10 % 3 W
  a 10000 / 10 % 4 W
  a 100000 / 10 % 5 W
  M
  a 1 + a!
  a 1000000 = (0 a!)
)
;
```

