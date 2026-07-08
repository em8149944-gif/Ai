# 🤖 Intelligent Roblox AI Player System

A comprehensive Lua scripting system for creating intelligent AI players in Roblox games with advanced features.

## ✨ Features

### **Automatic Game Detection**
- Detects the current Roblox game
- Loads pre-configured game strategies
- Supports customizable game configs

### **Combat System**
```lua
-- Automatically detects and attacks nearby enemies
ai:detectNearbyEnemies()      -- Find enemies within range
ai:attackClosestEnemy()       -- Attack the nearest enemy
ai:onEnemyDefeated(enemy)     -- Track defeated enemies
```

### **Memory & State Management**
- Remembers visited locations with timestamps
- Tracks defeated enemies
- Stores collected items
- Maintains experience and level progress
- Full state restoration from checkpoints

```lua
ai:rememberLocation("SpawnZone", position)
ai:getMemory("experience")
ai:updateMemory("levelProgress", 5)
```

### **Checkpoint System**
```lua
ai:saveCheckpoint("Level1Complete")
ai:loadCheckpoint("Level1Complete")
ai:listCheckpoints()
```

### **Goal-Based Navigation**
```lua
ai:setObjective("defeat_enemies")
ai:moveToZone("Arena")
ai:moveToCheckpoint("SafeZone")
ai:exploreRandomZone()
```

## 📖 Usage

### Basic Setup

1. **Place the AIPlayer.lua module in ServerScriptService**
2. **Create an NPC Model** with:
   - Humanoid instance
   - HumanoidRootPart
   - Character parts (Head, Torso, Limbs)

3. **Initialize the AI**
```lua
local AIPlayer = require(game:GetService("ServerScriptService"):WaitForChild("AIPlayer"))

local npc = game.Workspace:WaitForChild("MyNPC")
local ai = AIPlayer.new(npc)

-- Start the AI
ai:start()
```

### Advanced Usage

```lua
-- Detect the game automatically
local gameName = ai:detectGame()

-- Save progress
ai:saveCheckpoint("BeforeBoss")

-- Set objectives
ai:setObjective("defeat_enemies")
ai:setObjective("collect_items")
ai:setObjective("explore")

-- Check status
ai:printStatus()

-- Load from checkpoint if defeated
ai:loadCheckpoint("BeforeBoss")
```

## 🎮 Pre-Configured Games

### Adopt Me
- Objectives: collect_pets, earn_money, explore
- Zones: School, Nursery, Shop
- No enemies

### Combat Arena
- Objectives: defeat_enemies, survive, level_up
- Zones: Spawn, Arena, Boss Room
- Has enemies: Goblin, Orc, Boss

### Obby Simulator
- Objectives: complete_levels, reach_end
- Zones: Level1, Level2, Level3
- No enemies

## 🔧 Configuration

Customize the AI by modifying:

```lua
ai.combatRange = 25              -- Distance to detect enemies
ai.pathfindingRadius = 50        -- Navigation radius
ai.updateInterval = 0.5          -- Update frequency (seconds)
```

Add custom game configurations:

```lua
GAME_CONFIGS["MyGame"] = {
    gameId = 999,
    objectives = {"objective1", "objective2"},
    zones = {
        {name = "Zone1", position = Vector3.new(0, 5, 0)},
        {name = "Zone2", position = Vector3.new(100, 5, 0)},
    },
    hasEnemies = true,
    enemies = {"Enemy1", "Enemy2"},
}
```

## 📊 Memory Structure

```lua
ai.memory = {
    visitedLocations = {
        ["LocationName"] = {
            position = Vector3,
            lastVisited = timestamp,
            visitCount = number,
        }
    },
    defeatedEnemies = {
        {
            name = "EnemyName",
            defeatedAt = timestamp,
            location = Vector3,
        }
    },
    itemsCollected = {},
    levelProgress = 0,
    health = 100,
    experience = 0,
}
```

## 🚀 Example: Full Game Loop

```lua
local AIPlayer = require(game:GetService("ServerScriptService"):WaitForChild("AIPlayer"))
local npc = game.Workspace:WaitForChild("AIBot")
local ai = AIPlayer.new(npc)

-- Setup
ai:detectGame()
ai:setObjective("explore")
ai:saveCheckpoint("StartGame")

-- Combat settings
ai.combatRange = 30
ai.updateInterval = 0.5

-- Start playing
ai:start()

-- Monitor (from another script)
while true do
    wait(5)
    ai:printStatus()
end
```

## 📝 Debug Commands

```lua
ai:printStatus()              -- Display current AI stats
ai:listCheckpoints()          -- Show all saved checkpoints
ai:detectNearbyEnemies()      -- Find nearby enemies
```

## ⚙️ State Structure

```lua
ai.state = {
    currentObjective = "explore",      -- Current goal
    currentTarget = nil,               -- Combat target
    isInCombat = false,                -- Combat status
    currentZone = "SpawnZone",         -- Current location
}
```

## 🎯 Tips

1. **Save checkpoints** before boss fights
2. **Increase combat range** for harder enemies
3. **Adjust update interval** for performance
4. **Remember locations** for fast travel
5. **Track objectives** to measure progress

## 🐛 Troubleshooting

**AI not moving?**
- Ensure HumanoidRootPart exists
- Check if zone positions are accessible

**Combat not working?**
- Verify `hasEnemies` is true for game config
- Check combat range setting

**Memory errors?**
- Ensure Humanoid exists before starting
- Use `printStatus()` to debug

---

**Created for advanced Roblox AI development** 🎮