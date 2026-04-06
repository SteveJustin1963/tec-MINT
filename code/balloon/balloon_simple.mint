// Balloon Height Calculator for MINT2
// Solves: Two observers measure angles to a balloon
// Input: distance between observers, two elevation angles
// Output: height of balloon

// Tangent lookup (scaled x10000)
:T a! a 40=( 8391)/E( a 70=( 27475)/E( 1)) ;

// Main calculation
:B b! a! d! a T t! b T u! 10000 10000* t/ 10000 10000* u/+ s! d 10000* s/ h! `Height: ` h. ` km`/N ;

// Demo: 2km distance, 40deg and 70deg angles
:D 2 40 70 B ;
