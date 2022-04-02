# tec-MINT
- https://github.com/orgMINT                The source 
- https://github.com/monsonite/MINT         Depreciated
- https://www.facebook.com/groups/tec1z80   Search 


THIS IS A PRFOUND STEP FORWARD IN SOFTWARE DEVELOPMENT FOR THE TEC1. 
NOW ITS POSSIBLE TO RAPIDY PROTOTYPE CODE that works first time by EVERYONE!



A small forth like system for the tec-1 and other sbc.

In no order, John Hardy, Ken Boak, Craig Jones and Craig Hart and maybe more folk have made a big breakthrough, read the announcement ...

https://www.facebook.com/groups/tec1z80/posts/1250512652124448/ 

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/263565308_1147844542415783_7150078760328965579_n.jpg)

### Videos
- https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/video-1638969598.mp4
- https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/video-1639658972.mp4
- https://www.youtube.com/watch?v=m66y6C54Cds

### My attempt to run v1.1
- cj sent me a blank EEPROM chip to load the code, its a AT28C64B. it will hang over the tec1d socket by 2 pins each side.
- need to extend the 24 pin socket to 28 as pinout identical except for A12 and VCC, an easy mod
- see this https://github.com/SteveJustin1963/tec-MINT/blob/main/docs/MemoryDevices01.pdf
 
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/ee%20pins2.png)

- cut off a 2x2 off a wide socket bend the pins out and epoxy to the end of the 24 sock, attach wires
- this extends the socket to 28. under relocate jumper wire on right as it touches the bent socket pin, run wire to the 74138.
- solder another wire from vcc on lhs so rom select switch 5v.

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8433.jpg)

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/sock1.png)

- download Tera Term https://ttssh2.osdn.jp/ because it has a variable baud rate, helps with fault find
- plug in a USB to TTL serial cable, 5v is close enough for rs232, that has the embedded chip for the conversion, usually have 4 wires, tx-green rx-white gnd-blk 5v-red
- plug it in PnP will load a driver and allocate a com port, find in device manager, ull get like com12, do a loop back test short tx-rx, should echo char in teraterm
- now without a dedicated serial port chip, mint can do bitbang, compile and get code that supports it, default is 4800, so ull need the 4mhx chip in the clock
- also need to make a cct mod see CJ's mod in https://github.com/SteveJustin1963/tec-BIT-BANG

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8455.jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8456.jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8457.jpg)
![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/IMG_8458.jpg)
![]()
![]()



## Ref
- https://github.com/monsonite/MINT
- https://github.com/monsonite/MINT-Documentation
- https://github.com/tec1group/MINT-cookbook
- chat https://github.com/SteveJustin1963/tec-MINT/wiki
