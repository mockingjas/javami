MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local timer = require("timer")
local Gesture = require("lib_gesture")
local scene = storyboard.newScene()

------- Global variables ---------
local screenGroup
-- 1 up, 2 down, 3 right, 4 left, 5 cw, 6 ccw, 7 shake
local instructionSet = display.newGroup()
local rand, maxSeq, maxSprite
local instructionOrder = ""
local spriteOrder = ""
local instruction
local curr = 0 -- kung ilan na yung nasagot

local incorrectSound = audio.loadSound("incorrect.mp3")
local correctSound = audio.loadSound("correct.mp3")

--------- FUNCTIONS FOR STRING MANIPULATIONS ------------
function replace_char (pos, str, ch)
	if (pos == 1) then return ch .. str:sub(pos+1)
	elseif (pos == str:len()) then return str:sub(1, str:len()-1) .. ch
	else return str:sub(1, pos-1) .. ch .. str:sub(pos+1)
	end
end

function swap_char (pos1, pos2, str)
	local temp1 = get_char(pos1, str)
	local temp2 = get_char(pos2, str)
	str = replace_char(pos1, str, temp2)
	str = replace_char(pos2, str, temp1)
	return str
end

function get_char (pos, str)
	return str:sub(pos, pos)
end
---------------------------------------------------------

--------- FUNCTIONS FOR SWIPING ------------

local answer = ""
local answer2 = "" -- temp lang kasi di pa ok yung circle

local beginX = 0
local beginY = 0
local endX = 0
local endY = 0
 
local xDistance  
local yDistance
	
function checkDirection()
    -- 1 up, 2 down, 3 right, 4 left, 5 shake
    xDistance =  math.abs(endX - beginX) -- math.abs will return the absolute, or non-negative value, of a given value. 
    yDistance =  math.abs(endY - beginY)

    if xDistance > yDistance then -- SWIPE LEFT OR RIGHT
    	
        if beginX > endX then
                print("swipe left")
                answer = answer .. "4"
                answer2 = answer2 .. "4"
				curr = curr + 1
        else 
                print("swipe right")
                answer = answer .. "3"
                answer2 = answer2 .. "3"
				curr = curr + 1
        end
    else 
        if beginY > endY then -- SWIPE UP OR DOWN
                print("swipe up")
                answer = answer .. "1"
                answer2 = answer2 .. "1"
				curr = curr + 1
        else 
                print("swipe down")
                answer = answer .. "2"
                answer2 = answer2 .. "2"
				curr = curr + 1
        end
    end
    
end

function gestures(event)

	if event.isShake then
		print("shake")
		answer = answer .. "5"
		answer2 = answer2 .. "5"
		curr = curr + 1
		if( #answer ~= #instructionOrder ) then
        	print("ANSWER: " .. answer)
        	print("ANSWER2: " .. answer2)
        	print("CURR: " .. curr)
        	if( get_char(curr, answer) ~= get_char(curr, instructionOrder) and get_char(curr, answer2) ~= get_char(curr, instructionOrder) ) then
        		print("wrong!")
        		curr = 0
        		answer = ""
        		answer2 = ""
        		audio.play(incorrectSound)
        	end
        elseif (answer == instructionOrder or answer2 == instructionOrder) then
        	print("ANSWER: " .. answer)
        	print("ANSWER2: " .. answer2)
        	print("CURR: " .. curr)
        	print("correct!")
        	audio.play(correctSound)

        end
	end

    if event.phase == "began" then

        beginX = event.x
        beginY = event.y
    end
    
    if event.phase == "ended"  then
        endX = event.x
        endY = event.y
        checkDirection();

        if( #answer ~= #instructionOrder ) then
        	print("ANSWER: " .. answer)
        	print("ANSWER2: " .. answer2)
        	print("CURR: " .. curr)
        	if( get_char(curr, answer) ~= get_char(curr, instructionOrder) and get_char(curr, answer2) ~= get_char(curr, instructionOrder) ) then
        		print("wrong!")
        		curr = 0
        		answer = ""
        		answer2 = ""
        		audio.play(incorrectSound)
        	end
        elseif (answer == instructionOrder or answer2 == instructionOrder) then
        	print("ANSWER: " .. answer)
        	print("ANSWER2: " .. answer2)
        	print("CURR: " .. curr)
        	print("correct!")
        	audio.play(correctSound)

        end

    end
end

--------------------------------------------

function _destroyDialog()
	
end

function scene:createScene(event)
	
	screenGroup = self.view
	-- 1 up, 2 down, 3 right, 4 left, 5 cw, 6 ccw, 7 shake
	local x, y

	category = event.params.categ
	if category == 'easy' then
		maxTime = 60
		maxSeq = 3
		maxSprite = 3
		x = 175
		y = 280
		--3 in a sequence
		--3 sprites

	elseif category == 'medium' then
		maxTime = 120
		maxSeq = 5
		maxSprite = 4
		x = 110
		y = 280
		--5 in a sequence
		--4 sprites

	elseif category == 'hard' then
		maxTime = 180
		maxSeq = 7
		maxSprite = 5
		x = 45
		y = 280
		--7 in a sequence
		--5 sprites
	end


	-- CHOOSE FROM SPRITES ONLY
	if (maxSprite < 5) then
		for i = 1, maxSprite do
			rand = math.random(5)
			while (spriteOrder:find(rand) ~= nil) do
				rand = math.random(5)
			end
			spriteOrder = spriteOrder .. rand
		end
	else
		spriteOrder = "12345"
	end

	-- SHUFFLE -------------
	for i = #spriteOrder, 2, -1 do -- backwards
		local r = math.random(i) -- select a random number between 1 and i
		spriteOrder = swap_char(i, r, spriteOrder) -- swap the randomly selected item to position i
	end  
	-- ---------------------

	print("sprites: " .. spriteOrder)

	--easy, tatlo lang rin
	instructionOrder = spriteOrder

	if (maxSprite ~= maxSeq) then --medium and hard, magdadagdag
		for i = #spriteOrder+1, maxSeq do
			rand = math.random(#spriteOrder)
			instructionOrder = instructionOrder .. get_char(rand, spriteOrder)
		end
		print("instructions: " .. instructionOrder)
	end

	-- SHUFFLE -------------
	for i = #instructionOrder, 2, -1 do -- backwards
		local r = math.random(i) -- select a random number between 1 and i
		instructionOrder = swap_char(i, r, instructionOrder) -- swap the randomly selected item to position i
	end 
	-- ---------------------
	print("shuffled ins: "..instructionOrder)

	for i = 1, #instructionOrder do
		instruction = display.newImage("images/thirdgame/white/" .. get_char(i, instructionOrder) .. ".png")
		instructionSet:insert(i, instruction)
		instruction.x = x
		instruction.y = y
		x = x + 65

	end

	screenGroup:insert(instructionSet)

	Runtime:addEventListener("touch", gestures)
	Runtime:addEventListener("accelerometer", gestures)

end


function scene:enterScene(event)
	
end

function scene:exitScene(event)
	
end

function scene:destroyScene(event)

end


scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene