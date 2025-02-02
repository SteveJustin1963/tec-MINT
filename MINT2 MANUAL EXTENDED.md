MINT Programming Language version 2.0

- if a program, function or command has any type of logical or syntax error, it will corrupt MINTS ability accept even correct input and or run correct input
- all input MUST be prefect and error free for the code to run error free unless there is a bug in the code.
- MINT is a minimalist character-based interpreter but one which aims at fast performance, readability and ease of use. 
- this is the prompt of MINT `> ` ready to accept input
- On initialisation it will present a user prompt ">"
- It is now ready to accept commands from the keyboard which can be entered followed by followed by a CRLF (enter key)
- after CRLF a new prompt will appear. when you upload code into terminal with a text transfer method, at the end of each function the `>` should be echoed back
- lines cannot exceed 256 bytes in length with the current internal buffer setting
- MINT is a byte-code interpreter - this means that all of its instructions are 1 byte long. 
- However, the choice of instruction uses printable ASCII characters, as a human readable alternative to assembly
language. 
- Variables are a to z lowercase and only as single character followed by a space, double letter allowed if commented at top of program
- Functions labelled from A to Z uppercase as single character followed by a space, they are created with beginning with `:` eg :F, there is strictly now space between : and F, and function ends with with `;`
- if you run out of function letters you can use double letters, note it with comment //
- if a variable is updated eg a b + and you want to store it, you cannot use ! on its own it must be with a variable, ie b!


- Z is reserved for interrupt calls. You write your interrupt routine under this function.
- eg :R 1 2 + . ;
- do not enter a space between `:` and the function letter
- this means we define a function with : and end with ;
- when designing code use plenty comments per line and CRLF
- but when uploading code into the interpreter put each function as a one whole line with no comments, strip all comments out
- make all inline strings short, we only have 2k of ram
- 
- The mint can only handle signed 16-bit integers in decimal and unsigned in hexadecimal
- to increase integer accuracy write your code by using signed 16-bit (2-byte) cells and store intermediate results using 32-bit (4-byte)
- scale your number accordingly to prevent overflows where possible
- it is known that integer maths has less complexity and more efficiency than floating point for may tasks 
- if we need 32bit floating point we can optionally call the AP9511 APU chip placed at port 0x80 for /CS and port 0x81 for C,/D where D = port 80 and C = port 81
- When stripping out all comments, also best to place one function per line, not stagger across several lines; reduces crashes.
- Comments are preceded with //
- Comment must not occur on same line as code (bug) but placed on the next line
- In this manual we will place them on the same line for explanation purposes only.
- Do not use it in actual code as it interferes with MINT's buffer
- Better to remove all comments when loading final code.
- @ has no use in code, ignore its use for now
- delays are made with (), for example 100() means do nothing 100 times, this can be nested for longer loops 100(100())
-

### Reverse Polish Notation (RPN)
- RPN is a way of writing expressions in which the operators come after their operands. 
- Concatenation languages makes use of the stack which is used to collect data to do work on. 
- The results are pushed back onto the stack.
- Like Forth, MINT has no protection against underflow for performance reasons, thus calling things off the stack that are not placed there will call spurious numbers

eg 
```
> 10 20 + .  // puts two number on stack, then add, then show result from the stack with `.`
30
>
```

### Interaction 
- interact with the MINT interpreter (MI) at the prompt which looks like this `> `
- if we enter numbers, they are pushed onto the stack. 
- If the MI encounters a non number it decides if its an operator eg such as `+` which is used to add two items from the stack and then pushes the result back to the stack.
- We can display the result with `.` operator that takes the result from the stack and prints it to the MI console which is talking to a ASCII terminal via a serial line at 4800 bps.

### Numbers 
- MINT only uses 16-bit integers and signed numbers to represent numbers. Nothing bigger! 
- When `+` and `-` operations are performed and the result is larger that 16bits a carry bit is set and stored in variable `/c`
- the `/c` bit remains until a new carry is set or reset in code with `0 /c !`
- With `*` operations, when the result exceeds 16bits it rolls over, each roll over is stored in variable `/r` 
- the `/r` bit remains until a new rollover is set or reset in code with `0 /r !`
- when the `/` is used to divide, the result goes on the stack and the remainder goes into /r variable
- all the `/ * + - ` operations will set the `/c` and `/r` variables correctly each time used


- There are two main types of numbers in MINT: 
- decimal numbers and hexadecimal numbers.
- The largest number is #FFFF or 65535 for unsigned, then it wraps or loops back to 0 
- When we using in hex number 0000 to FFFF, there is no signed numbers
- when using decimal integers it converts to signed numbers

### for example
```
> #FFFF 1 - . // display decimal integer with `.`                                                           
-2                                                                              
> #FFFF 1 - , // display hex integer with `,`
FFFE                                                                            
> 

> 0 /r! 0 /c!            // setting to 0                                           
> #FFFF 1 + ,  // add 1 and show result as hex
0000
> /r .                  // show result 
0
> /c .                  // show result 
1
>
```

