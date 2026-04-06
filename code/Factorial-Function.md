Factorial Function
A recursive function that calculates the factorial of a number.
```
:F
  "           // Duplicate n
  1 >         // Check if n > 1
  (           // If true
    " 1 - F * // n * factorial(n - 1)
  ) /E (      // Else condition wrapped in parentheses
    1         // Return 1
  )
;

 
5 F .         // Calculate factorial of 5, prints: 120
```

This function recursively calculates the factorial of a number n.
- If n > 1, it calls itself with n - 1 and multiplies n by the result.
- If n is 1 or less, it returns 1, which is the base case to stop recursion.
