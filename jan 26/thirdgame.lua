------- Requirements ---------
MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local timer = require("timer")
local physics = require("physics")
local lfs = require("lfs")
local stopwatch = require("stopwatch")
local toast2 = require("toast2")
local scene = storyboard.newScene()

------- Global variables ---------
--for the blackboard
local screenGroup
--for the timer and reloading
local timerr, timerText, blinker
--for reloading params
local currTime, boolFirst, currScore, category, option
--for the pause screen
local pausegroup
--for the gameover screen
local gameovergroup, round, score, gameover
--for backend
local rand, dimensions, order, current, answer
local obj, objectGroup
local r, g, b
--for analytics
local roundNumber, correctCtr, roundSpeed, pauseCtr, profileName

------- Load sounds ---------
local incorrectSound = audio.loadSound("music/incorrect.mp3")
local correctSound = audio.loadSound("music/correct.mp3")
local thirdGameMusic = audio.loadSound("music/ThirdGame.mp3")
local tempsound = audio.loadSound("music/3.mp3")
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


---------- DB FUNCTIONS ---------------------------------

--save score
function insertToDB(category, score, name, timestamp, pausectr)
	local query = [[INSERT INTO ThirdGame VALUES (NULL, ']] .. 
	category .. [[',']] ..
	score .. [[',']] ..
	name .. [[',']] ..
	timestamp .. [[',']] ..
	pausectr.. [[');]]
	db:exec(query)

	for row in db:nrows("SELECT id FROM ThirdGame") do
		id = row.id
	end
	return id
end

--save analytics
function insertAnalyticsToDB(gameid, roundid, roundscore, roundspeed)
	local query = [[INSERT INTO ThirdGameAnalytics VALUES (NULL, ']] .. 
	gameid .. [[',']] ..
	roundid .. [[',']] ..
	roundscore .. [[',']] ..
	roundspeed .. [[');]]
	db:exec(query)
end

---------------------------------------------------------

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
	if (timerr ~= nil) then
   		timerText.text = timerr:toRemainingString()
   		local done = timerr:isElapsed()
 		local secs = timerr:getElapsedSeconds()
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
		timerr = nil
	else
		self.x = self.x - (self.speed)
	end
end

function queryAndSaveToFile(id)
	local report = ""
	for row in db:nrows("SELECT * FROM ThirdGame ORDER BY id DESC") do
		report = report .. "GAME # " .. row.id .."\n\nPlayer: ".. row.name.."\nCategory : "..row.category.."\nTimestamp: "..row.timestamp.."\nFinal Score: "..row.score.."\nNumber of rounds: "..roundNumber
		--add longest time, shortest time, average time

		for row in db:nrows("SELECT * FROM ThirdGameAnalytics where gamenumber = '"..row.id.."'") do
			report = report .. "\n\nROUND "..row.roundnumber .. "\nRound time: "..row.speed.." second/s" .. "\nRound score: "..row.score
		end
		break
	end

	-- Save to file
	print(report)
	local path = system.pathForFile( "Game 3.txt", system.ResourceDirectory )
	local file = io.open( path, "w" )
	file:write( report )
	io.close( file )
	file = nil

	--Append
	report = report .. "\n----------------------------------\n"
	local path = system.pathForFile( "Game 3 Analytics.txt", system.ResourceDirectory )
	local file = io.open( path, "a" )
	file:write( report )
	io.close( file )
	file = nil
end

function gameoverdialog()

	-- ANALYTICS ----------------------
	local date = os.date( "*t" )
	local timeStamp = date.month .. "-" .. date.day .. "-" .. date.year .. " ; " .. date.hour .. ":" .. date.min
	--save to DB
	id = insertToDB(category, currScore, profileName, timeStamp, pauseCtr)

	--per round
	for i = 1, roundNumber do
		-- if last
		if tonumber(correctCtr[i]) > 0 and tonumber(roundSpeed[i]) == 0 then
			roundSpeed[i] = currTime - roundSpeed[i]
		end
		--save to db
		insertAnalyticsToDB(id, i, correctCtr[i], roundSpeed[i])
	end

	queryAndSaveToFile(id)
	-------------------

	objectGroup:removeSelf()
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
       	pauseCtr = pauseCtr + 1
    	timerr:pause()
    	timer.pause(blinker)
        pauseBtn.isVisible = false
        audio.pause(game3MusicChannel)
        showpauseDialog()
        return true
    end
end
 
 --------------- RESTART GAME ----------------------
function restart_onBtnRelease()
	if (timerr ~= nil) then
		objectGroup:removeSelf()
		pausegroup:removeSelf()
		timerText:removeSelf()
		timerr = nil
		timer.cancel(blinker)
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
	audio.stop()
	storyboard.removeScene("reloadthird")
	storyboard.gotoScene("reloadthird", option)
end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
	if (muted == 0) then 
		audio.resume(game2MusicChannel)
	end
	pausegroup:removeSelf()
	timerr:resume()
	timer.resume(blinker)
    pauseBtn.isVisible = true
	return true
end

---------------- EXIT FROM PAUSE ----------------
function exit_onBtnRelease()
	objectGroup:removeSelf()
	pausegroup:removeSelf()
	timerText:removeSelf()
	timerr = nil
	timer.cancel(blinker)
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

local function playBlink(event)
	print("--play seq")
		current = current + 1
		print("current " .. current)
		obj = objectGroup[string.byte(order,current) % 96]
		transition.to( obj, {time = 200, alpha = 0} )
		audio.play(tempsound)
		transition.to( obj, {delay = 200, time = 200, alpha = 1} )
	print("--end seq")
end

function shuffle(array)
	for i = 1, #array*2 do
		local a = math.random(#array)
		local b = math.random(#array)
		array[a], array[b] = array[b], array[a]
	end
	return array
end


------------------CREATE SCENE: MAIN -----------------------------
function scene:createScene(event)
	muted = 0
	profileName = "Cha" --temp
	--get passed parameters from previous scene
	category = event.params.categ
	currScore = event.params.score
	currTime = event.params.time
	boolFirst = event.params.first

	-- Start timerr
	timerr = stopwatch.new(currTime)
	screenGroup = self.view

	if category == 'easy' then
		dimensions = 2
	elseif category == 'medium' then
		dimensions = 3
	elseif category == 'hard' then
		dimensions = 4
	end

	correctCtr = {0}
	roundSpeed = {0}

	if(boolFirst) then
		game3MusicChannel = audio.play( thirdGameMusic, { loops=-1}  )
		roundNumber = 1
		correctCtr[1] = 0
		roundSpeed[1] = 0
		pauseCtr = 0
	else
		game3MusicChannel = event.params.music
		roundNumber = event.params.roundctr
		correctCtr = event.params.correctcount
		correctCtr[roundNumber] = 0
		roundSpeed = event.params.roundspeed
		roundSpeed[roundNumber] = 0
		pauseCtr = event.params.pausecount
	end

	print("\n\nROUND NUMBER " .. roundNumber)

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
	size = 0
	if category == 'easy' then
		c = 1
		size = 2
	elseif category == 'medium' then
		c = 3
		size = 1.5
	elseif category == 'hard' then
		c = 5
		size = 1
	end

	r = {255,	0,		200,	255,	128 }
	g = {0,		128,	50, 	128, 	0 }
	b = {128,	255,	50,		0,		128 }
	
	for i = 1, #b do
		print("b " .. i .. " " .. b[i])
	end

	color = {}
	colorStr = ""
	for i = 1, c do
		tempC = ""
		temp = math.random(5)
		tempC = tempC .. temp
		while (string.find(colorStr, temp) ~= nil) do
			tempC = ""
			temp = math.random(5)
			tempC = tempC .. temp	
		end
		colorStr = colorStr .. temp
		color[i] = temp
	end

	for i = 1, #color do
		print("COLOR: " .. color[i])
	end

	print("COLOR STR: " .. colorStr)
	
	for i = #color+1, dimensions * dimensions do
		a = math.random(#colorStr)
		color[i] = tonumber(get_char(a, colorStr))
	end

	print("   BEFORE COLOR ORDER: ")

	for i = 1, #color do
		print(color[i])
	end

	print("   AFTER COLOR ORDER: ")

	shuffle(color)

	for i = 1, #color do
		print(color[i])
	end

	rand = math.random(10)
	x = 0
	y = 0
	local z = 0
	for i = 1, dimensions * dimensions do
		if (i % dimensions ~= 1) then
			x = x + (60*size)
		elseif(i % dimensions == 1 and i > 1) then
			x = 0
			y = y + (60*size)
		end
		if (rand > 5) then
			--circles x y radius
			obj = display.newCircle(x, y, 25*size)
		else
			--squares
			obj = display.newRect(x, y, 50*size, 50*size)
		end

		obj.name = "" .. string.char(96+i)
		objectGroup:insert(i, obj)

		z = tonumber(color[i])
		obj:setFillColor(r[z],g[z],b[z])

		obj.isVisible = false
	end

	objectGroup:setReferencePoint(display.CenterReferencePoint)
	objectGroup.x = display.viewableContentWidth/2
	objectGroup.y = display.viewableContentHeight/2 + 10

	-- SHUFFLE -------------
	-- 97 == a
	order = ""
	for i = 1, dimensions * dimensions do
		order = order .. string.char(96+i)
	end

	for i = order:len(), 2, -1 do -- backwards
		local r = math.random(i) -- select a random number between 1 and i
		order = swap_char(i, r, order) -- swap the randomly selected item to position i
	end 
	print("ORDER: " .. order)
	-- ---------------------

	for i = 1, dimensions*dimensions do
		obj = objectGroup[string.byte(order,i) % 96]
		obj.isVisible = true
		obj.alpha = 1
		obj:addEventListener("tap", checkanswer)
		obj:addEventListener("touch", checkanswer)
	end

	answer = ""
	current = 0
	startSequence(1)

	screenGroup:insert(objectGroup)
end

function startSequence(last)
	current = 0
	for i = 1, last do
		blinker = timer.performWithDelay(i*1000, playBlink, 1)
	end
end

function checkanswer(event)
	local t = event.target
	if (event.phase == "ended") then
		print("ended " .. t.name)
		answer = answer .. t.name
		print(answer)
		if(string.find(order, answer) ~= nil) then
			a,b = string.find(order, answer)
			print(a .. b)

			if (a == 1 and b == current) then
				-- CORRECT YUNG BUONG PAGKAKASUNOD
				print("CORRECT!!!!")
				currScore = currScore + 1
				correctCtr[roundNumber] = correctCtr[roundNumber] + 1
				scoreToDisplay.text = "Score: "..currScore

				---------- HERE: HINDI NAGPPLAY BEFORE MAG RELOAD.
				audio.play(correctSound)
				--next!
				answer = ""
				-- print("CURRENT SA CHECKANSWER ".. current+1)
				if (current + 1 <= dimensions*dimensions) then
					startSequence(current+1)
				else
					reload()
				end
			elseif (a == 1 and b < current) then
				-- CORRECT PERO HINDI PA NIYA NACCOMPLETE YUNG CURRENT SEQUENCE
				-- PA-ADD NG TOAST NG CHECK MARK DUN SA SAME OBJECT NA TAMA YUNG NACLICK
				print("subround not yet done")
				audio.play(tempsound)
				currScore = currScore + 1
				correctCtr[roundNumber] = correctCtr[roundNumber] + 1
				scoreToDisplay.text = "Score: "..currScore
			end
		else
			---------- HERE: HINDI NAGPPLAY BEFORE MAG RELOAD.
			---------- ALSO, PAAYOS NG TOAST BEFORE MAG RELOAD.
			print("WRONG!!!!")
			audio.play(incorrectSound)
			toast2.new("images/wrong.png", 80, 10, 200)
			
			reload()
		end
	end
end

function reload()
	objectGroup:removeSelf()
	timerText:removeSelf()
	boolFirst = false
	roundSpeed[roundNumber] = timerr:getElapsedSeconds()
	roundNumber = roundNumber + 1
	option = {
		effect = "fade",
		time = 300,
		params = {
			categ = category,
			first = true,
			time = currTime - timerr:getElapsedSeconds(),
			score = currScore,
			first = boolFirst,
			roundctr = roundNumber,
			correctcount = correctCtr,
			roundspeed = roundSpeed,
			pausecount = pauseCtr
		}
	}
	timerr = nil
	audio.stop()
	storyboard.removeScene("reloadthird")
	storyboard.gotoScene("reloadthird", option)
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