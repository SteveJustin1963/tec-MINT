#!/usr/bin/env python3
"""
TEC-1 ROM10 Interrupt Patch Tool
Enables :Z function for hardware interrupts

Usage: python3 tec1_int_patch.py [input.bin] [output.bin]
"""

import sys
import os

def patch_rom(input_file, output_file):
    """Patch TEC-1ROM10 to enable interrupt handler"""
    
    # Read original ROM
    try:
        with open(input_file, 'rb') as f:
            data = bytearray(f.read())
    except FileNotFoundError:
        print(f"ERROR: File '{input_file}' not found!")
        return False
    except Exception as e:
        print(f"ERROR reading file: {e}")
        return False
    
    # Verify ROM size
    rom_size = len(data)
    print(f"ROM size: {rom_size} bytes ({rom_size//1024}K)")
    
    if rom_size < 0x3B:
        print("ERROR: ROM too small!")
        return False
    
    # Show original bytes
    print(f"\nOriginal bytes at 0x38:")
    print(f"  0x38: 0x{data[0x38]:02X} (should be 0xC9 = RET)")
    if len(data) > 0x39:
        print(f"  0x39: 0x{data[0x39]:02X}")
    if len(data) > 0x3A:
        print(f"  0x3A: 0x{data[0x3A]:02X}")
    
    # Verify it's actually RET at 0x38
    if data[0x38] == 0xC9:
        print("✓ Found RET instruction at RST 38h (as expected)")
    elif data[0x38] == 0xC3 and data[0x39] == 0x8B and data[0x3A] == 0x00:
        print("⚠ ROM already patched! (JP 008Bh already present)")
        choice = input("Continue anyway? (y/n): ")
        if choice.lower() != 'y':
            return False
    else:
        print(f"⚠ WARNING: Expected 0xC9 at 0x38, found 0x{data[0x38]:02X}")
        choice = input("Continue with patch? (y/n): ")
        if choice.lower() != 'y':
            return False
    
    # Apply patch
    print("\nApplying patch...")
    data[0x38] = 0xC3  # JP opcode
    data[0x39] = 0x8B  # Low byte of ISR address (008Bh)
    data[0x3A] = 0x00  # High byte of ISR address
    
    # Show patched bytes
    print(f"Patched bytes at 0x38:")
    print(f"  0x38: 0x{data[0x38]:02X} = JP opcode")
    print(f"  0x39: 0x{data[0x39]:02X} = ISR low byte")
    print(f"  0x3A: 0x{data[0x3A]:02X} = ISR high byte")
    print(f"  Disassembly: JP 008Bh")
    
    # Verify patch
    if data[0x38] == 0xC3 and data[0x39] == 0x8B and data[0x3A] == 0x00:
        print("✓ Patch applied successfully")
    else:
        print("✗ ERROR: Patch failed!")
        return False
    
    # Write patched ROM
    try:
        with open(output_file, 'wb') as f:
            f.write(data)
        print(f"\n✓ Patched ROM written to: {output_file}")
        print(f"  Size: {len(data)} bytes")
        return True
    except Exception as e:
        print(f"ERROR writing file: {e}")
        return False

def verify_rom(filename):
    """Verify a ROM has been patched correctly"""
    try:
        with open(filename, 'rb') as f:
            data = f.read()
        
        if len(data) < 0x3B:
            print("ERROR: ROM too small")
            return False
        
        print(f"\nVerifying: {filename}")
        print(f"Bytes at 0x38: {data[0x38]:02X} {data[0x39]:02X} {data[0x3A]:02X}")
        
        if data[0x38] == 0xC3 and data[0x39] == 0x8B and data[0x3A] == 0x00:
            print("✓ ROM is correctly patched (JP 008Bh present)")
            return True
        elif data[0x38] == 0xC9:
            print("✗ ROM is NOT patched (still has RET)")
            return False
        else:
            print(f"⚠ Unknown instruction at 0x38: {data[0x38]:02X}")
            return False
    except Exception as e:
        print(f"ERROR: {e}")
        return False

def create_ips_patch():
    """Create IPS patch file"""
    ips_data = bytearray()
    ips_data.extend(b'PATCH')           # Header
    ips_data.extend(b'\x00\x00\x38')    # Address: 0x000038
    ips_data.extend(b'\x00\x03')        # Length: 3 bytes
    ips_data.extend(b'\xC3\x8B\x00')    # Data: JP 008Bh
    ips_data.extend(b'EOF')             # Trailer
    
    with open('TEC1-INT.ips', 'wb') as f:
        f.write(ips_data)
    print("✓ Created IPS patch: TEC1-INT.ips")

def show_hex_dump(filename, address, length):
    """Show hex dump of ROM at address"""
    try:
        with open(filename, 'rb') as f:
            f.seek(address)
            data = f.read(length)
        
        print(f"\nHex dump of {filename} at 0x{address:04X}:")
        for i in range(0, len(data), 16):
            hex_str = ' '.join(f'{b:02X}' for b in data[i:i+16])
            ascii_str = ''.join(chr(b) if 32 <= b < 127 else '.' for b in data[i:i+16])
            print(f"{address+i:08X}  {hex_str:<48}  {ascii_str}")
    except Exception as e:
        print(f"ERROR: {e}")

