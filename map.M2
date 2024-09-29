Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice.

# Compile, Map, and Filter Functions in MINT Version 2.0

---

## Introduction

In this guide, we'll update the MINT code for compiling words and bytes, and implement the `Map` and `Filter` functions using **MINT Version 2.0** syntax. We'll include detailed comments and explanations to help you understand how the code works.

---

## Compiling Words and Bytes

In MINT, compiling involves writing data to the memory address pointed to by the heap pointer (`/h`) and then incrementing the heap pointer accordingly.

### Word Compilation

**Purpose:** Write a 16-bit word to the heap and increment the heap pointer by 2 bytes.

**Stack Effect:** `( val -- )`

**MINT Code:**

```mint
// Function W: Compile a word to the heap
:W
  /h @ !              // Store 'val' at the address pointed by '/h'
  2 /h @ + /h !       // Increment '/h' by 2 bytes
;
```

**Explanation:**

- `:W`: Begins the definition of function `W`.
- `/h @ !`: Stores the value on top of the stack (`val`) at the address pointed to by `/h`.
- `2 /h @ + /h !`: Adds `2` to the current heap pointer and stores the result back in `/h`.
- `;`: Ends the function definition.

### Byte Compilation

**Purpose:** Write an 8-bit byte to the heap and increment the heap pointer by 1 byte.

**Stack Effect:** `( val -- )`

**MINT Code:**

```mint
// Function B: Compile a byte to the heap
:B
  /h @ \!             // Byte-store 'val' at the address pointed by '/h'
  1 /h @ + /h !       // Increment '/h' by 1 byte
;
```

**Explanation:**

- `:B`: Begins the definition of function `B`.
- `/h @ \!`: Stores the byte value (`val`) at the address pointed to by `/h`.
- `1 /h @ + /h !`: Adds `1` to the current heap pointer and stores the result back in `/h`.
- `;`: Ends the function definition.

---

## Map Function

The `Map` function applies a given function to each element of an array, producing a new array with the transformed values.

**Stack Effect:** `( arr len fun -- arr' len' )`

### MINT Code:

```mint
// Function M: Map
:M
  f !                   // Store function pointer in variable 'f'
  /h @ q !              // Store current heap pointer as start of new array in 'q'
  p !                   // Store source array pointer in 'p'
  n !                   // Store length in 'n'
  n @ (                 // Loop 'n' times
    p @ @               // Fetch value from address in 'p'
    f @ /G              // Call function 'f' with value on stack
    /h @ !              // Store result at current heap pointer
    2 /h @ + /h !       // Increment heap pointer by 2 bytes
    p @ 2 + p !         // Increment 'p' by 2 bytes (word array)
  )
  q @                   // Push start address of new array onto stack
  /h @ q @ - 2 /        // Compute length in words
;
```

### Explanation:

1. **Variable Initialization:**

   - `f !`: Stores the function pointer (from the stack) in variable `f`.
   - `/h @ q !`: Stores the current heap pointer in variable `q` (start of the new array).
   - `p !`: Stores the source array pointer in variable `p`.
   - `n !`: Stores the length of the array in variable `n`.

2. **Loop Over Array Elements:**

   - `n @ (`: Begins a loop that runs `n` times.
   - **Inside the Loop:**
     - `p @ @`: Fetches the value from the address pointed to by `p`.
     - `f @ /G`: Calls the function `f` with the fetched value on the stack.
     - `/h @ !`: Stores the result at the current heap pointer.
     - `2 /h @ + /h !`: Increments the heap pointer by 2 bytes.
     - `p @ 2 + p !`: Increments the source pointer `p` by 2 bytes (moving to the next array element).
   - `)`: Ends the loop.

3. **Finalize and Return New Array:**

   - `q @`: Pushes the start address of the new array onto the stack.
   - `/h @ q @ - 2 /`: Computes the length of the new array in words (by subtracting the start address from the current heap pointer and dividing by 2).
   - `;`: Ends the function definition.

### Example Usage: Doubling Array Elements

**Function D:** Doubles a number.

```mint
// Function D: Double a number
:D
  2 *                      // Multiply the top of the stack by 2
;
```

**Create an Array:**

