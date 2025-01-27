// Binary Search

// Initialize variables
0 n! 0 i! 0 j! 0 m! 0 t! 0 f!

// Main binary search function
:B                      // B for Binary search
    h!                 // high index
    l!                 // low index
    t!                 // target value
    
    -1 f!             // found flag/index
    
    // Validate array
    a /S n!           // get array size
    h n >= (          // if high >= size
        `Invalid high index` /N
        /T            // exit
    )
    
    l 0 < (           // if low < 0
        `Invalid low index` /N
        /T
    )
    
    // Main search loop
    /U (              // unlimited loop
        l h <= /W     // while low <= high
        
        // Find middle
        l h + 2 / m!  // middle = (low + high)/2
        
        // Show current state
        `Searching [` l . `,` h . `], middle: ` m . /N
        
        // Compare
        a m ? t = (   // if found target
            m f!      // save index
            /T        // exit loop
        ) /E (        // else
            a m ? t > ( // if target > middle
                m 1 + l! // search right half
            ) /E (     // else
                m 1 - h! // search left half
            )
        )
    )
    
    // Return result
    f -1 = (
        `Target ` t . ` not found` /N
    ) /E (
        `Found target ` t . ` at index ` f . /N
    )
    f                 // leave result on stack
;

// Test function
:T                      // T for Test
    // Test 1: Basic search
    [ 1 3 5 7 9 11 13 15 17 19 ] a!
    `Test 1 - Search for 7` /N
    7 t!              // target
    `Array: ` D
    0 9 7 B /N
    
    // Test 2: First element
    `Test 2 - Search for first element` /N
    1 t!
    0 9 1 B /N
    
    // Test 3: Last element
    `Test 3 - Search for last element` /N
    19 t!
    0 9 19 B /N
    
    // Test 4: Not found
    `Test 4 - Search for missing value` /N
    8 t!
    0 9 8 B /N
    
    // Test 5: Single element
    [ 5 ] a!
    `Test 5 - Single element array` /N
    5 t!
    0 0 5 B /N
;

// Print array helper
:D                      // D for Display
    a /S (             // loop array size times
        a /i ? .       // print number
        ` `           // space
    ) /N
;

// Visual binary search
:V                      // V for Visualize
    [ 2 4 6 8 10 12 14 16 18 20 ] a!
    t!                 // target value
    
    `Binary Search Visualization` /N
    `Array: `
    D
    `Searching for: ` t . /N
    
    0 l!              // initialize bounds
    a /S 1 - h!
    
    /U (              // search loop
        l h <= /W
        
        // Show current range
        n (           // for each position
            /i i!
            i l = i h = | ( `[` ) /E (   // show bounds
            i m = ( `|` ) /E (           // show middle
            ` ` ) )
        ) /N
        
        // Show values
        n (
            /i i!
            a i ? .
            ` `
        ) /N
        
        // Calculate and compare
        l h + 2 / m!
        
        a m ? t = (
            `Found at index ` m . /N
            /T
        ) /E (
            a m ? t > (
                m 1 + l!
            ) /E (
                m 1 - h!
            )
        )
    )
;

// Interactive search
:I                      // I for Interactive
    [ 10 20 30 40 50 60 70 80 90 100 ] a!
    `Interactive Binary Search` /N
    `Array: `
    D
    
    `Enter target value: `
    /K #30 - t!       // read target
    
    `Choose display mode:` /N
    `1. Basic` /N
    `2. Visual` /N
    /K #30 - m!       // read choice
    
    m 1 = (
        0 a /S 1 - t B
    ) /E (
        t V
    )
;

// Educational component
:E                      // E for Educate
    `Binary Search Algorithm` /N
    `--------------------` /N
    `Efficiently finds a value in a sorted array by:` /N
    `1. Looking at middle element` /N
    `2. If target found, return position` /N
    `3. If target smaller, search left half` /N
    `4. If target larger, search right half` /N
    `5. Repeat until found or not possible` /N
    /N
    `Time complexity: O(log n)` /N
    `Space complexity: O(1)` /N
    /N
    `Demonstration:` /N
    [ 2 4 6 8 10 ] a!
    6 V              // visual search for 6
;


///////////////////////

27.1.25

```
:M m a ? t = ( m f! /T ) ;

:H m 1 - h! ;

:L m 1 + l! ;

:B h! l! t! -1 f! 
  /U (
    l h <= /W
    l h + h l - 2 / m!   
    M
    m a ? t < ( H ) /E ( L )
  )
  f -1 = ( `Not found` /N ) /E ( `Found at ` f . /N ) `B-done` ;

:T 
  [1 3 5 7 9 11 13 15 17 19] a!
  `Test: Searching for 7` /N 0 9 7 B
  `Test: Searching for 1` /N 0 9 1 B
  `Test: Searching for 19` /N 0 9 19 B
  `Test: Searching for 8` /N 0 9 8 B ;
```

```
Start
  |
  v
Initialize:
  - Store h, l, t
  - Set f = -1
  |
  v
l <= h ? ------------------ No --> Output: Not Found --> End
  | Yes
  v
Calculate m:
  m = (l + h) // 2
  |
  v
a[m] == t ? --------------- Yes --> Store m in f --> Output: Found at f --> End
  |
  No
  |
  v
a[m] < t ? ---------------- Yes --> Update l = m + 1
  |
  No
  |
  v
Update h = m - 1
  |
  v
Loop back to l <= h
```

```
:B h! l! t! -1 f! 
  /U (
    l h <= /W
    l h + h l - 2 / m!
    m a ? t = ( m f! /T )
    m a ? t < ( m 1 + l! ) /E ( m 1 - h! )
  )
  f -1 = ( `Not found` /N ) /E ( `Found at ` f . /N ) ;
:T 
  [1 3 5 7 9 11 13 15 17 19] a!
  0 9 7 B
  0 9 1 B
  0 9 19 B
  0 9 8 B ;
```



