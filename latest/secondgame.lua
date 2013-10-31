MultiTouch = require("dmc_multitouch");
local storyboard = require ("storyboard")
local widget = require( "widget" )
local timer = require("timer")
local scene = storyboard.newScene()
local gridView = require("gridView")
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )   
------- Global variables ---------

function _destroyDialog()
	
end

function scene:createScene(event)

	local categories = {"Living", "Non-Living", "Red", "Green", "Blue", "Yellow", "Triangle", "Rectangle", "Circle", "Animal", "Body Part"}
	local values = {"1", "0", "red", "green", "blue", "yellow", "triangle", "rectangle", "circle", "1", "1"}

	level = event.params.categ
	screenGroup = self.view

	--BACKGROUND
	width = 550; height = 320

	--HEADER
	score = display.newText("SCORE: ", -30, 0, font, 20)
	timer = display.newText("TIME: ", 400, 0, font, 20)
	screenGroup:insert(score)
	screenGroup:insert(timer)

	--BOXES
	boxGroup = display.newGroup()
	boxSize = 50
	box1 = display.newImageRect("images/secondgame/box.png", 80, 80)
	box2 = display.newImageRect("images/secondgame/box.png", 80, 80)

	local function getWords(type)
		dbFields = {}
		dbValues = {}
		for i = 1, #rand do
			if rand[i] == 1 or rand[i] == 2 then
				dbFields[i] = "livingThingCategory"
				dbValues[i] = values[rand[i]]
			elseif rand[i] >= 3 and rand[i] <= 6 then
				dbFields[i] = "colorCategory"
				dbValues[i] = values[rand[i]]
			elseif rand[i] >= 7 and rand[i] <= 9 then
				dbFields[i] = "shapeCategory" 
				dbValues[i] = values[rand[i]]			
			elseif rand[i] == 10 then
				dbFields[i] = "animalCategory"
				dbValues[i] = values[rand[i]]
			elseif rand[i] == 11 then
				dbFields[i] = "bodyPartCategory"
				dbValues[i] = values[rand[i]]				
			end
		end

		--query database:correct words
		correctWords = {}
		print("ALL WORDS CORRECT:")
		for i = 1, #dbFields do
			print("---FOR"..dbFields[i].."---")
			for row in db:nrows("SELECT * FROM Words where "..dbFields[i].." = '".. dbValues[i] .. "'") do
				correctWords[#correctWords+1] = row.name
				print(row.name)
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

	--Process the event when user click on the grid
	local function gridListener(index)
--		print("You select item "..index)
	end

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

	local function randomize(array, limit)
		words = {}
		words[1] = array[math.random(#array)]
		for i = 2, limit do
			words[i] = array[math.random(#array)]
			for j = 1, i-1 do
				while(words[i] == words[j]) do
					words[i] = array[math.random(#array)]
				end
			end
		end

		return words
	end


	----------------------------------------------------------------Data
	easy = {}; med = {}; hard = {}
	easyText = {}; medText = {}; hardText = {}

	if level == 'easy' then
		numberOfCategories = 2
		rand = randomizeCategory()

		-- boxes
		box1.x = width/4; box1.y = 290
		box2.x = width/4 + (4*boxSize); box2.y = 290
		display.newText(categories[rand[1]], box1.x-20, box1.y, font, 20)
		display.newText(categories[rand[2]], box2.x-20, box2.y, font, 20)
		boxGroup:insert(box1)
		boxGroup:insert(box2)

		--randomize correct answers
		allWords = getWords("correct")
		numberOfCorrectAnswers = 14
		correctWords = randomize(allWords, numberOfCorrectAnswers)
		for i=1,#correctWords do
			print(correctWords[i])
		end

		--randomize panggulo
		allExtras = getWords("incorrect")
		numberOfIncorrectAnswers = 10
		extraWords = randomize(allExtras, numberOfIncorrectAnswers)
		for i=1,#extraWords do
			print(extraWords[i])
		end

		-- pictures
		length = 24
		for i = 1, length do
			easy[i] = "images/secondgame/game1.png"
		end

		--display board
		for i = 1, numberOfCorrectAnswers do easyText[i] = correctWords[i] end
		for i = numberOfCorrectAnswers+1, length do easyText[i] = extraWords[i - numberOfCorrectAnswers] end

		--Initialize the starView object. The parameters are the gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight, gridListener.
		gridView:new(width/7, 30, easy, easyText, length/4, 5, 5, 50, 50, gridListener)

	elseif level == 'medium' then
		-- boxes
		numberOfCategories = 3
		rand = randomizeCategory()

		box1.x = width/3 - boxSize; box1.y = 290
		box2.x = width/3 + boxSize; box2.y = 290
		box3 = display.newImageRect("images/secondgame/box.png", 80, 80)
		box3.x = width/3 + (3*boxSize); box3.y = 290
		display.newText(categories[rand[1]], box1.x-20, box1.y, font, 20)
		display.newText(categories[rand[2]], box2.x-20, box2.y, font, 20)
		display.newText(categories[rand[3]], box3.x-20, box3.y, font, 20)
		boxGroup:insert(box1)
		boxGroup:insert(box2)
		boxGroup:insert(box3)

		-- * CHOOSE WORDS  * --

		-- correct answers
		allWords = getWords("correct")
		numberOfCorrectAnswers = 17
		correctWords = randomize(allWords, numberOfCorrectAnswers)
		for i=1,#correctWords do
			print(correctWords[i])
		end

		-- panggulo
		allExtras = getWords("incorrect")
		numberOfIncorrectAnswers = 15
		extraWords = randomize(allExtras, numberOfIncorrectAnswers)
		for i=1,#extraWords do
			print(extraWords[i])
		end

		-- * DISPLAY * --

		-- pictures
		length = 32
		for i = 1, length do
			med[i] = "images/secondgame/game1.png"
		end

		-- text
		for i = 1, numberOfCorrectAnswers do medText[i] = correctWords[i] end
		for i = numberOfCorrectAnswers+1, length do medText[i] = extraWords[i - numberOfCorrectAnswers] end

		--Initialize the starView object. The parameters are the gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight, gridListener.
		gridView:new(width/22, 30, med, medText, length/4, 5, 5, 50, 50, gridListener)

	else
		-- boxes
		numberOfCategories = 4
		rand = randomizeCategory()
		box1.x = width/4 - boxSize; box1.y = 290
		box2.x = width/4 + boxSize; box2.y = 290
		box3 = display.newImageRect("images/secondgame/box.png", 80, 80)
		box3.x = width/4 + (3*boxSize); box3.y = 290
		box4 = display.newImageRect("images/secondgame/box.png", 80, 80)
		box4.x = width/4 + (5*boxSize); box4.y = 290
		display.newText(categories[rand[1]], box1.x-20, box1.y, font, 20)
		display.newText(categories[rand[2]], box2.x-20, box2.y, font, 20)
		display.newText(categories[rand[3]], box3.x-20, box3.y, font, 20)
		display.newText(categories[rand[4]], box4.x-20, box4.y, font, 20)
		boxGroup:insert(box1)
		boxGroup:insert(box2)
		boxGroup:insert(box3)
		boxGroup:insert(box4)


		-- * CHOOSE WORDS  * --

		-- correct answers
		allWords = getWords("correct")
		numberOfCorrectAnswers = 24
		correctWords = randomize(allWords, numberOfCorrectAnswers)
		for i=1,#correctWords do
			print(correctWords[i])
		end

		-- panggulo
		allExtras = getWords("incorrect")
		numberOfIncorrectAnswers = 16
		extraWords = randomize(allExtras, numberOfIncorrectAnswers)
		for i=1,#extraWords do
			print(extraWords[i])
		end

		-- * DISPLAY * --

		-- pictures
		length = 40
		for i = 1, length do
			hard[i] = "images/secondgame/game1.png"
		end

		-- text
		for i = 1, numberOfCorrectAnswers do hardText[i] = correctWords[i] end
		for i = numberOfCorrectAnswers+1, length do hardText[i] = extraWords[i - numberOfCorrectAnswers] end

		--Initialize the starView object. The parameters are the gridX, gridY, photoArray, photoTextArray, columnNumber, paddingX, paddingY, photoWidth, photoHeight, gridListener.
		gridView:new(-30, 30, hard, hardText, length/4, 5, 5, 50, 50, gridListener)

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