require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()
--Modal 
local dialog
local msgText
local easyBtn
local mediumBtn
local hardBtn
local easy
local medium
local hard

local button1 = function( event )
-- MODAL 
	function _destroyDialog()
		dialog:removeSelf()
		easyBtn:removeSelf()
		mediumBtn:removeSelf()
		hardBtn:removeSelf()
	end
	-- 

	--PASS PARAMETERS TO NEXT SCENE
	easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
		}
	}

	medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
		}
	}

	hard =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "hard",
		}
	}

	function easy_onBtnRelease()
		_destroyDialog()
		storyboard.gotoScene("firstgame", easy)
		return true
	end

	function medium_onBtnRelease()
		_destroyDialog()
		storyboard.gotoScene("firstgame", medium)
		return true
	end

	function hard_onBtnRelease()
		_destroyDialog()
		storyboard.gotoScene("firstgame", hard)
		return true
	end
	-- 
	function showDialog()
		physics.pause()
		isPause = true
	 	 
	 	dialog = display.newImage("images/modal/modal_bg.png")
	 	dialog.x = display.contentWidth/2;
	 
		easyBtn = widget.newButton{
			defaultFile="images/modal/level_easy2.png",
			overFile="images/modal/level_easy2.png",
			onRelease = easy_onBtnRelease -- event listener function
		}
		easyBtn:setReferencePoint( display.CenterReferencePoint )
		easyBtn.x = bg.x
		easyBtn.y = 50

		mediumBtn = widget.newButton{
			defaultFile="images/modal/level_medium2.png",
			overFile="images/modal/level_medium2.png",
			onRelease = medium_onBtnRelease	-- event listener function
		}
		mediumBtn:setReferencePoint( display.CenterReferencePoint )
		mediumBtn.x = bg.x
		mediumBtn.y = 150

		hardBtn = widget.newButton{
			defaultFile="images/modal/level_hard2.png",
			overFile="images/modal/level_hard2.png",
			onRelease = hard_onBtnRelease	-- event listener function
		}
		hardBtn:setReferencePoint( display.CenterReferencePoint )
		hardBtn.x = bg.x
		hardBtn.y = 230
	 
	end
	showDialog()
end

function scene:createScene(event)

	local screenGroup = self.view

	bg = display.newImageRect("images/menu/bg_back.png", 570, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	-- an image sheet with purple house
	local sheet1 = graphics.newImageSheet( "images/menu/purple.png", { width=158, height=212, numFrames=2 } )
	local instance1 = display.newSprite( sheet1, { name="purple", start=1, count=2, time=1000 } )
	instance1.x = 40
	instance1.y = 185
	instance1:play()
	screenGroup:insert(instance1)
	
	instance1:addEventListener("tap", button1)
	screenGroup: insert(instance1)
	
	-- an image sheet with orange house
	local sheet2 = graphics.newImageSheet( "images/menu/orange.png", { width=188, height=212, numFrames=2 } )
	local instance2 = display.newSprite( sheet2, { name="orange", start=1, count=2, time=1000 } )
	instance2.x = 220
	instance2.y = 210
	instance2:play()
	screenGroup:insert(instance2)
	--instance2:addEventListener("tap", button1)
	
	
	-- an image sheet with orange house
	local sheet3 = graphics.newImageSheet( "images/menu/blue.png", { width=220, height=160, numFrames=2 } )
	local instance3 = display.newSprite( sheet3, { name="blue", start=1, count=2, time=1000 } )
	instance3.x = 410
	instance3.y = 240
	instance3:play()
	screenGroup:insert(instance3)
	--instance2:addEventListener("tap", button1)
	
	bg_ground = display.newImageRect("images/menu/ground.png", 570, 320)
	bg_ground.x = display.contentWidth/2;
	bg_ground.y = display.contentHeight/2;
	screenGroup:insert(bg_ground)
	
	
end

scene:addEventListener("createScene", scene)

return scene