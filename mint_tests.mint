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



// ========================================================================
// EDGE CASE TESTS FOR BITWISE OPERATIONS (16-bit System)
// Tests: ~, &, |, ^, {, } with boundary conditions
// ========================================================================

// TEST 1: BITWISE NOT (~) - Edge Cases
// ========================================================================
:A `=== TEST 1: BITWISE NOT EDGE CASES ===` /N ;

:B `Zero:           ~0x0000 = ` 0 ~ , `  (expect FFFF)` /N ;
:C `All ones:       ~0xFFFF = ` #FFFF ~ , `  (expect 0000)` /N ;
:D `Low byte:       ~0x00FF = ` #00FF ~ , `  (expect FF00)` /N ;
:E `High byte:      ~0xFF00 = ` #FF00 ~ , `  (expect 00FF)` /N ;
:F `Single bit 0:   ~0x0001 = ` #0001 ~ , `  (expect FFFE)` /N ;
:G `Single bit 15:  ~0x8000 = ` #8000 ~ , `  (expect 7FFF)` /N ;
:H `Alternating:    ~0xAAAA = ` #AAAA ~ , `  (expect 5555)` /N ;
:I `Alternating:    ~0x5555 = ` #5555 ~ , `  (expect AAAA)` /N ;
:J `Mid value:      ~0x7FFF = ` #7FFF ~ , `  (expect 8000)` /N ;

// Run Test 1
:T A B C D E F G H I J ;
`Run with: T` /N /N


// TEST 2: BITWISE AND (&) - Edge Cases
// ========================================================================
:K `=== TEST 2: BITWISE AND EDGE CASES ===` /N ;

:L `AND with 0:     0xFFFF & 0x0000 = ` #FFFF 0 & , `  (expect 0000)` /N ;
:M `AND with self:  0xAAAA & 0xAAAA = ` #AAAA #AAAA & , `  (expect AAAA)` /N ;
:N `AND complement: 0xAAAA & 0x5555 = ` #AAAA #5555 & , `  (expect 0000)` /N ;
:O `Mask low byte:  0x1234 & 0x00FF = ` #1234 #00FF & , `  (expect 0034)` /N ;
:P `Mask high byte: 0x1234 & 0xFF00 = ` #1234 #FF00 & , `  (expect 1200)` /N ;
:Q `Check bit 15:   0x8000 & 0x8000 = ` #8000 #8000 & , `  (expect 8000)` /N ;
:R `Check bit 0:    0x0001 & 0x0001 = ` #0001 #0001 & , `  (expect 0001)` /N ;
:S `Max values:     0xFFFF & 0xFFFF = ` #FFFF #FFFF & , `  (expect FFFF)` /N ;

// Run Test 2
:U K L M N O P Q R S ;
`Run with: U` /N /N


// TEST 3: BITWISE OR (|) - Edge Cases
// ========================================================================
:V `=== TEST 3: BITWISE OR EDGE CASES ===` /N ;

:W `OR with 0:      0x0000 | 0x0000 = ` 0 0 | , `  (expect 0000)` /N ;
:X `OR with self:   0xAAAA | 0xAAAA = ` #AAAA #AAAA | , `  (expect AAAA)` /N ;
:Y `OR complement:  0xAAAA | 0x5555 = ` #AAAA #5555 | , `  (expect FFFF)` /N ;
:Z `Combine bytes:  0xFF00 | 0x00FF = ` #FF00 #00FF | , `  (expect FFFF)` /N ;
:A `Combine nibbles: 0xF0F0 | 0x0F0F = ` #F0F0 #0F0F | , `  (expect FFFF)` /N ;
:B `Set bit 15:     0x0000 | 0x8000 = ` 0 #8000 | , `  (expect 8000)` /N ;
:C `Set bit 0:      0x0000 | 0x0001 = ` 0 #0001 | , `  (expect 0001)` /N ;
:D `Max OR:         0xFFFF | 0xFFFF = ` #FFFF #FFFF | , `  (expect FFFF)` /N ;

// Run Test 3
:E V W X Y Z A B C D ;
`Run with: E` /N /N


// TEST 4: BITWISE XOR (^) - Edge Cases
// ========================================================================
:F `=== TEST 4: BITWISE XOR EDGE CASES ===` /N ;