### Decimal numbers
- Decimal numbers are represented in MINT in the same way that they are represented
in most other programming languages. 
- decimal is signed integers using 16 bits
- For example, the number `12345` is represented as `12345`. 
- A negative number is preceded by a `-` as in `-786`.
- to apply negation to a number, is done with `-1 * `

### Hexadecimal numbers
- Hexadecimal numbers are represented in MINT using 0 to 9 and uppercase A to F to represent 
the digits from 0 to 15
- Hexadecimal numbers are prefixed with a #
- for example, the hexadecimal number 1F3A is entered as #1F3A, and displayed as 1F3A
- and if #FF is entered its displayed as 00FF
- hexadecimal numbers are assumed to be positive in MINT not signed like decimal numbers


All programming logic for decimal and hexadecimal need to follow integer logic 
and and fixed point numbers need to scaled before logic then converted back.


### Printing
- MINT provides commands for printing numbers in decimal and hexadecimal format.
- The `.` operator prints numbers to the console in decimal. like 123 or -25 (minus 25)
- The `,` operator prints numbers to the console in hexadecimal. like 00FF
- Printing text, can print literal text by using enclosed quotes with the ` character
- literal text with `....` does not need the `.` dot to display it, only numbers need `.` or `,`
- For example
```
> 100 x !           // the value of x is 100
> x .
100
>
```

### Stack Manipulation 
- The stack is a central data structure that stores values temporarily.
- we need to use the stack to write code. 
- Duplicate; this operator duplicates the top element of the stack with the the command `"` 
- eg

```
> 10 " . .
10 10
>
```

### Drop 
- drops the top number from the stack, we use the `'` letter to do this  
- eg

```
> 20 30 ' .
20
>
```

### Swap
swaps positions on the top two elements of the stack, we use `$` 
- eg 
```
> 40 50 $ . .
50 40
>
```

### Over
performs an over operation on the second element from the top of the stack and
places it on the top of the stack, we use the `%` 
-eg

```
> 60 70 % . . .
70 60 70
>
```



### Basic arithmetic operations

### Addition
eg
```
> 10 20 + .
30
>
```

- This program adds 20 to 10 which results in the value 30
- The `.` operator prints the sum as signed decimal 
- if we add more than the 16 bits we get a carry overflow and this will set the /c variable

eg
```
> c .  // making sure carry is 0
0 
> # FFFF 1 +
> /c .
1
> /c .
1
// the carry is not reset we have to manually clear it
> 0 /c !  /c .
0
>
```




### Multiplication
```
> 5 4 * .
20
>
```

