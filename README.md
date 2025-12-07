# Awesome Player - Modular 3D Player Controller for Godot

A highly configurable, scalable 3D player controller with state machine architecture, camera systems, and inventory management for Godot 4.x.

## Features

### 🎮 Core Systems
- **State Machine Architecture**: Clean separation of player states (Idle, Walk, Sprint, Jump, Fall, Crouch, Reload)
- **First-Person Camera**: Smooth FPS camera with configurable sensitivity, FOV, and camera bobbing
- **Modular Component System**: Plug-and-play components for stats, combat, equipment, and interaction
- **Inventory System**: Flexible grid-based or slot-based inventory with optional weight management
- **Health & Stamina**: Configurable stat system with regeneration and modifiers
- **Combat System**: Weapon equipping and combat component architecture
- **Interaction System**: Raycast-based object interaction with focus/unfocus detection
- **Equipment System**: Visual equipment attachment with stat modifiers

### 🎨 Animation System
- **AnimationPlayer Support**: Play simple animations by name
- **AnimationTree Support**: Use advanced blend trees with BlendSpace2D
- **State Integration**: Each state can trigger specific animations
- **Blend Value Updates**: Automatic blend value calculation for locomotion animations

### ⚙️ Component Architecture

The player uses a modular component system for easy extension:

- **StatsComponent**: Manages health, stamina, regeneration, and stat modifiers
- **CombatComponent**: Handles weapon equipping and combat logic
- **EquipmentManager**: Manages visual equipment attachment and stat effects
- **InteractionComponent**: Raycast-based interaction system
- **InventoryManager**: Grid or slot-based inventory with weight support

### 🎒 Inventory System

Supports two inventory types:
- **Grid-based**: Tarkov-style inventory with 2D grid placement
- **Slot-based**: Minecraft-style inventory with fixed slots

Features:
- Weight management (optional)
- Item stacking
- Item metadata support
- Signal-based events for integration

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

## 🚀 Quick Start

### 1. Add Player to Scene
1. Instance `player.tscn` in your level
2. The player will auto-setup components, camera, and state machine on `_ready()`
3. Components are automatically created if not assigned in the editor

### 2. Configure Components

Components can be assigned in the editor or created automatically:

- **StatsComponent**: Configure health/stamina values and regeneration rates
- **CombatComponent**: Set up weapon manager paths
- **EquipmentManager**: Automatically finds equipment slots in Skeleton3D
- **InteractionComponent**: Configure interaction range and layer
- **InventoryManager**: Set inventory type (grid/slot) and dimensions

### 3. Configure Animations
1. Add an `AnimationPlayer` or `AnimationTree` to your player scene
2. The player automatically updates blend values for BlendSpace2D animations
3. Select each state node (Idle, Walk, etc.) and configure state-specific behavior

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

# Access inventory grid (for grid-based)
var item_at_pos = inventory.get_item_at_grid_position(Vector2i(0, 0))

# Access inventory slots (for slot-based)
var item_at_slot = inventory.get_item_at(0)
```

### 5. Equipment Usage

```gdscript
# Equip an item
var helmet_resource = load("res://resources/equipment/helmet.tres")
player.equipment.equip(helmet_resource)

# Equipment automatically applies stat modifiers and updates visuals
```

## 🎨 Customization

### Adding New States
1. Create a new script in `scripts/states/`:
```gdscript
extends State
class_name PlayerCustomState

func enter() -> void:
    # Called when state is entered
    pass

func physics_update(delta: float) -> void:
    # Handle physics and transitions
    if Input.is_action_just_pressed("custom_action"):
        state_machine.change_state(other_state)
    
    # Apply movement, etc.
    player.move_and_slide()
```

2. Add the state node to `player.tscn` under `PlayerStateMachine`
3. The script will auto-attach on runtime via `_setup_state_machine()`

### Custom Item Effects
Items can have effects applied via the Equipment system:

```gdscript
# Equipment resources can have StatModifierEffect resources attached
# These automatically apply/remove when equipment is equipped/unequipped
```

### Connecting to Signals

```gdscript
# Health/Stamina changes
player.stats.health_changed.connect(func(current, max): print("Health: ", current, "/", max))
player.stats.stamina_changed.connect(func(current, max): print("Stamina: ", current, "/", max))

# Inventory events
player.inventory.item_added.connect(func(item, slot): print("Added: ", item.data.item_name))
player.inventory.item_removed.connect(func(item, slot): print("Removed: ", item.data.item_name))

# Interaction events
player.interaction.focused.connect(func(obj): print("Focused: ", obj))
player.interaction.interacted.connect(func(obj): print("Interacted: ", obj))
```

## 🔧 Component Details

### StatsComponent
- Health and stamina management
- Automatic stamina regeneration
- Stat modifiers support
- Signals for health/stamina changes and death

### CombatComponent
- Weapon equipping/unequipping
- Weapon manager integration
- Signals for weapon changes

### EquipmentManager
- Visual mesh attachment to skeleton bones
- Stat modifier application
- Equipment slot management (Helmet, Torso, Pant, Shoe)

### InteractionComponent
- Raycast-based interaction detection
- Focus/unfocus events
- Configurable interaction range and layers

### InventoryManager
- Grid-based (2D array) or slot-based (1D array)
- Weight management
- Item stacking
- Position-based item placement

## 📝 Project Structure

```
player/
├── scripts/
│   ├── player.gd              # Main player controller
│   ├── components/           # Modular components
│   │   ├── stats_component.gd
│   │   ├── combat_component.gd
│   │   └── interaction_component.gd
│   ├── equipment_manager.gd  # Equipment system
│   ├── inventory/           # Inventory system
│   │   ├── inventory_manager.gd
│   │   ├── inventory_item.gd
│   │   └── item_data.gd
│   ├── states/               # Player states
│   │   ├── idle.gd
│   │   ├── walk.gd
│   │   ├── sprint.gd
│   │   └── ...
│   └── state_machine.gd      # State machine base
├── resources/                # Resource definitions
│   ├── equipment/
│   ├── base.gd
│   └── stat_modifier_effect.gd
└── player.tscn              # Main player scene
```

## 🔧 Debugging

Enable debug prints:
```gdscript
# Print current state
print(player.state_machine.current_state.name)

# Print inventory contents
for item in player.inventory.items:
    if item:
        print(item.data.item_name)

# Check stats
print("Health: ", player.stats.current_health, "/", player.stats.max_health)
print("Stamina: ", player.stats.current_stamina, "/", player.stats.max_stamina)
```

## 📝 License

This player controller is designed to be reusable across projects. Modify and extend as needed!
