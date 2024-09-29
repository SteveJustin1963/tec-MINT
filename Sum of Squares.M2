

:S
  b ! a !
  0 t !
  `Start: ` a . /N
  `End: ` b . /N
  a i !
  b a - 1 + c !
  `Iterations: ` c . /N
  c (
    `Number: ` i . /N
    i i * s !
    `Squared: ` s . /N
    t s + t !
    `Total: ` t . /N
    i 1 + i !
  )
  `Final total: ` t . /N
;

1 5 S
