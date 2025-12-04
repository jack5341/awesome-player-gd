# Awesome Player - Modular 3D Player Controller for Godot

A highly configurable, scalable 3D player controller with state machine architecture, camera systems, and inventory management for Godot 4.x.

## Features

### 🎮 Core Systems
- **State Machine Architecture**: Clean separation of player states (Idle, Walk, Sprint, Jump, Fall, Crouch, Reload)
- **Dual Camera Modes**: First-person (FPS) and third-person (TPS) with smooth transitions
- **Inventory System**: Flexible grid-based or slot-based inventory with weight management
- **Health & Stamina**: Configurable stat system with regeneration
- **Combat System**: Attack damage, range, cooldown, and knockback
- **Interaction System**: Raycast-based object interaction

### Equipment System
- **Equipment System**: Flexible equipment system

### 🎨 Animation System
- **AnimationPlayer Support**: Play simple animations by name
- **AnimationTree Support**: Use advanced blend trees
- **State Integration**: Each state can trigger specific animations

### 🎒 Inventory UI
- **Grid & Slot Support**: Automatically adapts to inventory type
- **Themeable**: Fully customizable via Godot Themes
- **Drag & Drop**: (Coming soon)
- **Tooltips**: Detailed item information on hover

### ⚙️ Key Input Mappings
| Action | Key | Description |
|--------|-----|-------------|
| `awesome_player_move_up` | W | Move forward |
| `awesome_player_move_down` | S | Move backward |
| `awesome_player_move_left` | A | Move left |
| `awesome_player_move_right` | D | Move right |
| `awesome_player_move_jump` | Space | Jump |
| `awesome_player_move_sprint` | Shift | Sprint |
| `awesome_player_move_crouch` | Ctrl | Crouch |
| `awesome_player_interact` | E | Interact with objects |
| `awesome_player_attack` | Left Mouse | Attack |
| `awesome_player_aim` | Right Mouse | Aim |
| `awesome_player_inventory` | Tab | Toggle inventory |

## 🚀 Quick Start

### 1. Add Player to Scene
1. Instance `player.tscn` in your level
2. The player will auto-setup camera and state machine on `_ready()`

### 2. Configure Animations
1. Add an `AnimationPlayer` or `AnimationTree` to your player scene
2. Assign it to the `Animation` section in the Player Inspector
3. Select each state node (Idle, Walk, etc.) and set the `Animation Name` property

### 3. Setup Inventory UI
1. Instance `inventory_ui.tscn` in your main UI canvas
2. Assign it to the `Inventory UI` property in the Player Inspector
3. (Optional) Create a custom Theme resource and assign it to the Inventory UI

### 4. Inventory Usage

```gdscript
# Get player's inventory
var inventory = $Player.inventory

# Create an item
var item_data = ItemData.new("health_potion", "Health Potion")
item_data.stack_size = 10
item_data.weight = 0.5
item_data.metadata["heal_amount"] = 50

var item = InventoryItem.new(item_data, 1)

# Add to inventory
if inventory.add_item(item):
    print("Item added!")
```

## 🎨 Customization

### Adding New States
1. Create a new script in `scripts/states/`:
```gdscript
extends State
class_name PlayerCustomState

@export var animation_name: String = "custom_anim"

func enter() -> void:
    if player.has_method("play_animation"):
        player.play_animation(animation_name)

func physics_update(delta: float) -> void:
    # Handle physics and transitions
    pass
```

2. Add the state node to `player.tscn` under `PlayerStateMachine`
3. The script will auto-attach on runtime

### Custom Item Effects
Override `_on_item_used()` in `player.gd`:
```gdscript
func _on_item_used(item: InventoryItem) -> void:
    if item.data.item_id == "speed_boost":
        walk_speed *= 1.5
        await get_tree().create_timer(5.0).timeout
        walk_speed /= 1.5
```

## 🔧 Debugging

Enable debug prints:
```gdscript
# Print current state
print(player.state_machine.current_state.name)

# Print inventory contents
player.inventory.print_inventory()
```

## 📝 License

This player controller is designed to be reusable across projects. Modify and extend as needed!