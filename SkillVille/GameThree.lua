------- Requirements ---------
local MultiTouch 	= require("dmc_multitouch")
local storyboard 	= require("storyboard")
local widget 		= require("widget")
local physics 		= require("physics")
local lfs 			= require("lfs")
local stopwatch 	= require("stopwatch")
local toast 		= require("toast")
local scene 		= storyboard.newScene()

scene.purgeOnSceneChange = true

------- Global variables ---------
--for the blackboard
local word, wordGroup, wordToGuess, letterbox, letterboxGroup, chalkLetter, letterbox, image
local wordFromDB, submit
--local screenGroup
--for the timer and reloading
local timer, timerText
--for reloading params
local currTime, boolFirst, currScore, category, option
--for the pause screen
local pausegroup
--for the gameover screen, 
local gameovergroup, round, score
local dialog, msgText, startTime
--for sounds
local muted, muteBtn, unmuteBtn, clearBtn
--for after modal
local levelgroup
local name, email, age, namedisplay, agedisplay -- forward reference (needed for Lua closure)
local userAge, username, emailaddress

--Listeners
local rect, name, age, playBtn, homeBtn, emailBtn, instance1, pausedialog, hintBtn, pauseBtn, unmuteBtn, muteBtn, clearBtn

-------- Analytics------------
-- *per item
local item, itemSpeed, itemHint, itemTries
-- *per game
local pauseCtr, profileName, latestId, profileAge

------- Load DB ---------
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )   

------- Load sounds ---------
local incorrectSound = audio.loadSound("music/incorrect.mp3")
local correctSound = audio.loadSound("music/correct.mp3")
local firstGameMusic = audio.loadSound("music/GameThree.mp3")
local game1MusicChannel

------- Load font ---------
local font
if "Win" == system.getInfo( "platformName" ) then
    font = "Cartwheel"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "Cartwheel"
end

