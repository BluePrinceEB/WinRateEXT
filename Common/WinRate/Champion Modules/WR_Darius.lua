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

    class 'Darius'  

    function Darius:__init()
        --[[Data Initialization]]
        self.Allies, self.Enemies = {}, {}
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]   
        --Callback.Add("Load",          function() self:OnLoad()    end) --Just Use OnLoad()        
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

    function Darius:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 415,
            Delay = 0.75,
            Speed = huge,
            Radius = 250,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.W = Spell({
            Slot = 1,
            Range = 300,
            Delay = 0.25,
            Speed = 1450,
            Radius = huge,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.E = Spell({
            Slot = 2,
            Range = 490,
            Delay = 0.3,
            Speed = huge,
            Radius = huge,
            Collision = false,
            From = myHero,
            Type = "AOE"
        })
        self.R = Spell({
            Slot = 3,
            Range = 460,
            Delay = 0.25,
            Speed = huge,
            Radius = huge,
            Collision = false,
            From = myHero,
            Type = "Targetted"
        })
    end

    function Darius:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Misc"}})
        Menu.Q:MenuElement({id = "Auto", name = "Positioning Helper", value = true})          
        --W--
        Menu.W:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.W:MenuElement({id = "Combo", name = "Combo Mode", value = true})
        Menu.W:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.W:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.W:MenuElement({id = "Harass", name = "Harass Mode", value = true})
        Menu.W:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})    
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Combo Mode", value = true})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "Auto", name = "Auto Use on Escaping Enemies", value = true}) 
        Menu.E:MenuElement({id = "Interrupt", name = "Interrupt Targets", type = MENU})
            Menu.E.Interrupt:MenuElement({id = "Loading", name = "Loading Champions...", type = SPACE})    
        --R--
        Menu.R:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.R:MenuElement({id = "Combo", name = "Use on Combo", value = true})        
        Menu.R:MenuElement({id = "Mana", name = "Min Mana %", value = 0, min = 0, max = 100, step = 1})
        Menu.R:MenuElement({name = " ", drop = {"Misc"}})
        Menu.R:MenuElement({id = "Auto", name = "Auto Use on Killable", value = true}) 
        Menu.R:MenuElement({id = "Tweak", name = "Damage Mod +[%]", value = 0, min = -50, max = 50, step = 5})
        --Items--
        Menu:MenuElement({id = "Items", name = "Items Settings", type = MENU})
        Menu.Items:MenuElement({id = "Tiamat", name = "Use Tiamat", value = true})
        Menu.Items:MenuElement({id = "TitanicHydra", name = "Use Titanic Hydra", value = true})
        Menu.Items:MenuElement({id = "Hydra", name = "Use Ravenous Hydra", value = true})
        Menu.Items:MenuElement({id = "Youmuu", name = "Use Youmuu's", value = true}) 
        --Misc--
        Menu.Draw:MenuElement({id = "Helper", name = "Draw Q Helper Pos", value = true, leftIcon = icons.WR})
        Menu:MenuElement({name = "[WR] "..char_name.." Script", drop = {"Release_"..self.scriptVersion}})
        --
        self.menuLoadRequired = true
        Callback.Add("Tick", function() self:MenuLoad() end)
    end

    function Darius:MenuLoad()
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
                end
            end
            if #Menu.E.Interrupt == 0 then
                Menu.E.Interrupt:MenuElement({name = "No Spells To Be Interrupted", drop = {" "}})
                Callback.Del("Tick", function() Interrupter:OnTick() end)
            end           
            Menu.E.Interrupt.Loading:Hide(true)
            self.menuLoadRequired = nil         
        else
            Callback.Del("Tick", function() self:MenuLoad() end)
        end
    end 

    function Darius:OnTick() 
        if ShouldWait() then return end 
        --        
        self.enemies = GetEnemyHeroes(500)
        self.target = GetTarget(self.Q.Range, 0)
        self.mode = GetMode() 
        --
        self:UpdateItems()               
        if myHero.isChanneling then return end        
        self:Auto()
        --
        if not self.mode then return end        
        local executeMode = 
            self.mode == 1 and self:Combo()   or 
            self.mode == 2 and self:Harass()      
    end

    function Darius:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false
            return 
        end
        --Q Helper logic        
        if self.moveTo then
            if GetDistance(self.moveTo) < 20 then 
                args.Process = false 
            elseif not MapPosition:inWall(self.moveTo) then 
                args.Target = self.moveTo 
            end 
        end 
    end

    function Darius:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() then 
            args.Process = false 
            return
        end 
    end

    function Darius:OnPostAttack()        
        local target = GetTargetByHandle(myHero.attackData.target)
        if ShouldWait() or not IsValidTarget(target) then return end  
        if target.type == Obj_AI_Hero then
            if self.W:IsReady() and ((self.mode == 1 and Menu.W.Combo:Value()) or (self.mode == 2 and Menu.W.Harass:Value())) and ManaPercent(myHero) >= Menu.W.Mana:Value() then
                self.W:Cast()
                ResetAutoAttack()
            elseif self.mode == 1  then
                self:UseItems(target)
            end  
        end
    end

    function Darius:OnInterruptable(unit, spell)
        if ShouldWait() then return end         
        if Menu.E.Interrupt[spell.name]:Value() and IsValidTarget(enemy, self.E.Range) and self.E:IsReady() then
            self.E:Cast(unit)            
        end        
    end   

    function Darius:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() then return end   
        if Menu.E.Auto:Value() and IsValidTarget(unit, self.E.Range) and GetDistance(unitPosTo) > 300 and unit.team == TEAM_ENEMY and not IsFacing(unit, myHero) then 
            self.E:CastToPred(unit, 2)
        end
    end 

    function Darius:Auto()        
        if self.enemies and (Menu.R.Auto:Value() or (Menu.R.Combo:Value() and self.mode == 1)) and self.R:IsReady() then
            for i=1, #(self.enemies) do
                local enemy = self.enemies[i]                                            
                if self.R:GetDamage(enemy) * self:GetUltMultiplier(enemy) >= enemy.health + enemy.shieldAD then
                    self.R:Cast(enemy)
                    break
                end
            end
        end                       
    end

    function Darius:Combo()                
        for i=1, #(self.enemies) do
            local enemy = self.enemies[i]
            self:Youmuu(enemy)
            local distance = GetDistance(enemy)
            if self.E:IsReady() and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() and distance >= 350 and distance <= self.E.Range and not IsFacing(enemy, myHero) then
                self.E:Cast(enemy) 
            end                                 
        end        
        if self.Q:IsReady() and Menu.Q.Combo:Value() and self.target and ((self.W:IsReady() == false and not HasBuff(myHero, "DariusNoxianTacticsONH")) or GetDistance(self.target) > 200) and ManaPercent(myHero) >= Menu.Q.Mana:Value()  then 
            self.Q:Cast()
        end        
    end

    function Darius:Harass()
        if self.target and self.Q:IsReady() and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then 
            self.Q:Cast()
        end        
    end

    function Darius:OnDraw()
        local drawSettings = Menu.Draw
        if Menu.Q.Auto:Value() and HasBuff(myHero, "dariusqcast") and self.target then
            self.moveTo = self.target:GetPrediction(huge, 0.2):Extended(myHero.pos, ((self.Q.Radius + self.Q.Range)/2))
        else
            self.moveTo = nil 
        end        
        if drawSettings.ON:Value() then                                
            local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104)
            local mLambda = drawSettings.Helper:Value() and self.moveTo and Draw.Circle(self.moveTo, 50)
            local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, DrawColor(255,255,0,0))
            if self.enemies and drawSettings.Dmg:Value() and self.R:IsReady() then
                for i=1, #self.enemies do
                    local enemy = self.enemies[i]                                        
                    self.R:DrawDmg(enemy, self:GetUltMultiplier(enemy), 0)
                end 
            end 
        end    
    end

    function Darius:GetStacks(target)
        local buff = GetBuffByName(target, "DariusHemo")               
        return buff and buff.count or 0
    end

    function Darius:GetUltMultiplier(target)
        return 0.855 * (1 +0.2 * self:GetStacks(target) + Menu.R.Tweak:Value()/100) --0.84 because dmgLib is off        
    end

    local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
    function Darius:UpdateItems()
        --[[
            Youmuu = 3142
            Tiamat = 3077
            Hidra = 3074
            Titanic = 3748
        ]]
        for i = ITEM_1, ITEM_7 do
            local id = myHero:GetItemData(i).itemID
            --[[In Case They Sell Items]]
            if self.Youmuus and i == self.Youmuus.Index and id ~= 3142 then
                self.Youmuus = nil
            elseif self.Tiamat and i == self.Tiamat.Index and id ~= 3077 then
                self.Tiamat = nil
            elseif self.Hidra and i == self.Hidra.Index and id ~= 3074 then
                self.Hidra = nil
            elseif self.Titanic and i == self.Titanic.Index and id ~= 3748 then
                self.Titanic = nil
            end 
            --- 
            if id == 3142 then 
                self.Youmuus = {Index = i, Key = ItemHotKey[i]}
            elseif id == 3077 then
                self.Tiamat = {Index = i, Key = ItemHotKey[i]}
            elseif id == 3074 then
                self.Hidra = {Index = i, Key = ItemHotKey[i]}
            elseif id == 3748 then
                self.Titanic = {Index = i, Key = ItemHotKey[i]}
            end
        end
    end

    function Darius:UseItems(target)
        if self.Tiamat or self.Hidra then 
            self:Hydra(target)        
        elseif self.Titanic then
            self:TitanicHydra(target)            
        end
    end

    function Darius:UseItem(key, reset)
        KeyDown(key)
        KeyUp(key)
        return reset and ResetAutoAttack()
    end

    function Darius:Youmuu(target)        
        if self.Youmuus and Menu.Items.Youmuu:Value() and myHero:GetSpellData(self.Youmuus.Index).currentCd == 0 and IsValidTarget(target, 600) then
            self:UseItem(self.Youmuus.Key, false)                       
        end
    end

    function Darius:TitanicHydra(target)
        if self.Titanic and Menu.Items.TitanicHydra:Value() and myHero:GetSpellData(self.Titanic.Index).currentCd == 0 and IsValidTarget(target, 380) then
            self:UseItem(self.Titanic.Key, true)
        end
    end

    function Darius:Hydra(target)
        if self.Hidra and Menu.Items.Hydra:Value() and myHero:GetSpellData(self.Hidra.Index).currentCd == 0 and IsValidTarget(target, 380) then
            self:UseItem(self.Hidra.Key, true)
        elseif self.Tiamat and Menu.Items.Tiamat:Value() and myHero:GetSpellData(self.Tiamat.Index).currentCd == 0 and IsValidTarget(target, 380) then
            self:UseItem(self.Tiamat.Key, true)           
        end
    end