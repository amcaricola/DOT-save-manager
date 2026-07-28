# 💾 Dot Save Manager for Godot

An addon (plugin) for Godot 4.x that registers a Global Singleton (autoload) named **DOT_save** to simplify persistent data storage using a **JSON-based** format with optional AES-256 encryption.

> **Version 2.0.0** — See [Breaking Changes](#migration-from-v1x-to-v2) below if upgrading from v1.x.

## ⚙️ Features

- **Global Singleton:** Access your save system from any script as `DOT_save.set_value_data()` or `DOT_save.get_value_data(...)`.
- **JSON Serialization:** Saves data as `.json` files instead of `.tres` — more portable, human-readable, and encryption-friendly.
- **Type-Preserving Transformer:** All Godot types (Vector2/3/4, Color, Dictionary, Array, Resources, etc.) are safely serialized and deserialized without data loss.
- **AES-256 Encryption:** Optional encryption via Godot's `FileAccess.open_encrypted_with_pass()`. Toggle on/off and set your own key.
- **Configuration Panel:** An editor dock panel where you can change file name, encryption toggles, debug mode, and resource security settings — all without touching code.
- **Slot System:** Manage up to 3 save slots (`SLOTS.SPACE_0`, `SPACE_1`, `SPACE_2`) with built-in slot switching.
- **Signals:** `data_is_saving()` and `data_is_loading()` allow any node to self-manage its persistence.
- **Debugging Mode:** Switch between `user://` and `res://` paths from the dock panel to inspect save files directly in the editor.
- **Security Hardening:** Loading Resources from `user://` is **disabled by default** to prevent malicious file injection. Can be explicitly enabled in the panel.
- **Ready to Use:** Includes everything — the `DOT_save.gd` logic, the `_json_transformer_DOT` serializer, the configuration panel, and the `DOT_resource_save` resource class. The plugin auto-registers the singleton.

## 🚀 Installation and Usage

### 1. Installation

1. Download the `addons/dot_save_manager` folder.
2. Copy the folder into your Godot project's `addons/` directory.
3. Go to **Project > Project Settings > Plugins**.
4. Find **"DOT_save Manager"** and ensure it is **Enabled**.
5. The singleton **DOT_save** is registered automatically by the plugin — no manual Autoload setup needed.

### 2. Configuration Panel

Once enabled, look for the **DOT_save** panel in the left upper dock of the editor:

| Setting | Description | Default |
|---|---|---|
| **Debug (Test)** | Use `res://` instead of `user://` for easy file inspection | `true` |
| **File Name** | Base name for save files (final path: `{folder}/{name}_{slot}.json`) | `"Save"` |
| **Encrypt** | Enable AES-256 encryption on save files | `false` |
| **Encrypt key** | Password used for encryption / decryption | `"json_transformer_key"` |
| **Allow `user://` Resource load** | Permit loading `.tres`/`.res` files from `user://` (security risk) | `false` |

Click **Apply changes** to persist your settings.

### 3. Usage Examples

The `DOT_save` handles a dictionary named `DATA` inside a `_resource_save_DOT` resource. All data is persistent once `save_data()` is called.

#### A. Storing and Retrieving Data

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

#### B. Saving and Loading (Disk)

All data stored through `DOT_save.set_value_data()` is saved to the file by calling `save_data()`, this is an asynchronous operation. It is recommended to use `await` to ensure the file system has finished writing.

```gdscript
func _on_save_button_pressed():
	# Save current memory data to "user://Save_0.json" -> Default path
	await DOT_save.save_data()
	print("Game Saved Successfully!")

func _on_load_button_pressed():
	# Load existing data from disk into memory
	await DOT_save.load_data()
```

#### C. Slots and File Management

```gdscript
# Change the active slot using the SLOTS enum
DOT_save.change_slot(DOT_save.SLOTS.SPACE_1)
# Path becomes "user://Save_1.json"

# Wipe current slot data (overwrites the file on disk with an empty save)
DOT_save.delete_data()

# Creates a fresh (empty) data instance for the current slot, without touching the file on disk.
DOT_save.create_new_temporal_data()

# Read all data from a slot without switching to it
var slot_data = DOT_save.get_all_data_from_slot(DOT_save.SLOTS.SPACE_2)
```

> **Note:** The base file name and debug mode are configured from the **DOT_save** editor dock panel (see [Configuration Panel](#2-configuration-panel)), not from code.

#### D. Debugging Mode

Debug mode toggles the save path between `user://` and `res://`, so you can see your save files directly in the Godot FileSystem dock. Toggle it from the **DOT_save** → **Debug (Test)** checkbox in the editor panel. When **checked (true)** the path is `res://`; when **unchecked (false)** the path is `user://`.

## 📑 API Reference

### 1. Methods

| Method                              | Returns      | Description                                                                      |
| ----------------------------------- | ------------ | -------------------------------------------------------------------------------- |
| `set_value_data(key, value)`        | `void`       | Stores a value in the DATA dictionary of the current slot.                       |
| `get_value_data(key, default)`      | `Variant`    | Retrieves a value from the DATA dictionary. Returns `default` if the key doesn't exist. |
| `save_data(time_to_deferred)`       | `Error`      | (Async) Saves the current slot to disk. Emits `data_is_saving` before saving. Accepts optional deferred time (default 0.5s). |
| `load_data()`                       | `Error`      | Loads the current slot from disk. Emits `data_is_loading` after loading.         |
| `change_slot(SLOTS)`                | `void`       | Updates the active slot using the SLOTS enum and loads its data.                 |
| `delete_data()`                     | `Error`      | Clears all data from the current slot and overwrites the file on disk with an empty save. |
| `get_all_data_from_slot(slot)`      | `Dictionary` | Returns the entire DATA dictionary from the given slot (defaults to current).    |
| `create_new_temporal_data()`        | `void`       | Creates a fresh (empty) data instance for the current slot, without touching the file on disk. |

### 2. Signals

- `data_is_saving()`: Emitted before the save file is written to disk.
- `data_is_loading()`: Emitted after the save file has been loaded from disk.

#### A. How to use these signals

Using these signals allows game objects to be **self-managing**. Instead of a central script manually gathering data from every node, each object (like the Player) can listen for save/load events and handle its own data independently.

##### Example: Auto-saving Player Position

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

##### Key Benefits of this Pattern:

- **Encapsulation**: The `DOT_save` doesn't need to know the Player exists; it just broadcasts the event.
- **Scalability**: You can add as many "savable" objects as you want (NPCs, Chests, Environment states) just by connecting them to these signals.
- **Clean Code**: Keeps your save logic distributed and modular rather than having one giant, messy save function.

## 🔐 Resource-to-JSON Transformer

Version 2.0 introduces `_json_transformer_DOT`, a static utility that converts Godot types to JSON-safe arrays and back. Every value stored in the DATA dictionary is transformed into a `[value, TYPE_CONSTANT]` tuple, preserving its exact type.

**Supported types:**
- `null`, `bool`, `int`, `float`, `String`
- `Vector2`, `Vector2i`, `Vector3`, `Vector3i`, `Vector4`, `Vector4i`
- `Color`
- `Dictionary` (recursive)
- `Array` (recursive)
- `Resource` (stored as its `resource_path`)

**Security:** When loading a Resource from a `user://` path, the system checks the `ALLOW_USER_RESOURCE` setting. If disabled (default), the resource is silently returned as `null`. This prevents loading malicious files from user-modified save data.

## ⚠️ Known Limitations & Best Practices

To ensure data integrity, keep these technical constraints in mind:

### 1. No Node Serialization

You cannot save Godot Nodes (e.g., `get_node("Player")`) directly into the DATA dictionary.

- **Why:** Nodes contain internal pointers that cannot be serialized to disk.
- **Solution:** Save only the necessary properties (e.g., `position: Vector2`, `health: int`).

### 2. Mandatory Awaiting

Both `save_data()` and `load_data()` are asynchronous. Failing to use `await` before closing the game or changing scenes can result in corrupted save files or reading stale data.

- Correct Usage: `await DOT_save.save_data()` and `await DOT_save.load_data()`

### 3. Encryption Toggle Breaks Existing Saves

Switching **encryption on or off** between game versions will break existing save files. A plaintext JSON file and an AES-256 encrypted file use different underlying formats — Godot's `open_encrypted_with_pass()` cannot read a plain file, and `open()` cannot read an encrypted one. The system will treat the old saves as missing or corrupted.

- **Solution:** Pick one setting at release and never change it. If you must change it, ship a one-time migration script that reads old saves and re-writes them with the new setting, or accept that players will lose their progress.

### 4. Encryption Key

The encryption key is stored in plaintext in `_config_DOT.cfg`. This is suitable for **obfuscation and basic protection**, not high-security. Do not rely on it for sensitive data.

### 5. Dictionary & Processing Overhead

As your DATA dictionary grows, saving might become more taxing for the system.

- **Solution:** This is why the `time_to_deferred` parameter in `save_data(time_to_deferred)` exists. By passing a value (default is 0.5), you give the system a "buffer" or loading time to process the data safely before the physical write happens.

### 6. Case Sensitivity

Dictionary keys are case-sensitive. `"Health"` and `"health"` are treated as two different variables. Always stick to one naming convention to avoid data loss.

## 🔄 Migration from v1.x to v2

If you are upgrading from version 1.x, please be aware of the following **breaking changes**:

| v1.x | v2.0 | Action Required |
|---|---|---|
| `DOT_save.DEBUG(bool)` | Removed. Debug mode is now set exclusively from the editor dock panel. | Remove all calls to `DOT_save.DEBUG(...)`. Toggle debug via the **DOT_save** panel in the editor. |
| `DOT_save.debugging(bool)` | Removed. Debug mode is now set exclusively from the editor dock panel. | Remove all calls to `DOT_save.debugging(...)`. Toggle debug via the **DOT_save** panel in the editor. |
| `DOT_save.change_file_name(str)` | Removed. File name is now configured from the editor dock panel. | Remove all calls to `DOT_save.change_file_name(...)`. Set the file name via the **DOT_save** panel. |
| Save files in `.tres` format | Save files are now `.json` format. | Existing `.tres` saves are **not compatible**. You will need to migrate manually or start fresh. |
| `save_data()` (no params) | `save_data(time_to_deferred := 0.5)` | Fully backward-compatible (default parameter). No action needed. |
| `load_data()` returned `void` | `load_data()` returns `Error` and emits `data_is_loading` signal. | Check return value if needed. If your code connected to a signal named `data_is_loading`, it will now fire. |
| No encryption | Optional AES-256 encryption. | No action needed (disabled by default). |
| No configuration panel | Editor dock with 5 settings. | No action needed (defaults are sensible). |
| Resource loading unrestricted | `ALLOW_USER_RESOURCE` defaults to `false`. | If you load Resources from `user://` in your save data, enable the setting in the dock panel or set `ALLOW_USER_RESOURCE = true` in `_config_DOT.cfg`. |

### Quick Migration Checklist

1. Remove any calls to `DOT_save.DEBUG(...)`, `DOT_save.debugging(...)`, and `DOT_save.change_file_name(...)` — these methods no longer exist. Configure debug mode and file name via the **DOT_save** editor panel instead.
2. Export your existing save data to the new format, or accept that old saves will not carry over.
3. If you relied on loading Resources from `user://` via save data, enable the **Allow user:// Resource load** option in the DOT_save panel.
4. Review any save/load scripts to take advantage of the new signals for cleaner architecture.
