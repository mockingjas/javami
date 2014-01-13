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
local gameovergroup, round, score, gameover
--for backend
local rand, dimensions, order, current
local obj, objectGroup, correctObj

------- Load sounds ---------
local incorrectSound = audio.loadSound("music/incorrect.mp3")
local correctSound = audio.loadSound("music/correct.mp3")
local thirdGameMusic = audio.loadSound("music/ThirdGame.mp3")
local game3MusicChannel
local muted = 0

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


--------------- TIMER: RUNTIME FUNCTION --------------------
timerText = display.newText("", 480, 5, font, 18) 
timerText:setTextColor(0,0,0)
local function onFrame(event)
	if (timer ~= nil) then
   		timerText.text = timer:toRemainingString()
   		local done = timer:isElapsed()
 		local secs = timer:getElapsedSeconds()
-- 		print("done:" .. secs)

   		if(done) then
   			Runtime:removeEventListener("enterFrame", onFrame)
   			objectGroup:removeSelf()
	    	gameoverdialog()
		end
	end  

end

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	if(event.phase == "ended") then
		gameovergroup.isVisible = false
		gameover.isVisible = false
		scoreToDisplay.isVisible = false
		timerText.isVisible =false
  		storyboard.removeScene("thirdgame")
  		storyboard.removeScene("mainmenu")

  		audio.stop()
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

---------------- UNMUTE GAME ---------------------------
function unmuteGame(event)
	audio.resume(game3MusicChannel)
	unmuteBtn.isVisible = false
	muteBtn.isVisible = true
	muted = 0
end

---------------- MUTE GAME ---------------------------
function muteGame(event)
	audio.pause(game3MusicChannel)
	muteBtn.isVisible = false
	unmuteBtn.isVisible = true
	muted = 1
end

------------------------ FINAL MENU --------------------------------

local function finalmenu()
--    print(event.phase)
   		
	gameovergroup = display.newGroup()

	local playBtn = display.newImage( "images/firstgame/playagain_button.png")
    playBtn.x = 140
    playBtn.y = display.contentCenterY + 30
    playBtn:addEventListener("touch", restart_onBtnRelease)
    gameovergroup:insert(playBtn)

    local playtext = display.newText(" PLAY\nAGAIN", 118, display.contentCenterY + 60, font, 15) 
    playtext:setTextColor(0,0,0)
    gameovergroup:insert(playtext)

    local homeBtn = display.newImage( "images/firstgame/home_button.png")
    homeBtn.x = 240
    homeBtn.y = display.contentCenterY + 30
   	homeBtn:addEventListener("touch", home)
    gameovergroup:insert(homeBtn)

    local hometext = display.newText("BACK TO\n  MENU", 205, display.contentCenterY + 60, font, 15) 
    hometext:setTextColor(0,0,0)
    gameovergroup:insert(hometext)

    local emailBtn = display.newImage( "images/firstgame/email_button.png")
    emailBtn.x = 340
    emailBtn.y = display.contentCenterY + 30
    --email:addEventListener("touch", home)
    gameovergroup:insert(emailBtn)
    
    local emailtext = display.newText(" EMAIL\nRESULTS", 310, display.contentCenterY + 60, font, 15) 
    emailtext:setTextColor(0,0,0)
    gameovergroup:insert(emailtext)

end
------------------- GAME OVER ---------------------------

function moveBG(self,event)
	--print(self.x)
	if(self.x == 241) then
		Runtime:removeEventListener("enterFrame", gameover)
		finalmenu()
		timer = nil
	else
		self.x = self.x - (self.speed)
	end
end

function gameoverdialog()

	pauseBtn.isVisible = false
	unmuteBtn.isVisible = false
	muteBtn.isVisible = false

	gameover= display.newImage( "images/thirdgame/gameover.png" )
	gameover.x = 700
	gameover.y =  display.contentHeight/2 - 10;
	gameover.speed = 3

	gameover.enterFrame = moveBG
    Runtime:addEventListener("enterFrame", gameover)

end


