```
// MINT 2.0
// Exponentiation in MINT (Power Function)

:pow
    b !                           // Store the base in 'b'
    e !                           // Store the exponent in 'e'
    1 r !                         // Initialize result 'r' to 1
    e (                            // Loop 'e' times
        r b * r !                  // Multiply current result by the base
    )
    r .                            // Print the result
;

// to run
> 2 3 pow
8
>
```
