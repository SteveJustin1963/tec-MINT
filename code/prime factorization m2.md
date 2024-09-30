does not work yet
work in progress

prime factorization method for integers between 0 and hex FFFF

```
:R
  0 n !
  /U (
    /K c !
    c 13 = c 10 = | (
      n
    ) /E (
      c 48 - d !
      d 0 >= d 9 <= & (
        n 10 * d + n !
      ) /E (
        `Invalid input, ignoring` /N
      )
    )
  )
;

:F
  n !
  n 2 < (
    `Not applicable for numbers less than 2`
  ) /E (
    n " .
    ` = `
    2 f !
    /U (
      n 1 > /W
      n f % 0 = (
        f .
        n f / n !
        n 1 > (
          ` * `
        )
      ) /E (
        f 1 + f !
      )
    )
  )
  /N
;

:T
  /U (
    `Enter a number (0 to quit): `
    R n !
    `Number entered: ` n . /N
    n 0 = (
      `Exiting` /N
    ) /E (
      n F
    )
  )
;

```
