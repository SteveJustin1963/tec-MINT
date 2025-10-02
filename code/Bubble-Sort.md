///////////////// tested working 3.10.2025

```
:S
l ! l /S s !
s 1 - p !
0 i !
p (
  0 j !
  s 1 - (
    l j ? l j 1 + ? > /T = (
      l j ? t !
      l j 1 + ? l j ?!
      t l j 1 + ?!
    )
    j 1 + j !
  )
  i 1 + i !
)
`Sorted: ` 
0 k !
s ( l k ? . 32 /C k 1 + k ! ) 
/N
;
```
```
// usage
// [ 4 7 6 3 5 567 3 56 2 ] S
// [ 345 5483 456 2437 235 24 45 2 5 7 4 2 4 7 4 2 3 5 3 4345 2 45 6  2] S
```

//////////////////////////////////////////////////////



```
:S
l !                          // Pop array from stack, store in variable l
l /S s !                     // Get array size, store in variable s

s 1 - p !                    // Calculate number of passes needed (size-1), store in p

0 i !                        // Initialize outer loop counter i to 0
p (                          // Outer loop: repeat p times (for each pass)
  
  0 j !                      // Initialize inner loop counter j to 0
  s 1 - (                    // Inner loop: compare s-1 pairs of adjacent elements
    
    l j ? l j 1 + ? >        // Get l[j] and l[j+1], compare: is l[j] > l[j+1]?
    /T = (                   // If comparison result equals TRUE (-1)
      
      l j ? t !              // Store l[j] in temporary variable t
      l j 1 + ? l j ?!       // Move l[j+1] into position j (shift smaller left)
      t l j 1 + ?!           // Move t (original l[j]) into position j+1 (shift larger right)
    )
    
    j 1 + j !                // Increment inner counter: j = j + 1
  )
  
  i 1 + i !                  // Increment outer counter: i = i + 1
)

// Print sorted array
`Sorted: `                   // Print label

0 k !                        // Initialize print counter k to 0
s (                          // Loop through all s elements
  l k ? .                    // Get element at index k and print it
  32 /C                      // Print space character (ASCII 32)
  k 1 + k !                  // Increment print counter: k = k + 1
)

/N                           // Print newline
;



```
