# MINT coding, punch yourself in the nuts!

![image](https://github.com/user-attachments/assets/2dedb642-9c9e-4c19-9cf5-f6345052792c)



![image](https://github.com/user-attachments/assets/76699c73-d350-4f52-a544-398e5a6214a2)
![image](https://github.com/user-attachments/assets/e15ac155-4a9c-48a9-a4c3-31413bce2aa3)


- A small and fast forth like system for the TEC-1 and SCC, and others
- 400,000 commands /sec (4Mhz clock)
- Rapid prototyping of code
- Never works as expected until it does 

- [https://github.com/orgMINT  ](https://github.com/orgMINT/MINT)       ..THE SOURCE ! 

  
- https://github.com/monsonite/MINT 
- https://www.facebook.com/groups/623556744820045/search/?q=mint   Search 
- https://docs.google.com/spreadsheets/d/1uoJT1DG8Mu-oMqlK1f7USof6CF3R0vvWduXqJm4WmjY/
- https://github.com/SteveJustin1963/tec-MINT/tree/main/code WIP


## Honour Roll 
The structuring or acknowledgment of the individuals involved in the development of the code follows no discernible hierarchy or prioritization of recognition, implying that their contributions are regarded in a manner devoid of any preordained or systematic reverence. This lack of sequentiality reflects an egalitarian or arbitrary approach, wherein no specific developer is elevated above another in terms of the order of respect or recognition for their work.

- John Hardy
- Ken Boak
- Craig Jones
- Craig Hart-RIP
- Steve Justin - teeny weeny bit of almost nothing
- TEC-1 group - they love the smell of napalm in the morning

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

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8455.jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8483%20(1).jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8483%20(2).jpg)
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
- new release, see my updated readme
- need more ram, cannot load long programs, moving to 4k 
- adding SPI cct .. see [tec-SCOPE ](https://github.com/SteveJustin1963/tec-SCOPE)
- play with /int calls :Z function
- need a larger variable and function set, name length needs to be increased to 2 characters
- John please fix all bugs! https://github.com/orgMINT/MINT/issues

## ver 3
- maintain the classic 1D
- mod in the last two high address for more rom from the 32k eeprom
- ![image](https://github.com/user-attachments/assets/36d45b5b-a19b-4acb-93f1-78bcea778814)

- arrays and strings are handled the same way, never directly stored on the stack. 
- need examples of calculations when doing floating point and/or matrices...even the most basic floating point number could be considered an array with one element in it.
- consider ideas from APL style languages
- add SPI master
- enhance /INT :F
- enhance ASM calls and return
- add 48-bit floating point (FP) for now
- FP always goes into a VAR, and if its put on the stack, only the pointer is stored there
- the stack is only for 16-bit integers and pointers, then mint doesn't need to change very much and you could have larger than 32-bit floating point numbers.

For a 48-bit floating-point signed number, the range depends on how the bits are allocated for the sign, exponent, and mantissa. In typical floating-point formats, the structure is as follows:

- **1 bit** for the sign
- **Exponent bits** (usually defined in relation to the format, which affects the range)
- **Mantissa bits** (precision)

Assuming a similar structure to IEEE formats, if we allocate bits as follows:

1. **1 bit** for the sign
2. **11 bits** for the exponent (bias of 1023)
3. **36 bits** for the mantissa

The approximate range would be:

- **Smallest positive (normalized) number:** \( 2^{-1022} \approx 2.23 \times 10^{-308} \)
- **Largest positive number:** \( (2 - 2^{-36}) \times 2^{1023} \approx 1.79 \times 10^{308} \)

 




This range is roughly similar to a 64-bit double-precision floating-point format, but with slightly less precision due to the shorter mantissa (36 bits instead of 52). However, without a standard like IEEE defining it, the exact range could vary depending on the chosen exponent and mantissa split.


 

![image](https://github.com/user-attachments/assets/c28e7498-5bc2-4928-b141-aae132415934)