:G `XOR with 0:     0xAAAA ^ 0x0000 = ` #AAAA 0 ^ , `  (expect AAAA)` /N ;
:H `XOR with self:  0xAAAA ^ 0xAAAA = ` #AAAA #AAAA ^ , `  (expect 0000)` /N ;
:I `XOR complement: 0xAAAA ^ 0x5555 = ` #AAAA #5555 ^ , `  (expect FFFF)` /N ;
:J `XOR all ones:   0x1234 ^ 0xFFFF = ` #1234 #FFFF ^ , `  (expect EDCB)` /N ;
:K `Toggle bit 15:  0x0000 ^ 0x8000 = ` 0 #8000 ^ , `  (expect 8000)` /N ;
:L `Toggle bit 0:   0xFFFF ^ 0x0001 = ` #FFFF #0001 ^ , `  (expect FFFE)` /N ;
:M `Swap pattern:   0xF0F0 ^ 0xFFFF = ` #F0F0 #FFFF ^ , `  (expect 0F0F)` /N ;

// Run Test 4
:N F G H I J K L M ;
`Run with: N` /N /N


// TEST 5: SHIFT LEFT ({) - Overflow Edge Cases
// ========================================================================
:O `=== TEST 5: SHIFT LEFT EDGE CASES ===` /N ;

