; ═══════════════════════════════════════════════════════════════════════
; TEC-1 ROM10 MODIFICATION: ENABLE :Z INTERRUPT HANDLER
; ═══════════════════════════════════════════════════════════════════════
; Based on analysis of TEC-1ROM10_z80.lst
;
; DISCOVERY: The infrastructure for :Z is ALREADY IN THE ROM!
; - ISR routine exists at 008Bh
; - It loads "Z" and calls ENTER to execute the MINT function Z
; - RST 38h (IM 1 interrupt vector) just does RET (line 170)
; 
; ALL WE NEED: Change RET to JP ISR at address 0038h!
; ═══════════════════════════════════════════════════════════════════════

; ───────────────────────────────────────────────────────────────────────
; CURRENT STATE (BROKEN)
; ───────────────────────────────────────────────────────────────────────
; Address  Hex    Assembly         Comment
; ───────────────────────────────────────────────────────────────────────
; 0038h    C9     RET              ← Interrupts do nothing!
; 0039h    --     (unused)
;
; WHY IT'S BROKEN:
; When a hardware interrupt occurs with IM 1:
; 1. CPU pushes PC onto stack
; 2. CPU jumps to 0038h
; 3. RET pops the return address and continues
; 4. :Z is NEVER called
;
; ───────────────────────────────────────────────────────────────────────
; SOLUTION 1: MINIMAL FIX (Recommended for IM 1)
; ───────────────────────────────────────────────────────────────────────
; Replace the RET at 0038h with JP to ISR
;
; Address  Hex       Assembly         Comment
; ───────────────────────────────────────────────────────────────────────
; 0038h    C3 8B 00  JP   008Bh      ← Jump to ISR routine
;
; This makes RST 38h behave like the other RST vectors (08h, 10h, etc.)

        .ORG    0038h
        JP      008Bh           ; Jump to ISR (was: RET)

; ───────────────────────────────────────────────────────────────────────
; WHAT THE ISR ROUTINE DOES (Already in ROM at 008Bh)
; ───────────────────────────────────────────────────────────────────────
; From TEC-1ROM10_z80.lst lines 474-479:
;
; 008B ISR:     
; 008B   LD    h,0              ; H = 0
; 008D   LD    (vIntID),hl      ; Store interrupt ID in vIntID (0C92h)
; 0090   CALL  enter            ; Call MINT interpreter
; 0093   .CSTR "Z"              ; Execute function :Z
; 0095   RET                    ; Return from interrupt
;
; The ISR:
; 1. Clears H (L is set by RST vector, for RST 38h it would be 7)
; 2. Stores interrupt ID in vIntID variable
; 3. Calls ENTER with "Z" string
; 4. ENTER looks up function Z in DEFS table (0C34h + 25*2 = 0C66h)
; 5. Executes the MINT code stored in :Z
; 6. Returns from interrupt (RETI would be better, see below)

; ───────────────────────────────────────────────────────────────────────
; SOLUTION 2: BETTER ISR WITH RETI (More compatible)
; ───────────────────────────────────────────────────────────────────────
; The current ISR uses RET instead of RETI
; For proper interrupt handling, especially with daisy-chain or nested
; interrupts, we should use RETI (Return from Interrupt)

        .ORG    0038h
        JP      ISR_IM1         ; Jump to new IM1 handler

ISR_IM1:
        PUSH    AF              ; Save all registers
        PUSH    BC
        PUSH    DE
        PUSH    HL
        EXX
        PUSH    BC              ; Save alternate registers
        PUSH    DE
        PUSH    HL
        EX      AF,AF'
        PUSH    AF
        
        LD      L,7             ; Interrupt ID = 7 for RST 38h
        LD      H,0
        LD      (vIntID),HL     ; Store ID at 0C92h
        
        ; Call MINT function Z
        LD      BC,Z_STR        ; Point to "Z" string
        CALL    ENTER           ; Execute :Z function
        
        POP     AF              ; Restore all registers
        EX      AF,AF'
        POP     HL
        POP     DE
        POP     BC
        EXX
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        
        EI                      ; Re-enable interrupts
        RETI                    ; Return from interrupt

Z_STR:  DB      'Z',0           ; Null-terminated string

vIntID  EQU     0C92h           ; Interrupt ID variable
ENTER   EQU     03BDh           ; MINT ENTER function

