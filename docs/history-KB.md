MINT - History and Future
Inbox

Ken Boak <ken.boak@gmail.com>
Sun, Sep 29, 6:16 PM (16 hours ago)
to me

Hi Steve,

I am one of the three developers who originally created MINT during the lockdowns of 2021. I am London based whilst John and Craig are, like yourself, part of the TEC-1 community mostly based in Australia.

I have noticed that you are very active with MINT, and are kicking the wheels and trying it out for practical applications. I am very impressed with your telescope project.

Historical Notes......

I met John Hardy through an online Forth Group, and I pitched my idea of a minimal Forth-like language. John had already been working on a Forth for the Z80, so he had experience of a lot of the code for the primitives.

I introduced him to the idea of the bytecode interpreter, as a means of reducing the amount of code found in a typical Forth implementation. From 6K to 2K.

One of the earliest examples that I can find of a bytecode interpreter is MUSYS, written for the PDP-8 as a means of scripting electronic music and controlling early analogue synthesisers from a PDP-8 minicomputer. This was back in 1969 and is a contemporary of Chares Moore's Forth (1968) but there was no documentation on Forth until at least 1971.

Peter Drogono, who wrote MUSYS for EMS (Electronic Music Studios) later adapted it into a programming language called MOUSE, which also runs on the Z80.

MOUSE is very similar to MINT - and achieves the same goals, but MINT is a cleanroom development, with no code being copied from MOUSE.

I came across bytecode interpreters from a project by Ward Cunningham, from back in 2011. He wanted an easy way to interact with an Arduino.  He created Textzyme, which is a bytecode interpreter written in C and aimed at Arduino compatible boards. It had 13 commands, but no math or nested subroutines.

I took Textzyme and added math routines and Forth-like dictionary definitions.  It was written in C and I called it SIMPL - Serial Interpreted Minimal Programming Language. I ported it to several systems, and wrote a version of it to run on a 16-bit MSP430 mcu.

In April of 2020, during the lockdown, I founded "Minimalist Computing" on FB and John Hardy was one of the first members.

We also had a Hungarian founder Sandor - who had created a bytecode interpreter in 49 lines of extremely dense C code.

So MINT pulled together all of these influences and during the (UK) Autumn of 2020, John, Craig Jones and I created MINT.

John was principal architect supplying structure and nested subroutine handling, Craig assisted with porting it to the bit-banging serial of the TEC-1, and I supplied some of the instruction dispatch structure and the maths routines.

Regarding the future - that will be the topic for a follow up email.

regards,

Ken
