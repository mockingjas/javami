local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()

local button1 = function( event )
	storyboard.gotoScene("firstgame", "fade", 400)
end

function scene:createScene(event)

	local screenGroup = self.view

	bg = display.newImageRect("bg.png", 570, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	first = widget.newButton{
		id = "first",
		defaultFile = "buttonOrange.png",
		overFile = "buttonBlue.png",
		label = "First Game",
		fontSize = 20,
		emboss = true,
		onEvent = button1,
	}

	first.x = 350; first.y = 80
	screenGroup:insert(first)
	
	second = widget.newButton{
		id = "second",
		defaultFile = "buttonOrange.png",
		overFile = "buttonBlue.png",
		label = "Second Game",
		fontSize = 20,
		emboss = true,
		--onEvent = buttonHandler,
	}

	second.x = 350; second.y = 150
	screenGroup:insert(second)
	
	third = widget.newButton{
		id = "third",
		defaultFile = "buttonOrange.png",
		overFile = "buttonBlue.png",
		label = "Third Game",
		fontSize = 20,
		emboss = true,
		--onEvent = buttonHandler,
	}

	third.x = 350; third.y = 230
	screenGroup:insert(third)
	
end

scene:addEventListener("createScene", scene)

return scene