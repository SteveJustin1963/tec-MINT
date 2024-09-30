# Binary Search
A binary search algorithm that searches for a value in a sorted array.
```
:B h ! l !             // Pop high and low indices from the stack (LIFO order)
l h <= (               // While low <= high
  m l h + 2 / !        // Find the middle index
  m a ? t = (          // If value at m is target
    m .                // Print index
  ) /E (               // Else block for equality wrapped in parentheses
    m a ? t < (        // If target is smaller, search left half
      m 1 - h !
    ) /E (             // Else block for greater condition wrapped
      l m 1 + !
    )
  )
)
;
```

- `h ! l !`: Pops the high (h) and low (l) indices from the stack in the correct LIFO order. When the function is called, you push the high value first, followed by the low value.
- The binary search logic proceeds as normal:
  - Find the middle: `m l h + 2 / !` calculates the middle index.
  - Compare: If the middle value matches the target, print the index. Otherwise, adjust the search range accordingly (either update `l` or `h`).
# Example of Calling the Function:
`0 9 B       // Searches in a sorted array from index 0 to 9`
