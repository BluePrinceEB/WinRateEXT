    local char_name, summoner_name, myId = myHero.charName, myHero.name, myHero.networkID
    --
    local huge, pi, floor, ceil, sqrt, max, min = math.huge, math.pi, math.floor, math.ceil, math.sqrt, math.max, math.min 
    --
    local lenghtOf, abs, deg, cos, sin, acos, atan = math.lenghtOf, math.abs, math.deg, math.cos, math.sin, math.acos, math.atan 
    --
    local contains, insert, remove = table.contains, table.insert, table.remove
    --
    local TEAM_JUNGLE, TEAM_ALLY, TEAM_ENEMY = 300, myHero.team, 300 - myHero.team
    --
    local _STUN, _TAUNT, _SLOW, _SNARE, _FEAR, _CHARM, _SUPRESS, _KNOCKUP, _KNOCKBACK = 5, 8, 10, 11, 21, 22, 24, 29, 30
    --
    local Vector, KeyDown, KeyUp, IsKeyDown, SetCursorPos   = Vector, Control.KeyDown, Control.KeyUp, Control.IsKeyDown, Control.SetCursorPos
    --
    local DrawCircle, DrawLine, DrawColor = Draw.Circle, Draw.Line, Draw.Color
    --
    local barHeight, barWidth, barYOffset = 8, 103, -8
    --
    local Latency                 = Game.Latency
    local Timer                   = Game.Timer
    local Hero, HeroCount         = Game.Hero, Game.HeroCount
    local Ward, WardCount         = Game.Ward, Game.WardCount
    local Minion, MinionCount     = Game.Minion, Game.MinionCount    
    local Turret, TurretCount     = Game.Turret, Game.TurretCount
    local Object, ObjectCount     = Game.Object, Game.ObjectCount
    local Missile, MissileCount   = Game.Missile, Game.MissileCount
    local Particle, ParticleCount = Game.Particle, Game.ParticleCount

    class 'Vladimir'  

    function Vladimir:__init()
        --[[Data Initialization]]
        self.Allies, self.Enemies = {}, {}
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]   
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        --[[Orb Callbacks]]
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)        
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end) 
    end

    function Vladimir:Spells()
        local flashData = myHero:GetSpellData(SUMMONER_1).name:find("Flash") and SUMMONER_1 or myHero:GetSpellData(SUMMONER_2).name:find("Flash") and SUMMONER_2 or nil
        self.Q = Spell({
            Slot = 0,
            Range = 600,
            Delay = 0.25,
            Speed = huge,
            Radius = huge,
            Collision = false,
            From = myHero,
            Type = "Targetted"
        })
        self.W = Spell({
            Slot = 1,
            Range = huge,
            Delay = 0.25,
            Speed = huge,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.E = Spell({
            Slot = 2,
            Range = 600,
            Delay = 0.25,
            Speed = 2500,
            Radius = 100,
            Collision = true,
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 750,
            Delay = 0.25,
            Speed = huge,
            Radius = 200,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.Flash = flashData and Spell({
            Slot = flashData,
            Range = 400,
            Delay = 0.25,
            Speed = huge,
            Radius = 200,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
    end

    function Vladimir:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "LastHit", name = "Use to LastHit", value = false}) --add
        Menu.Q:MenuElement({id = "Unkillable", name = "    Only when Unkillable", value = false}) -- add
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Auto", name = "Auto Use to Harass", value = true})
        Menu.Q:MenuElement({id = "MinHealth", name = "    When Health Below %", value = 100, min = 10, max = 100, step = 1})
        Menu.Q:MenuElement({id = "KS", name = "Use on KS", value = true})
        Menu.Q:MenuElement({id = "Flee", name = "Use on Flee", value = true})            
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})        
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}}) 
        Menu.W:MenuElement({id = "Gapcloser", name = "Use on GapCloser", value = false})
        Menu.W:MenuElement({id = "Count", name = "Auto Use When X Enemies Around", value = 2, min = 0, max = 5, step = 1})
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})      
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})        
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.E:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.E:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.E:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})   
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.R:MenuElement({id = "Duel", name = "Use To Duel", value = true})
        Menu.R:MenuElement({id = "Heroes", name = "Duel Targets", type = MENU})
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu.R:MenuElement({name = " ", drop = {"Misc"}})
        Menu.R:MenuElement({id = "Count", name = "Auto Use When X Enemies", value = 2, min = 0, max = 5, step = 1})                
        --Burst            
        Menu:MenuElement({id = "Burst", name = "Burst Settings", type = MENU})
        Menu.Burst:MenuElement({id = "Flash", name = "Allow Flash On Burst", value = true}) 
        Menu.Burst:MenuElement({id = "Key", name = "Burst Key", key = string.byte("T")})
        --
        Menu:MenuElement({name = "[WR] "..char_name.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Vladimir:MenuLoad()
        if self.menuLoadRequired then 
            local count = HeroCount()
            if count == 1 then return end 
            for i = 1, count do 
                local hero = Hero(i)
                local charName = hero.charName
                if hero.team == TEAM_ALLY then
                    insert(self.Allies, hero)                    
                else
                    insert(self.Enemies, hero)                    
                    Menu.R.Heroes:MenuElement({id = charName, name = charName, value = false, leftIcon = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/Champs/"..charName..".png"})
                end
            end                      
            Menu.R.Heroes.Loading:Hide(true)            
            self.menuLoadRequired = nil        
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Vladimir:OnTick()         
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(1500)
        self.target = GetTarget(self.Q.Range, 1)
        self.mode = GetMode() 
        --  
        if Menu.Burst.Key:Value() then
            self:Burst()
            return
        end    
        self:LogicE()
        self:LogicW()                
        if myHero.isChanneling then return end    
        self:Auto()
        self:KillSteal()
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 3 and self:Clear()   or
            self.mode == 4 and self:Clear()   or
            self.mode == 5 and self:LastHit() or
            self.mode == 6 and self:Flee()      
    end

    function Vladimir:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Vladimir:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() or not myHero.valid then 
            args.Process = false 
            return
        end 
    end

    function Vladimir:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() or not self.W:IsReady() or not Menu.W.Gapcloser:Value() then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 500 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then --Gapcloser                    
            self.W:Cast()
        end
    end 

    function Vladimir:Auto() 
        local rMinHit, wMinHit = Menu.R.Count:Value(), Menu.W.Count:Value()
        --
        if self.Q:IsReady() and (Menu.Q.Auto:Value() and HealthPercent(myHero) <= Menu.Q.MinHealth:Value()) then
                if self.target then
                self.Q:Cast(self.target);return
            end
        end
        if rMinHit ~= 0 and self.R:IsReady() then  
            local bestPos, hit = self.R:GetBestCircularCastPos(nil, GetEnemyHeroes(1000))
            if bestPos and hit >= rMinHit then
                self.R:Cast(bestPos);return
            end
        end
        if wMinHit ~= 0 and self.W:IsReady() then
            local nearby = GetEnemyHeroes(600)
            if #nearby >= wMinHit then                
                self.W:Cast();return
            end
        end                   
    end

    function Vladimir:Combo()         
        if not self.target then return end
        --
        if self.R:IsReady() and Menu.R.Duel:Value() and Menu.R.Heroes[self.target.charName] and Menu.R.Heroes[self.target.charName]:Value() then
            self.R:CastToPred(self.target, 2)
        elseif self.Q:IsReady() and Menu.Q.Combo:Value() then
            self.Q:Cast(self.target)
        elseif self.E:IsReady() and not IsKeyDown(HK_E) and Menu.E.Combo:Value() then 
            KeyDown(HK_E)                         
        end            
    end

    function Vladimir:Harass()
        if not self.target then return end
        --
        if self.Q:IsReady() and Menu.Q.Harass:Value() then
            self.Q:Cast(self.target)
        elseif self.E:IsReady() and not IsKeyDown(HK_E) and Menu.E.Harass:Value() then 
            KeyDown(HK_E)                         
        end        
    end

    function Vladimir:Clear()            
        local qRange, jCheckQ, lCheckQ = self.Q.Range, Menu.Q.Jungle:Value(), Menu.Q.Clear:Value()
        local eRange, jCheckE, lCheckE = self.E.Range, Menu.E.Jungle:Value(), Menu.E.Clear:Value()
        --
        if self.Q:IsReady() and (jCheckQ or lCheckQ) then            
            local minions = (jCheckQ and GetMonsters(qRange)) or {}
            minions = (#minions == 0 and lCheckQ and GetEnemyMinions(qRange)) or minions            
            for i=1, #minions do
                local minion = minions[i]
                if minion.health <= self.Q:GetDamage(minion) or minion.team == TEAM_JUNGLE then 
                    self.Q:Cast(minion)
                    return
                end            
            end
        end
        if self.E:IsReady() and (jCheckE or lCheckE) then
            local minions = (jCheckE and GetMonsters(eRange)) or {}
            minions = (#minions == 0 and lCheckE and GetEnemyMinions(eRange)) or minions
            if #minions >= Menu.E.Min:Value() or (minions[1] and minions[1].team == TEAM_JUNGLE) then
                KeyDown(HK_E)
            end        
        end       
    end

    function Vladimir:LastHit()  
        if self.Q:IsReady() and Menu.Q.LastHit:Value() then
            local minions = GetEnemyMinions(self.Q.Range)
            for i=1, #minions do
                local minion = minions[i]
                if minion.health <= self.Q:GetDamage(minion) then --check if Q dmg is right
                    self.Q:Cast(minion)
                    return
                end            
            end
        end      
    end

    function Vladimir:Flee()
        if Menu.Q.Flee:Value() and self.Q:IsReady() then
            if self.target then
                self.Q:Cast(self.target)
            end
        elseif Menu.W.Flee:Value() and self.W:IsReady() then            
            if #GetEnemyHeroes(400) >= 1 then                
                self.W:Cast() 
            end
        end        
    end

    function Vladimir:KillSteal()
        if (Menu.Q.KS:Value() and self.Q:IsReady()) then
            for i=1, #self.enemies do
                local enemy = self.enemies[i]
                if enemy and self.Q:GetDamage(enemy) >= enemy.health then
                    self.Q:Cast(self.target);return
                end
            end
        end
    end

    function Vladimir:OnDraw()
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
            local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104)
            local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, DrawColor(255,255,0,0))
            if self.enemies and drawSettings.Dmg:Value() then
                for i=1, #self.enemies do
                    local enemy = self.enemies[i]
                    local qDmg, eDmg = self.Q:IsReady() and self.Q:GetDamage(enemy) or 0, self.E:IsReady() and self.E:GetDamage(enemy) or 0
                    self.R:DrawDmg(enemy, 1, qDmg+eDmg)                    
                end 
            end 
        end    
    end

    function Vladimir:LogicE()
        if not HasBuff(myHero, "VladimirE") then
            local eSpell = myHero:GetSpellData(self.E.Slot)          
            if eSpell.currentCd ~= 0 and eSpell.cd - eSpell.currentCd > 0.5 and IsKeyDown(HK_E) then 
                KeyUp(HK_E) --release stuck key                
            end            
            return      
        end
        --
        local eRange = self.E.Range
        local enemies, minions = GetEnemyHeroes(eRange + 300), GetEnemyMinions(eRange + 300)
        local willHit, entering, leaving = 0, 0, 0
        for i=1, #enemies do
            local target = enemies[i]            
            local tP, tP2, pP2 = target.pos,target:GetPrediction(huge, 0.2), myHero:GetPrediction(huge, 0.2)           
            -- 
            if GetDistance(tP) <= eRange then --if inside(might go out)
                if #mCollision(myHero, tP, self.E, minions) == 0 then
                    willHit = willHit + 1
                end
                if GetDistance(tP2, pP2) > eRange then                
                    leaving = leaving + 1
                end                
            elseif GetDistance(tP2, pP2) < eRange then    --if outside(might come in)            
                entering = entering + 1
            end              
        end        
        if entering <= leaving and (willHit > 0 or entering == 0) then            
            if leaving > 0 and IsKeyDown(HK_E) then 
                KeyUp(HK_E) --release skill
            end           
        end
    end

    function Vladimir:LogicW()
        if self.W:IsReady() and not self.Q:IsReady() and not self.E:IsReady() and ((self.mode == 1 and Menu.W.Combo:Value()) or (self.mode == 2 and Menu.W.Harass:Value())) then
            local nearby = GetEnemyHeroes(600)             
            --
            for i=1, #nearby do
                local enemy = nearby[i]                
                if GetDistance(enemy) <= 300 then
                    self.W:Cast()  
                end
            end            
        end 
    end

    local function castSummoner(summonerName, castPos)
        local castPos = castPos or cursorPos
        if myHero:GetSpellData(SUMMONER_1).name == summonerName and Game.CanUseSpell(SUMMONER_1) == 0 then
            Control.CastSpell(HK_SUMMONER_1, castPos)
        elseif myHero:GetSpellData(SUMMONER_2).name == summonerName and Game.CanUseSpell(SUMMONER_2) == 0 then
            Control.CastSpell(HK_SUMMONER_2, castPos)
        end
    end

    local bursting, startEarly = false, false
    function Vladimir:Burst()          
        Orbwalk()
        if not HasBuff(myHero, "vladimirqfrenzy") then            
            return self.Q:IsReady() and self:LoadQ()
        end
        if not bursting and self.Q:IsReady() and (self.E:IsReady() or startEarly) and self.R:IsReady() then
            local canFlash = self.Flash:IsReady() and Menu.Burst.Flash:Value()
            local range = self.E.Range+(canFlash and self.Flash.Range or 0)
            local bTarget, eTarget = GetTarget(range+300, 1), GetTarget(self.E.Range, 1)
            local shouldFlash = canFlash and bTarget ~= eTarget
            --
            if bTarget then
                startEarly = GetDistance(bTarget) > 600 and KeyDown(HK_E)
                if GetDistance(bTarget) < range then                    
                    self:BurstCombo(bTarget, shouldFlash, 1)  
                end
            end          
        end        
    end

    function Vladimir:BurstCombo(target, shouldFlash, step)        
        if step == 1 then                      
            bursting = true
            local chargeE = not IsKeyDown(HK_E) and KeyDown(HK_E)
            if shouldFlash then 
                local pos, hK = mousePos, self.Flash:SlotToHK()
                SetCursorPos(target.pos)
                KeyDown(hK)
                KeyUp(hK)
                DelayAction(function() SetCursorPos(pos) end, 0.05)                
            end
            DelayAction(function() self:BurstCombo(target, shouldFlash, 2) end, 0.3)
        elseif step == 2 then            
            Control.CastSpell(HK_R, target,pos)
            local releaseE = IsKeyDown(HK_E) and KeyUp(HK_E)
            DelayAction(function() self:BurstCombo(target, shouldFlash, 3) end, 0.3)
        elseif step == 3 then            
            self.Q:Cast(target)
            DelayAction(function() self.W:Cast() end, 0.05)
            bursting = false
            DelayAction(function() self:Protobelt(target) end, 0.3)                      
        end
    end

    function Vladimir:LoadQ()
        local qRange = self.Q.Range
        local qTarget = GetTarget(qRange, 1)
        if qTarget then return self.Q:Cast(qTarget) end
        --
        local minions = GetEnemyMinions(qRange)
        if #minions <1 then minions = GetMonsters(qRange) end
        if minions[1] then return self.Q:Cast(minions[1]) end 
    end

    function Vladimir:Protobelt(target)
        local slot, key = GetItemSlot(3152)
        if slot then
            Control.CastSpell(key, target)
        end
    end
