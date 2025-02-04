```
// Function L: Natural logarithm approximation using Taylor series
:L x!                     
   1000 x * f!           // Convert x to fixed-point (x * 1000)
   0 r!                  // Reset result accumulator
   f 1 - n!              // n = x - 1 (to fit LN(1+n))
   n 1000 * t!           // t = 1000 * n (fixed-point)
   1 s!                  // Start denominator at 1
   5(                    // Use 5 terms of Taylor series
      t s / a!           // a = (t / s)
      s 1 + s!           // Increment denominator
      s 2 % 0 = (a -1 * a!)  // Alternate sign between positive/negative
      a r + r!           // Accumulate result
   )
   r 1000 / .           // Convert back and print
;

// Function R: Calculate entropy of input numbers
// Note: reusing variable 'a' as we need 27 slots but only have 26 letters
:R [a b c d e f g h i j k l m n o p q r s t u v w x y z a b] d!  // Initialize array
   27(                   // Read 27 numbers
      `Enter digit (0-9):` /K 48 - n!  // Read digit
      n d /i ?!          // Store in array
   )
   0 e!                  // Initialize entropy
   27(                   // Process all numbers
      d /i ? f!          // Get current number
      0 s!               // Reset frequency counter
      27(               // Count occurrences
         d /j ? f = (s 1 + s!)
      )
      s 27 * 1000 / l!  // Calculate probability
      l 0 > (           // If probability > 0
         l L p!         // Get natural log
         l p * 1000 / e + e!  // Add to entropy
      )
   )
   e NEG 1000 / .       // Print final entropy
;
```

