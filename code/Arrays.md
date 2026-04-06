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
```
:L
  a /S s !                // Get the size of the array and store it in s
  `Array contents:` /N    // Print header
  s (                     // Loop s times
    /i 1 + .              // Print index (starting from 1)
    `: ` a /i ? . /N      // Print ": " followed by array element and newline
  )
;
```
//////////////////////////////////////////
```
 
:L
  a /S s !
  `Array contents:` /N
  s (
    /i 1 + .
    `: ` a /i ? . /N
  )
;

// run the code
> [ 1 2 3 4 5]a! L

Array contents:
1 : 1
2 : 2
3 : 3
4 : 4
5 : 5

>
```

////////////////////

arrays are declared using [ ]. 
but we cannot declare an empty one as [ ] n ! with a given for later use
we can get the array size with /S 
set array size with [ 3 /S ] // not sure whats best here - future feature ?


this works
```
:A /Ka! /Kb! /Kc!;
:B [a b c] d! ;
:C d0?. d1?. d2?. ;   // or :C d0?/C d1?/C d2?/C  ;
:D 1(A B C) ;

> D 
123
49 50 51
>D 
abc
97 98 99
>
``` 
```
> [ a b c] a! 
> a/S .
3
>
```
we can use loop counters /i and /j to also control array size and access


also this works 
```
// Define an array of 5 elements and store its address in 'a'
[ 0 0 0 0 0 ] a! // need to initialise each time 

// Loop 5 times to read input and store in the array
5 (
  `Enter a digit: `       // Prompt the user
  /K 48 - n!              // Read a character, convert ASCII digit to number, store in 'n'
  n a /i ?!  /N              // Store 'n' into array at index /i
)

// Loop 5 times to print each element of the array
5 (
  `Value is: `            // Print label
  a /i ? .  /N              // Fetch array element at index /i and print it
)

/////////////

: A [ 0 0 0 0 0 ] a! ; 
: B 5 ( `Enter a digit: `  /K 48 - n!  n a /i ?!  /N ) ;
: C 5 ( `Value is: ` a /i ? .  /N ) ;

// run it
ABC

///////////////////
```