; ───────────────────────────────────────────────────────────────────────
; SOLUTION 3: USER-PATCHABLE VECTOR (Most flexible)
; ───────────────────────────────────────────────────────────────────────
; Use the INTVEC variable (0A14h) that's already in RAM
; This allows users to change the interrupt handler without re-burning ROM

        .ORG    0038h
        PUSH    HL              ; Save HL
        LD      HL,(INTVEC)     ; Load vector from RAM (0A14h)
        EX      (SP),HL         ; Swap HL with saved value on stack
        RET                     ; Jump to handler via RET

; Now users can change the interrupt handler in MINT:
; > #0500 INTVEC !    (set INTVEC to point to custom code at 0500h)
;
; Or call ISR by default:
; > #008B INTVEC !    (set INTVEC to point to ISR)

INTVEC  EQU     0A14h           ; Interrupt vector in RAM

; ───────────────────────────────────────────────────────────────────────
; SOLUTION 4: IM 2 MODE (Most powerful, requires hardware setup)
; ───────────────────────────────────────────────────────────────────────
; IM 2 allows a 256-entry vector table for different interrupt sources
; Requires setting I register and having a vector table in RAM

        .ORG    0038h
        RETI                    ; IM 1 handler - just return

INIT_IM2:
        DI                      ; Disable interrupts during setup
        
        ; Set up IM 2 vector table
        LD      A,HIGH(IM2_TABLE)
        LD      I,A             ; I register = high byte of table
        
        ; Fill table with ISR address
        LD      HL,IM2_TABLE
        LD      DE,IM2_TABLE+1
        LD      BC,255
        LD      (HL),LOW(ISR_IM2)
        LDIR                    ; Fill low bytes
        
        LD      HL,IM2_TABLE+256
        LD      DE,IM2_TABLE+257
        LD      BC,255
        LD      (HL),HIGH(ISR_IM2)
        LDIR                    ; Fill high bytes
        
        IM      2               ; Enable IM 2 mode
        EI                      ; Re-enable interrupts
        RET

IM2_TABLE:
        .ORG    0B00h           ; Must be on 256-byte boundary
        DS      512             ; 256 vectors * 2 bytes each

ISR_IM2:
        ; Similar to ISR_IM1 but can determine source
        ; by checking which vector was used
        PUSH    AF
        ; ... rest of handler
        RETI

; ───────────────────────────────────────────────────────────────────────
; ROM MODIFICATION BYTES
; ───────────────────────────────────────────────────────────────────────
; For EPROM programmers, here are the exact bytes to change:

; SOLUTION 1 (Simplest - 3 bytes):
; Address  Old    New    Description
; ────────────────────────────────────────────────────────────────────────
; 0038h    C9     C3     Change RET to JP
; 0039h    ??     8B     Jump address low byte (ISR)
; 003Ah    ??     00     Jump address high byte (ISR)

; SOLUTION 3 (Flexible - 6 bytes):
; Address  Old    New    Description
; ────────────────────────────────────────────────────────────────────────
; 0038h    C9     E5     PUSH HL
; 0039h    ??     2A     LD HL,(nn) - opcode
; 003Ah    ??     14     Address low byte (INTVEC)
; 003Bh    ??     0A     Address high byte (INTVEC)
; 003Ch    ??     E3     EX (SP),HL
; 003Dh    ??     C9     RET

; ───────────────────────────────────────────────────────────────────────
; HOW TO USE AFTER MODIFICATION
; ───────────────────────────────────────────────────────────────────────

; 1. Define your interrupt handler in MINT:
;    > :Z 3 /I 1 ^ 3 /O ;
;    This toggles bit 0 of port 3 on every interrupt

; 2. Generate interrupts:
;    - Connect hardware to INT pin (active low)
;    - Use 6850 ACIA with RIE bit set for serial interrupts
;    - Use timer/counter chip like Z80 CTC
;    - Use NMI button (already works, goes to RST 66h)

; 3. Enable interrupts:
;    System already runs: IM 1 ; EI at startup (line 508-509)

; 4. Test with software interrupt (RST instruction):
;    You can't directly execute RST 38h from MINT, but you can
;    test other RST vectors that already work:
;    > 8 /X    (if /X was implemented, calls RST 08h)

