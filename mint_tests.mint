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
