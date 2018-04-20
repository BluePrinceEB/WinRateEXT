
    local champs = {        --Supported Champions
        "Ashe",                 --v1.0 - Reestructured and Improved - RMAN        
        "Corki",                --v1.0 - Reestructured and Improved - RMAN
        "Darius",               --v1.0 - Reestructured and Improved - RMAN
        "Draven"                --v1.0 - Reestructured and Improved - RMAN         
    }

    local brokenIconChamps = { 
        "Twitch"
    }     
    --
    local char_name = myHero.charName
    local contains = table.contains
    local isSupported = contains(champs, char_name)
    local isBrokenIconChamp = contains(brokenIconChamps, char_name)
    --x--
    icons, WR_Menu, Menu = {}

    if isSupported then
        --        
        icons.WR    = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/WinRateLogo.png"
        icons.Q     = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/spells/"..myHero:GetSpellData(_Q).name..".png"
        icons.W     = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/spells/"..myHero:GetSpellData(_W).name..".png"
        icons.E     = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/spells/"..myHero:GetSpellData(_E).name..".png"
        icons.R     = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/spells/"..myHero:GetSpellData(_R).name..".png"
        --
        --WR_Menu = MenuElement({id = "WR_Menu", name = "Win Rate Settings", type = MENU, leftIcon = icons.WR})
        --WR_Menu:MenuElement({id = "Prediction", name = "Prediction To Use", value = 1,drop = {"WinPred", "TPred", "WhateverTheFuckElseWeImplement", "No Pred"}})
        --
        Menu = MenuElement({id = char_name, name = "Project WinRate | "..char_name, type = MENU, leftIcon = icons.WR})        
            Menu:MenuElement({name = " ", drop = {"Spell Settings"}})
            if isBrokenIconChamp then                
                icons.Q = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/spells/"..char_name.."Q.png"
                icons.W = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/spells/"..char_name.."W.png"
                icons.E = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/spells/"..char_name.."E.png"
                icons.R = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/Icons/spells/"..char_name.."R.png"
            end               
            Menu:MenuElement({id = "Q", name = "Q Settings", type = MENU, leftIcon = icons.Q})
            local lambda = char_name == "Lucian" and Menu:MenuElement({id = "Q2", name = "Q2 Settings", type = MENU, leftIcon = icons.Q, tooltip = "Extended Q Settings"})            
            Menu:MenuElement({id = "W", name = "W Settings", type = MENU, leftIcon = icons.W})
            Menu:MenuElement({id = "E", name = "E Settings", type = MENU, leftIcon = icons.E})
            Menu:MenuElement({id = "R", name = "R Settings", type = MENU, leftIcon = icons.R})
            --        
            Menu:MenuElement({name = " ", drop = {"Global Settings"}})
            Menu:MenuElement({id = "Draw", name = "Draw Settings", type = MENU})
            Menu.Draw:MenuElement({id = "ON", name = "Enable Drawings", value = true})
            Menu.Draw:MenuElement({id = "TS", name = "Draw Selected Target", value = true, leftIcon = icons.WR})
            Menu.Draw:MenuElement({id = "Dmg", name = "Draw Damage On HP", value = true, leftIcon = icons.WR}) 
            Menu.Draw:MenuElement({id = "Q", name = "Q", value = false, leftIcon = icons.Q})
            Menu.Draw:MenuElement({id = "W", name = "W", value = false, leftIcon = icons.W})    
            Menu.Draw:MenuElement({id = "E", name = "E", value = false, leftIcon = icons.E})
            Menu.Draw:MenuElement({id = "R", name = "R", value = false, leftIcon = icons.R})                           
    end

    
    if _G.WR_COMMON_LOADED then
	    return 
	end
	--
	_G.WR_COMMON_LOADED = true 

  	require "MapPositionGOS"
  	require "DamageLib"    
  	require "2DGeometry"    


--<Interfaces Control>
    local _ENV = _G
    local SDK               = _G.SDK
    local Orbwalker         = SDK.Orbwalker 
    local ObjectManager     = SDK.ObjectManager
    local TargetSelector    = SDK.TargetSelector
    local HealthPrediction  = SDK.HealthPrediction
    --local Prediction     = Pred --Wont work cuz its being initialized before the class
   --</Interfaces Control>

