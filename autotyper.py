from pynput import keyboard
from pynput.keyboard import Controller, Key
import time
import sys

# Set the path to the text file
file_path = r"C:\Users\61418\Desktop\textfile.txt"

# Dictionary mapping special characters to their shifted versions
shift_chars = {
    '~': '`', '!': '1', '@': '2', '#': '3', '$': '4', '%': '5', '^': '6',
    '&': '7', '*': '8', '(': '9', ')': '0', '_': '-', '+': '=', '{': '[',
    '}': ']', '|': '\\', ':': ';', '"': "'", '<': ',', '>': '.', '?': '/'
}

def read_file():
    """Read the text file content."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.read()
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return None

def type_text(text):
    """Simulate typing the text."""
    keyboard_controller = Controller()
    text = text.replace('\r\n', '\n').replace('\r', '\n')  # Normalize line endings
    
    for char in text:
        try:
            if char == '\n':  # Handle new lines
                keyboard_controller.press(Key.enter)
                keyboard_controller.release(Key.enter)
                time.sleep(0.2)  # Slightly longer delay for Enter
            
            elif char in shift_chars:  # Handle shifted characters
                keyboard_controller.press(Key.shift)
                keyboard_controller.press(shift_chars[char])
                keyboard_controller.release(shift_chars[char])
                keyboard_controller.release(Key.shift)
            
            elif char.isupper():  # Handle uppercase letters
                keyboard_controller.press(Key.shift)
                keyboard_controller.press(char.lower())
                keyboard_controller.release(char.lower())
                keyboard_controller.release(Key.shift)
            
            elif char == ' ':  # Handle spaces
                keyboard_controller.press(Key.space)
                keyboard_controller.release(Key.space)
            
            else:  # Handle regular characters
                keyboard_controller.press(char)
                keyboard_controller.release(char)
            
            time.sleep(0.05)  # Delay for typing speed
            
        except Exception as e:
            print(f"Error typing character '{char}': {str(e)}")
            continue

def on_activate():
    """Function to run when hotkey is pressed"""
    print("Starting typing sequence...")
    text = read_file()
    if text:
        time.sleep(0.5)  # Small delay before typing starts
        type_text(text)
        print("\nTyping complete. Program will exit in 2 seconds...")
        time.sleep(2)
        sys.exit(0)
    else:
        print("No text to type. Program will exit...")
        time.sleep(2)
        sys.exit(1)

def for_canonical(f):
    return lambda k: f(l.canonical(k))

def main():
    """Main program loop."""
    global l  # Make listener accessible to for_canonical
    
    try:
        # Create the hotkey combination
        hotkey = keyboard.HotKey(keyboard.HotKey.parse('<ctrl>+7'), on_activate)
        
        # Create and start the listener
        with keyboard.Listener(
            on_press=for_canonical(hotkey.press),
            on_release=for_canonical(hotkey.release)
        ) as l:
            print("Hotkey listener running. Press Ctrl+7 to type the text.")
            print(f"Reading from file: {file_path}")
            l.join()
            
    except Exception as e:
        print(f"Error in main program: {str(e)}")
        time.sleep(2)
        sys.exit(1)

if __name__ == "__main__":
    main()