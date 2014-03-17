------- Requirements ---------
MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local timer = require("timer")
local physics = require("physics")
local lfs = require("lfs")
local stopwatch = require("stopwatch")
local toast = require("toast")
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
--for after modal
local levelgroup
local name, email, age, namedisplay, agedisplay -- forward reference (needed for Lua closure)
local userAge, username, emailaddress, latestId
local isClick, numOfBlinks

local roundToDisplay
local isPaused = false
------- Load sounds ---------
local incorrectSound = audio.loadSound("music/incorrect.mp3")
local correctSound = audio.loadSound("music/correct.mp3")
--local thirdGameMusic = audio.loadSound("music/ThirdGame.mp3")
--local game3MusicChannel
local one = audio.loadSound("music/1.mp3")
local two = audio.loadSound("music/2.mp3")
local three = audio.loadSound("music/3.mp3")
local four = audio.loadSound("music/4.mp3")
local five = audio.loadSound("music/5.mp3")
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
------- Load DB ---------
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )
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

function saveProfile(dbname, dbage)
	print("SAVE PROFILE " .. latestId)
	local query = [[INSERT INTO Profile VALUES (NULL, ']] .. 
	dbname .. [[',']] ..
	dbage .. [[');]]
	db:exec(query)

	for row in db:nrows("UPDATE ThirdGame SET name ='" .. dbname .. "' where id = '" .. latestId .. "'") do end
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

--------------------------- EMAIL RESULTS -----------------------------
local function onSendEmail( event )
	print("\nFUNCTION OnSendMail")
	local options =
	{
	   to = "",
	   subject = "Game 3 Analytics",
	   body = "Name: "..username.text.." Age: "..userAge.text,
	   attachment = { baseDir=system.DocumentsDirectory, filename="Game 3.txt", type="text" },
	}
	print("  SHOWPOPUP: " .. native.showPopup("mail", options))
	native.showPopup("mail", options)
end

-----------------------FUNCTIONS FOR GETTING NAME ------------------------------------

function closedialog()
	username = display.newText(name.text, 190, 100, font, 20)
	username.isVisible = false
	userAge = display.newText(age.text, 190, 100, font, 20)
	userAge.isVisible = false
	levelgroup.isVisible = false
	name.isVisible = false
	age.isVisible = false

	saveProfile(username.text, userAge.text)
	queryAndSaveToFile(latestId)
end

local function nameListener( event )
	if(event.phase == "began") then
	elseif(event.phase == "editing") then
	elseif(event.phase == "ended") then
		name.text = event.target.text
	end
end

local function ageListener( event )
	if(event.phase == "began") then
	elseif(event.phase == "editing") then
	elseif(event.phase == "ended") then
		age.text = event.target.text
	end
end

function showUserDialog()
 	
 	levelgroup = display.newGroup()

	local rect = display.newImage("images/modal/gray.png")
 	rect.x = display.contentWidth/2;
 	rect:addEventListener("touch", function() return true end)
	rect:addEventListener("tap", function() return true end)
	levelgroup:insert(rect)

	local dialog = display.newImage("images/modal/saveanalytics.png")
 	dialog.x = display.contentWidth/2;
 	levelgroup:insert(dialog)

	namelabel = display.newText("Kid's name", 190, 100, font, 20)
	namelabel:setTextColor(0,0,0)
	name = native.newTextField( 135, 125, 220, 40 )    -- passes the text field object
    name:setTextColor( 0,0,0)
    name.hintText= ""
   	name.text = name.hintText
   	levelgroup:insert(namelabel)
   	levelgroup:insert(name)

   	agelabel = display.newText("Kid's Age", 200, 160, font, 20)
   	agelabel:setTextColor(0,0,0)
	age = native.newTextField( 200, 190, 100, 40 )    -- passes the text field object
    age:setTextColor( 0,0,0)
   	age.inputType = "number"
   	age.hintText = ""
   	age.text = age.hintText
   	levelgroup:insert(agelabel)
   	levelgroup:insert(age)

   	--checkbutton
	okay = widget.newButton{
		id = "okay",
		defaultFile = "images/firstgame/submit_button.png",
		fontSize = 15,
		emboss = true,
		onEvent = closedialog
	}
	okay.x = 350; okay.y = 235
	levelgroup:insert(okay)

   	name:addEventListener( "userInput", nameListener)
	age:addEventListener( "userInput", ageListener)

end


--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	if(event.phase == "ended") then
		gameovergroup.isVisible = false
		gameover.isVisible = false
		scoreToDisplay.isVisible = false
		roundToDisplay.isVisible = false
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
--[[
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
end]]

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
    emailBtn:addEventListener("touch", onSendEmail)
    gameovergroup:insert(emailBtn)
    
    local emailtext = display.newText(" EMAIL\nRESULTS", 310, display.contentCenterY + 60, font, 15) 
    emailtext:setTextColor(0,0,0)
    gameovergroup:insert(emailtext)

    screenGroup:insert(gameovergroup)

end
------------------- GAME OVER ---------------------------

function moveBG(self,event)
	--print(self.x)
	if(self.x == 241) then
		Runtime:removeEventListener("enterFrame", gameover)
		finalmenu()
		showUserDialog()
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
	print("REPORT: " .. report)
	local path = system.pathForFile( "Game 3.txt", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write( report )
	io.close( file )
	file = nil

	--Append
	report = report .. "\n----------------------------------\n"
	local path = system.pathForFile( "Game 3 Analytics.txt", system.DocumentsDirectory )
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
	latestId = insertToDB(category, currScore, profileName, timeStamp, pauseCtr)

	--per round
	for i = 1, roundNumber do
		-- if last
		if tonumber(correctCtr[i]) > 0 and tonumber(roundSpeed[i]) == 0 then
			roundSpeed[i] = currTime - roundSpeed[i]
		end
		--save to db
		insertAnalyticsToDB(latestId, i, correctCtr[i], roundSpeed[i])
	end

	-------------------

	objectGroup:removeSelf()
	pauseBtn.isVisible = false
--	unmuteBtn.isVisible = false
--	muteBtn.isVisible = false

	gameover= display.newImage( "images/thirdgame/gameover.png" )
	gameover.x = 700
	gameover.y =  display.contentHeight/2 - 10;
	gameover.speed = 3

	gameover.enterFrame = moveBG
    Runtime:addEventListener("enterFrame", gameover)

    screenGroup:insert(gameover)


end


---------------- PAUSE GAME ---------------------------
function pauseGame(event)
    if(event.phase == "ended") then
       	pauseCtr = pauseCtr + 1
    	timerr:pause()
    	timer.pause(blinker)
    	audio.pause(one)
    	audio.pause(two)
    	audio.pause(three)
    	audio.pause(four)
    	audio.pause(five)

        pauseBtn.isVisible = false
        --audio.pause(game3MusicChannel)
        showpauseDialog()
      
        return true
    end
end
 
 --------------- RESTART GAME ----------------------
function restart_onBtnRelease()
	if category == "easy" then
		currTime = 62
	elseif category == "medium" then
		currTime = 122
	elseif category == "hard" then
		currTime = 182
	end
	option = {
		effect = "fade",
		time = 1000,
		params = {
			categ = category,
			first = true,
			time = currTime,
			score = 0
		}
	}
	audio.stop()
	Runtime:removeEventListener("touch", gestures)
	Runtime:removeEventListener("accelerometer", gestures)
	storyboard.gotoScene("reloadthird", option)
end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
--[[	if (muted == 0) then 
		audio.resume(game2MusicChannel)
	end]]
	audio.resume(one)
	audio.resume(two)
	audio.resume(three)
	audio.resume(four)
	audio.resume(five)
--	pausegroup:removeSelf()
	pausegroup.isVisible = false
	timerr:resume()
	timer.resume(blinker)
    pauseBtn.isVisible = true
	return true
end

---------------- EXIT FROM PAUSE ----------------
function exit_onBtnRelease()
	
	Runtime:removeEventListener("touch", gestures)
	Runtime:removeEventListener("accelerometer", gestures)

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
	resumeBtn.x = bg.x - 80
	resumeBtn.y = 170
	pausegroup:insert(resumeBtn)

	local exitBtn = widget.newButton{
		defaultFile="images/pause/exit_button.png",
		overFile="images/pause/exit_button.png",
		onEvent = exit_onBtnRelease -- event listener function
	}
	exitBtn:setReferencePoint( display.CenterReferencePoint )
	exitBtn.x = bg.x + 100
	exitBtn.y = 170
	pausegroup:insert(exitBtn)

	screenGroup:insert(pausegroup)
end

function shuffle(array)
	for i = 1, #array*2 do
		local a = math.random(#array)
		local b = math.random(#array)
		array[a], array[b] = array[b], array[a]
	end
	return array
end

function canClick()
	local done = timerr:isElapsed()
	if(not done) then
		toast.new("images/go.png", 300, 80, 0, "thirdgame")
	end
	isClick = true
end

local function playBlink(event)
		print("\nFUNCTION playBlink")
		print(isClick)
		local p1 = event.source.params.p1
		n = string.byte(order,p1) % 96
		print("  N: " .. n)
		print("  CURRENT: " .. p1)
		obj = objectGroup[n]
--		print("  OBJECT NAME: "..obj.name)
		transition.to( obj, {time = 200, alpha = 0} )
		
		if (n % 5 == 0) then
			audio.play(one)
			print("  SOUND: 1")
		elseif (n % 5 == 1) then
			audio.play(two)
			print("  SOUND: 2")
		elseif (n % 5 == 2) then
			audio.play(three)
			print("  SOUND: 3")
		elseif (n % 5 == 3) then
			audio.play(four)
			print("  SOUND: 4")
		elseif (n % 5 == 4) then
			audio.play(five)
			print("  SOUND: 5")
		end

		transition.to( obj, {delay = 200, time = 200, alpha = 1} )
		print("BLINKS "..numOfBlinks)
		
		if p1 == numOfBlinks then
			timer.performWithDelay( 800, canClick )
		end
end


local function startSequence(last)
	numOfBlinks = last
	isClick = false
	print("\nFUNCTION startSequence")
	for i = 1, last do
		print("  I/CURRENT: " .. i)
		blinker = timer.performWithDelay(i*750, playBlink, 1)
		blinker.params = { p1 = i }
		current = i
	end
end


------------------CREATE SCENE: MAIN -----------------------------
function scene:createScene(event)
	muted = 0
	profileName = "Cha" --temp
	isClick = false
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

	correctCtr = {}
	roundSpeed = {}

	if(boolFirst) then
		--game3MusicChannel = audio.play( thirdGameMusic, { loops=-1}  )
		roundNumber = 1
		correctCtr[1] = 0
		roundSpeed[1] = 0
		pauseCtr = 0
	else
		--game3MusicChannel = event.params.music
		roundNumber = event.params.roundctr
		correctCtr = event.params.correctcount
		correctCtr[roundNumber] = 0
		roundSpeed = event.params.roundspeed
		roundSpeed[roundNumber] = 0
		pauseCtr = event.params.pausecount
	end

	print("\n  ROUND NUMBER: " .. roundNumber .. "\n")
	-- Screen Elements

	--bg
	width = 550; height = 320;

	imageCategory = math.random(5)

	local filename = "images/thirdgame/game3bg.png"

	if (imageCategory == 1) then
		filename = "images/thirdgame/bg/bg_garden.png"
	elseif (imageCategory == 2) then
		filename = "images/thirdgame/bg/bg_kitchen.png"
	elseif (imageCategory == 3) then
		filename = "images/thirdgame/bg/bg_clouds.png"
	elseif (imageCategory == 4) then
		filename = "images/thirdgame/bg/bg_teaparty.png"
	elseif (imageCategory == 5) then
		filename = "images/thirdgame/bg/bg_night.png"
	end

	bg = display.newImageRect(filename, width, height)
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

	--round
	roundToDisplay = display.newText("Round 1", (display.contentWidth/2)-35, 5, font, 18 )
	roundToDisplay:setTextColor(0,0,0)
	screenGroup:insert(roundToDisplay)

	--pause button
	pauseBtn = display.newImageRect( "images/secondgame/pause.png", 20, 20)
    pauseBtn.x = 445
    pauseBtn.y = 15
    pauseBtn:addEventListener("touch", pauseGame)
    pauseBtn:addEventListener("tap", pauseGame)
    screenGroup:insert( pauseBtn )
    screenGroup:insert(timerText)

    -- GAME
	objectGroup = display.newGroup()

	order = ""
	size = 0
	if category == 'easy' then
		imageCategoryCount = 1
		size = 2
	elseif category == 'medium' then
		imageCategoryCount = 2
		size = 1.5
	elseif category == 'hard' then
		imageCategoryCount = 3
		size = 1
	end

	-- imageCategory = math.random(4) FOUND BEFORE THE BG IS SET
	x = 0
	y = 0
	local z = 0
	for i = 1, dimensions * dimensions do
		if (i % dimensions ~= 1) then
			x = x + (70*size)
		elseif(i % dimensions == 1 and i > 1) then
			x = 0
			y = y + (60*size)
		end

		local pixelWidth = 50
		local pixelHeight = 50
		if (imageCategory == 1) then
			flowerNumber = math.random(8)
			filename = "images/thirdgame/flowers" .. flowerNumber .. ".png"
		elseif (imageCategory == 2) then
			fruitNumber = math.random(6)
			filename = "images/thirdgame/fruits" .. fruitNumber .. ".png"
		elseif (imageCategory == 3) then
			cloudNumber = math.random(5)
			filename = "images/thirdgame/clouds" .. cloudNumber .. ".png"
			pixelWidth = 75
		elseif (imageCategory == 4) then
			teaNumber = math.random(5)
			teaTypeNumber = math.random(4)
			teaType = {"smallpot", "bigpot", "cup", "pitcher"}
			filename = "images/thirdgame/" .. teaType[teaTypeNumber] .. teaNumber .. ".png"
		elseif(imageCategory == 5) then
			nightNumber = math.random(10)
			filename = "images/thirdgame/night" .. nightNumber .. ".png"
			if(nightNumber >= 7) then
				pixelWidth = 75
			end
		end

		obj = display.newImageRect(filename, pixelWidth*size, pixelHeight*size)
		obj.x = x
		obj.y = y

		obj.name = "" .. string.char(96+i)
		objectGroup:insert(i, obj)

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
	print("  ORDER: " .. order)
	-- ---------------------

	answer = ""
	-- current = 0
	print("BEFORE MAG PLAY ")
	print(isClick)

	startSequence(1)

	for i = 1, dimensions*dimensions do
		obj = objectGroup[string.byte(order,i) % 96]
		obj.isVisible = true
		obj.alpha = 1
		obj:addEventListener("tap", checkanswer)
		--obj:addEventListener("touch", checkanswer)
	end
	screenGroup:insert(objectGroup)
end

function checkanswer(event)
	print("\nFUNCTION checkanswer")
	local t = event.target
--	print("  T.NAME: " .. t.name)
	print(isClick)

	if isClick == true then
	-- if (event.phase == "ended") then
		-- print("  EVENT.PHASE == ENDED: " .. t.name)
		answer = answer .. t.name
		print("  ANSWER: " .. answer)
		a,b = string.find(order, answer)

		if(string.find(order, answer) ~= nil and a == 1) then
			print("  A and B: " .. a .. b)
			n = string.byte(t.name) % 96
			print("  THIS IS N: "..n)

			obj = objectGroup[n]
			transition.to( obj, {time = 200, alpha = 0} )

			if (n % 5 == 0) then
				audio.play(one)
				print("  SOUND: 1") 
			elseif (n % 5 == 1) then
				audio.play(two)
				print("  SOUND: 2")
			elseif (n % 5 == 2) then
				audio.play(three)
				print("  SOUND: 3")
			elseif (n % 5 == 3) then
				audio.play(four)
				print("  SOUND: 4")
			elseif (n % 5 == 4) then
				audio.play(five)
				print("  SOUND: 5")
			end

			transition.to( obj, {delay = 200, time = 200, alpha = 1} )
			
			if (a == 1 and b == current) then
				-- CORRECT YUNG BUONG PAGKAKASUNOD
				print("  a == 1 and b == current: CORRECT!!!!")
				currScore = currScore + 1
				correctCtr[roundNumber] = correctCtr[roundNumber] + 1
				scoreToDisplay.text = "Score: "..currScore
				toast.new("images/correct.png", 300, 80, 0, "thirdgame")
				roundToDisplay.text = "Round "..current+1
				--next!
				answer = ""
				-- print("CURRENT SA CHECKANSWER ".. current+1)
				if (current + 1 <= dimensions*dimensions) then
					startSequence(current+1)
				else
					reload()
				end
			elseif (a == 1 and b < current) then
				print(" a == 1 and b < current: correct and continue")
				currScore = currScore + 1
				correctCtr[roundNumber] = correctCtr[roundNumber] + 1
				scoreToDisplay.text = "Score: "..currScore
			end
		else
			---------- HERE: HINDI NAGPPLAY BEFORE MAG RELOAD.
			---------- ALSO, PAAYOS NG TOAST BEFORE MAG RELOAD.
			print("  WRONG!!!!")
			audio.play(incorrectSound)
			toast.new("images/wrong.png", 80, 80, 0, "thirdgame")
			reload()
		end
	-- else
	-- 	print("  ELSE")
	-- end
	end
end

function reload()
	isClick = false
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