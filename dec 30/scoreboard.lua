require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()
--DB
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )
--Game
local bgMusic
local game1flag = false
local homeBtn, tabGroup, scrollView, scores
-- Font
local font
if "Win" == system.getInfo( "platformName" ) then
    font = "Bebas"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "Bebas"
else
    -- Mac and iOS
    font = "Bebas"
end

--------------  FUNCTION FOR SCROLLVIEW --------------------
local function scrollListener( event )
	local direction = event.direction
	
	-- If the scrollView has reached it's scroll limit
	if event.limitReached then
		if "up" == direction then
			print( "Reached Top Limit" )
		elseif "down" == direction then
			print( "Reached Bottom Limit" )
		elseif "left" == direction then
			print( "Reached Left Limit" )
		elseif "right" == direction then
			print( "Reached Right Limit" )
		end
	end
			
	return true
end

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	print("HOME")
	homeBtn.isVisible = false
	tabGroup.isVisible = false
	scrollView.isVisible = false
	storyboard.removeScene("mainmenu")
	storyboard.removeScene("reloadscores")
	audio.stop(bgMusic)
	storyboard.gotoScene("reloadscores")
	return true
end

--------------  FUNCTIONS FOR DISPLAYING SCORES --------------------
function displayByCategory(category)
	
	local count = 0
	local text = nil
	y = y + 20

	for row in db:nrows("SELECT * FROM FirstGame where category = '"..category.."'") do
		count = row.count
	end

	if count ~= 0 then
		text = display.newText(string.upper(category), 0, 0, font, 20)
		text.x = x
		text.y = y
		scrollView:insert(text)
		game1flag = true
	end

	for row in db:nrows("SELECT * FROM FirstGame where category = '"..category.."' order by CAST(score AS integer) desc") do
		scores = display.newText(row.name.. " : " .. row.score, 0, 0, font, 20)
		scores.x = x
		scores.y = y + 20
		scores:setTextColor(0,0,0)
		scrollView:insert(scores)
		y = y + 20
		game1flag = true
	end

end

function displayGame1()

	x = display.contentCenterX 
	y = 10

	if game1flag == false then
		displayByCategory("easy")
		displayByCategory("medium")
		displayByCategory("hard")
	end

end

function displayGame2()

end

function displayGame3()

end

function scene:createScene( event )

	bgMusic = event.params.music

	--Scrollbar
	display.setStatusBar( display.HiddenStatusBar ) 
	display.setDefault( "background", 176, 224, 230)

	-- Create a ScrollView
	scrollView = widget.newScrollView
	{
		left = 0,
		top = 0,
		width = display.contentWidth + 30,
		height = display.contentHeight - 80,
		bottomPadding = 50,
		id = "onBottom",
		hideBackground = true,
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		listener = scrollListener,
	}

	-- back to home
	homeBtn = display.newImage( "images/firstgame/home_button.png")
	homeBtn.x = display.contentWidth
	homeBtn.y = 30
	homeBtn:addEventListener("touch", home)

	tabGroup = display.newGroup()
	scoresGroup = display.newGroup()

	local tabButtons = 
	{
		{
			width = 32, height = 32,
			defaultFile = "assets/tabIcon.png",
			overFile = "assets/tabIcon-down.png",
			label = "Game 1",
			onPress = displayGame1,
			selected = true
		},
		{
			width = 32, height = 32,
			defaultFile = "assets/tabIcon.png",
			overFile = "assets/tabIcon-down.png",
			label = "Game 2",
--			onPress = displayGame2,
		},
		{
			width = 32, height = 32,
			defaultFile = "assets/tabIcon.png",
			overFile = "assets/tabIcon-down.png",
			label = "Game 3",
--			onPress = displayGame3,
		}
	}
	--tabGroup:insert(tabButtons)

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