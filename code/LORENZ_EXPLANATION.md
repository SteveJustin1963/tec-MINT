# Why Your MINT Lorenz Attractor Settles Instead of Being Chaotic

## Your Observed Output Pattern
```
100  -72    <- Wild initial transient
83  221
96  96
...
7  9
7  -10
...
2  2       <- Locks into stable cycle
2  -3
2  -6
2  0
2  2       <- Repeats forever!
2  -3
2  -6
2  0
```

## ROOT CAUSE: Integer Truncation Kills Chaos

### The Mathematics That Kills It

When the system reaches x=2, y=2, z=2:

**Step 1: Calculate d (dx/dt)**
```
d = (y - x) * sigma / 100
d = (2 - 2) * 10 / 100
d = 0 * 10 / 100 = 0        ✓ Correct
```

**Step 2: Calculate e (dy/dt)**
```
e = x * (rho - z) / 100 - y
e = 2 * (28 - 2) / 100 - 2
e = 2 * 26 / 100 - 2
e = 52 / 100 - 2
e = 0 - 2 = -2              ✗ SHOULD BE 0.52 - 2 = -1.48
```

**TRUNCATION ERROR**: `52/100 = 0` in integer math, should be 0.52!

**Step 3: Calculate f (dz/dt)**
```
f = x*y/100 - beta*z/100
f = 2*2/100 - 267*2/100
f = 4/100 - 534/100
f = 0 - 5 = -5              ✗ MAJOR ERROR (both terms truncated)
```

### The Feedback Loop of Death

1. **Large values** → divisions work somewhat (96/100 = 0, but deltas still move system)
2. **Medium values** → truncation starts dominating (52/100 = 0)
3. **Small values** → almost all motion disappears
4. **Tiny values (2,2,2)** → locked in periodic orbit because:
   - Changes too small to register
   - System can't escape due to quantization
   - Enters stable 4-cycle: (2,2) → (2,-3) → (2,-6) → (2,0) → repeat

## Why Real Lorenz is Chaotic

The true Lorenz equations need **continuous** values:
```
dx/dt = 10(y - x)           needs x ≈ -15 to +15 with 0.01 precision
dy/dt = x(28 - z) - y       needs precise subtraction
dz/dt = xy - (8/3)z         needs 8/3 = 2.666... precision
```

**Your integer version has only 2 decimal places** (scale=100):
- 267 represents 2.67 (should be 2.666...)
- 52/100 = 0 (should be 0.52)
- Loss of 99% of the derivative information!

## The Speed Slowdown Mystery - SOLVED

**It's NOT the computation slowing down - it's the SERIAL OUTPUT!**

### The Math:
```
Serial settings: 4800 baud = 480 bytes/second
Each output line: "100  -72\n" = ~10 characters
Time per line: 10 chars ÷ 480 chars/sec = 0.020 seconds (20ms)

Total I/O time for 500 iterations:
500 × 20ms = 10 seconds just printing!
```

**The computation takes < 0.1 seconds.**
**The printing takes ~10 seconds.**

### Why It FEELS Slower Later:
- **Human perception bias**: First 10 lines flash by (0.2 sec)
- Later: watching 490 more lines slowly print (9.8 sec)
- Your brain registers "it got slower" but it's **constant 20ms/line**

## Solutions

### Option 1: Increase Scaling (Better Precision)
```mint
:L
10000 x! 10000 y! 10000 z!      // Scale by 10000 instead of 100
// ... adjust all divisions accordingly
```
More precision, but risk of 16-bit overflow!

### Option 2: Print Less Often (Faster)
```mint
i 10 % 0 = (x . 32 /C y . /N)   // Only print every 10th iteration
```
Runs 10x faster (saves 9 seconds on I/O)

### Option 3: Use Floating Point APU
Call the AM9511 APU chip at port 0x80 for real floating point

### Option 4: Accept The Limitation
MINT's 16-bit integers **cannot do chaotic Lorenz properly**
- Use it for simple dynamics
- Use Octave/MATLAB for real Lorenz simulations

## Key Takeaways

1. **Chaos requires precision** - you can't fake it with 2 decimal places
2. **Integer math kills continuous dynamics** - truncation = energy loss
3. **Serial I/O dominates runtime** - not the CPU
4. **TEC-1 is amazing** - but it has limits (and that's okay!)

The fact you got it to run at all on a Z80 with 2KB RAM is impressive!
The settling into stability is a **feature of discrete mathematics**, not a bug.