```mint
[ 1 4 3 6 2 ] ' arr !      // Define an array and store its address in 'arr'
```

**Apply Map Function:**

```mint
arr @ 5 /?D M              // Call Map with array, length, and address of 'D'
```

**Explanation:**

- `arr @`: Pushes the array address onto the stack.
- `5`: Pushes the length of the array onto the stack.
- `/?D`: Gets the address of function `D` and pushes it onto the stack.
- `M`: Calls the `Map` function.
- **Result:** A new array with elements `[2, 8, 6, 12, 4]` and length `5`.

---

## Filter Function

The `Filter` function processes an array and returns a new array containing only the elements that satisfy a given condition.

**Stack Effect:** `( arr len fun -- arr' len' )`

### MINT Code:

```mint
// Function F: Filter
:F
  f !                   // Store function pointer in 'f'
  /h @ q !              // Store current heap pointer as start of new array in 'q'
  p !                   // Store source array pointer in 'p'
  n !                   // Store length in 'n'
  n @ (                 // Loop 'n' times
    p @ @               // Fetch value from address in 'p'
    dup                 // Duplicate the value (needed if function consumes it)
    f @ /G              // Call function 'f' with value on stack
    (                   // Begin conditional execution if result is true (non-zero)
      /h @ !            // Store original value at heap pointer
      2 /h @ + /h !     // Increment heap pointer by 2 bytes
    )
    p @ 2 + p !         // Increment 'p' by 2 bytes
  )
  q @                   // Push start address of new array onto stack
  /h @ q @ - 2 /        // Compute length in words
;
```

### Explanation:

1. **Variable Initialization:**

   - Similar to the `Map` function.

2. **Loop Over Array Elements:**

   - `n @ (`: Begins a loop that runs `n` times.
   - **Inside the Loop:**
     - `p @ @`: Fetches the value from the array.
     - `dup`: Duplicates the value to keep a copy for potential storage.
     - `f @ /G`: Calls the filter function `f`. The function should leave a boolean (non-zero for true) on the stack.
     - `(`: Begins a conditional block that executes if the top of the stack is true.
       - `/h @ !`: Stores the original value at the current heap pointer.
       - `2 /h @ + /h !`: Increments the heap pointer by 2 bytes.
     - `)`: Ends the conditional block.
     - `p @ 2 + p !`: Increments the source pointer `p` by 2 bytes.
   - `)`: Ends the loop.

3. **Finalize and Return New Array:**

   - Similar to the `Map` function.

### Example Usage: Filtering Even Numbers

**Function E:** Checks if a number is even.

```mint
// Function E: Check if number is even
:E
  2 % 0 =                // Modulo 2, check if result equals 0
;
```

**Create an Array:**

```mint
[ 1 4 3 6 2 ] ' arr !      // Define an array and store its address in 'arr'
```

**Apply Filter Function:**

```mint
arr @ 5 /?E F              // Call Filter with array, length, and address of 'E'
```

**Explanation:**

- **Result:** A new array with elements `[4, 6, 2]` and length `3`.

---

## Additional Notes

- **Variables Used:**

  - `f`: Stores the function pointer.
  - `p`: Pointer to the current position in the source array.
  - `q`: Pointer to the start of the new array (destination).
  - `n`: Holds the length of the array.

- **Stack Management:**

  - Careful stack manipulation is crucial. Use `dup`, `swap`, and other stack operations to maintain the correct order of values.
  - Ensure that the stack is properly balanced at the end of each function.

- **Function Pointers:**

  - Use `/?F` to get the address of a function `F`.
  - Use `/G` to execute a function at an address.

- **Heap Pointer (`/h`):**

  - Always ensure that the heap pointer is correctly managed to prevent overwriting memory.
  - Increment the heap pointer appropriately after writing data.

---

## Conclusion

By updating the code and including detailed comments, we've adapted the `Compile`, `Map`, and `Filter` functions to **MINT Version 2.0**. These functions demonstrate:

- How to write data to the heap and manage the heap pointer.
- Applying transformations to arrays using custom functions.
- Filtering arrays based on conditions.

Feel free to experiment with these functions and integrate them into your MINT programs.

---

**Happy coding with MINT Version 2.0!**

---
