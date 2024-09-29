# Greatest Common Divisor (GCD) using Euclidean Algorithm
This program finds the GCD of two numbers using the Euclidean algorithm.
```
:A b ! a !    // Pop two numbers from the stack in LIFO order (b first, then a)
/U (          // Begin an unlimited loop
  b 0 > /W    // Continue while b > 0 (break if b == 0)
  a b % a !   // a = a mod b
  a b !       // Swap: b = old a, repeat
)
a .           // Print the GCD
;
```
- `/W` as a Loop-While: The `/W` construct functions as a loop-while, where the loop continues as long as the condition is true (non-zero). When the condition becomes false (zero), the loop terminates.
- `b 0 > /W`: This checks if b is greater than 0 at each iteration.
`- The loop continues while b > 0 and breaks when b == 0, completing the Euclidean algorithm.

# Example of Calling the Function:
`30 20 A       // Calculates the GCD of 30 and 20, prints GCD: 10`

