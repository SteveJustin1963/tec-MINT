# tec-MINT

# WARNING 
THIS IS A PROFOUND STEP FORWARD IN SOFTWARE DEVELOPMENT FOR THE TEC-1. 
NOW IT'S POSSIBLE TO RAPIDLY PROTOTYPE CODE that works first time by EVERYONE!

- https://github.com/orgMINT                Code and howtos updated here ...Thee Source!
- https://github.com/monsonite/MINT         howtos added here as well
- https://www.facebook.com/groups/623556744820045/search/?q=mint   Search 
- https://docs.google.com/spreadsheets/d/1uoJT1DG8Mu-oMqlK1f7USof6CF3R0vvWduXqJm4WmjY/

MINT is a small forth like system for the tec-1 and other SBC or MCU.

## Glory to...
In no order, John Hardy, Ken Boak, Craig Jones and Craig Hart-RIP and maybe more folk have made a big breakthrough, read the announcement ...
https://www.facebook.com/groups/tec1z80/posts/1250512652124448/ 

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/263565308_1147844542415783_7150078760328965579_n.jpg)

### Videos
- https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/video-1638969598.mp4
- https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/video-1639658972.mp4
- https://www.youtube.com/watch?v=m66y6C54Cds  transcript in wiki



### Now, my attempt to run v1.1

- you can erase and reprogram a standard EPROM
- however CJ sent me a blank EEPROM chip to load the code, its a AT28C64B. It electricaly erased and faster to use. 
- roll a 1.1 see below from CJ
- it will hang over the tec1d socket by 2 pins each side. need to fix this.
- so need to extend the 24 pin socket out to 28 pins, its good the pinout is identical except for A12 and VCC, an easy mod
- see this https://github.com/SteveJustin1963/tec-MINT/blob/main/docs/MemoryDevices01.pdf
 
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/ee%20pins2.png)

- cut off a 2x2 off a wide socket bend the pins out and epoxy to the end of the 24 sock, attach wires
- this extends the socket to 28. one pin will touch the wire bridge, so unsolder it and just solder it to pad landing, dont let the wire poke thru and touch the socket pin.
- solder another wire from vcc on lhs so rom select switch 5v.

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8433.jpg)

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/sock1.png)

- download Tera Term https://ttssh2.osdn.jp/ because it has a variable baud rate, helps with fault find
- plug in a USB to TTL serial cable, 5v is close enough for rs232, that has the embedded chip for the conversion, usually have 4 wires, tx-green rx-white gnd-blk 5v-red
- plug it in PnP will load a driver and allocate a com port, find in device manager, ull get like com12, do a loop back test short tx-rx, should echo char in teraterm
- now without a dedicated serial port chip, mint can do bitbang, compile and get code that supports it, default is 4800, so ull need the 4mhx chip in the clock
- also need to make a cct mod see CJ's mod in https://github.com/SteveJustin1963/tec-BIT-BANG

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

### roll a 1.1
CJ; "To build a new Mint for the TEC-1 you need all the files from orgMINT/MINT-builds/TEC-1_Build.
Overwrite the existing MINT.asm, MINT-macros.asm and ram.asm with your new versions. 
Compile the file TEC-1-ROM-B.z80. "

BUT its not complete. We need to combines parts from CJ with JH so we get a .bin that has bit bang or code for serial chip. JH updates only in https://github.com/orgMINT/MINT (no where else- this is THE source) files like MINT.asm and test.RUN.z80. 




## Iterate
- MINT monitor
- talk to all standard HW addons
- build new projects
- MINT compiler
- new vers of MINT or Forth etc
  - https://github.com/jhlagado/www.colorforth.com
  - https://github.com/jhlagado/firth
  - https://github.com/jhlagado/siena
  - https://github.com/jhlagado/menta
  - https://github.com/jhlagado/minto
  - https://github.com/jhlagado/sectorforth
  - https://github.com/jhlagado/zedforth
  - https://github.com/jhlagado/MINTY
  - https://github.com/jhlagado/monty
  - https://github.com/jhlagado/Mindy
  -  
- 

## Ref
- https://github.com/monsonite/MINT
- https://github.com/monsonite/MINT-Documentation
- https://github.com/tec1group/MINT-cookbook
- chat https://github.com/SteveJustin1963/tec-MINT/wiki
- Help file https://docs.google.com/spreadsheets/d/1uoJT1DG8Mu-oMqlK1f7USof6CF3R0vvWduXqJm4WmjY/edit#gid=0
 