---------------- PAUSE GAME ---------------------------
function pauseGame(event)
    if(event.phase == "ended") then
    	timer:pause()
        pauseBtn.isVisible = false
        audio.pause(game3MusicChannel)
        showpauseDialog()
        return true
    end
end
 
 --------------- RESTART GAME ----------------------
function restart_onBtnRelease()
	if (timer ~= nil) then
		objectGroup:removeSelf()
		pausegroup:removeSelf()
		timerText:removeSelf()
		timer = nil
	else
		gameovergroup.isVisible = false
		gameover.isVisible = false
		scoreToDisplay.isVisible = false
		timerText:removeSelf()
	end
	if category == "easy" then
		currTime = 61
	elseif category == "medium" then
		currTime = 121
	elseif category == "hard" then
		currTime = 181
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
	audio.stop(game3MusicChannel)
	storyboard.removeScene("reloadthird")
	storyboard.gotoScene("reloadthird", option)
end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
	if (muted == 0) then 
		audio.resume(game2MusicChannel)
	end
	pausegroup:removeSelf()
	timer:resume()
    pauseBtn.isVisible = true
	return true
end

---------------- EXIT FROM PAUSE ----------------
function exit_onBtnRelease()
	objectGroup:removeSelf()
	pausegroup:removeSelf()
	timerText:removeSelf()
	timer = nil
	Runtime:removeEventListener("touch", gestures)
	Runtime:removeEventListener("accelerometer", gestures)
	storyboard.removeScene("thirdgame")
	storyboard.removeScene("mainmenu")

	audio.stop()
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
	muted = 0
	--get passed parameters from previous scene
	category = event.params.categ
	currScore = event.params.score
	currTime = event.params.time
	boolFirst = event.params.first

	-- Start timer
	timer = stopwatch.new(currTime)
	screenGroup = self.view

	if category == 'easy' then
		dimensions = 2
	elseif category == 'medium' then
		dimensions = 3
	elseif category == 'hard' then
		dimensions = 4
	end

	if(boolFirst) then
		game3MusicChannel = audio.play( thirdGameMusic, { loops=-1}  )
	else
		game3MusicChannel = event.params.music
	end
 
	-- Screen Elements

	--bg
	width = 550; height = 320;

	bg = display.newImageRect("images/thirdgame/game3bg.png", width, height)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	rect = display.newRect( 0, 0, 570, 50)
	rect:setFillColor( 75, 75, 755, 100 )
	rect.x = display.contentWidth/2;
	rect.y = 10
	screenGroup:insert(rect)

	rect2 = display.newRect( 0, 0, 570, 20)
	rect2:setFillColor( 75, 75, 755, 100 )
	rect2.x = display.contentWidth/2;
	rect2.y = 320
	screenGroup:insert(rect2)

	--score
	scoreToDisplay = display.newText("Score: "..currScore, -30, 5, font, 18 )	
	scoreToDisplay:setTextColor(0,0,0)
	screenGroup:insert(scoreToDisplay)



	--pause button
	pauseBtn = display.newImageRect( "images/secondgame/pause.png", 20, 20)
    pauseBtn.x = 445
    pauseBtn.y = 15
    pauseBtn:addEventListener("touch", pauseGame)
    pauseBtn:addEventListener("tap", pauseGame)
    screenGroup:insert( pauseBtn )

     --mute button
    unmuteBtn = display.newImageRect( "images/secondgame/mute_button.png", 20, 20)
    unmuteBtn.x = 420
    unmuteBtn.y = 15
    unmuteBtn:addEventListener("touch", unmuteGame)
    unmuteBtn:addEventListener("tap", unmuteGame)
    screenGroup:insert( unmuteBtn )
    unmuteBtn.isVisible = false


    --mute button
	muteBtn = display.newImageRect( "images/secondgame/unmute_button.png", 20, 20)
    muteBtn.x = 420
    muteBtn.y = 15
    muteBtn:addEventListener("touch", muteGame)
    muteBtn:addEventListener("tap", muteGame)
    screenGroup:insert( muteBtn )


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