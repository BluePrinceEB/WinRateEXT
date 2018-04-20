
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

    