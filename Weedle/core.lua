    
    --[[
        core.lua
        WR TEAM
    --]]

    _G.WR = 
        {
            Common = nil,
            Prediction = nil
        }

    local AddEvent              = Callback.Add 
   
    local MenuValue             = MenuElement.Value
    local MenuHide              = MenuElement.Hide
   
    local IsOnTop               = Game.IsOnTop
    local IsChatOpen            = Game.IsChatOpen
    local Latency               = Game.Latency
    local Timer                 = Game.Timer
    local FPS                   = Game.FPS 
    local Resolution            = Game.Resolution 
    local CanUseSpell           = Game.CanUseSpell
    local GetObjectByNetID      = Game.GetObjectByNetID
   
    local HeroCount             = Game.HeroCount
    local ObjectCount           = Game.ObjectCount 
    local ParticleCount         = Game.ParticleCount 
    local MissileCount          = Game.MissileCount 
    local TurretCount           = Game.TurretCount 
    local WardCount             = Game.WardCount 
    local CampCount             = Game.CampCount    
    local Hero                  = Game.Hero    
    local Object                = Game.Object 
    local Particle              = Game.Particle 
    local Missile               = Game.Missile  
    local Turret                = Game.Turret 
    local Ward                  = Game.Ward
    local Camp                  = Game.Camp
 
    local IsKeyDown             = Control.IsKeyDown
    local KeyDown               = Control.KeyDown
    local KeyUp                 = Control.KeyUp
    local MouseEvent            = Control.mouse_event
    local SetCursorPos          = Control.SetCursorPos
 
    local Circle                = Draw.Circle
    local CircleMinimap         = Draw.CircleMinimap
    local Color                 = Draw.Color 
    local Font                  = Draw.Font 
    local FontRect              = Draw.FontRect 
    local Line                  = Draw.Line 
    local Rect                  = Draw.Rect
    local Text                  = Draw.Text 
 
    local huge                  = math.huge
    local pi                    = math.pi
    local floor                 = math.floor 
    local sqrt                  = math.sqrt 
    local max                   = math.max 
    local min                   = math.min 
    local abs                   = math.abs 
    local deg                   = math.deg 
    local cos                   = math.cos 
    local sin                   = math.sin 
    local acos                  = math.acos 
    local atan                  = math.atan 
             
    local sort                  = table.sort 
    local insert                = table.insert 
    local remove                = table.remove 
    local contains              = table.contains 
                        
    --WR--
 
    local summoner_name         = myHero.name 
    local char_name             = myHero.charName 
    local myID                  = myHero.networkID
 
    local TEAM_JUNGLE           = 300 
    local TEAM_ALLY             = myHero.team 
    local TEAM_ENEMY            = TEAM_JUNGLE - TEAM_ALLY
 
    local _SpawnPoint           = Obj_AI_SpawnPoint
    local _Camp                 = Obj_AI_Camp
    local _Barracks             = Obj_AI_Barracks
    local _Hero                 = Obj_AI_Hero
    local _Minion               = Obj_AI_Minion
    local _Turret               = Obj_AI_Turret
    local _LineMissle           = Obj_AI_LineMissle
    local _Shop                 = Obj_AI_Shop
    local _HQ                   = "obj_HQ"
 
    local _INTERNAL             = 0
    local _AURA                 = 1 
    local _ENHANCER             = 2 
    local _DEHANCER             = 3 
    local _SPELLSHIELD          = 4 
    local _STUN                 = 5
    local _INVIS                = 6
    local _SILENCE              = 7
    local _TAUNT                = 8
    local _POLYMORPH            = 9    
    local _SLOW                 = 10    
    local _SNARE                = 11
    local _DMG                  = 12 
    local _HEAL                 = 13 
    local _HASTE                = 14
    local _SPELLIMM             = 15
    local _PHYSIMM              = 16
    local _INVULNERABLE         = 17 
    local _SLEEP                = 18 
    local _NEARSIGHT            = 19 
    local _FRENZY               = 20 
    local _FEAR                 = 21    
    local _CHARM                = 22
    local _POISON               = 23
    local _SUPRESS              = 24     
    local _BLIND                = 25
    local _COUNTER              = 26 
    local _SHRED                = 27
    local _FLEE                 = 28
    local _KNOCKUP              = 29
    local _KNOCKBACK            = 30   
    local _DISARM               = 31    
          
    --WR--

    local Common = {}

    function Common:GetDistanceSqr(p1, p2) 
        p2 = p2 or myHero
        p1 = p1.pos or p1
        p2 = p2.pos or p2

        local dx, dz = p1.x - p2.x, p1.z - p2.z 
        return dx * dx + dz * dz
    end

    function Common:GetDistance(p1, p2)
        return sqrt(GetDistanceSqr(p1, p2))
    end 

    function Common:GotBuff(unit, name)
        for i = unit.buffCount, 1, -1 do 
            local buff = unit:GetBuff(i) 
            if buff.name == name and buff.count > 0 then 
                return buff.count 
            end
        end
        return 0
    end

    function Common:GetBuffData(unit, name)
        for i = unit.buffCount, 1, -1 do 
            local buff = unit:GetBuff(i)
            if buff.name == name then 
                return buff 
            end
        end
        return nil 
    end

    function Common:HasBuffOfType(unit, type)
        for i = unit.buffCount, 1, -1 do 
            local buff = unit:GetBuff(i)
            if buff.type == type and buff.count > 0 and buff.duration > 0 then 
                return true 
            end
        end
        return false 
    end     

    --WR--

    local Prediction = {}

    function Prediction:VectorMovementCollision(startPoint1, endPoint1, v1, startPoint2, v2, delay)
        local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
        local d, e = eP1x-sP1x, eP1y-sP1y
        local dist, t1, t2 = sqrt(d*d+e*e), nil, nil
        local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
        function GetCollisionPoint(t) return t and {x = sP1x+S*t, y = sP1y+K*t} or nil end
        if delay and delay~=0 then sP1x, sP1y = sP1x+S*delay, sP1y+K*delay end
        local r, j = sP2x-sP1x, sP2y-sP1y
        local c = r*r+j*j
        if dist>0 then
            if v1 == huge then
                local t = dist/v1
                t1 = v2*t>=0 and t or nil
            elseif v2 == huge then
                t1 = 0
            else
                local a, b = S*S+K*K-v2*v2, -r*S-j*K
                if a==0 then
                    if b==0 then --c=0->t variable
                        t1 = c==0 and 0 or nil
                    else --2*b*t+c=0
                        local t = -c/(2*b)
                        t1 = v2*t>=0 and t or nil
                    end
                else --a*t*t+2*b*t+c=0
                    local sqr = b*b-a*c
                    if sqr>=0 then
                        local nom = sqrt(sqr)
                        local t = (-nom-b)/a
                        t1 = v2*t>=0 and t or nil
                        t = (nom-b)/a
                        t2 = v2*t>=0 and t or nil
                    end
                end
            end
        elseif dist==0 then
            t1 = 0
        end
        return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
    end

    function Prediction:IsDashing(unit, spell)
        local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From.pos
        local OnDash, CanHit, Pos = false, false, nil
        local pathData = unit.pathing
        --
        if pathData.isDashing then
            local startPos = Vector(pathData.startPos)
            local endPos = Vector(pathData.endPos)
            local dashSpeed = pathData.dashSpeed
            local timer = Timer()
            local startT = timer - Game.Latency()/2000
            local dashDist = GetDistance(startPos, endPos)
            local endT = startT + (dashDist/dashSpeed)
            --
            if endT >= timer and startPos and endPos then
                OnDash = true
                --
                local t1, p1, t2, p2, dist = Prediction:VectorMovementCollision(startPos, endPos, dashSpeed, from, speed, (timer - startT) + delay)
                t1, t2 = (t1 and 0 <= t1 and t1 <= (endT - timer - delay)) and t1 or nil, (t2 and 0 <= t2 and t2 <=  (endT - timer - delay)) and t2 or nil
                local t = t1 and t2 and min(t1, t2) or t1 or t2
                --
                if t then
                    Pos = t == t1 and Vector(p1.x, 0, p1.y) or Vector(p2.x, 0, p2.y)
                    CanHit = true
                else
                    Pos = Vector(endPos.x, 0, endPos.z)
                    CanHit = (unit.ms * (delay + GetDistance(from, Pos)/speed - (endT - timer))) < radius
                end
            end
        end

        return OnDash, CanHit, Pos
    end

    function Prediction:IsImmobile(unit, spell)
        if unit.ms == 0 then return true, unit.pos, unit.pos end
        local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From.pos
        local debuff = {}
        for i = unit.buffCount, 1, -1 do
            local buff = unit:GetBuff(i)
            if buff.duration > 0 then
                local ExtraDelay = speed == huge and 0 or (GetDistance(from, unit.pos) / speed)
                if buff.expireTime + (radius / unit.ms) > Timer() + delay + ExtraDelay then
                    debuff[buff.type] = true
                end
            end
        end
        if  debuff[_STUN] or debuff[_TAUNT] or debuff[_SNARE] or debuff[_SLEEP] or
            debuff[_CHARM] or debuff[_SUPRESS] or debuff[_AIRBORNE] then
            return true, unit.pos, unit.pos
        end
        return false, unit.pos, unit.pos
    end

    function Prediction:IsSlowed(unit, spell)
        local delay, speed, from = spell.Delay, spell.Speed, spell.From.pos
        for i = 1, unit.buffCount do
            local buff = unit:GetBuff(i)
            if buff.type == _SLOW and buff.expireTime >= Timer() and buff.duration > 0 then
                if buff.expireTime > Timer() + delay + GetDistance(unit.pos, from) / speed then
                    return true
                end
            end
        end
        return false
    end

    function Prediction:CalculateTargetPosition(unit, spell, tempPos)
        local delay, radius, speed, from = spell.Delay, spell.Radius, spell.Speed, spell.From
        local calcPos = nil
        local pathData = unit.pathing
        local pathCount = pathData.pathCount
        local pathIndex = pathData.pathIndex
        local pathEndPos = Vector(pathData.endPos)
        local pathPos = tempPos and tempPos or unit.pos
        local pathPot = (unit.ms * ((GetDistance(pathPos) / speed) + delay))
        local unitBR = unit.boundingRadius
        --
        if pathCount < 2 then
            local extPos = unit.pos:Extended(pathEndPos, pathPot - unitBR)
            --
            if GetDistance(unit.pos, extPos) > 0 then
                if GetDistance(unit.pos, pathEndPos) >= GetDistance(unit.pos, extPos) then
                    calcPos = extPos
                else
                    calcPos = pathEndPos
                end
            else
                calcPos = pathEndPos
            end
        else
            for i = pathIndex, pathCount do
                if unit:GetPath(i) and unit:GetPath(i - 1) then
                    local startPos = i == pathIndex and unit.pos or unit:GetPath(i - 1)
                    local endPos = unit:GetPath(i)
                    local pathDist = GetDistance(startPos, endPos)
                    --
                    if unit:GetPath(pathIndex  - 1) then
                        if pathPot > pathDist then
                            pathPot = pathPot - pathDist
                        else
                            local extPos = startPos:Extended(endPos, pathPot - unitBR)

                            calcPos = extPos

                            if tempPos then
                                return calcPos, calcPos
                            else
                                return Prediction:CalculateTargetPosition(unit, spell, calcPos)
                            end
                        end
                    end
                end
            end
            
            if GetDistance(unit.pos, pathEndPos) > unitBR then
                calcPos = pathEndPos
            else
                calcPos = unit.pos
            end
        end

        calcPos = calcPos and calcPos or unit.pos

        if tempPos then
            return calcPos, calcPos
        else
            return Prediction:CalculateTargetPosition(unit, spell, calcPos)
        end
    end

    function Prediction:GetBestCastPosition(unit, spell)       
        local range = spell.Range and spell.Range - 15 or huge
        local radius = spell.Radius == 0 and 1 or (spell.Radius + unit.boundingRadius) - 4
        local speed = spell.Speed or huge
        from = spell.From or myHero
        local delay = spell.Delay + (0.07 + Game.Latency() / 2000)
        local collision = spell.Collision or false
        --
        local Position, CastPosition, HitChance = Vector(unit), Vector(unit), 0
        local TargetDashing, CanHitDashing, DashPosition = Prediction:IsDashing(unit, spell)
        local TargetImmobile, ImmobilePos, ImmobileCastPosition = Prediction:IsImmobile(unit, spell)

        if TargetDashing then
            if CanHitDashing then
                HitChance = 5
            else
                HitChance = 0
            end
            Position, CastPosition = DashPosition, DashPosition
        elseif TargetImmobile then
            Position, CastPosition = ImmobilePos, ImmobileCastPosition
            HitChance = 4
        else
            Position, CastPosition = Prediction:CalculateTargetPosition(unit, spell)

            if unit.activeSpell and unit.activeSpell.valid then
                HitChance = 2
            end

            if GetDistanceSqr(from.pos, CastPosition) < 250 then
                HitChance = 2
                local newSpell = {Range = range, Delay = delay * 0.5, Radius = radius, Width = radius, Speed = speed *2, From = from}
                Position, CastPosition = Prediction:CalculateTargetPosition(unit, newSpell)
            end

            local temp_angle = from.pos:AngleBetween(unit.pos, CastPosition)
            if temp_angle > 60 then
                HitChance = 1
            elseif temp_angle < 30 then
                HitChance = 2
            end
        end
        if GetDistanceSqr(from.pos, CastPosition) >= range * range then
            HitChance = 0                
        end
        if collision and HitChance > 0 then
            local newSpell = {Range = range, Delay = delay, Radius = radius * 2, Width = radius * 2, Speed = speed *2, From = from}
            if #(mCollision(from.pos, CastPosition, newSpell)) > 0 then
                HitChance = 0                    
            end
        end        
        
        return Position, CastPosition, HitChance
    end

    --WR--

    _G.WR.Common = Common
    _G.WR.Prediction = Prediction

