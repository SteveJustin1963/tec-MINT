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

### My attaempt to run v1.1
- cj sent me a EEPROM chip to load the code, its a AT28C64B. it will hang over the tec1d socket by 2 pins each side.
- need to make an adapter board to fix this. as can run a 28 pin in 24 pin rom socket
- see this https://github.com/SteveJustin1963/tec-MINT/blob/main/docs/MemoryDevices01.pdf

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/ee%20pins2.png)

- so i extend the socket 4 pins and glue to end of existing socket. relocate jumper wire on right by removing and running long wire to the 74138 that way the bent leg of the socket does not touch it.
- solder another wire from vcc on lhs so rom select switch 5v.

![](https://github.com/SteveJustin1963/tec-MINT/blob/main/pics/sock1.png)

- downlad Tera Term https://ttssh2.osdn.jp/ because it has a variable baud rate, helps with fault find
- plug in a USB to TTL serial cable, 5v is close enough for rs232, that has the embedded chip for the conversion, usualy have 4 wires, tx-green rx-white gnd-blk 5v-red
- 


## Ref
- https://github.com/monsonite/MINT
- https://github.com/monsonite/MINT-Documentation
- https://github.com/tec1group/MINT-cookbook
- chat https://github.com/SteveJustin1963/tec-MINT/wiki
