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
; // go left
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
