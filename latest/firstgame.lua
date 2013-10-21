MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local timer = require("timer")
local scene = storyboard.newScene()

------- Global variables ---------
local word, wordGroup, wordToGuess, letterbox, letterboxGroup
local wordFromDB, category
local boolFirst
local db = sqlite3.open("javami_DB.sqlite3")
local gameTimer, text, maxTime
local currScore, option, screenGroup

--load your sound effect near the beginning of your file
local mySoundEffect = audio.loadSound("incorrect.mp3")

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
	print("SELECT * FROM Words where category =" ..categ)
	local words = {}
	for row in db:nrows("SELECT * FROM Words where category ='"..categ.."'") do
		local rowData = row.id .. " " .. row.name.." "..row.category.." "..row.isCorrect.."\n"
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
		if i == 10 then -- change to kung ilan words sa DB
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
			print("char at rand: " .. get_char(rand, wordToGuess))
			print("curr letterbox: " .. letterbox)
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
	for i = 1, wordToGuess:len() do
		if ( get_char(i, wordToGuess) ~= "_" ) then -- not blank
			answer = answer .. get_char(i, wordToGuess)
		else
			for j = 1, letterbox:len() do
				if ( get_char(i, word) == get_char(j, letterbox) ) then -- if same letter, dapat same pos
					local s = "_" .. get_char(i, word)
					distX = math.abs(letterboxGroup[get_char(j, letterbox)].x - wordGroup[s].x)
					distY = math.abs(letterboxGroup[get_char(j, letterbox)].y - wordGroup[s].y)
					if (distX <= 10) and (distY <= 10) then
						-- if nasa blank
						answer = answer .. get_char(j, letterbox)
						-- print("nasa for ng blank " .. s .. ": " .. answer)
					end
				end
			end
		end
	end

  	if event.phase == "ended" then
		if answer == word then
			boolFirst = false
			print("Correct!")
			updateDB(word) --set isCorrect to true
			currScore = currScore + 1
			print("New score: "..currScore)
			option = {
				effect = "fade",
				time = 400,
				params = {
					categ = category,
					first = boolFirst,
					time = gameTimer,
					score = currScore,
				}
			}
			storyboard.removeScene("reload")
			storyboard.gotoScene("reload", option)
		else
			print("wrong!")
			--To play the sound effect, call this whenever you want to play it
			audio.play(mySoundEffect)
		end
	end
end

-- IM COMING HOME
local backToMenu = function(event)
	back:removeSelf()
	timesup:removeSelf()
	round:removeSelf()
	scoreToDisplay:removeSelf()
  	text:removeSelf()
  	storyboard.gotoScene("mainmenu", "fade", 400)
end


function _destroyDialog()
	wordGroup:removeSelf()
	letterboxGroup:removeSelf()
	image:removeSelf()
	scoreToDisplay:removeSelf()
	submit:removeSelf()

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


-- TIMER
text = display.newText( "0:00", 420, 10, font, 30 )
function text:timer( event )
		
	local count = event.count
	self.text = count
 
 	if (count % 60 < 10) then self.text = math.floor(count/60) .. ":0" .. (count%60)
 	else self.text = math.floor(count/60) .. ":" .. (count%60)
 	end
	if count % maxTime == 0 then
		timer.cancel( event.source )
		_destroyDialog()
		print("TIME'S UP!")
	end

end

function scene:createScene(event)
	--get passed parameters from previous scene
	gameTimer = event.params.time
	boolFirst = event.params.first
	category = event.params.categ
	if category == 'easy' then
		maxTime = 60
	elseif category == 'medium' then
		maxTime = 120
	elseif category == 'hard' then
		maxTime = 180
	end
--	maxTime = event.params.time

   	print( "CATEGORY:"..category )
	print( "MAXTIME:"..maxTime )

   	-- TIMER & SCORE
	local timeDelay = 1000;
	if boolFirst == true then
		resetDB() --reset all words to un-answered bawat reload
		text.text = "0:00"
		gameTimer = timer.performWithDelay( timeDelay, text, maxTime )	-- maintain time kahit magreload na
		currScore = 0
	else
		currScore = event.params.score
		text:removeSelf()
	end

	-- Display score
	scoreToDisplay = display.newText("Score: "..currScore, 5, 20, font, 30 )

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

	image = display.newImage( "images/firstgame/pictures/" .. word .. ".png" )
	image.x = 310/2; image.y = 260/2;
	
	-- DISPLAY LETTERS -----
	local x = -40
	local y = 270
	wordGroup = display.newGroup()
	local a = 1
	for i = 1, #wordToGuess do
		local c = get_char(i, wordToGuess)
		local chalkLetter = display.newText( c:upper(), x, y, font, 50)
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
	x = 320
	y = 90
	letterboxGroup = display.newGroup()


	for i = 1, #letterbox do
		local c = get_char(i, letterbox)
		local chalkLetter = display.newText( c:upper(), x, y, font, 50)
		letterboxGroup:insert(i, chalkLetter)
		letterboxGroup[c] = chalkLetter
		if (x - 330 < 120) then
			x = x + 40
		else
			y = y + 50
			x = 370
		end
		letterboxGroup[i].x = x 
		chalkLetter.y = y
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