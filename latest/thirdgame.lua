------- Requirements ---------
MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local timer = require("timer")
local physics = require("physics")
local lfs = require("lfs")
local stopwatch =require "stopwatch"
local scene = storyboard.newScene()

------- Global variables ---------
--for the blackboard
local screenGroup
--for the timer and reloading
local timer, timerText
--for reloading params
local currTime, boolFirst, currScore, category, option
--for the pause screen
local pausegroup
--for the gameover screen
local gameovergroup, round, score

-- 1 up, 2 down, 3 right, 4 left, 5 shake
local instructionSet = display.newGroup()
local rand, maxSeq, maxSprite
local instructionOrder = ""
local spriteOrder = ""
local instruction
local curr = 0 -- kung ilan na yung nasagot

local answer = ""
local beginX, beginY, endX, endY = 0
local xDistance, yDistance

------- Load sounds ---------
local incorrectSound = audio.loadSound("incorrect.mp3")
local correctSound = audio.loadSound("correct.mp3")

------- Load font ---------
local font
if "Win" == system.getInfo( "platformName" ) then
    font = "Eraser"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "EraserRegular"
else
    -- Mac and iOS
    font = "Eraser-Regular"
end

--------- FUNCTIONS FOR STRING MANIPULATIONS ------------
-- position in str to be replaced with ch
function replace_char (pos, str, ch)
	if (pos == 1) then return ch .. str:sub(pos+1)
	elseif (pos == str:len()) then return str:sub(1, str:len()-1) .. ch
	else return str:sub(1, pos-1) .. ch .. str:sub(pos+1)
	end
end

function get_char (pos, str)
	return str:sub(pos, pos)
end

function swap_char (pos1, pos2, str)
	local temp1 = get_char(pos1, str)
	local temp2 = get_char(pos2, str)
	str = replace_char(pos1, str, temp2)
	str = replace_char(pos2, str, temp1)
	return str
end

--------- FUNCTIONS FOR SWIPING ------------

function checkDirection()
    -- 1 up, 2 down, 3 right, 4 left, 5 shake
    xDistance =  math.abs(endX - beginX) -- math.abs will return the absolute, or non-negative value, of a given value. 
    yDistance =  math.abs(endY - beginY)

    if xDistance > yDistance then -- SWIPE LEFT OR RIGHT
    	
        if beginX > endX then
                print("swipe left")
                answer = answer .. "4"
				curr = curr + 1
        else 
                print("swipe right")
                answer = answer .. "3"
				curr = curr + 1
        end
    else 
        if beginY > endY then -- SWIPE UP OR DOWN
                print("swipe up")
                answer = answer .. "1"
				curr = curr + 1
        else 
                print("swipe down")
                answer = answer .. "2"
				curr = curr + 1
        end
    end
    
end

function gestures(event)

	if event.isShake then
		print("shake")
		answer = answer .. "5"
		curr = curr + 1
		checkanswer()
	end

    if event.phase == "began" then

        beginX = event.x
        beginY = event.y
    end
    
    if event.phase == "ended"  then
        endX = event.x
        endY = event.y
        checkDirection();

        checkanswer()

    end
end

--------------------------------------------

