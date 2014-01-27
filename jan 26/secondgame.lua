
------- Requirements ---------
MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local physics = require("physics")
local lfs = require("lfs")
local stopwatch =require "stopwatch"
local scene = storyboard.newScene()


------- Global variables ---------
--for the game
local numberOfCategories, selectedCategories
local images, labels, answers
local gameBoard, boxGroup, boxes
--for the timer and reloading
local maintimer, timerText
--for reloading params
local currTime, boolFirst, currScore, category, option, correctCtr, corrects
--for the pause screen
local pausegroup
--for the gameover screen, 
local gameovergroup, round, score, x, y, i
--for sounds
local muted 
local muteBtn, unmuteBtn
local profileName
local boolNew = false

------- Load DB ---------
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )

------- Load sounds ---------
local incorrectSound = audio.loadSound("music/incorrect.mp3")
local correctSound = audio.loadSound("music/correct.mp3")
local secondGameMusic = audio.loadSound("music/SecondGame.mp3")
local game2MusicChannel
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

-------- Analytics------------
local pauseCtr, count, roundNumber

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	if(event.phase == "ended") then
		gameovergroup.isVisible = false
		gameover.isVisible = false
  		storyboard.removeScene("secondgame")
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

--------- FUNCTION FOR GAME OVER SPRITE LISTENER ---------
local function finalmenu( )
--    print(event.phase)
		gameovergroup = display.newGroup()

    round= display.newText("ROUND: "..category, 0, 0, font, 15)
	round.x = 150
	round.y = display.contentCenterY - 120
	round:setTextColor(0,0,0)
	gameovergroup:insert(round)

	score= display.newText("SCORE: "..currScore, 0, 0, font, 15)
	score.x = 300
	score.y = display.contentCenterY - 120
	score:setTextColor(0,0,0)
	gameovergroup:insert(score)

	local playBtn = display.newImage( "images/firstgame/playagain_button.png")
    playBtn.x = 130
    playBtn.y = display.contentCenterY - 80
    playBtn:addEventListener("touch", restart_onBtnRelease)
    gameovergroup:insert(playBtn)

    local playtext = display.newText("PLAY AGAIN", 165, display.contentCenterY - 90, font, 25) 
    playtext:setTextColor(0,0,0)
    gameovergroup:insert(playtext)

    local homeBtn = display.newImage( "images/firstgame/home_button.png")
    homeBtn.x = 130
    homeBtn.y = display.contentCenterY - 25
    homeBtn:addEventListener("touch", home)
    gameovergroup:insert(homeBtn)

    local hometext = display.newText("BACK TO MENU", 165, display.contentCenterY - 30, font, 25) 
    hometext:setTextColor(0,0,0)
    gameovergroup:insert(hometext)

    local emailBtn = display.newImage( "images/firstgame/email_button.png")
    emailBtn.x = 130
    emailBtn.y = display.contentCenterY + 30
    --email:addEventListener("touch", home)
    gameovergroup:insert(emailBtn)
    
    local emailtext = display.newText("EMAIL RESULTS", 165, display.contentCenterY + 25, font, 25) 
    emailtext:setTextColor(0,0,0)
    gameovergroup:insert(emailtext)
end

--------------- FUNCTION FOR FALLING LETTERS -------------
local fallover = function(event)
	if (i < 9) then
		local crate1 = display.newImage( "images/secondgame/" .. game[i].. ".png" )
		crate1.x = x; crate1.y = 10
		physics.addBody( crate1, { density=0.6, friction=0.6, bounce=0.3, radius= 19 } )
		crate1.isFixedRotation= true
		crate1.isSleepingAllowed = true
		i = i + 1
		x = x + 60
		gameover:insert(crate1)
	else
		maintimer = nil
		finalmenu()
	end
end

function cleanArray(array)
	result = {}
	ctr = 1

	for i = 1, #array do
		if ctr > 1 then
			isUnique = true
			for j = 1, #result do
				if array[i] == result[j] then
					isUnique = false
				end
			end
			if isUnique then
				result[ctr] = array[i]
				ctr = ctr + 1
			end
		else
			result[ctr] = array[i]
			ctr = ctr + 1
		end
	end

	return result
