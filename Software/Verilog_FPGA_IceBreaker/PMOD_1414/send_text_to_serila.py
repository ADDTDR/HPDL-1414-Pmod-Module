import serial
import time

# Configure the serial port
port = "COM10"
baud_rate = 115200

text = "PLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum"
text = text.upper()
try:
    # Open the serial port
    with serial.Serial(port, baud_rate, timeout=1) as ser:
        print(f"Opened {port} at {baud_rate} baud.")
        for char in text:
            ser.write(char.encode())  
            time.sleep(0.1)  
        print("Done writing to the serial port.")
except serial.SerialException as e:
    print(f"Error: {e}")
