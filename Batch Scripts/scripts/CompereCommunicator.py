import tkinter as tk
import pyautogui
import socket
import threading
import re
import json
from pynput.mouse import Listener
from tkinter import messagebox
from PIL import Image, ImageTk

class Application(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Compere Communicator")
        self.geometry("320x200")
        self.configure(bg="#555555")
        self.listener = None
        self.listener_running = False

        # CONFIG OPTIONS
        self.timeout_value = 3 # Timeout in seconds


        # Default server address and port
        self.SERVER_ADDRESS = '127.0.0.1'  # Default server address
        self.SERVER_PORT = 5584         # Default server port number
        self.connection_status = False  # Variable to track connection status
        self.timelines = []
        self.layers = []

        self.server_ip_label = tk.Label(self, text="Server IP Address:", bg=self.cget('bg'), pady=5)
        self.server_ip_label.grid(row=0, column=0, columnspan=2)
        self.server_ip_entry = tk.Entry(self, width=30)
        self.server_ip_entry.insert(0, "127.0.0.1")  # Set default value
        self.server_ip_entry.grid(row=0, column=2, columnspan=2)

        self.server_port_label = tk.Label(self, text="Server Port:", bg=self.cget('bg'), pady=10)
        self.server_port_label.grid(row=1, column=0, columnspan=2)
        self.server_port_entry = tk.Entry(self, width=30)
        self.server_port_entry.insert(0, "5584")  # Set default value
        self.server_port_entry.grid(row=1, column=2, columnspan=2)

        self.connect_button = tk.Button(self, text="Connect to Server", bg="#777777", command=self.toggle_connection)
        self.connect_button.grid(row=2, column=0, columnspan=4, sticky="s")

        self.options = ["ColorPicker", "TimelineFader", "FutureUse"]
        self.selected_option = tk.StringVar(self)
        self.selected_option.set(self.options[0])

        self.option_label = tk.Label(self, text="Select Option:", bg=self.cget('bg'), pady=20)
        self.option_label.grid(row=3, column=0, columnspan=2)
        self.option_menu = tk.OptionMenu(self, self.selected_option, *self.options)
        self.option_menu.config(bg="#777777", width=25, border=2, highlightbackground="black")
        self.option_menu.grid(row=3, column=2, columnspan=2)

        self.create_widget_button = tk.Button(self, text="Create Widget", bg="#777777", command=self.create_widget)
        self.create_widget_button.grid(row=4, column=0, columnspan=4, sticky="s")

        self.test_button = tk.Button(self, text="Test Button", bg="#777777", command=self.send_message_get_layers)
        self.test_button.grid(row=5, column=0, columnspan=4, sticky="s")

    def toggle_connection(self):
        if not self.connection_status:
            self.establish_connection()  # Connect if not connected
            self.connect_button.config(text="Disconnect from Server")  # Change button text
            self.server_ip_entry.config(state="disabled")
            self.server_port_entry.config(state="disabled")  
        else:
            self.close_connection()  # Disconnect if connected
            self.timelines = []
            self.connect_button.config(text="Connect to Server")  # Change button text
            self.server_ip_entry.config(state="normal")
            self.server_port_entry.config(state="normal")

        # Toggle connection status
        self.connection_status = not self.connection_status

    def establish_connection(self):
        try:
            # Establish connection
            self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.client_socket.connect((self.SERVER_ADDRESS, self.SERVER_PORT))
            self.send_message_timeline_count()
            # messagebox.showinfo("Connection Test", f"Connected to server: {self.SERVER_ADDRESS}:{self.SERVER_PORT}")
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

    def start_listener(self):
        self.listener = Listener(on_click=ColorPickerWidget.get_mouse_click)

    def create_widget(self):
        selected_option = self.selected_option.get()
        if selected_option == "ColorPicker":
            self.create_color_picker_widget(self.timelines)
        if selected_option == "TimelineFader":
            self.create_timeline_fader_widget()
    
    def create_color_picker_widget(self, timelines):
        if not self.connection_status:
            pass
        else:
            root = tk.Toplevel(self)
            color_picker_widget = ColorPickerWidget(root, timelines)
    
    def create_timeline_fader_widget(self):
        if not self.connection_status:
            pass
        else:
            master = tk.Toplevel(self)
            timeline_fader_widget = TimelineFaderWidget(master)
    
    def receive_netstring_response(self):
        data = self.client_socket.recv(4096).decode()
        print("Server response:", data)

    def send_message_timeline_count(self):
        message = '{"type": "request","cookie": 1,"caller-id": "CompereCommunicator","command": "get-extended-status","path": "TimelineGroupObject","params": {}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)

            # Set a timeout for the socket
            self.client_socket.settimeout(self.timeout_value)

            # Receive and print the server response
            response = b""
            while True:
                try:
                    data = self.client_socket.recv(4096)
                    if not data:
                        break
                    response += data
                except socket.timeout:
                    print("Socket timeout occurred. No more data to receive.")
                    break
                
            print("Server response:", response.decode())

            # self.close_connection()

            self.parse_timelines(response)
            print(self.timelines)

        except Exception as e:
            print("Error:", e)
    
    def parse_timelines(self, response):
        try:
            # Split the response by commas to separate the netstring encapsulated JSONs
            response_d = response.decode()
            response_string = response_d.split('"caller-id":"CompereCommunicator","cookie":1},')
            netstring = response_string[1]
            json_string = self.trim_string(netstring)
            # print(json_string)
            json_converted_string = json.loads(json_string)
            
            for child in json_converted_string['TimelineGroupObject']['children']:
                if 'TimelineStatusObject' in child:
                    name_value = child['TimelineStatusObject']['children'][0]['name']['value']
                    self.timelines.append(name_value)
            
            print("Timeline Array:")
            return self.timelines
        
        except Exception as e:
            print("Error parsing timelines:", e)
            return None
        
    def send_message_get_layers(self):
        message = '{"type": "request","cookie": 1,"caller-id": "CompereCommunicator","command": "get","path": "Timelines/Timeline 1","params": {}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)

            # Set a timeout for the socket
            self.client_socket.settimeout(self.timeout_value)

            # Receive and print the server response
            response = b""
            while True:
                try:
                    data = self.client_socket.recv(4096)
                    if not data:
                        break
                    response += data
                except socket.timeout:
                    print("Socket timeout occurred. No more data to receive.")
                    break
                
            print("Server response:", response.decode())

            # self.close_connection()

            self.parse_layers(response)
            print(self.layers)

        except Exception as e:
            print("Error:", e)
    
    def parse_layers(self, response):
        try:
            # Split the response by commas to separate the netstring encapsulated JSONs
            response_d = response.decode()
            response_string = response_d.split('"caller-id":"CompereCommunicator","cookie":1},')
            netstring = response_string[1]
            json_string = self.trim_string(netstring)
            # print(json_string)
            json_converted_string = json.loads(json_string)
            
            for child in json_converted_string['Timeline']['children']:
                if 'Timeline' in child:
                    name_value = child['Timeline']['children'][0]['name']['value']
                    self.layers.append(name_value)
            
            print("Layer Array:")
            return self.layers
        
        except Exception as e:
            print("Error parsing layers:", e)
            return None

    def trim_string(self, input_string):
        # Find the position of the first ":" and the last ","
        first_colon_index = input_string.find(":")
        last_comma_index = input_string.rfind(",")
        
        # Check if both ":" and "," are found in the string
        if first_colon_index != -1 and last_comma_index != -1:
            # Extract the substring between ":" and ","
            trimmed_string = input_string[first_colon_index + 1:last_comma_index]
            return trimmed_string
        else:
            # Return original string if ":" or "," not found
            return input_string

        
class ColorPickerWidget:
    def __init__(self, root, timelines):
        # Build Widget
        self.root = root
        self.root.title("7thChromaSender")
        self.root.configure(bg="#555555")
        self.root.geometry("540x540")
        self.first_click = True
        self.timelines = timelines

        # Variables to store the values of red, green, and blue
        self.hex_value = tk.StringVar()
        self.red_value = tk.StringVar()
        self.green_value = tk.StringVar()
        self.blue_value = tk.StringVar()
        self.tolerance_value = tk.IntVar()
        
        # Color Picker
        self.pick_button = tk.Button(self.root, text="Pick a Color from Screen", command=self.pick_color_from_screen)
        self.pick_button.grid(row=0, column=1, sticky="w", padx=40, pady=(20, 20))

        # Hex
        self.hex_label = tk.Label(self.root, text="Hex:", font=("Arial", 16), bg=self.root.cget('bg'), fg="black")
        self.hex_label.grid(row=1, column=0, sticky="e", padx=(10, 0))
        self.hex_entry = tk.Entry(self.root, textvariable=self.hex_value, width=58)
        self.hex_entry.grid(row=1, column=1, sticky="w", padx=(0, 10))

        # Entry field for timeline number
        self.timeline_label = tk.Label(self.root, text="Timeline Name:", font=("Arial", 16), bg=self.root.cget('bg'))
        self.timeline_label.grid(row=2, column=0, sticky="e", padx=(10, 0))
        self.selected_timeline = tk.StringVar(root)
        self.selected_timeline.set(self.timelines[0])
        self.timeline_menu = tk.OptionMenu(self.root, self.selected_timeline, *self.timelines)
        self.timeline_menu.config(bg="#777777", width=58, border=2, highlightbackground="black")
        #self.timeline_entry = tk.Entry(self.root, width=58)
        #self.timeline_entry.insert(0, "Timeline 1")  # Set default value
        self.timeline_menu.grid(row=2, column=1, sticky="w", padx=(0, 10))
        
        # Entry field for layer number
        self.layer_label = tk.Label(self.root, text="Layer Name:", font=("Arial", 16), bg=self.root.cget('bg'))
        self.layer_label.grid(row=3, column=0, sticky="e", padx=(10, 0))
        self.layer_entry = tk.Entry(self.root, width=58)
        self.layer_entry.insert(0, "Layer 1")  # Set default value
        self.layer_entry.grid(row=3, column=1, sticky="w", padx=(0, 10))
        
        # Entry field for resource name
        self.resource_label = tk.Label(self.root, text="Resource Name:", font=("Arial", 16), bg=self.root.cget('bg'))
        self.resource_label.grid(row=4, column=0, sticky="e", padx=(10, 0))
        self.resource_entry = tk.Entry(self.root, width=58)
        self.resource_entry.grid(row=4, column=1, sticky="w", padx=(0, 10))

        # Slider for Tolerance
        self.tolerance_label = tk.Label(self.root, text="Tolerance:", font=("Arial", 16), bg=self.root.cget('bg'), fg="black")
        self.tolerance_label.grid(row=5, column=0, sticky="e", padx=(10, 0))
        self.tolerance_entry = tk.Entry(self.root, textvariable=self.tolerance_value, width=58)
        self.tolerance_entry.grid(row=5, column=1, sticky="w", padx=(0, 10))
        self.slider_tolerance = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_tolerance, length=500, border=4, background="grey", highlightbackground="black")
        self.slider_tolerance.grid(row=6, column=0, columnspan=2, sticky="w", padx=10)

        # Red
        self.red_label = tk.Label(self.root, text="Red:", font=("Arial", 16), bg=self.root.cget('bg'), fg="red")
        self.red_label.grid(row=7, column=0, sticky="e", padx=(10, 0))
        self.red_entry = tk.Entry(self.root, textvariable=self.red_value, width=58)
        self.red_entry.grid(row=7, column=1, sticky="w", padx=(0, 10))
        self.slider_red = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_red, length=500, border=4, background="red", highlightbackground="black")
        self.slider_red.grid(row=8, column=0, columnspan=2, sticky="w", padx=(10, 10))

        # Green
        self.green_label = tk.Label(self.root, text="Green:", font=("Arial", 16), bg=self.root.cget('bg'), fg="green")
        self.green_label.grid(row=9, column=0, sticky="e", padx=(10, 0))
        self.green_entry = tk.Entry(self.root, textvariable=self.green_value, width=58)
        self.green_entry.grid(row=9, column=1, sticky="w", padx=(0, 10))
        self.slider_green = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_green, length=500, border=4, background="green", highlightbackground="black")
        self.slider_green.grid(row=10, column=0, columnspan=2, sticky="w", padx=(10, 10))

        # Blue
        self.blue_label = tk.Label(self.root, text="Blue:", font=("Arial", 16), bg=self.root.cget('bg'), fg="blue")
        self.blue_label.grid(row=11, column=0, sticky="e", padx=(10, 0))
        self.blue_entry = tk.Entry(self.root, textvariable=self.blue_value, width=58)
        self.blue_entry.grid(row=11, column=1, sticky="w", padx=(0, 10))
        self.slider_blue = tk.Scale(self.root, from_=0, to=4096, orient=tk.HORIZONTAL, command=self.send_message_blue, length=500, border=4, background="blue", highlightbackground="black")
        self.slider_blue.grid(row=12, column=0, columnspan=2, sticky="w", padx=(10, 10))

        self.listener = None
        self.listener_running = False  # Initialize listener_running attribute

    def pick_color_from_screen(self):
        if not self.listener_running:  # Check if the listener is already running
            self.start_listener()
            self.listener_running = True
        self.first_click = True
        self.pick_button.config(state=tk.DISABLED)

    def get_mouse_click(self, x, y, button, pressed):
        if pressed:
            color = pyautogui.screenshot().getpixel((x, y))
            hex_color = '#{:02x}{:02x}{:02x}'.format(color[0], color[1], color[2])
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
            self.listener_running = False  # Reset listener_running
        else:
            self.first_click = False
    
    def start_listener(self):
        self.listener = Listener(on_click=self.get_mouse_click)
        self.listener.start()
    
    
    def send_message_tolerance(self, event):
        layer_number = self.layer_entry.get()
        resource_name = self.resource_entry.get()
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + str(self.selected_timeline.get()) + '/' + layer_number + '/LayerResourceSet/' + resource_name + '","params":{"keyingTolerance":"'+str(self.slider_tolerance.get())+'"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.root.master.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.root.master.client_socket.connect((self.root.master.SERVER_ADDRESS, self.root.master.SERVER_PORT))
            self.root.master.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)
    
    def send_message_red(self, event):
        layer_number = self.layer_entry.get()
        resource_name = self.resource_entry.get()
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + str(self.selected_timeline.get()) + '/' + layer_number + '/LayerResourceSet/' + resource_name + '","params":{"redValue":"'+str(self.slider_red.get())+'"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.root.master.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.root.master.client_socket.connect((self.root.master.SERVER_ADDRESS, self.root.master.SERVER_PORT))
            self.root.master.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)

    def send_message_green(self, event):
        layer_number = self.layer_entry.get()
        resource_name = self.resource_entry.get()
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + str(self.selected_timeline.get()) + '/' + layer_number + '/LayerResourceSet/' + resource_name + '","params":{"greenValue":"'+str(self.slider_green.get())+'"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.root.master.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.root.master.client_socket.connect((self.root.master.SERVER_ADDRESS, self.root.master.SERVER_PORT))
            self.root.master.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)

    def send_message_blue(self, event):
        layer_number = self.layer_entry.get()
        resource_name = self.resource_entry.get()
        message = '{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"' + str(self.selected_timeline.get()) + '/' + layer_number + '/LayerResourceSet/' + resource_name + '","params":{"blueValue":"'+str(self.slider_blue.get())+'"}}'
        payload = str(len(message)) + ":" + message + ","
        try:
            self.root.master.client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.root.master.client_socket.connect((self.root.master.SERVER_ADDRESS, self.root.master.SERVER_PORT))
            self.root.master.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)
        except Exception as e:
            print("Error:", e)


