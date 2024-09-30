# Tower of Hanoi
```
:H s ! t ! f ! n !      // Pop the number of disks and rods (source, target, spare) from the stack
n 1 = (                 // If there is only 1 disk
  f t m !               // Move from source to destination
) /E (                  // Else
  n 1 - f t s H !       // Move n-1 disks from source to spare
  f t m !               // Move nth disk to destination
  s t f H !             // Move n-1 disks from spare to destination
)
;
```

- `s ! t ! f ! n !`: Pops the number of disks n, source rod f, target rod t, and spare rod s from the stack in the correct LIFO order.
` Recursive Steps:
  - If there's only 1 disk, it moves directly from the source to the destination.
  - If there are more than 1 disk, it recursively moves n-1 disks to the spare rod, moves the nth disk to the target, and then moves the n-1 disks from the spare to the target.

# Example of Calling the Function:
`3 f t s H .  // Solve Tower of Hanoi for 3 disks`
