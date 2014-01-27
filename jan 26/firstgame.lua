------- Requirements ---------
MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local physics = require("physics")
local lfs = require("lfs")
local stopwatch =require "stopwatch"
local scene = storyboard.newScene()
local toast = require("toast");
local toast2 = require("toast2");
local profileName

------- Global variables ---------
--for the blackboard
local word, wordGroup, wordToGuess, letterbox, letterboxGroup, chalkLetter, letterbox, image
local wordFromDB, submit, screenGroup
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
local muted 
local muteBtn, unmuteBtn, clearBtn
local origx, origy

-------- Analytics------------
-- *per item
local item, itemSpeed, itemHint, itemTries

-- *per game
local pauseCtr

------- Load DB ---------
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )   

------- Load sounds ---------
local incorrectSound = audio.loadSound("music/incorrect.mp3")
local correctSound = audio.loadSound("music/correct.mp3")
local firstGameMusic = audio.loadSound("music/FirstGame.mp3")
local game1MusicChannel

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

--------- FUNCTIONS FOR DATABASE ------------
--DB: fetch
function fetchByCategory(categ)
	local words = {}
	for row in db:nrows("SELECT * FROM Words where firstGameCategory ='"..categ.."'") do
		local rowData = row.id .. " " .. row.name.." "..row.firstGameCategory.." "..row.isCorrect.."\n"
        words[#words+1] = rowData
	end
	return words
end

--DB: update if word was guessed
function updateDB(word)
	for row in db:nrows("UPDATE Words SET isCorrect ='true' where name ='"..word.."'") do
	end
end

--DB: insert to first game
function insertToDB(category, score, name, timestamp, pausectr)
	local insertQuery = [[INSERT INTO FirstGame VALUES (NULL, ']] .. 
	category .. [[',']] ..
	score .. [[',']] ..
	name .. [[',']] ..
	timestamp .. [[',']] ..
	pausectr .. [[');]]
	db:exec(insertQuery)

	--NEW
	for row in db:nrows("SELECT id FROM FirstGame") do
		id = row.id
	end
	return id
end

--NEW
function insertAnalyticsToDB(gameid, roundid, speed, hintctr, triesctr, word)
	if tonumber(triesctr) > 0 then
		local query = [[INSERT INTO FirstGameAnalytics VALUES (NULL, ']] .. 
		gameid .. [[',']] ..
		roundid .. [[',']] ..
		speed .. [[',']] ..
		hintctr .. [[',']] ..
		triesctr .. [[',']] ..
		word .. [[');]]
		db:exec(query)
	end
end
--

--DB: reset all words to un-guessed
function resetDB()
	for row in db:nrows("UPDATE Words SET isCorrect ='false'") do
	end
end

--DB:close
function onSystemEvent( event )
	if event.type == "applicationExit" then
		if db and db:isopen() then
			db:close()
		end
	end
end
Runtime:addEventListener( "system", onSystemEvent )

--DB: check if a word has been answered correctly
function hasBeenAnswered(wordToGuess)
	local rowData
	for row in db:nrows("SELECT * FROM Words WHERE name = '"..wordToGuess.."'") do
		rowData = row.isCorrect
	end
	return rowData
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

------- GET WORD FROM DB ---------
function getwordfromDB()
	local words = fetchByCategory(category)
--	for i=1,#words do print("DB:"..words[i]) end

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

	print(wordToGuess)
	--analytics
	item[currScore+1] = word


	
end

------- FUNCTION FOR SETTING THE WORD --------------
function setword()

	getwordfromDB()
--	print("String length: " .. word:len())
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

--	print("Word to guess: " .. wordToGuess)
	-- ---------------------

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

	-- SHUFFLE -------------
	for i = letterbox:len(), 2, -1 do -- backwards
		local r = math.random(i) -- select a random number between 1 and i
		letterbox = swap_char(i, r, letterbox) -- swap the randomly selected item to position i
	end  
	-- ---------------------

--	print("Letterbox: " .. letterbox)
	-- ---------------------
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
		---------- BOUNDARIES ----------
		
		for i = 1, wordToGuess:len() do
			if ( get_char(i, wordToGuess) == "_" ) then
				local s = "_" .. get_char(i, word)
				distX = math.abs(t.x - wordGroup[s].x);
				distY = math.abs(t.y - wordGroup[s].y);
				if (distX <= 10) and (distY <= 10) then
					t.x = wordGroup[s].x;
					t.y = wordGroup[s].y;
				end
			end
		end
	end
end

------- FUNCTION FOR CHECKING ANSWER --------------
local checkanswer = function(event)
	-- check the word
	-- if right, add score and then,

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
  	  	--analytics
	  	itemTries[currScore+1] = itemTries[currScore+1] + 1

		if answer == word and count == blanks then
			audio.pause(game1MusicChannel)
			audio.play(correctSound)
			boolFirst = false
--			print("Correct!")
			updateDB(word) --set isCorrect to true
			currScore = currScore + 1
--			print("New score: "..currScore)
--			print(timer:getElapsedSeconds())

			-- ANALYTICS PER ITEM
			print("\n\n***ANALYTICS PER ITEM*** ")
			itemSpeed[currScore] = timer:getElapsedSeconds()
			print("WORD: "..item[currScore])
			print("speed: " .. itemSpeed[currScore])
			print("hint: " .. itemHint[currScore])
			print("tries: " .. itemTries[currScore])
			print("\n\n")

			option = {
				time = 400,
				params = {
					categ = category,
					first = boolFirst,
					time = currTime - timer:getElapsedSeconds(),
					score = currScore,
					music = game1MusicChannel,
					--analytics
					speed = itemSpeed,
					pause = pauseCtr,
					itemWord = item,
					tries = itemTries,
					hint = itemHint,
				}
			}

			timerText:removeSelf()
			timer = nil
			storyboard.removeScene("reload")
			storyboard.gotoScene("reload", option)
		else
--			print("wrong!")
			--To play the sound effect, call this whenever you want to play it
			-- new: wrong toast
			toast2.new("", 500)
			audio.play(incorrectSound)
		end
	end
end

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	if(event.phase == "ended") then
		gameovergroup.isVisible = false
  		storyboard.removeScene("firstgame")
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

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function emaildialogue(event)
	if(event.phase == "ended") then
		gameovergroup.isVisible = false
  		storyboard.removeScene("firstgame")
  		storyboard.removeScene("emaildialogue")

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
		storyboard.gotoScene("emaildialogue", option)
  		return true
  	end
end

--------- FUNCTION FOR GAME OVER SPRITE LISTENER ---------
local function spriteListener( event )
--    print(event.phase)
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
	   	emailBtn:addEventListener("touch", emaildialogue)
	    gameovergroup:insert(emailBtn)
	    local emailtext = display.newText("EMAIL RESULTS", 165, display.contentCenterY + 50, font, 25) 
	    gameovergroup:insert(emailtext)


	 end
end

function queryAnalytics(gamectr, column, value)
	result = ""
	ctr = 0
	for row in db:nrows("SELECT * FROM FirstGameAnalytics WHERE gamenumber = '" ..gamectr.. "' and " .. column .. "= '" .. value .. "'") do
		if ctr == 0 then
			result = row.word
		else
			result = result .. ", " .. row.word
		end
		ctr = ctr + 1
	end
	return result
end

function generateReport()
	gamenumber = {} roundnumber = {} speed = {} hint = {} tries = {} words = {}
	local report = ""
	for row in db:nrows("SELECT * FROM FirstGameAnalytics") do
		gamenumber[#gamenumber+1] = row.gamenumber
		roundnumber[#roundnumber+1] = row.roundnumber
		speed[#speed+1] = row.speed
		hint[#hint+1] = row.hintcount
		tries[#tries+1] = row.triescount
		words[#words+1] = row.word
	end

	first = gamenumber[1]
	last = gamenumber[#gamenumber]

	for i = first, last do
	--- PER GAME
		print("GAME# " .. i)
		report = report .. "GAME# " .. i .. "\n"
		for row in db:nrows("SELECT * FROM FirstGame where id = '" .. i .. "'") do
			finalscore = row.score
			print("Player:\t\t" .. row.name .. "\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score .. "\n")
			report = report .. "\nPlayer:\t\t" .. row.name .. "\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score
		end

		if tonumber(finalscore) > 0 then
			report = report .. "\n"
			--NEW
			--By Speed
			for row in db:nrows("SELECT speed FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' ORDER BY speed DESC") do
				maxVal = row.speed
				break
			end
			for row in db:nrows("SELECT speed FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' ORDER BY speed") do
				minVal = row.speed
				break
			end
			if maxVal ~= minVal then
				max = queryAnalytics(i, "speed", maxVal)
				report = report .. "Longest Time:\t"..max.." ("..maxVal.." seconds)\n"
				print("Longest Time:\t"..max.." ("..maxVal.." seconds)")
				min = queryAnalytics(i, "speed", minVal)
				print("Shortest Time:\t"..min.." ("..minVal.. " seconds)")
				report = report .. "Shortest Time:\t"..min.." ("..minVal.. " seconds)\n"
			end

			--By Hints
			for row in db:nrows("SELECT * FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' ORDER BY hintcount DESC") do
				maxVal = row.hintcount
				break
			end
			for row in db:nrows("SELECT * FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' ORDER BY hintcount") do
				minVal = row.hintcount
				break
			end
			if maxVal ~= minVal then
				max = queryAnalytics(i, "hintcount", maxVal)
				print("Most hints:\t"..max.." (" ..maxVal.." time/s)")
				report = report .. "Most hints:\t"..max.." (" ..maxVal.." time/s)\n"
				min = queryAnalytics(i, "hintcount", minVal)
				print("Least hints:\t"..min.." ("..minVal.." time/s)")
				report = report .. "Least hints:\t"..min.." ("..minVal.." time/s)\n"
			end

			--By Tries
			for row in db:nrows("SELECT * FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' ORDER BY triescount DESC") do
				maxVal = row.triescount
				break
			end
			for row in db:nrows("SELECT * FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' ORDER BY triescount") do
				minVal = row.triescount
				break
			end
			if maxVal ~= minVal then
				max = queryAnalytics(i, "triescount", maxVal)
				print("Most mistaken:\t"..max.." ("..maxVal.." attempt/s)")
				report = report .. "Most mistaken:\t"..max.." ("..maxVal.." attempt/s)\n"
				min = queryAnalytics(i, "triescount", minVal)
				print("Least mistaken:\t"..min.." ("..minVal.." attempt/s)")
				report = report .. "Least mistaken:\t"..min.." ("..minVal.." attempt/s)\n"
			end

		--PER WORD
			print("\nPER ITEM ANALYSIS:")
			print("\nWORD\tSPEED\tHINTS\tTRIES")
			report = report .. "\nPER ITEM ANALYSIS:"
			report = report .. "\nWORD\tSPEED\tHINTS\tTRIES\n"
			for j = 1, #roundnumber do
				-- per item
				if tonumber(gamenumber[j]) == i then
					print(words[j] .. "\t" .. speed[j] .. "\t" .. hint[j] .. "\t" .. tries[j])
					report = report .. words[j] .. "\t" .. speed[j] .. "\t" .. hint[j] .. "\t" .. tries[j].."\n"
				end
			end
			report = report .. "\n"
		end

		print("-------------------------------------------------------------\n\n")
		report = report .. "-------------------------------------------------------------\n"

	end

	-- Save to file
	local path = system.pathForFile( "Game 1 Analytics.txt", system.ResourceDirectory )
	local file = io.open( path, "w" )
	file:write( report )
	io.close( file )
	file = nil
end

--------------- FUNCTION FOR END OF GAME ----------------
function gameoverdialog()

	-- SCORING: Timestamp
	local date = os.date( "*t" )
	local timeStamp = date.month .. "-" .. date.day .. "-" .. date.year .. " ; " .. date.hour .. ":" .. date.min
	print( "time"..timeStamp )
	id = insertToDB(category, currScore, profileName, timeStamp, pauseCtr) 	--NEW

	--

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

	--- GAME ANALYTICS ---
	for i = 1, #item do
		print(id.." "..i.." "..itemSpeed[i].." "..itemHint[i].. " "..itemTries[i] .. " "..item[i])
		insertAnalyticsToDB(id, i, itemSpeed[i], itemHint[i], itemTries[i], item[i]) 	--NEW
	end

	generateReport() -- NEW

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

---------------- new: CLEAR ---------------------------
function clear(event)
	local newx = origx
	local newy = origy

	for i = 1, #letterbox do
		if(i == 6) then
			newx = (display.viewableContentWidth/2) + 65
			newy = newy + 40
		else
			newx = newx + 40
		end
		letterboxGroup[i].x = newx 
		letterboxGroup[i].y = newy
		MultiTouch.activate(chalkLetter, "move", "single")
		chalkLetter:addEventListener(MultiTouch.MULTITOUCH_EVENT, objectDrag);
	end
end

---------------- UNMUTE GAME ---------------------------
function unmuteGame(event)
	audio.resume(game1MusicChannel)
	unmuteBtn.isVisible = false
	muteBtn.isVisible = true
	muteBtn.isVisible = true
	muted = 0
--	print("unmuteGame " .. muted)
end

---------------- MUTE GAME ---------------------------
function muteGame(event)
	audio.pause(game1MusicChannel)
	muteBtn.isVisible = false
	unmuteBtn.isVisible = true
	muted = 1
end

---------------- PAUSE GAME ---------------------------
function pauseGame(event)
    if(event.phase == "ended") then
       	pauseCtr = pauseCtr + 1 --NEW
    	timer:pause()
    	audio.pause(game1MusicChannel)
    	submit:setEnabled(false)
   		for i = 1, #letterbox do
			MultiTouch.deactivate(letterboxGroup[i])
		end
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
			score = 0,
			--analytics
			speed = itemSpeed,
			pause = pauseCtr,
			itemWord = item,
			tries = itemTries,
			hint = itemHint,
		}
	}
	audio.stop()
	storyboard.removeScene("reload")
	storyboard.gotoScene("reload", option)
end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
	pausegroup:removeSelf()
	if (muted == 0) then 
		audio.resume(game1MusicChannel)
	end
	timer:resume()
	submit:setEnabled(true)
	for i = 1, #letterbox do
		MultiTouch.activate(letterboxGroup[i], "move", "single")
	end
    pauseBtn.isVisible = true
	return true
end

---------------- EXIT FROM PAUSE ----------------
function exit_onBtnRelease()
	pausegroup:removeSelf()
	timerText:removeSelf()
	timer = nil
	storyboard.removeScene("firstgame")
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

local function networkListener( event )
	local speech = audio.loadSound( word..".mp3", system.TemporaryDirectory )

	if speech == nil then
--		print("ERROR!")
		toast.new("Device must be connected\nto the internet!", 3000)
	else
	   	audio.play( speech )
	end

end

function play()
	itemHint[currScore+1] = itemHint[currScore+1] + 1
	network.download( "http://www.translate.google.com/translate_tts?tl=en&q='"..word.."'", "GET", networkListener, word..".mp3", system.TemporaryDirectory )	
end

------------------CREATE SCENE: MAIN -----------------------------
function scene:createScene(event)
	--get passed parameters from previous scene

	muted = 0
	boolFirst = event.params.first
	category = event.params.categ
	currScore = event.params.score
	currTime = event.params.time
	profileName = "Cha" --temp

	-- analytics
	item = {}
	itemTries = {0}
	itemHint = {0}
	itemSpeed = {}

	-- Start timer
	timer = stopwatch.new(currTime)
	if (boolFirst) then
		game1MusicChannel = audio.play( firstGameMusic, { loops=-1}  )
		resetDB()
		-- analytics
		itemSpeed[1] = 0
		item[1] = ""
		itemTries[1] = 0
		itemHint[1] = 0
		pauseCtr = 0
	else
		game1MusicChannel = event.params.music
		audio.resume(game1MusicChannel)
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

	screenGroup = self.view
	setword()

	-- Screen Elements
	--score
	scoreToDisplay = display.newText("Score: "..currScore, 0, 25, font, 18 )	
	
	--blackboard
	bg = display.newImageRect("images/firstgame/board.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	--checkbutton
	submit = widget.newButton{
		id = "submit",
		defaultFile = "images/firstgame/submit_button.png",
		fontSize = 15,
		emboss = true,
		onEvent = checkanswer,
	}
	submit.x = 453; submit.y = 180
	screenGroup:insert(submit)
	
	--picture of word
	image = display.newImage( "images/firstgame/pictures/"..word..".png" )
	if image == nil then
		image = display.newImage( "images/firstgame/pictures/blank.png" )
	end

	image.x = 310/2; image.y = 260/2;

	-- hint
	hintBtn = widget.newButton{
		id = "hint",
		defaultFile = "images/firstgame/hint_button.png",
		fontSize = 15,
		emboss = true,
	}
	hintBtn.x = 400; hintBtn.y = 180
	screenGroup:insert(hintBtn)
	hintBtn:addEventListener("tap", play)


	--pause button
	pauseBtn = display.newImageRect( "images/firstgame/pause.png", 20, 20)
    pauseBtn.x = 410
    pauseBtn.y = 37
    pauseBtn:addEventListener("touch", pauseGame)
    pauseBtn:addEventListener("tap", pauseGame)
    screenGroup:insert( pauseBtn )

    --mute button
    unmuteBtn = display.newImageRect( "images/firstgame/mute_button.png", 20, 20)
    unmuteBtn.x = 380
    unmuteBtn.y = 37
    unmuteBtn.isVisible = false
	unmuteBtn:addEventListener("touch", unmuteGame)
    unmuteBtn:addEventListener("tap", unmuteGame)
    screenGroup:insert( unmuteBtn )

	muteBtn = display.newImageRect( "images/firstgame/unmute_button.png", 20, 20)
    muteBtn.x = 380
    muteBtn.y = 37
    muteBtn:addEventListener("touch", muteGame)
    muteBtn:addEventListener("tap", muteGame)
    screenGroup:insert( muteBtn )
	
	-- letters
	local x = -20
	local y = 260
	wordGroup = display.newGroup()
	local a = 1
	for i = 1, #wordToGuess do
		local c = get_char(i, wordToGuess)

		local filename = "images/firstgame/"
		if (c == "_") then
			filename = filename .. "newblank.png"
			chalkLetter = display.newImage(filename)
		else
--			filename = filename .. c .. ".png"
			chalkLetter = display.newText( c:upper(), x, y, font, 35)
		end		

--		chalkLetter = display.newText( c:upper(), x, y, font, 45)
		wordGroup:insert(chalkLetter)
		if (c == "_") then
			c = c .. get_char(i, word)
		end
		wordGroup[c] = chalkLetter
		x = x + 50
		chalkLetter.x = x 
		chalkLetter.y = y
	end

	--new: clear button
	clearBtn = display.newImageRect( "images/firstgame/clear.png", 50, 50)
    clearBtn.x = x + 55
    clearBtn.y = y
    clearBtn:addEventListener("touch", clear)
    clearBtn:addEventListener("tap", clear)
    screenGroup:insert( clearBtn )
	
	--letters to fill up with
	x = (display.viewableContentWidth/2) + 25
	y = (display.viewableContentHeight/2) - 80
	letterboxGroup = display.newGroup()
	origx = x
	origy = y


	for i = 1, #letterbox do
		local c = get_char(i, letterbox)
		chalkLetter = display.newText( c:upper(), x, y, font, 35)
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
		MultiTouch.activate(chalkLetter, "move", "single")
		chalkLetter:addEventListener(MultiTouch.MULTITOUCH_EVENT, objectDrag);
	end

	--- add to screen
	screenGroup:insert(image)
	screenGroup:insert(wordGroup)
	screenGroup:insert(letterboxGroup)
	screenGroup:insert(scoreToDisplay)
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