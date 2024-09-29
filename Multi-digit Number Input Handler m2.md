```
// Read multi-digit number function and store in variable a
:R
  0 a !                  // Initialize a to 0
  /U (                   // Start unlimited loop
    /K c !               // Read a character (stored as ASCII value)
    c /C                 // Debug: Print character
    c 13 = c 10 = | (    // If CR (13) or NL (10)
      /N                 // Print newline
      `Number stored: `  // Debug: Print stored number
      a .                // Print value of a as a number
      /N                 // Print newline
    ) /E (               // Else
      c 48 >= c 57 <= & (  // If valid digit (ASCII 48-57)
        a 10 * c 48 - + a !  // a = a * 10 + (c - 48)
      ) /E (             // Else (invalid input)
        `Invalid input, ignoring` /N
      )
    )
  )
;

// Test function
:T
  /U (                           // Start unlimited loop
    `Enter a number (333 to exit): `  // Prompt for input
    R                            // Call input function
    a 333 = (                    // If input is 333
      `Exiting` /N               // Print exit message and newline
    ) /E (                       // Else
      `Continue...` /N           // Print continue message
    )
  )
;
```
