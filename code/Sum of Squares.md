```

// Sum of Squares 
// Initialize variables

0 n! 0 i! 0 j! 0 s! 0 t! 0 a! 0 b!

// Main sum of squares function
:S                      // S for Sum of squares
    b!                 // end number
    a!                 // start number
    
    // Validate input
    b a < (            // if end < start
        `Invalid range` /N
        /T             // exit
    )
    
    0 t!              // initialize total
    a i!              // current = start
    b a - 1 + n!      // number of iterations
    
    // Print header
    `Sum of Squares Calculator` /N
    `Range: ` a . ` to ` b . /N
    `Number of terms: ` n . /N
    
    // Calculate sum
    n (               // for each number
        `Term ` /i 1 + . `: ` // show term number
        i .          // show current number
        ` squared = ` 
        i i * s!     // calculate square
        s .          // show square
        t s + t!     // add to total
        ` (Running total: ` t . `)` /N
        i 1 + i!     // increment current
    )
    
    // Show final result
    /N
    `Final sum of squares from ` a . ` to ` b . `: ` t . /N
;

// Test function
:T                      // T for Test
    // Test 1: Small range
    `Test 1: Range 1-5` /N
    1 5 S /N
    
    // Test 2: Single number
    `Test 2: Single number` /N
    3 3 S /N
    
    // Test 3: Zero start
    `Test 3: Range 0-3` /N
    0 3 S /N
    
    // Test 4: Invalid range
    `Test 4: Invalid range` /N
    5 1 S /N
;

// Calculate and show formula
:F                      // F for Formula
    b!                 // end number
    a!                 // start number
    
    `Formula explanation:` /N
    `Sum of squares from n=a to b is:` /N
    `Σ(n²) = [n(n+1)(2n+1)]/6` /N
    
    // Calculate using formula
    b b 1 + * b 2 * 1 + * 6 / s!
    a 1 - a * a 1 - 2 * 1 + * 6 / t!
    s t - n!
    
    `Using formula for ` a . ` to ` b . `:` /N
    `Result = ` n . /N
    
    // Compare with iteration
    `Verifying with iteration:` /N
    a b S
;

// Visual representation
:V                      // V for Visualize
    b!                 // end number
    a!                 // start number
    
    `Visual squares from ` a . ` to ` b . `:`/N
    
    a i!              // start number
    b 1 + (           // for each number
        i .           // show number
        `: `
        i i * j!      // calculate square
        j (           // print dots for square
            `*`
        )
        ` (` j . `)` /N
        i 1 + i!
    )
;

// Educational component
:E                      // E for Educate
    `Sum of Squares` /N
    `--------------` /N
    `This program calculates the sum of squared numbers` /N
    `in a given range using two methods:` /N
    `1. Iteration: Adding each square one by one` /N
    `2. Formula: Using mathematical formula` /N
    /N
    `Example with range 1-4:` /N
    `1² + 2² + 3² + 4² = 1 + 4 + 9 + 16 = 30` /N
    /N
    `Demonstration:` /N
    1 4 S
;

// Interactive mode
:I                      // I for Interactive
    `Enter start number: ` /N
    /K #30 - a!       // read and convert to number
    
    `Enter end number: ` /N
    /K #30 - b!       // read and convert to number
    
    `Choose output:` /N
    `1. Basic calculation` /N
    `2. Visual representation` /N
    `3. Formula comparison` /N
    
    /K #30 - n!       // read choice
    
    n 1 = ( a b S ) /E (
    n 2 = ( a b V ) /E (
    a b F ) )
;

```



