------- Requirements ---------
MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local timer = require("timer")
local physics = require("physics")
local lfs = require("lfs")
local scene = storyboard.newScene()

------- Global variables ---------
local word, wordGroup, wordToGuess, letterbox, letterboxGroup, chalkLetter, letterbox
local wordFromDB, category, submit
local boolFirst
local timerID, timerText, maxTime, timeDelay
local currScore, option, screenGroup

local pausedialog, resumeBtn, restartBtn, exitBtn
local currTime, pauseBtn

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
    font = "Eraser"
else
    -- Mac and iOS
    font = "Eraser-Regular"
end

--------- FUNCTIONS FOR DATABASE ------------
--DB: fetch
function fetchByCategory(categ)
--	print("SELECT * FROM Words where category =" ..categ)
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
			option = {
				time = 400,
				params = {
					categ = category,
					first = boolFirst,
					timeID = timerID,
					timeText = currTime,
					score = currScore,
				}
			}
			audio.play(correctSound)
			timerText:removeSelf()
			storyboard.removeScene("reload")
			storyboard.gotoScene("reload", option)
		else
			print("wrong!")
			--To play the sound effect, call this whenever you want to play it
			audio.play(incorrectSound)
		end
	end
end

--------------  FUNCTION FOR HOME --------------------
function backToMenu ()
	back:removeSelf()
	timesup:removeSelf()
	round:removeSelf()
	scoreToDisplay:removeSelf()
  	storyboard.removeScene("firstgame")
  	storyboard.removeScene("mainmenu")
  	storyboard.gotoScene("mainmenu", "fade", 400)
end

--------------- FUNCTION FOR END OF GAME ----------------
function gameover()
	wordGroup:removeSelf()
	letterboxGroup:removeSelf()
	image:removeSelf()
	scoreToDisplay:removeSelf()
	submit:removeSelf()
	pauseBtn:removeSelf()

	-- Stuff to display when time's up
	timesup= display.newText("TIME'S UP!", 0, 0, font, 30)
	timesup.x = display.contentCenterX
	timesup.y = display.contentCenterY - 10
	timesup:setTextColor(255, 255, 255, 255)

	round= display.newText("ROUND: "..category, 0, 0, font, 20)
	round.x = display.contentCenterX
	round.y = display.contentCenterY + 20

	scoreToDisplay= display.newText("SCORE: "..currScore, 0, 0, font, 20)
	scoreToDisplay.x = display.contentCenterX
	scoreToDisplay.y = display.contentCenterY + 40

	back = widget.newButton{
		id = "home",
		defaultFile = "images/firstgame/button_small.png",
		label = "HOME",
		fontSize = 15,
		emboss = true,
		onEvent = backToMenu,
	}
	back.x = 460; back.y = 280
	insertToDB(category, currScore)
	--
end
---------------- PAUSE GAME ---------------------------
function pauseGame(event)
    if(event.phase == "ended") then
    	timer.pause(timerID)
    	submit:setEnabled(false)
   		for i = 1, #letterbox do
			MultiTouch.deactivate(letterboxGroup[i])
		end
        pauseBtn.isVisible = false
        pause()
        return true
    end
end
 
function pause()
	function _destroyDialog()
		pausedialog:removeSelf()
		restartBtn:removeSelf()
		resumeBtn:removeSelf()
		exitBtn:removeSelf()
	end

	function restart_onBtnRelease()
		_destroyDialog()
		timerText:removeSelf()
		option = {
			time = 400,
			params = {
				categ = category,
				first = true,
				timeText = maxTime,
				score = 0,
			}
		}
		storyboard.removeScene("reload")
		storyboard.gotoScene("reload", option)
	end

	function resume_onBtnRelease()
		_destroyDialog()
		timer.resume(timerID)
		submit:setEnabled(true)
		for i = 1, #letterbox do
			MultiTouch.activate(letterboxGroup[i], "move", "single")
		end
        pauseBtn.isVisible = true
		return true
	end


	function exit_onBtnRelease()
		_destroyDialog()
		timerText:removeSelf()
		storyboard.removeScene("firstgame")
  		storyboard.removeScene("mainmenu")
  		storyboard.gotoScene("mainmenu")
	end
	showpauseDialog()
end

