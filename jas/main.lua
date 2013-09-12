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

for i = 1, #word_to_guess do
    local c = get_char(i, word_to_guess)
    local filename = "images2"
    if (c == "_") then
    	filename = filename .. "/blank.png"
    else
 		filename = filename .. "/" .. c .. ".png"
    end
    print(filename
    	)
    local letter = display.newImage(filename)
    word_group:insert(letter)
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
    if (c == "_") then
    	filename = filename .. "/blank.png"
    else
 		filename = filename .. "/" .. c .. ".png"
    end
    print(filename)
    local letter = display.newImage(filename)
    letterbox_group:insert(letter)
    letterbox_group[c] = letter
    x = x + 60
    letterbox_group[c].x = x 
    letterbox_group[c].y = y
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




local apple = display.newImage( "app.png" )
apple.x = 60; apple.y = 150;

--local line = display.newImage( "images/line.png" )
--line.x = 100; line.y = 300;

-- A
local myText = display.newText( "A", 0, 0, native.systemFont, 50 )
myText.x = 400;
myText.y = 300;

-- P
local sqLine = display.newImageRect("images/sqLine.png", 228, 228); 
sqLine.x = 600;
sqLine.y = 300;

-- P
local myText2 = display.newText( "P", 0, 0, native.systemFont, 200 )
myText2.x = 800;
myText2.y = 300;

-- L
local myText5 = display.newText( "L", 0, 0, native.systemFont, 200 )
myText5.x = 950;
myText5.y = 300;

-- E
local sqLine2 = display.newImageRect("images/sqLine.png", 228, 228); 
sqLine2.x = 1150;
sqLine2.y = 300;

local myText = display.newText( "Drag the correct letters into the blanks!", 0, 0, native.systemFont, 50 )
myText.x = 500;
myText.y = 480;

-- letterP
local myText3 = display.newText( "P", 0, 0, native.systemFont, 200 )
myText3.x = 144;
myText3.y = 600;

-- letterE
local myText4 = display.newText( "E", 0, 0, native.systemFont, 200 )
myText4.x = 300;
myText4.y = 600;

-- letterR
local myText6 = display.newText( "R", 0, 0, native.systemFont, 200 )
myText6.x = 450;
myText6.y = 600;

-- letterX
local myText7 = display.newText( "X", 0, 0, native.systemFont, 200 )
myText7.x = 600;
myText7.y = 600;

--------------------------------------------------------------
-- LetterP
MultiTouch.activate(myText3, "move", "single");
forP = false;
forE = false;
-- Set initial variables to 0
local myText3PosX = 0;
local myText3PosY = 0;
-- User drag interaction on blue circle
local function myText3Drag (event)
	local t = event.target
	--If user touches & drags circle, follow the user's touch
	if event.phase == "moved" then
		forP = false;
		myText3PosX = myText3.x - sqLine.x; 
		myText3PosY = myText3.y - sqLine.y;
		if (myText3PosX < 0) then
			myText3PosX = myText3PosX * -1;
			end
			if (myText3PosY < 0) then
				myText3PosY = myText3PosY * -1;
			end

			-- If user drags myText3 within 50 pixels of center of outline, snap into middle
			if (myText3PosX <= 50) and (myText3PosY <= 50) then
				myText3.x = sqLine.x;
				myText3.y = sqLine.y;
			end
		--
		myText3PosX2 = myText3.x - sqLine2.x; 
		myText3PosY2 = myText3.y - sqLine2.y;
		if (myText3PosX2 < 0) then
			myText3PosX2 = myText3PosX2 * -1;
			end
			if (myText3PosY2 < 0) then
				myText3PosY2 = myText3PosY2 * -1;
			end

			-- If user drags myText3 within 50 pixels of center of outline, snap into middle
			if (myText3PosX2 <= 50) and (myText3PosY2 <= 50) then
				myText3.x = sqLine2.x;
				myText3.y = sqLine2.y;
			end
		
	-- When the stops dragging myText3 within 50 pixels of center of outline, snap into middle, and...
	elseif event.phase == "ended" then
		if (myText3PosX <= 50) and (myText3PosY <= 50) then
			myText3.y = sqLine.y;
			myText3.x = sqLine.x;
			-- ...lock myText3 into place where it cannot be moved.
			forP = true
			print(forP)
			if forE == true then
				local yay = display.newText( "CORRECT!", 0, 0, native.systemFont, 80)
				yay.x = 700;
				yay.y = 100;
				yay:setTextColor(255, 0, 0)
				MultiTouch.deactivate(myText3);
				MultiTouch.deactivate(myText4);
				MultiTouch.deactivate(myText6);				
				MultiTouch.deactivate(myText7);
			end
		elseif (myText3PosX2 <= 50) and (myText3PosY2 <= 50) then
			myText3.y = sqLine2.y;
			myText3.x = sqLine2.x;
			-- ...lock myText3 into place where it cannot be moved.
		end
		
	end
	return true;
