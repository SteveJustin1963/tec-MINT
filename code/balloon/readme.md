Height of a weather balloon Observers at positions A and B
2 km apart simultaneously measure the angle of elevation of a
weather balloon to be 40° and 70°, respectively. If the balloon is
directly above a point on the line segment between A and B, find
the height of the balloon.



Step 1: Set up the geometric model Let \(h\) represent the height of the balloon. 
Let \(C\) be the point on the ground directly beneath the balloon. 
The observers are at points \(A\) and \(B\), separated by a total distance of \(2\text{\ km}\). 
Let the distance from \(A\) to \(C\) be \(x\).
Since the balloon is between \(A\) and \(B\), the distance from \(B\) to \(C\) is \(2-x\). 

Step 2: Formulate trigonometric equations Using the definition of 
the tangent function 
(\(\tan \theta =\frac{\text{opposite}}{\text{adjacent}}\)) 
for both right triangles 
\(\triangle ACD\) and \(\triangle BCD\): 

For observer A: \(\tan (40^{\circ })=\frac{h}{x}\implies x=\frac{h}{\tan (40^{\circ })}\)

For observer B: \(\tan (70^{\circ })=\frac{h}{2-x}\implies 2-x=\frac{h}{\tan (70^{\circ })}\) 

Step 3: Solve for the height (\(h\)) Substitute the expression for \(x\) from the first equation into 
the second:\(2-\frac{h}{\tan (40^{\circ })}=\frac{h}{\tan (70^{\circ })}\)\(2=h\left(\frac{1}{\tan (40^{\circ })}+\frac{1}{\tan (70^{\circ })}\right)\)\(h=\frac{2}{\cot (40^{\circ })+\cot (70^{\circ })}\)

Using a calculator: \(\tan (40^{\circ })\approx 0.8391\)\(\tan (70^{\circ })\approx 2.7475\)\(h=\frac{2}{1.1917+0.3640}\approx \frac{2}{1.5557}\approx 1.2856\)

Answer: The height of the balloon is approximately 1.29 km. 


## MINT2 Solution

Three MINT implementations are provided:

### balloon_simple.mint
Minimal implementation (< 256 bytes per function) for the example problem.

**Functions:**
- `:T` - Tangent lookup for 40° and 70° (scaled x10000)
- `:B` - Main calculation (distance, angle1, angle2 -> height)
- `:D` - Demo with example values (2km, 40°, 70°)

**Usage:**
```
> D
Height: 1 km
```

For custom values:
```
> 2 40 70 B
Height: 1 km
```

### balloon_v2.mint
Extended version with comprehensive angle table (10° - 80° in 5° increments).

**Usage:**
```
> M           // Run example
> 2 40 70 P   // Custom: P takes distance angle1 angle2
```

### balloon.mint
Educational version with detailed output and error messages.

**Note:** MINT uses 16-bit integer math, so values are scaled by 10000 for precision.
The result `1` represents 1.2856 km ≈ 1286 meters (limited by integer precision).
