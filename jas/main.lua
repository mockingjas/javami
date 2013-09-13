MultiTouch = require("dmc_multitouch");

-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local widget = require("widget")
local bg = display.newImage( "images2/bg4.png" )
bg.width = display.contentWidth;
bg.height = display.contentHeight;
bg.x = display.contentWidth/2;
bg.y = display.contentHeight/2;

local word = "apple"
local wordToGuess = word
local apple = display.newImage( "images2/" .. word .. ".png" )
apple.x = 60; apple.y = 150;

print("String length: " .. word:len())

local blanks = math.floor(word:len()/2)

print("Blanks: " .. blanks)


-- FUNCTION ------------
-- position in string to be replaced with ch
function replace_char (pos, str, ch)
	if (pos == 1) then return ch .. str:sub(pos+1)
	elseif (pos == str:len()) then return str:sub(1, str:len()-1) .. ch
	else return str:sub(1, pos-1) .. ch .. str:sub(pos+1)
	end
end

function get_char (pos, str)
	return str:sub(pos, pos)
end
-- ---------------------

local letterbox = ""
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

-- FUNCTION ------------
function swap_char (pos1, pos2, str)
	local temp1 = get_char(pos1, str)
	local temp2 = get_char(pos2, str)
	str = replace_char(pos1, str, temp2)
	str = replace_char(pos2, str, temp1)
	return str
end
-- ---------------------

-- SHUFFLE -------------
for i = letterbox:len(), 2, -1 do -- backwards
	local r = math.random(i) -- select a random number between 1 and i
	letterbox = swap_char(i, r, letterbox) -- swap the randomly selected item to position i
end  
-- ---------------------

print("Letterbox: " .. letterbox)
-- ---------------------

-- DISPLAY LETTERS -----
local x = 100
local y = 150
local wordGroup = display.newGroup()
-- local a = 1
for i = 1, #wordToGuess do
	local c = get_char(i, wordToGuess)
	local filename = "images2"
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
		-- c = c .. a
		-- a = a + 1
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
local letterboxGroup = display.newGroup()

for i = 1, #letterbox do
	local c = get_char(i, letterbox)
	local filename = "images2"
	filename = filename .. "/" .. c .. ".png"
	-- print(filename)
	local letter = display.newImage(filename)
	letterboxGroup:insert(letter)
	letterboxGroup[c] = letter
	x = x + 60
	letter.x = x 
	letter.y = y
	MultiTouch.activate(letter, "move", "single");


	-- OBJECT DRAG ---------
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
	-- ---------------------


	letter:addEventListener(MultiTouch.MULTITOUCH_EVENT, objectDrag);
end

local submitted = false
local answer = ""
-- ADD SUBMIT BUTTON ---
local submitHandler = function( event )
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
	print(answer)
	if (answer == word) then
		print("correct!")
	end
end

local submitButton = widget.newButton
{
	id = "submitButton",
	defaultFile = "images2/button.png",
	overFile = "images2/button_over.png",
	label = "Submit",
	font = native.systemFontBold,
	fontSize = 22,
	emboss = true,
	onRelease = submitHandler,
}
-- ---------------------