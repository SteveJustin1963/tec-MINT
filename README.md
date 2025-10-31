 


<img width="555" height="555" alt="image" src="https://github.com/user-attachments/assets/404baeeb-6ae2-4975-b781-face3bb329e7" />


 
**The structuring or acknowledgment of the individuals involved
in the development of the MINT interpreter
follows no discernible hierarchy or prioritization of recognition,
implying that their contributions are regarded in a manner
devoid of any preordained or systematic reverence.
This lack of sequentiality reflects an egalitarian or arbitrary approach,
wherein no specific developer is elevated above another
in terms of the order of respect or recognition for their work.** 


<img width="365" height="610" alt="image" src="https://github.com/user-attachments/assets/87a01b68-8479-4382-b8f3-4e41999ef39d" />


# Announcements
  - https://www.facebook.com/groups/tec1z80/posts/1250512652124448/ 
  - https://github.com/SteveJustin1963/tec-MINT/blob/main/docs/history.md

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/263565308_1147844542415783_7150078760328965579_n.jpg)

# Videos
- https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/video-1638969598.mp4
- https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/video-1639658972.mp4
- https://www.youtube.com/watch?v=m66y6C54Cds **Alright, buckle up buttercup, because we're about to embark on a cinematic quest longer than a toddler's nap after a sugar rush!  WARNING - 3 1/2 HOURS !**


# MINTing your NUTS


 
**Ah, right then, gather 'round, ye code-crunching wizards! You must read my excessively scribbled-upon, over-explained, and possibly bewildering edition of the "[MINT2 Manual](https://github.com/user-attachments/assets/404baeeb-6ae2-4975-b781-face3bb329e7)", now with 67% more footnotes and unnecessary asides. When done reading, try and code some wild and mysterious code fragments then give em a good ol smoke test and modify on the fly— which, in this case, may or may not be assisted by some questionable items of dubious legality. As the test hacking progresses, you’ll inevitably amass a sizeable collection of code nuts — so be sure they’re good and crispy! Next, tie up those nuts but not too tightly into neat function bundles labeled with :A....: , :B....; and so on, until all your nuts are firmly in place so not one dares to escape from use. And now for the Pièce de Résistance: take a deep breath, fling your functions around like a fish monger upon their glorious unification shouting with confidence, “This piece of halibut is good enough for Jehovah!” and Voilà! You've now written and used MINT code for intergalactic conquest. Otherwise if yout nuts are sore use some POLA.** 


![image](https://github.com/user-attachments/assets/76699c73-d350-4f52-a544-398e5a6214a2)




# Reality
You can run small programs in 2k but for real halibut you need to max out your ram physically (see below), the tec-1d can take 2k x 7 chips (14k) or if using the asm80.com emulation of the code, max out the ram in file `constants.asm` aka... for then non-puritans there's the fully sic tec1-G.

```
; Configuration for TEC-1
LOADER EQU 0
BITBANG EQU 0
        
ROMSTART    EQU $0000
RAMSTART    EQU $0800
ROMSIZE     EQU $0800
RAMSIZE     EQU $4000   ;this is 14k of ram (like a real tec1-D maxed out), asm80 can take it bigger
```

This also may help if your nuts are too big, by changing `ram.ram` to show `TIBSIZE EQU $800 ` on both tec-1 or asm80 so you can enter huge nuts of code per line.  The text input buffer is where the code lives and is also used again to display code with ctrl-L. For asm80 use my nifty upload code tool called `autotyper.py` tool, and its a dog so it will rip out comments it does not like. Last but always least, if your old Millennium Falcon needs more than 12 parsecs to make the Kessel Run ( whatever) then adjust the 3 delays in the `.py` code; make it longer, say ah 0.2 but not much more case it bores you to tears if too large. last ...use the force Luke so Yoda can access your c:\path\mint-code   :-)

