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
11 n!  // Binary: 1011
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
g {{{{{{{{{ . ` (green shifted)` /N
`Combined in hex: ` r {{{{{{{{{{{{{{{{ g {{{{{{{{{ | b | , /N
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

