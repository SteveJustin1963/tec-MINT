// Weather Balloon Height Calculator - Version 2
// Improved with better tangent approximations
// Uses scaled integer math (x10000 for precision)

// Tangent table: tan(angle) * 10000 for angles 10-80 degrees
// Format: angle -> tan(angle) * 10000

:T
a !
a 10 = ( 1763 ) /E (
a 15 = ( 2679 ) /E (
a 20 = ( 3640 ) /E (
a 25 = ( 4663 ) /E (
a 30 = ( 5774 ) /E (
a 35 = ( 7002 ) /E (
a 40 = ( 8391 ) /E (
a 45 = ( 10000 ) /E (
a 50 = ( 11918 ) /E (
a 55 = ( 14281 ) /E (
a 60 = ( 17321 ) /E (
a 65 = ( 21445 ) /E (
a 70 = ( 27475 ) /E (
a 75 = ( 37321 ) /E (
a 80 = ( 56713 ) /E (
  `Angle ` a . ` not supported` /N
  1
)
)
)
)
)
)
)
)
)
)
)
)
)
)
)
;

// Function H: Calculate height from distance and two angles
// Stack: distance angle1 angle2
// Formula: h = d / (1/tan(a1) + 1/tan(a2))
:H
b ! a ! d !

`Balloon Height Problem` /N
`--------------------` /N
`Distance: ` d . ` km` /N
`Angle A: ` a . ` deg` /N
`Angle B: ` b . ` deg` /N
/N

// Get tan(a1) and tan(b1)
a T t1 !
b T t2 !

// Calculate 1/tan(a1) = 10000/tan(a1)
10000 10000 * t1 / c1 !

// Calculate 1/tan(b2) = 10000/tan(b2)
10000 10000 * t2 / c2 !

// Sum cotangents
c1 c2 + s !

`Cot(` a . `) = ` c1 . /N
`Cot(` b . `) = ` c2 . /N
`Sum = ` s . /N
/N

// Calculate h = d * 10000 / sum
d 10000 * s / h !

`Height = ` h . ` km` /N
`Height = ` h 1000 * . ` m` /N
;

// Main example: 2km, 40° and 70°
:M
`Example from problem:` /N
2 40 70 H
;

// Custom input version
:P
d ! a ! b !
d a b H
;
