John Hardy

INTRODUCING MINT - A PROGRAMMING LANGUAGE FOR THE TEC-1
As most of you know the TEC-1 was designed by Ken Stone and myself over the summer of 1982-83 and published in the February 1983 issue of Talking Electronics magazine. This design was the culmination of a few years of experimentation which began in the late 1970s and passed through a prototype stage (the "Onion" computer). It was strongly influenced by the computers of the time, computer training boards such as the Microprofessor and of course the then dominant Sinclair range of entry level computers.

The published TEC-1 kit was the entry point into digital hardware and computing for a large number of people. Many people attribute the TEC-1 as having influenced the trajectory of their careers. This is very gratifying. Personally, the TEC-1 was where I first cut my teeth as a software engineer and I am personally happy that people still remember this little computer design and continue to tinker with it.

That said, the TEC-1 was never an easy machine to program unlike other machines such as its contemporary, the ZX81, which came with an easy to use BASIC programming language ROM. Interpreted BASIC for all its faults enabled people to code reasonably simply and to even control hardware. It was never fast though, in fact it was very slow when compared to native machine code. It always seemed odd to me that there was no in between: you either programmed in machine code and used the full speed of the CPU or you programmed in BASIC and lost two orders of magnitude in performance but gained a little bit of a higher level perspective.

There have always been lesser known alternatives such as Chuck Moore's Forth programming language and I've wondered for a long time whether Forth would be a viable language for programming the TEC-1. Over the past two years I've thrown myself into and developed a reasonable level of expertise in Forth.
For the last 3 months I've be collaborating with Ken Boak and Craig Jones to bring a minimalist programming language called "MINT" to the TEC-1. MINT is not a pure Forth but is modelled very closely on Forth. Even a small Forth has a minimal kernel of around 5K on the Z80 but the basic configuration of the TEC-1 comes with a 2K ROM, just enough for a monitor program. What else can be done in such a small space?

Ken Boak wrote the initial version of MINT back in July this year and then I got involved and have worked closely with him to add many of the Forth capabilities that I thought that the first version of MINT lacked. Craig Jones wrote the serial drivers which work with both bit-banged and 6850 driven hardware. He also added code to enable users to load Intel hex files into the TEC-1 RAM to extend Mint's capabilities.

I think that MINT is a nice compromise between writing machine code and using BASIC. It's interpreted like BASIC but it uses a much more efficient byte code virtual machine which allows MINT run at a decent speed. We still need to write detailed benchmarks to make a fair comparison but my current feeling is that MINT is an order of magnitude slower than machine code and an order of magnitude faster than BASIC. It is interactive in a similar way to BASIC or Python but quite a bit faster than both. It also runs in considerably less memory and I think it's ideal for prototyping, exercising hardware, controlling ports. It would be excellent for "bringing up" new hardware and we currently looking around at other CPUs and computing systems to port to.

We are launching MINT first for the TEC-1 as an exclusive first look. Our goal has been to release MINT before Christmas and we've just met that goal. Expect more posts on MINT in the coming weeks. Posts on how to get it running on your TEC-1, how to program in MINT ands also because the TEC-1 Z80 Computer Group is all about developing a low level understanding of how things work, a series of posts on the internals of MINT and how it does what it does.
The MINT repo with the TEC-1 ROM and other builds can be found here:

https://github.com/orgMINT/
https://github.com/orgMINT/MINT-Documentation

The documentation, which is still a work in progress, please read the README.
Below you can see a video of Craig Jones running a MINT program on the TEC-1F


///////////

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
///////////
