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

        # Build Widget
        self.root = tk.Tk()
        self.root.title("7thChromaSender")
        self.root.configure(bg="#555555",)
        self.first_click = True
        self.listener = None
        
        
        # Variables to store the values of red, green, and blue
        self.hex_value = tk.IntVar()
        self.red_value = tk.IntVar()
        self.green_value = tk.IntVar()
        self.blue_value = tk.IntVar()
        self.tolerance_value = tk.IntVar()

        # Color Picker
        self.pick_button = tk.Button(self.root, text="Pick a Color from Screen", command=self.pick_color_from_screen)
        self.pick_button.grid(row=0, column=1, sticky="w", padx=80, pady=(10, 20))
        
        # Slider for Tolerance
        self.tolerance_label = tk.Label(self.root, text="Tolerance:", font=("Arial", 16), bg=self.root.cget('bg'), fg="black")
        self.tolerance_label.grid(row=2, column=0, sticky="e", padx=(10, 0))
        self.tolerance_entry = tk.Entry(self.root, textvariable=self.tolerance_value, width=66)
        self.tolerance_entry.grid(row=2, column=1, sticky="w", padx=(0, 10))
        self.slider_Tolerance = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_tolerance, length=500, border=4, background="grey", highlightbackground="black")
        self.slider_Tolerance.grid(row=3, column=0, columnspan=2, sticky="w", padx=10)

        # Red
        self.red_label = tk.Label(self.root, text="Red:", font=("Arial", 16), bg=self.root.cget('bg'), fg="red")
        self.red_label.grid(row=4, column=0, sticky="e", padx=(10, 0))
        self.red_entry = tk.Entry(self.root, textvariable=self.red_value, width=66)
        self.red_entry.grid(row=4, column=1, sticky="w", padx=(0, 10))
        self.slider_red = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_red, length=500, border=4, background="red", highlightbackground="black")
        self.slider_red.grid(row=5, column=0, columnspan=2, sticky="w", padx=(10, 10))

        # Green
        self.green_label = tk.Label(self.root, text="Green:", font=("Arial", 16), bg=self.root.cget('bg'), fg="green")
        self.green_label.grid(row=6, column=0, sticky="e", padx=(10, 0))
        self.green_entry = tk.Entry(self.root, textvariable=self.green_value, width=66)
        self.green_entry.grid(row=6, column=1, sticky="w", padx=(0, 10))
        self.slider_green = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_green, length=500, border=4, background="green", highlightbackground="black")
        self.slider_green.grid(row=7, column=0, columnspan=2, sticky="w", padx=10)

        # Blue
        self.blue_label = tk.Label(self.root, text="Blue:", font=("Arial", 16), bg=self.root.cget('bg'), fg="blue")
        self.blue_label.grid(row=8, column=0, sticky="e", padx=(10, 0))
        self.blue_entry = tk.Entry(self.root, textvariable=self.blue_value, width=66)
        self.blue_entry.grid(row=8, column=1, sticky="w", padx=(0, 10))
        self.slider_blue = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_blue, length=500, border=4, background="blue", highlightbackground="black")
        self.slider_blue.grid(row=9, column=0, columnspan=2, sticky="w", padx=10)

        # Hex
        self.hex_label = tk.Label(self.root, text="Hex:", font=("Arial", 16), bg=self.root.cget('bg'), fg="black")
        self.hex_label.grid(row=10, column=0, sticky="e", padx=(10, 0))
        self.hex_entry = tk.Entry(self.root, textvariable=self.hex_value, width=58)
        self.hex_entry.grid(row=10, column=1, sticky="w", padx=(0, 10))

        # Entry field for server address
        self.server_address_label = tk.Label(self.root, text="Server Address:", padx=10)
        #self.server_address_label.pack()
        self.server_address = tk.StringVar(value=self.SERVER_ADDRESS)
        self.server_address.trace_add("write", self.on_server_address_change)  # Listen for changes in the entry field
        self.server_address_entry = tk.Entry(self.root, textvariable=self.server_address)
        #self.server_address_entry.pack()
        
        # Entry field for server port
        self.server_port_label = tk.Label(self.root, text="Server Port:", padx=10)
        #self.server_port_label.pack()
        self.server_port = tk.StringVar(value=str(self.SERVER_PORT))
        self.server_port.trace_add("write", self.on_server_port_change)  # Listen for changes in the entry field
        self.server_port_entry = tk.Entry(self.root, textvariable=self.server_port, width=5)
        #self.server_port_entry.pack()
        
        
        # Entry field for timeline number
        self.timeline_label = tk.Label(self.root, text="Timeline Number:", padx=15)
        #self.timeline_label.pack()
        self.timeline_entry = tk.Entry(self.root, width=5)
        #self.timeline_entry.pack()
        
        # Entry field for layer number
        self.layer_label = tk.Label(self.root, text="Layer Number:", padx=15)
        #self.layer_label.pack()
        self.layer_entry = tk.Entry(self.root, width=5)
        #self.layer_entry.pack()
        
        # Entry field for resource name
        self.resource_label = tk.Label(self.root, text="Resource Name:", padx=15)
        #self.resource_label.pack()
        self.resource_entry = tk.Entry(self.root, width=30)
        #self.resource_entry.pack()

        # Initialize the Widget
        self.root.mainloop()

    # Config Server Address
    def on_server_address_change(self, event):
        self.SERVER_ADDRESS = self.server_address.get()
        print("Server address updated:", self.SERVER_ADDRESS)
    
    # Config Server Port
    def on_server_port_change(self, event):
        try:
            self.SERVER_PORT = int(self.server_port.get())
            print("Server port updated:", self.SERVER_PORT)
        except ValueError:
            print("Invalid port number")

    # Define Color Picker Function 
    def pick_color_from_screen(self):
        self.first_click = True
        self.pick_button.config(state=tk.DISABLED)
        self.listener = Listener(on_click=self.get_mouse_click)
        self.listener.start()

    # Define Mouse Click
    def get_mouse_click(self, x, y, button, pressed):
        if pressed: # and not self.first_click:
            color = pyautogui.screenshot().getpixel((x, y))  # Get the color of the pixel at the clicked position
            hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2])  # Convert RGB to hexadecimal
            self.pick_button.config(bg=hex_color)
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

    # Define Compere Sender Messages
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

# Create an instance of the ColorPickerApp class
app = ColorPickerApp()
