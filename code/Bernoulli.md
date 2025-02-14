```
// https://rclab.de/en/analyticalengine/bernoullinumbercalculation
// https://mathworld.wolfram.com/BernoulliNumber.html
// https://math.stackexchange.com/questions/2844290/what-is-the-simplest-way-to-get-bernoulli-numbers


#include <stdio.h>

// Function to calculate coefficients A_i(n) iteratively for each Bernoulli term
double calculate_A(int n, int i) {
    double result = (i == 0) ? (1.0 / 2) * (2.0 * n - 1) / (2.0 * n + 1) : 1.0;

    for (int j = 1; j <= i / 2; j++) {
        result *= ((2.0 * n - (2 * j - 1)) / (2 * j + 1)) * ((2.0 * n - (2 * j - 2)) / (2 * j + 2));
    }

    return result;
}

// Main function to calculate Bernoulli numbers up to B_(2n-1) for a given max_n
void calculate_Bernoulli_numbers(int max_n) {
    double BernoulliNumbers[40] = {0};  // Array to store Bernoulli numbers up to B_39
    BernoulliNumbers[1] = calculate_A(1, 0);  // B1 = A0(1)

    // Calculate subsequent Bernoulli numbers
    for (int n = 2; n <= max_n; n++) {
        // Initialize B_(2n-1) with A_0(n), the constant term for this Bernoulli number
        double B_current = calculate_A(n, 0);

        // Add recursive contributions from previously computed Bernoulli numbers
        for (int i = 1; i < 2 * n - 1; i += 2) { // Odd indices as per Lovelace’s formula
            double Ai = calculate_A(n, i);         // Coefficient A_i(n)
            double Bi = BernoulliNumbers[i];       // Previously computed Bernoulli number
            B_current += Ai * Bi;                  // Update current Bernoulli number
        }

        // Store the calculated Bernoulli number B_(2n-1)
        BernoulliNumbers[2 * n - 1] = B_current;
    }

    // Output the calculated Bernoulli numbers
    for (int i = 1; i <= 2 * max_n - 1; i += 2) {
        printf("B_%d = %f\n", i, BernoulliNumbers[i]);
    }
}

int main() {
    int max_n = 10; // Calculate Bernoulli numbers up to B_19 (first 20 numbers)
    calculate_Bernoulli_numbers(max_n);
    return 0;
}
```

//////////////////////////////
```
// 16 bit signed with integer logic

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define SCALE 1000  // Scaling factor to approximate fractions

// Custom absolute value function for int16_t
int16_t abs_int16(int16_t value) {
    return (value < 0) ? -value : value;
}

// Function to calculate scaled coefficients A_i(n) for each Bernoulli term
int16_t calculate_A(int n, int i) {
    int16_t result = (i == 0) ? (int16_t)((1.0 / 2) * (2 * n - 1) / (2 * n + 1) * SCALE) : SCALE;

    for (int j = 1; j <= i / 2; j++) {
        result = (int16_t)(((int32_t)result * (2 * n - (2 * j - 1)) / (2 * j + 1) * (2 * n - (2 * j - 2)) / (2 * j + 2)) / SCALE);
    }

    return result;
}

// Main function to calculate Bernoulli numbers up to B_(2n-1) for a given max_n
void calculate_Bernoulli_numbers(int max_n) {
    int16_t BernoulliNumbers[40] = {0};  // Array to store scaled Bernoulli numbers up to B_39
    BernoulliNumbers[1] = calculate_A(1, 0);  // B1 = A0(1), the initial Bernoulli number

    // Calculate subsequent Bernoulli numbers
    for (int n = 2; n <= max_n; n++) {
        // Initialize B_(2n-1) with scaled A_0(n), the constant term for this Bernoulli number
        int16_t B_current = calculate_A(n, 0);

        // Add contributions from previously computed Bernoulli numbers
        for (int i = 1; i < 2 * n - 1; i += 2) { // Odd indices as per Lovelace’s formula
            int16_t Ai = calculate_A(n, i);         // Scaled coefficient A_i(n)
            int16_t Bi = BernoulliNumbers[i];       // Previously computed scaled Bernoulli number
            B_current += (int16_t)(((int32_t)Ai * Bi) / SCALE);  // Update current Bernoulli number
        }

        // Store the scaled Bernoulli number B_(2n-1)
        BernoulliNumbers[2 * n - 1] = B_current;
    }

    // Output the scaled Bernoulli numbers (dividing by SCALE to approximate)
    for (int i = 1; i <= 2 * max_n - 1; i += 2) {
        printf("B_%d = %d.%03d\n", i, BernoulliNumbers[i] / SCALE, abs_int16(BernoulliNumbers[i] % SCALE));
    }
}

int main() {
    int max_n = 10; // Calculate Bernoulli numbers up to B_19 (first 20 numbers)
    calculate_Bernoulli_numbers(max_n);
    return 0;
}
```


