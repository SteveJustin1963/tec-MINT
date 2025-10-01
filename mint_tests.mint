10 20 + .  // 30

50 20 - .  // 30

5 6 * .  // 30

20 4 / .  // 5

10 5 > .  // -1

5 10 < .  // -1

10 10 = .  // -1

5 5 = .  // -1

3 5 = .  // 0

#FF #0F & ,  // 000F

#F0 #0F | ,  // 00FF

#FF #0F ^ ,  // 00F0

#0F ~ ,  // -016

1 { ,  // 0002

8 } ,  // 0004

10 20 30 ' . .  // 20 10

5 " . .  // 5 5

10 20 $ . .  // 10 20

10 20 % . . .  // 10 20 10

10 20 30 /D .  // 3

42 .  // 42

#FF ,  // 00FF

#FFFF ,  // FFFF

`Hello World`  // Hello World

65 /C  // A

32 /C  // (space)

10 /C /N  // (newline newline)

100 x !  // (stores 100 in x)

x .  // 100

x 10 + .  // 110

10 a ! 20 b ! a b + .  // 30

:A 10 20 + . ;  // (defines function A)

A  // 30

:B " * . ;  // (defines function B)

5 B  // 25

[ 1 2 3 4 5 ] a !  // (creates array in a)

a 0 ? .  // 1

a 4 ? .  // 5

a /S .  // 5

10 a 2 ?!  // (stores 10 at index 2)

a 2 ? .  // 10

5 ( /i . 32 /C ) /N  // 0 1 2 3 4

10 ( /i . 32 /C ) /N  // 0 1 2 3 4 5 6 7 8 9

/F ( `no` ) /E ( `yes` )  // yes

/T ( `yes` ) /E ( `no` )  // yes

5 5 = ( `equal` ) /E ( `not equal` )  // equal

3 5 = ( `equal` ) /E ( `not equal` )  // not equal

10 x ! x 5 > ( `big` ) /E ( `small` )  // big

3 ( 3 ( /j . 32 /C /i . 32 /C ) /N )  // 0 0 0 1 0 2 (newline) 1 0 1 1 1 2 (newline) 2 0 2 1 2 2

/U ( /i . 32 /C /i 5 = /W ) /N  // 0 1 2 3 4 5

100 200 + /c .  // 0

20 3 / .  // 6

20 3 / /r .  // 2

[ 10 20 30 ] b !  // (creates array in b)

b /S .  // 3

b 0 ? .  // 10

b 1 ? .  // 20

b 2 ? .  // 30

:C 1 2 + 3 4 + * . ;  // (defines function C)

C  // 21

10 x ! 20 y ! x y + z ! z .  // 30

#FFFF 1 + ,  // 10000

3 2 > /T = .  // -1

[ 5 3 8 4 2 ] c !  // (creates array)

c 0 ? c 1 ? > ( `yes` ) /E ( `no` )  // yes

c 1 ? c 0 ? > ( `yes` ) /E ( `no` )  // no

:D n ! n 0 > ( n . ) /E ( `negative` ) ;  // (defines function D)

5 D  // 5

-5 D  // negative

0 D  // negative

:E 0 a ! 1 b ! 10 ( a . 32 /C a b + c ! b a ! c b ! ) ;  // (defines Fibonacci function E)

E  // 0 1 1 2 3 5 8 13 21 34

:F 0 s ! 5 ( s /i + s ! ) s . ;  // (defines function F - sum 0 to 4)

F  // 10

:G a ! b ! a b + . ;  // (defines function G - add two numbers)

10 20 G  // 30

15 25 G  // 40

[ 1 2 3 ] [ 4 5 6 ] x ! y !  // (creates two arrays)

x 0 ? y 0 ? + .  // 5

:H 3 ( /i . ) ;  // (defines function H)

H  // 0 1 2

10 ( /i 2 = ( `TWO` ) ) /N  // TWO

