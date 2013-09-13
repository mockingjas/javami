MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()

------- Global variables ---------
local word
local wordGroup
local wordToGuess
local letterbox
local letterboxGroup
local wordFromDB
local db = sqlite3.open("JAVAMIADB.sqlite3")

--------- FUNCTIONS FOR STRING MANIPULATIONS ------------
--DB functions
local function fetchByCategory(categ)
	print("SELECT * FROM Words where category =" ..categ)
	local words = {}
	for row in db:nrows("SELECT * FROM Words where category ='"..categ.."'") do
		local rowData = row.id .. " " .. row.name.." "..row.category.." "..row.imageFN.." "..row.audioFN.."\n"
        words[#words+1] = rowData
	end
	return words
end

local function onSystemEvent( event )
	if event.type == "applicationExit" then
		if db and db:isopen() then
			db:close()
		end
	end
end
Runtime:addEventListener( "system", onSystemEvent )

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
	-- Insert function for getting random word from database here
	local category = "easy"
	local words = fetchByCategory(category)	--returns whole row
	for i=1,#words do 
		print("DB:"..words[i]) 
	end

--	print("#of words:"..#words)
	local rand = math.random(#words)
--	print("rand word index:"..rand)	
	print(words[rand])
	
	wordFromDB = {}
	i = 1
	for token in string.gmatch(words[rand], "[^%s]+") do
		wordFromDB[i] = token
		i = i+1
	end
	
	-- 	id = wordFromDB[1]
	--	name = wordFromDB[2]
	--	category = wordFromDB[3]
	--	imageFN = wordFromDB[4]
	--	audioFN = wordFromDB[5]	
	print(wordFromDB[2])
	--word = "apple"
	word = wordFromDB[2]
	wordToGuess = word
	
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
		local letter = string.char(97+rand)
		while (string.find(letterbox, letter) ~= nil) do
			rand = math.random(26)
			letter = string.char(97+rand)
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
	local t = event.target
	if event.phase == "moved" then
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
local checkanswer = function( event )
	-- check the word
	-- if right, add score and then,
	answer = ""
	submitted = true
	print(submitted)
	for i = 1, wordToGuess:len() do
		if ( get_char(i, wordToGuess) ~= "_" ) then -- not blank
			answer = answer .. get_char(i, wordToGuess)
		else
			for j = 1, letterbox:len() do
				if ( get_char(i, word) == get_char(j, letterbox) ) then -- if same letter, dapat same pos
					local s = "_" .. get_char(i, word)
					distX = math.abs(letterboxGroup[get_char(j, letterbox)].x - wordGroup[s].x)
					distY = math.abs(letterboxGroup[get_char(j, letterbox)].y - wordGroup[s].y)
					if (distX < 7) and (distY < 7) then
						-- if nasa blank
						answer = answer .. get_char(j, letterbox)
						-- print("nasa for ng blank " .. s .. ": " .. answer)
					end
				end
			end
		end
	end
	print("answer: " .. answer)
	if (answer == word) then
		print("correct!")
	end
	storyboard.gotoScene("reload", "fade", 400)
end


function scene:createScene(event)

	local screenGroup = self.view
	setword()

	bg = display.newImageRect("blackboard.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	submit = widget.newButton{
		id = "submit",
		defaultFile = "button.png",
		label = "Submit",
		fontSize = 20,
		emboss = true,
		onEvent = checkanswer,
	}

	submit.x = 400; submit.y = 50
	screenGroup:insert(submit)
	
	image = display.newImage( "images/" .. word .. ".png" )
	image.x = 60; image.y = 150;
	
	-- DISPLAY LETTERS -----
	local x = 100
	local y = 150
	wordGroup = display.newGroup()
	local a = 1
	for i = 1, #wordToGuess do
		local c = get_char(i, wordToGuess)
		local filename = "images"
		if (c == "_") then
			filename = filename .. "/blank.png"
		else
			filename = filename .. "/" .. c .. ".png"
		end
		--print(filename)
		local letter = display.newImage(filename)
		wordGroup:insert(letter)
		if (c == "_") then
			c = c .. get_char(i, word)
		end
		wordGroup[c] = letter
		x = x + 60
		letter.x = x 
		letter.y = y
	end
	-- ---------------------
	
	-- DISPLAY LETTERBOX ---
	x = 100
	y = 250
	letterboxGroup = display.newGroup()

	for i = 1, #letterbox do
		local c = get_char(i, letterbox)
		local filename = "images"
		filename = filename .. "/" .. c .. ".png"
		-- print(filename)
		local letter = display.newImage(filename)
		letterboxGroup:insert(letter)
		letterboxGroup[c] = letter
		x = x + 60
		letter.x = x 
		letter.y = y
		MultiTouch.activate(letter, "move", "single")
		letter:addEventListener(MultiTouch.MULTITOUCH_EVENT, objectDrag);
	end
	
	screenGroup:insert(wordGroup)
	screenGroup:insert(letterboxGroup)
	screenGroup:insert(image)
	
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