class TimelineFaderWidget:
    def __init__(self, root):
        self.root = root
        self.root.title("Opacity Sliders")
        self.root.configure(bg="#555555")
        self.slider_values = {}
        self.sliders = self.root.master.timelines
        self.create_sliders()
    
    def create_sliders(self):
        # Create sliders and timeline names horizontally
        for index, timeline_name in enumerate(self.sliders, start=0):
            slider = tk.Scale(self.root, from_=1.0, to=0.0, resolution=0.01, orient=tk.VERTICAL, length=150)
            slider.grid(row=0, column=index, pady=(10, 0), padx=(5, 5))  # Use index instead of timeline_name
            # self.sliders[index] = slider  # Store the slider in the dictionary using index
            #self.slider_values[index] = 0  # Initialize slider values
            label = tk.Label(self.root, text=f"{timeline_name} Opacity")
            label.grid(row=1, column=index, padx=(10, 0), pady=(0, 10))
            button = tk.Button(self.root, text="Animate", command=lambda tl=index: self.move_slider(tl))
            button.grid(row=2, column=index, padx=(10, 0), pady=(0, 10))
    
    def send_message_opacity(self, timeline_number):
        # Construct the message
        message = '{{"type":"request","cookie":1,"caller-id":"python","command":"set","path":"Timelines/Timeline {}/Opacity","params":{{"opacity":"{}"}}}}'.format(timeline_number, self.slider_values[timeline_number])
        # Construct the payload
        payload = str(len(message)) + ":" + message + ","
        try:
            self.root.master.client_socket.sendall(payload.encode())
            print("Message sent to server:", payload)

        except Exception as e:
            print("Error:", e)     
 
    def move_slider(self, timeline_number):
        slider = self.sliders[timeline_number]
        current_value = self.slider_values[timeline_number]
        new_value = 1 - current_value  # Toggle between 0 and 1
        slider.set(new_value)
        self.slider_values[timeline_number] = new_value
        threading.Thread(target=self.send_message_opacity, args=(timeline_number,)).start()


if __name__ == "__main__":
    app = Application()
    app.mainloop()
