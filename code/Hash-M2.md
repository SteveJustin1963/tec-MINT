see also https://github.com/SteveJustin1963/hash


Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice.

# Hashing Functions in MINT Version 2.0

---

## Overview

We will define two functions in MINT to compute hash values:

- **Function `K`**: Computes a hash of the values on the **stack**.
- **Function `H`**: Computes a hash of the values in an **array**.

These functions demonstrate how to process sequences of data in MINT using loops, stack manipulation, and bitwise operations.

---

## Function `K`: Hashing Values on the Stack

**Objective:** Compute a hash value by processing `n` items on the stack.

**Stack Effect:** `x1 x2 ... xn n -- hash`

### MINT Code:

```mint
// Function K: Compute hash of values on the stack
:K
  0 h !                         // Initialize hash to 0, store in variable 'h'
  (                             // Start loop, repeats 'n' times
    over h @ swap               // Duplicate next value (xi), fetch current hash, swap
    1 +                         // Increment xi by 1
    swap ^ h !                  // XOR xi+1 with hash, store back in 'h'
    '                           // Drop xi from the stack
  )
  h @                           // Push the final hash value onto the stack
;
```

### Explanation:

1. **Initialize Hash Variable:**

   ```mint
   0 h !
   ```

   - Pushes `0` onto the stack.
   - Stores it in variable `h`, which will hold the hash value.

2. **Start Loop:**

   ```mint
   (
   ```

   - Begins a loop that will run `n` times.
   - The loop count `n` is consumed from the stack.

3. **Loop Body:**

   ```mint
   over h @ swap
   1 +
   swap ^ h !
   '
   ```

   - **`over h @ swap`**:
     - `over`: Duplicates the second item on the stack (next value `xi`).
     - `h @`: Fetches the current hash value.
     - `swap`: Swaps the top two items to prepare for addition.
   - **`1 +`**:
     - Increments `xi` by 1.
   - **`swap ^ h !`**:
     - Swaps `xi+1` and `hash` so that `hash` is on top.
     - Performs bitwise XOR between `hash` and `xi+1`.
     - Stores the result back in `h`.
   - **`'`**:
     - Drops the original `xi` from the stack, keeping the stack size consistent.

4. **End Loop and Retrieve Hash:**

   ```mint
   )
   h @
   ```

   - Ends the loop.
   - Fetches the final hash value from `h` and pushes it onto the stack.

5. **End Function:**

   ```mint
   ;
   ```

   - Ends the function definition.

### Example Usage:

Suppose we have values `10`, `20`, `30` on the stack and want to compute the hash:

```mint
> 10 20 30 3 K .
```

- **Stack Before `K`:** `10 20 30 3`
- **After `K`:** `hash`
- **Prints the Hash Value.**

---

## Function `H`: Hashing an Array

**Objective:** Compute a hash value by processing an array of bytes.

**Stack Effect:** `arr len -- hash`

### MINT Code:

```mint
// Function H: Compute hash of an array
: H
  0 h !                         // Initialize hash to 0, store in 'h'
  p !                           // Store array address in 'p'
  (                             // Start loop, repeats 'len' times
    p @ \@                      // Fetch byte from address 'p'
    1 +                         // Increment value by 1
    h @ ^ h !                   // XOR with hash, store back in 'h'
    p @ 1 + p !                 // Increment pointer 'p' by 1
  )
  h @                           // Push the final hash onto the stack
;
```

### Explanation:

1. **Initialize Hash Variable and Pointer:**

   ```mint
   0 h !
   p !
   ```

   - **`0 h !`**:
     - Pushes `0` onto the stack.
     - Stores it in variable `h` (hash).
   - **`p !`**:
     - Stores the array address (`arr`) in variable `p`.

2. **Start Loop:**

   ```mint
   (
   ```

   - Begins a loop that will run `len` times.
   - The loop count `len` is consumed from the stack.

3. **Loop Body:**

   ```mint
   p @ \@
   1 +
   h @ ^ h !
   p @ 1 + p !
   ```

   - **`p @ \@`**:
     - Fetches the address from `p`.
     - `\@`: Fetches the byte at that address.
   - **`1 +`**:
     - Increments the fetched value by 1.
   - **`h @ ^ h !`**:
     - Fetches current hash value.
     - Performs bitwise XOR with the incremented value.
     - Stores the result back in `h`.
   - **`p @ 1 + p !`**:
     - Fetches address from `p`, adds 1 to move to the next byte.
     - Stores the updated address back in `p`.

4. **End Loop and Retrieve Hash:**

   ```mint
   )
   h @
   ```

   - Ends the loop.
   - Fetches the final hash value from `h` and pushes it onto the stack.

5. **End Function:**

   ```mint
   ;
   ```

   - Ends the function definition.

### Example Usage:

Suppose we have an array `[10, 20, 30]` and want to compute the hash:

```mint
> \[ 10 20 30 ] ' arr !
> arr @ 3 H .
```

- **Defines an Array:**
  - `\[ 10 20 30 ]`: Creates a byte array with values `10`, `20`, `30`.
  - `'`: Drops the length (we only need the address).
  - `arr !`: Stores the array address in variable `arr`.
- **Calls `H`:**
  - `arr @ 3 H`: Passes the array address and length `3` to function `H`.
- **Prints the Hash Value.**

---

## Variables Used

- **`h`**: Variable to store the current hash value.
- **`p`**: Pointer to the current position in the array.
- **`arr`**: Variable to store the address of the array (in the example).
- **Note:** Ensure variables `h`, `p`, and `arr` are not used elsewhere to avoid conflicts.

---

## Notes

- **Hash Function Logic:**
  - **Increment Each Value:** The hash functions increment each value by `1` before XORing with the hash.
  - **Bitwise XOR (`^`):** Combines values in a way that is sensitive to the order and content of the data.

- **Stack Management:**
  - **Loop Constructs:** The loop consumes the count (`n` or `len`) from the stack.
  - **Stack Cleanup:** It's important to manage the stack properly, dropping any intermediate values that are no longer needed.

- **Variable Scope:**
  - **Global Variables:** MINT variables (`a` to `z`) are global. Be cautious to prevent conflicts with other parts of your program.

---

## Conclusion

By updating the functions and including detailed comments, we've adapted the code to **MINT Version 2.0**, making it clearer and easier to understand. These hashing functions showcase how to:

- Use loops to process sequences.
- Manipulate the stack effectively.
- Perform bitwise operations.
- Utilize variables for storing intermediate data.

---

**Feel free to experiment with these functions, modify the hashing logic, or integrate them into larger MINT programs. Happy coding with MINT Version 2.0!**

---
