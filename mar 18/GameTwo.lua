------- Requirements ---------
MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local physics = require("physics")
local lfs = require("lfs")
local stopwatch =require "stopwatch"
local toast = require("toast");
local scene = storyboard.newScene()

--for the game
local numberOfCategories, selectedCategories
local images, labels, answers, maxcount
local gameBoard, boxGroup, boxes, selected
--for the timer and reloading
local maintimer, timerText
--for reloading params
local currTime, boolFirst, currScore, category, option, correctCtr, corrects
--for the pause screen
local pausegroup
--for the gameover screen, 
local gameovergroup, round, score, x, y, i
--for sounds
local muted, muteBtn, unmuteBtn
--for analytics
local profileName, pauseCtr, count, roundNumber, profileAge
local boolNew = false
--for after modal
local levelgroup
local name, email, age, namedisplay, agedisplay -- forward reference (needed for Lua closure)
local userAge, username, emailaddress, latestId

------- Load DB ---------
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )
------- Load sounds ---------
local incorrectSound = audio.loadSound("music/incorrect.mp3")
local correctSound = audio.loadSound("music/correct.mp3")
local secondGameMusic = audio.loadSound("music/GameTwo.mp3")
local game2MusicChannel
------- Load font ---------
local font
if "Win" == system.getInfo( "platformName" ) then
    font = "Cartwheel"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "Cartwheel"
end
--------------------------------------------------- FUNCTIONS ------------------------------------------------------------------------

-- END: EMAIL
local function onSendEmail( event )
	local options =
	{
	   to = "",
	   subject = "SkillVille: Game 2 Searching and Sorting Single Assessment",
	   body = "<html>Attached is the assessment for the most recently played Searching and Sorting game.<br>Name: "..username.text.."<br>Age: "..userAge.text.."</html>",
	   attachment = { baseDir=system.DocumentsDirectory, filename="SkillVille - Game 2 Searching and Sorting Single Assessment.txt", type="text" },
	   isBodyHtml = true
	}
	native.showPopup("mail", options)
end

