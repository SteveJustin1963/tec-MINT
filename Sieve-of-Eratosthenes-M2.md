# Sieve of Eratosthenes
A simple implementation of the Sieve of Eratosthenes to find prime numbers up to 30.
```
:S l !             // Pop the limit from the stack
2 p !              // Initialize p to 2 (start from the first prime)
l 2 - (            // Loop from 2 to the limit
  /T f !           // Set flag assuming p is prime
  p 2 * l < (      // Loop for multiples of p within the limit
    p i % 0 = (    // If p is divisible by i
      /F f !       // Set flag to false if divisible
    )
  )
  f /T = (         // If the flag is still true, print the prime
    p .
  )
  p 1 + p !        // Increment p
)
;

```
# Explanation:

- `S l !`: The limit l (e.g., 30) is passed from the stack and stored in l.
- `2 p !`: The starting number for checking primes is set to 2 (the first prime number).
- Loop: The loop iterates over numbers from 2 to l - 1.
  - `/T f !`: A flag f is initially set to true, assuming the number is prime.
  - Multiples Check: For each number p,
    - another loop checks if p is divisible by any number between 2 and `p - 1`
    - If p is divisible by i (i.e., `p % i == 0`), the flag f is set to false (`/F f !`)
  - Prime Check: After checking all divisors,
    - if the flag f remains true (`f /T =`), the number p is prime and is printed (p .)
  - Increment: After each iteration, p is incremented by 1 (`p 1 + p !`)
 
# Example of Calling the Function:
`30 S  // Set the limit to 30 and call the sieve function`
