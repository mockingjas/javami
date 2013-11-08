require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()

display.setDefault( "background", 255, 255, 255 )
local homeBtn, tabGroup, scrollView, scores

local db = sqlite3.open("javami_DB.sqlite3")

--[[local game1scores = function(event)
	i = 70
	for row in db:nrows("SELECT * FROM FirstGame") do
		scores = display.newText(row.category.." "..row.score, 0, 0, native.systemFont, 20)
		scores.x = 380; scores.y = i
		scores:setTextColor(0,0,0)
		screenGroup:insert(scores)
		i = i + 20
	end
end]]

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
	storyboard.gotoScene("reloadscores")
	return true
end

--------------  FUNCTIONS FOR DISPLAYING SCORES --------------------

function displayScores(text)
	if scores ~= nil then
		scores:removeSelf()
	end
	scores = display.newText(text, 0, 0, font, 15)
	scores.x = display.contentCenterX 
	scores.y = display.contentCenterY - 130
	scores:setTextColor(0,0,0)
	scrollView:insert(scores)
end

function displayGame1()
	displayScores("Scores1")
end

function displayGame2()
	displayScores("Scores2")
end

function displayGame3()
	displayScores("Scores3")
end

function scene:createScene( event )

	--Scrollbar
	display.setStatusBar( display.HiddenStatusBar ) 

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

	--Create a text object for the scrollViews title
	local titleText = display.newText("Move Up to Scroll", 0, 0, native.systemFontBold, 16)
	titleText:setTextColor(0, 0, 0)
	titleText.x = display.contentCenterX
	titleText.y = 48
	scrollView:insert( titleText )

	--Create a large text string
	local lotsOfText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur imperdiet consectetur euismod. Phasellus non ipsum vel eros vestibulum consequat. Integer convallis quam id urna tristique eu viverra risus eleifend.\n\nAenean suscipit placerat venenatis. Pellentesque faucibus venenatis eleifend. Nam lorem felis, rhoncus vel rutrum quis, tincidunt in sapien. Proin eu elit tortor. Nam ut mauris pellentesque justo vulputate convallis eu vitae metus. Praesent mauris eros, hendrerit ac convallis vel, cursus quis sem. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque fermentum, dui in vehicula dapibus, lorem nisi placerat turpis, quis gravida elit lectus eget nibh. Mauris molestie auctor facilisis.\n\nCurabitur lorem mi, molestie eget tincidunt quis, blandit a libero. Cras a lorem sed purus gravida rhoncus. Cras vel risus dolor, at accumsan nisi. Morbi sit amet sem purus, ut tempor mauris.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur imperdiet consectetur euismod. Phasellus non ipsum vel eros vestibulum consequat. Integer convallis quam id urna tristique eu viverra risus eleifend.\n\nAenean suscipit placerat venenatis. Pellentesque faucibus venenatis eleifend. Nam lorem felis, rhoncus vel rutrum quis, tincidunt in sapien. Proin eu elit tortor. Nam ut mauris pellentesque justo vulputate convallis eu vitae metus. Praesent mauris eros, hendrerit ac convallis vel, cursus quis sem. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque fermentum, dui in vehicula dapibus, lorem nisi placerat turpis, quis gravida elit lectus eget nibh. Mauris molestie auctor facilisis.\n\nCurabitur lorem mi, molestie eget tincidunt quis, blandit a libero. Cras a lorem sed purus gravida rhoncus. Cras vel risus dolor, at accumsan nisi. Morbi sit amet sem purus, ut tempor mauris. "

	--Create a text object containing the large text string and insert it into the scrollView
	local lotsOfTextObject = display.newText( lotsOfText, 0, 0, 300, 0, "Helvetica", 14)
	lotsOfTextObject:setTextColor( 0 ) 
	lotsOfTextObject:setReferencePoint( display.TopCenterReferencePoint )
	lotsOfTextObject.x = display.contentCenterX
	lotsOfTextObject.y = titleText.y + titleText.contentHeight + 10
	scrollView:insert( lotsOfTextObject )	

	-- back to home
	homeBtn = display.newImage( "images/firstgame/home_button.png")
	homeBtn.x = display.contentWidth
	homeBtn.y = 30
	homeBtn:addEventListener("touch", home)

	tabGroup = display.newGroup()

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
			onPress = displayGame2,
		},
		{
			width = 32, height = 32,
			defaultFile = "assets/tabIcon.png",
			overFile = "assets/tabIcon-down.png",
			label = "Game 3",
			onPress = displayGame3,
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


