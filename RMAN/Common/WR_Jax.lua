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

    class 'Jax'  

    function Jax:__init()
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
        OnPostAttack(function(...) self:OnPostAttack(...) end)
        OnPreMovement(function(...) self:OnPreMovement(...) end)                     
    end

    function Jax:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 700,
            Delay = 0.85,
            Speed = huge,
            Radius = 150,
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
            Type = "Targetted"
        })
        self.E = Spell({
            Slot = 2,
            Range = 300,
            Delay = 0.25,
            Speed = 2500,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.R = Spell({
            Slot = 3,
            Range = 800,
            Delay = 0.85,
            Speed = huge,
            Radius = 150,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
    end

    function Jax:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})                                     
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})            
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})    
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})                                   
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})      
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "LastHit", name = "Use to LastHit", value = false})                                
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})                                
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})       
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "KS", name = "Use on KS", value = true})                                           
        Menu.Q:MenuElement({id = "Flee", name = "Use on Flee", value = true})
        Menu.Q:MenuElement({id = "Jump", name = "WardJump Settings", type = MENU}) 
        Menu.Q.Jump:MenuElement({id = "Flee", name = "Ward On Flee", value = true})                                   
        Menu.Q.Jump:MenuElement({id = "Key", name = "WardJump Key", key = string.byte("Z")})                                         
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})                                     
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})            
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})                                   
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})      
        Menu.W:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.W:MenuElement({id = "LastHit", name = "Use to LastHit", value = false})                                
        Menu.W:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})                             
        Menu.W:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})                                
        Menu.W:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})       
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})                                     
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})            
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})                                  
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})      
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "Flee", name = "Use on Flee", value = true})                                       
        --R--  
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})      
        Menu.R:MenuElement({id = "Combo", name = "Use on Combo", value = true})                                     
        Menu.R:MenuElement({id = "Count", name = "    When X Enemies", value = 2, min = 1, max = 5, step = 1})             
        Menu.R:MenuElement({id = "Heroes", name = "    Duel Targets", type = MENU})                                 
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})        
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})             
        --Jump--
                                               
                              
                      

        Menu:MenuElement({name = "[WR] "..char_name.." Script", drop = {"Release_"..self.scriptVersion}})

        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Jax:MenuLoad()
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

    function Jax:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(1500)
        self.target = GetTarget(self.Q.Range, 0)
        self.mode = GetMode() 
        --   
        if Menu.Q.Jump.Key:Value() then
            self:Jump(true)            
        end
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
            self.mode == 4 and self:Clear()   or
            self.mode == 5 and self:LastHit() or
            self.mode == 6 and self:Flee()      
    end

    function Jax:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Jax:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Jax:OnPostAttack()        
        local target = GetTargetByHandle(myHero.attackData.target)
        local tType = target.type
        if ShouldWait() or not IsValidTarget(target) or not self.W:IsReady() then return end
        local wMenu, isMob, isHero = Menu.W, tType == Obj_AI_Minion, target.type == myHero.type
        local modeCheck, manaCheck
        --
        if isMob then
            local laneClear, jungleClear = self.mode == 3, self.mode == 4
            modeCheck = laneClear or jungleClear
            castCheck = target.team == TEAM_JUNGLE and wMenu.Jungle:Value() or target.team == TEAM_ENEMY and wMenu.Clear:Value()
            manaCheck = ManaPercent(myHero) >= Menu.W.ManaClear:Value() 
        elseif isHero then 
            local combo, harass = self.mode == 1, self.mode == 2
            modeCheck = (combo or harass)
            castCheck = combo and wMenu.Combo:Value() or harass and wMenu.Harass:Value()
            manaCheck = combo and ManaPercent(myHero) >= Menu.W.Mana:Value()  or harass and ManaPercent(myHero) >= Menu.W.ManaHarass:Value()
        end
        --
        if modeCheck and castCheck and manaCheck then
            self.W:Cast()
            ResetAutoAttack()
        end
    end

    function Jax:Auto()
        if not self:IsDeflecting() then                   
            return      
        end
        --
        local eRange = self.E.Range
        local enemies = GetEnemyHeroes(eRange + 300)
        local willHit, entering, leaving = 0, 0, 0
        --
        for i=1, #enemies do
            local target = enemies[i]            
            local tP, tP2, pP2 = target.pos,target:GetPrediction(huge, 0.2), myHero:GetPrediction(huge, 0.2)           
            -- 
            if GetDistance(tP) <= eRange then --if inside(might go out)                
                willHit = willHit + 1
                if GetDistance(tP2, pP2) > eRange then                
                    leaving = leaving + 1
                end                
            elseif GetDistance(tP2, pP2) < eRange then    --if outside(might come in)            
                entering = entering + 1
            end              
        end        
        if entering <= leaving and (willHit > 0 or entering == 0) then            
            if leaving > 0 and self.E:IsReady() then 
                self.E:Cast() 
            end           
        end        
    end

    function Jax:Combo()
        local targ = self.target                 
        if not IsValidTarget(targ) then return end
        local dist = GetDistance(targ)
        --  
        if Menu.E.Combo:Value() and dist < GetTrueAttackRange(targ) and self.E:IsReady() and not self:IsDeflecting() and mana >= Menu.E.Mana:Value() then
            self.E:Cast()      
        elseif Menu.Q.Combo:Value() and dist <= self.Q.Range and self.Q:IsReady() and (dist >= GetTrueAttackRange(myHero) or self.Q:GetDamage(targ) > targ.health) and mana >= Menu.Q.Mana:Value() then
            self.Q:Cast(targ)        
        elseif Menu.R.Combo:Value() and self.R:IsReady() and mana >= Menu.Q.Mana:Value() then
            if #self.enemies >= Menu.R.Count:Value() or (Menu.R.Heroes[targ.charName] and Menu.R.Heroes[targ.charName]:Value()) then
                self.R:Cast()
            end            
        end                    
    end

    function Jax:Harass() 
        local targ = self.target                 
        if not IsValidTarget(targ) then return end
        local dist, mana = GetDistance(targ), ManaPercent(myHero)
        --  
        if self.E:IsReady() and Menu.E.Harass:Value() and dist < GetTrueAttackRange(targ) and not self:IsDeflecting() and mana >= Menu.E.ManaHarass:Value() then
            self.E:Cast()      
        elseif self.Q:IsReady() and Menu.Q.Harass:Value() and dist <= self.Q.Range and (dist >= GetTrueAttackRange(myHero) or self.Q:GetDamage(targ) > targ.health) and mana >= Menu.Q.ManaHarass:Value() then
            self.Q:Cast(targ)          
        end
    end

    function Jax:Clear() 
        if Menu.Q.Clear:Value() and self.Q:IsReady() and ManaPercent() > Menu.Q.ManaClear:Value() then
            local minions = GetEnemyMinions(self.Q.Range)
            local aaRange, aaCooldown = GetTrueAttackRange(myHero), myHero.attackData.state == STATE_WINDDOWN
            --
            for i=1, #minions do
                local minion = minions[i]
                if minion.health >= 20 and self.Q:GetDamage(minion) > minion.health and ((GetDistance(minion) > aaRange or aaCooldown)) then
                    return self.Q:Cast(minion)                    
                end
            end            
        end      
    end

    function Jax:LastHit()
        if myHero.attackData.state == STATE_WINDDOWN and Menu.W.LastHit:Value() and self.W:IsReady() and ManaPercent() > Menu.W.ManaClear:Value() then
            local aaRange = GetTrueAttackRange(myHero)
            local minions = GetEnemyMinions(aaRange)            
            --
            for i=1, #minions do
                local minion = minions[i]
                if minion.health >= 20 and self.W:GetDamage(minion) > minion.health then
                    self.W:Cast()   
                    ResetAutoAttack()     
                    return            
                end
            end  
        elseif Menu.Q.LastHit:Value() and self.Q:IsReady() and ManaPercent() > Menu.Q.ManaClear:Value() then
            local minions = GetEnemyMinions(self.Q.Range)
            local aaRange, aaCooldown = GetTrueAttackRange(myHero), myHero.attackData.state == STATE_WINDDOWN
            --
            for i=1, #minions do
                local minion = minions[i]
                if minion.health >= 20 and (GetDistance(minion) > aaRange or aaCooldown) and self.Q:GetDamage(minion) > minion.health then
                    self.Q:Cast(minion)  
                    return                  
                end
            end            
        end           
    end

    function Jax:Flee()
        if Menu.Q.Flee:Value() then
            self:Jump(Menu.Q.Jump.Flee:Value())
        end
        if Menu.E.Flee:Value() and self.E:IsReady() then            
            if #GetEnemyHeroes(400) >= 1 then                
                self.W:Cast() 
            end
        end      
    end

    function Jax:KillSteal()                  
        if Menu.Q.KS:Value() and self.Q:IsReady() then            
            for i=1, #self.enemies do
                local targ = self.enemies[i]  
                local qDmg, wDmg = self.Q:GetDamage(targ) , (wReady and self.W:GetDamage(targ) or 0)              
                if qDmg+wDmg >= targ.health then
                    if qDmg < targ.health then
                        self.W:Cast()
                    end
                    self.Q:Cast(targ)                
                end
            end
        end
    end

    function Jax:OnDraw()
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
                    local qDmg, wDmg = self.Q:IsReady() and self.Q:GetDamage(enemy), self.W:IsReady() and self.W:GetDamage(enemy)
                    self.R:DrawDmg(enemy, 1, qDmg+wDmg)
                end 
            end 
        end    
    end

    function Jax:IsDeflecting()
        return GetBuffByName(myHero, "JaxCounterStrike")
    end

    local jumping = false
    function Jax:Jump(canWard)
        jumping = true
        local jumpPos = myHero.pos + (mousePos - myHero.pos):Normalized() * self.Q.Range --always jump at max range
        local jumpObject = self:GetJumpObject(jumpPos) 
        --
        if jumpObject and IsValidTarget(jumpObject) then
            self.E:Cast(jumpObject)
            return
        elseif canWard then
            local pos, wardKey = mousePos, self:GetWard()
            SetCursorPos(jumpPos)
            KeyDown(wardKey)
            KeyUp(wardKey)
            DelayAction(function() 
                KeyDown(HK_Q)
                KeyUp(HK_Q)
                DelayAction(function() SetCursorPos(pos) end, 0.05)  
            end, 0.05)          
        end
        DelayAction(function() jumping = false end, 1)  
    end

    function Jax:GetJumpObject(pos)
        local range, distance, result = GetDistance(pos) + 200, 10000, nil
        --
        local bases = GetMinions(range)
        --
        local heroes = GetHeroes(range)
        for i=1, #heroes do bases[#bases+1] = heroes[i] end
        --
        local wards = GetWards(range)
        for i=1, #wards do bases[#bases+1] = wards[i] end
        --
        local monsters = GetWonsters(range)
        for i=1, #monsters do bases[#bases+1] = monsters[i] end
        --
        for i = 1, #bases do
            local obj = bases[i]
            local dist = GetDistance(obj, pos)
            if dist <= 200 and dist <= distance and IsValidTarget(obj) then                
                    distance = dist
                    result = obj
                end
            end
        end
        return result
    end

    local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7}
    local wardItemIDs = {['3340'] = true, ["2049"] = true, ["2301"] = true, ["2302"] = true, ["2303"] = true, ["3711"] = true}
    function Jax:GetWard()        
        for i = ITEM_1, ITEM_7 do
            if myHero:GetItemData(i).itemID and wardItemIDs[myHero:GetItemData(i).itemID] and Ready(i) then
               return ItemHotKey[i]
            end
        end
    end