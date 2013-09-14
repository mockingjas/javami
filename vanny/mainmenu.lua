local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()

local button1 = function( event )
	storyboard.gotoScene("firstgame", "fade", 400)
end

function scene:createScene(event)

	local screenGroup = self.view

	bg = display.newImageRect("bg_back.png", 570, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	-- an image sheet with purple house
	local sheet1 = graphics.newImageSheet( "purple.png", { width=158, height=212, numFrames=2 } )
	local instance1 = display.newSprite( sheet1, { name="purple", start=1, count=2, time=1000 } )
	instance1.x = 40
	instance1.y = 185
	instance1:play()
	screenGroup:insert(instance1)
	
	instance1:addEventListener("tap", button1)
	screenGroup: insert(instance1)
	
	-- an image sheet with orange house
	local sheet2 = graphics.newImageSheet( "orange.png", { width=188, height=212, numFrames=2 } )
	local instance2 = display.newSprite( sheet2, { name="orange", start=1, count=2, time=1000 } )
	instance2.x = 220
	instance2.y = 210
	instance2:play()
	screenGroup:insert(instance2)
	--instance2:addEventListener("tap", button1)
	
	
	-- an image sheet with orange house
	local sheet3 = graphics.newImageSheet( "blue.png", { width=220, height=160, numFrames=2 } )
	local instance3 = display.newSprite( sheet3, { name="blue", start=1, count=2, time=1000 } )
	instance3.x = 410
	instance3.y = 240
	instance3:play()
	screenGroup:insert(instance3)
	--instance2:addEventListener("tap", button1)
	
	bg_ground = display.newImageRect("ground.png", 570, 320)
	bg_ground.x = display.contentWidth/2;
	bg_ground.y = display.contentHeight/2;
	screenGroup:insert(bg_ground)
	
	
end

scene:addEventListener("createScene", scene)

return scene