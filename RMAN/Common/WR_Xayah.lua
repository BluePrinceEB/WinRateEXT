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
    local Vector, KeyDown, KeyUp    = Vector, Control.KeyDown, Control.KeyUp
    --
    local DrawCircle, DrawLine, DrawColor, DrawText = Draw.Circle, Draw.Line, Draw.Color, Draw.Text
    --
    local barHeight, barWidth, barYOffset = 8, 103, -8
    --
    local Timer                   = Game.Timer
    local Hero, HeroCount         = Game.Hero, Game.HeroCount
    local Ward, WardCount         = Game.Ward, Game.WardCount
    local Minion, MinionCount     = Game.Minion, Game.MinionCount    
    local Turret, TurretCount     = Game.Turret, Game.TurretCount
    local Object, ObjectCount     = Game.Object, Game.ObjectCount
    local Missile, MissileCount   = Game.Missile, Game.MissileCount
    local Particle, ParticleCount = Game.Particle, Game.ParticleCount

    class 'Xayah'  

    function Xayah:__init()
        --[[Data Initialization]]
        self.Allies, self.Enemies = {}, {}
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]          
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        Callback.Add("WndMsg",        function(msg, param) self:OnWndMsg(msg, param) end)
        Callback.Add("ProcessRecall", function(unit, proc) self:OnRecall(unit, proc) end)
        --[[Orb Callbacks]]        
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPostAttack(function(...) self:OnPostAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)
        --[[Custom Callbacks]]        
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)                       
    end

    function Xayah:Spells()
        self.PassiveTable = {} 
        self.Q = Spell({
            Slot = 0,
            Range = 1100,
            Delay = 0.5,
            Speed = 1200,
            Width = 70,
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.W = Spell({
            Slot = 1,
            Range = 925,
            Delay = 0.25,
            Speed = 1450,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.E = Spell({
            Slot = 2,
            Range = 1000,
            Delay = 0.25,
            Speed = 2000,
            Width = 70,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 1100,
            Delay = 1,
            Speed = 1200,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
    end

    function Xayah:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "KS", name = "Use on KS", value = true})          
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.W:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.W:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.W:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.W:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1}) 
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Auto Settings"}})
        Menu.E:MenuElement({id = "Auto", name = "Auto Use", value = true})
        Menu.E:MenuElement({id = "MinRoot", name = "If Can Root X Enemies", value = 2, min = 1, max = 5, step = 1})
        Menu.E:MenuElement({id = "MinFeather", name = "If Can Hit X Feathers", value = 15, min = 3, max = 20, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use in Combo", value = true})
        Menu.E:MenuElement({id = "MinRootCombo", name = "If Can Root X Enemies", value = 2, min = 1, max = 5, step = 1})
        Menu.E:MenuElement({id = "MinFeatherCombo", name = "If Can Hit X Feathers", value = 15, min = 3, max = 20, step = 1})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use in Harass", value = false})
        Menu.E:MenuElement({id = "MinRootHarass", name = "If Can Root X Enemies", value = 2, min = 1, max = 5, step = 1})
        Menu.E:MenuElement({id = "MinFeatherHarass", name = "If Can Hit X Feathers", value = 15, min = 3, max = 20, step = 1})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1}) 
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "KS", name = "Use in KS", value = true})                 
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})        
        Menu.R:MenuElement({id = "Peel", name = "Use To Peel", value = true})
        Menu.R:MenuElement({id = "Min", name = "Use When X Enemies", value = 2, min = 1, max = 5, step = 1})
        Menu.R:MenuElement({id = "GapCloser", name = "Use On Gapcloser", value = true})         
        Menu.R:MenuElement({id = "Heroes", name = "Dodge Gapclosers From", type = MENU})
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        --Menu.R:MenuElement({id = "Spells", name = "Dodge Spells", type = MENU})
        --     Menu.R.Spells:MenuElement({id = "Loading", name = "Loading Spells...", type = SPACE})      
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})       
        --Draw--        
        Menu.Draw:MenuElement({id = "Hit", name = "Draw X Feathers Hit", value = true})
        Menu.Draw:MenuElement({id = "Feathers", name = "Draw Feathers Pos", value = true})
        Menu.Draw:MenuElement({id = "Lines", name = "Draw Feathers Collision Lines", value = true})
        --
        Menu:MenuElement({name = "[WR] "..char_name.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Xayah:MenuLoad()
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

    function Xayah:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(1500)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.mode = GetMode() 
        --               
        if myHero.isChanneling then return end        
        self:Auto()
        self:KillSteal()
        --
        if not self.mode or (self.mode < 3 and #self.enemies == 0) then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 3 and self:Clear()   or
            self.mode == 4 and self:Clear()              
      
    end

    function Xayah:OnWndMsg(msg, param)
        if msg == 257 then
            local ping, delay = Game.Latency() / 1000 , nil
            if param == HK_Q then
                delay = self.Q.Delay + ping
            elseif param == HK_R then
                delay = self.R.Delay + ping
            elseif param == HK_E then
                delay = ping
            end            
            if delay then               
                DelayAction(function() self:UpdateFeathers() end, delay)
            end
        end
    end

    function Xayah:OnRecall(unit, proc)
    end    

    function Xayah:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Xayah:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
        if args.Target and self.W:IsReady() and myHero.hudAmmo <= 2 then
            local check = (self.mode == 1 and Menu.W.Combo:Value()  and ManaPercent(myHero) >= Menu.W.Mana:Value()) or 
                          (self.mode == 2 and Menu.W.Harass:Value() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value()) or
                          (self.mode == 3 and Menu.W.Clear:Value()  and ManaPercent(myHero) >= Menu.W.ManaClear:Value()) or 
                          (self.mode == 4 and Menu.W.Jungle:Value() and ManaPercent(myHero) >= Menu.W.ManaClear:Value() and args.Target.team == TEAM_JUNGLE)
            if check then
                self.W:Cast()
            end
        end
    end

    function Xayah:OnPostAttack()  
        self:UpdateFeathers()      
        local target = GetTargetByHandle(myHero.attackData.target)
        if ShouldWait() or not IsValidTarget(target) then return end
    end

    function Xayah:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 400 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) and Menu.R.Gapcloser:Value() then --Gapcloser
            if Menu.R.Heroes[targ.charName] and Menu.R.Heroes[targ.charName]:Value() then 
                self.R:Cast(unitPosTo)
            end
        end
    end

    function Xayah:Auto() 
        if Menu.E.Auto:Value() then            
            self:AutoE()                   
        end
        if Menu.R.Peel:Value() and self.R:IsReady() then
            local nearby = GetEnemyHeroes(400)
            if #nearby >= Menu.R.Min:Value() then
                self.R:Cast(nearby[1])
            end
        end                      
    end

    function Xayah:Combo()        
        if not Menu.E.Auto:Value() and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() then            
            self:AutoE()           
        end
        --
        if not HasBuff(myHero, "XayahW") or myHero.hudAmmo <= 2 then
            if Menu.Q.Combo:Value() and self.Q:IsReady() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then
                local qTarget = GetTarget(self.Q.Range, 1)
                self:CastQ(qTarget)            
            end            
        end       
    end

    function Xayah:Harass()  
        if not Menu.E.Auto:Value() and Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() then            
            self:AutoE()           
        end
        --
        if not HasBuff(myHero, "XayahW") or myHero.hudAmmo <= 2 then
            if Menu.Q.Combo:Value() and self.Q:IsReady() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then
                local qTarget = GetTarget(self.Q.Range, 1)
                self:CastQ(qTarget)            
            end            
        end       
    end

    function Xayah:Clear()        
    end

    function Xayah:KillSteal()
    end

    local col1, col2 = DrawColor(255, 255, 0, 0), DrawColor(255, 153, 0, 153)
    function Xayah:OnDraw()
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
            local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104)
            local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, col1)
            if self.enemies then
                local Hit, Feathers, Lines = drawSettings.Hit:Value() , drawSettings.Feathers:Value() , drawSettings.Lines:Value()
                local currentTime = Timer()
                local myPos = myHero.pos:To2D()
                if Hit then            
                    for i=1, #self.enemies do
                        local target = self.enemies[i]
                        local hits = self:CountFeatherHits(target)
                        local pos = target.pos:To2D()
                        DrawText(tostring(hits), 25, pos.x, pos.y, DrawColor(255, 255, 255, 0))
                    end
                end
                if Feathers or Lines then
                    for i=1, #self.PassiveTable do
                        local object = self.PassiveTable[i]
                        if object and object.placetime > currentTime then
                            if Feathers then
                                DrawCircle(object.pos, 50, 3, object.hit and col1 or col2)
                            end
                            if Lines then                        
                                local pos = object.pos:To2D()
                                DrawLine(myPos.x, myPos.y, pos.x, pos.y, 4, object.hit and col1 or col2)
                            end
                            object.hit = false
                        else
                            remove(self.PassiveTable,i)
                        end                
                    end
                end 
            end 
        end    
    end

    function Xayah:CheckFeather(obj)
        for i=1, #self.PassiveTable do
            if self.PassiveTable[i].ID == obj.networkID then
                return true
            end
        end        
    end
    
    function Xayah:CountFeatherHits(target)
        local HitCount = 0
        if target then  
            for i=1, #self.PassiveTable do                
                local collidingLine = LineSegment(myHero.pos, self.PassiveTable[i].pos)
                if Point(target):__distance(collidingLine) < 80 + target.boundingRadius then
                    HitCount = HitCount + 1
                    self.PassiveTable[i].hit = true
                end
            end
        end
        return HitCount
    end
    
    function Xayah:UpdateFeathers()
        --[[Particles are more precise but will only be detected on endPos]]
        --for i = 0,GameObjectCount() do
        --    local obj = GameObject(i)
        --    if obj.owner == myHero and obj.name == "Feather" and not obj.dead and not self:CheckFeather(obj) then
        --        self.PassiveTable[#self.PassiveTable+1] = {placetime = Timer() + 6, ID = obj.networkID, pos = Vector(obj.pos), hit = false})                    
        --    end
        --end
        --[[Missiles will be detected instantly but can lead to wrong positions (eg out of map bondaries)]]
        for i = 1, GameMissileCount() do
            local missile = GameMissile(i)
            --print(missile.missileData.name)
            if missile.missileData and missile.missileData.owner == myHero.handle and not self:CheckFeather(missile) then                               
                if missile.missileData.name:find("XayahQMissile1") or missile.missileData.name:find("XayahQMissile2") then --pls dont change this line
                    self.PassiveTable[#self.PassiveTable+1] = {placetime = Timer() + 6, ID = missile.networkID, pos = Vector(missile.missileData.endPos), hit = false})    --pls dont remove Vector() here
                elseif missile.missileData.name:find("XayahRMissile") then
                    self.PassiveTable[#self.PassiveTable+1] = {placetime = Timer() + 6, ID = missile.networkID, pos = Vector(missile.missileData.endPos):Extended(myHero.pos, 100), hit = false})    --pls dont remove Vector() here
                elseif missile.missileData.name:find("XayahPassiveAttack") then
                    self.PassiveTable[#self.PassiveTable+1] = {placetime = Timer() + 6, ID = missile.networkID, pos = Vector(myHero.pos:Extended(missile.missileData.endPos,1000)), hit = false})    --pls dont remove Vector() here
                elseif missile.missileData.name:find("XayahEMissileSFX") then                                      
                    self.PassiveTable = {}
                end
            end
        end
    end

    function Xayah:AutoE()
        if not self.enemies and self.E:IsReady() then return end
        local config = Menu.E
        local ksActive = config.KS:Value()
        local Auto, Combo, Harass = config.Auto:Value(), (config.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() and self.mode == 1) , (config.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() and self.mode == 2)
        local minRoot = (Auto and config.MinRoot:Value()) or (Combo and config.MinRootCombo:Value()) or (Harass and config.MinRootHarass:Value()) or huge
        local minHit = (Auto and config.MinFeather:Value()) or (Combo and config.MinFeatherCombo:Value()) or (Harass and config.MinFeatherHarass:Value()) or huge 
        local rootedEnemies, feathersHit = 0 , 0
        --
        if not (Auto or Combo or Harass or ksActive) then return end        
        for i=1, #(self.enemies) do
            local target = self.enemies[i]
            if IsValidTarget(target) then
                local hitsOnTarget = self:CountFeatherHits(target)
                --
                feathersHit = feathersHit + hitsOnTarget                 
                if hitsOnTarget >= 3 then
                    rootedEnemies = rootedEnemies + 1
                end
                --
                if ksActive then
                    local rawDmg = (45 + myHero:GetSpellData(_E).level*10 + 0.6*myHero.bonusDamage)* hitsOnTarget *(1+myHero.critChance/2)
                    local dmg = CalcPhysicalDamage(myHero,target,rawDmg)
                    if dmg > target.health then
                        self.E:Cast()                        
                    end
                end                
            end
        end
        if rootedEnemies >= minRoot or feathersHit >= minHit then 
            self.E:Cast()                  
        end
    end