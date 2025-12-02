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

## 📂 Project Structure

```
player/
├── scripts/
│   ├── player.gd                    # Main player controller
│   ├── state.gd                     # Base state class
│   ├── state_machine.gd             # State machine manager
│   ├── states/                      # Player states
│   │   ├── idle.gd
│   │   ├── walk.gd
│   │   ├── sprint.gd
│   │   ├── jump.gd
│   │   ├── fall.gd
│   │   ├── crouch.gd
│   │   └── reload.gd
│   └── inventory/                   # Inventory system
│       ├── item_data.gd             # Item resource definition
│       ├── inventory_item.gd        # Runtime item instance
│       └── inventory_manager.gd     # Inventory logic
├── player.tscn                      # Player scene
└── project.godot                    # Project configuration

```

## 🚀 Quick Start

### 1. Add Player to Scene
1. Instance `player.tscn` in your level
2. The player will auto-setup camera and state machine on `_ready()`

### 2. Configure Player
Select the Player node and configure export variables in the Inspector:

**Movement:**
- `walk_speed`: Base walking speed (default: 5.0)
- `sprint_speed`: Sprint speed (default: 12.0)
- `jump_velocity`: Jump height (default: 4.5)
- `can_sprint`: Enable/disable sprinting

**Camera:**
- `camera_mode`: FPS or TPS
- `camera_sensitivity`: Mouse sensitivity (default: 0.003)
- `mouse_capture_enabled`: Capture mouse on start

**Health & Stamina:**
- `max_health`: Maximum HP
- `is_stamina_enabled`: Enable stamina system
- `stamina_regen_rate`: Stamina regen per second

### 3. Inventory Usage

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

# Use item
inventory.use_item(item)  # Triggers healing
```

## 🎨 Customization

### Adding New States
1. Create a new script in `scripts/states/`:
```gdscript
extends State
class_name PlayerCustomState

@export var fallback_state: State

func enter() -> void:
    # Called when entering this state
    pass

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

### Camera Customization
Toggle between FPS and TPS at runtime:
```gdscript
player.camera_mode = Player.CameraMode.TPS  # or CameraMode.FPS
player._setup_camera()
```

## 📊 Inventory System

### Grid-Based Inventory (Tarkov-style)
```gdscript
inventory.inventory_type = InventoryManager.InventoryType.GRID
inventory.grid_width = 6
inventory.grid_height = 6
```

### Slot-Based Inventory (Minecraft-style)
```gdscript
inventory.inventory_type = InventoryManager.InventoryType.SLOT
inventory.slot_count = 20
```

### Item Properties
Items support:
- Stack size
- Weight
- Grid dimensions (for grid inventory)
- Rotation
- Durability
- Custom metadata

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

## 🤝 Contributing

When extending this system:
1. Keep state logic isolated in state scripts
2. Use signals for UI updates
3. Document new export variables with `##` comments
4. Follow the existing naming conventions

---

**Created for scalable game development in Godot 4.x**