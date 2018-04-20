    
    class 'Ashe'  

    function Ashe:__init()
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
        --[[Custom Callbacks]]        
        OnLoseVision(function(unit) self:OnLoseVision(unit) end)        
        OnInterruptable(function(unit, spell) self:OnInterruptable(unit, spell) end)
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)                               
    end

    function Ashe:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = GetTrueAttackRange(myHero),
            Delay = 0.85,
            Speed = huge,
            Radius = 0,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.W = Spell({
            Slot = 1,
            Range = 1200,
            Delay = 0.25,
            Speed = 1500,
            Radius = 100,
            Collision = true,
            From = myHero,
            Type = "AOE"
        })
        self.E = Spell({
            Slot = 2,
            Range = huge,
            Delay = 0.25,
            Speed = 1400,
            Width = 10,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
        self.R = Spell({
            Slot = 3,
            Range = huge,
            Delay = 0.25,
            Speed = 1600,
            Width = 150,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
    end

    function Ashe:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})        
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})        
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Auto", name = "Auto AA Reset Mode", value = 2,drop = {"Heroes Only", "Heroes + Jungle", "Always", "Never"}})           
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})        
        Menu.W:MenuElement({id = "Combo", name = "Use on Combo", value = true})        
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})        
        Menu.W:MenuElement({id = "KS", name = "Use on KS", value = true})  
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})      
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})     
        --R-- 
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})       
        Menu.R:MenuElement({id = "Duel", name = "Use On Duel", value = true})         
        Menu.R:MenuElement({id = "Heroes", name = "Duel Targets", type = MENU})
            Menu.R.Heroes:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Automatic Usage"}})
        Menu.R:MenuElement({id = "Gapcloser", name = "Auto Use On Gapcloser", value = true})
        Menu.R:MenuElement({id = "Hit", name = "Use When X Enemies Hit", type = MENU})
            Menu.R.Hit:MenuElement({id = "Enabled", name = "Enabled", value = false})
            Menu.R.Hit:MenuElement({id = "Min", name = "Number Of Enemies", value = 3, min = 1, max = 5, step = 1})
        Menu.R:MenuElement({id = "Interrupter", name = "Use To Interrupt", value = false})
        Menu.R:MenuElement({id = "Interrupt", name = "Interrupt Targets", type = MENU})
            Menu.R.Interrupt:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})
        Menu:MenuElement({name = "[WR] "..char_name.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Ashe:MenuLoad()
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
                    Interrupter:AddToMenu(hero, Menu.R.Interrupt)                    
                    Menu.R.Heroes:MenuElement({id = charName, name = charName, value = false, leftIcon = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/Champs/"..charName..".png"})                    
                end
            end
            if #Menu.R.Interrupt == 0 then
                Menu.R.Interrupt:MenuElement({name = "No Spells To Be Interrupted", drop = {" "}})
                Callback.Del("Tick", function() Interrupter:OnTick() end)
            end            
            Menu.R.Heroes.Loading:Hide(true)
            Menu.R.Interrupt.Loading:Hide(true)
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Ashe:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(self.W.Range)
        self.target = GetTarget(GetTrueAttackRange(myHero), 0)
        self.lastTarget = self.target or self.lastTarget    
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
            self.mode == 6 and self:Flee()       
    end

    function Ashe:OnPreMovement(args) 
        if ShouldWait() then 
            args.Process = false
            return 
        end 
    end

    function Ashe:OnPreAttack(args) 
        if ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Ashe:OnPostAttack()        
        local target = GetTargetByHandle(myHero.attackData.target)        
        if ShouldWait() or not IsValidTarget(target) then return end
        self.target = target
        --        
        local tType = target.type       
        local mode = Menu.Q.Auto:Value()
        --        
        if self.Q:IsReady() then
            local qCombo, qHarass = self.mode == 1 and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() , not qCombo and self.mode == 2 and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value()
            local qClear = not (qCombo or qHarass) and ((self.mode == 3 and Menu.Q.Clear:Value()) or self.mode == 4 and Menu.Q.Jungle:Value()) and ManaPercent(myHero) >= Menu.Q.ManaClear:Value() and #GetEnemyMinions(500) >= Menu.Q.Min:Value() 
            if qClear or mode == 3 or (tType == Obj_AI_Hero and (mode ~= 4 or qCombo or qHarass)) or (mode == 2 and tType == Obj_AI_Minion and target.team == 300) or (tType == Obj_AI_Turret and mode ~= 4) then
                self.Q:Cast()
                ResetAutoAttack()
            end 
        end        
        if self.W:IsReady() and not HasBuff(myHero, "AsheQAttack") and tType == Obj_AI_Hero then            
            local wCombo, wHarass = self.mode == 1 and Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() , not wCombo and self.mode == 2 and Menu.W.Harass:Value() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value()
            if wCombo or wHarass then                
                self.W:CastToPred(target, 2)
            end             
        end     
    end

    function Ashe:OnLoseVision(unit)        
        if self.E:IsReady() and self.lastTarget and unit.valid and not unit.dead and unit.networkID == self.lastTarget.networkID  then
            if (Menu.E.Combo:Value() and self.mode == 1 and ManaPercent(myHero) >= Menu.E.Mana:Value()) or (Menu.E.Harass:Value() and self.mode == 2 and ManaPercent(myHero) >= Menu.E.ManaHarass:Value()) then
                self.E:Cast(unit.pos)
            end
        end       
    end

    function Ashe:OnInterruptable(unit, spell)
        if ShouldWait() or not (Menu.R.Interrupter:Value() and self.R:IsReady()) then return end         
        if Menu.R.Interrupt[spell.name]:Value() and IsValidTarget(enemy, 1500) then 
            self.R:CastToPred(unit, 2)
        end        
    end   

    function Ashe:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() or not (Menu.R.Gapcloser:Value() and self.R:IsReady()) then return end
        --   
        if IsValidTarget(unit, 600) and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then --Gapcloser 
            self.R:CastToPred(target, 3)        
        end
    end

    function Ashe:Auto() 
        if not self.enemies then return end
        -- 
        local minHit = Menu.R.Hit.Min:Value()    
        if Menu.R.Hit.Enabled:Value() and #self.enemies >= minHit and self.R:IsReady() then
            local targ, count1 = nil, 0
            for i=1, #(self.enemies) do
                local enemy = self.enemies[i]
                targ, count1 = enemy, 1
                local count2 = CountEnemiesAround(enemy.pos, 175)                
                if count2 > count1 then
                    targ = enemy
                    count1 = count2
                end                             
            end            
            if targ and count1 >= minHit then
                self.R:CastToPred(targ, 2)
            end
        end                   
    end

    function Ashe:Combo() 
        local wTarget = GetTarget(self.W.Range, 0)
        local rTarget = self.lastTarget        
        --
        if wTarget and GetDistance(wTarget) > GetTrueAttackRange(myHero) and Menu.W.Combo:Value() and self.W:IsReady() and ManaPercent(myHero) >= Menu.W.Mana:Value()then
            self.W:CastToPred(wTarget, 2)            
        end        
        if Menu.R.Duel:Value() and self.R:IsReady() and IsValidTarget(rTarget, 1500) and Menu.R.Heroes[rTarget.charName]:Value() and ManaPercent(myHero) >= Menu.R.Mana:Value() then                       
            if rTarget.health >= 200 and (self.R:GetDamage(rTarget) * 4 > GetHealthPrediction(rTarget, GetDistance(rTarget)/self.R.Speed) or HealthPercent(myHero) <= 40 )then
                self.R:CastToPred(rTarget, 2)                  
            end            
        end       
    end

    function Ashe:Harass()
        local wTarget = GetTarget(self.W.Range, 0)
        --
        if wTarget and GetDistance(wTarget) > GetTrueAttackRange(myHero) and Menu.W.Harass:Value() and self.W:IsReady() and ManaPercent(myHero) >= Menu.W.ManaHarass:Value() then
            self.W:CastToPred(wTarget, 2)            
        end       
    end

    function Ashe:Flee()        
        if self.enemies and Menu.W.Flee:Value() and self.W:IsReady() then
            for i=1, #self.enemies do
                local wTarget = self.enemies[i]                
                if IsValidTarget(wTarget, 700) then                
                    if self.W:CastToPred(wTarget, 1) then 
                        break 
                    end
                end
            end
        end        
    end

    function Ashe:KillSteal()
        if self.enemies and Menu.W.KS:Value() and self.W:IsReady() then
            for i=1, #self.enemies do
                local wTarget = self.enemies[i]                
                if IsValidTarget(wTarget) then
                    local dmg, health = self.W:GetDamage(wTarget), wTarget.health
                    if health >= 100 and dmg >= health then                                      
                        if self.W:CastToPred(wTarget, 1) then 
                            break 
                        end
                    end                                
                end
            end
        end
    end

    function Ashe:OnDraw()
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
                    local wDmg = self.W:IsReady() and self.W:GetDamage(enemy)
                    self.R:DrawDmg(enemy, 1, wDmg)
                end 
            end 
        end     
    end


    Ashe()