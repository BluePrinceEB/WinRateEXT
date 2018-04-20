if _G.Prediction_Loaded then
	return
end

_G.Prediction_Loaded = true

require("MapPositionGOS")

local myHero = myHero
local LocalHuge = math.huge
local LocalSqrt = math.sqrt
local LocalMax = math.max
local LocalMin = math.min
local LocalAbs = math.abs
local LocalFloor = math.floor
local LocalCos = math.cos
local LocalSin = math.sin

local TYPE_TURRET = Obj_Ai_Turret

local LocalLatency = Game.Latency
local LocalGameTimer = Game.Timer
local LocalMinionCount = Game.MinionCount
local LocalMinion = Game.Minion
local LocalHeroCount = Game.HeroCount
local LocalHero = Game.Hero

local TYPE_HERO = myHero.type

local TEAM_ALLY = myHero.team
local TEAM_JUNGLE = 300
local TEAM_ENEMY = 300 - TEAM_ALLY

local LocalMapPosition = MapPosition
local LocalPoint = Point
local LocalLineSegment = LineSegment

local ENEMY_BASE = nil 
local ALLY_BASE = nil

TYPE_LINE = 1
TYPE_CIRCULAR = 2
TYPE_CONE = 3
TYPE_GENERIC = 4

local CCBuffs = {
	[5] = "Stun",
	[11] = "Snare",
	[24] = "Surppression",
	[39] = "KnockUp",
	[8] = "Taunt",
	[21] = "Fear",
	[22] = "Charm"
}

local ActiveMissing = {}
local ActiveRecalls = {}

local function OnLoseVision(unit)
	ActiveMissing[unit.networkID] = {timer = LocalGameTimer() - (LocalLatency() / 2000), pos = unit.pos, dir = unit.dir:Normalized()}
end

local VisionHandler = {}
Callback.Add("Tick", function()
	for i = 1, LocalHeroCount() do
		local h = LocalHero(i)
		local visible = h.visible
		if VisionHandler[h.networkID] == nil then
			VisionHandler[h.networkID] = visible
		end
		if visible == false and VisionHandler[h.networkID] then
			OnLoseVision(h)
		end
		VisionHandler[h.networkID] = visible
	end
end)

Callback.Add("Load", function()
	for i = 1, Game.ObjectCount() do
		local o = Game.Object(i)
		if o.type == Obj_AI_SpawnPoint then
			if o.team == TEAM_ENEMY then
				ENEMY_BASE = o.pos
			else
				ALLY_BASE = o.pos
			end
		end
	end
end)

Callback.Add("ProcessRecall", function(unit, recall)
	if unit.type == TYPE_HERO then
		if recall.isStart then
			ActiveRecalls[unit.networkID] = {startTime = LocalGameTimer() - (LocalLatency() / 2000), windUp = recall.totalTime / 1000}
		elseif recall.isFinish then
			ActiveRecalls[unit.networkID] = nil
			ActiveMissing[unit.networkID] = {timer = LocalGameTimer() - (LocalLatency() / 2000), pos = (unit.team == TEAM_ENEMY and ENEMY_BASE or ALLY_BASE), dir = Vector(0, 0 ,0)}
		end
	end
end)

local function GetCCBuffData(unit)
	local GameTimer = LocalGameTimer()
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 and GameTimer >= Buff.startTime and Buff.expireTime > GameTimer and CCBuffs[Buff.type] then
			return Buff
		end
	end
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

local function GetDistance(p1, p2)
	local dx, dz = p1.x - p2.x, p1.z - p2.z
	return LocalSqrt(dx * dx + dz * dz)
end

local function GetDistanceSqr(p1, p2)
	local dx, dz = p1.x - p2.x, p1.z - p2.z
	return dx * dx + dz * dz
end

local Prediction = {}
Prediction.__index = Prediction

function Prediction:SetSpell(spellData, spellType, useHitBoxPrediction)
	local data = {}
	setmetatable(data, Prediction)
	data.spellData = {}
	data.spellData.delay = spellData.delay or 0
	data.spellData.delay = data.spellData.delay + 0.07
	data.spellData.range = spellData.range or LocalHuge
	data.spellData.speed = spellData.speed or LocalHuge
	data.spellData.width = spellData.width or 1

	data.spellType = spellType or 4
	data.useHitBoxPrediction = useHitBoxPrediction
	return data
end