if __name__ == '__main__':
    print("═" * 70)
    print("  TEC-1 ROM10 Interrupt Patch Tool")
    print("  Enables :Z function for hardware interrupts")
    print("═" * 70)
    
    # Parse arguments
    if len(sys.argv) == 1:
        print("\nUsage:")
        print(f"  {sys.argv[0]} <input.bin> [output.bin]")
        print(f"  {sys.argv[0]} --verify <rom.bin>")
        print(f"  {sys.argv[0]} --create-ips")
        print(f"  {sys.argv[0]} --dump <rom.bin>")
        print("\nExamples:")
        print(f"  {sys.argv[0]} TEC-1ROM10.bin TEC-1ROM10-INT.bin")
        print(f"  {sys.argv[0]} --verify TEC-1ROM10-INT.bin")
        sys.exit(1)
    
    if sys.argv[1] == '--verify':
        if len(sys.argv) < 3:
            print("ERROR: Specify ROM file to verify")
            sys.exit(1)
        verify_rom(sys.argv[2])
        sys.exit(0)
    
    if sys.argv[1] == '--create-ips':
        create_ips_patch()
        sys.exit(0)
    
    if sys.argv[1] == '--dump':
        if len(sys.argv) < 3:
            print("ERROR: Specify ROM file to dump")
            sys.exit(1)
        show_hex_dump(sys.argv[2], 0x30, 0x20)
        sys.exit(0)
    
    # Patch ROM
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'TEC-1ROM10-PATCHED.bin'
    
    if not os.path.exists(input_file):
        print(f"ERROR: Input file '{input_file}' not found!")
        sys.exit(1)
    
    if os.path.exists(output_file):
        print(f"⚠ WARNING: Output file '{output_file}' already exists!")
        choice = input("Overwrite? (y/n): ")
        if choice.lower() != 'y':
            print("Aborted.")
            sys.exit(1)
    
    success = patch_rom(input_file, output_file)
    
    if success:
        print("\n" + "─" * 70)
        print("NEXT STEPS:")
        print("1. Verify the patch:")
        print(f"   {sys.argv[0]} --verify {output_file}")
        print("2. Burn ROM using programmer:")
        print(f"   minipro -p AT28C64 -w {output_file}")
        print("3. Test in TEC-1:")
        print("   > :Z `*` ;")
        print("   > (generate interrupt - should print *)")
        print("─" * 70)
        sys.exit(0)
    else:
        print("\n✗ Patch failed!")
        sys.exit(1)


# ═══════════════════════════════════════════════════════════════════════
# BASH SCRIPT ALTERNATIVE (save as tec1_patch.sh)
# ═══════════════════════════════════════════════════════════════════════
"""
#!/bin/bash
# TEC-1 ROM10 Interrupt Patch Script

INPUT="${1:-TEC-1ROM10.bin}"
OUTPUT="${2:-TEC-1ROM10-INT.bin}"

if [ ! -f "$INPUT" ]; then
    echo "ERROR: File '$INPUT' not found!"
    exit 1
fi

echo "═══════════════════════════════════════════════════════════════"
echo "  TEC-1 ROM10 Interrupt Patch"
echo "═══════════════════════════════════════════════════════════════"
echo "Input:  $INPUT"
echo "Output: $OUTPUT"

# Show original byte
echo ""
echo "Original byte at 0x38:"
xxd -s 0x38 -l 1 "$INPUT"

# Create patch
echo ""
echo "Creating patch..."
cp "$INPUT" "$OUTPUT"
printf '\xC3\x8B\x00' | dd of="$OUTPUT" bs=1 seek=56 conv=notrunc 2>/dev/null

# Verify
echo ""
echo "Patched bytes at 0x38:"
xxd -s 0x38 -l 3 "$OUTPUT"

# Check if successful
if xxd -s 0x38 -l 3 "$OUTPUT" | grep -q "c38b 00"; then
    echo ""
    echo "✓ SUCCESS! ROM patched successfully"
    echo ""
    echo "Next steps:"
    echo "1. Burn ROM: minipro -p AT28C64 -w $OUTPUT"
    echo "2. Test: > :Z \`*\` ;"
else
    echo ""
    echo "✗ ERROR: Patch failed!"
    exit 1
fi
"""

# ═══════════════════════════════════════════════════════════════════════
# WINDOWS BATCH SCRIPT (save as tec1_patch.bat)
# ═══════════════════════════════════════════════════════════════════════
"""
@echo off
REM TEC-1 ROM10 Interrupt Patch Script

set INPUT=%1
set OUTPUT=%2

if "%INPUT%"=="" set INPUT=TEC-1ROM10.bin
if "%OUTPUT%"=="" set OUTPUT=TEC-1ROM10-INT.bin

if not exist "%INPUT%" (
    echo ERROR: File '%INPUT%' not found!
    exit /b 1
)

echo ===============================================================
echo   TEC-1 ROM10 Interrupt Patch
echo ===============================================================
echo Input:  %INPUT%
echo Output: %OUTPUT%
echo.

echo Creating patched ROM...
copy /b "%INPUT%" "%OUTPUT%" >nul

REM Create patch bytes (requires debug.exe or certutil)
echo C3>patch.hex
echo 8B>>patch.hex
echo 00>>patch.hex
certutil -decodehex patch.hex patch.bin >nul 2>&1

REM Apply patch at offset 0x38 (56 decimal)
REM This requires a hex editor or third-party tool on Windows
REM Alternative: use HxD, WinHex, or Hex Workshop manually

echo.
echo Patch created. Please use a hex editor to:
echo 1. Open %OUTPUT%
echo 2. Go to address 0x38
echo 3. Change bytes to: C3 8B 00
echo.
echo Or use: python3 tec1_int_patch.py %INPUT% %OUTPUT%

del patch.hex patch.bin 2>nul
"""
