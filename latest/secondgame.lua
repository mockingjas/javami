MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local timer = require("timer")
local scene = storyboard.newScene()
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )   

local numberOfCategories
local gameCategories
local images
local word
local categories
local length
local correctWords
local answers
local incorrectSound = audio.loadSound("incorrect.mp3")
local correctSound = audio.loadSound("correct.mp3")
local currScore = 0
------- Global variables ---------

function _destroyDialog()
	
end

function scene:createScene(event)

	categories = {"Living", "Non-Living", "Red", "Green", "Blue", "Yellow", "Triangle", "Rectangle", "Circle", "Animal", "Body Part"}
	values = {"1", "0", "red", "green", "blue", "yellow", "triangle", "rectangle", "circle", "1", "1"}

	level = event.params.categ
	print(level)

	if level == 'easy' then
		maxTime = 60
		bgImage = "images/secondgame/room1.jpg"
	elseif level == 'medium' then
		maxTime = 120
		bgImage = "images/secondgame/room2.jpg"
	else
		maxTime = 180
		bgImage = "images/secondgame/room3.jpg"
	end

	screenGroup = self.view

	--BACKGROUND
	width = 550; height = 320
	bg = display.newImageRect(bgImage, 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	--HEADER
	score = display.newText("SCORE: ", -30, 0, font, 20)
	score:setTextColor(0,0,0)
	scoreNumber = display.newText(currScore, 50, 0, font, 20)
	scoreNumber:setTextColor(0,0,0)
	-- Display score
	screenGroup:insert(score)
	screenGroup:insert(scoreNumber)

	timerText = display.newText( "0:00", 460, 0, font, 20 )
	timerText:setTextColor(0,0,0)
	screenGroup:insert(timerText)

	function timerText:timer( event )
	   	maxTime = maxTime-1
		if (maxTime % 60 < 10) then timerText.text = math.floor(maxTime/60) .. ":0" .. (maxTime%60)
		else timerText.text = math.floor(maxTime/60) .. ":" .. (maxTime%60)
		end

	    if(maxTime == 0)then
			timer.cancel( event.source )
			_destroyDialog()
			print("TIME'S UP!")
	    end
	end

	timeDelay = 1000
	timerText.text = maxTime/60 .. ":00"
	timerID = timer.performWithDelay( timeDelay, timerText, maxTime )	-- maintain time kahit magreload na

	---------PAUSE FUNCTIONS
	function pauseGame(event)
	    if(event.phase == "ended") then
--	    	timer:pause()
	    	timer.pause(timerID)
	        pauseBtn.isVisible = false
	        showpauseDialog()
	        return true
	    end
	end

--------------- RESUME FROM PAUSE -----------------
function resume_onBtnRelease()
	pausegroup:removeSelf()
	timer.resume(timerID)
    pauseBtn.isVisible = true
	return true
end

---------------- EXIT FROM PAUSE ----------------
function exit_onBtnRelease()
	pausegroup:removeSelf()
	timerText:removeSelf()
	boxGroup:removeSelf()
	gameBoard:removeSelf()
--	timer = nil
	storyboard.removeScene("secondgame")
	storyboard.removeScene("mainmenu")
	storyboard.gotoScene("mainmenu")
end

 --------------- RESTART GAME ----------------------
function restart_onBtnRelease()
--	if (timer ~= nil) then
	pausegroup:removeSelf()
	timerText:removeSelf()
	boxGroup:removeSelf()
	gameBoard:removeSelf()
--		timer = nil
--	end
	option =	{
		effect = "fade",
		time = 50,
		params = {
			categ = level,
			time = maxTime,
		}
	}

	storyboard.removeScene("secondgame")
	storyboard.gotoScene("reloadsecond", option)
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


	--PAUSE
	pauseBtn = display.newImageRect( "images/secondgame/pause.png", 20, 20)
    pauseBtn.x = 445
    pauseBtn.y = 12
	pauseBtn:addEventListener("touch", pauseGame)
	pauseBtn:addEventListener("tap", pauseGame)
    screenGroup:insert( pauseBtn )


	-- FUNCTION FOR GETTING WORDS FROM DB
	local function getWords(type)
		dbFields = {}
		dbValues = {}
		for i = 1, #gameCategories do
			if gameCategories[i] == 1 or gameCategories[i] == 2 then
				dbFields[i] = "livingThingCategory"
				dbValues[i] = values[gameCategories[i]]
			elseif gameCategories[i] >= 3 and gameCategories[i] <= 6 then
				dbFields[i] = "colorCategory"
				dbValues[i] = values[gameCategories[i]]
			elseif gameCategories[i] >= 7 and gameCategories[i] <= 9 then
				dbFields[i] = "shapeCategory" 
				dbValues[i] = values[gameCategories[i]]			
			elseif gameCategories[i] == 10 then
				dbFields[i] = "animalCategory"
				dbValues[i] = values[gameCategories[i]]
			elseif gameCategories[i] == 11 then
				dbFields[i] = "bodyPartCategory"
				dbValues[i] = values[gameCategories[i]]				
			end
		end

		--query database:correct words

		answers = {}
		correctWords = {}
		for i = 1, #dbFields do
		    answers[i] = {}
		    j = 1
			for row in db:nrows("SELECT * FROM Words where "..dbFields[i].." = '".. dbValues[i] .. "'") do
				answers[i][j] = row.name
				j = j + 1
			end
		end

		-- all correct answers, no duplicates
		correctWords[1] = answers[1][1]
		for i = 1, #dbFields do
			for j = 1, 127 do
				isUnique = true
				for k = 1, #correctWords do
					if answers[i][j] == correctWords[k] then
						isUnique = false
					end
				end

				if isUnique == true and answers[i][j] ~= nil then
					correctWords[#correctWords+1] = answers[i][j]
				end
			end
		end

		for i = 1, #dbFields do
			print("!!!!!!"..dbFields[i])
			for j = 1, 127 do
				if answers[i][j] ~= nil then
					print(answers[i][j])
				end
			end
		end

		if type == "correct" then
			words = correctWords
			print("TOTAL CORRECT"..#words)
		--query database:extra words
		elseif type == "incorrect" then
			words = {}
			for i = 1, #dbFields do
				ctr = 1
				for row in db:nrows("SELECT * FROM Words where "..dbFields[i].." = '-1'") do
					isUnique = true
					if ctr == 1 then
						for row in db:nrows("SELECT * FROM Words where "..dbFields[1].." = '-1'") do
							words[1] = row.name
						end
					else
						-- don't repeat words
						for j = 1, #words-1 do
							if row.name == words[j] then
								isUnique = false
							end
						end
						-- don't repeat words that are correct
						for j = 1, #correctWords do
							if row.name == correctWords[j] then
								isUnique = false
							end
						end
						if isUnique == true then
							words[#words+1] = row.name
						end
					end
					ctr = ctr + 1
				end
			end
			print("TOTAL WRONG"..#words)
		end

		return words
	end

	local function updateScore()
		currScore = currScore + 1
		scoreNumber.text = currScore
	end

	-- FUNCTION FOR RANDOMIZING A CATEGORY
	local function randomizeCategory()
		rand = {}
		rand[1] = math.random(#categories)
		for i = 2, numberOfCategories do
			rand[i] = math.random(#categories)			
			for j = 1, i-1 do
				while(rand[i] == rand[j]) do
					rand[i] = math.random(#categories)
				end
			end
		end
		return rand
	end

	function shuffle(array)
		for i = 1, #array*2 do -- repeat this for twice the amount of elements in the table, to make sure everything is shuffled well
			a = math.random(#array)
			b = math.random(#array)
			array[a], array[b] = array[b], array[a]
		end

		return array
	end

	-- FUNCTION FOR SELECTING N WORDS
	local function randomize(array, limit)

		print("CORRECT ANSWERS:")
		for i = 1, #array do
			print(array[i])
		end

		-- shuffle entries
		array = shuffle(array)
		print("SHUFFLED ANSWERS:")
		for i = 1, #array do
			print(array[i])
		end

		for i = 1, limit do
			words[i] = array[i]
		end

		return words
	end

	-- FUNCTION FOR DRAGGING IMAGES
	local function imageDrag (event)
		local imagePosX = {}
		local imagePosY = {}
		isMoved = false
		t = event.target

		if event.phase == "moved" or event.phase == "ended" then
			for i =1, numberOfCategories do
				imagePosX[i] = math.abs(t.x - box[i].x)
				imagePosY[i] = math.abs(t.y - box[i].y)
			end
			-- Snap to middle
			for i = 1, numberOfCategories do
				if (imagePosX[i] <= 50) and (imagePosY[i] <= 50) then
					t.x = box[i].x;
					t.y = box[i].y;
					isMoved = true
				end
			end
		end

		if event.phase == "ended" then
			-- Check answer
			if isMoved == true then
				for i = 1, numberOfCategories do
					if t.x == box[i].x then
						boxNumber = i
						print("box# "..boxNumber)
						break
					end
				end

				for i = 1, #images do
					if t == images[i] then
						wordToCheck = word[i]
						print(wordToCheck)
						break
					end
				end

				isCorrect = false
				for j = 1, 127 do
					if answers[boxNumber][j] == wordToCheck then
						print("CORRECT!")
						updateScore()
						print("SCORE:"..currScore)
						isCorrect = true
						audio.play(correctSound)
						t:removeSelf()
						break
					end
				end
				if isCorrect == false then
					print("WRONG!")
					audio.play(incorrectSound)
					t.x = t.initialX
					t.y = t.initialY
				end
			end

		end

		return true
	end 

	----------------------------------------------------------------Data

	function drawGrid(gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight)

		local currentX = gridX
		local currentY = gridY
		images = {}
		gameBoard = display.newGroup()

		for i = 1, #photoArray do
			local fontSize = 12

			images[i] = display.newImageRect(photoArray[i], photoWidth, photoHeight)
			images[i].x = currentX + 23
			images[i].y = currentY + 20
			images[i].initialX = images[i].x
			images[i].initialY = images[i].y
			gameBoard:insert(images[i])

			local textPosX = photoWidth/2 - (fontSize/2)*string.len(photoTextArray[i])/2
			textObject = display.newText( photoTextArray[i], currentX + textPosX, currentY + photoHeight - 50, native.systemFontBold, fontSize )
			textObject:setTextColor( 0,0,0 )
			gameBoard:insert(textObject)

			--Update the position of the next item
			currentX = currentX + photoWidth + paddingX

			if(i % columnNumber == 0) then
				currentX = gridX
				currentY = currentY + photoHeight + paddingY
			end

			MultiTouch.activate(images[i], "move", "single");
			images[i]:addEventListener(MultiTouch.MULTITOUCH_EVENT, imageDrag);

		end
	end

	boxGroup = display.newGroup()
	boxSize = 50

	if level == 'easy' then
		numberOfCategories = 2
		gameCategories = randomizeCategory()

		-- boxes
		box = {}
		boxLabel = {}
		for i = 1, numberOfCategories do
			box[i] = display.newImageRect("images/secondgame/box.png", 80, 110)
		end
		box[1].x = width/4; box[1].y = 280
		box[2].x = width/4 + (4*boxSize); box[2].y = 280


		for i = 1, numberOfCategories do
			boxLabel[i] = display.newText(categories[gameCategories[i]], box[i].x-20, box[i].y-5, 50, 50, font, 15)
			boxGroup:insert(box[i])
			boxGroup:insert(boxLabel[i])
		end

		allWords = getWords("correct")
		numberOfCorrectAnswers = 14
		selectedWords = randomize(allWords, numberOfCorrectAnswers)
		print("SELECTION")
		for i=1,#selectedWords do print(selectedWords[i]) end

		--randomize panggulo
		allExtras = getWords("incorrect")
		numberOfIncorrectAnswers = 10
		extraWords = randomize(allExtras, numberOfIncorrectAnswers)
--		for i=1,#extraWords do print(extraWords[i]) end

		-- pictures
		photos = {}
		length = 24
		for i = 1, length do
			photos[i] = "images/secondgame/image.png"
		end

		-- labels
		word = {}
		for i = 1, numberOfCorrectAnswers do word[i] = selectedWords[i] end
		for i = numberOfCorrectAnswers+1, length do word[i] = extraWords[i - numberOfCorrectAnswers] end
		word = shuffle(word)

		print("TO DISPLAY!!!!")
		for i = 1, length do
			print(word[i])
		end

		--Initialize the starView object. The parameters are the gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight, gridListener.
		drawGrid(width/7, 30, photos, word, length/4, 5, 5, 50, 50)

	elseif level == 'medium' then
		numberOfCategories = 3
		gameCategories = randomizeCategory()
		box = {}
		boxLabel = {}
		--BOXES
		for i = 1, numberOfCategories do
			box[i] = display.newImageRect("images/secondgame/box.png", 80, 110)
		end

		box[1].x = width/3 - boxSize; box[1].y = 280
		box[2].x = width/3 + boxSize; box[2].y = 280
		box[3].x = width/3 + (3*boxSize); box[3].y = 280

		for i = 1, numberOfCategories do
			boxLabel[i] = display.newText(categories[gameCategories[i]], box[i].x-20, box[i].y-5, 50, 50, font, 15)
			boxGroup:insert(box[i])
			boxGroup:insert(boxLabel[i])
		end

		-- * CHOOSE WORDS  * --

		-- correct answers
		allWords = getWords("correct")
		numberOfCorrectAnswers = 17
		selectedWords = randomize(allWords, numberOfCorrectAnswers)
--		for i=1,#correctWords do print(correctWords[i]) end

		-- panggulo
		allExtras = getWords("incorrect")
		numberOfIncorrectAnswers = 15
		extraWords = randomize(allExtras, numberOfIncorrectAnswers)
--		for i=1,#extraWords do print(extraWords[i]) end

		-- * DISPLAY * --

		-- pictures
		photos = {}
		length = 32
		for i = 1, length do
			photos[i] = "images/secondgame/image.png"
		end

		-- labels
		word = {}
		for i = 1, numberOfCorrectAnswers do word[i] = selectedWords[i] end
		for i = numberOfCorrectAnswers+1, length do word[i] = extraWords[i - numberOfCorrectAnswers] end
		word = shuffle(word)

		--Initialize the starView object. The parameters are the gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight, gridListener.
		drawGrid(width/22, 30, photos, word, length/4, 5, 5, 50, 50)

	else

		numberOfCategories = 4
		gameCategories = randomizeCategory()

		box = {}
		boxLabel = {}


		--BOXES
		for i = 1, numberOfCategories do
			box[i] = display.newImageRect("images/secondgame/box.png", 80, 110)
		end

		box[1].x = width/4 - boxSize; box[1].y = 280
		box[2].x = width/4 + boxSize; box[2].y = 280
		box[3].x = width/4 + (3*boxSize); box[3].y = 280
		box[4].x = width/4 + (5*boxSize); box[4].y = 280

		for i = 1, numberOfCategories do
			boxLabel[i] = display.newText(categories[gameCategories[i]], box[i].x-20, box[i].y-5, 50, 50, font, 15)			
			boxGroup:insert(box[i])
			boxGroup:insert(boxLabel[i])
		end

		-- * CHOOSE WORDS  * --

		-- correct answers
		allWords = getWords("correct")
		numberOfCorrectAnswers = 24
		selectedWords = randomize(allWords, numberOfCorrectAnswers)
--		for i=1,#correctWords do print(correctWords[i]) end

		-- panggulo
		allExtras = getWords("incorrect")
		numberOfIncorrectAnswers = 16
		extraWords = randomize(allExtras, numberOfIncorrectAnswers)
		for i=1,#extraWords do
			print(extraWords[i])
		end

		-- * DISPLAY * --

		-- pictures
		photos = {}
		length = 40
		for i = 1, length do
			photos[i] = "images/secondgame/image.png"
		end

		-- labels
		word = {}
		for i = 1, numberOfCorrectAnswers do word[i] = selectedWords[i] end
		for i = numberOfCorrectAnswers+1, length do word[i] = extraWords[i - numberOfCorrectAnswers] end
		word = shuffle(word)

		--Initialize the starView object. The parameters are the gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight, gridListener.
		drawGrid(-30, 30, photos, word, length/4, 5, 5, 50, 50)

	end
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