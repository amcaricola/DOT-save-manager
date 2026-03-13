# #💾 Simple Save Tool Addon for Godot

An addon (plugin) for Godot 4.x that implements a Global Singleton (autoload) named **SAVE_MANAGER** to simplify persistent data storage using Resources (.tres).

## ##⚙️ Features

- **Global Singleton:** Access your save system from any script as `SAVE_MANAGER.save_data()` or `SAVE_MANAGER.get_data(...)`.
- **Resource-Based:** Built on top of Godot's Resource class for native, fast, and structured serialization.
- **Slot System:** Manage multiple save files (e.g., Save_0.tres, Save_1.tres) with built-in slot switching.
- **Ready to Use:** Includes both the SaveManager.gd logic and the SAVE resource class out of the box.

## ##🚀 Installation and Usage

### 1. Installation

1.  Download the addons/simple_save_tool folder.
2.  Copy the folder into your Godot project's addons/ directory.
3.  Go to **Project > Project Settings > Plugins**.
4.  Find **"Simple Save Tool"** and ensure it is **Enabled**.
5.  Ensure **SAVE_MANAGER** is added as an **Autoload** (Project Settings > Autoload).

### 2. Usage Examples

The `SAVE_MANAGER` handles a dictionary named `DATA` inside a `SAVE` resource. All data is persistent once `save_data()` is called.

### A. Storing and Retrieving Data

```gdscript
var player_name
var player_coins

# Storing data in the current session
SAVE_MANAGER.set_data("player_name", "Aris")
SAVE_MANAGER.set_data("coins", 150)

# Retrieving data (with optional default value if the key doesn't exist)
player_name = SAVE_MANAGER.get_data("player_name", "Generic Hero")
player_coins = SAVE_MANAGER.get_data("coins", 0)

# NOTE: A default value can be passed to "get_data()" as an error handler;
# the function will return this value if the key doesn't exist in the DATA dictionary.
```

### B. Saving and Loading (Disk)

all data stored through `SAVE_MANAGER.set_data()` is saved to the file by calling `save_data() `, this is an asynchronous operation. It is recommended to use `await` to ensure the file system has finished writin

```gdscript
func _on_save_button_pressed():
	# Save current memory data to "user://Save_0.tres" -> Default path
	await SAVE_MANAGER.save_data()
	print("Game Saved Successfully!")

func _ready():
	# Load existing data from disk into memory
	SAVE_MANAGER.load_data()
```

### C. Slots and File Management

```gdscript
# Change the active slot (this automatically updates the file path)
SAVE_MANAGER.change_slot(2)
# Path becomes "user://Save_2.tres"

# Change the base file name
SAVE_MANAGER.change_file_name("MyGameSave")
# Path becomes "user://MyGameSave_2.tres"

# Wipe current slot data
SAVE_MANAGER.delete_data()
```

## ##📑 API Reference

### 1. Methods

| Method                         | Description                                                                     |
| ------------------------------ | ------------------------------------------------------------------------------- |
| `set_data(key, value)  `       | Stores a value in the dictionary.                                               |
| `get_data(key, default_value)` | Returns the value. If the key is missing, creates it with the default value.    |
| `save_data(time) `             | (Async) Saves the resource to disk. Emits `will_save_data` before saiving.      |
| `load_data()   `               | Loads the resource from the current path. Emits `load_data_done` after loading. |
| `change_slot(int)  `           | Updates the active slot and refreshes the file path.                            |
| `change_file_name(str)`        | Changes the base name of the save file.                                         |
| `delete_data()     `           | (Async) Wipes the current file and replaces it with a fresh SAVE instance.      |
| `get_all_data()  `             | Returns the entire DATA dictionary.                                             |

### 2. Signals

- `will_save_data()`: Triggered just before the ResourceSaver begins writing.
- `load_data_done()`: Triggered after the ResourceLoader has finished updating the internal resource.

### A. How to use this signals

Using this signals allow game objects to be **self-managing**. Instead of a central script manually gathering data from every node, each object (like the Player) can listen for save/load events and handle its own data independently.

#### Example: Auto-saving Player Position

By connecting to these signals, the Player node becomes responsible for its own persistence. When any part of your game triggers a save, the player will automatically "check in" its data.

```gdscript
extends Node #PLAYER NODE

var player_position : Vector2

func _ready() -> void:
	# Connect to the global SAVE_MANAGER signals
	SAVE_MANAGER.will_save_data.connect(_player_on_save)
	SAVE_MANAGER.load_data_done.connect(_player_on_load)

func _player_on_save() -> void:
	# Automatically register position to memory before the file is written
	SAVE_MANAGER.set_data("player_position", player_position)

func _player_on_load() -> void:
	# Automatically update position when a load is completed
	# If no data exists, it defaults to Vector2(0,0)
	player_position = SAVE_MANAGER.get_data("player_position", Vector2(0,0))

```

#### Key Benefits of this Pattern:

- **Encapsulation**: The `SAVE_MANAGER` doesn't need to know the Player exists; it just broadcasts the event.
- **Scalability**: You can add as many "savable" objects as you want (NPCs, Chests, Environment states) just by connecting them to these signals.
- **Clean Code**: Keeps your save logic distributed and modular rather than having one giant, messy save function.

## ⚠️ Known Limitations & Best Practices

To ensure data integrity, keep these technical constraints in mind:

### 1. No Node Serialization

You cannot save Godot Nodes (e.g., `get_node("Player")`) directly into the DATA dictionary.

- Why: Nodes contain internal pointers that cannot be serialized to disk.
- Solution: Save only the necessary properties (e.g., `position: Vector2`, `health: int`).

### 2. Mandatory Awaiting

The `save_data()` function is asynchronous. Failing to use `await` before closing the game or changing scenes can result in corrupted save files.

- Correct Usage: `await SAVE_MANAGER.save_data()`

### 3. Resource Class Stability

Changing the name of the SAVE class or moving the save.gd file after your game is released will break existing save files.

- Why: Godot's Resource loader relies on the class path. If it changes, the ".tres" file becomes unreadable.

### 4. Dictionary & Processing Overhead

As your DATA dictionary grows, saving might become more taxing for the system.

- Solution: This is why the `time` parameter in `save_data(time)` exists. By passing a `time` value (default is 0.5), you give the system a "buffer" or loading time to process the data safely before the physical write happens.

### 5. Case Sensitivity

Dictionary keys are case-sensitive. `"Health"` and `"health"` are treated as two different variables. Always stick to one naming convention to avoid data loss.
