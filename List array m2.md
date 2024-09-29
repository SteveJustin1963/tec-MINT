:L
  a /S s !                // Get the size of the array and store it in s
  `Array contents:` /N    // Print header
  s (                     // Loop s times
    /i 1 + .              // Print index (starting from 1)
    `: ` a /i ? . /N      // Print ": " followed by array element and newline
  )
;