------- FUNCTION FOR CHECKING ANSWER --------------
function checkanswer()
	-- check the word
	-- if right, add score and then,

	if( #answer ~= #instructionOrder ) then
    	print("ANSWER: " .. answer)
    	print("CURR: " .. curr)
    	if( get_char(curr, answer) ~= get_char(curr, instructionOrder) ) then
    		print("wrong!")
    		curr = 0
    		answer = ""
    		audio.play(incorrectSound)
    	end
    elseif (answer == instructionOrder) then
    	print("ANSWER: " .. answer)
    	print("CURR: " .. curr)
    	print("correct!")
    	audio.play(correctSound)

    end
end

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	if(event.phase == "ended") then
		gameovergroup.isVisible = false
  		storyboard.removeScene("firstgame")
  		storyboard.removeScene("mainmenu")
  		storyboard.gotoScene("mainmenu")
  		return true
  	end
end

--------- FUNCTION FOR GAME OVER SPRITE LISTENER ---------
local function spriteListener( event )
    print(event.phase)
    if (event.phase == "ended") then

    	score.isVisible = false
		round.isVisible = false
		gameovergroup = display.newGroup()

    	local playBtn = display.newImage( "images/firstgame/playagain_button.png")
	    playBtn.x = 130
	    playBtn.y = display.contentCenterY - 80
	    playBtn:addEventListener("touch", restart_onBtnRelease)
	    gameovergroup:insert(playBtn)

	    local playtext = display.newText("PLAY AGAIN", 165, display.contentCenterY - 85, font, 25) 
	    gameovergroup:insert(playtext)

	    local homeBtn = display.newImage( "images/firstgame/home_button.png")
	    homeBtn.x = 130
	    homeBtn.y = display.contentCenterY - 20
	    homeBtn:addEventListener("touch", home)
	    gameovergroup:insert(homeBtn)

	    local hometext = display.newText("BACK TO MENU", 165, display.contentCenterY - 25, font, 25) 
	    gameovergroup:insert(hometext)

	    local emailBtn = display.newImage( "images/firstgame/email_button.png")
	    emailBtn.x = 130
	    emailBtn.y = display.contentCenterY + 42
	    --email:addEventListener("touch", home)
	    gameovergroup:insert(emailBtn)
	    local emailtext = display.newText("EMAIL RESULTS", 165, display.contentCenterY + 37, font, 25) 
	    gameovergroup:insert(emailtext)

	    round= display.newText("ROUND: "..category, 0, 0, font, 20)
		round.x = display.contentCenterX
		round.y = display.contentCenterY + 85

		score= display.newText("SCORE: "..currScore, 0, 0, font, 20)
		score.x = display.contentCenterX
		score.y = display.contentCenterY + 110

	 end
end

--------------- FUNCTION FOR END OF GAME ----------------
function gameoverdialog()

	timerText:removeSelf()
	timer = nil

	scoreToDisplay.isVisible = false
	pauseBtn.isVisible = false

	local sheet1 = graphics.newImageSheet( "images/trygameover.png", { width=414, height=74, numFrames=24 } )
	local instance1 = display.newSprite( sheet1, { name="gameover", start=1, count=24, time=4000, loopCount = 1} )
	instance1.x = display.contentCenterX
	instance1.y = display.contentCenterY - 20
	instance1:play()
	instance1:addEventListener( "sprite", spriteListener )
	screenGroup:insert(instance1)

	round= display.newText("ROUND: "..category, 0, 0, font, 20)
	round.x = display.contentCenterX
	round.y = display.contentCenterY + 25

	score= display.newText("SCORE: "..currScore, 0, 0, font, 20)
	score.x = display.contentCenterX
	score.y = display.contentCenterY + 45

end

--------------- TIMER: RUNTIME FUNCTION --------------------
timerText = display.newText("", 453, 25, font, 18) 
local function onFrame(event)
	if (timer ~= nil) then
   		timerText.text = timer:toRemainingString()
   		local done = timer:isElapsed()
 		local secs = timer:getElapsedSeconds()
-- 		print("done:" .. secs)

   		if(done) then
	   		Runtime:removeEventListener("enterFrame", onFrame)
	    	gameoverdialog()
		end
	end  

end
---------------- PAUSE GAME ---------------------------
function pauseGame(event)
    if(event.phase == "ended") then
    	timer:pause()
        pauseBtn.isVisible = false
        showpauseDialog()
        return true
    end
end
 
 --------------- RESTART GAME ----------------------
function restart_onBtnRelease()
	if (timer ~= nil) then
		pausegroup:removeSelf()
		timerText:removeSelf()
		timer = nil
	else
		gameovergroup.isVisible = false
	end
	if category == "easy" then
		currTime = 61
	elseif category == "medium" then
		currTime = 121
	elseif category == "hard" then
		currTime = 181
	end
	option =	{
		effect = "fade",
		time = 100,
		params = {
			categ = category,
			first = true,
			time = currTime,
			score = 0
		}
	}
	storyboard.removeScene("reloadthird")
	storyboard.gotoScene("reloadthird", option)
end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
	pausegroup:removeSelf()
	timer:resume()
    pauseBtn.isVisible = true
	return true
end

---------------- EXIT FROM PAUSE ----------------
function exit_onBtnRelease()
	pausegroup:removeSelf()
	timerText:removeSelf()
	timer = nil
	storyboard.removeScene("thirdgame")
	storyboard.removeScene("mainmenu")
	storyboard.gotoScene("mainmenu")
end

----------------- PAUSE DIALOG ------------------
function showpauseDialog()

	pausegroup = display.newGroup()
	local pausedialog = display.newImage("images/pause/pause_modal.png")
 	pausedialog.x = display.contentWidth/2;
 	pausedialog:addEventListener("touch", function() return true end)
	pausedialog:addEventListener("tap", function() return true end)
	pausegroup:insert(pausedialog)

	local resumeBtn = widget.newButton{
		defaultFile="images/pause/resume_button.png",
		overFile="images/pause/resume_button.png",
		onEvent = resume_onBtnRelease -- event listener function
	}
	resumeBtn:setReferencePoint( display.CenterReferencePoint )
	resumeBtn.x = bg.x - 100
	resumeBtn.y = 170
	pausegroup:insert(resumeBtn)

	local restartBtn = widget.newButton{
		defaultFile="images/pause/restart_button.png",
		overFile="images/pause/restart_button.png",
		onEvent = restart_onBtnRelease -- event listener function
	}
	restartBtn:setReferencePoint( display.CenterReferencePoint )
	restartBtn.x = bg.x + 100
	restartBtn.y = 170
	pausegroup:insert(restartBtn)

	local exitBtn = widget.newButton{
		defaultFile="images/pause/exit_button.png",
		overFile="images/pause/exit_button.png",
		onEvent = exit_onBtnRelease -- event listener function
	}
	exitBtn:setReferencePoint( display.CenterReferencePoint )
	exitBtn.x = bg.x + 5
	exitBtn.y = 220
	pausegroup:insert(exitBtn)
end

-- hint sound
local function networkListener( event )
	local speech = audio.loadSound( word..".mp3", system.TemporaryDirectory )
	if speech == nil then
		print("ERROR!")
--		errorMsg = display.newText("No internet connection found!", 250, 200, font, 10 )
	end
   	audio.play( speech )
end

function play()
	network.download( "http://www.translate.google.com/translate_tts?tl=en&q='"..word.."'", "GET", networkListener, word..".mp3", system.TemporaryDirectory )	
end


------------------CREATE SCENE: MAIN -----------------------------
function scene:createScene(event)
	--get passed parameters from previous scene
	category = event.params.categ
	currScore = 0
	currTime = event.params.time

	screenGroup = self.view

	if category == 'easy' then
		maxSeq = 3
		maxSprite = 3
		x = 175
		y = 280
		--3 in a sequence
		--3 sprites

	elseif category == 'medium' then
		maxSeq = 5
		maxSprite = 4
		x = 110
		y = 280
		--5 in a sequence
		--4 sprites

	elseif category == 'hard' then
		maxSeq = 7
		maxSprite = 5
		x = 45
		y = 280
		--7 in a sequence
		--5 sprites
	end

	-- Start timer
	timer = stopwatch.new(currTime)

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

	-----------------------------------------------------------------------------------------------

	-- Screen Elements
	--score
	scoreToDisplay = display.newText("Score: "..currScore, 0, 25, font, 18 )	
	
	--blackboard
	bg = display.newImageRect("images/firstgame/board.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	--pause button
	pauseBtn = display.newImageRect( "images/firstgame/pause.png", 20, 20)
    pauseBtn.x = 410
    pauseBtn.y = 37
    pauseBtn:addEventListener("touch", pauseGame)
    pauseBtn:addEventListener("tap", pauseGame)
    screenGroup:insert( pauseBtn )
	

	--- add to screen

	screenGroup:insert(scoreToDisplay)

	-----------------------------------------------------------------------------------------------

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
Runtime:addEventListener("enterFrame", onFrame)

return scene