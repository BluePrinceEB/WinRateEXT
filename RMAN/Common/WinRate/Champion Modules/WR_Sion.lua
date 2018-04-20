
    class 'Sion'  

    function Sion:__init()
        --[[Data Initialization]]
        self.castingQ = false
        self.scriptVersion = "1.0"
        self:Spells()
        self:Menu() 
        --[[Default Callbacks]]   
        --Callback.Add("Load",          function() self:OnLoad()    end) --Just Use OnLoad()
        Callback.Add("Tick",          function() self:OnTick()    end)
        Callback.Add("Draw",          function() self:OnDraw()    end)
        Callback.Add("WndMsg",        function(msg, param) self:OnWndMsg(msg, param) end)        
        --[[Orb Callbacks]]        
        OnPreAttack(function(...) self:OnPreAttack(...) end)        
        OnPreMovement(function(...) self:OnPreMovement(...) end)
        --[[Custom Callbacks]]        
        OnInterruptable(function(unit, spell) self:OnInterruptable(unit, spell) end)
        OnDash(function(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) self:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance) end)                              
    end

    function Sion:Spells()
        self.Q = Spell({
            Slot = 0,
            Range = 750,
            Delay = 0.25,
            Speed = huge,
            Radius = 200, --reduced on purpose
            Collision = false,
            From = myHero,
            Type = "SkillShot"
        })
        self.W = Spell({
            Slot = 1,
            Range = huge,
            Delay = 0.25,
            Speed = huge,
            Radius = 550,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
        self.E = Spell({
            Slot = 2,
            Range = 750,
            Delay = 0.25,
            Speed = 2500,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
        self.E2 = Spell({
            Slot = 2,
            Range = 1550,
            Delay = 0.25,
            Speed = 2500,
            Radius = 100,
            Collision = false,
            From = myHero,
            Type = "Skillshot"
        })
        self.E.ExtraRange = 775
        self.R = Spell({
            Slot = 3,
            Range = 7600,
            Delay = 8,
            Speed = 950,
            Radius = 200,
            Collision = false,
            From = myHero,
            Type = "Press"
        })
    end

    function Sion:Menu()
        --Q--
        Menu.Q:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.Q:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.Q:MenuElement({id = "Count", name = "Enemies To Cast", value = 1, min = 0, max = 5, step = 1})
        Menu.Q:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.Q:MenuElement({id = "Harass", name = "Use on Harass", value = true})
        Menu.Q:MenuElement({id = "CountHarass", name = "Enemies To Cast", value = 1, min = 0, max = 5, step = 1})
        Menu.Q:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.Q:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.Q:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.Q:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.Q:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.Q:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})         
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
        Menu.W:MenuElement({name = " ", drop = {"Misc"}})
        Menu.W:MenuElement({id = "Flee", name = "Use on Flee", value = true})      
        --E--
        Menu.E:MenuElement({name = " ", drop = {"Combo Settings"}})
        Menu.E:MenuElement({id = "Combo", name = "Use on Combo", value = true})
        Menu.E:MenuElement({id = "Mana", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Harass Settings"}})
        Menu.E:MenuElement({id = "Harass", name = "Use on Harass", value = false})
        Menu.E:MenuElement({id = "ManaHarass", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Farm Settings"}})
        Menu.E:MenuElement({id = "Jungle", name = "Use on JungleClear", value = false})
        Menu.E:MenuElement({id = "Clear", name = "Use on LaneClear", value = false})
        Menu.E:MenuElement({id = "Min", name = "Minions To Cast", value = 3, min = 0, max = 6, step = 1})
        Menu.E:MenuElement({id = "ManaClear", name = "Min Mana %", value = 15, min = 0, max = 100, step = 1})
        Menu.E:MenuElement({name = " ", drop = {"Misc"}})
        Menu.E:MenuElement({id = "KS", name = "Use on KS", value = true})
        Menu.E:MenuElement({id = "Flee", name = "Use on Flee", value = true})     
        --R--
        Menu.R:MenuElement({name = "Spell Not Supported", drop = {" "}})
        Menu:MenuElement({name = "[WR] "..char_name.." Script", drop = {"Release_"..self.scriptVersion}})
        --        
    end
    

    function Sion:OnTick() 
        if ShouldWait()then return end 
        --        
        self.enemies = GetEnemyHeroes(1500)
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
            self.mode == 4 and self:Clear()   or
            self.mode == 6 and self:Flee()      
    end

    function Sion:OnWndMsg(msg, param)        
        if not self.qCastPos and msg == 256 and param == HK_Q then
            for i=1, 3 do            
                DelayAction(function() self:CheckParticle() end, i*0.1)
            end           
        end
    end

    function Sion:OnPreMovement(args) --args.Process|args.Target
        if ShouldWait() or self.castingQ then 
            args.Process = false
            return 
        end 
    end

    function Sion:OnPreAttack(args) --args.Process|args.Target
        if ShouldWait() or self.castingQ then 
            args.Process = false 
            return
        end 
    end

    function Sion:OnInterruptable(unit, spell)
        if ShouldWait() or self.castingQ then return end         
        if Menu.R.Interrupt[spell.name]:Value() and IsValidTarget(enemy) and Ready(_R) then            
        end        
    end   

    function Sion:OnDash(unit, unitPos, unitPosTo, dashSpeed, dashGravity, dashDistance)  
        if ShouldWait() or self.castingQ then return end   
        if IsValidTarget(unit) and GetDistance(unitPosTo) < 500 and unit.team == TEAM_ENEMY and IsFacing(unit, myHero) then --Gapcloser                    
        end
    end 

    function Sion:Auto()                       
    end

    function Sion:Combo()
        if self.W:IsReady() and Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() then
            self:CastW()
        end
        if self.E:IsReady() and Menu.E.Combo:Value() and ManaPercent(myHero) >= Menu.E.Mana:Value() then
            local eTarget = GetTarget(self.E.Range + 775)
            self:CastE(eTarget)
        elseif self.Q:IsReady() and Menu.Q.Combo:Value() and ManaPercent(myHero) >= Menu.Q.Mana:Value() then
            local pos, hit = self.Q:GetBestCircularCastPos(nil, GetEnemyHeroes(self.Q.Range))
            local willHit, entering, leaving = self:CheckPolygon(pos)
            if pos and GetDistance(pos) < 600 and willHit >= Menu.Q.Count:Value() and leaving == 0 then
                self:StartCharging(pos)
            end    
        end           
    end

    function Sion:Harass()
        if self.W:IsReady() and Menu.W.Combo:Value() and ManaPercent(myHero) >= Menu.W.Mana:Value() then
            self:CastW()
        end
        if self.E:IsReady() and Menu.E.Harass:Value() and ManaPercent(myHero) >= Menu.E.ManaHarass:Value() then
            local eTarget = GetTarget(self.E.Range + 775)
            self:CastE(eTarget)
        elseif self.Q:IsReady() and Menu.Q.Harass:Value() and ManaPercent(myHero) >= Menu.Q.ManaHarass:Value() then
            local pos, hit = self.Q:GetBestCircularCastPos(nil, GetEnemyHeroes(self.Q.Range))
            local willHit, entering, leaving = self:CheckPolygon(pos)
            if pos and willHit >= Menu.Q.Count:Value() and leaving == 0 then
                self:StartCharging(pos)
            end    
        end        
    end

    function Sion:Clear()            
        local qRange, jCheckQ, lCheckQ = self.Q.Range, Menu.Q.Jungle:Value(), Menu.Q.Clear:Value()
        local wRange, jCheckW, lCheckW = self.W.Radius, Menu.W.Jungle:Value(), Menu.W.Clear:Value()
        local eRange, jCheckE, lCheckE = self.E.Range, Menu.E.Jungle:Value(), Menu.E.Clear:Value()
        --
        if self.W:IsReady() and (jCheckW or lCheckW) then
            local minions = (jCheckW and GetMonsters(wRange)) or {}
            minions = (#minions == 0 and lCheckW and GetEnemyMinions(wRange)) or minions 
            if #minions == 0 then return end
            --
            self.W:Cast()
        elseif self.E:IsReady() and (jCheckE or lCheckE) then
            local minions = (jCheckE and GetMonsters(eRange)) or {}
            minions = (#minions == 0 and lCheckE and GetEnemyMinions(eRange)) or minions
            if #minions == 0 then return end
            --
            local pos, hit = GetBestLinearCastPos(self.E, nil, minions)
            if pos and hit >= Menu.E.Min:Value() or (minions[1] and minions[1].team == TEAM_JUNGLE) then
                self.E:Cast(pos)
            end
        elseif self.Q:IsReady() and (jCheckQ or lCheckQ) then            
            local minions = (jCheckQ and GetMonsters(qRange)) or {}
            minions = (#minions == 0 and lCheckQ and GetEnemyMinions(qRange)) or minions 
            if #minions == 0 then return end
            --           
            local pos, hit = GetBestCircularCastPos(self.Q, nil, minions)
            if pos and (hit >= Menu.Q.Min:Value() or (minions[1] and minions[1].team == TEAM_JUNGLE)) then 
                self:StartCharging(pos)
                return                           
            end                
        end       
    end

    function Sion:Flee() 
        if self.E:IsReady() and Menu.E.Flee:Value() then
            local eTarget = GetTarget(self.E.Range)
            self:CastE(eTarget)
        elseif self.W:IsReady() and Menu.W.Flee:Value() then
            self:CastW()
        end     
    end

    function Sion:KillSteal()
        if self.E:IsReady() and Menu.E.KS:Value() then
            local targets = GetEnemyHeroes(self.E.Range + 775)
            for i=1, #targets do
                local eTarget = targets[i]
                local hp = eTarget.health                
                if self.E:GetDamage(eTarget) >= hp and (hp >= 50 or HeroesAround(400, eTarget.pos, TEAM_ALLY) == 0) then                    
                    if self:CastE(eTarget) then return end                    
                end
            end   
        end        
    end

    function Sion:OnDraw()
        local drawSettings = Menu.Draw
        self:LogicQ()
        if drawSettings.ON:Value() then            
            local qLambda = drawSettings.Q:Value() and self.Q and self.Q:Draw(66, 244, 113)
            local wLambda = drawSettings.W:Value() and self.W and self.W:Draw(66, 229, 244)
            local eLambda = drawSettings.E:Value() and self.E and self.E:Draw(244, 238, 66)
            local rLambda = drawSettings.R:Value() and self.R and self.R:Draw(244, 66, 104) and self.R:DrawMap(244, 66, 104)
            local tLambda = drawSettings.TS:Value() and self.target and DrawMark(self.target.pos, 3, self.target.boundingRadius, DrawColor(255,255,0,0))
            if self.enemies and drawSettings.Dmg:Value() then
                for i=1, #self.enemies do
                    local enemy = self.enemies[i]
                    local eDmg = self.E:IsReady() and self.E:GetDamage(enemy)
                    self.R:DrawDmg(enemy, 0, eDmg)
                end 
            end 
        end    
    end    

    function Sion:LogicQ()
        --[[As of March/2018 EXT's myHero.dir wont update if you cast the spell somewhere you're not facing. To fix that, I used Sion's Q particle.]] 
        local spell = myHero.activeSpell
        self.castingQ = spell.isCharging and spell.name == "SionQ" --HasBuff(myHero, "SionQ")        
        if not self.castingQ then            
            local qSpell = myHero:GetSpellData(self.Q.Slot)          
            if (qSpell.currentCd ~= 0 and qSpell.cd - qSpell.currentCd > 0.5) then 
                self.qCastPos = nil
                if IsKeyDown(HK_Q) then KeyUp(HK_Q) end--release stuck key                
            end                        
            return      
        end
        --        
        local qRange = self.Q.Range        
        local willHit, entering, leaving = self:CheckPolygon()       
        DrawText("Q will hit: "..willHit, myHero.pos:To2D()) 
        if entering <= leaving and (willHit > 0 or entering == 0) then                    
            if leaving > 0 and IsKeyDown(HK_Q) then                 
                KeyUp(HK_Q) --release skill
            end           
        end      
    end

    function Sion:CheckPolygon(targetPos)
        local pP, eP = myHero.pos, targetPos or self.qCastPos
        local endPointCenter = targetPos and pP + (eP-pP):Normalized() * 770 or RotateAroundPoint(pP + (eP-pP):Normalized() * 770, pP, (0.5/180)*pi) --0.5 degrees for angleCorrection fml
            --
        local perpend1, perpend2 = (pP-eP):Perpendicular():Normalized(), (pP-eP):Perpendicular2():Normalized()
        local startPoint1, startPoint2 = pP + 160 * perpend1, pP + 180 * perpend2   --why the fuck is this not symmetrical rito         
        local endPoint1, endPoint2 = endPointCenter + 290 * perpend1, endPointCenter + 290 * perpend2        
        --
        local willHit, entering, leaving = 0, 0, 0
        local qPolygon = Polygon(Point(startPoint1),Point(endPoint1), Point(endPoint2), Point(startPoint2))        
        for i=1, #self.enemies do        
            local target = self.enemies[i]
            local tP, tP2 = Point(target.pos), Point(target:GetPrediction(huge, 0.2))  
            -- 
            if qPolygon:__contains(tP) then   --if inside(might leave)                 
                willHit = willHit + 1
                if not qPolygon:__contains(tP2) then leaving = leaving + 1 end
            else      --if outside(might come in)
                if qPolygon:__contains(tP2) then entering = entering + 1 end
            end            
        end
        --qPolygon:__draw()
        --[[Maxxx 2dGeoLib draw functions are broken, I told him already how to fix and am waiting for response.]] --Fixed, we're waiting for Fere to push a lib update
        --DrawLine(startPoint1:To2D(), startPoint2:To2D())
        --DrawLine(startPoint1:To2D(), endPoint1:To2D())
        --DrawLine(endPoint1:To2D(), endPoint2:To2D())
        --DrawLine(endPoint2:To2D(), startPoint2:To2D())        
        return willHit, entering, leaving
    end

    function Sion:CheckParticle()               
        for i=1, ParticleCount() do
            local obj = Particle(i)            
            if obj then
                if obj.name:find("Sion_Base_Q_Indicator") then                          
                    self.qCastPos = obj.pos
                    return true                
                end
            end
        end
    end

    local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
    function Sion:StartCharging(pos)   
        local ticker = GetTickCount()             
        if castSpell.state == 0 and GetDistance(myHero.pos,pos) < self.Q.Range + 100 and ticker - castSpell.casting > self.Q.Delay + Latency() and pos:ToScreen().onScreen then
            castSpell.state = 1
            castSpell.mouse = mousePos
            castSpell.tick = ticker
        end
        if castSpell.state == 1 then
            if ticker - castSpell.tick < Latency() then
                SetCursorPos(pos)
                self.qCastPos = pos
                KeyDown(HK_Q)                             
                castSpell.casting = ticker + self.Q.Delay
                DelayAction(function()
                    if castSpell.state == 1 then
                        SetCursorPos(castSpell.mouse)
                        castSpell.state = 0
                    end
                end,Latency()/1000)
            end
            if ticker - castSpell.casting > Latency() then
                SetCursorPos(castSpell.mouse)
                castSpell.state = 0
            end
        end
    end

    function Sion:CastE(eTarget)
        if not IsValidTarget(eTarget) then return end        
        if GetDistance(eTarget) <= self.E.Range then
            return self.E:CastToPred(eTarget, 2)
        else
            local extendTargets, temp = GetEnemyMinions(self.E.Range), GetMonsters(self.E.Range)
            for i=1, #temp do extendTargets[#extendTargets + 1] = temp[i] end
            --
            local bestPos, castPos, hC = self.E2:GetPrediction(eTarget)
            if bestPos and hC >= 2 and #mCollision(myHero.pos, bestPos, self.E, extendTargets) >= 1 then
                return self.E:Cast(bestPos)
            end
        end
    end

    function Sion:CastW()        
        if #GetEnemyHeroes(self.W.Radius) >= 1 then
            return self.W:Cast()
        end
    end

