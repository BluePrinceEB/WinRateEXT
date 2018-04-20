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
