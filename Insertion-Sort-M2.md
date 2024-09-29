# Insertion Sort
An implementation of the insertion sort algorithm.
```
:I l !         // Pop the list from the stack
l /S s !       // Get the size of the list
s 2 > (        // If list has more than 1 element
  s 1 to (     // Loop through the list starting from index 1
    l i ? k !  // Assign key from list element at index i
    i 1 - j !  // Initialize j to i - 1
    j 0 > k l j ? < (  // While j > 0 and key is less than list[j]
      l j 1 + l j !    // Shift elements to the right
      j 1 - j !        // Decrement j
    )
    k l j 1 + !        // Place the key at the correct position
  )
)
;
```
- `l !`: Pop the list from the stack.
- `l /S s !`: Use /S to get the size of the list and store it in `s`.
` Key and Comparison: Iterates over the list starting from index 1,
  - compares the current element (`k`) with previous elements,
  - and shifts larger elements to the right until the correct position for `k` is found.

# Example of Calling the Function:
`[5 3 8 4 2] I  // Sort the list [5, 3, 8, 4, 2]`