This program places 5 and 4 on the stack and runs the operator `*` which
multiplies them together. If multiplications result in a value greater than #FFFF, the `overflow` of the
last multiplication operation is available in the /r system variable. ( not in /c, that's for + and - )


```
> 10 20 - .
-10
>
```
This program subtracts 20 from 10` which results in negative value -10


### Division
```
> 5 4 / .
1
```
- This program divides 5 with 4 prints the result 1
- To get the remainder of the division we read the /r system variable.
eg
```
> 5 4 /.
> /r .
1
```

### Logical operators
- MINT uses numbers to define boolean values.
- false is represented by the number `0` or `/F`
- true is represented by either `-1` or `1` and `/T` but it defaults to `-1`

eg 
```
> 3 0 = .
0
>
// also
> 0 0 = .
-1
>
```

### Bitwise Logical Operators 
- MINT has a set of bitwise logical operators that can be used to manipulate bits. 
- These operators are:
- & performs a bitwise AND operation on the two operands.
- | performs a bitwise OR operation on the two operands.
- ^ performs a bitwise XOR operation on the two operands.
- { shifts the bits of the operand to the left by one.
- } shifts the bits of the operand to the right by one.

They can be used to 
- Check if a bit is set or unset.
- Setting or clearing a bit.
- Flipping a bit.
-
 Counting the number of set bits in a number.

eg 
- Check if the first bit of the number 10 is set
```
> 11 1 & ,
0001
>
```

eg 
Shift 1 three times to the left (i.e. multiple by 8) and then OR 1 with the least significant bit.
```
> 1 {{{ 1 | ,
0009
>
```

eg S
hift 1 two times to the left (i.e. multiple by 4) and then XOR #000F and then mask with #000F.
```
> 1 {{ #F ^ #F & ,
000B
>
```
### Variables
- Variables are named locations in memory that can store data. 
- MINT has a limited number of global variables 
- which have single letter names. never more than one character.
- variable can be referred to by a singer letter from `a` to `z` so there are 26 only available
- Global variables can be used to store numbers, strings, arrays, blocks, functions etc.
- To assign the value `10` to the global variable `x` use the `!` operator.

eg 
```
> 10 x !
> x .
10
>
```

- the number `10` is assigned to the variable `x`
- To access a value in a variable `x`, simply refer to it in your code as the letter on its own
- no need to place it on the stack

eg
- adds `3` to the value stored in variable `x` and then prints it.
```
> 3 x + .
13
>
```
- The following code assigns the hexadecimal number `#3FFF` to variable `a`
- The second line fetches the value stored in `a` and prints it.

eg
```
> #3FFF a !
> a .
16383
>a ,
3FFF
>
```

Next, this longer example, the number 10 is stored in `a` 
- and the number `20` is stored in `b`. 
- The values in these two variables are then added together 
- and the answer `30` is stored in `z`. 
- Finally `z` is printed.

ie

```
> 10 a ! 20 b !
> a b + z !
> z .
30
>
```
### Arrays

### Basic arrays
- MINT arrays are a type of data structure that can be used to store a collection of elements.
- they are stored in the heap area of MINT until rebooted, once defined, their size cannot be changed
- Arrays are indexed, which means that each element in the array has a unique number associated with it. 
- This number is called the index of the element.
- In MINT, the array indexes start at 0
- To create a MINT array, you can use the following syntax:  
- v = variable i.e. single lowercase single letter
- n= number 

```
> [n n n] // multi n can be used until heap memory is used up.
          // note there must be no space between [n and n]
> [n v]   // you can mixed numbers with variables

```


eg
```
> [1 2 3]  // but we need to save it
```
- the whole Arrays can be assigned to a variables letter just like numbers can be assigned to a variables letter


ie
```
> [1 2 3]a!  // not no space between ]a!
```
- An array of 16-bit numbers can be defined by enclosing them within square brackets:

next we 
```
> [1 2 3 4 5 6 7 8 9 0] 
> .
3254 // we get the memory location, we do use it this way, so save it to a variable like a!
>
```
- when defining an array, its contents is placed in the heap and its address onto the stack unless stored in a variable, which is recommended.
- once defined the array size cannot change.
- for example `> [1] ` will place its address on stack, we can see it with `>.` showing 3234 
- if we add another array [4] then `>.` shows 3238 
- we should save the address that points to the array in a variable, so it acts as a pointer to the array in the heap memory

ie
```
> [1 2 3 4 5 6 7 8 9 0]a!

>
```
then
- To fetch the Nth member of the array, we use a index operator `?`
- The following prints the item at index 2 (which is 3).

eg
```
> [1 2 3]2? .
3
>
```

### Updating contents of array
eg

```
> [1 2 3]p!  // save to p                                            
> p 0?.  // let recall p and check location 0                                                                         
1        // correct
> p0? -222 p0?!        // lets call p0? then replace with -222 then save it again

// lets test it
> p 0?.        // lets check if it updated
-222                                                                            
>         // good its worked
```

### Array size
- as noted before the array size cannot change once set
- The size of an array can be determined with the `/S` operator
- which puts the number of items in the array on the stack
- The following prints 5 on the console.

eg
```
> [1 2 3 4 5] /S .
5
>
```

### Array depth
bug, this command is broken, do not use
it should work like this
```> [1 2 3] /D .
3
> 
```



### Nested arrays 

- In MINT arrays can be nested inside one another.

- this works
```
> [1 2 3 4] a !
> [2 a 3] b!
The syntax to access the third element of a from b is
> b 1? 3? .
4
>
// note the result, it works
```


- The following code shows an array with another array as its second item.
- This code accesses the second item of the first array with `1?`. 
- It then accesses the first item of the inner array with `0?` and prints the result (which is 2).

eg
```
> [1 [ 2 3 ] ] a!                                                
> [1 2 3 ] b!
> b 0?.
1
// looks correct
> b 2?.
3
> // looks correct
> a 0?. 
1
> // looks correct
> a 1?.               
3246
> // Bug!! dont use
>

> // tried
> [ 3 4 [1 2] a!] b!                                                            
                                                                                
> a 0?.                                                                         
1     //good                                                                          
> b 1?.                                                                         
4     //good                                                                          
> b 2?.                                                                         
2     // ????? bug
> b 3?.                                                                         
3     // ????? bug
> b 4?.                                                                         
2    // ?????? bug
>    
```

### Byte arrays
- MINT by default declares arrays of 16 bit words 
- however it is also possible to declare and array of 8 bit byte values by using `\` 
which puts MINT into `byte mode`.

eg

```
> \[1 2 3] a!
>
```
- The size of a byte array can be determined with the `/S` operator.
- The following code prints 3.

Then
```
> \[1 2 3] /S .
2
>
> \[1 2 3] 1\?   .
3
>
```

### Leaving byte mode (and return to 16bit word mode) 
- when it executes a `]`, `?` or `!`


### Memory allocation
- memory allocation in MINT is the simplest raw memory allocation on the heap.
- This type of allocation is similar to arrays of bytes and are created using the `/A` allocation operator.

This code allocates a 1000 byte block of uninitialised memory and returns a pointer 
(an address) to the start of this block.
```
> 1000 /A
```

The same as allocating a byte array of three bytes ie
```
3 /A a !
```

Here the main difference is that the memory is not initialised.
also /S (get array size) does not work with memory allocated by /A. ie
```			
\[ 0 0 0] a !
```

To get a value, e.g. get item 0 to 10, is the same for both use
```
a 0 /?
```

To set a value, e.g set item 1 to 10, is the same for both use
```
10 a 1 /? /!
```


### Variables in Arrays
- you can put a variable in an array but it will only store the ASCII number of that you are inputting
- this means when you call an array value, and want to use it 
you have to convert the ASCII back to its alpha or numeric character 
- after calling the value form the array you can print the ASCII symbol with /K.

eg
```
> // setup functions
> : A /Ka! /Kb! /K c! ;
> : B [a b c] d! ;
> : C d0?. d1?. d2?. ;
> : D 1(A B C) ;
> D                  //run D and press 123
49 50 51   
>                 //it shows ASCII for 1 2 3
> D                 // run D and press abc
97 98 99  
>                // it shows ASCII for abc
```

### Control loops and counters 
- with /i and /j to control array size and access
- [ 0 0 0 0 0 ] a! // we need to initialise array each time in loops
 

eg
```
> // Define an array of 5 elements and store its address in 'a'
> [ 0 0 0 0 0 ] a! 	// need to initialize each time 
> 			// Loop 5 times to read input and store in the array
> 5( `Enter a digit:`   // Prompt the user
/K 48 - n!              // Read a character, convert ASCII digit to number, store in 'n'
n a /i ?!  /N           // Store 'n' into array at index /i
)
>
>
> 			// Loop 5 times to print each element of the array
5 ( `Value is:`		// Print label
a /i ? .  /N		// Fetch array element at index /i and print it
)
```


: A [ 0 0 0 0 0 ] a! ; 
: B 5 ( `Enter a digit: `  /K 48 - n!  n a /i ?!  /N ) ;
: C 5 ( `Value is: ` a /i ? .  /N ) ;

// run it
ABC



### Loops
- Looping in MINT is of the form

n(code)  // n is number of loops

eg
```
> 5 (`x`)
xxxxx
>
```
- The number represents the number of times the code between parentheses will be repeated. 
- If the number is zero then the code will be skipped. 
- If the number is ten, it will be repeated ten times. 
- If the number is -1 then the loop will repeat forever.


```
0(this code will not be executed but skipped)
1(this code will be execute once)
10(this code will execute 10 times)
/F(this code will not be executed but skipped)
/T(this code will be execute once)
/U(this code will be execute forever)
```

eg
```
> 10 (`x`)  // prints x 10 times
xxxxxxxxxx
>
```

eg
- The following code repeats ten times and adds 1 to the variable `t` each time.
- When the loop ends it prints the value of t which is 10.

```
> 0t! 10( t 1+ t! ) t .
10
>
```

### Loop Counter

### Inner Loop counter
- called `/i` which acts as a inner loop counter. 
- The counter counts up from zero 
- Just before the counter reaches the limit number it terminates the loop.

eg
- This prints the numbers 0 to 9.
```
> 10 ( /i . )
0 1 2 3 4 5 6 7 8 9
>
```

### Unlimited Loops 
- repeat loop forever with /U. 
- controlled with the "while" operator `/W`
- passing a false value to /W via a conditional test ( like > < or = ) will terminate the loop

eg
-
 This code initializes `t` to zero and starts a loop to repeat 10 times. 
- As it the code repeats it accesses the `/i` variable and compares it to 4. 
- When `/i` exceeds 4 it breaks the loop. Otherwise it accesses `t` and adds 1 to it.
- Finally when the loop ends it prints the value of t which is 4.

```
> 0t! /U(/i 4 < /W /i t 1+ t!) t . 
4
> // so it did it 5 times from 0 to 4
>
```
### Outer Loop counter 
- nested look like 

eg
```
> 10 ( `x` 10 (`y`)) 
xyyyyyyyyyyxyyyyyyyyyyxyyyyyyyyyyxyyyyyyyyyyxyyyyyyyyyyxyyyyyyyyyyxyyyyyyyyyyxyyyyyyyyyyxyyyyyyyyyyxyyyyyyyyyy
>
```

- We apply an outer loop counter with the `/j` variable 
- allows access the outer loop counter 

eg
- The following has two nested loops with limits of 2. 
- The two counter variables are summed and added to `t`.
- When the loop ends `t` it prints 4.

```
> 0t! 2(2(/i /j + t + t! )) t .
4
>
```

### Conditional code
- the looping mechanism can also be used to execute code conditionally. 
- boolean `false` is represented by 0 or `/F`  // uppercase F 
- boolean `true` is represented by 1 or `/T`   // uppercase T

eg
```
> /F(code will not be executed but skipped)
> /T(code will be execute once)
…result…
>
```

eg
- The following tests if `x` is less that 5.
```
> 3 x!
> x 5 < (`true`)
true
>
```

### IF-THEN-ELSE 
- the syntax for IF-THEN-ELSE or "if...else" operator in MINT is an extension of the loop syntax.

eg 
// boolean (code-block-then) /E (code-block-else)
- If the condition is true, then `code-block-then` is executed. 
- Otherwise, `code-block-else` is executed.

eg
```
> 10 x ! 20 y !
> x y > ( `x is greater than y` ) /E ( `y is greater than x` )
y is greater than x
> // result correct
>
```
- the variable x is assigned the value 10 and 
- the variable y is assigned the value 20.
- The "if...else" operator then checks to see if x is greater than y. 
- If it is, then the string "x is greater than y" is returned. 
- Otherwise, the string "y is greater than x" is returned.

eg
- code conditionally prints text straight to the console.
```
> 18 a !
> `This person ` a 17 > (`can `) /E (`cannot `) `vote`
This person can vote
>
```

- the variable a is assigned the value 18. 
- The "if...else" operator checks to see if age is greater than 17. 
- If it is, then the text "can " is printed to the console. 
- Otherwise, the string "cannot " is printed.

### Functions
- You can put any code inside `:` and `;` block 
- which tells MINT to "execute this later” when called by that letter
- Functions are stored in variables with single uppercase letters. 
- There are 26 functions only using the uppercase letters from A to Z
- Functions are called by referring to them by that letter

eg
- The following stores a function in the variable `Z`.
```
> :K `hello` 1. 2. 3. ; // important - no space between `:` and `K`
> K	    		// called by referring to it
hello 1 2 3
>
```

eg
- A basic function to square a value
```
> :F " * ;
> 4 F .  	// call function with a stack value of 4, remember we are do RPN
16
>
```
- The function stored in F duplicates the value on the stack and then multiplies them together then prints it


### Function with multiple arguments
- you can also define functions with multiple arguments

eg

```
> :F $ . . ;  
//swaps top two arguments on the stack and then prints 
> 3 7 . . 
7 3
> 3 7 F  
3 7 
>  
```
### Calling functions
```
> :F * ;
> 30 20 F .
600
>
```
- code passes the numbers `30` and `20` to the function Z which multiplies them and returns
the result which is then printed.

### Using functions
- Once you have written some code using variables and operator you can assign them to a functions use uppercase single letter such as
 A, B, C etc, this make up your overall MINT code. then you can run them by calling the label or labels or place them in other functions and calling that
Eg
```
> :A . ;
> :B + . ; 
> 10 A       // prints 10
10
> 3 7 B      // prints 10, the sum of 3 and 7
10
```
- In A we store 10 on the stack, call A  that executes `.` which prints `10`. 
- two numbers 3 and 7 are placed on stack, call B that executes with `+ .` add them then prints 10. 



### Anonymous functions 
- bug - does not work - do not use at moment
- MINT code is not restricted to upper case variables. 
- Functions an be declared without a variable (i.e. anonymously) by using the `:@` operator. 
- A function declared this way puts the address of the function on the stack.
- A function at an address can be executed with the `/G` operator.

eg
- This code declares an anonymous function and stores its address in `a`. 
- This function will increment its argument by 1.
- The next line pushes the number 3 on the stack and executes the function in `a`.
- The function adds 1 and prints 4 to the console.

```
> :@ 1+ ;   a! 
> 3 a . /G
bad output
//bug, dont use
```


- Anonymous functions can be stored in arrays 
- and can even be used as a kind of "switch" statement.

eg
- This code declares an array containing 3 anonymous functions. 
- The next line accesses the array at index 2 and runs it. 
- "two" is printed to the console.

```
> [:@ `zero` ; :@ `one` ; :@ `two` ;] b!
> b 2? /G
// bug hangs
```
all these tests hang or dont complete
```
>:@ 1 ; /G
1
>:@ 1+ ; a! 3 a /G
4
>[:@ 10 ;] 0? /G
10
>[:@ 10 ; :@ 20 ; :@ 30 ;] 2? /G
30
```



### Appendices

### List of operators

### Maths Operators

| Symbol | Description                               | Effect   |
| ------ | ----------------------------------------- | -------- |
| -      | 16-bit integer subtraction SUB            | n n -- n |
| /      | 16-bit by 8-bit division DIV              | n n -- n |
| +      | 16-bit integer addition ADD               | n n -- n |
| \*     | 8-bit by 8-bit integer multiplication MUL | n n -- n |


### Logical Operators

| Symbol | Description          | Effect   |
| ------ | -------------------- | -------- |
| >      | 16-bit comparison GT | n n -- b |
| <      | 16-bit comparison LT | n n -- b |
| =      | 16 bit comparison EQ | n n -- b |
| &      | 16-bit bitwise AND   | n n -- b |
| |      | 8-bit bitwise OR     | n n -- b |
| \|     | 16-bit bitwise OR    | n n -- b |
| ^      | 16-bit bitwise XOR   | n n -- b |
| ~      | 16-bit NOT           | n -- n   |
| {      | shift left           | n -- n   |
| }      | shift right          | --       |

### Stack Operations

| Symbol | Description                                                          | Effect       |
| ------ | -------------------------------------------------------------------- | ------------ |
| '      | drop the top member of the stack DROP                                | m n -- m     |
| "      | duplicate the top member of the stack DUP                            | n -- n n     |
| %      | over - take the 2nd member of the stack and copy to top of the stack | m n -- m n m |
| $      | swap the top 2 members of the stack SWAP                             | m n -- n m   |
| /D     | stack depth                                                          | -- n         |

### Input & Output Operations

| Symbol | Description                                    | Effect |
| ------ | ---------------------------------------------- | ------ |
| .      | print the number on the stack as a decimal     | n --   |
| ,      | print the number on the stack as a hexadecimal | n --   |
| \`     | print the literal string between \` and \`     | --     |
| /C     | prints a character to output                   | n --   |
| /K     | read a char from input                         | -- n   |
| /O     | output to an I/O port                          | n p -- |
| /I     | input from a I/O port                          | p -- n |

### Functions

| Symbol   | Description                     | Effect |
| -------- | ------------------------------- | ------ |
| :A ... ; | define a new command or function DEF        | --     |
- where "A" represents any uppercase letter
| :@ ... ; | define an anonymous command DEF | -- a   |
| /G       | execute mint code at address    | a -- ? |
| /X       | execute machine code at address | a -- ? |


### Loops and conditional execution

| Symbol | Description                            | Effect |
| ------ | -------------------------------------- | ------ |
| (      | BEGIN a loop which will repeat n times | n --   |
| )      | END a loop code block                  | --     |
| /U     | unlimited loop constant                | -- b   |
| /W     | if false break out of loop             | b --   |
| /E     | else condition                         | -- b   |
| /F     | false constant                         | -- b   |
| /T     | true constant                          | -- b   |

### Memory and Variable Operations

| Symbol | Description             | Effect |
| ------ | ----------------------- | ------ |
| a..z   | variable access         | -- n   |
| !      | STORE a value to memory | n a -- |
| /V     | address of last access. | -- a   |

### Array Operations

| Symbol | Description               | Effect   |
| ------ | ------------------------- | -------- |
| [      | begin an array definition | --       |
| ]      | end an array definition   | -- a     |
| ?      | get array item            | a n -- n |
| /S     | array size                | a -- n   |
| /A     | allocate heap memory      | n -- a   |

### Byte Mode Operations

| Symbol | Description                   | Effect   |
| ------ | ----------------------------- | -------- |
| \\     | put MINT into byte mode       | --       |
| \\!    | STORE a byte to memory        | b a --   |
| \\[    | begin a byte array definition | --       |
| \\?    | get byte array item           | a n -- b |

### System variables

| Symbol | Description                              | Effect |
| ------ | ---------------------------------------- | ------ |
| /c     | carry variable                           | -- n   |
| /h     | heap pointer variable                    | -- a   |
| /i     | loop variable
                            | -- n   |
| /j     | outer loop variable                      | -- n   |
| /k     | (internal) offset into text input buffer | -- a   |
| /r     | remainder/overflow of last div/mul       | -- n   |
| /s     | address of start of stack                | -- a   |
| /z     | (internal) name of last defined function | -- c   |

### Miscellaneous

| Symbol | Description                                   | Effect |
| ------ | --------------------------------------------- | ------ |
| //     | comment text, skips reading until end of line | --     | 

- there is a bug with comments, it does not skip when inline with code
- so always place comments on the next line on its own

### Utility commands

| Symbol | Description   | Effect |
| ------ | ------------- | ------ |
| /N     | prints a CRLF | --     |
| /P     | print prompt  | --     |

### Control keys
- executed on terminal, not in code

| Symbol | Description       |
| ------ | ----------------- |
| ^E     | edit a definition |
| ^H     | backspace         |
| ^L     | list definitions  |
| ^R     | re-edit           |
| ^S     | print stack       |


### Algorithm Examples
- Do not use 
- they are untested but they do provide some examples

### 1. Fibonacci Sequence
A loop that prints the first 10 numbers of the Fibonacci sequence.

```
:F n !        // Pop the number of iterations (n) from the stack
0 a ! 1 b !   // Initialize a = 0, b = 1
n (           // Loop n times
  a .         // Print current Fibonacci number
  a b + c !   // c = a + b
  b a !       // a = b
  c b !       // b = c
)
;
```
- **`n !`**: Pops the number of iterations from the stack and assigns it to `n`.
- The loop runs `n` times, printing `a` and updating `a` and `b` in each iteration.

### Calling the Function:
```
10 F  // Print the first 10 Fibonacci numbers
```


### 2. Factorial Function
- A recursive function that calculates the factorial of a number.

```
:F
  "           // Duplicate n
  1 >         // Check if n > 1
  (           // If true
    " 1 - F * // n * factorial(n - 1)
  ) /E (      // Else condition wrapped in parentheses
    1         // Return 1
  )
;
5 F .         // Calculate factorial of 5, prints: 120
```
- This function recursively calculates the factorial of a number `n`.
- If `n > 1`, it calls itself with `n - 1` and multiplies `n` by the result.
- If `n` is 1 or less, it returns 1, which is the base case to stop recursion.

### 3. Sieve of Eratosthenes
- A simple implementation of the Sieve of Eratosthenes to find prime numbers up to 30.

```
:S l !             // Pop the limit from the stack
2 p !              // Initialize p to 2 (start from the first prime)
l 2 - (            // Loop from 2 to the limit
  /T f !           // Set flag assuming p is prime
  p 2 * l < (      // Loop for multiples of p within the limit
    p i % 0 = (    // If p is divisible by i
      /F f !       // Set flag to false if divisible
    )
  )
  f /T = (         // If the flag is still true, print the prime
    p .
  )
  p 1 + p !        // Increment p
)
;
```
- **`S l !`**: The limit `l` (e.g., 30) is passed from the stack and stored in `l`.
- **`2 p !`**: The starting number for checking primes is set to `2` (the first prime number).
- **Loop**: The loop iterates over numbers from 2 to `l - 1`.
- **`/T f !`**: A flag `f` is initially set to true, assuming the number is prime.
- **Multiples Check**: For each number `p`, 
- another loop checks if `p` is divisible by any number between `2` and `p - 1`. 
- If `p` is divisible by `i` 
- (i.e., `p % i == 0`), the flag `f` is set to false (`/F f !`).
- **Prime Check**: After checking all divisors, if the flag `f` remains true (`f /T =`), the number `p` is prime and is printed (`p .`).
- **Increment**: After each iteration, `p` is incremented by 1 (`p 1 + p !`).
- to run it 
```
> 30 S  // Set the limit to 30 and call the sieve function
```

### 4. Greatest Common Divisor (GCD) using Euclidean Algorithm
- This program finds the GCD of two numbers using the Euclidean algorithm.

```
:A b ! a !    // Pop two numbers from the stack in LIFO order (b first, then a)
/U (          // Begin an unlimited loop
  b 0 > /W    // Continue while b > 0 (break if b == 0)
  a b % a !   // a = a mod b
  a b !       // Swap: b = old a, repeat
)
a .           // Print the GCD
;
```
- **`/W` as a Loop-While**: The `/W` construct functions as a loop-while, where the loop continues as long as the condition is **true** (non-zero). 
- When the condition becomes **false** (zero), the loop terminates.
- **`b 0 > /W`**: This checks if `b` is greater than 0 at each iteration. The loop continues while `b > 0` and breaks when `b == 0`, completing the 
- run it 
```
> 30 20 A       // Calculates the GCD of 30 and 20, prints GCD: 10
```

Example:
- To find the GCD of 30 and 20, you would call the function like this:

```
> 30 20 A       // Call the GCD function with 30 and 20, prints GCD: 10
```

### 5. Bubble Sort

```
:S l !                         // Store the list passed from the stack into variable l
l /S s !                       // Get the size of the list and store it in s
/T c !                         // Initialize the continue flag (c) to true
/U (                           // Start an unlimited loop for swapping
  c /W                         // Break the loop early if no swaps occurred (c == false)
  s 1 - (                      // Iterate over the list (size - 1 times)
    l i ? x !                  // Store l[i] in x
    l i 1 + ? y !              // Store l[i+1] in y
    x y > (                    // Compare x and y (l[i] and l[i+1])
      y l i !                  // Move y (l[i+1]) to l[i]
      x l i 1 + !              // Move x (l[i]) to l[i+1]
      /F c !                   // Set the continue flag to false (indicating a swap occurred)
    )
  )
)
;
```
- **Temporary Variables**: `x` stores `l[i]` and `y` stores `l[i+1]` to avoid repetition when swapping elements.
- **Continue Flag Initialization**: The continue flag `c` is initialized to **true** (`/T c !`) once at the start before the loop begins.
- **Early Check for Continue Flag**: The loop checks `c /W` early in each pass. If `c == false` (no swaps occurred in the previous pass), the loop terminates early.

Example running it
```
> [5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]
// result
> [5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]
// result
> [5 3 8 4 2] S  // Calls the bubble sort function on the list [5, 3, 8, 4, 2]
// result
```

### 6. Binary Search
- A binary search algorithm that searches for a value in a sorted array.
```
:B h ! l !             // Pop high and low indices from the stack (LIFO order)
l h <= (               // While low <= high
  m l h + 2 / !        // Find the middle index
  m a ? t = (          // If value at m is target
    m .                // Print index
  ) /E (               // Else block for equality wrapped in parentheses
    m a ? t < (        // If target is smaller, search left half
      m 1 - h !
    ) /E (             // Else block for greater condition wrapped
      l m 1 + !
    )
  )
)
;
```
- **`h ! l !`**: Pops the high (`h`) and low (`l`) indices from the stack in the correct LIFO order. When the function is called, you push the high 
- value first, followed by the low value.
- The binary search logic proceeds as normal:
- **Find the middle**: `m l h + 2 / !` calculates the middle index.
- **Compare**: If the middle value matches the target, print the index. 
- Otherwise, adjust the search range accordingly (either update `l` or `h`).
- to run it
```
> 0 9 B       // Searches in a sorted array from index 0 to 9
```

### 7. Quick Sort
- An implementation of the Quick Sort algorithm.

```
:Q s ! l !       // Pop the list and its size from the stack (LIFO order)
l s > 1 (        // If list length is greater than 1
  l p c !        // Choose a pivot element
  l s p p !      // Partition list around pivot
  s Q ! p Q !    // Recursively sort partitions
)
;
```
- **`s ! l !`**: Pops the list `l` and its size `s` from the stack in the correct LIFO order.
- **`l s > 1`**: Checks if the list length is greater than 1 to determine whether sorting is necessary.
- **Recursive Sorting**: It partitions the list around a pivot and recursively sorts both partitions until the base case is reached.
- run it 
```
> [5 3 8 4 2] 5 Q  // Sort the list [5, 3, 8, 4, 2]
```

### 8. Tower of Hanoi

```
:H s ! t ! f ! n !      // Pop the number of disks and rods (source, target, spare) from the stack
n 1 = (                 // If there is only 1 disk
  f t m !               // Move from source to destination
) /E (                  // Else
  n 1 - f t s H !       // Move n-1 disks from source to spare
  f t m !               // Move nth disk to destination
  s t f H !             // Move n-1 disks from spare to destination
)
;
```
- **`s ! t ! f ! n !`**: Pops the number of disks `n`, source rod `f`, target rod `t`, and spare rod `s` from the stack in the correct LIFO order.
- **Recursive Steps**:
- If there's only 1 disk, it moves directly from the source to the destination.
- If there are more than 1 disk, it recursively moves `n-1` disks to the spare rod, moves the nth disk to the target, and then moves the `n-1` disks from the spare 

to the target.
- run it 

```
> 3 f t s H .  // Solve Tower of Hanoi for 3 disks
```

### 9. Insertion Sort
- An implementation of the insertion sort algorithm.

```
:I l !         // Pop the list from the stack
l /S s !       // Get the size of the list
s 2 > (        // If list has more than 1 element
  s 1 to (     // Loop through the list starting from index 1
    l i ? k !  // Assign key from list element at index i
    i 1 - j !  // Initialize j to i - 1
    j 0 > k l j ? < (  // While j > 0 and key is less than list[j]
      l j 1 + l j !    //
 Shift elements to the right
      j 1 - j !        // Decrement j
    )
    k l j 1 + !        // Place the key at the correct position
  )
)
;
```
- **`l !`**: Pop the list from the stack.
- **`l /S s !`**: Use `/S` to get the size of the list and store it in `s`.
- **Key and Comparison**: Iterates over the list starting from index 1, compares the current element (`k`) with previous elements, and shifts 
- larger elements to the right until the correct position for `k` is found.
- run it

```
> [5 3 8 4 2] I  // Sort the list [5, 3, 8, 4, 2]
```

### 10. Dijkstra's Algorithm (Shortest Path)
- An implementation of Dijkstra's algorithm to find the shortest path in a graph.

```
:N g !           // Pop the graph from the stack
  u 0 !          // Initialize u (index) to 0
  g /S (         // Loop over all nodes in the graph
    u g ? d < (  // If the node at index u has a smaller distance
      u g !      // Update u to be the new minimum
    )
    u 1 + u !    // Increment u
  )
  u !            // Return the index of the minimum distance node
;

:D g ! s ! d !   // Pop the graph, start node, and distances from the stack
  d ! v /F !     // Initialize distances and visited nodes
  g /S (         // Loop over all nodes in the graph
    N m !        // Get the minimum distance node using N
    m u !        // Update distances of neighboring nodes
  )
  d .            // Print the shortest path
;
```
- run it 

```
> [ 0 7 9 0 0 14 0 0 10 15 0 11 0 6 ] g !  // Graph (Adjacency matrix)
> [ 0 999 999 999 999 ] d !               // Distances (start at 0, others infinity)
> 0 s !                                   // Start node is 0
> g s d D                                 // Call Dijkstra's algorithm
```
- **Graph**: `[ 0 7 9 0 0 14 0 0 10 15 0 11 0 6 ]` represents an adjacency matrix.
- **Distances**: `[ 0 999 999 999 999 ]` represents the distances from the start node to all other nodes, 
- initialized with infinity (or a large value) 
- except the start node (which is 0).
- **Start Node**: `s = 0` sets the start node to 0.

### Interrupt Handler         
- experimental code, do not use
- may or may not be in current source code, see John Hardy
- usage n /X  /v  :Z.....;        
- Interrupt Handler is triggered it executes the Z function on all interrupts including the RST instructions. 
- You can tell which interrupt it by looking in the /v variable.
- You won't be able to test the int 38 interrupt using asm80.com  serial terminal emulator because it is emulating a 6850 UART for the serial port to terminal 

output to screen
- but it will work with big bang serial code in MINT source code 
- you can simulate a interrupt by jumping to one of the RST addresses. 
- Eg RST 1 is at $0008 then :Z `hello!` ; // will execute

- eg 
- `> 8 /X`  
- This jumps to RST 1 address which will calls Z and return"        " know about RST instructions
- These are called software interrupts because they behave like hardware interrupts
- Hardware interrupts are RST 7 AND RST 8 which service INT and NMI
- You can't test hardware interrupts on asm80 for a few reasons
- but you can trigger a software interrupts. 
- The easiest way is to call the address of one. 
- RST 1 starts at $0008 
- RST 2 starts at $0010 etc
- "        "if you call $0008 from MINT, it's the same as a software interrupt 
- So try a software interrupt by calling its address. 
- good luck!

```
>8 /X
```
- /X pushes it's current location onto the stack and jumps to address $0008
- This then jumps to the mint function Z 
- When it returns it pops everything back and returns to your position in mint. 
- This is the same as what would happen if your mint code was interrupted by a hardware interrupt"        "
- So when you run a mint from ROM in the tec-1 and you interrupt it with an INT or a NMI, mint will not crash it will execute the function Z.

////end for now ///////
