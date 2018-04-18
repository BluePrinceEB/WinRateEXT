
	--[[
		wr_changelog.lua
		by Weedle
	--]]

	local script_data        = _G.script_data
    local isUpdated          = _G.isUpdated     
    local timeCheck          = _G.timeCheck 
    local core_version       = script_data.core_version
    local version            = script_data.version
    local logText            = script_data.changelog 

    local common_path        = COMMON_PATH 	
    local sprite_path        = SPRITE_PATH

    local wr_pref_data       = "wr_pref_data.lua"
    local wr_logo            = "MenuElement\\wr_logo_bw.png"
    local wr_logo_url        = "https://raw.githubusercontent.com/HiImWeedle/GoS/master/WinRate/Logo/wr_logo_bw.png"  
   
    if not FileExist(sprite_path..wr_logo) then 
    	DownloadFileAsync(wr_logo_url, sprite_path..wr_logo, function() end)
        repeat until FileExist(sprite_path..wr_logo)
    end

    local open               = io.open 
    local AddEvent           = Callback.Add
    local Timer              = Game.Timer 

    local Color              = Draw.Color
    local Line               = Draw.Line
    local Rect               = Draw.Rect
    local Text               = Draw.Text

    local default            = true 
    local log                = false 
    local box                = false 
    local stage              = 1 
    local bg_color           = Color(240, 15, 15, 15)    
    local res                = Game.Resolution()
    local xPoint             = res.x * 0.5 
    local yPoint             = res.y * 0.5 
    local box_x              = xPoint - 2
    local box_y              = 200
    local upper_box_y        = yPoint - box_y
    local lower_box_y        = yPoint + box_y
    local line1_x            = xPoint - 180 
    local line1_y            = yPoint - 160 
    local line2_x            = xPoint + 176 
    local line2_y            = yPoint - 160 

    local wr_sprite          = Sprite(wr_logo)
    local wr_width           = wr_sprite.width / 2
    local wr_height          = wr_sprite.height / 2
    local wr_x               = xPoint - wr_width
    local wr_y               = yPoint - wr_height

    local startTime          = Timer()
    local currentTime        = Timer()
    local endTime            = startTime + 1    
    local animationTime      = 1 
    local _dx, _dt           = 0, 0  

    local animationTimes     = {
    1, 
    0.5, 
    0.8,
    1.1, 
    0.5,
    0.3, 
    1, 
    0.5
    }    

    --WR--

    local function CreateFile()
    	local file = open(common_path..wr_pref_data, "w+")
    	file:write(tostring(default))
    	file:close()
    end

    local function LoadPreferences()
    	if not FileExist(common_path..wr_pref_data) then 
    		CreateFile()
    		return tostring(default)
    	end
    	local file = open(common_path..wr_pref_data, "r")
    	default = file:read("*all")
    	box = not default 
    	file:close()
    	return default
    end

    local function DrawRectOutline(x, y, width, height, thicc, color)
        local A = {x = x, y = y}
        local B = {x = x, y = y - height}
        local C = {x = x + width, y = y - height}
        local D = {x = x + width, y = y}
        Line(A.x, A.y, B.x, B.y, thicc, color)
        Line(B.x, B.y, C.x, C.y, thicc, color)
        Line(C.x, C.y, D.x, D.y, thicc, color)
        Line(D.x, D.y, A.x, A.y, thicc, color)
    end   

    local function SpriteAnimation(scale, xMove, yMove)
        if scale then 
            wr_sprite:SetScale(scale)
        end
        wr_width = wr_sprite.width / 2
        wr_height = wr_sprite.height / 2    
        wr_x, wr_y  = xPoint - wr_width + (xMove or 0), yPoint - wr_height + (yMove or 0)
        wr_sprite:Draw(wr_x, wr_y)
    end  

    --WR--       

    local function OnTick()
    	if log then 
    		currentTime = Timer()
    		endTime = startTime + animationTime
    		if currentTime >= endTime and (stage <= 5 or stage >= 7) then 
    			startTime = currentTime 
    			if stage == 8 then 
    				log = false 
    				return 
    			end
    			stage = stage + 1
    			animationTime = animationTimes[stage]
    		end
    		_dt = (currentTime - startTime) / animationTime 
    		_dx = _dt < 1 and _dt * (2 - _dt) or 1 
    	end
    end

	local function Stage2()
		local scale = 0.01 + 0.99 * _dx
		SpriteAnimation(scale)
	end

	local function Stage3()
		Line(box_x, yPoint, box_x, yPoint - 200 * _dx, 4, bg_color)
		Line(box_x, yPoint, box_x, yPoint + 200 * _dx, 4, bg_color)
        SpriteAnimation()
	end

	local function Stage4()
		Line(box_x, yPoint, box_x, upper_box_y, 900 * _dx, bg_color)
		Line(box_x, yPoint, box_x, lower_box_y, 900 * _dx, bg_color)
        SpriteAnimation()
	end

	local function Stage5()
		Line(box_x, yPoint, box_x, upper_box_y, 900, bg_color)
		Line(box_x, yPoint, box_x, lower_box_y, 900, bg_color) 

		Line(line1_x, line1_y, line1_x - 240 * _dx, line1_y, 4)
		Line(line2_x, line2_y, line2_x + 240 * _dx, line2_y, 4)

        local scale, xMove = 1 + (0.5*_dx), 300 * _dx
        SpriteAnimation(scale, xMove)
	end

	local function Stage6()
 		local white = Color(237 * _dx, 255, 255, 255)
        local grey = Color(200 * _dx, 20, 20, 20) 

        Line(box_x, yPoint, box_x, upper_box_y, 900, bg_color)
		Line(box_x, yPoint, box_x, lower_box_y, 900, bg_color)  
		Line(line1_x, line1_y, line1_x - 240, line1_y, 4)
        Line(line2_x, line2_y, line2_x + 240, line2_y, 4) 
        SpriteAnimation(1.5, 300)

      	Text("PROJECT WINRATE", 40, xPoint - 150, yPoint - 180, white)
      	Text(logText, 20, xPoint - 420, yPoint - 130, white)

        DrawRectOutline(xPoint - 420, yPoint + 180, 16, 16, white)    
        Text("Dont show this again", 12, xPoint - 398, yPoint + 165, white)

        Text("version: "..version.."\ncore_version: "..core_version, 12, xPoint + 323, yPoint + 156, white)

      	if box then 
      	    Rect(xPoint - 420, yPoint + 164, 16, 16, white)
        else
            Rect(xPoint - 420, yPoint + 164, 16, 16, grey)
        end
        
        DrawRectOutline(xPoint - 35, yPoint + 188, 70, 35, Color(200 * _dx, 255, 255, 255)) 
        Rect(xPoint - 35, yPoint + 154, 70, 34, grey)
        Text("OK", 22, xPoint - 12, yPoint + 160, white)           
	end

	local function Stage7()
 		local very_white = Color(255 - 255 * _dx, 255, 255, 255)
        local white = Color(237 - 237 * _dx, 255, 255, 255)
        local grey = Color(200 - 200 * _dx, 20, 20, 20)    
        bg_color = Color(240 - 240 * _dx, 15, 15, 15)

        Line(box_x, yPoint, box_x, upper_box_y, 900 - 900 * _dx, bg_color)
        Line(box_x, yPoint, box_x, lower_box_y, 900 - 900 * _dx, bg_color)
        Line(line1_x, line1_y, line1_x - (240 - 240 * _dx), line1_y, 4, very_white)
        Line(line2_x, line2_y, line2_x + (240 - 240 * _dx), line2_y, 4, very_white) 

        local scale, translation = 1 + (0.5 - 0.5 * _dx), 300 - 300 * _dx                             
        SpriteAnimation(scale, translation)

        Text("PROJECT WINRATE", 40, xPoint - 150, yPoint - 180, white)
        local _dx2 = _dx * 6 < 1 and _dx * 6 or 1 
        Text(logText, 20, xPoint - 420, yPoint - 130, Color(237 - 237 * _dx2, 255, 255, 255))    

        DrawRectOutline(xPoint - 420, yPoint + 180, 16, 16, white)    
        Text("Dont show this again", 12, xPoint - 398, yPoint + 165, white)  

        Text("version: "..version.."\ncore_version: "..core_version, 12, xPoint + 323, yPoint + 156, white)

        if box then 
            Rect(xPoint - 420, yPoint + 164, 16, 16, white)
        else
            Rect(xPoint - 420, yPoint + 164, 16, 16, grey)
        end                  

        DrawRectOutline(xPoint - 35, yPoint + 188, 70, 35, Color(200 - 200 *_dx, 255, 255, 255)) 
        Rect(xPoint - 35, yPoint + 154, 70, 34, grey)
        Text("OK", 22, xPoint - 12, yPoint + 160, white)       
	end

	local function Stage8()
		local scale = 1 - 0.99 * _dx 
		SpriteAnimation(scale)
	end

    --WR--

    local function OnDraw()
    	if log then 
    		if stage == 2 then Stage2() 
    		elseif stage == 3 then Stage3() 
    		elseif stage == 4 then Stage4() 
    		elseif stage == 5 then Stage5()
    		elseif stage == 6 then Stage6() 
    		elseif stage == 7 then Stage7() 
    		elseif stage == 8 then Stage8()
    		end
    	end
    end

    local function WndMsg(msg, wParam)
    	if log and stage == 6 and msg == 513 and wParam == 0 then 
    		local pos = cursorPos 
    		local xPos, yPos = pos.x, pos.y 
   			if xPos >= xPoint - 420 and xPos <= xPoint - 404 and yPos >= yPoint + 166 and yPos <= yPoint + 180 then
                box = not box
                default = not default 
                CreateFile()
            elseif xPos >= xPoint - 35 and xPos <= xPoint + 35 and yPos >= yPoint + 154 and yPos <= yPoint + 189 then 
                stage = 7
                startTime = Timer()
                _dx = 0
            end 		
        end
    end

    local function ChangeLog()
    	if (LoadPreferences() == "true" and timeCheck) or isUpdated then 
    		log = true 
    	end
    	if log then 
    		AddEvent("Tick", function() OnTick() end)
    		AddEvent("Draw", function() OnDraw() end)
    		AddEvent("WndMsg", function(msg, wParam) WndMsg(msg, wParam) end)
    	end
    end

    ChangeLog()