-- END: SAVE SCORE TO DB
function insertToDB(category, score, name, age, timestamp, pausectr)
	local query = [[INSERT INTO GameTwo VALUES (NULL, ']] .. 
	category .. [[',']] ..
	score .. [[',']] ..
	name .. [[',']] ..
	timestamp .. [[',']] ..
	pausectr.. [[',']] ..
	age.. [[');]]
	db:exec(query)

	for row in db:nrows("SELECT id FROM GameTwo") do
		id = row.id
	end
	return id
end

-- END: SAVE ANALYTICS TO DB
function insertAnalyticsToDB(gameid, roundid, word, category, isCorrect, speed)
	local query = [[INSERT INTO GameTwoAnalytics VALUES (NULL, ']] .. 
	gameid .. [[',']] ..
	roundid .. [[',']] ..
	word .. [[',']] ..
	category .. [[',']] ..
	isCorrect .. [[',']] ..
	speed .. [[');]]
	db:exec(query)
end

-- END: GENERATE REPORT & SAVE TO FILE
function saveToFile()
	report = ""
	report = report .. "------------------------------------------------------------"
	report = report .. "\nGAME 2 ANALYTICS\n"
	report = report .. "------------------------------------------------------------\n"
	report = report .. "The following information contains the analytics for the most recently played game for Game 2: Searching and Sorting (ORANGE HOUSE). Note: For Game 2, the image of the word is the basis for its category, not the meaning of the word. To complete one round, user must be able to categorize 10, 15 and 20 items respectively for each level.\n\n"

	for row in db:nrows("SELECT COUNT(*) as count FROM GameTwoAnalytics where gamenumber = '"..latestId.."'") do
		dbcount = row.count
	end

	if dbcount == 0 then
		report = report .. "GAME # " .. latestId .. "\n"
		for row in db:nrows("SELECT * FROM GameTwo where id = '" .. latestId .. "'") do
			report = report .. "\nPlayer:\t\t" .. row.name .. "\nAge:\t"..row.age.."\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score
		end
	else
		gamenumber = {}

		for row in db:nrows("SELECT * FROM GameTwoAnalytics") do
			gamenumber[#gamenumber+1] = row.gamenumber
		end

		report = ""
		report = report .. "GAME # " .. gamenumber[#gamenumber]
		for row in db:nrows("SELECT * FROM GameTwo where id = '" .. gamenumber[#gamenumber] .. "'") do
			report = report .. "\nPlayer:\t\t" .. row.name .. "\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score
		end
		--get round #
		allRoundNumbers = {}
		rounds = {}
		for row in db:nrows("SELECT roundnumber FROM GameTwoAnalytics WHERE gamenumber = '" .. gamenumber[#gamenumber] .. "'") do
			allRoundNumbers[#allRoundNumbers+1] = row.roundnumber
		end
		rounds = cleanArray(allRoundNumbers)

		for j = 1, #rounds do
			report = report .. "\n\nROUND "..rounds[j]
			--round speed
			for row in db:nrows("SELECT speed FROM GameTwoAnalytics WHERE roundnumber = '"..rounds[j].."' AND gamenumber = '"..gamenumber[#gamenumber].."'") do
				report = report .. "\nRound time: "..row.speed.." seconds"
				break
			end
			-- get categories
			allCategories = {}
			categories = {}
			for row in db:nrows("SELECT category FROM GameTwoAnalytics WHERE roundnumber = '"..rounds[j].."' AND gamenumber = '"..gamenumber[#gamenumber].."'") do
				allCategories[#allCategories+1] = row.category
			end
			categories = {}
			categories = cleanArray(allCategories)

			for k = 1, #categories do
				report = report .. "\n\nCATEGORY: " .. categories[k]
				-- get correct
				words = {}
				for row in db:nrows("SELECT word FROM GameTwoAnalytics WHERE isCorrect = '1' AND category = '"..categories[k].."' AND roundnumber = '"..rounds[j].."' AND gamenumber = '"..gamenumber[#gamenumber].."'") do
					words[#words+1] = row.word
				end
				report = report .. "\nCorrect Words: "..#words
				for w = 1, #words do
					report = report .. "\n\t"..words[w]
				end
				--get incorrect
				words = {}
				for row in db:nrows("SELECT word FROM GameTwoAnalytics WHERE isCorrect = '0' AND category = '"..categories[k].."' AND roundnumber = '"..rounds[j].."' AND gamenumber = '"..gamenumber[#gamenumber].."'") do
					words[#words+1] = row.word
				end
				report = report .. "\nIncorrect Words: "..#words
				for w = 1, #words do
					report = report .. "\n\t"..words[w]
				end
			end
		end
	end	
	local path = system.pathForFile( "SkillVille - Game 2 Searching and Sorting Single Assessment.txt", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write(report)
	io.close( file )
	file = nil
end

-- END: SAVE PROFILE
function saveProfile(dbname, dbage)
	local query = [[INSERT INTO Profile VALUES (NULL, ']] .. 
	dbname .. [[',']] ..
	dbage .. [[');]]
	db:exec(query)

	for row in db:nrows("UPDATE GameTwo SET name ='" .. dbname .. "' where id = '" .. latestId .. "'") do end
	for row in db:nrows("UPDATE GameTwo SET age ='" .. dbage .. "' where id = '" .. latestId .. "'") do end
end

-- END: GET NAME
local function nameListener( event )
	if(event.phase == "began") then
	elseif(event.phase == "editing") then
	elseif(event.phase == "ended") then
		name.text = event.target.text
	end
end

-- END: GET AGE
local function ageListener( event )
	if(event.phase == "began") then
	elseif(event.phase == "editing") then
	elseif(event.phase == "ended") then
		age.text = event.target.text
	end
end

-- END: CLOSE MODAL
function closedialog()
	username = display.newText(name.text, 190, 100, font, 20)
	username.isVisible = false
	userAge = display.newText(age.text, 190, 100, font, 20)
	userAge.isVisible = false

	-- SAVE TO PROFILE
	 if username.text == "" or userAge.text == "" then
		toast.new("Please enter your information.", 1000, 80, -105, "toastText")
	else
		levelgroup.isVisible = false
		name.isVisible = false
		age.isVisible = false
		saveProfile(username.text, userAge.text)
		saveToFile()
	end 
end

---- END: PROFILE MODAL
function showanalyticsDialog()
 	levelgroup = display.newGroup()

	local rect = display.newImage("images/modal/gray.png")
 	rect.x = display.contentCenterX;
 	rect.y = display.contentCenterY;
 	rect:addEventListener("touch", function() return true end)
	rect:addEventListener("tap", function() return true end)
	levelgroup:insert(rect)

	local dialog = display.newImage("images/modal/saveanalytics.png")
 	dialog.x = display.contentCenterX;
 	dialog.y = display.contentCenterY;
 	levelgroup:insert(dialog)

	namelabel = display.newText("Kid's name", display.contentCenterX, 100, font, 25)
	namelabel:setFillColor(0,0,0)
	name = native.newTextField( display.contentCenterX, 130, 220, 40 )    -- passes the text field object
    name.hintText= ""
   	name.text = name.hintText
   	levelgroup:insert(namelabel)
   	levelgroup:insert(name)

   	agelabel = display.newText("Kid's Age", display.contentCenterX, 165, font, 25)
   	agelabel:setFillColor(0,0,0)
	age = native.newTextField( display.contentCenterX, 200, 100, 40 )    -- passes the text field object
   	age.inputType = "number"
   	age.hintText = ""
   	age.text = age.hintText
   	levelgroup:insert(agelabel)
   	levelgroup:insert(age)

   	--checkbutton
	okay = widget.newButton{
		id = "okay",
		defaultFile = "images/buttons/submit_button.png",
		fontSize = 15,
		emboss = true,
		onEvent = closedialog
	}
	okay.x = 350; okay.y = 235
	levelgroup:insert(okay)

   	name:addEventListener( "userInput", nameListener)
	age:addEventListener( "userInput", ageListener)
end

-- END: GAME OVER SPRITE
local function finalmenu( )
	gameovergroup = display.newGroup()

    round = display.newText("ROUND: "..category, 0, 0, font, 15)
	round.x = 150
	round.y = display.contentCenterY - 120
	round:setFillColor(0,0,0)
	gameovergroup:insert(round)

	score = display.newText("SCORE: "..currScore, 0, 0, font, 15)
	score.x = 300
	score.y = display.contentCenterY - 120
	score:setFillColor(0,0,0)
	gameovergroup:insert(score)

	local playBtn = display.newImage( "images/buttons/playagain_button.png")
    playBtn.x = 130
    playBtn.y = display.contentCenterY - 80
    playBtn:addEventListener("touch", restart_onBtnRelease)
    gameovergroup:insert(playBtn)

    local playtext = display.newText("PLAY AGAIN", 165, display.contentCenterY - 90, font, 25) 
    playtext:setFillColor(0,0,0)
    gameovergroup:insert(playtext)

    local homeBtn = display.newImage( "images/buttons/home_button.png")
    homeBtn.x = 130
    homeBtn.y = display.contentCenterY - 25
    homeBtn:addEventListener("touch", home)
    gameovergroup:insert(homeBtn)

    local hometext = display.newText("BACK TO MENU", 165, display.contentCenterY - 30, font, 25) 
    hometext:setFillColor(0,0,0)
    gameovergroup:insert(hometext)

    local emailBtn = display.newImage( "images/buttons/email_button.png")
    emailBtn.x = 130
    emailBtn.y = display.contentCenterY + 30
    emailBtn:addEventListener("touch", onSendEmail)
    gameovergroup:insert(emailBtn)
    
    local emailtext = display.newText("EMAIL RESULTS", 165, display.contentCenterY + 25, font, 25) 
    emailtext:setFillColor(0,0,0)
    gameovergroup:insert(emailtext)

    screenGroup:insert(gameovergroup)
end

-- END: GAME OVER SPRITE
local fallover = function(event)
	if (i < 9) then
		local crate1 = display.newImage( "images/game_two/" .. game:sub(i,i).. ".png" )
		crate1.x = x
		crate1.y = 270
		transition.to(crate1, {time=1000, alpha=1})
		i = i + 1
		x = x + 60
		gameover:insert(crate1)
	else
		maintimer = nil
		finalmenu()
		showanalyticsDialog()
	end
	screenGroup:insert(gameover)
end

-- END: GAME OVER MODAL
function gameoverdialog()
	local date = os.date( "%m" ) .. "-" .. os.date( "%d" ) .. "-" .. os.date( "%y" )
	local time = os.date( "%I" ) .. ":" .. os.date( "%M" ) .. os.date( "%p" )
	local timeStamp = date .. ", " .. time

	latestId = insertToDB(category, currScore, profileName, profileAge, timeStamp, pauseCtr)
	
	timerText:removeSelf()
	scoreToDisplay.isVisible = false
	pauseBtn.isVisible = false
	boxGroup.isVisible = false
	gameBoard.isVisible = false
	unmuteBtn.isVisible = false
	muteBtn.isVisible = false
	progressBar.isVisible = false
	progressBarFill.isVisible = false
	for i = 1, #images do
		images[i].isVisible = false
	end

	gameover = display.newGroup()
	
	i = 1
	x = 20
	game = "GAMEOVER"
	timer.performWithDelay( 500, fallover, 9)

end

-- BUTTON: HOME
function home(event)
	if(event.phase == "ended") then
		gameovergroup.isVisible = false
		gameover.isVisible = false
  		storyboard.removeScene("GameTwo")
  		storyboard.removeScene("MainMenu")
  		audio.stop()
  		mainMusic = audio.loadSound("music/MainSong.mp3")
		backgroundMusicChannel = audio.play( mainMusic, { loops=-1}  )

		option = {
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

-- BUTTON: UNMUTE
function unmuteGame(event)
	audio.resume(game2MusicChannel)
	unmuteBtn.isVisible = false
	muteBtn.isVisible = true
	muted = 0
end

-- BUTTON: MUTE
function muteGame(event)
	audio.pause(game2MusicChannel)
	muteBtn.isVisible = false
	unmuteBtn.isVisible = true
	muted = 1
end

-- BUTTON: ZOOM IN
function zoomIn(event)
	filename = event.target.filename
	toast.new(filename, 1000, display.contentCenterX, display.contentCenterY, "toastGameTwo")
end

-- BUTTON: PAUSE
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

-- BUTTON: RESUME
function resume_onBtnRelease()
	if (muted == 0) then 
		audio.resume(game2MusicChannel)
	end
	pausegroup.isVisible = false
	maintimer:resume()
    pauseBtn.isVisible = true
	return true
end
 
-- BUTTON: RESTART
function restart_onBtnRelease()
	if category == "easy" then
		currTime = 62
	elseif category == "medium" then
		currTime = 122
	elseif category == "hard" then
		currTime = 182
	end
	option =	{
		effect = "fade",
		time = 1000,
		params = {
			categ = category,
			first = true,
			time = currTime,
			score = 0,
			new = boolNew,
			pause = pauseCtr,
			round = roundNumber,
			mute = muted,
		}
	}
	audio.stop()
	Runtime:removeEventListener("enterFrame", onFrame)
	storyboard.gotoScene("ReloadGameTwo", option)
end

-- BUTTON: EXIT PAUSE MODAL
function exit_onBtnRelease()
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
	storyboard.removeScene("GameTwo")
	storyboard.gotoScene("MainMenu", option)
end

-- PAUSE MODAL
function showpauseDialog()
	pausegroup = display.newGroup()
	local pausedialog = display.newImage("images/pause/pause_modal.png")
 	pausedialog.x = display.contentCenterX;
 	pausedialog.y = display.contentCenterY;
 	pausedialog:addEventListener("touch", function() return true end)
	pausedialog:addEventListener("tap", function() return true end)
	pausegroup:insert(pausedialog)

	local resumeBtn = widget.newButton{
		defaultFile="images/pause/resume_button.png",
		overFile="images/pause/resume_button.png",
		onEvent = resume_onBtnRelease -- event listener function
	}
	-- resumeBtn:setReferencePoint( display.CenterReferencePoint )
	resumeBtn.x = bg.x - 80
	resumeBtn.y = 170
	pausegroup:insert(resumeBtn)

	local exitBtn = widget.newButton{
		defaultFile="images/pause/exit_button.png",
		overFile="images/pause/exit_button.png",
		onEvent = exit_onBtnRelease -- event listener function
	}
	-- exitBtn:setReferencePoint( display.CenterReferencePoint )
	exitBtn.x = bg.x + 100
	exitBtn.y = 170
	pausegroup:insert(exitBtn)

	screenGroup:insert(pausegroup)
end

-- GAME: RELOAD
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
			round = roundNumber,
			mute = muted
		}
	}
	gameBoard:removeSelf()
	boxGroup:removeSelf()
	timerText:removeSelf()
	maintimer = nil
	storyboard.gotoScene("ReloadGameTwo", option)
end

-- GAME: CHECK ANSWER
function checkanswer(target)
	for i = 1, numberOfCategories do
		if target.x == boxes[i].x then
			boxNumber = i
			break
		end
	end

	isCorrect = false
	for j = 1, maxcount do
		if answers[boxNumber][j] == target.label then
			toast.new("images/correct.png", 300, display.contentCenterX, display.contentCenterY, "correct")
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
			-- progressBarFill.x = progressBarFill.x + (320/corrects) / 2
			break
		end
	end

	if isCorrect == false then
		audio.play(incorrectSound)
		toast.new("images/wrong.png", 300, display.contentCenterX, display.contentCenterY, "incorrect")
		if count == 0 then
			boxes[boxNumber].wrongCtr = boxes[boxNumber].wrongCtr + 1
			count = boxes[boxNumber].wrongCtr
			boxes[boxNumber].wrongWords[count] = target.label					
		else
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
		local gamenumber = 0
		for row in db:nrows("SELECT id FROM GameTwo ORDER BY id DESC") do
			if row.id ~= nil then
				gamenumber = row.id				
				break
			end
		end
		gamenumber = gamenumber + 1

		for i = 1, numberOfCategories do
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
end

-- GAME: DRAG IMAGE
function imageDrag (event)
	local imagePosX = {}
	local imagePosY = {}
	isMoved = false
	selected = event.target
	screenGroup:insert(selected)

	if event.phase == "moved" or event.phase == "ended" then
		---------- BOUNDARIES ----------
		if selected.x > display.viewableContentWidth then
			selected.x = display.viewableContentWidth
		elseif selected.x < 0 then
			selected.x = 0
		end

		if selected.y > display.viewableContentHeight - 30 then
			selected.y = display.viewableContentHeight - 30
		elseif selected.y < 30 then
			selected.y = 30
		end	
		---------- BOUNDARIES ----------

		for i = 1, numberOfCategories do
			imagePosX[i] = math.abs(selected.x - boxes[i].x)
			imagePosY[i] = math.abs(selected.y - boxes[i].y)
		end
		-- Snap to middle
		for i = 1, numberOfCategories do

			--dist from original
			local initX = math.abs(selected.initialX - selected.x)
			local initY = math.abs(selected.initialY - selected.y)

			if (imagePosX[i] <= 50) and (imagePosY[i] <= 50) then
				selected.x = boxes[i].x;
				selected.y = boxes[i].y;
				isMoved = true
			elseif (initX <= 5) and (initY <= 5) then
				-- snap back to original position
				selected.x = selected.initialX
				selected.y = selected.initialY
			end
		end
	end

	if event.phase == "ended" then
		if isMoved == true then
			checkanswer(selected)
		end
	end

	return true
end 

-- GAME: GRID LAYOUT
function drawGrid(gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight)
	local currentX = gridX
	local currentY = gridY
	images = {}
	gameBoard = display.newGroup()
	fontSize = 12

	for i = 1, #photoArray do
		images[i] = display.newImageRect(photoArray[i], photoWidth, photoHeight)
		if images[i] == nil then
			images[i] = display.newImageRect("images/game_two/image.png", photoWidth, photoHeight)
			images[i].filename = "images/game_two/image.png"
			templabel = photoTextArray[i]
		else
			images[i].filename = photoArray[i]
			templabel = ""
		end
		images[i].x = currentX + 23
		images[i].y = currentY + 20
		images[i].initialX = images[i].x
		images[i].initialY = images[i].y
		images[i].label = photoTextArray[i]
		images[i]:addEventListener("tap", zoomIn)
		gameBoard:insert(images[i])

		local textPosX = photoWidth/2 - (fontSize/2)*string.len(photoTextArray[i])/2
		textObject = display.newText( templabel, currentX + textPosX, currentY + photoHeight - 50, native.systemFontBold, fontSize )
		textObject:setFillColor( 0,0,0 )
		gameBoard:insert(textObject)
		screenGroup:insert(gameBoard)

		--Update the position of the next item
		currentX = currentX + photoWidth + paddingX

		if(i % columnNumber == 0) then
			currentX = gridX
			currentY = currentY + photoHeight + paddingY
		end

		MultiTouch.activate(images[i], "move", "single");
		images[i]:addEventListener(MultiTouch.MULTITOUCH_EVENT, imageDrag);
	end

	screenGroup:insert(gameBoard)
end

-- WORD: EASY RAND
function randomizeEasy(categories)
	rand = math.random(2)
	rand2 = {}

	colors = {3,4,5,6}
	shapes = {7,8,9}

	if rand == 1 then
		-- colors
		rand2[1] = math.random(#colors)
		rand2[2] = math.random(#colors)
		while(rand2[1] == rand2[2]) do
			rand2[2] = math.random(#colors)
		end
		rand2[1] = colors[rand2[1]]
		rand2[2] = colors[rand2[2]]
	else
		-- shapes
		rand2[1] = math.random(#shapes)
		rand2[2] = math.random(#shapes)
		while(rand2[1] == rand2[2]) do
			rand2[2] = math.random(#shapes)
		end
		rand2[1] = shapes[rand2[1]]
		rand2[2] = shapes[rand2[2]]
	end
	return rand2
end

-- WORD: RANDOMIZE CATEGORY
function randomizeCategory(categories)

	local numbers = {}
	for i = 1, numberOfCategories do
		local uniq, num
		while not uniq do
			num = math.random(#categories)
	    	uniq = true -- assume number is unique
		  	if category == 'medium' then
			--wag 1 or 2
				while (num == 1 or num == 2) do
				    num = math.random(#categories)
				end
			end
	    
	    -- check if it really is
	   		for k = 1,i-1 do
	      		if numbers[k] == num then uniq = false end
	    	end
	  	end
	  	numbers[i] = num
	end

	return numbers
end

-- WORD: RE-RANDOMIZE
function shuffle(array)
	for i = 1, #array*2 do
		a = math.random(#array)
		b = math.random(#array)
		array[a], array[b] = array[b], array[a]
	end
	return array
end

-- WORD: REMOVE DUPLICATES
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

-- WORD: GET FROM DB
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

	-- max count
	for row in db:nrows("SELECT COUNT(*) as count FROM Words where livingThingCategory = '0'") do
		maxcount = row.count
	end

	-- remove duplicates
	correctWords[1] = answers[1][1]
	for i = 1, #dbFields do
		for j = 1, maxcount do
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
	end

	-- Shuffle and select n words
	wordsCopy = {}
	wordsCopy = shuffle(words)
	for i = 1, limit do
		words[i] = wordsCopy[i]
	end

	return words
end

-- GAME: TIMER
local function onFrame(event)
	if (maintimer ~= nil) then
   		timerText.text = maintimer:toRemainingString()
   		local done = maintimer:isElapsed()
 		local secs = maintimer:getElapsedSeconds()

   		if(done) then
	   		Runtime:removeEventListener("enterFrame", onFrame)
	    	gameoverdialog()
		end
	end  
end

------------------CREATE SCENE: MAIN -----------------------------
function scene:createScene(event)
	boolFirst = event.params.first
	category = event.params.categ
	currScore = event.params.score
	currTime = event.params.time
	boolNew = event.params.new
	pauseCtr = event.params.pause
	roundNumber = event.params.round

	profileName = "Cha" --temp
	profileAge = 4
	count = 0

	-- Start timer
	maintimer = stopwatch.new(currTime)
	screenGroup = self.view

	-- Screen Elements
	scoreToDisplay = display.newText("Score: "..currScore, 15, 12, font, 25 )	
	scoreToDisplay:setFillColor(0,0,0)

	timerText = display.newText("", 482, 12, font, 25) 
	timerText:setFillColor(0,0,0)
	
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
	bg = display.newImageRect("images/game_two/game2bg.png", width, height)
	bg.x = display.contentCenterX;
	bg.y = display.contentCenterY;
	screenGroup:insert(bg)
	--pause button
	pauseBtn = display.newImageRect( "images/game_two/pause.png", 20, 20)
    pauseBtn.x = 438
    pauseBtn.y = 12
    pauseBtn:addEventListener("touch", pauseGame)
    pauseBtn:addEventListener("tap", pauseGame)
    screenGroup:insert( pauseBtn )
    --unmute button
    unmuteBtn = display.newImageRect( "images/game_two/mute_button.png", 20, 20)
    unmuteBtn.x = 415
    unmuteBtn.y = 12
	unmuteBtn:addEventListener("touch", unmuteGame)
    unmuteBtn:addEventListener("tap", unmuteGame)
    screenGroup:insert( unmuteBtn )
    unmuteBtn.isVisible = false
    --mute button
	muteBtn = display.newImageRect( "images/game_two/unmute_button.png", 20, 20)
    muteBtn.x = 415
    muteBtn.y = 12
    muteBtn:addEventListener("touch", muteGame)
    muteBtn:addEventListener("tap", muteGame)
    screenGroup:insert( muteBtn )
    --outer rectangle
    progressBar = display.newRect(display.contentCenterX, 10, 322, 15)
    -- progressBar:setReferencePoint(display.BottomLeftReferencePoint)
    progressBar.strokeWidth = 1
    progressBar:setStrokeColor( 0, 0, 0) 
    progressBar:setFillColor( 0, 0, 0 )  
    screenGroup:insert( progressBar )
    --inner rectangle which fills up
    progressBarFill = display.newRect(display.contentWidth/6 + 2, 10, 0, 10)
    progressBarFill:setFillColor(50,205,30)
    progressBarFill.anchorX = 0

    -- progressBarFill:setReferencePoint(display.BottomLeftReferencePoint)
    screenGroup:insert( progressBarFill )

    if boolFirst then
		muted = 0
		game2MusicChannel = audio.play( secondGameMusic, { loops=-1}  )
		boolNew = false
		pauseCtr = 0
		roundNumber = 1
	else
		muted = event.params.mute
		if muted == 1 then
			muteGame()
		else
			game2MusicChannel = event.params.music
			audio.resume(game2MusicChannel)
		end
		pauseCtr = event.params.pause
		roundNumber = event.params.round
	end
    
    -------------------------------------------- GAME --------------------
    --boxes
	boxGroup = display.newGroup()
	boxSize = 50
	boxes = {}
	boxLabels = {}

	if category == 'easy' then
		selectedCategories = randomizeEasy(categories)
	else
		selectedCategories = randomizeCategory(categories)
	end

	for i = 1, numberOfCategories do
		boxes[i] = display.newImageRect("images/game_two/"..categories[selectedCategories[i]].. ".png", 150, 100)
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

	allWords = {}
	allExtras = {}
	allWords = getWords("correct", numberOfCorrectAnswers)
	allExtras = getWords("incorrect", numberOfIncorrectAnswers)

	-- temporary labels
	labels = {}
	length = numberOfCorrectAnswers + numberOfIncorrectAnswers	
	for i = 1, numberOfCorrectAnswers do labels[i] = allWords[i] end
	for i = numberOfCorrectAnswers+1, length do labels[i] = allExtras[i - numberOfCorrectAnswers] end
	labels = shuffle(labels)

	-- photos
	photos = {}
	for i = 1, length do
		photos[i] = "images/pictures/"..labels[i]..".png"
	end
	screenGroup:insert(scoreToDisplay)
	screenGroup:insert(boxGroup)
	screenGroup:insert(timerText)

	--gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight
	drawGrid(gridX, 30, photos, labels, length/4, 5, 5, 50, 50)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)
Runtime:addEventListener("enterFrame", onFrame)

return scene