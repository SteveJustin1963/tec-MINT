```
// Tower of Hanoi
// Initialize variables

0 n! 0 s! 0 t! 0 f! 0 m! 0 c!

// Create pegs (arrays to represent each rod)
[ 0 0 0 0 0 0 0 0 0 0 ] p1!  // source peg
[ 0 0 0 0 0 0 0 0 0 0 ] p2!  // target peg
[ 0 0 0 0 0 0 0 0 0 0 ] p3!  // spare peg
[ 0 0 0 0 0 0 0 0 0 0 ] h!   // heights of pegs

// Move disk between pegs
:M                      // M for Move
    t!                 // to peg
    f!                 // from peg
    
    // Get heights
    h f ? i!          // source height
    h t ? j!          // target height
    
    // Move disk
    f 1 = ( p1 i 1 - ? ) /E (
    f 2 = ( p2 i 1 - ? ) /E (
    p3 i 1 - ? ) ) k!  // get disk
    
    t 1 = ( k p1 j ?! ) /E (
    t 2 = ( k p2 j ?! ) /E (
    k p3 j ?! ) )      // place disk
    
    // Update heights
    i 1 - h f ?!       // decrease source
    j 1 + h t ?!       // increase target
    
    // Print move
    `Move disk ` k . ` from rod ` f . ` to rod ` t . /N
    
    c 1 + c!           // increment move counter
;

// Main Hanoi recursive function
:H                      // H for Hanoi
    s!                 // spare rod
    t!                 // target rod
    f!                 // source rod
    n!                 // number of disks
    
    n 1 = (           // if only one disk
        f t M         // move it directly
    ) /E (            // else
        n 1 - " f s t H  // move n-1 disks to spare
        f t M             // move nth disk to target
        n 1 - s t f H    // move n-1 from spare to target
    )
;

// Initialize pegs
:I                      // I for Initialize
    n!                // number of disks
    
    // Clear all pegs
    n 1 + (           // for each position
        0 p1 /i ?!
        0 p2 /i ?!
        0 p3 /i ?!
    )
    
    // Set up source peg
    n (               // for each disk
        /i i!         // get position
        n i - 1 +     // disk size (largest at bottom)
        p1 i ?!       // place on first peg
    )
    
    // Set heights
    n h 1 ?!          // source has n disks
    0 h 2 ?!          // others empty
    0 h 3 ?!
    
    0 c!              // reset move counter
;

// Print current state
:P                      // P for Print state
    `Current state:` /N
    `Rod 1:` /N
    h 1 ? (           // for each disk
        p1 /i ? " 0 > ( // if disk present
            p1 /i ? .  // print disk
            ` `
        ) '
    ) /N
    `Rod 2:` /N
    h 2 ? (
        p2 /i ? " 0 > (
            p2 /i ? .
            ` `
        ) '
    ) /N
    `Rod 3:` /N
    h 3 ? (
        p3 /i ? " 0 > (
            p3 /i ? .
            ` `
        ) '
    ) /N /N
;

// Main entry point
:R                      // R for Run
    n!                // number of disks
    n 1 < (           // if invalid
        `Need at least one disk` /N
        /T
    )
    
    n I              // initialize
    `Initial state:` /N
    P
    
    // Solve
    n 1 2 3 H        // source=1, target=2, spare=3
    
    `Final state:` /N
    P
    `Total moves: ` c . /N
;

// Test function
:T                      // T for Test
    // Test 1: One disk
    `Test with 1 disk:` /N
    1 R /N
    
    // Test 2: Two disks
    `Test with 2 disks:` /N
    2 R /N
    
    // Test 3: Three disks
    `Test with 3 disks:` /N
    3 R /N
;

// Visualization with step tracking
:Z                      // Z for viZualize
    3 n!              // solve for 3 disks
    n I              // initialize
    
    `Tower of Hanoi Visualization` /N
    `Initial state:` /N
    P
    
    // Modified Hanoi with visualization
    :V                 // V for Visualize recursion
        s!            // spare rod
        t!            // target rod
        f!            // source rod
        n!            // number of disks
        
        n 1 = (
            f t M
            P
        ) /E (
            n 1 - f s t V
            f t M
            P
            n 1 - s t f V
        )
    ;
    
    n 1 2 3 V
    
    `Total moves: ` c . /N
;

// Educational component
:E                      // E for Educate
    `Tower of Hanoi` /N
    `-------------` /N
    `Rules:` /N
    `1. Move only one disk at a time` /N
    `2. A larger disk cannot be placed on a smaller disk` /N
    `3. All disks must move to the target rod` /N
    /N
    `Number of moves required: 2^n - 1` /N
    `where n is the number of disks` /N
    /N
    `Demonstration with 2 disks:` /N
    2 R
;
```


