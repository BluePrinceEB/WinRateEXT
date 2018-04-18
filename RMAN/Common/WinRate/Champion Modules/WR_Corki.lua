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
    local DrawCircle, DrawLine, DrawColor = Draw.Circle, Draw.Line, Draw.Color
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

    class 'Corki'  

    function Corki:__init()
        --[[Data Initialization]]
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]  
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        --[[Orb Callbacks]]        
        OnPreAttack(function(...) self:OnPreAttack(...) end)
        OnPostAttack(function(...) self:OnPostAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)        
        --[[Custom Callbacks]]       
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end) 
    end

    function Corki:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 825,
            Delay = 0.25,
            Speed = 1125,
            Radius = 250,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.W = Spell({
            Slot = 1,
            Range = 600,
            Delay = 0.3,
            Speed = 1000,
            Radius = 50,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
        self.E = Spell({
            Slot = 2,
            Range = 600,
            Delay = 0.3,
            Speed = huge,
            Radius = 80,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 1300,
            Delay = 0.25,
            Speed = 2000,
            Radius = 50,
            Collision = true,
            From = myHero,
            Type = "Skillshot"
        })
    end

    function Corki:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})        
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})        
        Menu.Q:MenuElement({id = "KS", name = "Use on KS", value = true})
        Menu.Q:MenuElement({id = "Auto", name = "Auto Use on Immobile", value = false})           
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})
        Menu.W:MenuElement({id = "Gapcloser", name = "Anti Gapcloser W", value = true})      
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 20, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 20, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.E:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.E:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.E:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.E:MenuElement({id = "ManaClear", name = "Min Mana %", value = 20, min = 0, max = 100, step = 1})    
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})       
        Menu.R:MenuElement({id = "Combo", name = "Use in Combo", value = true})
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Harass Settings"}}) 
        Menu.R:MenuElement({id = "Harass", name = "Use in Harass", value = false})
        Menu.R:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.R:MenuElement({id = "Jungle", name = "Use in JungleClear", value = false})
        Menu.R:MenuElement({id = "LastHit", name = "Use in LastHit", value = false})
        Menu.R:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Misc"}})
        Menu.R:MenuElement({id = "KS", name = "Use in KS", value = true})
        Menu.R:MenuElement({id = "Auto", name = "Auto Use on Immobile", value = true})
        Menu:MenuElement({name = "[WR] "..char_name.." Script", drop = {"Release_"..self.scriptVersion}})
    end

    function Corki:OnTick()         
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.R.Range)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.mode = GetMode() 
        --               
        if myHero.isChanneling then return end        
        self:Auto()
        self:KillSteal()
        --
        if not self.mode then return end
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()  or
            self.mode == 3 and self:Clear()   or
            self.mode == 5 and self:LastHit()                  
    end

    function Corki:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Corki:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Corki:OnPostAttack()        
        local target = GetTargetByHandle(myHero.attackData.target)
        if ShouldWait() or not IsValidTarget(target) then return end
        self.target = target
        --        
        local tType = target.type                  
        if tType == Obj_AI_Hero then
            if self.Q:IsReady() and ((self.mode == 1 and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value()) or (self.mode == 2 and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value())) then
                self.Q:CastToPred(target, 2)
            end         
            if self.E:IsReady() and ((self.mode == 1 and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value()) or (self.mode == 2 and Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value())) then
                self.E:Cast()             
            end
        elseif (tType == Obj_AI_Minion and target.team == 300 and (self.mode == 4 or self.mode == 3)) then            
            self:JungleClear(target)
        end
    end 

    function Corki:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if self:HasPackage() or ShouldWait() then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 500 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then                     
            local posTo = myHero.pos:Extended(unitPosTo, -self.W.Range)   
            if not self:IsDangerousPosition(posTo) then 
                self.W:Cast(posTo)
            end
        end
    end 

    function Corki:Auto()
        local checkQ, checkR = Menu.Q.Auto:Value(), Menu.R.Auto:Value()
        if not (checkQ or checkR) then return end 
        --       
        for i=1, #(self.enemies) do  
            local enemy = self.enemies[i]            
            if IsImmobile(enemy) then 
                local health = enemy.health                                     
                if self.Q:IsReady() and checkQ then 
                    self.Q:CastToPred(enemy, 4)
                elseif self.R:IsReady() and checkR then
                    self.R:CastToPred(enemy, 4)            
                end
            end               
        end      
    end

    function Corki:Combo()
        local target = GetTarget(self.R.Range, 0)         
        if not target then return end
        --           
        if self.R:IsReady() and Menu.R.Combo:Value() and ManaPercent(myHero) >= Menu.R.Mana:Value() then            
            self.R:CastToPred(target, 2)            
        elseif self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then          
            self.Q:CastToPred(target, 2)
        end        
    end

    function Corki:Harass()
        local target = GetTarget(self.R.Range, 0) 
        if not target then return end
        --      
        if self.R:IsReady() and Menu.R.Harass:Value() and ManaPercent(myHero) >= Menu.R.ManaHarass:Value() then            
            self.R:CastToPred(target, 2)            
        elseif self.Q:IsReady() and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() then          
            self.Q:CastToPred(target, 2)
        end        
    end

    function Corki:JungleClear(target)        
        if self.R:IsReady() and Menu.R.Jungle:Value() and ManaPercent(myHero) >= Menu.R.ManaClear:Value() then
            self.R:Cast(target.pos)                                       
        elseif self.Q:IsReady() and Menu.Q.Jungle:Value() and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() then
            self.Q:Cast(target.pos)
        elseif self.E:IsReady() and Menu.E.Jungle:Value() and ManaPercent(myHero) >= Menu.E.ManaClear:Value() then 
            self.E:Cast()
        end    
    end

    function Corki:Clear()
        if self.Q:IsReady() and Menu.Q.Clear:Value() and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() then
            local bestPos, count = self.Q:GetBestCircularFarmPos()            
            if bestPos and count >= Menu.Q.Min:Value() then
                self.Q:Cast(bestPos)                            
            end
        end
        --        
        if self.E:IsReady() and Menu.E.Clear:Value() and ManaPercent(myHero) >= Menu.E.ManaClear:Value() then             
            if #(GetEnemyMinions(self.E.Range)) >= Menu.E.Min:Value() then
                self.E:Cast()
            end
        end       
    end

    function Corki:LastHit()  
        if self.R:IsReady() and Menu.R.LastHit:Value() and ManaPercent(myHero) >= Menu.R.ManaClear:Value() then
            local minions = GetEnemyMinions(self.R.Range)
            if #minions == 0 then return end
            -- 
            local check1, range = myHero.attackData.state == STATE_WINDDOWN, GetTrueAttackRange(myHero)
            for i=1, #minions do
                local minion = minions[i]
                if self:GetMissileDamage(minion) >= minion.health and (check1 or minion.distance > range) and #mCollision(myHero.pos, minion.pos, self.R, minions) == 0 and GetHealthPrediction(minion, GetDistance(minion)/self.R.Speed) > 50 then
                    self.R:Cast(minion.pos) 
                    return                                       
                end
            end
        end        
    end

    function Corki:KillSteal()
        for i=1, #(self.enemies) do  
            local enemy = self.enemies[i]
            local health = enemy.health                                      
            if self.R:IsReady() and Menu.R.KS:Value() and health >= 100 and self:GetMissileDamage(enemy) >= health then
                self.R:CastToPred(enemy, 2)            
            elseif self.Q:IsReady() and Menu.Q.KS:Value() and IsValidTarget(enemy, self.Q.Range) and self.Q:GetDamage(enemy) >= health then 
                self.Q:CastToPred(enemy, 2)
            end               
        end
    end

    function Corki:OnDraw()
        local drawSettings = Menu.Draw
        if drawSettings.ON:Value() then            
            local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104)
            local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius*2, DrawColor(255,255,0,0))
            if self.enemies and drawSettings.Dmg:Value() then
                for i=1, #self.enemies do
                    local enemy = self.enemies[i]
                    local qDmg, rMul = self.Q:IsReady() and self.Q:GetDamage(enemy), self.R:IsReady() and 1 or 0 
                    self.R:DrawDmg(enemy, rMul, qDmg)
                end 
            end 
        end    
    end

    function Corki:IsDangerousPosition(pos)
        if IsUnderTurret(pos, TEAM_ENEMY) then return true end
        for i=1, GameHeroCount() do
            local hero = GameHero(i)      
            if IsValidTarget(hero) and GetTrueAttackRange(unit) < 400 and hero.pos:DistanceTo(pos) < 350 then 
                return true 
            end      
        end        
    end

    function Corki:HasPackage()
        return HasBuff(myHero, "corkiloaded") 
    end    

    function Corki:HasBigOne()
        return HasBuff(myHero, "mbcheck2") 
    end

    function Corki:GetMissileDamage(unit)
        return self:HasBigOne() and self.R:GetDamage(unit, 2) or self.R:GetDamage(unit)
    end

