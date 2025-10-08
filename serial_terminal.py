#!/usr/bin/env python3
import serial
import sys
import threading
import termios
import tty
import time

SERIAL_PORT = "/dev/ttyUSB0"
BAUD_RATE = 4800
STOP_FLAG = False

# Delay between characters (seconds)
CHAR_DELAY = 0.07  

def serial_reader(ser):
    """Continuously read serial and print all available bytes as fast as they arrive."""
    global STOP_FLAG
    while not STOP_FLAG:
        try:
            n = ser.in_waiting
            if n:
                data = ser.read(n)
                sys.stdout.write(data.decode(errors="replace"))
                sys.stdout.flush()
        except serial.SerialException:
            break

def main():
    global STOP_FLAG
    try:
        ser = serial.Serial(
            SERIAL_PORT,
            BAUD_RATE,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=0.01,
        )
    except serial.SerialException as e:
        print(f"Error opening {SERIAL_PORT}: {e}")
        sys.exit(1)

    print(f"Connected to {SERIAL_PORT} at {BAUD_RATE} 8N1.")
    print(f"Press Ctrl +C to quit. Sending is throttled to {CHAR_DELAY:.2f}s delay per char.\n")

    reader = threading.Thread(target=serial_reader, args=(ser,), daemon=True)
    reader.start()

    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    tty.setraw(fd)

    try:
        while True:
            ch = sys.stdin.buffer.read(1)
            if not ch:
                break
            ser.write(ch)
            ser.flush()
            time.sleep(CHAR_DELAY)

    except KeyboardInterrupt:
        print("\nInterrupted. Closing port...")
        STOP_FLAG = True
        reader.join(timeout=1)
        ser.close()
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        print("Serial port closed. Goodbye.")

if __name__ == "__main__":
    main()

