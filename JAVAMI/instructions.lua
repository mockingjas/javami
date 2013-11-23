require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()
local gameScreen, tabGroup

display.setDefault( "background", 255, 255, 255 )

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	if(event.phase == "ended") then
		gameScreen.isVisible = false
		tabGroup.isVisible = false
		storyboard.removeScene("mainmenu")
		storyboard.removeScene("reloadinstructions")
		storyboard.gotoScene("reloadinstructions")
		return true
  	end
end

--------------  FUNCTIONS FOR DISPLAYING INSTRUCTIONS --------------------

function displayScores(text)
	if gameScreen ~= nil then
		gameScreen:removeSelf()
	end
	gameScreen = display.newGroup()
	instructions = display.newText(text, 0, 0, font, 15)
	instructions.x = display.contentCenterX 
	instructions.y = display.contentCenterY - 130
	instructions:setTextColor(0,0,0)
	gameScreen:insert(instructions)

	-- home button
	homeBtn = display.newImage( "images/firstgame/home_button.png")
	homeBtn.x = display.contentWidth
	homeBtn.y = 30
	homeBtn:addEventListener("touch", home)
	gameScreen:insert(homeBtn)
end

function displayGame1()
	displayScores("Instructions1")
end

function displayGame2()
	displayScores("Instructions2")
end

function displayGame3()
	displayScores("Instructions3")
end

function scene:createScene( event )
	--[[ tabGroup = display.newGroup()

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

	displayGame1() ]]

	local slideView = require("slideView")
	
	local myImages = {
		"images/menu/howtoplay1.png",
		"images/menu/howtoplay2.png",
		"images/menu/howtoplay3.png",
	}		

	slideView.new( myImages )

end

function scene:enterScene( event )

end

function scene:exitScene( event )

end

function scene:destroyScene( event )

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene