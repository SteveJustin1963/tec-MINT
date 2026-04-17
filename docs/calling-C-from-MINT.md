# Calling Compiled C Code from MINT via `/X`

## Overview

MINT can execute raw Z80 machine code loaded anywhere in RAM using the `/X` command.
This means you can write functions in C, compile them for the Z80 using **SDCC**,
load the binary into TEC-1 RAM, and call those functions directly from MINT code.

---

## The `/X` Command

| Command | Stack effect | Description |
|---------|-------------|-------------|
| `/X`    | `addr --`   | Jump to machine code at `addr`, return when done |

**How it works internally** (`Stack_Fix/MAIN.asm:992`):

```asm
exec_:
    call exec1
    jp (iy)
exec1:
    pop hl
    EX (SP),hl
    jp (hl)         ; jump to address popped from Mint's stack
```

### Step-by-step walkthrough

**Background — the MINT interpreter loop:**

- `IY` is permanently pointed at `NEXT`, the fetch-decode-execute loop (set at line 279)
- `BC` is the **Instruction Pointer** — walks through MINT source text byte by byte
- `NEXT` reads `(BC)`, subtracts `'!'` to index into the jump table, and dispatches to the handler
- Every handler ends with `jp (iy)` — jump back to `NEXT` to fetch the next character
- MINT uses the **Z80 hardware stack (SP)** as its data stack

**When `/X` executes:**

1. `NEXT` dispatches to `exec_`
2. `call exec1` — Z80 pushes the address of `jp (iy)` onto SP and jumps to `exec1`
3. At this point SP looks like:
   ```
   SP   → [ address of "jp (iy)" ]   ← return address from the call
   SP+2 → [ user's machine-code address ]  ← value pushed before /X
   ```
4. `pop hl` — removes the return address into HL (discarded)
5. Now `SP` points at the user's address on the MINT data stack
6. `EX (SP),hl` — atomically swaps: loads the user's address into HL, puts the old HL value back on the stack (not needed)
7. `jp (hl)` — CPU jumps to your machine code

**Returning to MINT:**

When your machine code executes `RET`, it pops `SP` — which now holds the address of `jp (iy)` inside `exec_`. So control falls back into the MINT interpreter loop cleanly, as if `/X` had just finished normally.

It pops the address from the Mint data stack and jumps to it. When the machine
code executes a `RET`, control returns to the MINT interpreter.

**Basic usage:**

```
> #1800 /X          \ call code at RAM address $1800
```

> **Warning:** `/X` is implemented in `Stack_Fix/MAIN.asm` but is **not present**
> in the stock `TEC-1ROM10` binary. You must compile and burn the `Stack_Fix`
> version of MINT for `/X` to work.

---

## TEC-1 Memory Map (Stack_Fix build, 2K base config)

```
$0000 - $07FF   ROM  (MINT interpreter)
$0800 - $08FF   TIB  (text input buffer, 256 bytes)
$0900 - $097F   Return stack (128 bytes)
$0980 - $09FF   Data stack / DSTACK (128 bytes)
$0A00 - $0AFF   Opcodes / alt-codes table
$0B00 - $0BFF   Vars and defs (26 x 2 bytes each)
$0C00 - $0EFF   Alt-vars, heap pointer, system variables
$0F00 - $0FFF   Stack guard (do not write here)
$1000           CPUSTACK (Z80 hardware stack, grows down)
```

With a maxed-out TEC-1D (14K RAM) or asm80 emulation with larger RAM, free RAM
starts well above $1000. A safe load address for user machine code is **$1800**
or higher when using extended RAM.

---

## Tools Required

| Tool | Purpose | Install |
|------|---------|---------|
| **SDCC** | C compiler targeting Z80 | `sudo apt install sdcc` |
| **z80asm** or **nasm** | Write the asm bridge wrapper | `sudo apt install nasm` |
| **autotyper.py** | Upload binary/hex into TEC-1 via serial | included in this repo |
| **srec_cat** (optional) | Convert .ihx to raw binary | `sudo apt install srecord` |

---

## Step-by-Step Workflow

### Step 1 — Write freestanding C for Z80

C code for the TEC-1 must be **freestanding** — no standard library, no `printf`,
no `malloc`. Only logic and port I/O.

```c
/* multiply.c — freestanding Z80 C for MINT */

/* Pass args via fixed RAM locations, not the stack */
#define ARG_A  (*(int*)0x1900)
#define ARG_B  (*(int*)0x1902)
#define RESULT (*(int*)0x1904)

void run(void) {
    RESULT = ARG_A * ARG_B;
}
```

Using fixed RAM locations for arguments (rather than the Z80 stack) avoids
conflicts with MINT's internal CPU stack and is the simplest approach.

### Step 2 — Compile with SDCC

```bash
sdcc -mz80 --no-std-crt0 --code-loc 0x1800 --data-loc 0x1900 multiply.c
```

| Flag | Meaning |
|------|---------|
| `-mz80` | Target Z80 architecture |
| `--no-std-crt0` | No C runtime startup — we handle entry ourselves |
| `--code-loc 0x1800` | Place compiled code at this RAM address |
| `--data-loc 0x1900` | Place static data/variables here |

Convert to raw binary:

```bash
srec_cat multiply.ihx -Intel -o multiply.bin -Binary
```

Or use objcopy if you have the Z80 binutils:

```bash
objcopy -I ihex -O binary multiply.ihx multiply.bin
```

### Step 3 — Load the binary into TEC-1 RAM

Use `autotyper.py` or your serial terminal to upload `multiply.bin` starting
at address `$1800`. The exact upload method depends on your TEC-1 monitor ROM.

In asm80.com emulation, you can paste hex directly into the memory view at
address `$1800`.

