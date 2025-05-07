 


# FixedArrayManager  



```
// FixedArrayManager - MINT implementation for managing fixed arrays
// Variables: a=array, b=capacity, c=loop_index, d=value_to_add, s=logical_size

// Create array of 10 zeros
[0 0 0 0 0 0 0 0 0 0] a !
a /S b !  // Store physical capacity (10)
0 s !     // Initialize logical size to 0

// Add element to array if space available
:A
d !        // Get value to add
s b < (    // If there's space
  d a s ?! // Store at next available position
  s 1 + s! // Increment logical size
  `Added element. New size: ` s . 
) /E (
  `Array is full. Cannot add ` d . 
)
;

// Print logical array contents
:P
`Array Contents (` s . ` elements):` /N
0 c !     // Initialize loop counter
s (       // Loop up to logical size
  a c ? . // Print element
  32 /C   // Print space
  c 1 + c ! // Increment counter
)
/N
;
```

## Introduction
The FixedArrayManager is a simple MINT implementation that demonstrates how to work with fixed-size arrays while simulating dynamic array behavior. 
Since MINT doesn't support true dynamic arrays and has limited memory, this approach uses a fixed-size array with a separate variable to track the logical size.

## Variables
- `a`: The fixed array (capacity of 10)
- `b`: Physical capacity of the array
- `c`: Loop counter (for internal use)
- `d`: Temporary storage for values to add
- `s`: Current logical size of the array

## Functions

### A - Add Element
Adds a value to the end of the logical array if there's space available.

**Usage:**
```
value A
```

**Parameters:**
- `value`: The element to add to the array (taken from stack)

**Behavior:**
- Checks if the logical size is less than physical capacity
- If there's space, adds the element and increments the logical size
- If full, displays an error message

### P - Print Array
Prints all elements in the logical array (up to size `s`).

**Usage:**
```
P
```

**Output:**
- Displays the count of elements
- Lists all elements in the logical array, separated by spaces

## Example Usage

```
// Initialize array (done automatically when code is loaded)
// Array is created with capacity of 10, logical size of 0

// Add some elements
5 A     // Add value 5
10 A    // Add value 10
15 A    // Add value 15

// Print current array contents
P       // Should show 3 elements: 5 10 15

// Try adding elements until capacity is reached
20 A
25 A
30 A
35 A
40 A
45 A
50 A    // This should succeed and fill the array
55 A    // This should fail with "Array is full" message

// Print the filled array
P       // Should show 10 elements
```

## Tips and Limitations
- The array size is fixed at 10 elements
- Once initialized, the array buffer cannot be resized
- The logical size (`s`) should never exceed the physical capacity (`b`)
- For larger applications, adjust the initial array size as needed

## How It Works
This implementation makes a clear distinction between:
1. The physical array in memory (fixed capacity of 10)
2. The logical view of the array (only elements 0 to `s-1` are considered "in use")

When adding elements, we place them at the next available position (index `s`) and increment `s`. When displaying elements, we only loop through elements 0 to `s-1`, ignoring any unused capacity.