end 
myText3:addEventListener(MultiTouch.MULTITOUCH_EVENT, myText3Drag);

-- LETTER E
MultiTouch.activate(myText4, "move", "single");
-- Set initial variables to 0
local myText4PosX = 0;
local myText4PosY = 0;
-- User drag interaction on blue circle
local function myText4Drag (event)
	local t = event.target
	--If user touches & drags circle, follow the user's touch
	if event.phase == "moved" then
		forE = false;
		myText4PosX = myText4.x - sqLine.x; 
		myText4PosY = myText4.y - sqLine.y;
		if (myText4PosX < 0) then
			myText4PosX = myText4PosX * -1;
			end
			if (myText4PosY < 0) then
				myText4PosY = myText4PosY * -1;
			end

			-- If user drags myText4 within 50 pixels of center of outline, snap into middle
			if (myText4PosX <= 50) and (myText4PosY <= 50) then
				myText4.x = sqLine.x;
				myText4.y = sqLine.y;
			end
		--
		myText4PosX2 = myText4.x - sqLine2.x; 
		myText4PosY2 = myText4.y - sqLine2.y;
		if (myText4PosX2 < 0) then
			myText4PosX2 = myText4PosX2 * -1;
			end
			if (myText4PosY2 < 0) then
				myText4PosY2 = myText4PosY2 * -1;
			end

			-- If user drags myText4 within 50 pixels of center of outline, snap into middle
			if (myText4PosX2 <= 50) and (myText4PosY2 <= 50) then
				myText4.x = sqLine2.x;
				myText4.y = sqLine2.y;
			end
		
	-- When the stops dragging myText4 within 50 pixels of center of outline, snap into middle, and...
	elseif event.phase == "ended" then
		if (myText4PosX <= 50) and (myText4PosY <= 50) then
			myText4.y = sqLine.y;
			myText4.x = sqLine.x;
			-- ...lock myText4 into place where it cannot be moved.
	
		elseif (myText4PosX2 <= 50) and (myText4PosY2 <= 50) then
			myText4.y = sqLine2.y;
			myText4.x = sqLine2.x;
			-- ...lock myText4 into place where it cannot be moved.
			forE = true
			print(forE)
			if forP == true then
				local yay = display.newText( "CORRECT!", 0, 0, native.systemFont, 80)
				yay.x = 700;
				yay.y = 100;
				yay:setTextColor(255, 0, 0)
				MultiTouch.deactivate(myText3);
				MultiTouch.deactivate(myText4);
				MultiTouch.deactivate(myText6);				
				MultiTouch.deactivate(myText7);				
			end
		end
		
	
	end
	return true;
end 
myText4:addEventListener(MultiTouch.MULTITOUCH_EVENT, myText4Drag);