### Step 4 — Call from MINT

```
\ store arguments into fixed RAM locations
6 #1900 !       \ ARG_A = 6  (store 6 at $1900)
7 #1902 !       \ ARG_B = 7  (store 7 at $1902)

\ call the C function
#1800 /X

\ read result back from fixed RAM
#1904 @  .      \ prints 42
```

---

## The Stack Mismatch Problem

MINT has **two separate stacks**:

| Stack | Type | Purpose |
|-------|------|---------|
| **DSTACK** (~$0980) | Software stack in RAM | MINT data values |
| **CPUSTACK** ($1000) | Z80 hardware SP | Return addresses, MINT internals |

SDCC's C calling convention passes arguments on the **Z80 hardware stack**.
MINT's numbers live on the **software DSTACK**. They do not overlap.

**This is why the fixed-RAM-address approach above is recommended** — it sidesteps
the stack mismatch entirely and works reliably without an assembly bridge.

### Optional: Assembly Bridge for Stack-Passed Arguments

If you want to pass values directly from MINT's data stack to a C function,
you need a small Z80 assembly shim. This is more complex and only worth doing
once you are comfortable with both environments.

```asm
; bridge.asm — copy top 2 MINT stack values into Z80 stack for SDCC
; MINT stack pointer is stored at the DSTACK label in ram.asm
; Assumes DSTACK base = $09FE (adjust for your build)

DSTACK_PTR  EQU $09FE   ; adjust to match your ram.asm

bridge:
    ; --- read two values off MINT's data stack ---
    LD  HL,(DSTACK_PTR)     ; HL = current MINT stack pointer
    LD  E,(HL)
    INC HL
    LD  D,(HL)              ; DE = first Mint value (TOS)
    INC HL
    LD  C,(HL)
    INC HL
    LD  B,(HL)              ; BC = second Mint value (NOS)
    INC HL
    LD  (DSTACK_PTR),HL     ; update Mint stack pointer (popped 2 values)

    ; --- push as Z80 stack args for SDCC ---
    PUSH DE                 ; arg2
    PUSH BC                 ; arg1

    ; --- call the C function ---
    CALL $1900              ; address of compiled C code

    ; --- push HL (SDCC return value) back onto MINT stack ---
    LD  HL,(DSTACK_PTR)
    DEC HL
    LD  (HL),D              ; push high byte
    DEC HL
    LD  (HL),E              ; push low byte  (HL from SDCC = result)
    LD  (DSTACK_PTR),HL

    RET
```

> Note: verify `DSTACK_PTR` against your specific `ram.asm` build. The address
> shifts if you change `TIBSIZE`, `RSIZE`, or `DSIZE` in `constants.asm`.

---

## Worked Example: Port I/O from C

A practical use case — toggle an output port, something clumsy in MINT but
clean in C:

```c
/* ports.c — blink output port bit */
#define PORT_ADDR  0x01

void blink(void) {
    int i;
    for (i = 0; i < 100; i++) {
        __asm__("LD A,#0xFF");
        __asm__("OUT (#0x01),A");
        __asm__("LD A,#0x00");
        __asm__("OUT (#0x01),A");
    }
}
```

Compile, load at `$1800`, call from MINT:

```
:B #1800 /X ;    \ define function B to call blink
B                \ run it
```

---

## Limitations and Gotchas

| Issue | Detail |
|-------|--------|
| **`/X` not in stock ROM** | Must compile from source — see Source Availability below |
| **No stdlib** | SDCC's `printf`, `malloc` etc. will not work — freestanding only |
| **Fixed code address** | SDCC output is not position-independent by default; recompile if load address changes |
| **RAM budget** | Base TEC-1 has only ~3.5K free after MINT overhead; use extended RAM config |
| **SDCC output size** | Even simple C produces ~100-300 bytes; check your `.map` file |
| **No MINT stack bridge by default** | Use fixed RAM addresses for args unless you write the asm shim |
| **Z is reserved** | Do not compile a C function to overwrite the `$0008` RST vector area |

---

## Quick Reference

```
\ compile
sdcc -mz80 --no-std-crt0 --code-loc 0x1800 --data-loc 0x1900 mycode.c
srec_cat mycode.ihx -Intel -o mycode.bin -Binary

\ upload binary to TEC-1 RAM at $1800 via serial / autotyper

\ call from MINT
6  #1900 !          \ write arg to RAM
7  #1902 !
#1800 /X            \ execute C function
#1904 @  .          \ read result
```

---

## Source Availability of `/X`

`/X` is **not present in the pre-built `TEC-1ROM10.z80` binary** but is implemented in both known source trees:

| Source | Location | Line |
|--------|----------|------|
| Local `Stack_Fix/MAIN.asm` | `exec_` label | ~992 |
| Upstream `orgMINT/MINT` on GitHub | `exec_` label | ~620 |

The implementations are identical — `call exec1` / `EX (SP),hl` / `jp (hl)`. Either source can be compiled to get a ROM with `/X` support. The stock binary predates or excludes this feature.

---

## See Also

- `Stack_Fix/MAIN.asm` — `exec_` label (line ~992) for `/X` implementation
- `Stack_Fix/constants.asm` — memory map and RAM layout
- `Stack_Fix/ram.asm` — DSTACK, TIB, heap layout
- `MINT2 Manual.md` — `/X`, `/I` (port input), `/O` (port output) commands
- SDCC manual: http://sdcc.sourceforge.net/doc/sdccman.pdf
- SDCC Z80 port notes: https://sdcc.sourceforge.net/mediawiki/index.php/SDCC_and_Z80



claude --resume e72a24f1-5729-4525-bf2d-7fe1ee1f3e5c
