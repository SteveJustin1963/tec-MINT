# MINT Stack Collision Fix Manual
**TEC-1 Z80 Computer - MINT 2.0 Interpreter**

## Problem Description

MINT hangs or crashes immediately after boot due to a **stack collision**. The Z80 CPU hardware stack and MINT interpreter's data structures are using the same memory location (0x0A00), causing corruption of the interpreter's control flow.

### Symptoms:
- System hangs after displaying "MINT2.0" 
- No ">" prompt appears
- System may reboot continuously
- Commands like `.` (dot) cause hangs

## Root Cause

The CPU stack pointer (SP) is initialized to the same address as MINT's data stack:

```
0x0A00: DSTACK (MINT data stack)
0x0A00: CPU SP   (Hardware stack) ← COLLISION!
```

When the CPU executes `PUSH`, `CALL`, or handles interrupts, it writes to memory locations that MINT uses for its interpreter state, corrupting the system.

## The Fix

**Change only one line of code** to move the CPU stack away from MINT's data area.

### Step 1: Locate the Source File

Find the file containing the RESET routine. Use one of these methods:

**Command line search:**
```bash
grep -n "LD.*SP" *.asm
grep -n "RESET:" *.asm
```

**Manual search:** Look for a file containing:
- `RESET:` label
- `LD SP,DSTACK` or `LD SP,stack`

**Likely files:** `IOSerial.asm`, `MAIN.asm`, `MINT.asm`, or `TEC-1ROM10.asm`

### Step 2: Make the Change

Find this code in the RESET routine:
```asm
RESET:       
   LD   SP,DSTACK        ; <-- ORIGINAL (causes collision)
   LD   HL,IntRet   
   LD   (RST08),HL   
   ; ... rest of initialization
```

**Change the stack pointer line to:**
```asm
   LD   SP,0x0FF0        ; <-- NEW (safe location)
```

### Step 3: Rebuild and Test

1. **Assemble** your code using your normal build process
2. **Program** the ROM onto your TEC-1
3. **Reset** the system

**Expected behavior:**
- System displays "MINT2.0"
- Prompt ">" appears
- You can enter commands

**Simple test:**
```
10 20 + .     (should display: 30)
```

## Memory Map After Fix

```
0x0800-0x08FF: TIB (Text Input Buffer)     - Safe
0x0900-0x097F: Available space            - Safe  
0x0980-0x09FF: RSTACK (MINT return stack) - Safe
0x0A00-0x0EFF: DSTACK + Variables + Heap  - Safe
0x0F00-0x0FEF: Guard space                - Safe
0x0FF0-0x0FFF: CPU Hardware Stack         - Safe
```

**Result:** 240 bytes of separation between CPU stack and MINT data structures.

## Technical Details

### Why 0x0FF0?
- **Top of 2KB RAM:** TEC-1 has 2KB RAM from 0x0800-0x0FFF
- **16 bytes for stack:** Provides 16 bytes (0x0FF0-0x0FFF) for CPU stack
- **Downward growth:** CPU stack grows down from 0x0FF0 toward 0x0FE0
- **Safe margin:** 240 bytes between MINT heap and CPU stack

### What Doesn't Change
- MINT interpreter behavior (unchanged)
- Variable locations (unchanged)  
- Heap allocation (unchanged)
- Serial I/O routines (unchanged)
- All MINT commands work exactly the same

### What Does Change
- **Only** the CPU hardware stack location
- System stability (much improved)
- No more random crashes/hangs

## Troubleshooting

**If the fix doesn't work:**

1. **Verify the change:** Check that `LD SP,0x0FF0` assembled correctly
2. **Check build process:** Ensure you're programming the modified ROM
3. **Try different location:** If 0x0FF0 doesn't work, try 0x0FE0
4. **Revert if needed:** Change back to `LD SP,DSTACK` to restore original behavior

**If still having issues:**
- Check for hardware problems
- Verify RAM is working at 0x0F00+ addresses  
- Ensure ROM programming was successful

## Alternative Approaches

If the minimal fix above doesn't work, consider:

1. **Different stack location:** Try 0x0FE0 or 0x0FC0
2. **Larger separation:** Use 0x0F00 for more stack space
3. **Hardware check:** Verify RAM integrity in upper memory

## Success Criteria

After applying this fix:
- ✅ MINT boots reliably
- ✅ Prompt appears consistently  
- ✅ Basic arithmetic works: `10 20 + .`
- ✅ Stack operations work: `5 " . .` (prints: 5 5)
- ✅ No random hangs or crashes

---

**Author:** Stack collision analysis and fix  
**Version:** 1.0  
**Date:** 2025  
**Tested on:** TEC-1 with 2KB RAM configuration
