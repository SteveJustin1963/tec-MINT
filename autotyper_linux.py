from pynput.keyboard import Controller, Key
import time
import sys

print("Program starting...")

# Path to text file (Linux version)
file_path = "/home/sj/Desktop/textfile.txt"

# Ask for debugging
debug_input = input("Enable debug mode? (y/n): ").strip().lower()
DEBUG = debug_input == 'y'

# Special character mappings
shift_chars = {
    '~': '`', '!': '1', '@': '2', '#': '3', '$': '4', '%': '5', '^': '6',
    '&': '7', '*': '8', '(': '9', ')': '0', '_': '-', '+': '=', '{': '[',
    '}': ']', '|': '\\', ':': ';', '"': "'", '<': ',', '>': '.', '?': '/'
}

def type_text():
    try:
        with open(file_path, 'rb') as file:
            content = file.read().decode('utf-8')

        # Clean text
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

        print("Starting in 5 seconds...")
        time.sleep(5)
        print("Typing... (Press Ctrl+C in terminal to stop)")

        kb = Controller()

        for char in text:
            if DEBUG:
                print(f"[DEBUG] Typing char: {repr(char)}")

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

                time.sleep(0.1)
            except Exception as e:
                print(f"Error typing character '{char}': {e}")
                continue

        print("Done typing!")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit()

# Run immediately
type_text()