--
    local huge = math.huge
    local pi = math.pi
    local floor = math.floor 
    local ceil = math.ceil 
    local sqrt = math.sqrt 
    local max = math.max 
    local min = math.min 
    --
    local lenghtOf = math.lenghtOf
    local abs = math.abs 
    local deg = math.deg 
    local cos = math.cos 
    local sin = math.sin 
    local acos = math.acos 
    local atan = math.atan 
    --
    local contains = table.contains
    local insert = table.insert 
    local remove = table.remove 
    --
    local TEAM_JUNGLE = 300 
    local TEAM_ALLY = myHero.team 
    local TEAM_ENEMY = TEAM_JUNGLE - TEAM_ALLY
    --
    local _STUN = 5
    local _TAUNT = 8    
    local _SLOW = 10    
    local _SNARE = 11
    local _FEAR = 21    
    local _CHARM = 22
    local _SUPRESS = 24        
    local _KNOCKUP = 29
    local _KNOCKBACK = 30 
    --
    local Vector    = Vector
    local KeyDown   = Control.KeyDown 
    local KeyUp     = Control.KeyUp
    --
    local GameCanUseSpell      = Game.CanUseSpell
    local Timer                = Game.Timer
    local Latency              = Game.Latency
    local HeroCount            = Game.HeroCount
    local Hero                 = Game.Hero
    local MinionCount          = Game.MinionCount
    local Minion               = Game.Minion
    local TurretCount          = Game.TurretCount
    local Turret               = Game.Turret
    local WardCount            = Game.WardCount
    local Ward                 = Game.Ward
    local ObjectCount          = Game.ObjectCount
    local Object               = Game.Object
    local MissileCount         = Game.MissileCount
    local Missile              = Game.Missile
    local ParticleCount        = Game.ParticleCount
    local Particle             = Game.Particle 
    --
    local DrawCircle               = Draw.Circle    
    local DrawLine                 = Draw.Line
    local DrawColor                = Draw.Color
    local DrawMap                  = Draw.CircleMinimap
    --
    local barHeight = 8
    local barWidth = 103
    local barXOffset = 18                            
    local barYOffset = 2

    --<IOrbwalker>

    local function GetMode() --1:Combo|2:Harass|3:LaneClear|4:JungleClear|5:LastHit|6:Flee 
        local modes = Orbwalker.Modes               
        for i=0, #modes do            
            if modes[i] then return i+1 end 
        end
        return nil 
    end

    local function GetMinions(range)        
        return ObjectManager:GetMinions(range)
    end

    local function GetAllyMinions(range)
        return ObjectManager:GetAllyMinions(range)
    end

    local function GetEnemyMinions(range)
        return ObjectManager:GetEnemyMinions(range)
    end

    local function GetMonsters(range)
        return ObjectManager:GetMonsters(range)
    end

    local function GetHeroes(range)
        return ObjectManager:GetHeroes(range)
    end

    local function GetAllyHeroes(range)
        return ObjectManager:GetAllyHeroes(range)
    end

    local function GetEnemyHeroes(range)
        return ObjectManager:GetEnemyHeroes(range)
    end

    local function GetTurrets(range)
        return ObjectManager:GetTurrets(range)
    end

    local function GetAllyTurrets(range)
        return ObjectManager:GetAllyTurrets(range)
    end

    local function GetEnemyTurrets(range)
        return ObjectManager:GetEnemyTurrets(range)
    end

    local function GetWards(range)
        return ObjectManager:GetOtherMinions(range)
    end

    local function GetAllyWards(range)
        return ObjectManager:GetOtherAllyMinions(range)
    end

    local function GetEnemyWards(range)
        return ObjectManager:GetOtherEnemyMinions(range)
    end

    local function OnPreMovement(fn)
        Orbwalker:OnPreMovement(fn)
    end

    local function OnPreAttack(fn)
        Orbwalker:OnPreAttack(fn)
    end

    local function OnAttack(fn)
        Orbwalker:OnAttack(fn)
    end

    local function OnPostAttack(fn)
        Orbwalker:OnPostAttack(fn)
    end

    local function SetMovement(bool)
        Orbwalk:SetMovement(bool)
    end

    local function SetAttack(bool)
        Orbwalk:SetAttack(bool)
    end

    local function GetTarget(range, mode)     --0:Physical|1:Magical|2:True
        return TargetSelector:GetTarget(range or huge, mode or 0)
    end

    local function ResetAutoAttack()
        Orbwalker:__OnAutoAttackReset()
    end

    local function Orbwalk()
        Orbwalker:Orbwalk()
    end

    local function SetHoldRadius(value)
        Orbwalker.Menu.General.HoldRadius:Value(value)
    end

    local function SetMovementDelay(value)
        Orbwalker.Menu.General.MovementDelay:Value(value)
    end

    local function ForceTarget(unit)        
        Orbwalker.ForceTarget = unit
    end

    local function ForceMovement(pos)        
        Orbwalker.ForceMovement = pos
    end

    local function GetHealthPrediction(unit, delay)
        return HealthPrediction:GetPrediction(unit, delay)
    end    
    
    --</IOrbwalker>

	function Ready(spell)
        return GameCanUseSpell(spell) == 0
    end

    local function RotateAroundPoint(v1,v2, angle)
        local cos, sin = cos(angle), sin(angle)
        local x = ((v1.x - v2.x) * cos) - ((v1.z - v2.z) * sin) + v2.x
        local z = ((v1.z - v2.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
        return Vector(x, v1.y, z or 0)
    end

    local function GetDistanceSqr(p1, p2) 
        p2 = p2 or myHero
        p1 = p1.pos or p1
        p2 = p2.pos or p2

        local dx, dz = p1.x - p2.x, p1.z - p2.z 
        return dx * dx + dz * dz
    end

    local function GetDistance(p1, p2)
        return sqrt(GetDistanceSqr(p1, p2))
    end 

    local ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7}
    local function GetItemSlot(id) --returns Slot, HotKey
        for i = ITEM_1, ITEM_7 do
            if myHero:GetItemData(i).itemID == id then
               return i, ItemHotKey[i]
            end
        end
        return 0 
    end

    local wardItemIDs = {3340,2049,2301,2302,2303,3711}
    local function GetWardSlot() --returns Slot, HotKey
        for i=1, #wardItemIDs do            
            local ward, key = GetItemSlot(wardItemIDs[i])        
            if ward ~= 0 then               
                return ward , key
            end
        end
    end

    local rotateAngle = 0
    local function DrawMark(pos, thickness, size, color)
        rotateAngle = (rotateAngle + 2) % 720
        local hPos, thickness, color, size = pos or myHero.pos, thickness or 3, color or DrawColor(255,255,0,0), size*2 or 150
        local offset, rotateAngle, mod = hPos + Vector(0, 0, size), rotateAngle/360 * pi , 240/360*pi    
        local points = {
            hPos:To2D(),
            RotateAroundPoint(offset, hPos, rotateAngle):To2D() ,  
            RotateAroundPoint(offset, hPos, rotateAngle+mod):To2D() ,
            RotateAroundPoint(offset, hPos, rotateAngle+2*mod):To2D()
        }        
        --
        for i=1, #points do
            for j=1, #points do
                local lambda = i~=j and DrawLine(points[i].x-3, points[i].y-5, points[j].x-3, points[j].y-5, thickness, color)    -- -3 and -5 are offsets (because ext)
            end
        end
    end

    local function DrawRectOutline(vec1, vec2, width, color)
        local vec3, vec4 = vec2 - vec1, vec1 - vec2
        local A = (vec1 + (vec3:Perpendicular2():Normalized() * width )):To2D()
        local B = (vec1 + (vec3:Perpendicular():Normalized() * width )):To2D()
        local C = (vec2 + (vec4:Perpendicular2():Normalized() * width )):To2D()
        local D = (vec2 + (vec4:Perpendicular():Normalized() * width )):To2D()

        DrawLine(A, B, 3, color)
        DrawLine(B, C, 3, color)
        DrawLine(C, D, 3, color)
        DrawLine(D, A, 3, color)
    end      

    local function VectorPointProjectionOnLineSegment(v1, v2, v)
        local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
        local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
        local pointLine = { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }
        local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
        local isOnSegment = rS == rL
        local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
        return pointSegment, pointLine, isOnSegment
    end    

    local function mCollision(pos1, pos2, spell, list) --returns a table with minions (use #table to get count)
        local result, speed, width, delay, list = {}, spell.Speed, spell.Width + 65, spell.Delay , list
        --
        if not list then
            list = GetEnemyMinions(max(GetDistance(pos1), GetDistance(pos2)) + spell.Range + 100)
        end
        --
        for i = 1, #list do
            local m = list[i]
            local pos3 = delay and m:GetPrediction(speed, delay) or m.pos
            if m and m.team ~= TEAM_ALLY and m.dead == false and m.isTargetable and GetDistanceSqr(pos1, pos2) > GetDistanceSqr(pos1, pos3) then                
                local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(pos1, pos2, pos3)
                if isOnSegment and GetDistanceSqr(pointSegment, pos3) < width * width  then
                    result[#result+1] = m
                end
            end
        end               
        return result        
    end

    local function hCollision(pos1, pos2, spell, list)  --returns a table with heroes (use #table to get count)
        local result, speed, width, delay, list = {}, spell.Speed, spell.Width + 65, spell.Delay , list
        if not list then
            list = GetEnemyHeroes(max(GetDistance(pos1), GetDistance(pos2)) + spell.Range + 100)
        end
        for i = 1, #list do
            local h = list[i]
            local pos3 = delay and h:GetPrediction(speed, delay) or h.pos
            if h and h.team ~= TEAM_ALLY and h.dead == false and h.isTargetable and GetDistanceSqr(pos1, pos2) > GetDistanceSqr(pos1, pos3) then                
                local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(pos1, pos2, pos3)
                if isOnSegment and GetDistanceSqr(pointSegment, pos3) < width * width  then
                    insert(result, h)
                end
            end
        end
        return result
    end   

    local function HealthPercent(unit)
        return unit.maxHealth > 5 and unit.health/unit.maxHealth * 100 or 100
    end

    local function ManaPercent(unit)
        return unit.maxMana > 0 and unit.mana/unit.maxMana * 100 or 100
    end

    local function HasBuffOfType(unit, bufftype, delay)    --returns bool and endtime , why not starting at buffCOunt and check back to 1 ?
        local delay = delay or 0
        local bool = false
        local endT = Timer()
        for i=1, unit.buffCount do
            local buff = unit:GetBuff(i)
            if buff.type == bufftype and buff.expireTime >= Timer() and buff.duration > 0 then
                if buff.expireTime > endT then
                    bool = true 
                    endT = buff.expireTime
                end
            end
        end
        return bool, endT
    end

    local function HasBuff(unit, buffname)  --returns bool 
        return GotBuff(unit, buffname) == 1
    end

    local function GetBuffByName(unit, buffname)    --returns buff 
        return GetBuffData(unit, buffname)
    end

    local function GetBuffByType(unit, bufftype)    --returns buff 
        for i=1, unit.buffCount do
            local buff = unit:GetBuff(i)
            if buff.type == bufftype and buff.expireTime >= Timer() and buff.duration > 0  then
                return buff
            end
        end
        return nil
    end

    local UndyingBuffs = {
        ["Aatrox"] = function(target, addHealthCheck)
            return HasBuff(target, "aatroxpassivedeath")
        end,
        ["Fiora"] = function(target, addHealthCheck)
            return HasBuff(target, "FioraW")
        end,
        ["Tryndamere"] = function(target, addHealthCheck)
            return HasBuff(target, "UndyingRage") and (not addHealthCheck or target.health <= 30)
        end,
        ["Vladimir"] = function(target, addHealthCheck)
            return HasBuff(target, "VladimirSanguinePool")
        end,
    }

    local function HasUndyingBuff(target, addHealthCheck)
        --Self Casts Only
        local buffCheck = UndyingBuffs[target.charName]
        if buffCheck and buffCheck(target, addHealthCheck) then return true end
        --Can Be Casted On Others
        if HasBuff(target, "JudicatorIntervention") or ((not addHealthCheck or HealthPercent(target) <= 10) and (HasBuff(target, "kindredrnodeathbuff") or HasBuff(target, "ChronoShift") or HasBuff(target, "chronorevive"))) then
            return true
        end        
        return target.isImmortal
    end    

    local function IsValidTarget(unit, range) -- the == false check is faster than using "not"
        return unit and unit.valid and unit.visible and not unit.dead and unit.isTargetableToTeam and (not range or GetDistance(unit) <= range) and (not unit.type == myHero.type or not HasUndyingBuff(unit, true))
    end

    local function GetTrueAttackRange(unit, target)
        local extra = target and target.boundingRadius or 0
        return unit.range + unit.boundingRadius + extra
    end

    local function CountEnemiesAround(pos, range)
        return #HeroesAround(range, pos, TEAM_ENEMY)
    end

    local function HeroesAround(range, pos, team)
        pos = pos or myHero.pos
        local dist = GetDistance(pos) + range + 100
        local result = {}
        local heroes = (team == TEAM_ENEMY and GetEnemyHeroes(dist)) or (team == TEAM_ALLY and GetAllyHeroes(dist) or GetHeroes(dist))
        for i = 1, #heroes do
            local m = heroes[i]
            if h and m.team == team and h.isValid and h.visible and not h.dead and GetDistance(pos, h.pos) <= range then
                result[#result+1] = h
            end
        end
        return result
    end 

    local function MinionsAround(range, pos, team)
        pos = pos or myHero.pos
        local dist = GetDistance(pos) + range + 100
        local result = {}
        local minions = (team == TEAM_ENEMY and GetEnemyMinions(dist)) or (team == TEAM_ALLY and GetAllyMinions(dist) or GetMinions(dist))
        for i = 1, #minions do
            local m = minions[i]
            if m and not m.dead and GetDistance(pos, m.pos) <= range + m.boundingRadius then
                result[#result+1] = m
            end
        end
        return result
    end

    local function IsUnderTurret(pos, team)
        local turrets = GetTurrets(1000)
        for i=1, #turrets do
            if GetDistance(turrets[i]) <= 915 and turret.team == team then
                return true
            end
        end        
    end

    local function IsImmobile(unit, delay) 
        if unit.ms == 0 then return true, unit.pos, unit.pos end
        local delay = delay or 0
        local debuff, timeCheck = {} , Timer() + delay
        for i=1, unit.buffCount do
            local buff = unit:GetBuff(i)
            if buff.expireTime >= timeCheck and buff.duration > 0 then
                debuff[buff.type] = true
            end
        end
        if  debuff[_STUN] or debuff[_TAUNT] or debuff[_SNARE] or debuff[_SLEEP] or
            debuff[_CHARM] or debuff[_SUPRESS] or debuff[_AIRBORNE] then            
            return true
        end            
    end

    local function IsFacing(unit, p2)
        p2 = p2 or myHero        
        p2 = p2.pos or p2
        local V = unit.pos - p2
        local D = unit.dir
        local Angle = 180 - deg(acos(V*D/(V:Len()*D:Len())))
        if abs(Angle) < 80 then 
            return true  
        end        
    end

    local function CheckHandle(tbl, handle)
        for i=1, #tbl do
            local v = tbl[i]            
            if handle == v.handle then return v end                                 
        end
    end

    local function GetTargetByHandle(handle)
        return CheckHandle(GetEnemyHeroes(1200), handle)    or 
               CheckHandle(GetMonsters(1200), handle)       or 
               CheckHandle(GetEnemyTurrets(1200), handle)   or
               CheckHandle(GetEnemyMinions(1200), handle)   or 
               CheckHandle(GetEnemyWards(1200), handle)
    end

    local function ShouldWait()
        return myHero.dead or HasBuff(myHero,"recall") or Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading == true) 
    end

    local Emote = {
        Joke = HK_ITEM_1, 
        Taunt = HK_ITEM_2,
        Dance = HK_ITEM_3,
        Mastery = HK_ITEM_5,
        Laugh = HK_ITEM_7,
        Casting = false
    }  

    local function CastEmote(emote)        
        if not emote or Emote.Casting or myHero.attackData.state == STATE_WINDUP then return end
        --
        Emote.Casting = true        
        KeyDown(HK_LUS)        
        KeyDown(emote)            
        DelayAction(function()
            KeyUp(emote)
            KeyUp(HK_LUS)                
            Emote.Casting = false                
        end, 0.01)        
    end

    -- Farm Stuff

    local function ExcludeFurthest(average,lst,sTar)
        local removeID = 1 
        for i = 2, #lst do 
            if GetDistanceSqr(average, lst[i].pos) > GetDistanceSqr(average, lst[removeID].pos) then 
                removeID = i 
            end 
        end 

        local Newlst = {}
        for i = 1, #lst do 
            if (sTar and lst[i].networkID == sTar.networkID) or i ~= removeID then 
                Newlst[#Newlst + 1] = lst[i]
            end
        end
        return Newlst 
    end

    local function GetBestCircularCastPos(spell, sTar, lst)
        local average = {x = 0, z = 0, count = 0} 
        local heroList = lst and lst[1] and (lst[1].type == myHero.type)
        local range = spell.Range or 2000
        local radius = spell.Radius or 50
        if not lst or #lst == 0 then 
            if sTar then return Prediction:GetBestCastPosition(sTar,spell) end
            return 
        end
        --
        for i = 1, #lst do 
            if GetDistanceSqr(lst[i]) <= range * range then
                local org = heroList and Prediction:GetBestCastPosition(lst[i],spell) or lst[i].pos
                average.x = average.x + org.x 
                average.z = average.z + org.z 
                average.count = average.count + 1
            end
        end 
        --
        if sTar and sTar.type ~= lst[1].type then 
            local org = heroList and Prediction:GetBestCastPosition(sTar,spell) or lst[i].pos
            average.x = average.x + org.x 
            average.z = average.z + org.z 
            average.count = average.count + 1
        end
        --
        average.x = average.x/average.count 
        average.z = average.z/average.count 
        --
        local inRange = 0 
        for i = 1, #lst do 
            local bR = lst[i].boundingRadius
            if GetDistanceSqr(average, lst[i].pos) - bR * bR < radius * radius then 
                inRange = inRange + 1 
            end
        end
        --
        local point = Vector(average.x,myHero.pos.y,average.z)
        --
        if inRange == #lst then 
            return point, inRange
        else 
            return GetBestCircularCastPos(spell, sTar, ExcludeFurthest(average, lst))
        end
    end 

    local function GetBestLinearCastPos(spell, sTar, list)
        startPos = spell.From.pos or myHero.pos
        local isHero =  list[1].type == myHero.type
        --
        local center = GetBestCircularCastPos(spell, sTar, list)
        local endPos = startPos + (center - startPos):Normalized() * spell.Range
        local MostHit = isHero and #hCollision(startPos, endPos, spell, list) or #mCollision(startPos, endPos, spell, list)      
        return endPos, MostHit
    end
    
    local function GetBestLinearFarmPos(spell)
        local minions = GetEnemyMinions(spell.Range+spell.Radius)
        if #minions == 0 then return nil, 0 end
        return GetBestLinearCastPos(spell, nil, minions)
    end

    local function GetBestCircularFarmPos(spell)
        local minions = GetEnemyMinions(spell.Range+spell.Radius)
        if #minions == 0 then return nil, 0 end
        return GetBestCircularCastPos(spell, nil, minions)
    end

    class "Spell"

    function Spell:__init(SpellData)
        self.Slot       = SpellData.Slot
        self.Range      = SpellData.Range or huge
        self.Delay      = SpellData.Delay or 0.25
        self.Speed      = SpellData.Speed or huge
        self.Radius     = SpellData.Radius or SpellData.Width or 0
        self.Width      = SpellData.Width or SpellData.Radius or 0
        self.From       = SpellData.From or myHero
        self.Collision  = SpellData.Collision or false
        self.Type       = SpellData.Type or "Press"
        --
        return self
    end

    function Spell:SetRange(value)
        self.Range = value
    end

    function Spell:SetRadius(value)
        self.Radius = value
    end

    function Spell:SetSpeed(value)
        self.Speed = value
    end

    function Spell:SetFrom(value)
        self.From = value
    end

    function Spell:IsReady()
        return GameCanUseSpell(self.Slot) == READY
    end

    function Spell:CanCast(unit, range, from)
        local from = from or self.From.pos
        local range = range or self.Range
        return unit and unit.valid and unit.visible and not unit.dead and (not range or GetDistance(from, unit) <= range)
    end

    function Spell:GetPrediction(target)
        return Prediction:GetBestCastPosition(target, self)        
    end

    function Spell:GetBestLinearCastPos(sTar, lst)
        return GetBestLinearCastPos(self, sTar, lst)
    end

    function Spell:GetBestCircularCastPos(sTar, lst)
        return GetBestCircularCastPos(self, sTar, lst)
    end

    function Spell:GetBestLinearFarmPos()
        return GetBestLinearFarmPos(self)
    end

    function Spell:GetBestCircularFarmPos()
        return GetBestCircularFarmPos(self)
    end

    function Spell:GetDamage(target, stage)
        local slot = self:SlotToString()
        return getdmg(slot, target, self.From, stage or 1)
    end

    function Spell:OnDash(target)
        local OnDash, CanHit, Pos = Prediction:IsDashing(target, self)

        if self.Collision then
            local colStatus = #(mCollision(self.From.pos, Pos, self)) > 0
            if colStatus then return end
            return OnDash, CanHit, Pos
        end

        return OnDash, CanHit, Pos
    end

    function Spell:OnImmobile(target)
        local TargetImmobile, ImmobilePos, ImmobileCastPosition = Prediction:IsImmobile(target, self)

        if self.Collision then
            local colStatus = #(mCollision(self.From.pos, Pos, self)) > 0
            if colStatus then return end
            return TargetImmobile, ImmobilePos, ImmobileCastPosition
        end

        return TargetImmobile, ImmobilePos, ImmobileCastPosition
    end

    function Spell:SlotToHK()
        return ({ [_Q] = HK_Q, [_W] = HK_W, [_E] = HK_E, [_R] = HK_R, [SUMMONER_1] = HK_SUMMONER_1, [SUMMONER_2] = HK_SUMMONER_2})[self.Slot]
    end

    function Spell:SlotToString()
        return ({ [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R" })[self.Slot]
    end

    function Spell:Cast(castOn)
        if not self:IsReady() or ShouldWait() then return end         
        --       
        local slot = self:SlotToHK()
        if self.Type == "Press" then
            KeyDown(slot)
            return KeyUp(slot)
        end
        -- 
        local pos  = castOn.x and castOn
        local targ = castOn.health and castOn 
        --           
        if self.Type == "AOE" then
            local bestPos, hit = self:GetBestCircularCastPos(targ, GetEnemyHeroes(self.Range+self.Radius))
            pos = hit >= 2 and bestPos or pos
        end
        --        
        if (targ and not targ.pos:To2D().onScreen) then
            return  
        elseif (pos and not pos:To2D().onScreen) then
            pos = myHero.pos:Extended(pos, 200)
            if self.Type == "AOE" or not pos:To2D().onScreen then return end                                               
        end
        --                       
        return Control.CastSpell(slot, targ or pos)
    end

    function Spell:CastToPred(target, minHitchance)
        local predPos, castPos, hC = self:GetPrediction(target)        
        if predPos and hC >= minHitchance then                         
            return self:Cast(predPos)            
        end
    end

    function Spell:DrawDmg(hero, dmgModMultiplier, dmgModFlat, stage)
        local barPos = hero.hpBar
        if barPos.onScreen then                
            local damage = (self:IsReady() and 1 or 0) * self:GetDamage(hero, stage) * (dmgModMultiplier or 1) + (dmgModFlat or 0)
            local percentHealthAfterDamage = max(0, hero.health - damage) / hero.maxHealth
            local xPosEnd = barPos.x + barXOffset+ barWidth * hero.health/hero.maxHealth
            local xPosStart = barPos.x +barXOffset+  percentHealthAfterDamage * 100                            
            DrawLine(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, Draw.Color(255,235,103,25))                
        end        
    end

    function Spell:Draw(r, g, b)
        if self.Range and self.Range ~= huge then
            if self:IsReady() then 
                DrawCircle(self.From.pos, self.Range, 5, DrawColor(255, r, g, b))
            else
                DrawCircle(self.From.pos, self.Range, 5, DrawColor(80, r, g, b))
            end
            return true
        end
    end  

    function Spell:DrawMap(r, g, b)
        if self.Range and self.Range ~= huge then
            if self:IsReady() then 
                DrawMap(self.From.pos, self.Range, 5, DrawColor(255, r, g, b))
            else
                DrawMap(self.From.pos, self.Range, 5, DrawColor(80, r, g, b))
            end
            return true
        end        
    end

    print("[WR] Common Loaded")

    local _SPELL_TABLE_PROCESS = {}
    local _ANIMATION_TABLE = {}
    local _VISION_TABLE = {}
    local _LEVEL_UP_TABLE = {}
    local _ITEM_TABLE = {}
    local _PATH_TABLE = {}

    class 'BuffExplorer'
    
    function BuffExplorer:__init()
        __BuffExplorer = true
        self.Heroes = {}
        self.Buffs  = {}
        self.RemoveBuffCallback = {}
        self.UpdateBuffCallback = {}
        Callback.Add("Tick", function () self:Tick() end)
    end    

    function BuffExplorer:Tick() -- We can easily get rid of the pairs loops 
        for i = 1, HeroCount() do
            local hero = Hero(i)
            if not self.Heroes[hero] and not self.Buffs[hero.networkID] then
                insert(self.Heroes, hero)
                self.Buffs[hero.networkID] = {}
            end
        end
        if self.UpdateBuffCallback ~= {} then
            for i=1, #self.Heroes do
                local hero = self.Heroes[i]
                for i = 1, hero.buffCount do
                    local buff = hero:GetBuff(i)
                    if self:Valid(buff) then
                        if not self.Buffs[hero.networkID][buff.name] or (self.Buffs[hero.networkID][buff.name] and self.Buffs[hero.networkID][buff.name].expireTime ~= buff.expireTime) then
                            self.Buffs[hero.networkID][buff.name] = {expireTime = buff.expireTime, sent = true, networkID = buff.sourcenID, buff = buff}
                            for i, cb in pairs(self.RemoveBuffCallback) do
                                cb(hero,buff)
                            end
                        end
                    end
                end
            end
        end
        if self.RemoveBuffCallback ~= {} then
            for i=1, #self.Heroes do
                local hero = self.Heroes[i]
                for buffname,buffinfo in pairs(self.Buffs[hero.networkID]) do
                    if buffinfo.expireTime < Timer() then
                        for i, cb in pairs(self.UpdateBuffCallback) do
                            cb(hero,buffinfo.buff)
                        end
                        self.Buffs[hero.networkID][buffname] = nil                        
                    end
                end
            end
        end
    end
    
    function BuffExplorer:Valid(buff)
        return buff and buff.name and #buff.name > 0 and buff.startTime <= Timer() and buff.expireTime > Timer()
    end

    class("Animation")
    
    function Animation:__init()
        _G._ANIMATION_STARTED = true
        self.OnAnimationCallback = {}
        Callback.Add("Tick", function () self:Tick() end)
    end
    
    function Animation:Tick()
        if self.OnAnimationCallback ~= {} then
            for i = 1, HeroCount() do
                local hero = Hero(i)
                local netID = hero.networkID            
                if hero.activeSpellSlot then
                    if not _ANIMATION_TABLE[netID] and hero.charName ~= "" then
                        _ANIMATION_TABLE[netID] = {animation = ""}
                    end
                    local _animation = hero.attackData.animationTime
                    if _ANIMATION_TABLE[netID] and _ANIMATION_TABLE[netID].animation ~= _animation then
                        for _, Emit in pairs(self.OnAnimationCallback) do
                            Emit(hero, hero.attackData.animationTime)
                        end
                        _ANIMATION_TABLE[netID].animation = _animation
                    end
                end
            end
        end
    end 
    
    class("Vision")
    
    function Vision:__init()        
        self.GainVisionCallback = {}
        self.LoseVisionCallback = {}
        _G._VISION_STARTED = true
        Callback.Add("Tick", function () self:Tick() end)    
    end
    
    function Vision:Tick()
        local heroCount = HeroCount()  
        --if heroCount <= 0 then return end  
        for i = 1, heroCount do        
            local hero = Hero(i)
            if hero then
                local netID = hero.networkID
                if not _VISION_TABLE[netID] then
                    _VISION_TABLE[netID] = {visible = hero.visible}
                end
                if self.LoseVisionCallback ~= {} then
                    if hero.visible == false and _VISION_TABLE[netID] and _VISION_TABLE[netID].visible == true then
                        _VISION_TABLE[netID] = {visible = hero.visible}
                        for _, Emit in pairs(self.LoseVisionCallback) do
                            Emit(hero)
                        end
                    end
                end
                if self.GainVisionCallback ~= {} then
                    if hero.visible == true and _VISION_TABLE[netID] and _VISION_TABLE[netID].visible == false then
                        _VISION_TABLE[netID] = {visible = hero.visible}
                        for _, Emit in pairs(self.GainVisionCallback) do
                            Emit(hero)
                        end
                    end
                end
            end
        end
    end

    class "Path"
    
    function Path:__init()
        self.OnNewPathCallback = {}
        self.OnDashCallback = {}
        _G._PATH_STARTED = true        
        Callback.Add("Tick", function() self:Tick() end)
    end
    
    function Path:Tick()
        if self.OnNewPathCallback ~= {} or self.OnDashCallback ~= {} then
            for i = 1, HeroCount() do
                local hero = Hero(i)
                self:OnPath(hero)           
            end
        end
    end
    
    function Path:OnPath(unit)
        if not _PATH_TABLE[unit.networkID] then
            _PATH_TABLE[unit.networkID] = {
                pos = unit.posTo,
                speed = unit.ms,
                time = Timer()
            }
        end
    
        if _PATH_TABLE[unit.networkID].pos ~= unit.posTo then
            local path = unit.pathing
            local isDash = path.isDashing
            local dashSpeed = path.dashSpeed 
            local dashGravity = path.dashGravity 
            local dashDistance = GetDistance(unit.pos, unit.posTo)
            --
            _PATH_TABLE[unit.networkID] = {
                startPos = unit.pos,
                pos = unit.posTo ,
                speed = unit.ms,
                time = Timer()
            }
                --
            for k, cb in pairs(self.OnNewPathCallback) do
                cb(unit, unit.pos, unit.posTo, isDash, dashSpeed, dashGravity, dashDistance)
            end
            --
            if isDash then
                for k, cb in pairs(self.OnDashCallback) do
                    cb(unit, unit.pos, unit.posTo, dashSpeed, dashGravity, dashDistance)
                end
            end
        end
    end
    
    class("LevelUp")
    
    function LevelUp:__init()
        _G._LEVEL_UP_START = true
        self.OnLevelUpCallback = {}
        for _ = 1, HeroCount() do
            local obj = Hero(_)
            if obj then
                _LEVEL_UP_TABLE[obj.networkID] = {level = obj.levelData.lvl == 1 and 0 or obj.levelData.lvl}
            end
        end
        Callback.Add("Tick", function () self:Tick() end)
    end
    
    function LevelUp:Tick()
        if self.OnLevelUpCallback ~= {} then
            for i = 1, HeroCount() do
                local hero = Hero(i)
                local level = hero.levelData.lvl
                local netID = hero.networkID
                if not _LEVEL_UP_TABLE[netID] then 
                    _LEVEL_UP_TABLE[netID] = {level = obj.levelData.lvl == 1 and 0 or obj.levelData.lvl}
                end
                if _LEVEL_UP_TABLE[netID] and level and _LEVEL_UP_TABLE[netID].level ~= level then
                    for _, Emit in pairs(self.OnLevelUpCallback) do
                        Emit(hero, hero.levelData)
                    end
                    _LEVEL_UP_TABLE[netID].level = level
                end
            end
        end
    end
    
    class("ItemEvents")
    
    function ItemEvents:__init()
        self.BuyItemCallback = {}
        self.SellItemCallback = {}
        _G._ITEM_CHECKER_STARTED = true
        for i = ITEM_1, ITEM_7 do
            if myHero:GetItemData(i).itemID ~= 0 then
                _ITEM_TABLE[i] = {has = true, data = myHero:GetItemData(i)}
            else
                _ITEM_TABLE[i] = {has = false, data = nil}
            end
        end
    
        Callback.Add("Tick", function () self:Tick() end)
    end
    
    function ItemEvents:Tick()
        for i = ITEM_1, ITEM_7 do
            if myHero:GetItemData(i).itemID ~= 0 then
                if _ITEM_TABLE[i].has == false then
                    _ITEM_TABLE[i].has = true
                    _ITEM_TABLE[i].data = myHero:GetItemData(i)
                    for _, Emit in pairs(self.BuyItemCallback) do
                        Emit(myHero:GetItemData(i), i)
                    end                    
                end
            else
                if _ITEM_TABLE[i].has == true then
                    for _, Emit in pairs(self.SellItemCallback) do
                        Emit(_ITEM_TABLE[i].data, i)
                    end                    
                    _ITEM_TABLE[i].has = false
                    _ITEM_TABLE[i].data = nil
                end
            end
        end
    end    

    class("Interrupter")
    
    function Interrupter:__init()
        _G._INTERRUPTER_START = true
        self.InterruptCallback = {}
        self.spells = { --ty Deftsu
            ["CaitlynAceintheHole"]         = {Name = "Caitlyn",      displayname = "R | Ace in the Hole", spellname = "CaitlynAceintheHole"},
            ["Crowstorm"]                   = {Name = "FiddleSticks", displayname = "R | Crowstorm", spellname = "Crowstorm"},
            ["DrainChannel"]                = {Name = "FiddleSticks", displayname = "W | Drain", spellname = "DrainChannel"},
            ["GalioIdolOfDurand"]           = {Name = "Galio",        displayname = "R | Idol of Durand", spellname = "GalioIdolOfDurand"},
            ["ReapTheWhirlwind"]            = {Name = "Janna",        displayname = "R | Monsoon", spellname = "ReapTheWhirlwind"},
            ["KarthusFallenOne"]            = {Name = "Karthus",      displayname = "R | Requiem", spellname = "KarthusFallenOne"},
            ["KatarinaR"]                   = {Name = "Katarina",     displayname = "R | Death Lotus", spellname = "KatarinaR"},
            ["LucianR"]                     = {Name = "Lucian",       displayname = "R | The Culling", spellname = "LucianR"},
            ["AlZaharNetherGrasp"]          = {Name = "Malzahar",     displayname = "R | Nether Grasp", spellname = "AlZaharNetherGrasp"},
            ["Meditate"]                    = {Name = "MasterYi",     displayname = "W | Meditate", spellname = "Meditate"},
            ["MissFortuneBulletTime"]       = {Name = "MissFortune",  displayname = "R | Bullet Time", spellname = "MissFortuneBulletTime"},
            ["AbsoluteZero"]                = {Name = "Nunu",         displayname = "R | Absoulte Zero", spellname = "AbsoluteZero"},
            ["PantheonRJump"]               = {Name = "Pantheon",     displayname = "R | Jump", spellname = "PantheonRJump"},
            ["PantheonRFall"]               = {Name = "Pantheon",     displayname = "R | Fall", spellname = "PantheonRFall"},
            ["ShenStandUnited"]             = {Name = "Shen",         displayname = "R | Stand United", spellname = "ShenStandUnited"},
            ["Destiny"]                     = {Name = "TwistedFate",  displayname = "R | Destiny", spellname = "Destiny"},
            ["UrgotSwap2"]                  = {Name = "Urgot",        displayname = "R | Hyper-Kinetic Position Reverser", spellname = "UrgotSwap2"},
            ["VarusQ"]                      = {Name = "Varus",        displayname = "Q | Piercing Arrow", spellname = "VarusQ"},
            ["VelkozR"]                     = {Name = "Velkoz",       displayname = "R | Lifeform Disintegration Ray", spellname = "VelkozR"},
            ["InfiniteDuress"]              = {Name = "Warwick",      displayname = "R | Infinite Duress", spellname = "InfiniteDuress"},
            ["XerathLocusOfPower2"]         = {Name = "Xerath",       displayname = "R | Rite of the Arcane", spellname = "XerathLocusOfPower2"}
        }
        Callback.Add("Tick", function() self:OnTick() end)
    end
    
    function Interrupter:AddToMenu(unit, menu)
        self.menu = menu
        if unit then
            for i=1, #(self.spells) do
                local spells = self.spells[i]
                if spells.Name == unit.charName then
                    self.menu:MenuElement({id = spells.spellname, name = spells.Name .. " | " .. spells.displayname, value = true})
                end
            end
        end
    end
    
    function Interrupter:OnTick()
        local enemies = GetEnemyHeroes(3000)
        for i=1, #(enemies) do
            local enemy = enemies[i]
            if enemy and enemy.activeSpell and enemy.activeSpell.valid then
                local spell = enemy.activeSpell
                if self.spells[spell.name] and self.menu and self.menu[spell.name] and self.menu[spell.name]:Value() and spell.isChanneling and spell.castEndTime - Timer() > 0 then
                    for i, Emit in pairs(self.InterruptCallback) do
                        Emit(enemy, spell)
                    end
                end
            end
        end
    end    
    
    --------------------------------------
    local function OnInterruptable(fn)
        if not _INTERRUPTER_START then  
            _G.Interrupter = Interrupter()
            print("[WR] Callbacks | Interrupter Loaded.")
        end
        insert(Interrupter.InterruptCallback, fn)
    end
    local function OnLevelUp(fn)
        if not _LEVEL_UP_START then  
            _G.LevelUp = LevelUp()
            print("[WR] Callbacks | Level Up Loaded.")
        end
        insert(LevelUp.OnLevelUpCallback, fn)
    end
    
    local function OnNewPath(fn)
        if not _PATH_STARTED then  
            _G.Path = Path()
            print("[WR] Callbacks | Pathing Loaded.")
        end
        insert(Path.OnNewPathCallback, fn)
    end
    
    local function OnDash(fn)
        if not _PATH_STARTED then  
           _G.Path = Path()
           print("[WR] Callbacks | Pathing Loaded.")
        end
        insert(Path.OnDashCallback, fn)
    end
    
    local function OnGainVision(fn)
        if not _VISION_STARTED then  
           _G.Vision = Vision()
           print("[WR] Callbacks | Vision Loaded.")
        end
        insert(Vision.GainVisionCallback, fn)
    end
    
    local function OnLoseVision(fn)
        if not _VISION_STARTED then  
            _G.Vision = Vision()
            print("[WR] Callbacks | Vision Loaded.")
        end
        insert(Vision.LoseVisionCallback, fn)
    end
    
    local function OnAnimation(fn)
        if not _ANIMATION_STARTED then  
            _G.Animation = Animation()
            print("[WR] Callbacks | Animation Loaded.")
        end
        insert(Animation.OnAnimationCallback, fn)
    end
    
    local function OnUpdateBuff(cb)
        if not __BuffExplorer_Loaded then   
            _G.BuffExplorer = BuffExplorer()
            print("[WR] Callbacks | Buff Explorer Loaded.") 
        end
        insert(BuffExplorer.UpdateBuffCallback,cb)
    end
    
    local function OnRemoveBuff(cb)
        if not __BuffExplorer_Loaded then   
            _G.BuffExplorer = BuffExplorer()
            print("[WR] Callbacks | Buff Explorer Loaded.") 
        end
        insert(BuffExplorer.RemoveBuffCallback,cb)
    end
    
    local function OnBuyItem(fn)
        if not _ITEM_CHECKER_STARTED then  
            _G.ItemEvents = ItemEvents()
            print("[WR] Callbacks | Item Events Loaded.")
        end
        insert(ItemEvents.BuyItemCallback, fn)
    end
    
    local function OnSellItem(fn)
        if not _ITEM_CHECKER_STARTED then  
            _G.ItemEvents = ItemEvents()
            print("[WR] Callbacks | Item Events Loaded.")
        end
        insert(ItemEvents.SellItemCallback, fn)
    end
    class "Prediction"

    function Prediction:VectorMovementCollision(startPoint1, endPoint1, v1, startPoint2, v2, delay)
        local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
        local d, e = eP1x-sP1x, eP1y-sP1y
        local dist, t1, t2 = sqrt(d*d+e*e), nil, nil
        local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
        local function GetCollisionPoint(t) return t and {x = sP1x+S*t, y = sP1y+K*t} or nil end
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
            local startT = timer - Latency()/2000
            local dashDist = GetDistance(startPos, endPos)
            local endT = startT + (dashDist/dashSpeed)
            --
            if endT >= timer and startPos and endPos then
                OnDash = true
                --
                local t1, p1, t2, p2, dist = self:VectorMovementCollision(startPos, endPos, dashSpeed, from, speed, (timer - startT) + delay)
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
        for i = 1, unit.buffCount do
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
                                return self:CalculateTargetPosition(unit, spell, calcPos)
                            end
                        end
                    end
                end
            end
            --
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
            return self:CalculateTargetPosition(unit, spell, calcPos)
        end
    end

    function Prediction:GetBestCastPosition(unit, spell)       
        local range = spell.Range and spell.Range - 15 or huge
        local radius = spell.Radius == 0 and 1 or (spell.Radius + unit.boundingRadius) - 4
        local speed = spell.Speed or huge
        local from = spell.From or myHero
        local delay = spell.Delay + (0.07 + Latency() / 2000)
        local collision = spell.Collision or false
        --
        local Position, CastPosition, HitChance = Vector(unit), Vector(unit), 0
        local TargetDashing, CanHitDashing, DashPosition = self:IsDashing(unit, spell)
        local TargetImmobile, ImmobilePos, ImmobileCastPosition = self:IsImmobile(unit, spell)

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
            Position, CastPosition = self:CalculateTargetPosition(unit, spell)

            if unit.activeSpell and unit.activeSpell.valid then
                HitChance = 2
            end

            if GetDistanceSqr(from.pos, CastPosition) < 250 then
                HitChance = 2
                local newSpell = {Range = range, Delay = delay * 0.5, Radius = radius, Width = radius, Speed = speed *2, From = from}
                Position, CastPosition = self:CalculateTargetPosition(unit, newSpell)
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

    print("[WR] Prediction Loaded")    class 'Ashe'  

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