# 💾 Dot Save Manager for Godot

An addon (plugin) for Godot 4.x that registers a Global Singleton (autoload) named **DOT_save** to simplify persistent data storage using Resources (.tres).

## ⚙️ Features

- **Global Singleton:** Access your save system from any script as `DOT_save.set_value_data()` or `DOT_save.get_value_data(...)`.
- **Resource-Based:** Built on top of Godot's Resource class for native, fast, and structured serialization.
- **Slot System:** Manage up to 3 save slots (`SLOTS.SPACE_1`, `SPACE_2`, `SPACE_3`) with built-in slot switching.
- **Debugging Mode:** Toggle between `user://` and `res://` paths to inspect your save files directly in the editor.
- **Ready to Use:** Includes both the `DOT_save.gd` logic and the `DOT_resource_save` resource class. The plugin auto-registers the singleton.

## 🚀 Installation and Usage

### 1. Installation

1. Download the `addons/dot_save_manager` folder.
2. Copy the folder into your Godot project's `addons/` directory.
3. Go to **Project > Project Settings > Plugins**.
4. Find **"DOT_save Manager"** and ensure it is **Enabled**.
5. The singleton **DOT_save** is registered automatically by the plugin — no manual Autoload setup needed.

### 2. Usage Examples

The `DOT_save` handles a dictionary named `DATA` inside a `DOT_resource_save` resource. All data is persistent once `save_data()` is called.

### A. Storing and Retrieving Data

```gdscript
var player_name
var player_coins

# Storing data in the current session
DOT_save.set_value_data("player_name", "Aris")
DOT_save.set_value_data("player_coins", 150)

# Retrieving data (with optional default value if the key doesn't exist)
player_name = DOT_save.get_value_data("player_name", "Generic Hero")
player_coins = DOT_save.get_value_data("player_coins", 0)

# NOTE: A default value can be passed to "get_value_data()" as an error handler;
# the function will return this value if the key doesn't exist in the DATA dictionary.
```

### B. Saving and Loading (Disk)

All data stored through `DOT_save.set_value_data()` is saved to the file by calling `save_data()`, this is an asynchronous operation. It is recommended to use `await` to ensure the file system has finished writing.

```gdscript
func _on_save_button_pressed():
	# Save current memory data to "user://Save_0.tres" -> Default path
	await DOT_save.save_data()
	print("Game Saved Successfully!")

func _on_load_button_pressed():
	# Load existing data from disk into memory
	DOT_save.load_data()
```

### C. Slots and File Management

```gdscript
# Change the active slot using the SLOTS enum
DOT_save.change_slot(DOT_save.SLOTS.SPACE_2)
# Path becomes "user://Save_2.tres"

# Change the base file name
DOT_save.change_file_name("MyGameSave")
# Path becomes "user://MyGameSave_2.tres"

# Wipe current slot data
DOT_save.delete_data()

# Creates a fresh (empty) data instance for the current slot, without touching the file on disk.
DOT_save.create_new_temporal_data()
```

### D. Debugging Mode

This is extremely useful during development to see your save files directly in the Godot FileSystem dock.

```gdscript
# Switch path from "user://" to "res://"
DOT_save.debugging(true)
```

## 📑 API Reference

### 1. Methods

| Method                              | Returns      | Description                                                                      |
| ----------------------------------- | ------------ | -------------------------------------------------------------------------------- |
| `set_value_data(key, value)`        | `void`       | Stores a value in the DATA dictionary of the current slot.                       |
| `get_value_data(key, default)`      | `Variant`    | Retrieves a value from the DATA dictionary. Returns `default` if the key doesn't exist. |
| `save_data(time_to_deferred)`       | `Error`      | (Async) Saves the current slot to disk. Emits `data_is_saving` before saving.    |
| `load_data()`                       | `void`       | Loads the current slot from disk. Emits `data_is_loading` after loading.         |
| `change_slot(SLOTS)`                | `void`       | Updates the active slot using the SLOTS enum and refreshes the file path.        |
| `change_file_name(str)`             | `void`       | Changes the base file name (without extension). Default is "Save". Call at start.|
| `delete_data()`                     | `Error`      | (Async) Deletes the data and the file on disk for the current slot.              |
| `get_all_data_from_slot(slot)`      | `Dictionary` | Returns the entire DATA dictionary from the given slot (defaults to current).    |
| `create_new_temporal_data()`        | `void`       | Creates a fresh (empty) data instance for the current slot, without touching the file on disk.|
| `debugging(bool)`                   | `void`       | If `true`, switches the save path to `res://` for editor inspection.             |

### 2. Signals

- `data_is_saving()`: Emitted before the save file is written to disk.
- `data_is_loading()`: Emitted after the save file has been loaded from disk.

### A. How to use these signals

Using these signals allows game objects to be **self-managing**. Instead of a central script manually gathering data from every node, each object (like the Player) can listen for save/load events and handle its own data independently.

#### Example: Auto-saving Player Position

By connecting to these signals, the Player node becomes responsible for its own persistence. When any part of your game triggers a save, the player will automatically "check in" its data.

```gdscript
extends Node2D # PLAYER NODE

func _ready() -> void:
	# Connect to the global DOT_save signals
	DOT_save.data_is_saving.connect(_player_on_save)
	DOT_save.data_is_loading.connect(_player_on_load)

func _player_on_save() -> void:
	# Automatically register position to memory before the file is written
	DOT_save.set_value_data("player_position", position)

func _player_on_load() -> void:
	# Automatically update position when a load is completed
	# If no data exists, it defaults to Vector2(0,0)
	position = DOT_save.get_value_data("player_position", Vector2.ZERO)
```

#### Key Benefits of this Pattern:

- **Encapsulation**: The `DOT_save` doesn't need to know the Player exists; it just broadcasts the event.
- **Scalability**: You can add as many "savable" objects as you want (NPCs, Chests, Environment states) just by connecting them to these signals.
- **Clean Code**: Keeps your save logic distributed and modular rather than having one giant, messy save function.

## ⚠️ Known Limitations & Best Practices

To ensure data integrity, keep these technical constraints in mind:

### 1. No Node Serialization

You cannot save Godot Nodes (e.g., `get_node("Player")`) directly into the DATA dictionary.

- **Why:** Nodes contain internal pointers that cannot be serialized to disk.
- **Solution:** Save only the necessary properties (e.g., `position: Vector2`, `health: int`).

### 2. Mandatory Awaiting

The `save_data()` function is asynchronous. Failing to use `await` before closing the game or changing scenes can result in corrupted save files.

- Correct Usage: `await DOT_save.save_data()`

### 3. Resource Class Stability

Changing the name of the `DOT_resource_save` class or moving the `DOT_resource_save.gd` file after your game is released will break existing save files.

- **Why:** Godot's Resource loader relies on the class path. If it changes, the ".tres" file becomes unreadable.

### 4. Dictionary & Processing Overhead

As your DATA dictionary grows, saving might become more taxing for the system.

- **Solution:** This is why the `time_to_deferred` parameter in `save_data(time_to_deferred)` exists. By passing a value (default is 0.5), you give the system a "buffer" or loading time to process the data safely before the physical write happens.

### 5. Case Sensitivity

Dictionary keys are case-sensitive. `"Health"` and `"health"` are treated as two different variables. Always stick to one naming convention to avoid data loss.