:P `Shift 1x1:      1 << 1 = ` 1 { , `  (expect 0002)` /N ;
:Q `Shift 1x8:      1 << 8 = ` 1 {{{{{{{{ , `  (expect 0100)` /N ;
:R `Shift 1x15:     1 << 15 = ` 1 {{{{{{{{{{{{{{{ , `  (expect 8000)` /N ;
:S `Shift 1x16:     1 << 16 = ` 1 {{{{{{{{{{{{{{{{ , `  (expect 0000 - overflow!)` /N ;
:T `Shift max:      0xFFFF << 1 = ` #FFFF { , `  (expect FFFE)` /N ;
:U `Shift 0x8000:   0x8000 << 1 = ` #8000 { , `  (expect 0000 - bit lost!)` /N ;
:V `Shift 0x7FFF:   0x7FFF << 1 = ` #7FFF { , `  (expect FFFE)` /N ;
:W `Shift pattern:  0xAAAA << 1 = ` #AAAA { , `  (expect 5554)` /N ;

// Run Test 5
:X O P Q R S T U V W ;
`Run with: X` /N /N


// TEST 6: SHIFT RIGHT (}) - Edge Cases
// ========================================================================
:Y `=== TEST 6: SHIFT RIGHT EDGE CASES ===` /N ;

:Z `Shift 0xFF:     0xFF >> 1 = ` #FF } , `  (expect 007F)` /N ;
:A `Shift max:      0xFFFF >> 1 = ` #FFFF } , `  (expect 7FFF)` /N ;
:B `Shift 0x8000:   0x8000 >> 1 = ` #8000 } , `  (expect 4000)` /N ;
:C `Shift 1:        1 >> 1 = ` 1 } , `  (expect 0000)` /N ;
:D `Shift 0:        0 >> 1 = ` 0 } , `  (expect 0000)` /N ;
:E `Shift pattern:  0x5555 >> 1 = ` #5555 } , `  (expect 2AAA)` /N ;
:F `Divide by 8:    256 >> 3 = ` 256 }}} , `  (expect 0020)` /N ;

// Run Test 6
:G Y Z A B C D E F ;
`Run with: G` /N /N


```
Great debugging! I can see **two critical issues** from the trace:

## Issue 1: Stack Pollution Between Tests
Look at the final state: `[DEBUG] STACK: [256]` - Test M left 256 on the stack, which pollutes Test N!

## Issue 2: Rotate Logic is Still Wrong
The stack trace shows:
```
[DEBUG] BEFORE }: stack=[256 128 32767]
```

The problem is that we're pushing THREE values when we only need TWO for the rotation.

## Fixed Test 7:

```mint
// TEST 7: COMBINED OPERATIONS - Complex Patterns
// ========================================================================
:H `=== TEST 7: COMBINED OPERATIONS ===` /N ;

// Double NOT (should return original)
:I `~~0xAA:         ~~0xAA = ` #AA ~ ~ , `  (expect 00AA)` /N ;

// Shift and mask
:J `(1<<8) & 0xFF:  ` 1 {{{{{{{{ #FF & , `  (expect 0000)` /N ;
:K `(1<<8) & 0xFF00: ` 1 {{{{{{{{ #FF00 & , `  (expect 0100)` /N ;

// XOR twice (cancel out)
:L `A^B^B:          0x12^0x34^0x34 = ` #12 #34 ^ #34 ^ , `  (expect 0012)` /N ;

// Rotate left by 1 bit: (x<<1) | (x>>15)
// For 0x8000: shift left wraps to 0, shift right 15 gives bit that wraps
:M `Rotate 0x8000:  (0x8000<<1)|(0x8000>>15) ` 
   #8000 " { $ }}}}}}}}}}}}}}} | , 
   `  (expect 0001)` /N ;

// Alternative: rotate bit 7 to bit 0 is impossible - bit gets lost
// Instead test a clear rotation pattern
:N `Rotate 0xC000:  (0xC000<<1)|(0xC000>>15) ` 
   #C000 " { $ }}}}}}}}}}}}}}} | , 
   `  (expect 8001)` /N ;

// Create mask with NOT and shifts  
:O `Mask via NOT:   ~(~0<<8) = ` 
   0 ~ {{{{{{{{ ~ , 
   `  (expect 00FF)` /N ;

// Complex: Set bits 0-3, clear bit 2
:P `Set 0-3, clear 2: ` 
   #0F 4 ~ & , 
   `  (expect 000B)` /N ;

// Run Test 7
:Q H I J K L M N O P ;
`Run with: Q` /N /N
```

## Explanation of Fixes:

### Fix 1: Proper Rotate with Duplicate (`"`)
```mint
#8000 " { $ }}}}}}}}}}}}}}} | ,
```
- `#8000` → push 0x8000: `[0x8000]`
- `"` → duplicate: `[0x8000, 0x8000]`
- `{` → shift left top: `[0x8000, 0x0000]` (bit 15 wraps off)
- `$` → swap: `[0x0000, 0x8000]`
- `}}}...` (15 times) → shift right: `[0x0000, 0x0001]` (bit 15 → bit 0)
- `|` → OR: `[0x0001]` ✓

### Fix 2: Better Rotate Example
For `0xC000` (bits 15 and 14 set):
- `0xC000 << 1` = `0x8000` (bit 15 wraps off, bit 14 → bit 15)
- `0xC000 >> 15` = `0x0001` (bit 15 → bit 0)
- `0x8000 | 0x0001` = `0x8001` ✓

## Alternative: Add Stack Cleanup

If you want to keep the original test but fix stack pollution:

```mint
:M `Rotate test:  ` 
   #8000 " { $ }}}}}}}}}}}}}}} | 
   " , `  Result: ` .    // Duplicate, print hex, print decimal
   ' ;                   // Drop the duplicate - clean stack!
```

Or add a helper to clear stack between tests:

```mint
// Clear stack helper
:Z /D ( ' ) ;  // Drop all items: get depth, loop that many times dropping

// Use it:
:Q H Z I Z J Z K Z L Z M Z N Z O Z P ;
```

The key insight: **MINT's stack persists between function calls**, so you must either:
1. Consume all values you push
2. Explicitly clean up with `'` (drop)
3. Clear the stack between tests
```


















// TEST 8: BIT TESTING PATTERNS
// ========================================================================
:P `=== TEST 8: BIT TESTING PATTERNS ===` /N ;

// Test if bit 7 is set in 0xFF
:Q `Bit 7 in 0xFF:  ` #FF 1 {{{{{{{ & 0 > . `  (expect -1)` /N ;

// Test if bit 0 is set in 0xFE  
:R `Bit 0 in 0xFE:  ` #FE 1 & 0 = . `  (expect -1, bit is clear)` /N ;

// Count set bits in 0x0F (should be 4)
:S `Set bits test:  0x0F has bits: ` 
   #0F 1 & 0 > 
   #0F 2 & 0 > + 
   #0F 4 & 0 > + 
   #0F 8 & 0 > + 
   . /N ;

// Check if number is power of 2
:T `Is 0x80 power of 2? ` #80 #80 1 - & 0 = . `  (expect -1)` /N ;
:U `Is 0x81 power of 2? ` #81 #81 1 - & 0 = . `  (expect 0)` /N ;

// Run Test 8
:V P Q R S T U ;
`Run with: V` /N /N


// TEST 9: HEX PRINTER WITH NEGATIVE NUMBERS
// ========================================================================
:W `=== TEST 9: HEX PRINTER EDGE CASES ===` /N ;

// Test negative numbers displayed as hex
:X `Negative -1:    ` 1 -1 * , `  (expect FFFF in 16-bit)` /N ;
:Y `Negative -256:  ` 256 -1 * , `  (expect FF00 in 16-bit)` /N ;
:Z `Negative -32768: ` 32768 -1 * , `  (expect 8000 in 16-bit)` /N ;

// Test large positive numbers
:A `Large 65535:    ` 65535 , `  (expect FFFF)` /N ;
:B `Large 65536:    ` 65536 , `  (expect 0000 - wraps!)` /N ;
:C `Large 65537:    ` 65537 , `  (expect 0001 - wraps!)` /N ;

// Run Test 9
:D W X Y Z A B C ;
`Run with: D` /N /N


// TEST 10: BOUNDARY ARITHMETIC WITH BITWISE
// ========================================================================
:E `=== TEST 10: BOUNDARY ARITHMETIC ===` /N ;

// Max value operations
:F `Max & Max:      ` #FFFF #FFFF & , `  (expect FFFF)` /N ;
:G `Max | 0:        ` #FFFF 0 | , `  (expect FFFF)` /N ;
:H `Max ^ Max:      ` #FFFF #FFFF ^ , `  (expect 0000)` /N ;
:I `~Max:           ` #FFFF ~ , `  (expect 0000)` /N ;

// Min value operations
:J `0 & anything:   ` 0 #AAAA & , `  (expect 0000)` /N ;
:K `0 | anything:   ` 0 #AAAA | , `  (expect AAAA)` /N ;
:L `0 ^ anything:   ` 0 #AAAA ^ , `  (expect AAAA)` /N ;
:M `~0:             ` 0 ~ , `  (expect FFFF)` /N ;

// Run Test 10
:N E F G H I J K L M ;
`Run with: N` /N /N


// TEST 11: REAL-WORLD BIT MANIPULATION
// ========================================================================
:O `=== TEST 11: REAL-WORLD PATTERNS ===` /N ;

// Extract high byte
:P `High byte of 0x1234: ` #1234 }}}}}}}} , `  (expect 0012)` /N ;

// Extract low byte
:Q `Low byte of 0x1234:  ` #1234 #FF & , `  (expect 0034)` /N ;

// Swap bytes
:R `Swap bytes 0x1234:   ` #1234 }}}}}}}} #1234 #FF & {{{{{{{{ | , `  (expect 3412)` /N ;

// Set multiple bits
:S `Set bits 0,1,2:      ` 0 1 | 2 | 4 | , `  (expect 0007)` /N ;

// Clear specific bit
:T `Clear bit 4 from 0xFF: ` #FF 16 ~ & , `  (expect 00EF)` /N ;

// Toggle bit
:U `Toggle bit 7 in 0x00:  ` 0 128 ^ , `  (expect 0080)` /N ;
:V `Toggle bit 7 in 0xFF:  ` #FF 128 ^ , `  (expect 007F)` /N ;

// Run Test 11
:W O P Q R S T U V ;
`Run with: W` /N /N


// MASTER TEST RUNNER
// ========================================================================
:X 
  `==========================================` /N
  `  BITWISE OPERATIONS EDGE CASE TESTS` /N
  `  16-bit System with Overflow Handling` /N
  `==========================================` /N /N
  `Available Tests:` /N
  `  T - Test 1: NOT edge cases` /N
  `  U - Test 2: AND edge cases` /N
  `  E - Test 3: OR edge cases` /N
  `  N - Test 4: XOR edge cases` /N
  `  X - Test 5: Shift Left overflow` /N
  `  G - Test 6: Shift Right edge cases` /N
  `  O - Test 7: Combined operations` /N
  `  V - Test 8: Bit testing patterns` /N
  `  D - Test 9: Hex printer edge cases` /N
  `  N - Test 10: Boundary arithmetic` /N
  `  W - Test 11: Real-world patterns` /N
  `==========================================` /N
;

X

///////////////////////////////////////////////////////////////////////////////////////





