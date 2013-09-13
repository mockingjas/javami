
local storyboard = require ("storyboard")
local widget = require( "widget" )

local scene = storyboard.newScene()

local function startGame ( event )
	storyboard.gotoScene("mainmenu", "fade", 400)
end

function scene:createScene(event)

	local screenGroup = self.view

	bg = display.newImageRect("bg.png", 570, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)

	clouds = display.newImage( "bg2.png" )
	clouds.x = 0
	clouds.y =  display.contentHeight/2;
	screenGroup:insert(clouds)

	clouds2 = display.newImage( "bg2.png" )
	clouds2.x = 570;
	clouds2.y = display.contentHeight/2;
	screenGroup:insert(clouds2)
	
	title = widget.newButton{
		id = "title",
		defaultFile = "title.png",
		overFile = "title_over.png",
		emboss = true,
		onEvent = startGame,
	}
	title.x = display.contentWidth/2;
	title.y = 230;
	screenGroup:insert(title)

	helpText = display.newText("Tap the title to start game", display.contentWidth/6, 270, Arial, 25)
	helpText:setTextColor(255, 255, 255)
	screenGroup:insert(helpText)
	--[[
	start = widget.newButton{
		id = "start",
		defaultFile = "buttonOrange.png",
		overFile = "buttonBlue.png",
		label = "Start Game",
		fontSize = 20,
		emboss = true,
		onEvent = buttonHandler,
	}

	start.x = 250; start.y = 230
	screenGroup:insert(start)
	]]
end

function moveBG(self,event)
	if self.x == -300 then
		self.x = 850
	else
		self.x = self.x - 2
	end
end

function scene:enterScene(event)

	clouds.enterFrame = moveBG
    Runtime:addEventListener("enterFrame", clouds)
	
	clouds2.enterFrame = moveBG
    Runtime:addEventListener("enterFrame", clouds2)

	
end

function scene:exitScene(event)
	Runtime:removeEventListener("enterFrame", clouds)
	Runtime:removeEventListener("enterFrame", clouds2)
end

function scene:destroyScene(event)

end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene