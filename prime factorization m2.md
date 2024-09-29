prime factorization method for integers between 0 and hex FFFF

```
// Read multi-digit number function
:R
  0 n !                  // Initialize number to 0
  /U (                   // Start unlimited loop
    /K c !               // Read a character
    c 10 = (             // If character is newline (ASCII 10)
      n                  // Return the number
    ) /E (               // Else
      c 48 - d !         // Convert ASCII to digit
      n 10 * d + n !     // n = n * 10 + digit
    )
  )
;

// Prime Factorization Function
:F
  n !                  // Store input number in n
  n 2 < (              // If n < 2
    `Not applicable for numbers less than 2` // Print error message
  ) /E (               // Else
    n " .              // Print the original number
    ` = `              // Print equals sign
    2 f !              // Initialize factor to 2
    /U (               // Start unlimited loop
      n 1 > /W         // Continue while n > 1
      n f % 0 = (      // If n is divisible by f
        f .            // Print the factor
        n f / n !      // Divide n by f
        n 1 > (        // If n is still greater than 1
          ` * `        // Print multiplication sign
        )
      ) /E (           // Else
        f 1 + f !      // Increment f
      )
    )
  )
;

// Test function
:T
  /U (                           // Start unlimited loop
    `Enter a number (0 to quit): `  // Prompt for input
    R                            // Read number using R function
    " 0 = (                      // If input is 0
      `Exiting`                  // Print exit message
      /N                         // Print newline
    ) /E (                       // Else
      F                          // Call factorization function
      /N                         // Print newline
    )
  )
;
```
