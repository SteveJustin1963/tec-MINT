```
// bubble sort

:S 
  // Store the list passed from the stack into variable l
  l !
  // Get the size of the list
  l /S s !
  // Outer loop: repeat until no swaps are made
  /U (
    // Reset swap flag to false at the start of each pass
    /F f !
    // Inner loop: iterate through the list
    s 1 - (
      // Get current and next elements
      l /i + ? x !
      l /i 1 + + ? y !
      // If current > next, swap them
      x y > (
        y l /i + !
        x l /i 1 + + !
        // Set swap flag to true
        /T f !
      )
    )
    // If no swaps were made, exit the loop
    f /F = /W
  )
;

// Example usage
[5 3 8 4 2] S  // Sort the list [5, 3, 8, 4, 2]
l .            // Print the sorted list

```