end

function saveToFile()
	gamenumber = {}
	report = ""
	for row in db:nrows("SELECT * FROM SecondGameAnalytics") do
		gamenumber[#gamenumber+1] = row.gamenumber
	end

	for i = gamenumber[1], gamenumber[#gamenumber] do
		-- get game #
		print("\nGAME # " .. i)
		report = report .. "GAME # " .. i
		for row in db:nrows("SELECT * FROM SecondGame where id = '" .. i .. "'") do
			print("\nPlayer:\t\t" .. row.name .. "\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score.."\n")
			report = report .. "\nPlayer:\t\t" .. row.name .. "\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score
		end

		--get round #
		allRoundNumbers ={}	rounds = {}
		for row in db:nrows("SELECT roundnumber FROM SecondGameAnalytics WHERE gamenumber = '" .. i .. "'") do
			allRoundNumbers[#allRoundNumbers+1] = row.roundnumber
		end
		rounds = cleanArray(allRoundNumbers)

		print("ANALYSIS PER ROUND:")
		for j = 1, #rounds do
			print("\nROUND "..rounds[j])
			report = report .. "\n\nROUND "..rounds[j]

			--round speed
			for row in db:nrows("SELECT speed FROM SecondGameAnalytics WHERE roundnumber = '"..rounds[j].."' AND gamenumber = '"..i.."'") do
				print("Round time: "..row.speed.." seconds")
				report = report .. "\nRound time: "..row.speed.." seconds"
				break
			end

			-- get categories
			allCategories = {}		categories = {}
			for row in db:nrows("SELECT category FROM SecondGameAnalytics WHERE roundnumber = '"..rounds[j].."' AND gamenumber = '"..i.."'") do
				allCategories[#allCategories+1] = row.category
			end
			categories = cleanArray(allCategories)

			for k = 1, #categories do
				print("\nCATEGORY: " .. categories[k])
				report = report .. "\n\nCATEGORY: " .. categories[k]

				-- get correct
				words = {}
				for row in db:nrows("SELECT word FROM SecondGameAnalytics WHERE isCorrect = '1' AND category = '"..categories[k].."' AND roundnumber = '"..rounds[j].."' AND gamenumber = '"..i.."'") do
					words[#words+1] = row.word
				end
				print("\tCorrect Words: "..#words)
				report = report .. "\nCorrect Words: "..#words
				for w = 1, #words do
					print("\t\t"..words[w])
					report = report .. "\n\t"..words[w]
				end

				--get incorrect
				words = {}
				for row in db:nrows("SELECT word FROM SecondGameAnalytics WHERE isCorrect = '0' AND category = '"..categories[k].."' AND roundnumber = '"..rounds[j].."' AND gamenumber = '"..i.."'") do
					words[#words+1] = row.word
				end
				print("\tIncorrect Words: "..#words)
				report = report .. "\nIncorrect Words: "..#words
				for w = 1, #words do
					print("\t\t"..words[w])
					report = report .. "\n\t"..words[w]
				end
			end

		end
		print("----------------------------------")
		report = report .. "\n----------------------------------\n"
	end

	-- Save to file
	local path = system.pathForFile( "Game 2 Analytics.txt", system.ResourceDirectory )
	local file = io.open( path, "w" )
	file:write( report )
	io.close( file )
	file = nil

end

--------------- FUNCTION FOR END OF GAME ----------------
function gameoverdialog()
	--SCORING
	local date = os.date( "*t" )
	local timeStamp = date.month .. "-" .. date.day .. "-" .. date.year .. " ; " .. date.hour .. ":" .. date.min
	id = insertToDB(category, currScore, profileName, timeStamp, pauseCtr)
	print("ID2 " .. id)
	--
	-- Save to file
	saveToFile()
	
	timerText:removeSelf()
	-- maintimer = nil

	scoreToDisplay.isVisible = false
	pauseBtn.isVisible = false
	boxGroup.isVisible = false
	gameBoard.isVisible = false
	unmuteBtn.isVisible = false
	muteBtn.isVisible = false
	progressBar.isVisible = false
	progressBarFill.isVisible = false

	gameover = display.newGroup()

	physics.start()
	local rect = display.newRect( 0, 0, 570, 50)
	rect:setFillColor( 255, 255, 255, 100 )
	rect.isVisible = false -- optional
	rect.x = display.contentWidth/2;
	rect.y = display.contentHeight - 5
	physics.addBody( rect, "static" )
	gameover:insert(rect)

	i = 1
	x = 20

	getmetatable('').__index = function(str,i) return string.sub(str,i,i) end
	game = 'GAMEOVER'

	timer.performWithDelay( 500, fallover, 9)

end

--------------- TIMER: RUNTIME FUNCTION --------------------
timerText = display.newText("", 480, 0, font, 18) 
timerText:setTextColor(0,0,0)
local function onFrame(event)
	if (maintimer ~= nil) then
   		timerText.text = maintimer:toRemainingString()
   		local done = maintimer:isElapsed()
 		local secs = maintimer:getElapsedSeconds()
-- 		print("done:" .. secs)

   		if(done) then
	   		Runtime:removeEventListener("enterFrame", onFrame)
	    	gameoverdialog()
		end
	end  

end

---------------- UNMUTE GAME ---------------------------
function unmuteGame(event)
	audio.resume(game2MusicChannel)
	unmuteBtn.isVisible = false
	muteBtn.isVisible = true
	muted = 0
end

---------------- MUTE GAME ---------------------------
function muteGame(event)
	audio.pause(game2MusicChannel)
	muteBtn.isVisible = false
	unmuteBtn.isVisible = true
	muted = 1
end

---------------- ZOOM IN IMAGE ---------------------------
function zoomOut(event)
	levelgroup:removeSelf()
	maintimer:resume()
end

---------------- ZOOM IN IMAGE ---------------------------
function zoomIn(event)
	physics.pause()
	maintimer:pause()

 	levelgroup = display.newGroup()

	rect = display.newImage("images/modal/gray.png")
 	rect.x = display.contentWidth/2;
 	rect:addEventListener("touch", function() return true end)
	rect:addEventListener("tap", function() return true end)
	levelgroup:insert(rect)

 	zoomedImage = display.newImage("images/firstgame/pictures/blank.png", 200, 200)
 	zoomedImage.xScale = zoomedImage.xScale * 1.5
 	zoomedImage.yScale = zoomedImage.yScale * 1.5
 	zoomedImage.x = display.contentCenterX
 	zoomedImage.y = display.contentCenterY
 	levelgroup:insert(zoomedImage)

	exitBtn = widget.newButton{
		defaultFile="images/modal/closebutton.png",
		overFile="images/modal/closebutton.png",
		onRelease = zoomOut	-- event listener function
	}
	exitBtn:setReferencePoint( display.CenterReferencePoint )
	exitBtn.x = bg.x + 70
	exitBtn.y = 80
	levelgroup:insert(exitBtn)

end

---------------- PAUSE GAME ---------------------------
function pauseGame(event)
    if(event.phase == "ended") then
      	pauseCtr = pauseCtr + 1
    	maintimer:pause()
    	audio.pause(game2MusicChannel)
        pauseBtn.isVisible = false
        showpauseDialog()
        return true
    end
end
 
 --------------- RESTART GAME ----------------------
function restart_onBtnRelease()
	if (maintimer ~= nil) then
		pausegroup:removeSelf()
		timerText:removeSelf()
		gameBoard:removeSelf()
		boxGroup:removeSelf()
		scoreToDisplay.isVisible = false
		maintimer = nil
	else
		gameovergroup.isVisible = false
		gameover.isVisible = false
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
			score = 0,
			new = boolNew,
			pause = pauseCtr,
			round = roundNumber
		}
	}
	audio.stop()
	storyboard.removeScene("reloadsecond")
	storyboard.gotoScene("reloadsecond", option)
end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
	if (muted == 0) then 
		audio.resume(game2MusicChannel)
	end
	pausegroup:removeSelf()
	maintimer:resume()
    pauseBtn.isVisible = true
	return true
end
---------------- EXIT FROM PAUSE ----------------
function exit_onBtnRelease()
	pausegroup:removeSelf()
	timerText:removeSelf()
	boxGroup:removeSelf()
	gameBoard:removeSelf()
	scoreToDisplay.isVisible = false
	maintimer = nil
	storyboard.removeScene("secondgame")
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
	audio.stop()
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

--- SCORING
function insertToDB(category, score, name, timestamp, pausectr)
	local insertQuery = [[INSERT INTO SecondGame VALUES (NULL, ']] .. 
	category .. [[',']] ..
	score .. [[',']] ..
	name .. [[',']] ..
	timestamp .. [[',']] ..
	pausectr.. [[');]]
	db:exec(insertQuery)

	--NEW
	for row in db:nrows("SELECT id FROM SecondGame") do
		id = row.id
	end

	return id
end

function insertAnalyticsToDB(gameid, roundid, word, category, isCorrect, speed)
	local query = [[INSERT INTO SecondGameAnalytics VALUES (NULL, ']] .. 
	gameid .. [[',']] ..
	roundid .. [[',']] ..
	word .. [[',']] ..
	category .. [[',']] ..
	isCorrect .. [[',']] ..
	speed .. [[');]]
	db:exec(query)
end
----------------------- GET WORDS FROM DB -----------------------------
local function getWords(type, limit)
	dbFields = {}
	dbValues = {}
	for i = 1, #selectedCategories do
		if selectedCategories[i] == 1 or selectedCategories[i] == 2 then
			dbFields[i] = "livingThingCategory"
			dbValues[i] = values[selectedCategories[i]]
		elseif selectedCategories[i] >= 3 and selectedCategories[i] <= 6 then
			dbFields[i] = "colorCategory"
			dbValues[i] = values[selectedCategories[i]]
		elseif selectedCategories[i] >= 7 and selectedCategories[i] <= 9 then
			dbFields[i] = "shapeCategory" 
			dbValues[i] = values[selectedCategories[i]]			
		elseif selectedCategories[i] == 10 then
			dbFields[i] = "animalCategory"
			dbValues[i] = values[selectedCategories[i]]
		elseif selectedCategories[i] == 11 then
			dbFields[i] = "bodyPartCategory"
			dbValues[i] = values[selectedCategories[i]]				
		end
	end

	--query database:correct words
	answers = {}
	correctWords = {}
	for i = 1, #dbFields do
	    answers[i] = {}
	    j = 1
		for row in db:nrows("SELECT * FROM Words where "..dbFields[i].." = '".. dbValues[i] .. "'") do
			answers[i][j] = row.name
			j = j + 1
		end
	end

	-- remove duplicates
	correctWords[1] = answers[1][1]
	for i = 1, #dbFields do
		for j = 1, 127 do
			isUnique = true
			for k = 1, #correctWords do
				if answers[i][j] == correctWords[k] then
					isUnique = false
				end
			end
			if isUnique == true and answers[i][j] ~= nil then
				correctWords[#correctWords+1] = answers[i][j]
			end
		end
	end

	if type == "correct" then
		words = correctWords
		print("TOTAL CORRECT"..#words)
	--query database:extra words
	elseif type == "incorrect" then
		words = {}
		for i = 1, #dbFields do
			ctr = 1
			for row in db:nrows("SELECT * FROM Words where "..dbFields[i].." = '-1'") do
				isUnique = true
				if ctr == 1 then
					for row in db:nrows("SELECT * FROM Words where "..dbFields[1].." = '-1'") do
						words[1] = row.name
					end
				else
					-- remove duplicates
					for j = 1, #words-1 do
						if row.name == words[j] then
							isUnique = false
						end
					end
					-- remove correct words
					for j = 1, #correctWords do
						if row.name == correctWords[j] then
							isUnique = false
						end
					end
					if isUnique == true then
						words[#words+1] = row.name
					end
				end
				ctr = ctr + 1
			end
		end
		print("TOTAL WRONG"..#words)
	end

	-- Shuffle and select n words
	wordsCopy = shuffle(words)
	for i = 1, limit do
		words[i] = wordsCopy[i]
	end

	return words
end

-- FUNCTION FOR RANDOMIZING A CATEGORY
function randomizeCategory(categories)
	rand = {}
	rand[1] = math.random(#categories)
	for i = 2, numberOfCategories do
		rand[i] = math.random(#categories)			
		for j = 1, i-1 do
			while(rand[i] == rand[j]) do
				rand[i] = math.random(#categories)
			end
		end
	end
	return rand
end

-- FUNCTION FOR SHUFFLING ARRAY CONTENTS
function shuffle(array)
	for i = 1, #array*2 do
		a = math.random(#array)
		b = math.random(#array)
		array[a], array[b] = array[b], array[a]
	end
	return array
end

-- FUNCTION FOR RELOADING GAME
function generateNew()
	roundNumber = roundNumber + 1
	boolNew = true
	boolFirst = false
	option = {
		time = 400,
		params = {
			categ = category,
			first = boolFirst,
			time = currTime - maintimer:getElapsedSeconds(),
			score = currScore,
			new = boolNew,
			pause = pauseCtr,
			music = game2MusicChannel,
			round = roundNumber
		}
	}
	gameBoard:removeSelf()
	boxGroup:removeSelf()
	timerText:removeSelf()
	maintimer = nil
	storyboard.removeScene("reloadsecond")
	storyboard.gotoScene("reloadsecond", option)
end

-- FUNCTION FOR CHECKING ANSWER
function checkanswer(target)
	for i = 1, numberOfCategories do
		if target.x == boxes[i].x then
			boxNumber = i
			break
		end
	end

	isCorrect = false
	for j = 1, 127 do
		if answers[boxNumber][j] == target.label then
			currScore = currScore + 1
			scoreToDisplay.text = "Score: "..currScore
			isCorrect = true
			boxes[boxNumber].correctCtr = boxes[boxNumber].correctCtr + 1
			count = boxes[boxNumber].correctCtr
			boxes[boxNumber].correctWords[count] = target.label

			audio.play(correctSound)
			correctCtr = correctCtr - 1
			target:removeSelf()

			progressBarFill.width = progressBarFill.width + (320/corrects)
			progressBarFill.x = progressBarFill.x + (320/corrects) / 2
			break
		end
	end

	if isCorrect == false then
		audio.play(incorrectSound)
		-- first time
		if count == 0 then
			boxes[boxNumber].wrongCtr = boxes[boxNumber].wrongCtr + 1
			count = boxes[boxNumber].wrongCtr
			boxes[boxNumber].wrongWords[count] = target.label					
		else
			-- check kung nasa array na
			first = true
			for i = 1, #boxes[boxNumber].wrongWords do
				if boxes[boxNumber].wrongWords[i] == target.label then
					first = false
					break
				end
			end
			if first then
				boxes[boxNumber].wrongCtr = boxes[boxNumber].wrongCtr + 1
				count = boxes[boxNumber].wrongCtr
				boxes[boxNumber].wrongWords[count] = target.label					
			end
		end

		-- snap to original position
		target.x = target.initialX
		target.y = target.initialY
	end	

	if correctCtr == 0 then
		-- get game#
		for row in db:nrows("SELECT id FROM SecondGame ORDER BY id DESC") do
			gamenumber = row.id
			break
		end
		gamenumber = gamenumber + 1

		for i = 1, boxNumber do
			for j = 1, #boxes[i].correctWords do
				insertAnalyticsToDB(gamenumber, roundNumber, boxes[i].correctWords[j], boxes[i].label, 1, maintimer:getElapsedSeconds())
			end
			for j = 1, #boxes[i].wrongWords do
				insertAnalyticsToDB(gamenumber, roundNumber, boxes[i].wrongWords[j], boxes[i].label, 0, maintimer:getElapsedSeconds())
			end
		end
		generateNew()
	end
	boolNew = false
	--
end

-- FUNCTION FOR DRAGGING IMAGES
function imageDrag (event)
	local imagePosX = {}
	local imagePosY = {}
	isMoved = false
	local t = event.target

	if event.phase == "moved" or event.phase == "ended" then
		---------- BOUNDARIES ----------
		if t.x > display.viewableContentWidth then
			t.x = display.viewableContentWidth
		elseif t.x < 0 then
			t.x = 0
		end

		if t.y > display.viewableContentHeight - 30 then
			t.y = display.viewableContentHeight - 30
		elseif t.y < 30 then
			t.y = 30
		end	
		---------- BOUNDARIES ----------

		for i = 1, numberOfCategories do
			imagePosX[i] = math.abs(t.x - boxes[i].x)
			imagePosY[i] = math.abs(t.y - boxes[i].y)
		end
		-- Snap to middle
		for i = 1, numberOfCategories do
			if (imagePosX[i] <= 50) and (imagePosY[i] <= 50) then
				t.x = boxes[i].x;
				t.y = boxes[i].y;
				isMoved = true
			end
		end
	end

	if event.phase == "ended" then
		-- Check answer
		if isMoved == true then
			checkanswer(t)
		end
	end

	return true
end 

-- FUNCTION FOR GRID LAYOUT
function drawGrid(gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight)

	local currentX = gridX
	local currentY = gridY
	images = {}
	gameBoard = display.newGroup()

	for i = 1, #photoArray do
		fontSize = 12

		images[i] = display.newImageRect(photoArray[i], photoWidth, photoHeight)
		images[i].x = currentX + 23
		images[i].y = currentY + 20
		images[i].initialX = images[i].x
		images[i].initialY = images[i].y
		images[i].label = photoTextArray[i]

		images[i]:addEventListener("tap", zoomIn)
		
		gameBoard:insert(images[i])

		local textPosX = photoWidth/2 - (fontSize/2)*string.len(photoTextArray[i])/2
		textObject = display.newText( photoTextArray[i], currentX + textPosX, currentY + photoHeight - 50, native.systemFontBold, fontSize )
		textObject:setTextColor( 0,0,0 )
		gameBoard:insert(textObject)

		--Update the position of the next item
		currentX = currentX + photoWidth + paddingX

		if(i % columnNumber == 0) then
			currentX = gridX
			currentY = currentY + photoHeight + paddingY
		end

		MultiTouch.activate(images[i], "move", "single");
		images[i]:addEventListener(MultiTouch.MULTITOUCH_EVENT, imageDrag);

	end
end

------------------CREATE SCENE: MAIN -----------------------------
function scene:createScene(event)

	muted = 0
	--get passed parameters from previous scene
	boolFirst = event.params.first
	category = event.params.categ
	currScore = event.params.score
	currTime = event.params.time
	boolNew = event.params.new
	pauseCtr = event.params.pause
	roundNumber = event.params.round

	profileName = "Cha" --temp
	count = 0

	-- Start timer
	maintimer = stopwatch.new(currTime)
	screenGroup = self.view

	if (boolFirst) then
		game2MusicChannel = audio.play( secondGameMusic, { loops=-1}  )
		boolNew = false --analytics
		pauseCtr = 0
		roundNumber = 1
	else
		game2MusicChannel = event.params.music
		pauseCtr = event.params.pause
		roundNumber = event.params.round
	end

	-- Screen Elements
	--score
	scoreToDisplay = display.newText("Score: "..currScore, -30, 0, font, 18 )	
	scoreToDisplay:setTextColor(0,0,0)
	
    --Game
    categories = {"living", "nonliving", "red", "green", "blue", "yellow", "triangle", "rectangle", "circle", "animal", "bodypart"}
	values = {"1", "0", "red", "green", "blue", "yellow", "triangle", "rectangle", "circle", "1", "1"}

	if category == 'easy' then
		correctCtr = 10
		numberOfCategories = 2
	elseif category == 'medium' then
		correctCtr = 15
		numberOfCategories = 3
	else
		correctCtr = 20
		numberOfCategories = 4
	end

	corrects = correctCtr
	--bg
	width = 550; height = 320;
	bg = display.newImageRect("images/secondgame/game2bg.png", width, height)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	--pause button
	pauseBtn = display.newImageRect( "images/secondgame/pause.png", 20, 20)
    pauseBtn.x = 445
    pauseBtn.y = 10
    pauseBtn:addEventListener("touch", pauseGame)
    pauseBtn:addEventListener("tap", pauseGame)
    screenGroup:insert( pauseBtn )

     --mute button
    unmuteBtn = display.newImageRect( "images/secondgame/mute_button.png", 20, 20)
    unmuteBtn.x = 420
    unmuteBtn.y = 10
	unmuteBtn:addEventListener("touch", unmuteGame)
    unmuteBtn:addEventListener("tap", unmuteGame)
    screenGroup:insert( unmuteBtn )
    unmuteBtn.isVisible = false


    --mute button
	muteBtn = display.newImageRect( "images/secondgame/unmute_button.png", 20, 20)
    muteBtn.x = 420
    muteBtn.y = 10
    muteBtn:addEventListener("touch", muteGame)
    muteBtn:addEventListener("tap", muteGame)
    screenGroup:insert( muteBtn )

      --outer rectangle
    progressBar = display.newRect(display.viewableContentWidth/6 - 2, 3, 322, 15)
    progressBar:setReferencePoint(display.BottomLeftReferencePoint)
    progressBar.strokeWidth = 1
    progressBar:setStrokeColor( 0, 0, 0) 
    progressBar:setFillColor( 0, 0, 0 )  
    screenGroup:insert( progressBar )

    --inner rectangle which fills up
    progressBarFill = display.newRect(display.viewableContentWidth/6,5,0,10)
    progressBarFill:setFillColor(50,205,30)  
    progressBarFill:setReferencePoint(display.BottomLeftReferencePoint)
    screenGroup:insert( progressBarFill )
    
    -------------------------------------------- GAME --------------------

    --boxes
	boxGroup = display.newGroup()
	boxSize = 50
	boxes = {}
	boxLabels = {}

	selectedCategories = randomizeCategory(categories)
	for i = 1, numberOfCategories do
		boxes[i] = display.newImageRect("images/secondgame/"..categories[selectedCategories[i]].. ".png", 150, 100)
		boxes[i].label = categories[selectedCategories[i]]
		boxes[i].correctCtr = 0
		boxes[i].wrongCtr = 0
		boxes[i].correctWords = {}
		boxes[i].wrongWords = {}
		boxGroup:insert(boxes[i])
	end

	if category == 'easy' then
		boxes[1].x = width/4; boxes[1].y = 290
		boxes[2].x = width/4 + (4*boxSize); boxes[2].y = 290
		
		numberOfCorrectAnswers = 14
		numberOfIncorrectAnswers = 10
		gridX = width/7
	elseif category == 'medium' then
		boxes[1].x = width/3 - (2*boxSize) + 20; boxes[1].y = 290
		boxes[2].x = width/3 + boxSize + 10; boxes[2].y = 290
		boxes[3].x = width/3 + (3*boxSize) + 40; boxes[3].y = 290

		numberOfCorrectAnswers = 17
		numberOfIncorrectAnswers = 15
		gridX = width/22
	else
		boxes[1].x = width/4 - (2*boxSize) + 10; boxes[1].y = 290
		boxes[2].x = width/4 + boxSize - 15; boxes[2].y = 290
		boxes[3].x = width/4 + (3*boxSize) + 10; boxes[3].y = 290
		boxes[4].x = width/4 + (5*boxSize) + 30; boxes[4].y = 290

		numberOfCorrectAnswers = 24
		numberOfIncorrectAnswers = 16
		gridX = -30
	end

	allWords = getWords("correct", numberOfCorrectAnswers)
	allExtras = getWords("incorrect", numberOfIncorrectAnswers)

	-- photos
	photos = {}
	length = numberOfCorrectAnswers + numberOfIncorrectAnswers	
	for i = 1, length do
		photos[i] = "images/secondgame/image.png"
	end

	-- temporary labels
	labels = {}
	for i = 1, numberOfCorrectAnswers do labels[i] = allWords[i] end
	for i = numberOfCorrectAnswers+1, length do labels[i] = allExtras[i - numberOfCorrectAnswers] end
	labels = shuffle(labels)

	screenGroup:insert(scoreToDisplay)
	screenGroup:insert(boxGroup)

	--gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight
	drawGrid(gridX, 30, photos, labels, length/4, 5, 5, 50, 50)

end


scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)
Runtime:addEventListener("enterFrame", onFrame)

return scene