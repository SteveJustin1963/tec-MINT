```
// Initialize array with test values
[ 100 50 75 200 10 ] a!   // store array in variable a

// Define main radix sort function
:R                        // R for RadixSort function
    a /S s!              // get array size into s
    #1 e!                // initialize exponent (e) to 1
    0 m!                 // initialize max (m) to 0
    
    // Find maximum number to determine digits
    s (                  // loop array size times
        a /i ? " m!      // get array value and duplicate to m
        m > (            // if current > max
            m!           // update max
        ) ' '           // else drop it
    )
    
    // Main radix sort loop
    /U (                  // unlimited loop
        m e / 1 < /W      // while max/exp >= 1
        
        // Counting sort for current digit
        [ 0 0 0 0 0 0 0 0 0 0 ] c!   // counting array 0-9 in c
        
        // Count occurrences of each digit
        s (              // loop array size times
            a /i ? e /   // get digit at current exp
            #A * }       // shift right for ones digit
            " c $ + $    // increment count (dup, swap, add, swap)
            c $ !        // store back in count array
        )
        
        // Calculate positions
        1 p!             // position counter
        9 (             // loop for positions 0-9
            c /i ? c /i 1 + ? +   // add current and next count
            c /i 1 + !            // store sum back in count array
        )
        
        // Build output array
        [ 0 0 0 0 0 ] o!  // output array in o
        s 1 - n!          // n = size-1
        n 1 + (           // loop n+1 times
            a /i ? t!     // get current number into t
            t e / #A * } d!  // get digit at current exp into d
            c d ? 1 - p!   // get position-1 from count[digit]
            t o p ?!      // put number in output[position]
            c d ? 1 - c d ?!  // decrement count[digit]
        )
        
        // Copy back to original array
        s (              // loop size times
            o /i ? a /i ?!  // copy output[i] to array[i]
        )
        
        e #A * e!        // exp = exp * 10
    )
;

// Print array helper function  
:P 
    a /S (             // loop array size times
        a /i ? . /N    // print each number with newline
    )
;

// Main program
:M
    `Original array:` /N
    P                  // print original
    R                  // run radix sort
    `Sorted array:` /N  
    P                  // print result
;


```



