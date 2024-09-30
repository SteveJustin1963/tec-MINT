# Bubble Sort
```
:S l !                         // Store the list passed from the stack into variable l
l /S s !                       // Get the size of the list and store it in s
/T c !                         // Initialize the continue flag (c) to true
/U (                           // Start an unlimited loop for swapping
  c /W                         // Break the loop early if no swaps occurred (c == false)
  s 1 - (                      // Iterate over the list (size - 1 times)
    l i ? x !                  // Store l[i] in x
    l i 1 + ? y !              // Store l[i+1] in y
    x y > (                    // Compare x and y (l[i] and l[i+1])
      y l i !                  // Move y (l[i+1]) to l[i]
      x l i 1 + !              // Move x (l[i]) to l[i+1]
      /F c !                   // Set the continue flag to false (indicating a swap occurred)
    )
  )
)
;
```

- Temporary Variables: `x` stores `l[i]` and y stores `l[i+1]` to avoid repetition when swapping elements.
- Continue Flag Initialization: The continue flag `c` is initialized to true `(/T c !)` once at the start before the loop begins.
- Early Check for Continue Flag: The loop checks `c /W` early in each pass. If `c == false` (no swaps occurred in the previous pass), the loop terminates early.

# Example of Calling the Function:
- `[5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]`
- `[5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]`
- `[5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]`

