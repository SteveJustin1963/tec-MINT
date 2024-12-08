```
// bitonic-sort
// Initialize variables


0 n! 0 i! 0 j! 0 k! 0 t! 

// Helper function to swap array elements at positions i,j
:W                    // W for sWap
    a i ? t!          // temp = a[i]
    a j ? a i ?!      // a[i] = a[j]
    t a j ?!          // a[j] = temp
;

// Check if number is power of 2
:P                    // P for Power of 2 check
    " 1 - &          // n & (n-1)
    0 =              // equals 0?
;

// Compare and swap function
:C                    // C for Compare
    i j < (           // if i < j
        a i ? a j ?   // get elements
        > (           // if a[i] > a[j]
            i " k! j i! k j! // save i, swap i,j
            W        // swap elements
            k i! k ' // restore i, drop k
        ) ' '       // drop comparison values
    )
;

// Bitonic merge
:M                    // M for Merge
    k 0 > (          // if k > 0
        k { k!       // k = k/2 (shift left)
        n (          // for n times
            /i " i!  // i = current index
            /i k +   // i + k
            n < (    // if within bounds
                j!   // j = i + k
                C    // compare and swap
            ) '     // drop if outside bounds
        )
        M           // recursive merge
    )
;

// Main bitonic sort
:B                    // B for Bitonic sort
    " /S n!          // get array size
    n P /F = (       // if not power of 2
        `Array size must be power of 2` /N
        /T           // exit
    )
    n 1 > (          // if n > 1
        n { k!       // k = n/2
        n (          // for n times
            /i " i!  // save current index
            /i k < ( // if i < k
                j!   // j = i + k
                C    // compare and swap
            ) '     // drop if not needed
        )
        M           // merge
    )
;

// Print array
:D                    // D for Display
    `Array:` /N
    a /S (           // for array size
        a /i ? .     // print number
        ` ` 
    ) /N
;

// Test different array sizes
:T                    // T for Test
    // Test 1: Array size 4
    [ 4 2 1 3 ] a!
    `Test 1 - Size 4` /N
    `Before:` /N D
    B
    `After:` /N D /N

    // Test 2: Array size 8
    [ 8 4 2 1 6 3 7 5 ] a!
    `Test 2 - Size 8` /N
    `Before:` /N D
    B
    `After:` /N D /N

    // Test 3: Wrong size (not power of 2)
    [ 3 1 4 5 2 ] a!
    `Test 3 - Invalid size` /N
    `Before:` /N D
    B
    `After:` /N D /N
;

// Performance test function
:R                    // R for Random test
    [ 8 6 7 5 3 0 9 1 ] a! // Initialize with random numbers
    `Performance Test` /N
    `Before:` /N D
    `Sorting...` /N
    B
    `After:` /N D
;

```


