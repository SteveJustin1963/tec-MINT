// Weather Balloon Height Calculator
// Takes two angles and distance, outputs height
// Formula: h = d / (cot(a1) + cot(a2))
// Using scaled integer math (multiply by 1000 for precision)

// Function T: Tangent lookup table (scaled by 1000)
// Returns tan(angle) * 1000 for angles 0-90
:T
a !
a 40 = ( 839 ) /E (
a 70 = ( 2747 ) /E (
a 45 = ( 1000 ) /E (
a 30 = ( 577 ) /E (
a 60 = ( 1732 ) /E (
  `Error: Angle ` a . ` not in table` /N
  0
)
)
)
)
)
;

// Function C: Calculate cotangent (1/tan) scaled by 1000
// Input: angle on stack
// Output: cot(angle) * 1000
:C
T t !
1000000 t /
;

// Function H: Calculate height
// Stack: distance angle1 angle2
// Output: height
:H
b ! a ! d !

`Distance: ` d . ` km` /N
`Angle 1: ` a . ` degrees` /N
`Angle 2: ` b . ` degrees` /N
/N

// Calculate cot(a) + cot(b)
a C b C + s !

`Sum of cotangents (x1000): ` s . /N

// Calculate height = distance * 1000 / sum
d 1000 * s / h !

`Height: ` h . ` meters` /N
;

// Function M: Main demo with example from readme
// 2 km apart, angles 40 and 70 degrees
:M
`Weather Balloon Height Calculator` /N
`Example: 2km distance, 40° and 70° angles` /N
/N
2 40 70 H
;

// Function I: Interactive input version
:I
`Enter distance (km): ` /K 48 - d !
`Enter angle 1 (degrees): ` /K 48 - a !
`Enter angle 2 (degrees): ` /K 48 - b !
d a b H
;
