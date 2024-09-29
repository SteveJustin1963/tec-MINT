# Quick Sort
An implementation of the Quick Sort algorithm.
`
:Q s ! l !       // Pop the list and its size from the stack (LIFO order)
l s > 1 (        // If list length is greater than 1
  l p c !        // Choose a pivot element
  l s p p !      // Partition list around pivot
  s Q ! p Q !    // Recursively sort partitions
)
;
```

- `s ! l !`: Pops the list l and its size s from the stack in the correct LIFO order.
- `l s > 1`: Checks if the list length is greater than 1 to determine whether sorting is necessary.
- Recursive Sorting: It partitions the list around a pivot and recursively sorts both partitions until the base case is reached.

# Example of Calling the Function:
[`5 3 8 4 2] 5 Q  // Sort the list [5, 3, 8, 4, 2]`
