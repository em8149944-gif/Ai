--[[
    =====================================
    INTELLIGENT ROBLOX AI PLAYER SYSTEM
    =====================================
    
    Features:
    - Game detection and configuration
    - Combat system with enemy detection
    - Memory/state management
    - Goal-based pathfinding
    - Persistent checkpoint system
]]

local AIPlayer = {}
AIPlayer.__index = AIPlayer

-- ===== GAME CONFIGURATIONS =====
local GAME_CONFIGS = {
    ["Adopt Me"] = {
        gameId = 1,
        objectives = {"collect_pets", "earn_money", "explore"},
        zones = {
            {name = "School", position = Vector3.new(0, 5, 0)},
            {name = "Nursery", position = Vector3.new(50, 5, 0)},
            {name = "Shop", position = Vector3.new(-50, 5, 0)},
        },
        hasEnemies = false,
    },
    ["Combat Arena"] = {
        gameId = 2,
        objectives = {"defeat_enemies", "survive", "level_up"},
        zones = {
            {name = "Spawn", position = Vector3.new(0, 5, 0)},
            {name = "Arena", position = Vector3.new(100, 5, 0)},
            {name = "Boss Room", position = Vector3.new(200, 5, 0)},
        },
        hasEnemies = true,
        enemies = {"Goblin", "Orc", "Boss"},
    },
    ["Obby Simulator"] = {
        gameId = 3,
        objectives = {"complete_levels", "reach_end"},
        zones = {
            {name = "Level1", position = Vector3.new(0, 10, 0)},
            {name = "Level2", position = Vector3.new(0, 50, 0)},
            {name = "Level3", position = Vector3.new(0, 100, 0)},
        },
        hasEnemies = false,
    }
}

-- ===== AI PLAYER CLASS =====
function AIPlayer.new(npcModel)
    local self = setmetatable({}, AIPlayer)
    
    self.npc = npcModel
    self.humanoid = npcModel:FindFirstChildOfClass("Humanoid")
    self.hrp = npcModel:FindFirstChild("HumanoidRootPart")
    
    -- State Management
    self.memory = {
        visitedLocations = {},
        defeatedEnemies = {},
        itemsCollected = {},
        levelProgress = 0,
        health = 100,
        experience = 0,
    }
    
    self.state = {
        currentObjective = nil,
        currentTarget = nil,
        isInCombat = false,
        currentZone = nil,
    }
    
    self.checkpoints = {}
    self.currentGameConfig = nil
    
    -- Settings
    self.combatRange = 25
    self.pathfindingRadius = 50
    self.updateInterval = 0.5
    
    return self
end

-- ===== GAME DETECTION =====
function AIPlayer:detectGame()
    local gamePlace = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    
    for gameName, config in pairs(GAME_CONFIGS) do
        if string.find(game:GetService("RunService"):IsStudio() and "Test Game" or gameName, gameName) then
            self.currentGameConfig = config
            print("[AI] Detected game: " .. gameName)
            return gameName
        end
    end
    
    -- Default fallback config
    self.currentGameConfig = {
        objectives = {"explore"},
        zones = {{name = "Default", position = self.hrp.Position}},
        hasEnemies = false,
    }
    print("[AI] Using default game configuration")
    return "Unknown Game"
end

-- ===== CHECKPOINT SYSTEM =====
function AIPlayer:saveCheckpoint(name)
    local checkpoint = {
        name = name,
        position = self.hrp.Position,
        objective = self.state.currentObjective,
        memory = self:cloneTable(self.memory),
        timestamp = tick(),
    }
    table.insert(self.checkpoints, checkpoint)
    print("[CHECKPOINT] Saved: " .. name .. " at " .. tostring(self.hrp.Position))
    return checkpoint
end

function AIPlayer:loadCheckpoint(name)
    for _, checkpoint in ipairs(self.checkpoints) do
        if checkpoint.name == name then
            self.hrp.CFrame = CFrame.new(checkpoint.position)
            self.state.currentObjective = checkpoint.objective
            self.memory = self:cloneTable(checkpoint.memory)
            print("[CHECKPOINT] Loaded: " .. name)
            return true
        end
    end
    return false
end

function AIPlayer:listCheckpoints()
    print("[CHECKPOINTS]")
    for i, cp in ipairs(self.checkpoints) do
        print(i .. ". " .. cp.name .. " - " .. tostring(cp.position))
    end
end

-- ===== MEMORY SYSTEM =====
function AIPlayer:cloneTable(t)
    local clone = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            clone[k] = self:cloneTable(v)
        else
            clone[k] = v
        end
    end
    return clone
end

function AIPlayer:rememberLocation(name, position)
    self.memory.visitedLocations[name] = {
        position = position,
        lastVisited = tick(),
        visitCount = (self.memory.visitedLocations[name] and 
                     self.memory.visitedLocations[name].visitCount + 1) or 1,
    }
    print("[MEMORY] Remembered location: " .. name)
end

function AIPlayer:getMemory(key)
    return self.memory[key]
end

function AIPlayer:updateMemory(key, value)
    self.memory[key] = value
    print("[MEMORY] Updated " .. key .. " = " .. tostring(value))
end