# Down to business...
- Its a small fast [Forth](https://en.wikipedia.org/wiki/Forth_(programming_language)) like system meant especially for the TEC-1 prototype and its lesser cunning monkeys- rev A B C D (E F ?) G and SCC and if all fails for gods sake please use the Micocomp-1 whilst placed under a chair leg. 
- Incredible 400,000 commands /sec (4Mhz clock) or one order of power slower than your clock speed
- running your code in asm80 (16 Mhz clock) gets you around 1,600,000 parsecs or 4000 shekels +- 6 sigma there abouts on a sunny afternoon around 3:23pm
- Allows rapid prototyping of code, easy concatenation, no compiling, runs instantly, test as you build
- When you get an undetected error, reward yourself with a punch to the n@@ts
- [THE SOURCE CODE](https://github.com/orgMINT/MINT)
- https://github.com/tec1group/MINT-cookbook ver1 stuff
- [monsonite site](https://github.com/monsonite/MINT)
- [FB Search](https://www.facebook.com/groups/623556744820045/search/?q=mint)
- [spreadsheet help files](https://docs.google.com/spreadsheets/d/1uoJT1DG8Mu-oMqlK1f7USof6CF3R0vvWduXqJm4WmjY/)
- [Code to keep punching...](https://github.com/SteveJustin1963/tec-MINT/tree/main/code) and all over my github
- my ongoing updated [SJ Manual Mint V2.md](https://github.com/SteveJustin1963/tec-MINT/blob/main/SJ%20Manual%20Mint%20V2.md)
- my ongoing autopsy analysis [and extraction](https://github.com/SteveJustin1963/tec-MINT/wiki) 




# My attempt to run v1.1, first go

- using an EEPROM; AT28C64B.  https://github.com/SteveJustin1963/eeprom-programmer/wiki/eeprom
- compile v1.1, set flags as needed
- mod the socket, install eeprom, hangs over the existing rom socket by 2 pins each side. make the mod
- result; turn a 24 pin socket into 28 pins, lucky the pinout is identical except for A12 and VCC
- see this https://github.com/SteveJustin1963/tec-MINT/blob/main/docs/MemoryDevices01.pdf
 
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/ee%20pins2.png)

- cut off a 2x2 off a wide socket bend the pins out and epoxy to the end of the 24 sock, attach wires
- make a bigger socket to 28 pins
- one pin will touch the wire bridge, so unsolder it and just solder it to pad landing, dont let the wire poke thru and touch the socket pin.
- solder another wire from vcc on lhs so rom select switch 5v.

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8433.jpg)

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/sock1.png)

- Terminal on PC; TeraTerm at https://ttssh2.osdn.jp/
  - has variable baud rates, helps to find timing faults
- USB to TTL serial cable, TTl 5v is close enough for rs232
  - has embedded chip for usb to ttl 
  - 4 wires, tx-green rx-white gnd-blk 5v-red
- the pc will load PnP driver and allocate a com port
  - find in device manager
  - Teraterm will list it so select it
  - do a loop back test, short tx-rx, should echo char in terminal screen
- as we opted without a uart we can use serial bitbang
  - compile and get code that supports it, default is 4800
  - need 4mhz clock
- add cct mod for serial line off data bus,  https://github.com/SteveJustin1963/tec-BIT-BANG
![tec1-schematic](https://github.com/user-attachments/assets/d316e4da-a300-4390-832a-6fd06e389e6e)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8455.jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8483%20(1).jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8484%20(1).jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8485%20(1).jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8486%20(1).jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8487%20(1).jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8488%20(1).jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8467.jpg)
![]()

# Build v 1.1
- set correct flags for the build and then compile and then burn the rom. this will combine bitbang with MINT
- “it finally works"!  

# Ver 2 getting respectable
- new release, see my updated ver 2 manual 
- John still fixing bugs  [bugs](https://github.com/orgMINT/MINT/issues)
- my 2k cannot handle big halibut, i should move to 4k or more, or the mighty G ? 
- I wish to add SPI cct .. see [tec-SCOPE ](https://github.com/SteveJustin1963/tec-SCOPE)
- need to test /int calls :Z function
- need a larger variable and function set, increased to 2 characters would be a good start

# Ver 3 2025 maybe 
- adapted from JH's comments
- maintain the classic 1D, hell yes!
- add with modification the last two high address to get 6k more out of eeprom
- ![image](https://github.com/user-attachments/assets/9d753110-e74e-45b1-a050-2187cc91c0a7)
- ![image](https://github.com/user-attachments/assets/36d45b5b-a19b-4acb-93f1-78bcea778814)
- arrays and strings are handled the same way, never directly stored on the stack, uses heap space (grows with ram)
- need examples of calculations when doing floating point and/or matrices...even the most basic floating point number could be considered an array with one element in it.
- consider ideas from APL style languages, next MINT will be https://github.com/SteveJustin1963/Tec-TACIT
- add SPI master
- enhance /INT :F
- enhance ASM calls and return
- the Big halibut **Will do 32-bit floating point signed number!** 
- btw, FP always goes into a VAR, and if its put on the stack, only the pointer is stored there

```
The range depends on the allocation of bits for the sign, exponent, and mantissa. Following the typical IEEE 754 format:
1 bit for the sign
8 bits for the exponent (bias of 127)
23 bits for the mantissa (plus an implicit leading 1 for normalized numbers)
```
- the stack is only for 16-bit integers and pointers, then mint doesn't need to change very much and you could have larger than 32-bit floating point numbers.

# FP range is:

![image](https://github.com/user-attachments/assets/4f85de62-eb23-4f8c-94b9-0629619b52d6)

- https://en.wikipedia.org/wiki/IEEE_754


# playing with 7 seg display
- aug 2025
- https://github.com/SteveJustin1963/tec-MINT/blob/main/code/8-LED-light-chaser.md
- https://github.com/tec1group/MINT-cookbook/tree/main/misc/4-digit-counter
- crashes all the time!

 
# Training wheels, MINT in Octave
 ready!


![image](https://github.com/user-attachments/assets/e15ac155-4a9c-48a9-a4c3-31413bce2aa3)