function Prediction:mCollision()
	local Count = 0
	for i = LocalMinionCount(), 1, -1 do
		local m = LocalMinion(i)
		if m ~= self.target and m.team ~= TEAM_ALLY and m.dead == false and m.isTargetable then
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(self.sourcePos, self.castPos, m.pos)
			local w = self.spellData.width + m.boundingRadius
			local pos = m.pos
			if isOnSegment and GetDistanceSqr(pointSegment, pos) < w * w and GetDistanceSqr(self.sourcePos, self.castPos) > GetDistanceSqr(self.sourcePos, pos) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function Prediction:hCollision()
	local Count = 0
	for i = LocalHeroCount(), 1, -1 do
		local m = LocalHero(i)
		if m ~= self.target and m.team == TEAM_ENEMY and m.dead == false and m.isTargetable then
			local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(self.sourcePos, self.castPos, m.pos)
			local w = self.spellData.width + m.boundingRadius
			local pos = m.pos
			if isOnSegment and GetDistanceSqr(pointSegment, pos) < w * w and GetDistanceSqr(self.sourcePos, self.castPos) > GetDistanceSqr(self.sourcePos, pos) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function Prediction:GetPrediction(unit, sourcePos)
	local Origin = unit.pos
	local Waypoint = unit.posTo
	if Waypoint.x == 0 or Waypoint.z == 0 then
		Waypoint = Origin
	end
	local Delay = self.spellData.delay + (LocalLatency() / 2000)
	local Range = self.spellData.range
	local Width = self.spellData.width
	local Speed = self.spellData.speed
	local sourcePos = sourcePos or myHero.pos
	local skillshotType = self.skillshotType
	if skillshotType == TYPE_CIRCULAR then
		Range = Range + Width
	end
	local useHitBoxPrediction = self.useHitBoxPrediction
	
	local velocity = unit.ms
	local Direction = unit.dir
	local WPDirection = (Waypoint - Origin):Normalized()
	local dx, dz = Origin.x - sourcePos.x, Origin.z - sourcePos.z
	local Distance = LocalSqrt((dx * dx) + (dz * dz))
	local boundingRadius = unit.boundingRadius
	if skillshotType == 1 or skillshotType == 3 then
		Distance = (Distance + boundingRadius) - myHero.boundingRadius
	end
	local WPDistance = GetDistance(Origin, Waypoint)
	local vx, vz = (dx / WPDistance) * velocity, (dz / WPDistance) * velocity

	local TimeToHit = Delay
	
	if Speed < LocalHuge then
		if Origin ~= Waypoint then
			local a = (vx * vx) + (vz * vz) - (Speed * Speed)
			local b = 2 * (vx * (Origin.x - sourcePos.x) + vz * (Origin.z - sourcePos.z))
			local c = (Origin.x * Origin.x) + (Origin.z * Origin.z) + (sourcePos.x * sourcePos.x) + (sourcePos.z * sourcePos.z) - (2 * sourcePos.x * Origin.x) - (2 * sourcePos.z * Origin.z)
			local d = b * b - (4 * a * c)
			local t = 0
			if d >= 0 then
				d = LocalSqrt(d)
				local t1 = (-b + d) / (2 * a)
				local t2 = (-b - d) / (2 * a)
				t = LocalMin(t1, t2)
				if t < 0 then
					t = LocalMax(t1, t2)
				end
			end
			TimeToHit = TimeToHit + t
		else
			TimeToHit = TimeToHit + (Distance / Speed)
		end
	end
	
	local MaxWalkDistance = (TimeToHit * unit.ms)
	local WalkDistance = MaxWalkDistance
	if MaxWalkDistance > WPDistance then
		WalkDistance = WPDistance
	end
	if useHitBoxPrediction then
		WalkDistance = LocalMax((MaxWalkDistance + 4) - ((boundingRadius + Width) * 0.5), 0)
	end
	local GameTimer = LocalGameTimer()
	local CastPos = Origin
	local TrueWidth = Width + boundingRadius
	
	local mod = 0.5
	if unit.type == TYPE_HERO then
		local Buff = GetCCBuffData(unit)
		if Buff then
			mod = mod + Buff.expireTime - GameTimer
			CastPos = Waypoint == Origin and Origin or Origin + WPDirection * WalkDistance
		else
			local ActiveSpell = unit.activeSpell
			if ActiveSpell.valid then
				if ActiveSpell.spellWasCast == false then
					mod = mod + (ActiveSpell.castEndTime - GameTimer)
				elseif ActiveSpell.isChanneling then
					mod = mod + (ActiveSpell.endTime - GameTimer)
				end
			end
		end
		if unit.visible == false then
			mod = 0
		end
	end
	if Origin ~= Waypoint then
		local line = LocalLineSegment(LocalPoint(Origin), LocalPoint(Waypoint))
		if LocalMapPosition:intersectsWall(line) then
			CastPos = Origin + Direction * WalkDistance
		else
			CastPos = Origin + WPDirection * WalkDistance
		end
	end
	
	self.target = unit
	self.castPos = CastPos
	self.sourcePos = sourcePos
	self.hitChance = GetDistanceSqr(sourcePos, CastPos) > Range * Range and 0 or LocalMin(LocalMax((TrueWidth / (WalkDistance == 0 and MaxWalkDistance or WalkDistance)) * mod, 0), 1)
	return self
end

_G.Prediction = Prediction