-- ===== ENEMY DETECTION & COMBAT =====
function AIPlayer:detectNearbyEnemies()
    local enemies = {}
    local workspace = game:GetService("Workspace")
    
    for _, enemy in ipairs(workspace:GetDescendants()) do
        if enemy:FindFirstChildOfClass("Humanoid") and enemy ~= self.npc then
            local distance = (enemy:FindFirstChild("HumanoidRootPart").Position - self.hrp.Position).Magnitude
            if distance < self.combatRange then
                table.insert(enemies, {
                    model = enemy,
                    distance = distance,
                    health = enemy.Humanoid.Health,
                })
            end
        end
    end
    
    table.sort(enemies, function(a, b) return a.distance < b.distance end)
    return enemies
end

function AIPlayer:attackClosestEnemy()
    local enemies = self:detectNearbyEnemies()
    
    if #enemies > 0 then
        local target = enemies[1]
        self.state.isInCombat = true
        self.state.currentTarget = target.model
        
        print("[COMBAT] Attacking: " .. target.model.Name .. " (Distance: " .. math.floor(target.distance) .. ")")
        
        -- Move toward enemy
        self.humanoid:MoveTo(target.model.HumanoidRootPart.Position)
        
        -- Simulate attacks
        local function attack()
            if target.model:FindFirstChildOfClass("Humanoid") and target.model.Humanoid.Health > 0 then
                -- Deal damage (simulate)
                target.model.Humanoid:TakeDamage(10)
                print("[COMBAT] Hit! Enemy health: " .. target.model.Humanoid.Health)
                
                if target.model.Humanoid.Health <= 0 then
                    self:onEnemyDefeated(target.model)
                end
            end
        end
        
        attack()
        return true
    else
        self.state.isInCombat = false
        self.state.currentTarget = nil
        return false
    end
end

function AIPlayer:onEnemyDefeated(enemy)
    table.insert(self.memory.defeatedEnemies, {
        name = enemy.Name,
        defeatedAt = tick(),
        location = self.hrp.Position,
    })
    self.memory.experience = self.memory.experience + 50
    print("[ACHIEVEMENT] Defeated: " .. enemy.Name .. " | XP: " .. self.memory.experience)
end

-- ===== PATHFINDING & NAVIGATION =====
function AIPlayer:moveToZone(zoneName)
    if not self.currentGameConfig then return false end
    
    for _, zone in ipairs(self.currentGameConfig.zones) do
        if zone.name == zoneName then
            print("[NAVIGATION] Moving to zone: " .. zoneName)
            self.state.currentZone = zoneName
            self:rememberLocation(zoneName, zone.position)
            self.humanoid:MoveTo(zone.position)
            return true
        end
    end
    return false
end

function AIPlayer:moveToCheckpoint(name)
    for _, checkpoint in ipairs(self.checkpoints) do
        if checkpoint.name == name then
            print("[NAVIGATION] Moving to checkpoint: " .. name)
            self.humanoid:MoveTo(checkpoint.position)
            self.humanoid.MoveToFinished:Wait()
            return true
        end
    end
    return false
end

function AIPlayer:exploreRandomZone()
    if not self.currentGameConfig or #self.currentGameConfig.zones == 0 then return end
    
    local randomZone = self.currentGameConfig.zones[math.random(1, #self.currentGameConfig.zones)]
    print("[EXPLORATION] Exploring: " .. randomZone.name)
    self:moveToZone(randomZone.name)
end

-- ===== OBJECTIVE MANAGEMENT =====
function AIPlayer:setObjective(objective)
    self.state.currentObjective = objective
    print("[OBJECTIVE] Set to: " .. objective)
end

function AIPlayer:completeObjective()
    if self.state.currentObjective then
        print("[OBJECTIVE] Completed: " .. self.state.currentObjective)
        self.memory.levelProgress = self.memory.levelProgress + 1
    end
end

function AIPlayer:executeObjective()
    local objective = self.state.currentObjective or "explore"
    
    if objective == "defeat_enemies" then
        self:attackClosestEnemy()
    elseif objective == "collect_items" then
        print("[OBJECTIVE] Searching for items...")
        self:exploreRandomZone()
    elseif objective == "explore" then
        self:exploreRandomZone()
    elseif objective == "reach_checkpoint" then
        if self.checkpoints[1] then
            self:moveToCheckpoint(self.checkpoints[1].name)
        end
    end
end

-- ===== MAIN LOOP =====
function AIPlayer:start()
    print("[AI] Starting AI Player System...")
    self:detectGame()
    
    while true do
        if not self.humanoid or self.humanoid.Health <= 0 then
            print("[AI] AI Player defeated!")
            break
        end
        
        -- Update memory
        self.memory.health = self.humanoid.Health
        
        -- Combat priority
        if self.currentGameConfig.hasEnemies then
            if not self:attackClosestEnemy() then
                self:executeObjective()
            end
        else
            self:executeObjective()
        end
        
        wait(self.updateInterval)
    end
end

-- ===== DEBUG COMMANDS =====
function AIPlayer:printStatus()
    print("\n========== AI STATUS ==========")
    print("Current Objective: " .. tostring(self.state.currentObjective))
    print("Current Zone: " .. tostring(self.state.currentZone))
    print("Health: " .. self.memory.health)
    print("Experience: " .. self.memory.experience)
    print("Level Progress: " .. self.memory.levelProgress)
    print("Enemies Defeated: " .. #self.memory.defeatedEnemies)
    print("Checkpoints: " .. #self.checkpoints)
    print("==============================\n")
end

return AIPlayer