5 ( /i " . ) /N  // 0 1 2 3 4

list  // (shows all defined functions)


////////////////////////////////////

// ===================================================================================================
// MINT BIT SHIFT OPERATORS TEST SUITE
// Tests for { (shift left) and } (shift right)
// ===================================================================================================

// Test 1: Basic Shift Left (multiply by 2)
:A
`Test 1: Basic Shift Left (multiply by 2)` /N
1 . ` << 1 = ` 1 { . /N
2 . ` << 1 = ` 2 { . /N
4 . ` << 1 = ` 4 { . /N
8 . ` << 1 = ` 8 { . /N
/N
;

// Test 2: Basic Shift Right (divide by 2)
:B
`Test 2: Basic Shift Right (divide by 2)` /N
16 . ` >> 1 = ` 16 } . /N
8 . ` >> 1 = ` 8 } . /N
4 . ` >> 1 = ` 4 } . /N
2 . ` >> 1 = ` 2 } . /N
1 . ` >> 1 = ` 1 } . /N
/N
;

// Test 3: Multiple Shifts Left (powers of 2)
:C
`Test 3: Multiple Shifts Left (multiply by 2^n)` /N
1 . ` << 3 times = ` 1 {{{ . ` (1 * 2^3 = 8)` /N
1 . ` << 4 times = ` 1 {{{{ . ` (1 * 2^4 = 16)` /N
1 . ` << 5 times = ` 1 {{{{{ . ` (1 * 2^5 = 32)` /N
/N
;

// Test 4: Multiple Shifts Right (divide by 2^n)
:D
`Test 4: Multiple Shifts Right (divide by 2^n)` /N
64 . ` >> 3 times = ` 64 }}} . ` (64 / 2^3 = 8)` /N
128 . ` >> 4 times = ` 128 }}}} . ` (128 / 2^4 = 8)` /N
256 . ` >> 5 times = ` 256 }}}}} . ` (256 / 2^5 = 8)` /N
/N
;

// Test 5: Hexadecimal Shift Operations
:E
`Test 5: Hexadecimal Bit Shifts` /N
`#0001 << 1 = ` #0001 { , /N
`#000F << 1 = ` #000F { , /N
`#00FF << 1 = ` #00FF { , /N
`#0100 >> 1 = ` #0100 } , /N
`#0010 >> 1 = ` #0010 } , /N
/N
;

