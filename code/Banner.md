```mint1.0
\\ for ver 1.0
\\ https://github.com/monsonite/MINT-Documentation/blob/main/MINT_examples.txt

Print out the top element of the stack as 8-bit binary number

:C"(`1`)0=(`0`);         					C prints out either 1 or 0}}

:B b! 8(128 b@ & 128 = C b@ { b!);          B tests each bit in turn and prints out 1 or 0 accordingly

:G"(219 \E)0=(32 \E);						G emits either whitespace or blackspace (for chunky graphics).

:A b! 8(128 b@ & 128 = G b@ { b!) \N;		A produces a row of chunky pixels followed by NEWLINE

\N #7E A #81 A #81 A #81 A #FF A #81 A #81 A #81 A    Prints letter A

\N #FE A #81 A #81 A #FE A #81 A #81 A #81 A #FE A    Prints letter B

\N #7E A #80 A #80 A #80 A #80 A #80 A #81 A #7E A    Prints letter C
```

Cut and paste this code into terminal to print chunky A B C
```
:G"(219 \E)0=(32 \E);
:A b! 8(128 b@ & 128 = G b@ { b!) \N;
\N #7E A #81 A #81 A #FF A #81 A #81 A #81 A #00 A 
\N #FE A #81 A #81 A #FE A #81 A #81 A #FE A #00 A
\N #7E A #81 A #80 A #80 A #80 A #81 A #7E A #00 A
```
"BANANA BANDANA"  - a fun banner to print out on a terminal in chunky, 8x8 block graphics

First store the pixel patterns for  12 upper case alpha characters in byte arrays, define words G and P.
G prints out either a space (black) or an inverse space (white) character
P addresses the 8 bytes of the chosen array in turn and uses G to print a character 
```
\[#7E #81 #81 #FF #81 #81 #81 #00 ]  $a!   
\[#FE #81 #81 #FE #81 #81 #FE #00 ]  $b!
\[#7E #81 #80 #80 #80 #81 #7E #00 ]  $c!
\[#FE #81 #81 #81 #81 #81 #FE #00 ]  $d!
\[#FC #80 #80 #F8 #80 #80 #FC #00 ]  $e!
\[#FC #80 #80 #F8 #80 #80 #80 #00 ]  $f!
\[#FE #10 #10 #10 #10 #10 #FE #00 ]  $i!
\[#3C #42 #20 #18 #04 #42 #3C #00 ]  $s!
\[#FE #10 #10 #10 #10 #10 #10 #00 ]  $t!
\[#C3 #A5 #99 #81 #81 #81 #81 #00 ]  $m!  
\[#C1 #A1 #91 #89 #85 #83 #81 #00 ]  $n!
\[#00 #00 #00 #00 #00 #00 #00 #00 ]  $\s! 

:G"(219 \E)0=(32 \E);
:P @+\@ z! 8(128 z@ & 128 = G z@ { z!) 32 \E;
:M """mPiPnPtP\N;
:K """""""""""""bPaPnPaPnPaP\sPbPaPnPdPaPnPaP\N;
:B 8(\i@K);
:C 8(\i@M); 
C
B
```



```
\N #7E A #81 A #81 A #FF A #81 A #81 A #81 A #00 A #FE A #81 A #81 A #FE A #81 A #81 A #FE A #00 A  #7E A #81 A #80 A #80 A #80 A #81 A #7E A #00 A

:E b! 3(4 b@ & 4 = G b@ { b!) \N;        This is a 3x5 font  only numbers 0 to 7 are needed 

7E 4E 6E 4E 7E     Print an E

7E 5E 4E 5E 7E     Print a C

3E 5E 4E 5E 3E 

7E 5E 6E 5E 7E    Print a B

```
