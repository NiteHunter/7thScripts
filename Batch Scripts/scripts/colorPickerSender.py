import tkinter as tk
from tkinter import colorchooser

def choose_color():
    color = colorchooser.askcolor(title="Choose color")
    if color[1]:  # Check if a color was chosen
        color_label.config(text=f"Selected color: {color[1]}", bg=color[1])
        red_value.set(int(color[0][0] * 4096 / 255))
        green_value.set(int(color[0][1] * 4096 / 255))
        blue_value.set(int(color[0][2] * 4096 / 255))

def update_text():
    text = text_var.get()
    final_text.set(text)

# Create the main application window
root = tk.Tk()
root.title("Color Picker")

# Create a button to launch the color picker dialog
choose_button = tk.Button(root, text="Choose Color", command=choose_color)
choose_button.pack(pady=10)

# Label to display the selected color
color_label = tk.Label(root, text="Selected color: ", bg="white")
color_label.pack(pady=10)

# Variables to store the values of red, green, and blue
red_value = tk.IntVar()
green_value = tk.IntVar()
blue_value = tk.IntVar()

# Labels to display the values of red, green, and blue
red_label = tk.Label(root, text="Red:", padx=10)
red_label.pack()
red_entry = tk.Entry(root, textvariable=red_value)
red_entry.pack()

green_label = tk.Label(root, text="Green:", padx=10)
green_label.pack()
green_entry = tk.Entry(root, textvariable=green_value)
green_entry.pack()

blue_label = tk.Label(root, text="Blue:", padx=10)
blue_label.pack()
blue_entry = tk.Entry(root, textvariable=blue_value)
blue_entry.pack()

# # Text entry field
# text_var = tk.StringVar()
# text_entry_label = tk.Label(root, text="Timeline:", padx=10)
# text_entry_label.pack()
# text_entry = tk.Entry(root, textvariable=text_var)
# text_entry.pack()

# Button to update text
update_button = tk.Button(root, text="Update Config", command=update_text)
update_button.pack(pady=5)

# Variable to store final text
final_text = tk.StringVar()
final_text_label = tk.Label(root, textvariable=final_text, padx=10)
final_text_label.pack()

# Run the application
root.mainloop()
