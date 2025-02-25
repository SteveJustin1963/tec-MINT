mint V1

```
Counter

Write a program that counts up from 0 in hex incrementing every second.
=======================================
Here's the code
---
New in this example:
:G $ #0F& E $ \! ;
:H b@ 3+ 4( %% G 1- $ }}}} $ ) '' ;
:I #FFFF( \i@ H 100( B ) ) ;
---
Reused from last time:
\[0 0 0 0 0 0] ' b!
:A 2\O #40| 1\O 10() #40 1\O ;
:B #20 b@ 6( %% \@ A 1+ $}$ ) '' ;
\[#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47] ' c!
:E c@ + \@ ;
---
Run code with command I
===============================================
Command G: convert nibble to segments

Write a command which converts the lower 4 bits of a number into segments data and stores them at address
--
\\ ( number address -- )
:G $ #0F& E $ \! ;
--
:G declare a command called `G`
$ swap so that `number` is on top
#0F& mask bottom 4 bits of `number`
E get segments for nibble (see https://www.facebook.com/.../tec1z80/posts/1262903740885339/)
$ swap so that `address` is on top
\! write segments data to buffer address
; end of command
---
Command H: convert a number into segments data and store them in buffer
---
\\ ( number -- )
:H b@ 3+ 4( %% G 1- $ }}}} $ ) '' ;
---
:H declare a command called `H`
b@ get the address of the start of the display buffer
3+ get address of 3rd digit (we will write segment data for digits 3,4,5 and 6)
4( loop 4 times, once for each of the 4 digits
%% duplicate the top two items of stack: `number` and `address`
G convert the lower 4 bits of `number` into segments and store at `address`, consume both
1- decrement address
$ swap so that `number` is on top
}}}} shift `number` right by 4 bits
$ swap so that `address` is on top
) end of loop
' ' drop the top two items
; end of command
---
Main program
---
:I #FFFF( \i@ H 100( B ) ) ;
---
:I declare a command called `I`
#FFFF( count up from 0 to #FFFF
\i@ get loop counter variable
H convert to segments in buffer
100( B ) scan the display for about 1 second (on a 4MHz Z80)
) end of loop
; end of command
```

mint V2
no comments
```
\[0 0 0 0 0 0] b!
\[#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47] c!
:A 2 /O #40|1 /O 10()#40 1 /O;
:B #20 d! 6(d\? A 1+d}d!)'';
:E c?+\?;
:G $#0F&E$\!;
:H b?3+4(%%G 1-$}}}}$)'';
:I #FFFF(/i H 100(B));
```

with comments
```
// Display buffer for 6 digits
\[0 0 0 0 0 0] b!

// Segment patterns for hex digits 0-F
\[#EB #28 #CD #AD #2E #A7 #E7 #29 #EF #2F #6F #E6 #C3 #EC #C7 #47] c!

// Display a segment pattern at current digit position
:A 2 /O #40 | 1 /O 10() #40 1 /O;

// Scan the display 
:B #20 d! 6( d \? A 1+ d } d! ) '';

// Convert nibble to segment pattern
:E c? + \?;

// Convert nibble to segments and store at address
// (number address -- )
:G $ #0F & E $ \!;

// Convert a number to segments and store in buffer
// (number -- )
:H b? 3+ 4( %% G 1- $ } } } } $ ) '';

// Main program - count in hex
:I #FFFF( /i H 100( B ) );
```


