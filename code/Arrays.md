```
// Define an array of 5 elements and store its address in 'a'
[ 0 0 0 0 0 ] a!

// Loop 5 times to read input and store in the array
5 (
  `Enter a digit: `       // Prompt the user
  /K 48 - n!              // Read a character, convert ASCII digit to number, store in 'n'
  n a /i ?!               // Store 'n' into array at index /i
)

// Loop 5 times to print each element of the array
5 (
  `Value is: `            // Print label
  a /i ? .                // Fetch array element at index /i and print it
)

```

////////////////////
```
// Define a function to read a multi-digit number
:@
  0 n!                      // Initialize n to 0
  /U (                      // Start an unlimited loop
    /K k!                   // Read a character, store in k
    k 13 = /W               // If Enter key (ASCII 13), break loop
    k 48 -                  // Convert ASCII digit to number
    n 10 * + n!             // n = n * 10 + (k - 48)
  )
; read_number!

// Define an array of 5 elements and store its address in 'a'
[ 0 0 0 0 0 ] a!

// Loop 5 times to read input and store in the array
5 (
  `Enter a number: `
  read_number /G            // Call the read_number function
  n a /i ?!                 // Store 'n' into array at index /i
)

// Loop 5 times to print each element of the array
5 (
  `Value is: `
  a /i ? .
)



```
///////////////////////

:L
  a /S s !                // Get the size of the array and store it in s
  `Array contents:` /N    // Print header
  s (                     // Loop s times
    /i 1 + .              // Print index (starting from 1)
    `: ` a /i ? . /N      // Print ": " followed by array element and newline
  )
;

//////////////////////////////////////////

// no labels
:L
  a /S s !
  `Array contents:` /N
  s (
    /i 1 + .
    `: ` a /i ? . /N
  )
;
//////////////////////////////////////////


> [ 1 2 3 4 5]a! L
Array contents:
1 : 1
2 : 2
3 : 3
4 : 4
5 : 5

>
```