--------- FUNCTIONS FOR DATABASE ------------
local function fetchByCategory(categ)
	local words = {}
	for row in db:nrows("SELECT * FROM Words where firstGameCategory ='"..categ.."'") do
		local rowData = row.id .. " " .. row.name.." "..row.firstGameCategory.." "..row.isCorrect.."\n"
        words[#words+1] = rowData
	end
	return words
end

--DB: update if word was guessed
local function updateDB(word)
	for row in db:nrows("UPDATE Words SET isCorrect ='true' where name ='"..word.."'") do end
end

--DB: insert to first game
local function insertToDB(category, score, name, age, timestamp, pausectr)
	local insertQuery = [[INSERT INTO GameThree VALUES (NULL, ']] .. 
	category .. [[',']] ..
	score .. [[',']] ..
	name .. [[',']] ..
	timestamp .. [[',']] ..
	pausectr .. [[',']] ..
	age .. [[');]]
	db:exec(insertQuery)

	for row in db:nrows("SELECT id FROM GameThree") do
		id = row.id
	end
	return id
end

local function insertAnalyticsToDB(gameid, roundid, speed, hintctr, triesctr, word)
	local query = [[INSERT INTO GameThreeAnalytics VALUES (NULL, ']] .. 
	gameid .. [[',']] ..
	roundid .. [[',']] ..
	speed .. [[',']] ..
	hintctr .. [[',']] ..
	triesctr .. [[',']] ..
	word .. [[');]]
	db:exec(query)
end

function saveProfile(dbname, dbage)
	local query = [[INSERT INTO Profile VALUES (NULL, ']] .. 
	dbname .. [[',']] ..
	dbage .. [[');]]
	db:exec(query)

	for row in db:nrows("UPDATE GameThree SET name ='" .. dbname .. "' where id = '" .. latestId .. "'") do end
	for row in db:nrows("UPDATE GameThree SET age ='" .. dbage .. "' where id = '" .. latestId .. "'") do end
end

--DB: reset all words to un-guessed
local function resetDB()
	for row in db:nrows("UPDATE Words SET isCorrect ='false'") do end
end

--DB:close
local function onSystemEvent( event )
	if event.type == "applicationExit" then
		if db and db:isopen() then
			db:close()
		end
	end
end
Runtime:addEventListener( "system", onSystemEvent )

--DB: check if a word has been answered correctly
local function hasBeenAnswered(wordToGuess)
	local rowData
	for row in db:nrows("SELECT * FROM Words WHERE name = '"..wordToGuess.."'") do
		rowData = row.isCorrect
	end
	return rowData
end

--DB: get word
local function getwordfromDB()
	local words = fetchByCategory(category)
	--randomize a word from DB that hasn't been correctly answered yet
	local i = 1 
	while true do
		local rand = math.random(#words)
		wordFromDB = {}
		for token in string.gmatch(words[rand], "[^%s]+") do
			wordFromDB[#wordFromDB+1] = token
		end
		word = wordFromDB[2]
		wordToGuess = word
		if hasBeenAnswered(wordToGuess) == 'false' then
			break
		end
		-- if all words have already been correctly answered, reset
		if i == #words then -- change to kung ilan words sa DB
			resetDB()
		end
		i = i + 1
	end
	item[currScore+1] = word
end

local function queryAnalytics(gamectr, column, value)
	result = ""
	ctr = 0
	for row in db:nrows("SELECT * FROM GameThreeAnalytics WHERE gamenumber = '" ..gamectr.. "' and " .. column .. "= '" .. value .. "'") do
		if ctr == 0 then
			result = row.word
		else
			result = result .. ", " .. row.word
		end
		ctr = ctr + 1
	end
	return result
end

-----------------------------------------------------------------------

--------- FUNCTIONS FOR STRING MANIPULATIONS ------------
-- position in str to be replaced with ch
local function replace_char (pos, str, ch)
	if (pos == 1) then return ch .. str:sub(pos+1)
	elseif (pos == str:len()) then return str:sub(1, str:len()-1) .. ch
	else return str:sub(1, pos-1) .. ch .. str:sub(pos+1)
	end
end

local function get_char (pos, str)
	return str:sub(pos, pos)
end

local function swap_char (pos1, pos2, str)
	local temp1 = get_char(pos1, str)
	local temp2 = get_char(pos2, str)
	str = replace_char(pos1, str, temp2)
	str = replace_char(pos2, str, temp1)
	return str
end

------- FUNCTION FOR SETTING THE WORD --------------
local function setword()
	getwordfromDB()
	local blanks = math.floor(word:len()/2)
	letterbox = ""
	-- GET RANDOM BLANKS ---
	for i = 1,blanks do
		local rand = math.random(word:len())
		while (get_char(rand, wordToGuess) == "_") or (letterbox:find(get_char(rand, wordToGuess)) ~= nil) do
			rand = math.random(word:len())
		end
		letterbox = letterbox .. get_char(rand, wordToGuess)
		wordToGuess = replace_char(rand, wordToGuess, "_")
	end

	-- GET LETTERBOX -------
	for i = 1,10 - blanks do
		local rand = math.random(26)
		local letter = string.char(96+rand)
		while (string.find(letterbox, letter) ~= nil) do
			rand = math.random(26)
			letter = string.char(96+rand)
		end
		letterbox = letterbox .. letter
	end

	-- SHUFFLE 
	for i = #letterbox, 2, -1 do -- backwards
		local r = math.random(i) -- select a random number between 1 and i
		letterbox = swap_char(i, r, letterbox) -- swap the randomly selected item to position i
	end
end

------------ FUNCTION FOR OBJECT DRAG --------------------
local function objectDrag (event)
	local distX, distY
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
		---------- BLANK BOUNDARIES ----------
			
		for i = 1, wordToGuess:len() do
			if ( get_char(i, wordToGuess) == "_" ) then
				local s = "_" .. get_char(i, word)
				distX = math.abs(t.x - wordGroup[s].x);
				distY = math.abs(t.y - wordGroup[s].y);
				if (distX <= 40) and (distY <= 40) then
					t.x = wordGroup[s].x;
					t.y = wordGroup[s].y;
				end
			end
		end
	end
end

------- FUNCTION FOR CHECKING ANSWER --------------
local function checkanswer(event)
	answer = ""
	blanks = math.floor(word:len()/2)
	count = 0
	for i = 1, wordToGuess:len() do
		if ( get_char(i, wordToGuess) ~= "_" ) then -- not blank, SKIP
			answer = answer .. get_char(i, wordToGuess)
		else -- if BLANK
			for j = 1, letterbox:len() do
				distX = math.abs(letterboxGroup[j].x - wordGroup[i].x)
				distY = math.abs(letterboxGroup[j].y - wordGroup[i].y)
				if (distX <= 10) and (distY <= 10) then
					-- if nasa blank
					count = count + 1
					answer = answer .. get_char(j, letterbox)
				end
			end
		end
	end

  	if event.phase == "ended" then
	  	itemTries[currScore+1] = itemTries[currScore+1] + 1
		if answer == word and count == blanks then
			audio.pause(game1MusicChannel)
			audio.play(correctSound)
			boolFirst = false
			updateDB(word) --set isCorrect to true
			currScore = currScore + 1
			-- ANALYTICS PER ITEM
			itemSpeed[currScore] = timer:getElapsedSeconds()
			option = {
				time = 400,
				params = {
					categ = category,
					first = boolFirst,
					time = currTime - timer:getElapsedSeconds(),
					score = currScore,
					music = game1MusicChannel,
					speed = itemSpeed,
					pause = pauseCtr,
					itemWord = item,
					tries = itemTries,
					hint = itemHint,
					mute = muted,
				}
			}
			timerText:removeSelf()
			timer = nil
			storyboard.gotoScene("ReloadGameThree", option)
		else
			toast.new("images/wrong.png", 500, display.contentCenterX, display.contentCenterY, "incorrect")
			audio.play(incorrectSound)
		end
	end
end

--------------------------- EMAIL RESULTS -----------------------------
local function onSendEmail( event )
	local options =
	{
	   to = "",
	   subject = "SkillVille: Game 3 Language and Spelling Single Assessment",
	   body = "<html>Attached is the assessment for the most recently played Language and Spelling game.<br>Name: "..username.text.."<br>Age: "..userAge.text.."</html>",
	   attachment = { baseDir=system.DocumentsDirectory, filename="SkillVille - Game 3 Language and Spelling Single Assessment.txt", type="text" },
	   isBodyHtml = true
	}
	native.showPopup("mail", options)
end

-----------------------FUNCTIONS FOR GETTING NAME ------------------------------------
function generateReport()
	gamenumber = {}
	roundnumber = {}
	speed = {}
	hint = {}
	tries = {}
	words = {}
	
	for row in db:nrows("SELECT * FROM GameThreeAnalytics") do
		gamenumber[#gamenumber+1] = row.gamenumber
		roundnumber[#roundnumber+1] = row.roundnumber
		speed[#speed+1] = row.speed
		hint[#hint+1] = row.hintcount
		tries[#tries+1] = row.triescount
		words[#words+1] = row.word
	end

	first = gamenumber[1]
	last = gamenumber[#gamenumber]

	local report = ""
	report = report .. "------------------------------------------------------------"
	report = report .. "\nGAME 3 ANALYTICS"
	report = report .. "\n------------------------------------------------------------\n"
	report = report .. "The following information contains the analytics for the most recently played game for Game 3: Language and Spelling (PURPLE HOUSE). The speed for each correctly answered word, the number of times user asked for a hint and the number of tries before being corrected are recorded for every word that appears.\n\n" 
	report = report .. "GAME# " .. last .. "\n\n"
	for row in db:nrows("SELECT * FROM GameThree where id = '" .. last .. "'") do
		finalscore = row.score
		report = report .. "Player:\t\t" .. row.name .. "\nAge:\t"..row.age.."\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score .. "\n"
		break
	end

	--By Speed
	for row in db:nrows("SELECT speed FROM GameThreeAnalytics WHERE gamenumber = '"..last.."' and speed != '0' ORDER BY cast(speed as integer) desc") do
		maxVal = row.speed
		break
	end
	for row in db:nrows("SELECT speed FROM GameThreeAnalytics WHERE gamenumber = '"..last.."' and speed != '0' ORDER BY cast(speed as integer)") do
		if tonumber(row.speed) > 0 then
			minVal = row.speed
			break
		end
	end

	if maxVal ~= minVal then
		max = queryAnalytics(last, "speed", maxVal)
		report = report .. "Longest Time:\t"..max.." ("..maxVal.." seconds)\n"
		min = queryAnalytics(last, "speed", minVal)
		report = report .. "Shortest Time:\t"..min.." ("..minVal.. " seconds)\n"
	end

	--By Hints
	for row in db:nrows("SELECT hintcount FROM GameThreeAnalytics WHERE gamenumber = '"..last.."' ORDER BY cast(hintcount as integer) DESC") do
		maxVal = row.hintcount
		break
	end
	for row in db:nrows("SELECT hintcount FROM GameThreeAnalytics WHERE gamenumber = '"..last.."' ORDER BY cast(hintcount as integer)") do
		minVal = row.hintcount
		break
	end
	if maxVal ~= minVal then
		max = queryAnalytics(last, "hintcount", maxVal)
		report = report .. "Most hints:\t"..max.." (" ..maxVal.." time/s)\n"
		min = queryAnalytics(last, "hintcount", minVal)
		report = report .. "Least hints:\t"..min.." ("..minVal.." time/s)\n"
	end

	--By Tries
	for row in db:nrows("SELECT triescount FROM GameThreeAnalytics WHERE gamenumber = '"..last.."' and triescount != '0' ORDER BY cast(triescount as integer) DESC") do
		maxVal = row.triescount
		break
	end
	for row in db:nrows("SELECT triescount FROM GameThreeAnalytics WHERE gamenumber = '"..last.."' and triescount != '0' ORDER BY cast(triescount as integer)") do
		if tonumber(row.triescount) > 0 then			
			minVal = row.triescount
			break
		end
	end
	if maxVal ~= minVal then
		max = queryAnalytics(last, "triescount", maxVal)
		report = report .. "Most mistaken:\t"..max.." ("..maxVal.." attempt/s)\n"
		min = queryAnalytics(last, "triescount", minVal)
		report = report .. "Least mistaken:\t"..min.." ("..minVal.." attempt/s)\n"
	end

	--PER WORD
	report = report .. "\nPER ITEM ANALYSIS:"
	report = report .. "\nWORD\tSPEED\tHINTS\tTRIES"
	for j = 1, #roundnumber do
		if tonumber(gamenumber[j]) == tonumber(last) then
			report = report .. "\n" .. words[j] .. "\t" .. speed[j] .. "\t" .. hint[j] .. "\t" .. tries[j]
		end
	end
	-- Save to file
	local path = system.pathForFile( "SkillVille - Game 3 Language and Spelling Single Assessment.txt", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write( report )
	io.close( file )
	file = nil
end

function closedialog()
	username = display.newText(name.text, 190, 100, font, 20)
	username.isVisible = false
	userAge = display.newText(age.text, 190, 100, font, 20)
	userAge.isVisible = false

	if username.text == "" or userAge.text == "" then
		toast.new("Please enter your information.", 1000, 80, -105, "toastText")
	else
		levelgroup.isVisible = false
		name.isVisible = false
		age.isVisible = false
		saveProfile(username.text, userAge.text)
		generateReport()
	end
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

function showanalyticsDialog()
 	levelgroup = display.newGroup()

	local rect = display.newImage("images/modal/gray.png")
 	rect.x = display.contentCenterX;
 	rect.y = display.contentCenterY;
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

--------------  FUNCTION FOR GO BACK TO MENU --------------------
local function home(event)
--	if(event.phase == "ended") then
		gameovergroup.isVisible = false
  		storyboard.removeScene("GameThree")
  		storyboard.removeScene("MainMenu")
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
		storyboard.gotoScene("MainMenu", option)
  		return true
--  	end
end

--------- FUNCTION FOR GAME OVER SPRITE LISTENER ---------
local function spriteListener( event )
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

    	local playBtn = display.newImage( "images/buttons/playagain_button.png")
	    playBtn.x = 130
	    playBtn.y = display.contentCenterY - 60
	    playBtn:addEventListener("tap", restart_onBtnRelease)
	    gameovergroup:insert(playBtn)

	    local playtext = display.newText("PLAY AGAIN", display.contentCenterX-7, display.contentCenterY-60, font, 25) 
	    gameovergroup:insert(playtext)

	    local homeBtn = display.newImage( "images/buttons/home_button.png")
	    homeBtn.x = 130
	    homeBtn.y = display.contentCenterY
	    homeBtn:addEventListener("tap", home)
	    gameovergroup:insert(homeBtn)

	    local hometext = display.newText("BACK TO MENU", display.contentCenterX+10, display.contentCenterY, font, 25) 
	    gameovergroup:insert(hometext)

	    local emailBtn = display.newImage( "images/buttons/email_button.png")
	    emailBtn.x = 130
	    emailBtn.y = display.contentCenterY + 60
	   	emailBtn:addEventListener("tap", onSendEmail)
	    gameovergroup:insert(emailBtn)
	    local emailtext = display.newText("EMAIL RESULTS", display.contentCenterX+10, display.contentCenterY+60, font, 25) 
	    gameovergroup:insert(emailtext)

	    screenGroup:insert(gameovergroup)

	    showanalyticsDialog()
	end
end


--------------- FUNCTION FOR END OF GAME ----------------
function gameoverdialog()

	-- SAVE TO DB
	local date = os.date( "%m" ) .. "-" .. os.date( "%d" ) .. "-" .. os.date( "%y" )
	local time = os.date( "%I" ) .. ":" .. os.date( "%M" ) .. os.date( "%p" )
	local timeStamp = date .. ", " .. time
	latestId = insertToDB(category, currScore, profileName, profileAge, timeStamp, pauseCtr)

	-- SAVE ANALYTICS
	for i = 1, #item do
		insertAnalyticsToDB(latestId, i, itemSpeed[i], itemHint[i], itemTries[i], item[i])
	end

	timerText:removeSelf()
	timer = nil

	scoreToDisplay.isVisible = false
	image.isVisible = false
	letterboxGroup.isVisible = false
	wordGroup.isVisible = false
	submit.isVisible = false
	pauseBtn.isVisible = false
	hintBtn.isVisible = false
	unmuteBtn.isVisible = false
	muteBtn.isVisible = false
	clearBtn.isVisible = false

	local sheet1 = graphics.newImageSheet( "images/game_three/trygameover.png", { width=414, height=74, numFrames=24 } )
	local instance1 = display.newSprite( sheet1, { name="gameover", start=1, count=24, time=4000, loopCount = 1} )
	instance1.x = display.contentCenterX
	instance1.y = display.contentCenterY - 20
	instance1:play()
	instance1:addEventListener( "sprite", spriteListener )
	screenGroup:insert(instance1)

	round= display.newText("ROUND: "..category, 0, 0, font, 25)
	round.x = display.contentCenterX
	round.y = display.contentCenterY + 30

	score= display.newText("SCORE: "..currScore, 0, 0, font, 25)
	score.x = display.contentCenterX
	score.y = display.contentCenterY + 65

end

--------------- TIMER: RUNTIME FUNCTION --------------------
local function onFrame(event)
	if (timer ~= nil) then
   		timerText.text = timer:toRemainingString()
   		local done = timer:isElapsed()
 		local secs = timer:getElapsedSeconds()
   		if(done) then
	   		Runtime:removeEventListener("enterFrame", onFrame)
	    	gameoverdialog()
		end
	end 
end

function generateLetterbox()
	x = (display.viewableContentWidth/2) + 25
	y = (display.viewableContentHeight/2) - 80
	letterboxGroup = display.newGroup()

	for i = 1, #letterbox do
		local c = get_char(i, letterbox)
		chalkLetter = display.newText( c:upper(), x, y, font, 45)
		chalkLetter:setFillColor(0.94,0.88,0.1)
		letterboxGroup:insert(i, chalkLetter)
		letterboxGroup[c] = chalkLetter
		if(i == 6) then
			x = (display.viewableContentWidth/2) + 65
			y = y + 40
		else
			x = x + 40
		end
		letterboxGroup[i].x = x 
		letterboxGroup[i].y = y
		letterboxGroup[i].initX = x
		letterboxGroup[i].initY = y
		MultiTouch.activate(chalkLetter, "move", "single")
		chalkLetter:addEventListener(MultiTouch.MULTITOUCH_EVENT, objectDrag);
	end
	screenGroup:insert(letterboxGroup)
end

---------------- new: CLEAR ---------------------------
local function clear(event)
	for i = 1, #letterbox do
		letterboxGroup[i].isVisible = false
		letterboxGroup[i] = nil
	end
	letterboxGroup = nil
	generateLetterbox()
	-- for i = 1, #letterbox do
	-- 	letterboxGroup[i].x = letterboxGroup[i].initX
	-- 	letterboxGroup[i].y = letterboxGroup[i].initY
	-- end
end

---------------- UNMUTE GAME ---------------------------
local function unmuteGame(event)
	audio.resume(game1MusicChannel)
	unmuteBtn.isVisible = false
	muteBtn.isVisible = true
	muteBtn.isVisible = true
	muted = 0
end

---------------- MUTE GAME ---------------------------
local function muteGame(event)
	audio.pause(game1MusicChannel)
	muteBtn.isVisible = false
	unmuteBtn.isVisible = true
	muted = 1
end

---------------- PAUSE GAME ---------------------------
local function pauseGame(event)
    if(event.phase == "ended") then
       	pauseCtr = pauseCtr + 1 --NEW
    	timer:pause()
    	audio.pause(game1MusicChannel)
    	submit:setEnabled(false)
--[[   		for i = 1, #letterbox do
			MultiTouch.deactivate(letterboxGroup[i])
		end]]
        pauseBtn.isVisible = false
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
	option =	{
		effect = "fade",
		time = 1000,
		params = {
			categ = category,
			first = true,
			time = currTime,
			score = 0,
			--analytics
			speed = itemSpeed,
			pause = pauseCtr,
			itemWord = item,
			tries = itemTries,
			hint = itemHint,
			mute = muted,
		}
	}
	audio.stop()
	Runtime:removeEventListener("enterFrame", onFrame)
	storyboard.gotoScene("ReloadGameThree", option)
end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
	pausegroup.isVisible = false
	if (muted == 0) then 
		audio.resume(game1MusicChannel)
	end
	timer:resume()
	submit:setEnabled(true)
    pauseBtn.isVisible = true
	return true
end

---------------- EXIT FROM PAUSE ----------------
function exit_onBtnRelease()
	audio.stop()
	mainMusic = audio.loadSound("music/MainSong.mp3")
	backgroundMusicChannel = audio.play( mainMusic, { loops=-1}  )

	storyboard.gotoScene("MainMenu", "fade", 100, {music = backgroundMusicChannel})
end

----------------- PAUSE DIALOG ------------------
function showpauseDialog()
	pausegroup = display.newGroup()
	local pausedialog = display.newImage("images/pause/pause_modal.png")
 	pausedialog.x = display.contentCenterX;
 	pausedialog.y = display.contentCenterY;
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

local function networkListener( event )
	local speech = audio.loadSound( word..".mp3", system.TemporaryDirectory )

	if speech == nil then
		toast.new("Device must be connected\nto the internet!", 1000, 15, -105, "toastText")
	else
	   	audio.play( speech )
	end

end

local function play()
	itemHint[currScore+1] = itemHint[currScore+1] + 1
	network.download( "http://www.translate.google.com/translate_tts?tl=en&q='"..word.."'", "GET", networkListener, word..".mp3", system.TemporaryDirectory )	
end

local function displayScreenElements()
	--BG
	bg = display.newImageRect("images/game_three/board.png", 550, 320)
	bg.x = display.contentCenterX;
	bg.y = display.contentCenterY;
	screenGroup:insert(bg)
	--SCORE
	scoreToDisplay = display.newText("Score: "..currScore, 37, 37, font, 25 )
	timerText = display.newText("", 458, 37, font, 25)

	------ BUTTONS -------
	--SUBMIT
	submit = widget.newButton{
		id = "submit",
		defaultFile = "images/buttons/submit_button.png",
		fontSize = 15,
		emboss = true,
		onEvent = checkanswer,
	}
	submit.x = 453; submit.y = 180
	screenGroup:insert(submit)

	-- HINT
	hintBtn = widget.newButton{
		id = "hint",
		defaultFile = "images/game_three/hint_button.png",
		fontSize = 15,
		emboss = true,
	}
	hintBtn.x = 400; hintBtn.y = 180
	screenGroup:insert(hintBtn)
	hintBtn:addEventListener("tap", play)
	
	-- PAUSE
	pauseBtn = display.newImageRect( "images/game_three/pause.png", 20, 20)
    pauseBtn.x = 410
    pauseBtn.y = 37
    pauseBtn:addEventListener("touch", pauseGame)
    screenGroup:insert( pauseBtn )

    -- UN/MUTE
    unmuteBtn = display.newImageRect( "images/game_three/mute_button.png", 20, 20)
    unmuteBtn.x = 380
    unmuteBtn.y = 37
    unmuteBtn.isVisible = false
--	unmuteBtn:addEventListener("touch", unmuteGame)
    unmuteBtn:addEventListener("tap", unmuteGame)
    screenGroup:insert( unmuteBtn )

	muteBtn = display.newImageRect( "images/game_three/unmute_button.png", 20, 20)
    muteBtn.x = 380
    muteBtn.y = 37
--    muteBtn:addEventListener("touch", muteGame)
    muteBtn:addEventListener("tap", muteGame)
    screenGroup:insert( muteBtn )	
end

------------------CREATE SCENE: MAIN -----------------------------
function scene:createScene(event)

	-- ** VARIABLES  ** --
	screenGroup = self.view
	profileName = "Default"
	profileAge = 4
	item = {}
	itemTries = {0}
	itemHint = {0}
	itemSpeed = {}

	-- From previous scene
	boolFirst = event.params.first
	category = event.params.categ
	currScore = event.params.score
	currTime = event.params.time
	timer = stopwatch.new(currTime)

	displayScreenElements()

	if boolFirst then
		--resetDB()
		muted = 0
		game1MusicChannel = audio.play( firstGameMusic, { loops=-1}  )
		itemSpeed[1] = 0
		item[1] = ""
		itemTries[1] = 0
		itemHint[1] = 0
		pauseCtr = 0
	else
		muted = event.params.mute
		if muted == 1 then
			muteGame()
		else
			audio.resume(game1MusicChannel)
		end
		game1MusicChannel = event.params.music
		itemSpeed = event.params.speed
		pauseCtr = event.params.pause
		item = event.params.itemWord
		itemTries = event.params.tries
		itemHint = event.params.hint
		item[currScore+1] = ""
		itemTries[currScore+1] = 0
		itemHint[currScore+1] = 0
		itemSpeed[currScore+1] = 0
	end

	setword()

	--IMAGE
	image = display.newImage( "images/pictures/"..word..".png" )
	image.x = 310/2; image.y = 260/2;

	-- LETTERS
	local x = -20
	local y = 260
	wordGroup = display.newGroup()
	local a = 1
	for i = 1, #wordToGuess do
		local c = get_char(i, wordToGuess)
		local filename = "images/game_three/"
		if (c == "_") then
			filename = filename .. "newblank.png"
			chalkLetter = display.newImage(filename)
		else
			chalkLetter = display.newText( c:upper(), x, y, font, 45)
			chalkLetter:setFillColor(0.94, 0.88, 0.1)
		end		
		wordGroup:insert(chalkLetter)
		if (c == "_") then
			c = c .. get_char(i, word)
		end
		wordGroup[c] = chalkLetter
		x = x + 50
		chalkLetter.x = x 
		chalkLetter.y = y
	end

	-- CLEAR
	clearBtn = display.newImageRect( "images/game_three/clear.png", 50, 50)
    clearBtn.x = x + 55
    clearBtn.y = y
   -- clearBtn:addEventListener("touch", clear)
    clearBtn:addEventListener("tap", clear)
    screenGroup:insert( clearBtn )
	
	--- add to screen
	screenGroup:insert(image)

	--letters to fill up with
	generateLetterbox()

	screenGroup:insert(wordGroup)
	screenGroup:insert(scoreToDisplay)
	screenGroup:insert(timerText)
end

function scene:enterScene(event)
	print("went here")
end

function scene:destroyScene(event)
	print("went here")
end
function scene:exitScene(event)
	print("went here")
end


scene:addEventListener("createScene", scene)
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
Runtime:addEventListener("enterFrame", onFrame)



return scene