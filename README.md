# Punch yourself in the nuts with MINT coding !


![image](https://github.com/user-attachments/assets/76699c73-d350-4f52-a544-398e5a6214a2)
![image](https://github.com/user-attachments/assets/e15ac155-4a9c-48a9-a4c3-31413bce2aa3)




![image](https://github.com/user-attachments/assets/2dedb642-9c9e-4c19-9cf5-f6345052792c)

- A small and fast [Forth](https://en.wikipedia.org/wiki/Forth_(programming_language)) like system for the TEC-1 and SCC, and more 
- Incredible 400,000 commands /sec (4Mhz clock) or one order of power slower than your clock speed
- Allows rapid prototyping of code, easy concatenation, no compiling, runs instantly, test as you build
- It Never works as expected until it does! Bam!
- [THE SOURCE CODE](https://github.com/orgMINT/MINT)
- [monsonite site](https://github.com/monsonite/MINT)
- [{FB Search](https://www.facebook.com/groups/623556744820045/search/?q=mint)
- [spreadsheet help files](https://docs.google.com/spreadsheets/d/1uoJT1DG8Mu-oMqlK1f7USof6CF3R0vvWduXqJm4WmjY/)
- [Programs I suffer with may or may not work, punch!!](https://github.com/SteveJustin1963/tec-MINT/tree/main/code)


## Honour Roll 
The structuring or acknowledgment of the individuals involved in the development of the code follows no discernible hierarchy or prioritization of recognition, implying that their contributions are regarded in a manner devoid of any preordained or systematic reverence. This lack of sequentiality reflects an egalitarian or arbitrary approach, wherein no specific developer is elevated above another in terms of the order of respect or recognition for their work.

- John Hardy
- Ken Boak
- Craig Jones
- Craig Hart-RIP
- Steve Justin - post testing
- TEC-1 group - no idea

### Announcements
  - https://www.facebook.com/groups/tec1z80/posts/1250512652124448/ 
  - https://github.com/SteveJustin1963/tec-MINT/blob/main/docs/history.md

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/263565308_1147844542415783_7150078760328965579_n.jpg)

### Videos
- https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/video-1638969598.mp4
- https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/video-1639658972.mp4
- https://www.youtube.com/watch?v=m66y6C54Cds WARNING - 3 1/2 HR MOVIE LENGTH



### My attempt to run v1.1, first go

- using an EEPROM; AT28C64B.
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

### build v 1.1
- set correct flags for the build and then compile and then burn the rom. this will combine bitbang with MINT
- “it finally works!  

### ver 2
- new release, see my updated [manual](MEAT-EXTRACT.md)
- need more ram, cannot load long programs, moving to 4k 
- adding SPI cct .. see [tec-SCOPE ](https://github.com/SteveJustin1963/tec-SCOPE)
- play with /int calls :Z function
- need a larger variable and function set, name length needs to be increased to 2 characters
- John please fix all [bugs](https://github.com/orgMINT/MINT/issues)

## ver 3 (adapted and added to JH's comments)
- maintain the classic 1D
- add with modification the last two high address to get 6k more out of eeprom 
- ![image](https://github.com/user-attachments/assets/9d753110-e74e-45b1-a050-2187cc91c0a7)
- ![image](https://github.com/user-attachments/assets/36d45b5b-a19b-4acb-93f1-78bcea778814)

- arrays and strings are handled the same way, never directly stored on the stack, uses heap space (grows with ram)
- need examples of calculations when doing floating point and/or matrices...even the most basic floating point number could be considered an array with one element in it.
- consider ideas from APL style languages, next MINT will be https://github.com/SteveJustin1963/Tec-TACIT
- add SPI master
- enhance /INT :F
- enhance ASM calls and return
- add 32-bit floating point (FP) for now
- FP always goes into a VAR, and if its put on the stack, only the pointer is stored there
- the stack is only for 16-bit integers and pointers, then mint doesn't need to change very much and you could have larger than 32-bit floating point numbers.


For a **32-bit floating-point signed number**, the range depends on the allocation of bits for the sign, exponent, and mantissa. Following the typical IEEE 754 format:

- **1 bit** for the sign
- **8 bits** for the exponent (bias of 127)
- **23 bits** for the mantissa (plus an implicit leading 1 for normalized numbers)

The approximate range is:

![image](https://github.com/user-attachments/assets/4f85de62-eb23-4f8c-94b9-0629619b52d6)

https://en.wikipedia.org/wiki/IEEE_754



 


 
 

![image](https://github.com/user-attachments/assets/c28e7498-5bc2-4928-b141-aae132415934)








