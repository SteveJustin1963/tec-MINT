from pynput.keyboard import Controller, Key
import keyboard
import time
import sys

print("Program starting...")

# Path to text file
file_path = r"C:\Users\61418\Desktop\textfile.txt"

# Special character mappings
shift_chars = {
    '~': '`', '!': '1', '@': '2', '#': '3', '$': '4', '%': '5', '^': '6',
    '&': '7', '*': '8', '(': '9', ')': '0', '_': '-', '+': '=', '{': '[',
    '}': ']', '|': '\\', ':': ';', '"': "'", '<': ',', '>': '.', '?': '/'
}

def type_text():
    try:
        # Read and decode file
        with open(file_path, 'rb') as file:
            content = file.read().decode('utf-8')
            
        # Clean the text (replace non-breaking spaces and normalize line endings)
        text = content.replace('\xa0', ' ').replace('\r\n', '\n').replace('\r', '\n')
        
        print("Starting in 3 seconds...")
        time.sleep(3)
        print("Typing...")
        
        kb = Controller()
        
        for char in text:
            try:
                if char == '\n':
                    kb.press(Key.enter)
                    kb.release(Key.enter)
                
                elif char in shift_chars:  # Handle shift + key characters
                    kb.press(Key.shift)
                    kb.press(shift_chars[char])
                    kb.release(shift_chars[char])
                    kb.release(Key.shift)
                
                elif char.isupper():  # Handle uppercase letters
                    kb.press(Key.shift)
                    kb.press(char.lower())
                    kb.release(char.lower())
                    kb.release(Key.shift)
                
                else:  # Handle regular characters
                    kb.press(char)
                    kb.release(char)
                
                time.sleep(0.05)  # Delay between characters
                
            except Exception as e:
                print(f"Error typing character '{char}': {e}")
                continue
        
        print("Done typing!")
        sys.exit()
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit()

print("Press Ctrl+7 to start typing, Esc to quit")

# Set up hotkey
keyboard.add_hotkey('ctrl+7', type_text)

# Keep program running until Esc pressed
keyboard.wait('esc')
