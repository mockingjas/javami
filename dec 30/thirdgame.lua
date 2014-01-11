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
--for backend
local rand, dimensions, order, current
local obj, objectGroup, correctObj

------- Load sounds ---------
local incorrectSound = audio.loadSound("music/incorrect.mp3")
local correctSound = audio.loadSound("music/correct.mp3")

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

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	if(event.phase == "ended") then
		gameovergroup.isVisible = false
  		storyboard.removeScene("thirdgame")
  		storyboard.removeScene("mainmenu")

  		mainMusic = audio.loadSound("music/MainSong.mp3")
		backgroundMusicChannel = audio.play( mainMusic, { loops=-1}  )

		option =	{
			effect = "fade",
			time = 100,
			params = {
				music = backgroundMusicChannel
			}
		}
		storyboard.gotoScene("mainmenu", option)
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

		round= display.newText("ROUND: "..category, 0, 0, font, 15)
		round.x = 150
		round.y = display.contentCenterY - 100
		gameovergroup:insert(round)

		score= display.newText("SCORE: "..currScore, 0, 0, font, 15)
		score.x = 300
		score.y = display.contentCenterY - 100
		gameovergroup:insert(score)


    	local playBtn = display.newImage( "images/firstgame/playagain_button.png")
	    playBtn.x = 130
	    playBtn.y = display.contentCenterY - 60
	    playBtn:addEventListener("touch", restart_onBtnRelease)
	    gameovergroup:insert(playBtn)

	    local playtext = display.newText("PLAY AGAIN", 165, display.contentCenterY - 70, font, 25) 
	    gameovergroup:insert(playtext)

	    local homeBtn = display.newImage( "images/firstgame/home_button.png")
	    homeBtn.x = 130
	    homeBtn.y = display.contentCenterY
	    homeBtn:addEventListener("touch", home)
	    gameovergroup:insert(homeBtn)

	    local hometext = display.newText("BACK TO MENU", 165, display.contentCenterY - 10, font, 25) 
	    gameovergroup:insert(hometext)

	    local emailBtn = display.newImage( "images/firstgame/email_button.png")
	    emailBtn.x = 130
	    emailBtn.y = display.contentCenterY + 60
	    --email:addEventListener("touch", home)
	    gameovergroup:insert(emailBtn)
	    local emailtext = display.newText("EMAIL RESULTS", 165, display.contentCenterY + 50, font, 25) 
	    gameovergroup:insert(emailtext)

	 end
end

--------------- FUNCTION FOR END OF GAME ----------------
function gameoverdialog()

	timerText:removeSelf()
	timer = nil

	scoreToDisplay.isVisible = false
	pauseBtn.isVisible = false
	objectGroup:removeSelf()

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
		print("RESTART~~~~~~~~~~~~~~~~~~~~")
	if (timer ~= nil) then
		pausegroup:removeSelf()
		timerText:removeSelf()
		timer = nil
	end
	if category == "easy" then
		
	elseif category == "medium" then
		
	elseif category == "hard" then
		
	end
	option = {
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
	objectGroup:removeSelf()
	timer = nil
	storyboard.removeScene("thirdgame")
	storyboard.removeScene("mainmenu")


	mainMusic = audio.loadSound("music/MainSong.mp3")
	backgroundMusicChannel = audio.play( mainMusic, { loops=-1}  )

	option =	{
		effect = "fade",
		time = 100,
		params = {
			music = backgroundMusicChannel
		}
	}
	storyboard.gotoScene("mainmenu", option)
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

------------------CREATE SCENE: MAIN -----------------------------
function scene:createScene(event)
	--get passed parameters from previous scene

	category = event.params.categ
	currScore = event.params.score
	currTime = event.params.time

	screenGroup = self.view

	if category == 'easy' then
		dimensions = 2
	elseif category == 'medium' then
		dimensions = 3
	elseif category == 'hard' then
		dimensions = 4
	end

	-- Start timer
	timer = stopwatch.new(currTime)

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

	-- GAME
	objectGroup = display.newGroup()

	order = ""

	rand = math.random(10)
	if category == 'easy' then
		x = display.viewableContentWidth/2 - 40
		y = display.viewableContentHeight/2 - 40
	elseif category == 'medium' then
		x = display.viewableContentWidth/2 - 60 
		y = display.viewableContentHeight/2 - 50
	elseif category == 'hard' then
		x = display.viewableContentWidth/2 - 100
		y = display.viewableContentHeight/2 - 110
	end

	for i = 1, dimensions * dimensions do
		
		if (i % dimensions == 1 and i > 1) then
			if category == 'easy' then
				x = display.viewableContentWidth/2 - 40
				y = y + 60
			elseif category == 'medium' then
				x = display.viewableContentWidth/2 - 60 
				y = y + 60
			elseif category == 'hard' then
				x = display.viewableContentWidth/2 - 100
				y = y + 60
			end
		elseif (i % dimensions ~= 1) then
			x = x + 60
		end

		if (rand > 5) then
			--circles
			--x y radius
			obj = display.newCircle(x, y, 25)
		else
			--squares
			obj = display.newRect(x, y, 50, 50)
		end

		objectGroup:insert(i, obj)
		obj:setFillColor(x,x,x)
		obj.isVisible = false
	end

	-- SHUFFLE -------------
	-- 97 == a
	order = ""
	for i = 1, dimensions * dimensions do
		order = order .. string.char(96+i)
	end
	print("JSHGSJHGJLASDGJKSD " .. order)
	for i = order:len(), 2, -1 do -- backwards
		local r = math.random(i) -- select a random number between 1 and i
		order = swap_char(i, r, order) -- swap the randomly selected item to position i
	end 
	print("JSHGSJHGJLASDGJKSD " .. order)
	-- ---------------------

	current = 1

	correctObj = objectGroup[string.byte(order,current) % 96]
	correctObj.isVisible = true
	correctObj.alpha = 0
	transition.to(correctObj, {time=3000, alpha=1})
	correctObj:addEventListener("tap", checkanswer)

end

function  checkanswer(event)
	local t = event.target
	if (t == correctObj) then
		print("CORRECT!")
		for i = 1, current do
			obj = objectGroup[string.byte(order,i) % 96]
			obj.isVisible = false
			obj:removeEventListener("tap", checkanswer)
		end

		print("check answer current " .. current)
		if (current < dimensions * dimensions) then
			showNext()
		else
			boolFirst = false
			print("NEXT!")
			currScore = currScore + 1
			option = {
				time = 400,
				params = {
					categ = category,
					first = boolFirst,
					time = currTime - timer:getElapsedSeconds(),
					score = currScore,
				}
			}

			timerText:removeSelf()
			timer = nil
			storyboard.removeScene("reloadthird")
			storyboard.gotoScene("reloadthird", option)
		end
	else
		print("WRONG!")
	end
end

function showNext()
	for i = 1, current do
		print("loopy " .. i)
		obj = objectGroup[string.byte(order,i) % 96]
		obj.isVisible = true
		obj.alpha = 0
		transition.to(obj, {time=3000, alpha=1})
		obj:addEventListener("tap", checkanswer)
	end
	current = current + 1
	print("current " .. current)
	correctObj = objectGroup[string.byte(order,current) % 96]
	correctObj.isVisible = true
	correctObj.alpha = 0
	transition.to(correctObj, {time=3000, alpha=1})
	correctObj:addEventListener("tap", checkanswer)
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