Note-   longer than one character labels have been used to show clarity these need to be modified to single letter of your choice.

# Reduce Function in MINT Version 2.0

---

## Introduction

Reducing is a general operation that can be performed on an array with the purpose of reducing or folding it into a single value (often a number but not always).

The `Reduce` function takes:

- **`val0`**: Initial value.
- **`arr`**: Pointer to an array.
- **`len`**: Length of the array.
- **`fun`**: Pointer to a function that takes two arguments and returns a single value.

It returns a single value as the result of applying the reduction operation across the array.

**Stack Effect:**

```
Reduce ( val0 arr len fun -- val )
```

---

## Function `R`: Reduce

**MINT Code:**

```mint
// Function R: Reduce
:R
  f !               // Store function pointer in 'f'
  val !             // Store initial value 'val0' in 'val'
  p !               // Store array pointer in 'p'
  n !               // Store length in 'n'
  n @ (             // Loop 'n' times
    p @ @           // Fetch arr[i] from address in 'p'
    val @ swap      // Get current 'val', swap to arrange stack as arr[i] val
    f @ /G          // Call function 'f' with (val, arr[i])
    val !           // Store result back in 'val'
    p @ 2 + p !     // Increment array pointer 'p' by 2 bytes (next element)
  )
  val @             // Push final value onto stack
;
```

---

### Explanation:

1. **Initialize Variables:**

   - `f !`: Stores the function pointer from the stack into variable `f`.
   - `val !`: Stores the initial value `val0` from the stack into variable `val`.
   - `p !`: Stores the array pointer from the stack into variable `p`.
   - `n !`: Stores the length of the array from the stack into variable `n`.

2. **Loop Over Array Elements:**

   - `n @ (`: Begins a loop that runs `n` times.
   
   - **Inside the Loop:**
     - `p @ @`: Fetches the value at the current array position (dereferences `p`).
     - `val @ swap`: Fetches the current `val`, rearranges the stack to have `arr[i] val`.
     - `f @ /G`: Calls the function `f` with arguments `val` and `arr[i]`.
     - `val !`: Stores the result back into `val`.
     - `p @ 2 + p !`: Increments the array pointer `p` by 2 bytes to move to the next element.
     
   - `)`: Ends the loop.

3. **Return the Final Value:**

   - `val @`: Fetches the final value from `val` and pushes it onto the stack.

4. **End Function:**

   - `;`: Ends the function definition.

---

## Helper Functions for Reduce

We'll define several functions that can be used with `Reduce` for different operations like counting elements, finding maximum or minimum, summing elements, and computing a hash.

---

### Function `C`: Count

Counts the number of elements in the array.

**MINT Code:**

```mint
// Function C: Increment count
:C
  ' 1 +             // Drop arr[i], increment val by 1
;
```

**Explanation:**