-- LETTER R
MultiTouch.activate(myText6, "move", "single");
-- Set initial variables to 0
local myText6PosX = 0;
local myText6PosY = 0;
-- User drag interaction on blue circle
local function myText6Drag (event)
	local t = event.target
	--If user touches & drags circle, follow the user's touch
	if event.phase == "moved" then
		myText6PosX = myText6.x - sqLine.x; 
		myText6PosY = myText6.y - sqLine.y;
		if (myText6PosX < 0) then
			myText6PosX = myText6PosX * -1;
			end
			if (myText6PosY < 0) then
				myText6PosY = myText6PosY * -1;
			end

			-- If user drags myText6 within 50 pixels of center of outline, snap into middle
			if (myText6PosX <= 50) and (myText6PosY <= 50) then
				myText6.x = sqLine.x;
				myText6.y = sqLine.y;
			end
		--
		myText6PosX2 = myText6.x - sqLine2.x; 
		myText6PosY2 = myText6.y - sqLine2.y;
		if (myText6PosX2 < 0) then
			myText6PosX2 = myText6PosX2 * -1;
			end
			if (myText6PosY2 < 0) then
				myText6PosY2 = myText6PosY2 * -1;
			end

			-- If user drags myText6 within 50 pixels of center of outline, snap into middle
			if (myText6PosX2 <= 50) and (myText6PosY2 <= 50) then
				myText6.x = sqLine2.x;
				myText6.y = sqLine2.y;
			end
		
	-- When the stops dragging myText6 within 50 pixels of center of outline, snap into middle, and...
	elseif event.phase == "ended" then
		if (myText6PosX <= 50) and (myText6PosY <= 50) then
			myText6.y = sqLine.y;
			myText6.x = sqLine.x;
			-- ...lock myText6 into place where it cannot be moved.
		elseif (myText6PosX2 <= 50) and (myText6PosY2 <= 50) then
			myText6.y = sqLine2.y;
			myText6.x = sqLine2.x;
			-- ...lock myText6 into place where it cannot be moved.
		end
		
	
	end
	return true;
end 
myText6:addEventListener(MultiTouch.MULTITOUCH_EVENT, myText6Drag);

-- LETTER X
MultiTouch.activate(myText7, "move", "single");
-- Set initial variables to 0
local myText7PosX = 0;
local myText7PosY = 0;
-- User drag interaction on blue circle
local function myText7Drag (event)
	local t = event.target
	--If user touches & drags circle, follow the user's touch
	if event.phase == "moved" then
		myText7PosX = myText7.x - sqLine.x; 
		myText7PosY = myText7.y - sqLine.y;
		if (myText7PosX < 0) then
			myText7PosX = myText7PosX * -1;
			end
			if (myText7PosY < 0) then
				myText7PosY = myText7PosY * -1;
			end

			-- If user drags myText7 within 50 pixels of center of outline, snap into middle
			if (myText7PosX <= 50) and (myText7PosY <= 50) then
				myText7.x = sqLine.x;
				myText7.y = sqLine.y;
			end
		--
		myText7PosX2 = myText7.x - sqLine2.x; 
		myText7PosY2 = myText7.y - sqLine2.y;
		if (myText7PosX2 < 0) then
			myText7PosX2 = myText7PosX2 * -1;
			end
			if (myText7PosY2 < 0) then
				myText7PosY2 = myText7PosY2 * -1;
			end

			-- If user drags myText7 within 50 pixels of center of outline, snap into middle
			if (myText7PosX2 <= 50) and (myText7PosY2 <= 50) then
				myText7.x = sqLine2.x;
				myText7.y = sqLine2.y;
			end
		
	-- When the stops dragging myText7 within 50 pixels of center of outline, snap into middle, and...
	elseif event.phase == "ended" then
		if (myText7PosX <= 50) and (myText7PosY <= 50) then
			myText7.y = sqLine.y;
			myText7.x = sqLine.x;
			-- ...lock myText7 into place where it cannot be moved.
		elseif (myText7PosX2 <= 50) and (myText7PosY2 <= 50) then
			myText7.y = sqLine2.y;
			myText7.x = sqLine2.x;
			-- ...lock myText7 into place where it cannot be moved.
		end
	
	end
	return true;
end 
myText7:addEventListener(MultiTouch.MULTITOUCH_EVENT, myText7Drag);