function showpauseDialog()

	pausedialog = display.newImage("images/pause/pause_modal.png")
 	pausedialog.x = display.contentWidth/2;
 	pausedialog:addEventListener("touch", function() return true end)
	pausedialog:addEventListener("tap", function() return true end)

	resumeBtn = widget.newButton{
		defaultFile="images/pause/resume_button.png",
		overFile="images/pause/resume_button.png",
		onEvent = resume_onBtnRelease -- event listener function
	}
	resumeBtn:setReferencePoint( display.CenterReferencePoint )
	resumeBtn.x = bg.x - 100
	resumeBtn.y = 170

	restartBtn = widget.newButton{
		defaultFile="images/pause/restart_button.png",
		overFile="images/pause/restart_button.png",
		onEvent = restart_onBtnRelease -- event listener function
	}
	restartBtn:setReferencePoint( display.CenterReferencePoint )
	restartBtn.x = bg.x + 100
	restartBtn.y = 170

	exitBtn = widget.newButton{
		defaultFile="images/pause/exit_button.png",
		overFile="images/pause/exit_button.png",
		onEvent = exit_onBtnRelease -- event listener function
	}
	exitBtn:setReferencePoint( display.CenterReferencePoint )
	exitBtn.x = bg.x + 5
	exitBtn.y = 220
end

-------------------------------------------------------------------

function scene:createScene(event)

	--get passed parameters from previous scene
	timerID = event.params.timeID
	boolFirst = event.params.first
	category = event.params.categ

	if category == 'easy' then
		maxTime = 60
	elseif category == 'medium' then
		maxTime = 120
	elseif category == 'hard' then
		maxTime = 180
	end

	--------------- FUNCTION FOR TIMER --------------
	timerText = display.newText( "0:00", 440, 20, font, 20 )
	function timerText:timer( event )		
	   	currTime = currTime - 1
		if (currTime % 60 < 10) then
			timerText.text = math.floor(currTime/60) .. ":0" .. (currTime%60)
		else
			timerText.text = math.floor(currTime/60) .. ":" .. (currTime%60)
		end
	    if(currTime == 0)then
	    	timerText:removeSelf()
			timer.cancel( event.source )
			gameover()
			print("TIME'S UP!")
	    end
	end

   	-- TIMER & SCORE
	timeDelay = 1000
	if boolFirst == true then
		currTime = maxTime
		resetDB() --reset all words to un-answered bawat reload
		timerText.text = maxTime/60 .. ":00"
		currScore = 0
	else
		currTime = event.params.timeText
		currScore = event.params.score
		if (currTime % 60 < 10) then
			timerText.text = math.floor(currTime/60) .. ":0" .. (currTime%60)
		else
			timerText.text = math.floor(currTime/60) .. ":" .. (currTime%60)
		end

--		timerText:removeSelf()
	end
	timerID = timer.performWithDelay( timeDelay, timerText, maxTime )	-- maintain time kahit magreload na

	-- Display score
	scoreToDisplay = display.newText("Score: "..currScore, 0, 20, font, 20 )

	screenGroup = self.view
	setword()

	bg = display.newImageRect("images/firstgame/blackboard.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	submit = widget.newButton{
		id = "submit",
		defaultFile = "images/firstgame/button_small.png",
		label = "OK!",
		fontSize = 15,
		emboss = true,
		onEvent = checkanswer,
	}
	submit.x = 460; submit.y = 280
	screenGroup:insert(submit)

	image = display.newImage( "images/firstgame/pictures/apple.png" )
	image.x = 310/2; image.y = 260/2;

	-- Pause button

	pauseBtn = display.newImageRect( "images/firstgame/pause.png", 20, 20)
    pauseBtn.x = 420
    pauseBtn.y = 30
    pauseBtn:addEventListener("touch", pauseGame)
    screenGroup:insert( pauseBtn )
	
	-- DISPLAY LETTERS -----
	local x = -40
	local y = 270
	wordGroup = display.newGroup()
	local a = 1
	for i = 1, #wordToGuess do
		local c = get_char(i, wordToGuess)
		chalkLetter = display.newText( c:upper(), x, y, font, 50)
		wordGroup:insert(chalkLetter)
		if (c == "_") then
			c = c .. get_char(i, word)
		end
		wordGroup[c] = chalkLetter
		x = x + 55
		chalkLetter.x = x 
		chalkLetter.y = y
	end
	-- ---------------------
	
	-- DISPLAY LETTERBOX ---
	x = 270
	y = 90
	letterboxGroup = display.newGroup()


	for i = 1, #letterbox do
		local c = get_char(i, letterbox)
		chalkLetter = display.newText( c:upper(), x, y, font, 50)
		letterboxGroup:insert(i, chalkLetter)
		letterboxGroup[c] = chalkLetter
		if (x - 330 < 120) then
			x = x + 50
		else
			y = y + 50
			x = 320
		end
		letterboxGroup[i].x = x 
		letterboxGroup[i].y = y
		MultiTouch.activate(chalkLetter, "move", "single")
		chalkLetter:addEventListener(MultiTouch.MULTITOUCH_EVENT, objectDrag);
	end

	screenGroup:insert(wordGroup)
	screenGroup:insert(letterboxGroup)
	screenGroup:insert(image)
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

return scene