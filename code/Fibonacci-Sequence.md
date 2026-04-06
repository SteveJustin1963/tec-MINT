Fibonacci Sequence
A loop that prints the first 10 numbers of the Fibonacci sequence.
```
:F n !        // Pop the number of iterations (n) from the stack
0 a ! 1 b !   // Initialize a = 0, b = 1
n (           // Loop n times
  a .         // Print current Fibonacci number
  a b + c !   // c = a + b
  b a !       // a = b
  c b !       // b = c
)
;
```
n !: Pops the number of iterations from the stack and assigns it to n.
The loop runs n times, printing a and updating a and b in each iteration.

Example of Calling the Function:
`10 F  // Print the first 10 Fibonacci numbers`
