------- Requirements ---------
MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local physics = require("physics")
local lfs = require("lfs")
local stopwatch =require "stopwatch"
local scene = storyboard.newScene()

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

------- Load DB ---------
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )   

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

--------- FUNCTIONS FOR DATABASE ------------
--DB: fetch
function fetchByCategory(categ)
	print("SELECT * FROM Words where category =" ..categ)
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
function insertToDB(category, score)
	local insertQuery = [[INSERT INTO FirstGame VALUES (NULL, ']] .. 
	category .. [[',']] ..
	score .. [['); ]]
	db:exec(insertQuery)
end

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
	print("PASSED VARIABLE:"..category)
	local words = fetchByCategory(category)
	for i=1,#words do
		print("DB:"..words[i]) 
	end

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
	
end

------- FUNCTION FOR SETTING THE WORD --------------
function setword()

	getwordfromDB()
	print("String length: " .. word:len())
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

	print("Word to guess: " .. wordToGuess)
	-- ---------------------

	-- GET LETTERBOX -------
	for i = 1,word:len()-2 do
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

	print("Letterbox: " .. letterbox)
	-- ---------------------
end

------------ FUNCTION FOR OBJECT DRAG --------------------
local function objectDrag (event)
	local distX, distY
	local t = event.target
	if event.phase == "moved" or event.phase == "ended" then
		for i = 1, wordToGuess:len() do
			if ( get_char(i, wordToGuess) == "_" ) then
				local s = "_" .. get_char(i, word)
				distX = math.abs(event.target.x - wordGroup[s].x);
				distY = math.abs(event.target.y - wordGroup[s].y);
				if (distX <= 10) and (distY <= 10) then
					event.target.x = wordGroup[s].x;
					event.target.y = wordGroup[s].y;
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
		if answer == word and count == blanks then
			boolFirst = false
			print("Correct!")
			updateDB(word) --set isCorrect to true
			currScore = currScore + 1
			print("New score: "..currScore)
			print(timer:getElapsedSeconds())
			option = {
				time = 400,
				params = {
					categ = category,
					first = boolFirst,
					time = currTime - timer:getElapsedSeconds(),
					score = currScore
				}
			}
			timerText:removeSelf()
			timer = nil
			audio.play(correctSound)
			storyboard.removeScene("reload")
			storyboard.gotoScene("reload", option)
		else
			print("wrong!")
			--To play the sound effect, call this whenever you want to play it
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

	insertToDB(category, currScore)
	timerText:removeSelf()
	timer = nil

	scoreToDisplay.isVisible = false
	image.isVisible = false
	letterboxGroup.isVisible = false
	wordGroup.isVisible = false
	submit.isVisible = false
	pauseBtn.isVisible = false
	hintBtn.isVisible = false

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
			score = 0
		}
	}
	storyboard.removeScene("reload")
	storyboard.gotoScene("reload", option)
end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
	pausegroup:removeSelf()
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
	boolFirst = event.params.first
	category = event.params.categ
	currScore = event.params.score
	currTime = event.params.time

	-- Start timer
	timer = stopwatch.new(currTime)
	if (boolFirst) then
		resetDB()
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
	submit.x = 453; submit.y = 262
	screenGroup:insert(submit)
	
	--picture of word
	image = display.newImage( "images/firstgame/pictures/apple.png" )
	image.x = 310/2; image.y = 260/2;

	-- hint
	hintBtn = widget.newButton{
		id = "hint",
		defaultFile = "images/firstgame/play_button.png",
		fontSize = 15,
		emboss = true,
	}
	hintBtn.x = 453; hintBtn.y = 200
	screenGroup:insert(hintBtn)
	hintBtn:addEventListener("tap", play)

	--pause button
	pauseBtn = display.newImageRect( "images/firstgame/pause.png", 20, 20)
    pauseBtn.x = 410
    pauseBtn.y = 37
    pauseBtn:addEventListener("touch", pauseGame)
    pauseBtn:addEventListener("tap", pauseGame)
    screenGroup:insert( pauseBtn )
	
	-- letters
	local x = -20
	local y = 260
	wordGroup = display.newGroup()
	local a = 1
	for i = 1, #wordToGuess do
		local c = get_char(i, wordToGuess)
		chalkLetter = display.newText( c:upper(), x, y, font, 45)
		wordGroup:insert(chalkLetter)
		if (c == "_") then
			c = c .. get_char(i, word)
		end
		wordGroup[c] = chalkLetter
		x = x + 50
		chalkLetter.x = x 
		chalkLetter.y = y
	end
	
	--letters to fill up with
	x = 270
	y = 90
	letterboxGroup = display.newGroup()


	for i = 1, #letterbox do
		local c = get_char(i, letterbox)
		chalkLetter = display.newText( c:upper(), x, y, font, 45)
		letterboxGroup:insert(i, chalkLetter)
		letterboxGroup[c] = chalkLetter
		if (x - 330 < 120) then
			x = x + 45
		else
			y = y + 50
			x = 320
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