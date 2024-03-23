import tkinter as tk
from tkinter import *
from tkinter import ttk
import socket

def send_messageTolerance(event):
    message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Unreal Test/Timeline Layer 2/LayerResourceSet/TimelineRivermaxResource","params":{"keyingTolerance":"'+str(sliderTolerance.get())+'"}}'
    payload = str(len(message)) + ":" + message + ","
    try:
        client_socket.sendall(payload.encode())
        print("Message sent to server:", payload)
    except Exception as e:
        print("Error:", e)

def send_messageRed(event):
    message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Unreal Test/Timeline Layer 2/LayerResourceSet/TimelineRivermaxResource","params":{"redValue":"'+str(sliderRed.get())+'"}}'
    payload = str(len(message)) + ":" + message + ","
    try:
        client_socket.sendall(payload.encode())
        print("Message sent to server:", payload)
    except Exception as e:
        print("Error:", e)

def send_messageGreen(event):
    message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Unreal Test/Timeline Layer 2/LayerResourceSet/TimelineRivermaxResource","params":{"greenValue":"'+str(sliderGreen.get())+'"}}'
    payload = str(len(message)) + ":" + message + ","
    try:
        client_socket.sendall(payload.encode())
        print("Message sent to server:", payload)
    except Exception as e:
        print("Error:", e)

def send_messageBlue(event):
    message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Unreal Test/Timeline Layer 2/LayerResourceSet/TimelineRivermaxResource","params":{"blueValue":"'+str(sliderBlue.get())+'"}}'
    payload = str(len(message)) + ":" + message + ","
    try:
        client_socket.sendall(payload.encode())
        print("Message sent to server:", payload)
    except Exception as e:
        print("Error:", e)

# Create a TCP client socket
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Define the server address and port
SERVER_ADDRESS = '127.0.0.1'
SERVER_PORT = 5584

# Connect to the server
try:
    client_socket.connect((SERVER_ADDRESS, SERVER_PORT))
    print("Connected to server")
except Exception as e:
    print("Error connecting to server:", e)
    exit()

# Create the main window
root = tk.Tk()
root.title("TCP Client")

# Create a frame, label, and sliders for Tolerance
sliderToleranceFrame = ttk.Frame(root)
sliderToleranceFrame.pack(pady=10)
sliderToleranceValue = IntVar()
sliderToleranceValue.set('0')
sliderTolerance = ttk.Scale(root, from_=0, to=4096, orient='horizontal', length=500, variable=sliderToleranceValue)
sliderToleranceLabel = ttk.Label(sliderToleranceFrame, text="Tolerance:")
sliderToleranceLabel2 = ttk.Label(sliderToleranceFrame, textvariable=sliderToleranceValue)
sliderToleranceLabel2.grid(row=1, column=0, padx=5)
sliderToleranceLabel.grid(row=0, column=0, padx=5)

sliderTolerance.pack(pady=10)

# Create a frame, label, and sliders for Red
sliderRedFrame = ttk.Frame(root)
sliderRedFrame.pack(pady=10)
sliderRedValue = IntVar()
sliderRed = ttk.Scale(root, from_=0, to=4096, orient='horizontal', length=500, variable=sliderRedValue)
sliderRedLabel = ttk.Label(sliderRedFrame, text="Red:")
sliderRedLabel2 = ttk.Label(sliderRedFrame, textvariable=sliderRedValue)
sliderRedLabel2.grid(row=1, column=0, padx=5)
sliderRedLabel.grid(row=0, column=0, padx=5)

sliderRed.pack(pady=10)

# Create a frame, label, and sliders for Red
sliderGreenFrame = ttk.Frame(root)
sliderGreenFrame.pack(pady=10)
sliderGreenValue = IntVar()
sliderGreen = ttk.Scale(root, from_=0, to=4096, orient='horizontal', length=500, variable=sliderGreenValue)
sliderGreenLabel = ttk.Label(sliderGreenFrame, text="Green:")
sliderGreenLabel.grid(row=0, column=0, padx=5)
sliderGreenLabel2 = ttk.Label(sliderGreenFrame, textvariable=sliderGreenValue)
sliderGreenLabel2.grid(row=1, column=0, padx=5)
sliderGreen.pack(pady=10)

# Create a frame, label, and sliders for Blue
sliderBlueFrame = ttk.Frame(root)
sliderBlueFrame.pack(pady=10)
sliderBlueValue = IntVar()
sliderBlue = ttk.Scale(root, from_=0, to=4096, orient='horizontal', length=500, variable=sliderBlueValue)
sliderBlueLabel = ttk.Label(sliderBlueFrame, text="Blue:")
sliderBlueLabel.grid(row=0, column=0, padx=5)
sliderBlueLabel2 = ttk.Label(sliderBlueFrame, textvariable=sliderBlueValue)
sliderBlueLabel2.grid(row=1, column=0, padx=5)
sliderBlue.pack(pady=10)


# Create a button to send message
# send_button = ttk.Button(root, text="Send Message", command=send_messageTolerance)
# send_button.pack(pady=5)

# Bind the send_message function to the slider's motion event
sliderTolerance.bind("<Motion>", send_messageTolerance)
sliderRed.bind("<Motion>", send_messageRed)
sliderGreen.bind("<Motion>", send_messageGreen)
sliderBlue.bind("<Motion>", send_messageBlue)

# Run the main event loop
root.mainloop()

# Close the socket connection when the application exits
client_socket.close()