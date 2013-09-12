MultiTouch = require("dmc_multitouch");

-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local bg = display.newImage( "bg4.png" )
bg.width = display.contentWidth;
bg.height = display.contentHeight;
bg.x = display.contentWidth/2;
bg.y = display.contentHeight/2;

local apple = display.newImage( "app.png" )
apple.x = 60; apple.y = 150;

local word = "apple"
local word_to_guess = word

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
	local first = 0
	if (string.find(word_to_guess, "_") ~= nil) then
		first = string.find(word_to_guess, "_")
		-- print("1st blank index:" .. first)
	end
	local rand = math.random(word:len())
	-- print("rand: " .. rand .. " first: " .. first)
	while rand == first do
		-- print("while")
		rand = math.random(word:len())
	end
	-- print("blank at index: " .. rand)
	letterbox = letterbox .. get_char(rand, word_to_guess)
	word_to_guess = replace_char(rand, word_to_guess, "_")
end

print("Word to guess: " .. word_to_guess)
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
local word_group = display.newGroup()
local a = 1
for i = 1, #word_to_guess do
    local c = get_char(i, word_to_guess)
    local filename = "images2"
    if (c == "_") then
    	filename = filename .. "/blank.png"
    else
 		filename = filename .. "/" .. c .. ".png"
    end
    --print(filename)
    local letter = display.newImage(filename)
    word_group:insert(letter)
    if (c == "_") then
    	c = c .. a
    	a = a + 1
    end
    word_group[c] = letter
    x = x + 60
    word_group[c].x = x 
    word_group[c].y = y
end
-- ---------------------




-- DISPLAY LETTERBOX ---
x = 100
y = 250
local letterbox_group = display.newGroup()

for i = 1, #letterbox do
    local c = get_char(i, letterbox)
    local filename = "images2"
    filename = filename .. "/" .. c .. ".png"
    -- print(filename)
    local letter = display.newImage(filename)
    letterbox_group:insert(letter)
    letterbox_group[c] = letter
    x = x + 60
    letterbox_group[c].x = x 
    letterbox_group[c].y = y
    MultiTouch.activate(letter, "move", "single");


    -- OBJECT DRAG ---------
	-- User drag interaction on blue circle
	local function objectDrag (event)
		local t = event.target
		-- If user touches & drags circle, follow the user's touch
		if event.phase == "moved" then
		   firstX = event.target.x - word_group["_1"].x; 
		   firstY = event.target.y - word_group["_1"].y;
		   if (firstX < 0) then firstX = firstX * -1; end
		   if (firstY < 0) then firstY = firstY * -1; end
		   -- If user drags circle within 50 pixels of center of outline, snap into middle
		   if (firstX <= 10) and (firstY <= 10) then
		      event.target.x = word_group["_1"].x;
		      event.target.y = word_group["_1"].y;
		   end
		end

		if event.phase == "moved" then
		   circlePosX = event.target.x - word_group["_2"].x; 
		   circlePosY = event.target.y - word_group["_2"].y;
		   if (circlePosX < 0) then circlePosX = circlePosX * -1; end
		   if (circlePosY < 0) then circlePosY = circlePosY * -1; end
		   -- If user drags circle within 50 pixels of center of outline, snap into middle
		   if (circlePosX <= 10) and (circlePosY <= 10) then
		      event.target.x = word_group["_2"].x;
		      event.target.y = word_group["_2"].y;
		   end
		end
	end
	-- ---------------------


    letter:addEventListener(MultiTouch.MULTITOUCH_EVENT, objectDrag);
end
-- ---------------------

--[[
local letterFiles = { A="images2/a.png", B="images2/b.png", C="images2/c.png", D="images2/d.png", E="images2/e.png" }


-- print(letterFiles.A)


for key,file in pairs(letterFiles) do

	local letter = display.newImage( file );
	alphabet:insert(letter);
	alphabet[key] = letter;

end
]]





