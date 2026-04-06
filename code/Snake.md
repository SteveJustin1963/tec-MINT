Run sequence:
1. Enter code exactly as shown
2. Type `I` - shows start screen
3. Type `M` - starts game

Controls:
- W: Up 
- S: Right
- A: Down
- D: Left

Board shows:
- @ = Snake segments
- * = Food
- Score at top
- Borders around play area
- 8x8 grid display

Game ends when snake hits itself or score reaches 10.


```
// Initial variables
8w!     // width
2l!     // length
0d!     // direction
10s!    // score needed
0h!     // head position
0t!     // tail position
0f!     // food position
0g!     // game over flag
0p!     // Position 1
0q!     // Position 2
[p q]s! // Snake array

:I
0h!                   // Reset head
32s0?!               // Set middle position
0g!                  // Reset game over
N
`Snake Game` /N
`Use WASD to move` /N;

:U
s0?h!                // Get head
d0=(h8-h!)          // Up
d1=(h1+h!)          // Right
d2=(h8+h!)          // Down
d3=(h1-h!)          // Left
h0<(h64+h!)         // Wrap top
h63>(h64-h!)        // Wrap bottom
hf=(                 // Hit food:
  l1+l!              // Increase length
  s1-s!              // Score
  h p! [p q]s!       // Update array
  N                  // New food
)/E(                 // No food:
  h p! [p q]s!       // Update array
  s/S1-s!            // Remove tail
)
s/S1-(s/i?h=(1g!));  // Self collision

:M
R                    // Read
sD                   // Delay
H                    // Handle input
U                    // Update
g/F=(M);             // Loop if not game over

:R
`\n\n\n\n\n\n\n\n`  // Clear screen
`Score:` l . /N      // Show score
`================` /N
0y!                  // Reset row counter
8(                   // For each row
  0x!                // Reset column
  8(                 // For each column
    s/S(             // Check snake segments
      s/i?x y w * + = (`@`)/E(` `) // Print @ if snake here
    )
    x1+x!            // Next column
  )/N                // New line after row
  y1+y!              // Next row
)
`================` /N;

:N
/rw%"16*w%+"f!;     // New food position

:D
100(100());         // Delay

:H
/K                  // Get key
87=(d2=/F=(3d!))   // W
83=(d3=/F=(1d!))   // S
65=(d0=/F=(2d!))   // A
68=(d1=/F=(0d!));  // D
```
