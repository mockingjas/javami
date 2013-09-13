MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()

------- Global variables ---------
local word
local word_group
local word_to_guess
local letterbox

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
	-- Insert function for getting random word from database here
	word = "apple"
	word_to_guess = word
	
end

------- FUNCTION FOR SETTING THE WORD --------------
function setword()

	getwordfromDB()
	print("String length: " .. word:len())
	local blanks = math.floor(word:len()/2)

	letterbox = ""
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
function objectDrag (event)
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

------- FUNCTION FOR CHECKING ANSWER --------------
local checkanswer = function( event )
	-- check the word
	-- if right, add score and then,
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
	word_group = display.newGroup()
	local a = 1
	for i = 1, #word_to_guess do
	    local c = get_char(i, word_to_guess)
	    local filename = "images"
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
	    local filename = "images"
	    filename = filename .. "/" .. c .. ".png"
	    -- print(filename)
	    local letter = display.newImage(filename)
	    letterbox_group:insert(letter)
	    letterbox_group[c] = letter
	    x = x + 60
	    letterbox_group[c].x = x 
	    letterbox_group[c].y = y
	    MultiTouch.activate(letter, "move", "single")
	    letter:addEventListener(MultiTouch.MULTITOUCH_EVENT, objectDrag);
	end
	
	screenGroup:insert(word_group)
	screenGroup:insert(letterbox_group)
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