import tkinter as tk
import pyautogui
import socket
from tkinter import messagebox
from pynput.mouse import Listener

'''
Date: 2024-03-15
Author: NH
Editor: CG
Copyright: Nah
'''

class ColorPickerApp:
    def __init__(self):

        # Build Widget
        self.root = tk.Tk()
        self.root.title("7thChromaSender")
        self.root.configure(bg="#555555",)
        self.first_click = True
        self.listener = None

        # Default server address and port
        self.SERVER_ADDRESS = '127.0.0.1'  # Default server address
        self.SERVER_PORT = 5584         # Default server port number
        self.connection_status = False  # Variable to track connection status
        self.timeline = ""
        self.layer = ""
        self.resource = ""
        
        # Variables to store the values
        self.hex_value = tk.IntVar()
        self.red_value = tk.IntVar()
        self.green_value = tk.IntVar()
        self.blue_value = tk.IntVar()
        self.red_adjust_value = tk.DoubleVar()
        self.green_adjust_value = tk.DoubleVar()
        self.blue_adjust_value = tk.DoubleVar()

        # Entry field Values
        self.red_value.trace_add("write", self.update_red_slider)
        self.green_value.trace_add("write", self.update_green_slider)
        self.red_adjust_value.trace_add("write", self.update_red_adjust_slider)
        self.green_adjust_value.trace_add("write", self.update_green_adjust_slider)
        self.blue_adjust_value.trace_add("write", self.update_blue_adjust_slider)

        # Entry field for server address
        self.server_address_label = tk.Label(self.root, text="Server Address:", font=("Arial", 12), bg=self.root.cget('bg'), padx=5)
        self.server_address_label.grid(row=0, column=0, sticky="e", padx=10, pady=(10, 5))
        self.server_address_entry = tk.Entry(self.root, textvariable=self.SERVER_ADDRESS, width=10)
        self.server_address_entry.insert(0, self.SERVER_ADDRESS)
        self.server_address_entry.grid(row=0, column=1, sticky="w", padx=10, pady=5)

        # Entry field for server port
        self.server_port_label = tk.Label(self.root, text="Server Port:", font=("Arial", 12), bg=self.root.cget('bg'), padx=5)
        self.server_port_label.grid(row=1, column=0, sticky="e", padx=10, pady=5)
        self.server_port_entry = tk.Entry(self.root, textvariable=self.SERVER_PORT, width=5)
        self.server_port_entry.insert(0, self.SERVER_PORT)
        self.server_port_entry.grid(row=1, column=1, sticky="w", padx=10, pady=5)

        # Establish Connection
        self.connect_button = tk.Button(self.root, text="Connect to Server", bg="#777777", command=self.toggle_connection)
        self.connect_button.grid(row=2, column=0, columnspan=4, sticky="s")

        # Entry field for timeline number
        self.timeline_label = tk.Label(self.root, text="Timeline:", font=("Arial", 12), bg=self.root.cget('bg'), padx=5)
        self.timeline_label.grid(row=3, column=0, sticky="e", padx=10, pady=5)
        self.timeline_entry = tk.Entry(self.root, textvariable=self.timeline, width=50)
        self.timeline_entry.grid(row=3, column=1, sticky="w", padx=10, pady=5)
        self.timeline_entry.insert(0, "Timeline 1")

        # Entry field for layer number
        self.layer_label = tk.Label(self.root, text="Layer:", font=("Arial", 12), bg=self.root.cget('bg'), padx=5)
        self.layer_label.grid(row=4, column=0, sticky="e", padx=10, pady=5)
        self.layer_entry = tk.Entry(self.root, textvariable=self.layer, width=50)
        self.layer_entry.grid(row=4, column=1, sticky="w", padx=10, pady=5)
        self.layer_entry.insert(0, "Timeline Layer 1")
        
        # Entry field for resource name
        self.resource_label = tk.Label(self.root, text="Resource:", font=("Arial", 12), bg=self.root.cget('bg'), padx=5)
        self.resource_label.grid(row=5, column=0, sticky="e", padx=10, pady=5)
        self.resource_entry = tk.Entry(self.root, textvariable=self.resource, width=50)
        self.resource_entry.grid(row=5, column=1, sticky="w", padx=10, pady=5)
        
        # Color Picker and Hex
        self.pick_button = tk.Button(self.root, text="Pick a Color from Screen", command=self.pick_color_from_screen)
        self.pick_button.grid(row=6, column=1, sticky="w", padx=80, pady=(20, 10))
        self.hex_label = tk.Label(self.root, text="Hex:", font=("Arial", 12), bg=self.root.cget('bg'), fg="black", padx=5)
        self.hex_label.grid(row=7, column=0, sticky="e", padx=10, pady=(0, 20))
        self.hex_entry = tk.Entry(self.root, textvariable=self.hex_value, width=50)
        self.hex_entry.grid(row=7, column=1, sticky="w", padx=10, pady=(0, 20))

        # Red
        self.red_label = tk.Label(self.root, text="Red:", font=("Arial", 12), bg=self.root.cget('bg'), fg="red", padx=5)
        self.red_label.grid(row=8, column=0, sticky="e", padx=10)
        self.red_entry = tk.Entry(self.root, textvariable=self.red_value, width=50)
        self.red_entry.grid(row=8, column=1, sticky="w", padx=10)
        self.slider_red = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_red, length=500, border=4, background="red", highlightbackground="black")
        self.slider_red.grid(row=9, column=0, columnspan=2, sticky="w", padx=(10, 10))

        # Green
        self.green_label = tk.Label(self.root, text="Green:", font=("Arial", 12), bg=self.root.cget('bg'), fg="green", padx=5)
        self.green_label.grid(row=10, column=0, sticky="e", padx=10)
        self.green_entry = tk.Entry(self.root, textvariable=self.green_value, width=50)
        self.green_entry.grid(row=10, column=1, sticky="w", padx=10)
        self.slider_green = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_green, length=500, border=4, background="green", highlightbackground="black")
        self.slider_green.grid(row=11, column=0, columnspan=2, sticky="w", padx=10)

        # Blue
        self.blue_label = tk.Label(self.root, text="Blue:", font=("Arial", 12), bg=self.root.cget('bg'), fg="blue", padx=5)
        self.blue_label.grid(row=12, column=0, sticky="e", padx=10)
        self.blue_entry = tk.Entry(self.root, textvariable=self.blue_value, width=50)
        self.blue_entry.grid(row=12, column=1, sticky="w", padx=10)
        self.slider_blue = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_blue, length=500, border=4, background="blue", highlightbackground="black")
        self.slider_blue.grid(row=13, column=0, columnspan=2, sticky="w", padx=10, pady=(0,20))

        # Red Adjust
        self.red_adjust_label = tk.Label(self.root, text="Red Ratio:", font=("Arial", 12), bg=self.root.cget('bg'), fg="red", padx=5)
        self.red_adjust_label.grid(row=14, column=0, sticky="e", padx=10)
        self.red_adjust_entry = tk.Entry(self.root, textvariable=self.red_adjust_value, width=50)
        self.red_adjust_entry.grid(row=14, column=1, sticky="w", padx=10)
        self.slider_red_adjust = tk.Scale(self.root, from_=0.0, to=1.0, resolution=0.002, orient=tk.HORIZONTAL, command=self.send_message_red_adjust, length=500, border=4, background="red", highlightbackground="black")
        self.slider_red_adjust.grid(row=15, column=0, columnspan=2, sticky="w", padx=10)

        # Green Adjust
        self.green_adjust_label = tk.Label(self.root, text="Green Ratio:", font=("Arial", 12), bg=self.root.cget('bg'), fg="green", padx=5)
        self.green_adjust_label.grid(row=16, column=0, sticky="e", padx=10)
        self.green_adjust_entry = tk.Entry(self.root, textvariable=self.green_adjust_value, width=50)
        self.green_adjust_entry.grid(row=16, column=1, sticky="w", padx=10)
        self.slider_green_adjust = tk.Scale(self.root, from_=0.0, to=1.0, resolution=0.002, orient=tk.HORIZONTAL, command=self.send_message_green_adjust, length=500, border=4, background="green", highlightbackground="black")
        self.slider_green_adjust.grid(row=17, column=0, columnspan=2, sticky="w", padx=10)

        # Blue Adjust
        self.blue_adjust_label = tk.Label(self.root, text="Blue Ratio:", font=("Arial", 12), bg=self.root.cget('bg'), fg="blue", padx=5)
        self.blue_adjust_label.grid(row=18, column=0, sticky="e", padx=10)
        self.blue_adjust_entry = tk.Entry(self.root, textvariable=self.blue_adjust_value, width=50)
        self.blue_adjust_entry.grid(row=18, column=1, sticky="w", padx=10)
        self.slider_blue_adjust = tk.Scale(self.root, from_=0.0, to=1.0, resolution=0.002, orient=tk.HORIZONTAL, command=self.send_message_blue_adjust, length=500, border=4, background="blue", highlightbackground="black")
        self.slider_blue_adjust.grid(row=19, column=0, columnspan=2, sticky="w", padx=10)

        # Initialize the Widget
        self.root.mainloop()


    def toggle_connection(self):
        if not self.connection_status:
            self.establish_connection()  # Connect if not connected
            self.connect_button.config(text="Disconnect from Server")  # Change button text
            self.server_address_entry.config(state="disabled")
            self.server_port_entry.config(state="disabled")  
        else:
            self.close_connection()  # Disconnect if connected
            self.timelines = []
            self.connect_button.config(text="Connect to Server")  # Change button text
            self.server_address_entry.config(state="normal")
            self.server_port_entry.config(state="normal")

        # Toggle connection status
        self.connection_status = not self.connection_status

    def establish_connection(self):
        try:
            # Establish connection
            self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.client_socket.connect((self.SERVER_ADDRESS, self.SERVER_PORT))
            messagebox.showinfo("Connection Test", f"Connected to server: {self.SERVER_ADDRESS}:{self.SERVER_PORT}")
            print("Connection Test", f"Connected to server: {self.SERVER_ADDRESS}:{self.SERVER_PORT}")
            # self.close_connection()
        except Exception as e:
            messagebox.showerror("Connection Error", f"Error connecting to server: {e}")
            print("Error:", e)
    
    def close_connection(self):
        try:
            if self.client_socket:
                # Close the socket connection
                self.client_socket.close()
                # messagebox.showinfo("Connection Closed", "Socket connection closed successfully")
                print("Connection Closed", "Socket connection closed successfully")
                self.client_socket = None  # Reset client socket
        except Exception as e:
            messagebox.showerror("Error", f"Error closing connection: {e}")
            print("Error:", e)
    
    
    # Color Field changes
    def update_red_slider(self, *args):
        self.slider_red.set(self.red_value.get())

    def update_green_slider(self, *args):
        self.slider_green.set(self.green_value.get())

    def update_blue_slider(self, *args):
        self.slider_blue.set(self.blue_value.get())

    def update_red_adjust_slider(self, *args):
        self.slider_red_adjust.set(self.red_adjust_value.get())

    def update_green_adjust_slider(self, *args):
        self.slider_green_adjust.set(self.green_adjust_value.get())

    def update_blue_adjust_slider(self, *args):
        self.slider_blue_adjust.set(self.blue_adjust_value.get())

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


    # Server Messages
    def send_message_red(self, event):
        timeline = self.timeline_entry.get()
        layer = self.layer_entry.get()
        resource = self.resource_entry.get()
        self.red_value.set(int(self.slider_red.get()))
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + timeline + '/' + layer + '/LayerResourceSet/' + resource + '","params":{"redValue":"' + str(self.slider_red.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)
    
    def send_message_green(self, event):
        timeline = self.timeline_entry.get()
        layer = self.layer_entry.get()
        resource = self.resource_entry.get()
        self.green_value.set(int(self.slider_green.get()))
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + timeline + '/' + layer + '/LayerResourceSet/' + resource + '","params":{"greenValue":"' + str(self.slider_green.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)
    
    def send_message_blue(self, event):
        timeline = self.timeline_entry.get()
        layer = self.layer_entry.get()
        resource = self.resource_entry.get()
        self.blue_value.set(int(self.slider_blue.get()))
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + timeline + '/' + layer + '/LayerResourceSet/' + resource + '","params":{"blueValue":"' + str(self.slider_blue.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)

    def send_message_red_adjust(self, event):
        timeline = self.timeline_entry.get()
        layer = self.layer_entry.get()
        resource = self.resource_entry.get()
        self.red_adjust_value.set(self.slider_red_adjust.get())
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + timeline + '/' + layer + '/LayerResourceSet/' + resource + '","params":{"redRatio":"' + str(self.slider_red_adjust.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)
    
    def send_message_green_adjust(self, event):
        timeline = self.timeline_entry.get()
        layer = self.layer_entry.get()
        resource = self.resource_entry.get()
        self.green_adjust_value.set(self.slider_green_adjust.get())
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + timeline + '/' + layer + '/LayerResourceSet/' + resource + '","params":{"greenRatio":"' + str(self.slider_green_adjust.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)
    
    def send_message_blue_adjust(self, event):
        timeline = self.timeline_entry.get()
        layer = self.layer_entry.get()
        resource = self.resource_entry.get()
        self.blue_adjust_value.set(self.slider_blue_adjust.get())
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + timeline + '/' + layer + '/LayerResourceSet/' + resource + '","params":{"blueRatio":"' + str(self.slider_blue_adjust.get()) + '"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)

# Create an instance of the ColorPickerApp class
app = ColorPickerApp()
