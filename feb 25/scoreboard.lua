require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()
--DB
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )
--Game
--local bgMusic
local homeBtn, tabGroup, scores, emailBtn1, emailBtn2, emailBtn3
local boolFirst = false
local widgetGroup, demoTabs, screenGroup, bg
local avgRounds, avgSpeed, avgScore, IDs, getOneCount, getTwoCount, getThreeCount, report, roundNumber

-- Font
local font
if "Win" == system.getInfo( "platformName" ) then
    font = "inky"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "inky"
else
    -- Mac and iOS
    font = "inky"
end

-----------------FUNCTION FOR EMAIL

local function onSendEmail1( event )
	print("\n\n1!!!!!\n\n")
	local options =
	{
	   subject = "Game 1 Overall Analytics",
	   body = "Game 1 Overall Analytics",
	   attachment = { baseDir=system.DocumentsDirectory, filename="Game 3 General Assessment.txt", type="text" },
	}
	print(native.showPopup("mail", options))
	native.showPopup("mail", options)
end

local function onSendEmail2( event )
	print("\n\n2!!!!!\n\n")
	local options =
	{
	   subject = "Game 2 Overall Analytics",
	   body = "Game 2 Overall Analytics",
	   attachment = { baseDir=system.DocumentsDirectory, filename="Game 2 General Assessment.txt", type="text" },
	}
	print(native.showPopup("mail", options))
	native.showPopup("mail", options)
end

local function onSendEmail3( event )
	print("\n\n3!!!!!\n\n")
	local options =
	{
	   subject = "Game 3 Overall Analytics",
	   body = "Game 3 Overall Analytics",
	   attachment = { baseDir=system.DocumentsDirectory, filename="Game 1 General Assessment.txt", type="text" },
	}
	print(native.showPopup("mail", options))
	native.showPopup("mail", options)
end

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	print("HOME")
	homeBtn.isVisible = false
	tabGroup.isVisible = false
	widgetGroup.isVisible = false
	storyboard.removeScene("mainmenu")
	storyboard.removeScene("scoreboard")
	audio.stop(bgMusic)
	storyboard.gotoScene("reloadscores")
	return true
end

--------------  FUNCTIONS FOR DISPLAYING SCORES --------------------