; ───────────────────────────────────────────────────────────────────────
; MEMORY MAP REFERENCE
; ───────────────────────────────────────────────────────────────────────
; Address  Size   Description
; ────────────────────────────────────────────────────────────────────────
; 0000h    8      RST 00h - Reset vector (JP RESET)
; 0008h    5      RST 08h - Software interrupt 1 (JP ISR)
; 0010h    5      RST 10h - Software interrupt 2 (JP ISR)
; 0018h    5      RST 18h - Software interrupt 3 (JP ISR)
; 0020h    5      RST 20h - Software interrupt 4 (JP ISR)
; 0028h    5      RST 28h - Software interrupt 5 (JP ISR)
; 0030h    5      RST 30h - Software interrupt 6 (JP ISR)
; 0038h    1      RST 38h - Hardware interrupt (RET) ← FIX THIS!
; 0066h    5      NMI - Non-maskable interrupt (JP ISR)
; 008Bh    11     ISR - Interrupt service routine
; 03BDh    --     ENTER - MINT code executor
;
; 0800h    --     RAM START
; 0A06h    2      RST08 vector (RAM)
; 0A08h    2      RST10 vector (RAM)
; 0A0Ah    2      RST18 vector (RAM)
; 0A0Ch    2      RST20 vector (RAM)
; 0A0Eh    2      RST28 vector (RAM)
; 0A10h    2      RST30 vector (RAM)
; 0A14h    2      INTVEC - Interrupt vector (RAM)
; 0A16h    2      NMIVEC - NMI vector (RAM)
;
; 0C00h    52     VARS - Variables a-z (2 bytes each)
; 0C34h    52     DEFS - Function definitions A-Z (2 bytes each)
; 0C68h    --     ALTVARS - System variables
; 0C72h    2      vIntFunc - Interrupt function pointer
; 0C76h    2      vHeapPtr - Heap pointer
; 0C92h    2      vIntID - Interrupt ID
; 0CA0h    --     HEAP - Dynamic memory

; ───────────────────────────────────────────────────────────────────────
; TESTING PROCEDURE
; ───────────────────────────────────────────────────────────────────────

; 1. Modify ROM at 0038h using one of the solutions above
; 2. Burn new ROM or patch RAM if using RAM overlay
; 3. Boot TEC-1
; 4. Define a test interrupt handler:

;    MINT Code:
;    > 0 a !
;    > :Z a 1 + a ! ;
;    > 
;    (This increments variable 'a' on each interrupt)

; 5. Generate test interrupt:
;    - Ground INT pin briefly
;    - Or set up ACIA for receive interrupt:
;      > #03 #80 /O    (master reset)
;      > #92 #80 /O    (8N2, /64, RIE enabled)
;      (Now every received character triggers interrupt)

; 6. Check if it worked:
;    > a .
;    (Should show incremented count)

; ───────────────────────────────────────────────────────────────────────
; IMPORTANT NOTES
; ───────────────────────────────────────────────────────────────────────

; 1. KEEP :Z SHORT AND FAST
;    - Interrupt handlers should execute quickly
;    - Don't use loops or delays in :Z
;    - Don't print lots of text (fills buffer)
;    - Save data to variables, process later in main code

; 2. REENTRANCY
;    - If :Z calls other MINT functions, they must be reentrant
;    - The MINT stack is shared between main code and :Z
;    - Don't nest interrupts unless you know what you're doing

; 3. REGISTER PRESERVATION
;    - The ISR saves L and H
;    - ENTER and MINT operators preserve most registers
;    - But be careful with BC (instruction pointer)

; 4. INTERRUPT FREQUENCY
;    - At 4MHz Z80, can handle ~50,000 interrupts/sec
;    - But MINT is slower than assembly
;    - Keep interrupt rate reasonable (< 1000/sec for MINT)

; 5. 6850 ACIA INTERRUPTS
;    - RDR must be read to clear interrupt
;    - Or disable receive interrupt in control register
;    - Transmit interrupts also possible with RTSLIE

; 6. DEBUGGING
;    - Use DI to disable interrupts if system hangs
;    - Check that :Z is actually defined
;    - Monitor with oscilloscope on port 3 bit 0

; ───────────────────────────────────────────────────────────────────────
; EXAMPLE: COMPLETE INTERRUPT-DRIVEN SERIAL ECHO
; ───────────────────────────────────────────────────────────────────────

; Initialize serial port with interrupts
INIT_SERIAL:
        LD      A,03h           ; Master reset
        OUT     (80h),A
        LD      A,92h           ; 8N2, /64, RIE enabled
        OUT     (80h),A
        RET

; MINT interrupt handler - echo received character
; > :Z #81 /I #81 /O ;
;
; This reads from RDR (port 81h) and writes to TDR (port 81h)
; Every received character is immediately echoed back

; ═══════════════════════════════════════════════════════════════════════
; END OF MODIFICATION GUIDE
; ═══════════════════════════════════════════════════════════════════════
