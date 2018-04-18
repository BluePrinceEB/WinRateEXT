    local char_name, summoner_name, myId = myHero.charName, myHero.name, myHero.networkID
    --
    local huge, pi, floor, ceil, sqrt, max, min = math.huge, math.pi, math.floor, math.ceil, math.sqrt, math.max, math.min 
    --
    local lenghtOf, abs, deg, cos, sin, acos, atan = math.lenghtOf, math.abs, math.deg, math.cos, math.sin, math.acos, math.atan 
    --
    local contains, insert, remove, sort = table.contains, table.insert, table.remove, table.sort
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

    class 'Draven'  

    function Draven:__init()
        --[[Data Initialization]]
        self.Allies, self.Enemies, self.AxeList = {}, {}, {}
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu()
        self.moveTo = nil
        --[[Default Callbacks]]   
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)               
        --[[Orb Callbacks]]
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPostAttack(function(...) self:OnPostAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)
        --[[Custom Callbacks]]
        OnInterruptable(function(unit, spell) self:OnInterruptable(unit, spell) end)
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)                      
    end

    function Draven:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = nil,
            Delay = 0.25,
            Speed = nil,
            Radius = nil,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.W = Spell({
            Slot = 1,
            Range = nil,
            Delay = 0.25,
            Speed = nil,
            Radius = nil,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.E = Spell({
            Slot = 2,
            Range = 950,
            Delay = 0.25,
            Speed = 1400,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
        self.R = Spell({
            Slot = 3,
            Range = 1500, --huge
            Delay = 0.4,
            Speed = 2000,
            Radius = 160,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
    end

    function Draven:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "LastHit", name = "Use on LastHit", value = false})
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Catch", name = "Auto Catch Axes", value = true})
        Menu.Q:MenuElement({id = "Max", name = "Max Axes To Have",  value = 2, min = 1, max = 3})          
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})
        Menu.W:MenuElement({id = "Catch", name = "Use to Catch Axes", value = true})   
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})      
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "Flee", name = "Use on Flee", value = true}) 
        Menu.E:MenuElement({id = "Gapcloser", name = "Auto Use on Gapcloser", value = true})
        Menu.E:MenuElement({id = "Interrupt", name = "Interrupt Targets", type = MENU})
            Menu.E.Interrupt:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})             
        --R--                         
        Menu.R:MenuElement({id = "Heroes", name = "Duel Settings", type = MENU})
            Menu.R.Heroes:MenuElement({id = "Combo", name = "Enabled", value = true})
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu.R:MenuElement({id = "Count", name = "Auto Use When X Enemies", value = 2, min = 0, max = 5, step = 1})
        Menu.R:MenuElement({id = "KS", name = "Use on KS", value = true})
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu:MenuElement({name = "[WR] "..char_name.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Draven:MenuLoad()
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
                    Interrupter:AddToMenu(hero, Menu.E.Interrupt)
                    Menu.R.Heroes:MenuElement({id = charName, name = charName, value = false, leftIcon = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/Champs/"..charName..".png"})
                end
            end
            if #Menu.E.Interrupt == 0 then
                Menu.E.Interrupt:MenuElement({name = "No Spells To Be Interrupted", drop = {" "}})
                Callback.Del("Tick", function() Interrupter:OnTick() end)
            end            
            Menu.R.Heroes.Loading:Hide(true)
            Menu.E.Interrupt.Loading:Hide(true)
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Draven:OnTick()          
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(1500)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.mode = GetMode() 
        --               
        if myHero.isChanneling then return end
        self:ShouldCatch()        
        self:Auto()
        self:KillSteal()
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 6 and self:Flee()      
    end

    function Draven:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end
        if self.moveTo then
            if GetDistance(self.moveTo) < 20 then 
                args.Process = false 
            else
                args.Target = self.moveTo 
            end 
        end 
    end

    function Draven:OnPreAttack(args) --args.Process|args.Target
        SetHoldRadius(50) --Leave this or it wont catch close axes
        SetMovementDelay(100)
        local targ = args.Target
        if ShouldWait() or (self.moveTo and ((GetDistance(self.moveTo) / myHero.ms) + myHero.attackData.animationTime * 1.5 >= self.AxeList[1].endTime - Timer() and myHero.posTo:DistanceTo(self.moveTo) > 30)) then 
            if Menu.W.Catch:Value() and self.W:IsReady() and not HasBuff(myHero, "DravenFury") then 
                self.W:Cast()
            end          
            args.Process = false 
            return
        end
        if self:GetAxeCount() < Menu.Q.Max:Value() and IsValidTarget(targ, GetTrueAttackRange(myHero)) and self.Q:IsReady() then            
            if (Menu.Q.Combo:Value() and self.mode == 1 and ManaPercent(myHero) >= Menu.Q.Mana:Value()) or (Menu.Q.Harass:Value() and self.mode == 2 and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value()) or 
               (Menu.Q.Clear:Value() and self.mode == 3 and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() and targ.team ~= TEAM_JUNGLE) or (Menu.Q.Jungle:Value() and (self.mode == 4 or self.mode == 3) and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() and targ.team == TEAM_JUNGLE) or
               (Menu.Q.LastHit:Value() and self.mode == 5 and ManaPercent(myHero) >= Menu.Q.ManaClear:Value()) then
                self.Q:Cast()
            end
        end
    end

    function Draven:OnPostAttack()        
        local target = GetTargetByHandle(myHero.attackData.target)
        --if not IsValidTarget(target) then return end  
        local delay = (target and GetDistance(target)/myHero.attackData.projectileSpeed)
        if delay then            
            DelayAction(function() self:UpdateAxes() end, delay+Game.Latency()/1000) 
        else    --myHero.attackData.target is broken and fere probably wont fix it zzzzz
            self:UpdateAxes()
            for i= 0, 1, (1/3) do                               
                DelayAction(function() self:UpdateAxes() end, i)
            end
        end
    end

    function Draven:OnInterruptable(unit, spell)                
        if not ShouldWait() and Menu.E.Interrupt[spell.name]:Value() and IsValidTarget(enemy, self.E.Range) and self.E:IsReady() then
            self.E:Cast(unit.pos)
        end        
    end   

    function Draven:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() or not (Menu.E.Gapcloser:Value() and self.E:IsReady()) then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 500 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then --Gapcloser
            self.E:CastToPred(unit, 2)                    
        end
    end 

    function Draven:Auto()
        if self.enemies  and #self.enemies ~= 0 and Menu.R.Count:Value() ~= 0 and self.R:IsReady() then
            local bestPos, hit = GetBestLinearCastPos(self.R, nil, self.enemies)            
            if bestPos and hit >= Menu.R.Count:Value() then
                self.R:Cast(bestPos)
            end
        end                       
    end

    function Draven:Combo()
        local eTarget = GetTarget(self.E.Range, 0)
        local runningAway = (IsFacing(myHero, eTarget) and not IsFacing(eTarget, myHero) and GetDistance(eTarget) > GetTrueAttackRange(myHero))
        if self.W:IsReady() and Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() and not HasBuff(myHero, "DravenFury") then  
            if eTarget and (eTarget.ms > myHero.ms or runningAway) then
                self.W:Cast()
            end
        end        
        if self.E:IsReady() and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() then
            local eTarget = GetTarget(self.E.Range, 0)
            if IsValidTarget(eTarget) and (HealthPercent(myHero) <= 40 or runningAway) then
                self.E:CastToPred(eTarget, 2)
            end
        end
        if self.R:IsReady() and Menu.R.Heroes.Combo:Value() and ManaPercent(myHero) >= Menu.R.Mana:Value() then
            local rTarget = GetTarget(1500, 0)
            if IsValidTarget(rTarget) and Menu.R.Heroes[rTarget.charName]:Value() and rTarget.health >= 200 and (self.R:GetDamage(rTarget) * 4 > GetHealthPrediction(rTarget, GetDistance(rTarget)/self.R.Speed) or HealthPercent(myHero) <= 40 ) then
                if self.R:CastToPred(enemy, 2) then
                    self:CallUltBack(enemy)                    
                end
            end
        end                
    end

    function Draven:Harass()
        if self.E:IsReady() and Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() then
            local eTarget = GetTarget(self.E.Range, 0)            
            if IsValidTarget(eTarget) and (HealthPercent(myHero) <= 40 or (IsFacing(myHero, eTarget) and not IsFacing(eTarget, myHero) and GetDistance(eTarget) > GetTrueAttackRange(myHero))) then
                self.E:CastToPred(eTarget, 2)
            end
        end      
    end

    function Draven:Flee()
        local nearby = GetEnemyHeroes(600)
        if Menu.E.Flee:Value() and self.E:IsReady() then
            for i=1, #nearby do
                local enemy = nearby[i]
                local range = GetTrueAttackRange(enemy)
                if range <= 500 and GetDistance(enemy) <= range then
                    self.E:CastToPred(enemy, 1); break                    
                end
            end
        end
        if Menu.W.Flee:Value() and self.W:IsReady() and #nearby >= 1 then
            self.W:Cast()
        end               
    end

    function Draven:KillSteal()        
        if self.enemies and Menu.R.KS:Value() and self.R:IsReady() then
            for i=1, #(self.enemies) do
                local enemy = self.enemies[i]
                local hp = enemy.health + enemy.shieldAD                                            
                if self.R:GetDamage(enemy) * 2 >= hp and (hp >= 100 or HeroesAround(600, enemy.pos, TEAM_ALLY == 0)) then
                    if self.R:CastToPred(enemy, 2) then
                        self:CallUltBack(enemy)
                        break
                    end
                end
            end
        end
    end

    function Draven:OnDraw()
        self:Auto()
        if Menu.Q.Catch:Value() then
            self:UpdateAxeCatching()            
            self.moveTo = #self.AxeList >= 1 and self.AxeList[1].pos --axeNumber >= 2 and self.AxeList[1].pos + (self.AxeList[2].pos-self.AxeList[1].pos):Normalized() * 30 or axeNumber == 1 and 
        else
            self.moveTo = nil 
        end
        
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
                    self.R:DrawDmg(enemy, 2, 0)
                end 
            end 
        end    
    end

    function Draven:UpdateAxeCatching()
        sort(self.AxeList, function(a, b) return GetDistance(a) < GetDistance(b) end)        
        for i=1, #self.AxeList do
            local object = self.AxeList[i]
            if object and (object.endTime - Timer() >= 0 and GetDistance(object.obj.pos, object.pos) > 10) then                                
                DrawText(i, 48, object.pos:ToScreen(), DrawColor(255,0,255,0))
            else                
                remove(self.AxeList,i)
            end                
        end
    end 

    function Draven:CheckAxe(obj)
        for i=1, #self.AxeList do
            if self.AxeList[i].ID == obj.handle then
                return true
            end
        end        
    end

    
    function Draven:UpdateAxes()
        local count = MissileCount()
        for i = count, 1, -1  do
            local missile = Missile(i)
            local data = missile.missileData          
            if data and data.owner == myHero.handle and data.name == "DravenSpinningReturn" and not self:CheckAxe(missile) then                                                            
                insert(self.AxeList, {endTime = Timer() + 1.1, ID = missile.handle, pos = Vector(missile.missileData.endPos), obj = missile}) --its always 1.1 seconds (missile speed changes based on distance)  
                return true              
            end
        end        
    end

    function Draven:CallUltBack(enemy)
        DelayAction(function()
            KeyDown(HK_R)   
            KeyUp(HK_R)                         
        end, abs(GetDistance(enemy) - 500) / 2000)
    end

    function Draven:ShouldCatch()
        if Menu.Q.Catch:Value() and self.moveTo and not myHero.pathing.hasMovePath and self.mode then 
            Orbwalk()
        end
    end

    function Draven:GetAxeCount()
        local axesOnHand = (HasBuff(myHero, "dravenspinningleft") and 2) or (HasBuff(myHero, "dravenspinning") and 1) or 0  
        return #self.AxeList + axesOnHand
    end