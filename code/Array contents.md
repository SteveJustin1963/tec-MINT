```
//MINT 2

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
