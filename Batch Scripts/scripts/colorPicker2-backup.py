import tkinter as tk
import pyautogui
import socket
from pynput.mouse import Listener

'''
Date: 2024-03-15
Author: NH
Editor: CG
Copyright: Nah
'''

class ColorPickerApp:
    def __init__(self):

        # Default server address and port
        self.SERVER_ADDRESS = '127.0.0.1'  # Default server address
        self.SERVER_PORT = 5584         # Default server port number
        
        # Create a TCP client socket
        self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        # Connect to the server
        try:
            self.client_socket.connect((self.SERVER_ADDRESS, self.SERVER_PORT))
            print("Connected to server")
        except Exception as e:
            print("Error connecting to server:", e)
            exit()

        self.root = tk.Tk()
        self.root.title("Color Picker from Screen")
        
        self.pick_button = tk.Button(self.root, text="Pick a Color from Screen", command=self.pick_color_from_screen)
        self.pick_button.pack(pady=5)

        self.color_label = tk.Label(self.root, text="Chosen Color", width=30, height=3)
        self.color_label.pack(pady=5)

        # Variables to store the values of red, green, and blue
        self.hex_value = tk.IntVar()
        self.red_value = tk.IntVar()
        self.green_value = tk.IntVar()
        self.blue_value = tk.IntVar()

        # Labels to display the values of hex, red, green, and blue
        self.hex_label = tk.Label(self.root, text="Hex:", padx=10)
        self.hex_label.pack()
        self.hex_entry = tk.Entry(self.root, textvariable=self.hex_value)
        self.hex_entry.pack()
        
        self.red_label = tk.Label(self.root, text="Red:", padx=10)
        self.red_label.pack()
        self.red_entry = tk.Entry(self.root, textvariable=self.red_value)
        self.red_entry.pack()

        self.green_label = tk.Label(self.root, text="Green:", padx=10)
        self.green_label.pack()
        self.green_entry = tk.Entry(self.root, textvariable=self.green_value)
        self.green_entry.pack()

        self.blue_label = tk.Label(self.root, text="Blue:", padx=10)
        self.blue_label.pack()
        self.blue_entry = tk.Entry(self.root, textvariable=self.blue_value)
        self.blue_entry.pack()

        # Entry field for server address
        self.server_address_label = tk.Label(self.root, text="Server Address:", padx=10)
        self.server_address_label.pack()
        self.server_address = tk.StringVar(value=self.SERVER_ADDRESS)
        self.server_address.trace_add("write", self.on_server_address_change)  # Listen for changes in the entry field
        self.server_address_entry = tk.Entry(self.root, textvariable=self.server_address)
        self.server_address_entry.pack()
        
        # Entry field for server port
        self.server_port_label = tk.Label(self.root, text="Server Port:", padx=10)
        self.server_port_label.pack()
        self.server_port = tk.StringVar(value=str(self.SERVER_PORT))
        self.server_port.trace_add("write", self.on_server_port_change)  # Listen for changes in the entry field
        self.server_port_entry = tk.Entry(self.root, textvariable=self.server_port, width=5)
        self.server_port_entry.pack()
        
        
        # Entry field for timeline number
        self.timeline_label = tk.Label(self.root, text="Timeline Number:", padx=15)
        self.timeline_label.pack()
        self.timeline_entry = tk.Entry(self.root, width=5)
        self.timeline_entry.pack()
        
        # Entry field for layer number
        self.layer_label = tk.Label(self.root, text="Layer Number:", padx=15)
        self.layer_label.pack()
        self.layer_entry = tk.Entry(self.root, width=5)
        self.layer_entry.pack()
        
        # Entry field for resource name
        self.resource_label = tk.Label(self.root, text="Resource Name:", padx=15)
        self.resource_label.pack()
        self.resource_entry = tk.Entry(self.root, width=30)
        self.resource_entry.pack()

        # Slider for Tolerance
        self.slider_Tolerance_label = tk.Label(self.root, text="Tolerance:", padx=10)
        self.slider_Tolerance_label.pack()
        self.slider_Tolerance = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_tolerance, length=500, border=4, background="grey")
        self.slider_Tolerance.pack(padx=10)
        
        # Slider for red
        self.slider_red_label = tk.Label(self.root, text="Red:", padx=10)
        self.slider_red_label.pack()
        self.slider_red = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_red, length=500, border=4, background="red")
        self.slider_red.pack(padx=10)
        
        # Slider for green
        self.slider_green_label = tk.Label(self.root, text="Green:", padx=10)
        self.slider_green_label.pack()
        self.slider_green = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_green, length=500, border=4, background="green")
        self.slider_green.pack(padx=10)
        
        # Slider for blue
        self.slider_blue_label = tk.Label(self.root, text="Blue:", padx=10)
        self.slider_blue_label.pack()
        self.slider_blue = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_blue, length=500, border=4, background="blue")
        self.slider_blue.pack()

        self.first_click = True
        self.listener = None
        self.root.mainloop()
        
    def pick_color_from_screen(self):
        self.first_click = True
        self.pick_button.config(state=tk.DISABLED)
        self.listener = Listener(on_click=self.get_mouse_click)
        self.listener.start()

    def get_mouse_click(self, x, y, button, pressed):
        if pressed: # and not self.first_click:
            color = pyautogui.screenshot().getpixel((x, y))  # Get the color of the pixel at the clicked position
            hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2])  # Convert RGB to hexadecimal
            self.color_label.config(bg=hex_color)
            self.hex_value.set(hex_color)
            self.red_value.set(int(color[0] * 4096 / 255))
            self.green_value.set(int(color[1] * 4096 / 255))
            self.blue_value.set(int(color[2] * 4096 / 255))
            self.slider_red.set(int(color[0] * 4096 / 255))
            self.slider_green.set(int(color[1] * 4096 / 255))
            self.slider_blue.set(int(color[2] * 4096 / 255))
            self.pick_button.config(state=tk.NORMAL)
            self.listener.stop()
        else:
            self.first_click = False

    def send_message_tolerance(self, event):
        timeline_number = self.timeline_entry.get()
        layer_number = self.layer_entry.get()
        resource_name = self.resource_entry.get()
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Timeline ' + timeline_number + '/Timeline Layer ' + layer_number + '/LayerResourceSet/' + resource_name + '","params":{"keyingTolerance":"'+str(self.slider_Tolerance.get())+'"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)
 
    def send_message_red(self, event):
        timeline_number = self.timeline_entry.get()
        layer_number = self.layer_entry.get()
        resource_name = self.resource_entry.get()
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Timeline ' + timeline_number + '/Timeline Layer ' + layer_number + '/LayerResourceSet/' + resource_name + '","params":{"redValue":"' + str(self.slider_red.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)
    
    def send_message_green(self, event):
        timeline_number = self.timeline_entry.get()
        layer_number = self.layer_entry.get()
        resource_name = self.resource_entry.get()
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Timeline ' + timeline_number + '/Timeline Layer ' + layer_number + '/LayerResourceSet/' + resource_name + '","params":{"greenValue":"' + str(self.slider_green.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)
    
    def send_message_blue(self, event):
        timeline_number = self.timeline_entry.get()
        layer_number = self.layer_entry.get()
        resource_name = self.resource_entry.get()
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Timeline ' + timeline_number + '/Timeline Layer ' + layer_number + '/LayerResourceSet/' + resource_name + '","params":{"blueValue":"' + str(self.slider_blue.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)

    def on_server_address_change(self, event):
        # global self.SERVER_HOST
        self.SERVER_ADDRESS = self.server_address.get()
        print("Server address updated:", self.SERVER_ADDRESS)
    
    def on_server_port_change(self, event):
        # global SERVER_PORT
        try:
            self.SERVER_PORT = int(self.server_port.get())
            print("Server port updated:", self.SERVER_PORT)
        except ValueError:
            print("Invalid port number")

# Create an instance of the ColorPickerApp class
app = ColorPickerApp()