// Test 6: Shift and OR pattern (setting bits)
:F
`Test 6: Building bit patterns with shifts` /N
`Build 0x09 (binary 1001):` /N
1 {{{ . ` (shift 1 left 3 times = 8)` /N
1 { . ` (shift 1 left once = 2)` /N
1 {{{ 1 | . ` (OR with 1 = 9)` /N
`In hex: ` 1 {{{ 1 | , /N
/N
;

// Test 7: Shift and XOR pattern
:G
`Test 7: Shift with XOR operations` /N
`Start with 4, shift left twice, XOR with 0x0F, mask with 0x0F:` /N
1 {{ . ` (1 << 2 = 4)` /N
1 {{ #F ^ . ` (4 XOR 0x0F = 11)` /N
1 {{ #F ^ #F & . ` (result AND 0x0F = 11)` /N
`In hex: ` 1 {{ #F ^ #F & , /N
/N
;

// Test 8: Fast Multiplication by 8 (shift left 3 times)
:H
`Test 8: Fast Multiplication by 8 using shifts` /N
5 n!
`Traditional: ` n 8 * . /N
`Bit shift:   ` n {{{ . /N
10 n!
`Traditional: ` n 8 * . /N
`Bit shift:   ` n {{{ . /N
/N
;

// Test 9: Fast Division by 4 (shift right 2 times)
:I
`Test 9: Fast Division by 4 using shifts` /N
100 n!
`Traditional: ` n 4 / . /N
`Bit shift:   ` n }} . /N
64 n!
`Traditional: ` n 4 / . /N
`Bit shift:   ` n }} . /N
/N
;

// Test 10: Checking specific bit positions
:J
`Test 10: Check if bit is set using shifts` /N
11 n!  
// Binary: 1011
`Number: ` n . ` (binary: 1011)` /N
`Bit 0 (LSB): ` n 1 & . /N
`Bit 1: ` n } 1 & . /N
`Bit 2: ` n }} 1 & . /N
`Bit 3: ` n }}} 1 & . /N
/N
;

// Test 11: Building powers of 2 using only shifts
:K
`Test 11: Powers of 2 using shifts only` /N
`2^0 = ` 1 . /N
`2^1 = ` 1 { . /N
`2^2 = ` 1 {{ . /N
`2^3 = ` 1 {{{ . /N
`2^4 = ` 1 {{{{ . /N
`2^5 = ` 1 {{{{{ . /N
`2^6 = ` 1 {{{{{{ . /N
`2^7 = ` 1 {{{{{{{ . /N
`2^8 = ` 1 {{{{{{{{ . /N
/N
;

// Test 12: Shift loop - visualize shifting
:L
`Test 12: Loop demonstration of shifts` /N
1 n!
`Shift left 8 times:` /N
8 (
  n . 32 /C
  n { n!
)
/N
256 n!
`Shift right 8 times:` /N
8 (
  n . 32 /C
  n } n!
)
/N
;

// Test 13: Practical example - RGB color manipulation
:M
`Test 13: RGB color bit manipulation` /N
`Red = 0xFF, Green = 0x80, Blue = 0x40` /N
#FF r! #80 g! #40 b!
`Compose RGB (24-bit): R << 16 | G << 8 | B` /N
r {{{{{{{{{{{{{{{{ . ` (red shifted)` /N
g {{{{{{{{ . ` (green shifted)` /N
`Combined in hex: ` r {{{{{{{{{{{{{{{{ g {{{{{{{{ | b | , /N
/N
;

// Test 14: Edge cases
:N
`Test 14: Edge Cases` /N
`Shift 0: ` 0 { . /N
`Shift right 0: ` 0 } . /N
`Shift 1 then back: ` 42 { } . /N
`Shift back then forward: ` 42 } { . /N
/N
;

// Master test runner
:T
`====================================` /N
`MINT BIT SHIFT TEST SUITE` /N
`====================================` /N
/N
A B C D E F G H I J K L M N
`====================================` /N
`ALL TESTS COMPLETE` /N
`====================================` /N
;

// Run all tests
T


/////////////////////////////////////////////////////////////

// ========================================================================
// COMPREHENSIVE LOGICAL OPERATORS TEST SUITE FOR MINT
// Tests: >, <, =, &, |, ^, ~, {, }
// ========================================================================

// TEST 1: BASIC COMPARISON OPERATORS (>)
// ========================================================================
:A `TEST 1: Greater Than (>) Operator` /N ;

:B `  5 > 3 = ` 5 3 > . `  (expect -1)` /N ;
:C `  3 > 5 = ` 3 5 > . `  (expect 0)` /N ;
:D `  5 > 5 = ` 5 5 > . `  (expect 0)` /N ;
:E `  -5 > -10 = ` -5 -10 > . `  (expect -1)` /N ;
:F `  0 > -1 = ` 0 -1 > . `  (expect -1)` /N ;
:G `  #FF > #FE = ` #FF #FE > . `  (expect -1)` /N ;

// Run Test 1
A B C D E F G


// TEST 2: BASIC COMPARISON OPERATORS (<)
// ========================================================================
:H `TEST 2: Less Than (<) Operator` /N ;

:I `  3 < 5 = ` 3 5 < . `  (expect -1)` /N ;
:J `  5 < 3 = ` 5 3 < . `  (expect 0)` /N ;
:K `  5 < 5 = ` 5 5 < . `  (expect 0)` /N ;
:L `  -10 < -5 = ` -10 -5 < . `  (expect -1)` /N ;
:M `  -1 < 0 = ` -1 0 < . `  (expect -1)` /N ;
:N `  #FE < #FF = ` #FE #FF < . `  (expect -1)` /N ;

// Run Test 2
H I J K L M N


// TEST 3: BASIC COMPARISON OPERATORS (=)
// ========================================================================
:O `TEST 3: Equal (=) Operator` /N ;

:P `  5 = 5: ` 5 5 = . `  (expect -1)` /N ;
:Q `  3 = 5: ` 3 5 = . `  (expect 0)` /N ;
:R `  0 = 0: ` 0 0 = . `  (expect -1)` /N ;
:S `  -5 = -5: ` -5 -5 = . `  (expect -1)` /N ;
:T `  #FF = 255: ` #FF 255 = . `  (expect -1)` /N ;
:U `  #10 = 16: ` #10 16 = . `  (expect -1)` /N ;

// Run Test 3
O P Q R S T U


// TEST 4: BITWISE AND (&)
// ========================================================================
:V `TEST 4: Bitwise AND (&) Operator` /N ;

:W `  #FF & #0F = ` #FF #0F & , /N ;       // expect 000F
:X `  #F0 & #0F = ` #F0 #0F & , /N ;       // expect 0000
:Y `  #AA & #55 = ` #AA #55 & , /N ;       // expect 0000
:Z `  #FF & #FF = ` #FF #FF & , /N ;       // expect 00FF

// Run Test 4
V W X Y Z


// TEST 5: BITWISE OR (|)
// ========================================================================
:A `TEST 5: Bitwise OR (|) Operator` /N ;

:B `  #F0 | #0F = ` #F0 #0F | , /N ;       // expect 00FF
:C `  #AA | #55 = ` #AA #55 | , /N ;       // expect 00FF
:D `  #00 | #FF = ` #00 #FF | , /N ;       // expect 00FF
:E `  #10 | #01 = ` #10 #01 | , /N ;       // expect 0011
:F `  0 | 0 = ` 0 0 | , /N ;               // expect 0000

// Run Test 5
A B C D E F


// TEST 6: BITWISE XOR (^)
// ========================================================================
:G `TEST 6: Bitwise XOR (^) Operator` /N ;

:H `  #FF ^ #FF = ` #FF #FF ^ , /N ;       // expect 0000
:I `  #AA ^ #55 = ` #AA #55 ^ , /N ;       // expect 00FF
:J `  #F0 ^ #0F = ` #F0 #0F ^ , /N ;       // expect 00FF
:K `  #10 ^ #11 = ` #10 #11 ^ , /N ;       // expect 0001
:L `  0 ^ #FF = ` 0 #FF ^ , /N ;           // expect 00FF

// Run Test 6
G H I J K L


// TEST 7: BITWISE NOT (~)
// ========================================================================
:M `TEST 7: Bitwise NOT (~) Operator` /N ;

:N `  ~0 = ` 0 ~ , /N ;                    // all bits flipped
:O `  ~#FF = ` #FF ~ , /N ;                // expect FF00
:P `  ~#FFFF = ` #FFFF ~ , /N ;            // expect 0000
:Q `  ~#0001 = ` #0001 ~ , /N ;            // expect FFFE

// Run Test 7
M N O P Q


// TEST 8: SHIFT LEFT ({)
// ========================================================================
:R `TEST 8: Shift Left ({) Operator` /N ;

:S `  1 << 1 = ` 1 { , /N ;                // expect 0002
:T `  1 << 2 = ` 1 {{ , /N ;               // expect 0004
:U `  1 << 3 = ` 1 {{{ , /N ;              // expect 0008
:V `  #FF << 1 = ` #FF { , /N ;            // expect 01FE
:W `  #80 << 1 = ` #80 { , /N ;            // expect 0100

// Run Test 8
R S T U V W


// TEST 9: SHIFT RIGHT (})
// ========================================================================
:X `TEST 9: Shift Right (}) Operator` /N ;

:Y `  #FF >> 1 = ` #FF } , /N ;            // expect 007F
:Z `  8 >> 1 = ` 8 } , /N ;                // expect 0004
:A `  4 >> 1 = ` 4 } , /N ;                // expect 0002
:B `  #100 >> 1 = ` #100 } , /N ;          // expect 0080
:C `  1 >> 1 = ` 1 } , /N ;                // expect 0000

// Run Test 9
X Y Z A B C


// TEST 10: COMPLEX COMPARISON CHAINS
// ========================================================================
:D `TEST 10: Complex Comparison Chains` /N ;

// Test: (5 > 3) AND (10 < 20)
:E 5 3 > 10 20 < & `  (5>3) AND (10<20) = ` . /N ;  // expect -1

// Test: (5 > 10) OR (3 < 7)
:F 5 10 > 3 7 < | `  (5>10) OR (3<7) = ` . /N ;     // expect -1

// Test: (5 = 5) AND (10 = 10)
:G 5 5 = 10 10 = & `  (5=5) AND (10=10) = ` . /N ;  // expect -1

// Test: (5 > 3) XOR (10 > 8)
:H 5 3 > 10 8 > ^ `  (5>3) XOR (10>8) = ` . /N ;    // expect 0 (both true)

// Run Test 10
D E F G H


// TEST 11: BIT MANIPULATION PATTERNS
// ========================================================================
:I `TEST 11: Bit Manipulation Patterns` /N ;

// Test: Set bit 3 (create mask and OR)
:J 1 {{{ #00 | `  Set bit 3: ` , /N ;              // expect 0008

// Test: Clear bit 3 (create mask, NOT, and AND)
:K 1 {{{ ~ #FF & `  Clear bit 3 from 0xFF: ` , /N ; // expect 00F7

// Test: Toggle bit 3 (XOR)
:L #FF 1 {{{ ^ `  Toggle bit 3 in 0xFF: ` , /N ;   // expect 00F7

// Test: Check if bit 3 is set
:M #08 1 {{{ & 0 > `  Is bit 3 set in 0x08? ` . /N ; // expect -1

// Run Test 11
I J K L M


// TEST 12: CONDITIONAL EXECUTION WITH COMPARISONS
// ========================================================================
:N `TEST 12: Conditional Execution` /N ;

// Test: If-then-else with >
:O 10 5 > ( `  10 > 5: TRUE branch` /N ) /E ( `  FALSE branch` /N ) ;

// Test: If-then-else with 
:P 3 8 < ( `  3 < 8: TRUE branch` /N ) /E ( `  FALSE branch` /N ) ;

// Test: If-then-else with =
:Q 5 5 = ( `  5 = 5: TRUE branch` /N ) /E ( `  FALSE branch` /N ) ;

// Test: Nested conditionals
:R 10 5 > ( 
  `  Outer TRUE` /N 
  3 8 < ( `    Inner TRUE` /N ) /E ( `    Inner FALSE` /N )
) /E ( 
  `  Outer FALSE` /N 
) ;

// Run Test 12
N O P Q R


// TEST 13: LOOP CONTROL WITH COMPARISONS
// ========================================================================
:S `TEST 13: Loop Control with Comparisons` /N ;

// Test: Count from 0 to 4, break when i = 3
:T 0 c ! /U ( 
  c . 32 /C 
  c 1 + c ! 
  c 3 > /W 
) /N ;

// Test: Sum numbers where i < 5
:U 0 s ! 10 ( 
  /i 5 < ( 
    s /i + s ! 
  ) 
) `  Sum of i<5: ` s . /N ;

// Run Test 13
S T U


// TEST 14: BITWISE OPERATIONS IN CALCULATIONS
// ========================================================================
:V `TEST 14: Practical Bitwise Calculations` /N ;

// Test: Multiply by 8 using shift
:W 5 {{{ `  5 * 8 via shift: ` . /N ;              // expect 40

// Test: Divide by 4 using shift
:X 32 }} `  32 / 4 via shift: ` . /N ;              // expect 8

// Test: Check if number is even (bit 0 = 0)
:Y 10 1 & 0 = `  Is 10 even? ` . /N ;              // expect -1
:Z 11 1 & 0 = `  Is 11 even? ` . /N ;              // expect 0

// Run Test 14
V W X Y Z


// TEST 15: EDGE CASES AND BOUNDARY CONDITIONS
// ========================================================================
:A `TEST 15: Edge Cases` /N ;

// Test: Comparison with 0
:B 0 0 > `  0 > 0: ` . /N ;                         // expect 0
:C 0 0 < `  0 < 0: ` . /N ;                         // expect 0
:D 0 0 = `  0 = 0: ` . /N ;                         // expect -1

// Test: Maximum values
:E #FFFF #FFFF = `  MAX = MAX: ` . /N ;             // expect -1
:F #FFFF #FFFE > `  MAX > MAX-1: ` . /N ;           // expect -1

// Test: AND with zero
:G #FF 0 & `  0xFF AND 0: ` , /N ;                  // expect 0000

// Test: OR with zero (identity)
:H #FF 0 | `  0xFF OR 0: ` , /N ;                   // expect 00FF

// Test: XOR with self (always 0)
:I #AA #AA ^ `  0xAA XOR 0xAA: ` , /N ;             // expect 0000

// Run Test 15
A B C D E F G H I


// TEST 16: COMBINING ALL LOGICAL OPERATORS
// ========================================================================
:J `TEST 16: Complex Combined Operations` /N ;

// Test: ((A > B) AND (C < D)) OR (E = F)
:K 
  5 3 >     // A > B (-1)
  2 7 <     // C < D (-1)
  &         // AND (-1)
  10 11 =   // E = F (0)
  |         // OR (-1)
  `  ((5>3) AND (2<7)) OR (10=11): ` . /N
;

// Test: Bit manipulation chain
:L 
  #F0       // Start with F0
  #0F |     // OR with 0F -> FF
  1 {       // Shift left -> 1FE
  #01 &     // AND with 01 -> 00
  `  Complex bit chain result: ` , /N
;

// Test: Comparison result used in calculation
:M 
  5 3 >     // Returns -1 (true)
  10 *      // -1 * 10 = -10
  -1 *      // Make positive = 10
  `  Using comparison in math: ` . /N
;

// Run Test 16
J K L M


// TEST 17: REAL-WORLD SCENARIOS
// ========================================================================
:N `TEST 17: Real-World Scenarios` /N ;

// Scenario 1: Check if number is in range [10, 20]
:O 
  15 n !
  n 10 > n 20 < & 
  ( `  15 is in range [10,20]` /N ) 
  /E ( `  15 is NOT in range` /N )
;

// Scenario 2: Extract nibble from byte
:P 
  #A5 h !
  h #0F & `  Low nibble of 0xA5: ` , /N    // expect 0005
  h }}}} `  High nibble of 0xA5: ` , /N    // expect 000A
;

// Scenario 3: Set/clear/toggle status flags
:Q 
  #00 f !                        // Start with no flags
  f 1 { | f !                    // Set bit 1
  `  After set bit 1: ` f , /N
  f 1 {{ | f !                   // Set bit 2
  `  After set bit 2: ` f , /N
  f 1 { ^ f !                    // Toggle bit 1
  `  After toggle bit 1: ` f , /N
;

// Run Test 17
N O P Q


// TEST 18: PERFORMANCE AND STRESS TESTS
// ========================================================================
:R `TEST 18: Performance Tests` /N ;

// Test: 100 comparisons
:S 
  0 c ! 
  100 ( 
    /i 50 < ( c 1 + c ! ) 
  ) 
  `  Count of i<50 in 100 iterations: ` c . /N
;

// Test: Bitwise operations in loop
:T 
  1 r ! 
  10 ( 
    r { r ! 
  ) 
  `  1 shifted left 10 times: ` r . /N    // expect 1024
;

// Run Test 18
R S T


// MASTER TEST RUNNER
// ========================================================================
:M 
  `========================================` /N
  `MINT LOGICAL OPERATORS TEST SUITE` /N
  `========================================` /N /N
  `Run individual tests A-T or all tests` /N
  `Example: A (for test 1), M (for all)` /N
  `========================================` /N
;

M

////////////////////////////////////////
