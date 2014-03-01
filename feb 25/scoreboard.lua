require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()
--DB
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.DocumentsDirectory)
db = sqlite3.open( path )
--Game
local bgMusic
local homeBtn, tabGroup, scores, emailBtn1, emailBtn2, emailBtn3
local boolFirst = false
local widgetGroup, demoTabs, screenGroup, bg

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
	   attachment = { baseDir=system.DocumentsDirectory, filename="Game 1 Analytics.txt", type="text" },
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
	   attachment = { baseDir=system.DocumentsDirectory, filename="Game 2 Analytics.txt", type="text" },
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
	   attachment = { baseDir=system.DocumentsDirectory, filename="Game 3 Analytics.txt", type="text" },
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
	storyboard.removeScene("reloadscores")
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
	local titleBar = display.newRect( -33, 0, display.contentWidth + 66, 32 )
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
		rowTitle.x = display.contentCenterX + 30
		rowTitle.y = row.contentHeight * 0.5
		rowTitle:setTextColor( 0,0,0 )
	end

	-- Create a tableView
	list = widget.newTableView
	{
		left = -33,
		top = 32,
		width = display.contentWidth + 66, 
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

function displayGame1()

	if(widgetGroup ~= nil) then
		widgetGroup:removeSelf()
		bg:removeSelf()
	end
	bg = display.newImageRect("images/menu/scoresgame1.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	widgetGroup = display.newGroup()
	getScoresFromDB("FirstGame")
	screenGroup:insert(widgetGroup)
	screenGroup:insert(tabGroup)

	-- send email
	emailBtn1 = display.newImage( "images/firstgame/email_button.png", 5, 5)
	emailBtn1.x = display.contentWidth
	emailBtn1.y = 90
	widgetGroup:insert(emailBtn1)
	emailBtn1:addEventListener("touch", onSendEmail1)

end

function displayGame2()

	if(widgetGroup ~= nil) then
		widgetGroup:removeSelf()
		bg:removeSelf()
	end
	bg = display.newImageRect("images/menu/scoresgame2.png", 550, 320)
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
	emailBtn2:addEventListener("touch", onSendEmail2)

end

function displayGame3()

	if(widgetGroup ~= nil) then
		widgetGroup:removeSelf()
		bg:removeSelf()
	end
	bg = display.newImageRect("images/menu/scoresgame3.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	widgetGroup = display.newGroup()
	getScoresFromDB("ThirdGame")
	screenGroup:insert(widgetGroup)
	screenGroup:insert(tabGroup)

	-- send email
	emailBtn3 = display.newImage( "images/firstgame/email_button.png", 5, 5)
	emailBtn3.x = display.contentWidth
	emailBtn3.y = 90
	widgetGroup:insert(emailBtn3)
	emailBtn3:addEventListener("touch", onSendEmail3)

end

function scene:createScene( event )

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
			defaultFile = "assets/purple.png",
			overFile = "assets/purple2.png",
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
			defaultFile = "assets/blue.png",
			overFile = "assets/blue2.png",
			--label = "Game 3",
			onPress = displayGame3,
		}
	}

	--Create a tab-bar and place it at the bottom of the screen
	demoTabs = widget.newTabBar
	{
		top = display.contentHeight - 50,
		left = -33,
		width = display.contentWidth + 66,
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