function getScoresFromDB(tableName)

	local easyScores = {}
	for row in db:nrows("SELECT * FROM " .. tableName .. " where category = 'easy' order by cast(score as integer) desc") do
		easyScores[1] = "★TOP SCORE★"
		easyScores[2] = row.name .. " : " .. row.score .. " (" .. row.timestamp .. ")"
		break
	end

	for row in db:nrows("SELECT * FROM " .. tableName .. " where category = 'easy' order by id desc") do
		if #easyScores == 6 then
			break
		else
			easyScores[3] = "★RECENT SCORES★"
			easyScores[#easyScores+1] = row.name .. " : " .. row.score .. " (" .. row.timestamp .. ")"
		end
	end

	local mediumScores = {}
	for row in db:nrows("SELECT * FROM " .. tableName .. " where category = 'medium' order by cast(score as integer) desc") do
		mediumScores[1] = "★TOP SCORE★"
		mediumScores[2] = row.name .. " : " .. row.score .. " (" .. row.timestamp .. ")"
		break
	end
	for row in db:nrows("SELECT * FROM " .. tableName .. " where category = 'medium' order by id desc") do
		if #mediumScores == 6 then
			break
		else
			mediumScores[3] = "★RECENT SCORES★"
			mediumScores[#mediumScores+1] = row.name .. " : " .. row.score .. " (" .. row.timestamp .. ")"
		end
	end

	local hardScores = {}
	for row in db:nrows("SELECT * FROM " .. tableName .. " where category = 'hard' order by cast(score as integer) desc") do
		hardScores[1] = "★TOP SCORE★"
		hardScores[2] = row.name .. " : " .. row.score .. " (" .. row.timestamp .. ")"
		break
	end
	for row in db:nrows("SELECT * FROM " .. tableName .. " where category = 'hard' order by id desc") do
		if #hardScores == 5 then		
			break
		else
			hardScores[3] = "★RECENT SCORES★"
			hardScores[#hardScores+1] = row.name .. " : " .. row.score .. " (" .. row.timestamp .. ")"
		end
	end

	displayScores(easyScores, mediumScores, hardScores)

end


function displayScores(easyScores, mediumScores, hardScores)
	
	------------- TABLE

	local rowTitles = {}

	local titleGradient = graphics.newGradient( 
		{ 189, 203, 220, 255 }, 
		{ 89, 116, 152, 255 }, "down" )

	-- Create toolbar to go at the top of the screen
	local titleBar = display.newRect( -60, 0, display.contentWidth + 120, 32 )
	titleBar.y = display.statusBarHeight + ( titleBar.contentHeight * 0.5 )
	titleBar:setFillColor( titleGradient )
	titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5

	-- create embossed text to go on toolbar
	local titleText = display.newEmbossedText( "Scores", 0, 0, font, 20)
	titleText:setTextColor( 255 )
	titleText.x = display.contentCenterX
	titleText.y = titleBar.y

	-- Handle row rendering
	local function onRowRender( event )
		local phase = event.phase
		local row = event.row
		--local isCategory = row.isCategory
	
		local rowTitle = display.newText( row, rowTitles[row.index], 0, 0, font, 16 )
		rowTitle.x = display.contentCenterX + 60
		rowTitle.y = row.contentHeight * 0.5
		rowTitle:setTextColor( 0,0,0 )
	end

	-- Create a tableView
	list = widget.newTableView
	{
		left = -60,
		top = 32,
		width = display.contentWidth + 120, 
		height = 350,
		onRowRender = onRowRender,
		onRowTouch = onRowTouch,
		hideBackground = true,
	}

	widgetGroup:insert( list )
	widgetGroup:insert( titleBar )
	widgetGroup:insert( titleText )

	-- Display only 5 recent scores

--	for i = 1, #easyScores do print(easyScores[i]) end

	--Items to show in our list
	local listItems = {
		{ title = "Easy", items = easyScores },
		{ title = "Medium", items = mediumScores },
		{ title = "Hard", items = hardScores },
	}

	-- insert rows into list (tableView widget)
	for i = 1, #listItems do
		--Add the rows category title
		rowTitles[ #rowTitles + 1 ] = listItems[i].title
		
		--Insert the category
		list:insertRow{
			rowHeight = 30,
			rowColor = 
			{ 
				default = { 150, 160, 180, 200 },
			},
			--isCategory = true,
			hideBackground = true
		}

		--Insert the item
		for j = 1, #listItems[i].items do
			--Add the rows item title
			rowTitles[ #rowTitles + 1 ] = listItems[i].items[j]
			
			--Insert the item
			list:insertRow{
				rowHeight = 30,
				isCategory = false,
				rowColor = 
				{ 
					default = { 255, 255, 255, 150 },
				},
				--listener = onRowTouch,
				hideBackground = true
			}
		end
	end
end

-----------------------------------------------------------------------------------------------------------
function getCount(table, category)
	for row in db:nrows("SELECT COUNT(*) as count FROM "..table.." where category = '"..category.."'") do
		return row.count
	end
end

function countRounds(table1, table2, category)
	for row in db:nrows("SELECT COUNT(*) as count FROM "..table1.." where gamenumber in (SELECT id FROM "..table2.." where category = '"..category.."')") do
		return row.count
	end
end

function getAverageScore(table, category)
	print("\n**PER GAME AVERAGES**")
	report = report .. "\n**PER GAME AVERAGES**\n"
	for row in db:nrows("SELECT AVG(cast(score as integer)) as average FROM "..table.." where category = '"..category.."'") do
		print("AVERAGE OF TOTAL SCORES:\t"..string.format("%.2f",row.average))
		report = report .. "AVERAGE OF TOTAL SCORES:\t"..string.format("%.2f",row.average).."\n"
	end

	for row in db:nrows("SELECT AVG(cast(pausecount as integer)) as average FROM "..table.." where category = '"..category.."'") do
		print("AVERAGE # OF PAUSE COUNTS:\t"..string.format("%.2f",row.average))
		report = report .. "AVERAGE # OF PAUSE COUNTS:\t"..string.format("%.2f",row.average).."\n"
	end
end
-----------------------------------------------------------------------------------------------------------
-- GAME 2	
function getGameTwoAverages(table, category)
	IDs = {}
	for row in db:nrows("SELECT id from '"..table.."' where category = '"..category.."'") do
		IDs[#IDs+1] = row.id
	end
	-- ave # of rounds
	avgRounds = 0	
	for i = 1, gameTwoCount do
		for row in db:nrows("SELECT MAX(CAST(roundnumber as integer)) as max FROM SecondGameAnalytics where gamenumber = '"..IDs[i].."'") do
			if row.max ~= nil then
				avgRounds = avgRounds + row.max
			end
		end
	end
	avgRounds = avgRounds / gameTwoCount
	print("AVERAGE NUMBER OF ROUNDS:\t" .. string.format("%.2f",avgRounds))
	report = report .. "AVERAGE NUMBER OF ROUNDS:\t" .. string.format("%.2f",avgRounds).."\n"

	print("\n**PER ROUND AVERAGES**")
	report = report .. "\n**PER ROUND AVERAGES**\n"
	--AVG ROUND SPEED
	avgSpeed = 0
	ctr = countRounds("SecondGameAnalytics", table, category)
	for i = 1, gameTwoCount do
		for row in db:nrows("SELECT speed FROM SecondGameAnalytics where gamenumber = '"..IDs[i].."'") do
			avgSpeed = avgSpeed + row.speed
		end
	end
	avgSpeed = avgSpeed / ctr
	print("AVERAGE SPEED PER ROUND:\t" .. string.format("%.2f",avgSpeed) .. " seconds")
	report = report .. "AVERAGE SPEED PER ROUND:\t" .. string.format("%.2f",avgSpeed) .. " seconds\n"

	--AVG # OF CORRECT 
	local avgCorrect = 0
	local avgIncorrect = 0
	for i = 1, gameTwoCount do
		for row in db:nrows("SELECT * FROM SecondGameAnalytics where gamenumber = '"..IDs[i].."'") do
			if row.isCorrect == "1" then
				avgCorrect = avgCorrect + 1
			else
				avgIncorrect = avgIncorrect + 1
			end
		end
	end
	--AVG # OF INCORRECT 
	avgCorrect = avgCorrect / gameTwoCount
	print("AVERAGE # OF CORRECT ANSWERS:\t" .. string.format("%.2f",avgCorrect))
	report = report .. "AVERAGE # OF CORRECT ANSWERS:\t" .. string.format("%.2f",avgCorrect).."\n"
	avgIncorrect = avgIncorrect / gameTwoCount
	print("AVERAGE # OF INCORRECT ANSWERS:\t" .. string.format("%.2f",avgIncorrect))
	report = report .. "AVERAGE # OF INCORRECT ANSWERS:\t" .. string.format("%.2f",avgIncorrect).."\n"
end
-----------------------------------------------------------------------------------------------------------
-- GAME 3	
function getGameThreeAverages(table, category)
	IDs = {}
	for row in db:nrows("SELECT id from '"..table.."' where category = '"..category.."'") do
		IDs[#IDs+1] = row.id
	end

	print("\n**PER ROUND AVERAGES**")
	report = report .. "\n**PER ROUND AVERAGES**\n"
	-- avg time per word
	avgSpeed = 0	
	ctr = countRounds("FirstGameAnalytics", table, category)
	print(ctr)
	for i = 1, gameThreeCount do
		for row in db:nrows("SELECT speed FROM FirstGameAnalytics where gamenumber = '"..IDs[i].."'") do
			avgSpeed = avgSpeed + row.speed
		end
	end
	avgSpeed = avgSpeed / ctr
	print("AVERAGE SPEED:\t" .. string.format("%.2f",avgSpeed) .. " seconds")
	report = report .. "AVERAGE SPEED:\t" .. string.format("%.2f",avgSpeed) .. " seconds\n"

	--avg number of hints
	local avgHints = 0	
	for i = 1, gameThreeCount do
		for row in db:nrows("SELECT MAX(CAST(roundnumber as integer)) as max, hintcount FROM FirstGameAnalytics where gamenumber = '"..IDs[i].."'") do
			if row.max ~= nil then
				avgHints = avgHints + row.hintcount
			end
		end
	end
	avgHints = avgHints / ctr
	print("AVERAGE # OF HINTS:\t" .. string.format("%.2f",avgHints))
	report = report .. "AVERAGE # OF HINTS:\t" .. string.format("%.2f",avgHints).."\n"

	--avg number of tries
	local avgTries = 0	
	for i = 1, gameThreeCount do
		for row in db:nrows("SELECT MAX(CAST(roundnumber as integer)) as max, triescount FROM FirstGameAnalytics where gamenumber = '"..IDs[i].."'") do
			if row.max ~= nil then
				avgTries = avgTries + row.triescount
			end
		end
	end
	avgTries = avgTries / ctr
	print("AVERAGE # OF TRIES:\t" .. string.format("%.2f",avgTries))
	report = report .. "AVERAGE # OF TRIES:\t" .. string.format("%.2f",avgTries).."\n"

end
----------------------------------------------------------------------------------------------------
--GAME 1
function getGameOneAverages(table, category, score)
	-- AVERAGE # OF COMPLETE ROUNDS
	IDs = {}
	for row in db:nrows("SELECT id from '"..table.."' where category = '"..category.."'") do
		IDs[#IDs+1] = row.id
	end

	avgRounds = 0
	local completedRounds = {}
	for i = 1, gameOneCount do
		completedRounds[i] = 0
		-- completed rounds
		for row in db:nrows("SELECT * FROM ThirdGameAnalytics where gamenumber = '"..IDs[i].."' AND score = '"..score.."'") do
			completedRounds[i] = completedRounds[i] + 1
		end
	end

	for i = 1, gameOneCount do
		avgRounds = avgRounds + completedRounds[i]
	end
	avgRounds = avgRounds / gameOneCount
	print("AVERAGE # OF COMPLETE ROUNDS:\t" .. string.format("%.2f",avgRounds))
	report = report .. "AVERAGE # OF COMPLETE ROUNDS:\t" .. string.format("%.2f",avgRounds).."\n"

	print("\n**PER ROUND AVERAGES**")
	report = report .. "\n**PER ROUND AVERAGES**\n"
	--AVG ROUND SPEED
	avgSpeed = 0
	ctr = countRounds("ThirdGameAnalytics", table, category)
	for i = 1, gameOneCount do
		for row in db:nrows("SELECT speed FROM ThirdGameAnalytics where gamenumber = '"..IDs[i].."'") do
			avgSpeed = avgSpeed + row.speed
--			ctr = ctr + 1
		end
	end
	avgSpeed = avgSpeed / ctr
	print("AVERAGE SPEED:\t" .. string.format("%.2f",avgSpeed) .. " seconds")
	report = report .. "AVERAGE SPEED:\t" .. string.format("%.2f",avgSpeed) .. " seconds\n"

	--AVG ROUND SCORE
	avgScore = 0
	for i = 1, gameOneCount do
		for row in db:nrows("SELECT score FROM ThirdGameAnalytics where gamenumber = '"..IDs[i].."'") do
--			print(row.score)
			avgScore = avgScore + row.score
		end
	end
	avgScore = avgScore / ctr
	print("AVERAGE SCORE:\t" .. string.format("%.2f",avgScore))
	report = report .. "AVERAGE SCORE:\t" .. string.format("%.2f",avgScore).."\n"

	print("\n\n\n\n\n"..report)
end	

function generateReport1()

	report = ""
	report = report .. "\n------------------------------------------------------------"
	report = report .. "\nGENERAL ANALYTICS"
	report = report .. "\n------------------------------------------------------------\n"
	report = report .. "The following information contains the analytics for all the game plays for Game 1: Memory (BLUE HOUSE). Note: Completed rounds are the ones correctly answered up until the last sequence. For easy, there are 4 sequences, for medium, 9 sequences and for hard, 16 sequences.\n\n"

	print("\n**EASY**")
	report = report .. "*****EASY*****\n"
	gameOneCount = getCount("ThirdGame", "easy")
	print("NO. OF ENTRIES:\t"..gameOneCount)
	report = report .. "NO. OF ENTRIES:\t"..gameOneCount.."\n"
	if gameOneCount > 0 then
		getAverageScore("ThirdGame", "easy")
		getGameOneAverages("ThirdGame", "easy", 10)
	end

	print("\n**MEDIUM**")
	report = report .. "\n*****MEDIUM*****\n"
	gameOneCount = getCount("ThirdGame", "medium")
	print("NO. OF ENTRIES:\t"..gameOneCount)
	report = report .. "NO. OF ENTRIES:\t"..gameOneCount.."\n"
	if gameOneCount > 0 then
		getAverageScore("ThirdGame", "medium")
		getGameOneAverages("ThirdGame", "medium", 45)
	end

	print("\n**HARD**")
	report = report .. "\n*****HARD*****\n"
	gameOneCount = getCount("ThirdGame", "hard")
	print("NO. OF ENTRIES:\t"..gameOneCount)
	report = report .. "NO. OF ENTRIES:\t"..gameOneCount.."\n"
	if gameOneCount > 0 then
		getAverageScore("ThirdGame", "hard")
		getGameOneAverages("ThirdGame", "hard", 136)
	end

--	if gameOneCount > 0 then
--	end

	-- ALL ANALYTICS
	for row in db:nrows("SELECT * FROM ThirdGame ORDER BY id DESC") do
		roundNumber = 0
	--	if row.age ~= nil then
			report = report .. "\n------------------------------------------------------------"
			report = report .. "\nALL ANALYTICS\n"
			report = report .. "------------------------------------------------------------\n"
			report = report .. "The following information contains the analytics for each of the game plays for Game 1: Memory (BLUE HOUSE).\n"
			report = report .. "GAME # " .. row.id .."\n\nPlayer: ".. row.name.."\nAge: "..row.age.."\nCategory : "..row.category.."\nTimestamp: "..row.timestamp.. "\nPause count: " .. row.pausecount.."\nFinal Score: "..row.score
			for row in db:nrows("SELECT * FROM ThirdGameAnalytics where gamenumber = '"..row.id.."'") do
				report = report .. "\n\nROUND "..row.roundnumber .. "\nRound time: "..row.speed.." second/s" .. "\nRound score: "..row.score
				roundNumber = roundNumber + 1
			end
			report = report .. "\n\nTotal number of rounds: "..roundNumber.."\n"
--		end
	end

	--save to file
	local path = system.pathForFile( "Game 1 General Assessment.txt", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write( report )
	io.close( file )
	file = nil
end

-- WORD: REMOVE DUPLICATES
function cleanArray(array)
	result = {}
	ctr = 1

	for i = 1, #array do
		if ctr > 1 then
			isUnique = true
			for j = 1, #result do
				if array[i] == result[j] then
					isUnique = false
				end
			end
			if isUnique then
				result[ctr] = array[i]
				ctr = ctr + 1
			end
		else
			result[ctr] = array[i]
			ctr = ctr + 1
		end
	end

	return result
end

function generateReport2()
	report = ""
	report = report .. "\n------------------------------------------------------------"
	report = report .. "\nGENERAL ANALYTICS"
	report = report .. "\n------------------------------------------------------------\n"

	print("\n**EASY**")
	report = report .. "*****EASY*****\n"
	gameTwoCount = getCount("SecondGame", "easy")
	report = report .. "NO. OF ENTRIES:\t"..gameTwoCount.."\n"
	if gameTwoCount > 0 then
		getAverageScore("SecondGame", "easy")
		getGameTwoAverages("SecondGame", "easy")
	end

	print("\n--medium--")
	report = report .. "*****MEDIUM*****\n"
	gameTwoCount = getCount("SecondGame", "medium")
	print("NO. OF ENTRIES:\t"..gameTwoCount)
	report = report .. "NO. OF ENTRIES:\t"..gameTwoCount.."\n"
	if gameTwoCount > 0 then
		getAverageScore("SecondGame", "medium")
		getGameTwoAverages("SecondGame", "medium")
	end

	print("\n--hard--")
	report = report .. "*****HARD*****\n"
	gameTwoCount = getCount("SecondGame", "hard")
	print("NO. OF ENTRIES:\t"..gameTwoCount)
	report = report .. "NO. OF ENTRIES:\t"..gameTwoCount.."\n"
	if gameTwoCount > 0 then
		getAverageScore("SecondGame", "hard")
		getGameTwoAverages("SecondGame", "hard")
	end
end



function queryAnalytics(gamectr, column, value)
	result = ""
	ctr = 0
	for row in db:nrows("SELECT * FROM FirstGameAnalytics WHERE gamenumber = '" ..gamectr.. "' and " .. column .. "= '" .. value .. "'") do
		if ctr == 0 then
			result = row.word
		else
			result = result .. ", " .. row.word
		end
		ctr = ctr + 1
	end
	return result
end

function generateReport3()
	report = ""
	report = report .. "\n------------------------------------------------------------"
	report = report .. "\nGENERAL ANALYTICS"
	report = report .. "\n------------------------------------------------------------\n"
	report = report .. "\nThe following information contains the analytics for all the game plays for Game 3: Language and Spelling (PURPLE HOUSE).\n\n"
	print("\n**EASY**")
	report = report .. "*****EASY*****\n"
	gameThreeCount = getCount("FirstGame", "easy")
	report = report .. "NO. OF ENTRIES:\t"..gameThreeCount.."\n"
	if gameThreeCount > 0 then
		getAverageScore("FirstGame", "easy")
		getGameThreeAverages("FirstGame", "easy")
	end

	report = report .. "*****MEDIUM*****\n"
	gameThreeCount = getCount("FirstGame", "medium")
	report = report .. "NO. OF ENTRIES:\t"..gameThreeCount.."\n"
	if gameThreeCount > 0 then
		getAverageScore("FirstGame", "medium")
		getGameThreeAverages("FirstGame", "medium")
	end

	report = report .. "*****HARD*****\n"
	gameThreeCount = getCount("FirstGame", "hard")
	report = report .. "NO. OF ENTRIES:\t"..gameThreeCount.."\n"
	if gameThreeCount > 0 then
		getAverageScore("FirstGame", "hard")
		getGameThreeAverages("FirstGame", "hard")
	end

	-- ALL

	gamenumber = {}
	roundnumber = {}
	speed = {}
	hint = {}
	tries = {}
	words = {}
	
	for row in db:nrows("SELECT * FROM FirstGameAnalytics") do
		gamenumber[#gamenumber+1] = row.gamenumber
		roundnumber[#roundnumber+1] = row.roundnumber
		speed[#speed+1] = row.speed
		hint[#hint+1] = row.hintcount
		tries[#tries+1] = row.triescount
		words[#words+1] = row.word
	end

	first = gamenumber[1]
	last = gamenumber[#gamenumber]

if #gamenumber > 0 then
	report = report .. "\n------------------------------------------------------------"
	report = report .. "\nALL ANALYTICS"
	for i = last, first, -1 do
		report = report .. "\n------------------------------------------------------------\n"
		report = report .. "The following information contains the analytics for EACH of the game plays for Game 3: Language and Spelling (PURPLE HOUSE). The speed for each correctly answered word, the number of times user asked for a hint and the number of tries before being corrected are recorded for every word that appears.\n\n" 
		report = report .. "GAME# " .. i .. "\n\n"
		for row in db:nrows("SELECT * FROM FirstGame where id = '" .. i .. "'") do
--			if row.age ~= nil then
				finalscore = row.score
				print("Player:\t\t" .. row.name .. "\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score .. "\n")
				report = report .. "Player:\t\t" .. row.name .. "\nAge:\t"..row.age.."\nCategory:\t" .. row.category .. "\nTimestamp:\t" ..row.timestamp .. "\nPause count:\t" .. row.pausecount .. "\nFinal score:\t" .. row.score .. "\n"
--			end
		end

		--By Speed
		for row in db:nrows("SELECT speed FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' and speed != '0' ORDER BY cast(speed as integer) desc") do
			maxVal = row.speed
			break
		end
		for row in db:nrows("SELECT speed FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' and speed != '0' ORDER BY cast(speed as integer)") do
			if tonumber(row.speed) > 0 then
				minVal = row.speed
				break
			end
		end

		if maxVal ~= minVal then
			max = queryAnalytics(i, "speed", maxVal)
			print("Longest Time:\t"..max.." ("..maxVal.." seconds)")
			report = report .. "Longest Time:\t"..max.." ("..maxVal.." seconds)\n"
			min = queryAnalytics(i, "speed", minVal)
			print("Shortest Time:\t"..min.." ("..minVal.. " seconds)")
			report = report .. "Shortest Time:\t"..min.." ("..minVal.. " seconds)\n"
		end

		--By Hints
		for row in db:nrows("SELECT hintcount FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' ORDER BY cast(hintcount as integer) DESC") do
			maxVal = row.hintcount
			break
		end
		for row in db:nrows("SELECT hintcount FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' ORDER BY cast(hintcount as integer)") do
			minVal = row.hintcount
			break
		end
		if maxVal ~= minVal then
			max = queryAnalytics(i, "hintcount", maxVal)
			print("Most hints:\t"..max.." (" ..maxVal.." time/s)")
			report = report .. "Most hints:\t"..max.." (" ..maxVal.." time/s)\n"
			min = queryAnalytics(i, "hintcount", minVal)
			print("Least hints:\t"..min.." ("..minVal.." time/s)")
			report = report .. "Least hints:\t"..min.." ("..minVal.." time/s)\n"
		end

		--By Tries
		for row in db:nrows("SELECT triescount FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' and triescount != '0' ORDER BY cast(triescount as integer) DESC") do
			maxVal = row.triescount
			break
		end
		for row in db:nrows("SELECT triescount FROM FirstGameAnalytics WHERE gamenumber = '"..i.."' and triescount != '0' ORDER BY cast(triescount as integer)") do
			if tonumber(row.triescount) > 0 then			
				minVal = row.triescount
				break
			end
		end
		if maxVal ~= minVal then
			max = queryAnalytics(i, "triescount", maxVal)
			print("Most mistaken:\t"..max.." ("..maxVal.." attempt/s)")
			report = report .. "Most mistaken:\t"..max.." ("..maxVal.." attempt/s)\n"
			min = queryAnalytics(i, "triescount", minVal)
			print("Least mistaken:\t"..min.." ("..minVal.." attempt/s)")
			report = report .. "Least mistaken:\t"..min.." ("..minVal.." attempt/s)\n"
		end

		--PER WORD
		report = report .. "\nPER ITEM ANALYSIS:"
		report = report .. "\nWORD\tSPEED\tHINTS\tTRIES"
		for j = 1, #roundnumber do
			if tonumber(gamenumber[j]) == tonumber(i) then
				report = report .. "\n" .. words[j] .. "\t" .. speed[j] .. "\t" .. hint[j] .. "\t" .. tries[j]
			end
		end
	end

	--
	print("\n\n\n")
	print(report)
end
	-- Save to file
	local path = system.pathForFile( "Game 3 General Assessment.txt", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	file:write( report )
	io.close( file )
	file = nil
end

function displayGame1()

	if(widgetGroup ~= nil) then
		widgetGroup:removeSelf()
		bg:removeSelf()
	end
	bg = display.newImageRect("images/menu/scoresgame3.png", 600, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	widgetGroup = display.newGroup()
	getScoresFromDB("ThirdGame")
	screenGroup:insert(widgetGroup)
	screenGroup:insert(tabGroup)

	-- send email
	emailBtn1 = display.newImage( "images/firstgame/email_button.png", 5, 5)
	emailBtn1.x = display.contentWidth
	emailBtn1.y = 90
	widgetGroup:insert(emailBtn1)

	generateReport1()
	emailBtn1:addEventListener("touch", onSendEmail3)

end

function displayGame2()

	if(widgetGroup ~= nil) then
		widgetGroup:removeSelf()
		bg:removeSelf()
	end
	bg = display.newImageRect("images/menu/scoresgame2.png", 600, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	widgetGroup = display.newGroup()
	getScoresFromDB("SecondGame")
	screenGroup:insert(widgetGroup)
	screenGroup:insert(tabGroup)

	-- send email
	emailBtn2 = display.newImage( "images/firstgame/email_button.png", 5, 5)
	emailBtn2.x = display.contentWidth
	emailBtn2.y = 90
	widgetGroup:insert(emailBtn2)
	generateReport2()
	emailBtn2:addEventListener("touch", onSendEmail2)

end

function displayGame3()

	if(widgetGroup ~= nil) then
		widgetGroup:removeSelf()
		bg:removeSelf()
	end
	bg = display.newImageRect("images/menu/scoresgame1.png", 600, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	widgetGroup = display.newGroup()
	getScoresFromDB("FirstGame")
	screenGroup:insert(widgetGroup)
	screenGroup:insert(tabGroup)

	-- send email
	emailBtn3 = display.newImage( "images/firstgame/email_button.png", 5, 5)
	emailBtn3.x = display.contentWidth
	emailBtn3.y = 90
	widgetGroup:insert(emailBtn3)
	generateReport3()
	emailBtn3:addEventListener("touch", onSendEmail1)

end

function scene:createScene( event )

	storyboard.removeAll()
	screenGroup = self.view

	bgMusic = event.params.music

	-- back to home
	homeBtn = display.newImage( "images/firstgame/home_button.png", 5, 5)
	homeBtn.x = display.contentWidth
	homeBtn.y = 30
	homeBtn:addEventListener("touch", home)

	-- Tabs
	tabGroup = display.newGroup()

	local tabButtons = 
	{
		{
			width = 100, height = 32,
			defaultFile = "assets/blue.png",
			overFile = "assets/blue2.png",
			--label = "Game 1",
			onPress = displayGame1,
			selected = true
		},
		{
			width = 100, height = 32,
			defaultFile = "assets/orange.png",
			overFile = "assets/orange2.png",
			--label = "Game 2",
			onPress = displayGame2,
		},
		{
			width = 100, height = 32,
			defaultFile = "assets/purple.png",
			overFile = "assets/purple2.png",
			--label = "Game 3",
			onPress = displayGame3,
		}
	}

	--Create a tab-bar and place it at the bottom of the screen
	demoTabs = widget.newTabBar
	{
		top = display.contentHeight - 50,
		left = -60,
		width = display.contentWidth + 120,
		backgroundFile = "assets/tabbar.png",
		tabSelectedLeftFile = "assets/tabBar_tabSelectedLeft.png",
		tabSelectedMiddleFile = "assets/tabBar_tabSelectedMiddle.png",
		tabSelectedRightFile = "assets/tabBar_tabSelectedRight.png",
		tabSelectedFrameWidth = 20,
		tabSelectedFrameHeight = 52,
		buttons = tabButtons
	}

	tabGroup:insert(demoTabs)
	displayGame1()

end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene