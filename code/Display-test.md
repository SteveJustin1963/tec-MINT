```
// Hex digit to 7 segments conversion table
\[#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47] c!

// Display buffer initialization
\[0 0 0 0 0 0] d!

// Convert char to 7segments
:A c @ + \@ ;

// Read char from string, convert to seg and write to buffer
:B #0F & A $ \! ;

// Rshift val 4 bits and decrement buf ptr
:C } } } } $ 1 - $ ;

// Write 4 hex digits from val to buf
:D d @ 3 + $ 4 ( % % B C ) ' ' ;

// Write digit bit, keep bit 6 high
:E #40 | 1 \O ;

// Output segment + digit info to LEDs
:F \@ 2 \O ;

// Move to next segment, inc buf ptr
:G } $ 1 + $ ;

// Display scan 6 digits
:H \d @ #20 6 ( % % E F G ) ' ' ;

// Count to 10, convert, scan 100 times
:J 10 ( \i @ D 100 ( H ) ) 0 E ;

// Test cases
0 A .
15 A .

```