/////////////////////////////////////////
```

\ forth83
\ Scaling factor for fixed-point approximation
1000 CONSTANT SCALE

\ Define a variable array to store Bernoulli numbers
CREATE B-ARRAY  \ Changed from VARIABLE to CREATE
40 CELLS ALLOT  \ Allocate space for 40 scaled Bernoulli numbers

\ Helper word for absolute value of int16_t
: ABS16 ( n -- |n| )
    DUP 0< IF NEGATE THEN ;

\ Helper word to store a value in B-ARRAY at a specific index
: B! ( n index -- )
    CELLS B-ARRAY + ! ;

\ Helper word to retrieve a value from B-ARRAY at a specific index
: B@ ( index -- n )
    CELLS B-ARRAY + @ ;

\ Calculate the coefficient A_i(n) iteratively to avoid recursion
: CALCULATE-A ( n i -- result )
    OVER 0= IF  \ Get the constant term for A_0(n)
        DROP  \ Clean up stack
        2 * 1- SCALE *  \ Scale the numerator
        SWAP 2 * 1+ /   \ Divide by denominator
        EXIT
    THEN
    \ Iterate over j = 1 to i/2 for A_i(n)
    SCALE SWAP  \ Put scale on top for multiplication
    OVER 2 / 1+ 1 DO  \ Changed loop bounds to be more accurate
        2DUP I * SWAP  \ Duplicate n and scale, multiply by I
        2 * I 2 * - 1+ /  \ Calculate denominator
        I 2 * + 1+ /      \ Further division
        +                 \ Add to running sum
    LOOP
    NIP ;  \ Clean up stack

\ Main loop to calculate Bernoulli numbers up to B_(2n-1) for max_n
: CALCULATE-BERNOULLI-NUMBERS ( max_n -- )
    0 1 B!  \ Initialize B1 = A0(1)
    DUP 1+ 2 DO  \ Changed loop structure
        I 0 CALCULATE-A I B!  \ Store initial A_0(n)
        I 1 DO
            I J CALCULATE-A
            J I - B@ *  \ Fixed index calculation
            SCALE / 
            I B@ + I B!  \ Update current value
        LOOP
    LOOP ;

\ Print scaled Bernoulli numbers up to given max_n
: PRINT-BERNOULLI-NUMBERS ( max_n -- )
    CR ." Bernoulli Numbers:" CR
    DUP 1+ 1 DO
        I . ." : "  \ Print index
        I B@ DUP    \ Get value and duplicate
        SCALE /     \ Get integer part
        SWAP SCALE MOD  \ Get fractional part
        ABS16 
        OVER . ." ."  \ Print integer part and decimal point
        S>D <# # # #  \ Format fractional part with leading zeros
        #S #> TYPE    \ Convert to string and print
        CR
    LOOP ;

\ Example usage
: TEST-BERNOULLI ( -- )
    10 CALCULATE-BERNOULLI-NUMBERS
    10 PRINT-BERNOULLI-NUMBERS ;
```


/////////////////////////////////////////////

The code is calculating Bernoulli numbers with integer arithmetic by scaling them by 6 to avoid fractions. The known first few Bernoulli numbers are:
- B₀ = 1
- B₁ = -1/2 
- B₂ = 1/6

The code maintains accuracy by:
1. Scaling all values by 6 to work with integers
2. Doing calculations with the scaled values
3. Un-scaling at the end by dividing by appropriate factors


```mint2
// mint2 
 
 :B
[0 0 0 0 0]b!

// B0 = 1/1 (scaled by 6)
6 b 0?!
`B0=1/1`/N

// B1 = -1/2 (scaled by 6)
-3 b 1?!
`B1=-1/2`/N

// B2 calculation (scaled by 6)
// 1: Start with 6 (B0 scaled)
6 s!
// 2: Add -9 (3*B1 scaled)
b 1? 3 * t!
s t + p!
// 3: Negate and divide by 3
0 p - q!
q 3 / v!
v b 2?!
`B2=1/6`/N

`sum=`s.` t=`t.` p=`p.` final=`v./N
;
```


//////////////////////////////////