- The function `C` takes `arr[i]` and `val` from the stack.
- `'`: Drops `arr[i]` (since we don't need its value for counting).
- `1 +`: Increments `val` by 1.
- `;`: Ends the function definition.

---

### Function `G`: Greatest (Maximum)

Finds the maximum number in the array.

**MINT Code:**

```mint
// Function G: Maximum
:G
  over over >       // Compare val and arr[i], leave boolean on stack
  (\                // If val > arr[i]
    '               // Drop arr[i], keep val
  )
  (                 // Else (val <= arr[i])
    swap '          // Swap val and arr[i], drop old val, keep arr[i]
  )
;
```

**Explanation:**

- `over over >`: Compares `val` and `arr[i]`.
- `(\ ... )`: If condition is true (val > arr[i]), executes `'` to drop `arr[i]`.
- `(`: Else, executes `swap '` to keep `arr[i]` as the new `val`.
- `;`: Ends the function definition.

---

### Function `L`: Least (Minimum)

Finds the minimum number in the array.

**MINT Code:**

```mint
// Function L: Minimum
:L
  over over <       // Compare val and arr[i]
  (\                // If val < arr[i]
    '               // Drop arr[i], keep val
  )
  (                 // Else
    swap '          // Swap val and arr[i], drop old val
  )
;
```

---

### Function `S`: Sum

Computes the sum of the elements in the array.

**MINT Code:**

```mint
// Function S: Sum
:S
  +                 // Add val and arr[i]
;
```

---

### Function `H`: Hash

Computes a hash of the elements in the array.

**MINT Code:**

```mint
// Function H: Hash
:H
  1 + ^             // Increment arr[i] by 1, XOR with val
;
```

---

## Complete Code Listing

```mint
// Function R: Reduce
:R
  f !               // Store function pointer in 'f'
  val !             // Store initial value 'val0' in 'val'
  p !               // Store array pointer in 'p'
  n !               // Store length in 'n'
  n @ (             // Loop 'n' times
    p @ @           // Fetch arr[i]
    val @ swap      // Get val, arrange stack as arr[i] val
    f @ /G          // Call function 'f' with (val, arr[i])
    val !           // Store result back into 'val'
    p @ 2 + p !     // Increment array pointer 'p' by 2 bytes
  )
  val @             // Push final value onto stack
;

// Function C: Count
:C
  ' 1 +             // Drop arr[i], increment val by 1
;

// Function G: Maximum
:G
  over over >       // Compare val and arr[i]
  (\                // If val > arr[i]
    '               // Drop arr[i], keep val
  )
  (                 // Else
    swap '          // Swap val and arr[i], drop old val
  )
;

// Function L: Minimum
:L
  over over <       // Compare val and arr[i]
  (\                // If val < arr[i]
    '               // Drop arr[i], keep val
  )
  (                 // Else
    swap '          // Swap val and arr[i], drop old val
  )
;

// Function S: Sum
:S
  +                 // Add val and arr[i]
;

// Function H: Hash
:H
  1 + ^             // Increment arr[i], XOR with val
;
```

---

## Example Usage

### Prepare an Array

First, define an array and store its address and length.

```mint
\[ 1 4 3 6 2 ] ' arr !
5 n !              // Store length in 'n'
```

**Explanation:**

- `\[ 1 4 3 6 2 ]`: Creates a word array with the given numbers.
- `'`: Drops the length pushed by `]`, since we store it separately.
- `arr !`: Stores the array address in variable `arr`.
- `5 n !`: Stores the length `5` in variable `n`.

---

### Count Elements

```mint
0 arr @ n @ /?C R .
```

- `0`: Initial value `val0` is `0`.
- `arr @ n @`: Pushes array address and length onto the stack.
- `/?C`: Gets the address of function `C` and pushes it.
- `R`: Calls the `Reduce` function.
- `.`: Prints the result.

**Output:**

```
5
```

---

### Find Maximum

```mint
0 arr @ n @ /?G R .
```

- Initial value `val0` is `0`.
- Using function `G` to find the maximum.

**Output:**

```
6
```

---

### Find Minimum

```mint
9999 arr @ n @ /?L R .
```

- Initial value `val0` is a large number (`9999`).
- Using function `L` to find the minimum.

**Output:**

```
1
```

---

### Sum Elements

```mint
0 arr @ n @ /?S R .
```

- Initial value `val0` is `0`.
- Using function `S` to sum the elements.

**Output:**

```
16
```

---

### Compute Hash

```mint
0 arr @ n @ /?H R .
```

- Initial value `val0` is `0`.
- Using function `H` to compute the hash.

**Output:**

```
7
```

---

## Notes

- **Variables Used:**

  - `f`: Function pointer.
  - `val`: Accumulated value (initial value and result).
  - `p`: Array pointer.
  - `n`: Length of the array.

- **Function Pointers:**

  - Use `/?F` to get the address of function `F`.
    - E.g., `/?C` gets the address of function `C`.
  - Use `/G` to execute a function at an address.

- **Stack Management:**

  - Be cautious with stack manipulation to ensure the correct values are passed to functions and that the stack remains balanced.

- **Conditional Execution:**

  - In functions `G` and `L`, conditional execution is used to decide whether to keep `val` or `arr[i]` based on comparison.

    - `(\ ... )`: Executes if the condition is true.
    - `(` ... `)`: Executes if the condition is false.

- **Array Access:**

  - `p @ @`: Fetches the value at the address pointed to by `p`.

- **Looping:**

  - `n @ (` ... `)`: Loops `n` times.

- **Arithmetic and Logical Operations:**

  - `+`: Addition.
  - `^`: Bitwise XOR.
  - `>`, `<`: Comparison operators.
  - `1 +`: Increment by 1.

---

## Conclusion

By updating the `Reduce` function and related helper functions to **MINT Version 2.0**, we've created a flexible tool for processing arrays and reducing them to a single value. These functions demonstrate:

- How to iterate over arrays using loops.
- Passing and using function pointers.
- Using conditional execution to make decisions within functions.
- Stack manipulation techniques.

Feel free to expand upon these examples or create your own functions to use with `Reduce`.

---

**Happy coding with MINT Version 2.0!**

---
