from pynput.keyboard import Controller, Key, Listener
import time
import sys

print("Program starting...")

# Path to text file (Linux version)
file_path = "/home/sj/Desktop/textfile.txt"

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

        # Clean the text (remove comments, normalize line endings)
        lines = content.split('\n')
        cleaned_lines = []
        for line in lines:
            if line.strip().startswith(':Q'):
                cleaned_lines.append(line)
            else:
                comment_index = line.find('//')
                if comment_index != -1:
                    line = line[:comment_index].rstrip()
                if line:
                    cleaned_lines.append(line)

        text = '\n'.join(cleaned_lines)
        text = text.replace('\xa0', ' ').replace('\r\n', '\n').replace('\r', '\n')

        print("Starting in 3 seconds...")
        time.sleep(3)
        print("Typing...")

        kb = Controller()

        for char in text:
            try:
                if char == '\n':
                    kb.press(Key.enter)
                    kb.release(Key.enter)
                elif char in shift_chars:
                    kb.press(Key.shift)
                    kb.press(shift_chars[char])
                    kb.release(shift_chars[char])
                    kb.release(Key.shift)
                elif char.isupper():
                    kb.press(Key.shift)
                    kb.press(char.lower())
                    kb.release(char.lower())
                    kb.release(Key.shift)
                else:
                    kb.press(char)
                    kb.release(char)

                time.sleep(0.1)  # Delay between characters
            except Exception as e:
                print(f"Error typing character '{char}': {e}")
                continue

        print("Done typing!")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit()

print("Press Ctrl+7 to start typing, Esc to quit")

pressed_keys = set()

def on_press(key):
    try:
        pressed_keys.add(key)

        # Ctrl+7 hotkey
        if Key.ctrl_l in pressed_keys or Key.ctrl_r in pressed_keys:
            if hasattr(key, 'char') and key.char == '7':
                type_text()

        # Escape exits program
        if key == Key.esc:
            print("Exiting...")
            return False

    except Exception as e:
        print(f"Error in on_press: {e}")

def on_release(key):
    if key in pressed_keys:
        pressed_keys.remove(key)

# Start listening for hotkeys
with Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join()
