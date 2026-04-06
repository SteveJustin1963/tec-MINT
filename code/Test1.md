```
// Character to 7-segment conversion table
\[
#00 #18 #00 #00 #00 #00 #00 #00
#00 #04 #10 #00 #00 #00 #00 #00
#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F
#00 #00 #00 #00 #00 #00 #00
#6F #E6 #C3 #EC #C7 #47 #E3 #6E
#28 #E8 #CE #C2 #6B #6B #EB #4F
#2F #43 #A7 #46 #EA #E0 #EA #6E
#AE #CD
] c!

// Display buffer initialization
\[0 0 0 0 0 0] d!

// Convert char to 7segments
:A #20 - c @ + \@ ;

// Read char from string, convert to seg and write to buffer
:B \@ A $ \! ;

// Increment str ptr and buf ptr
:C 1 + $ 1 + $ ;

// Copy 6 chars from str to seg buffer
:D 6 ( % % B C ) ' ' ;

// Write digit bit, keep bit 6 high
:E #40 | 1 \O ;

// Output segment + digit info to LEDs
:F \@ 2 \O ;

// Move to next segment, inc buf ptr
:G } $ 1 + $ ;

// Display scan 6 digits
:H \d @ #20 6 ( % % E F G ) ' ' ;


// Scan 100 times
:I 100 ( H ) 0 E ;

// Count to 10, convert, scan 100 times
:J 10 ( 
    \i @ D   // Convert current count to display format
    I        // Scan display 100 times
) ;

// Additional function X (from the DB statement)
:X HELLO THERE ITS ME AGAIN!              ;

// Test cases
10000 ( ) #41 #20 - c @ + \@ .
72 A .
?X \@ A .
d @ ?X D d @ \@ .
d @ ?X D I
J \P \N

```






 

