require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()

-- Level Select Modal Variables --
local levelgroup, easy, medium, hard
local instance1, instance2, instance3, scores

------ GAME 1 Level Select Modal -------
local function button1 ( event )

	-- PARAMETERS TO PASS TO NEXT SCENE
	easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
			first = true,
			score = 0,
			time = 61
		}
	}

	medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
			first = true,
			score = 0,
			time = 121
		}
	}

	hard =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "hard",
			first = true,	
			score = 0,
			time = 181		
		}
	}
	function easy_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("firstgame", easy)
		return true
	end

	function medium_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("firstgame", medium)
		return true
	end

	function hard_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("firstgame", hard)
		return true
	end

	function exit_onBtnRelease()
		levelgroup:removeSelf()
		return true
	end
	-- 
	
	showlevelDialog()
	
end
-------------- END OF GAME 1 ------------

------ GAME 2 Level Select Modal -------
local function button2 ( event )

	-- INSERT PARAMETERS TO PASS TO NEXT SCENE
	easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
			first = true,
			time = 61
		}
	}

	medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
			first = true,
			time = 121
		}
	}

	hard =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "hard",
			first = true,
			time = 181			
		}
	}

	function easy_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("secondgame", easy)
		return true
	end

	function medium_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("secondgame", medium)
		return true
	end

	function hard_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("secondgame" , hard)
		return true
	end

	function exit_onBtnRelease()
		levelgroup:removeSelf()
		return true
	end
	
	showlevelDialog()
	
end
------ END OF GAME 2 -------

------ GAME 3 Level Select Modal -------
local function button3 ( event )

	-- INSERT PARAMETERS TO PASS TO NEXT SCENE
	easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
			first = true,
			time = 61
		}
	}

	medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
			first = true,
			time = 121
		}
	}

	hard =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "hard",
			first = true,
			time = 181			
		}
	}
	
	function easy_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("thirdgame" , easy)
		return true
	end

	function medium_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("thirdgame", medium)
		return true
	end

	function hard_onBtnRelease()
		levelgroup:removeSelf()
		storyboard.gotoScene("thirdgame", hard)
		return true
	end
	
	function exit_onBtnRelease()
		levelgroup:removeSelf()
		return true
	end
	
	showlevelDialog()
	
end
-------- END OF GAME 3 ----------

function showlevelDialog()
	physics.pause()
	isPause = true
 	
 	levelgroup = display.newGroup()

	local rect = display.newImage("images/modal/gray.png")
 	rect.x = display.contentWidth/2;
 	rect:addEventListener("touch", function() return true end)
	rect:addEventListener("tap", function() return true end)
	levelgroup:insert(rect)

	local dialog = display.newImage("images/modal/levelselect_wood.png")
 	dialog.x = display.contentWidth/2;
 	levelgroup:insert(dialog)

	local easyBtn = widget.newButton{
		defaultFile="images/modal/Easy.png",
		overFile="images/modal/Easy.png",
		onRelease = easy_onBtnRelease -- event listener function
	}
	easyBtn:setReferencePoint( display.CenterReferencePoint )
	easyBtn.x = bg.x - 5
	easyBtn.y = 115
	levelgroup:insert(easyBtn)

	local mediumBtn = widget.newButton{
		defaultFile="images/modal/Medium.png",
		overFile="images/modal/Medium.png",
		onRelease = medium_onBtnRelease	-- event listener function
	}
	mediumBtn:setReferencePoint( display.CenterReferencePoint )
	mediumBtn.x = bg.x
	mediumBtn.y = 190
	levelgroup:insert(mediumBtn)

	local hardBtn = widget.newButton{
		defaultFile="images/modal/Hard.png",
		overFile="images/modal/Hard.png",
		onRelease = hard_onBtnRelease	-- event listener function
	}
	hardBtn:setReferencePoint( display.CenterReferencePoint )
	hardBtn.x = bg.x - 5
	hardBtn.y = 250
	levelgroup:insert(hardBtn)

	local exitBtn = widget.newButton{
		defaultFile="images/modal/closebutton.png",
		overFile="images/modal/closebutton.png",
		onRelease = exit_onBtnRelease	-- event listener function
	}
	exitBtn:setReferencePoint( display.CenterReferencePoint )
	exitBtn.x = bg.x + 115
	exitBtn.y = 67
	levelgroup:insert(exitBtn)

end

local goToScoreboard = function(event)
	storyboard.gotoScene("scoreboard", "fade", 400)
end

function scene:createScene(event)

	local screenGroup = self.view

	bg = display.newImageRect("images/menu/bg_back.png", 570, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	-- an image sheet with purple house
	local sheet1 = graphics.newImageSheet( "images/menu/purple.png", { width=158, height=212, numFrames=2 } )
	instance1 = display.newSprite( sheet1, { name="purple", start=1, count=2, time=1000 } )
	instance1.x = 40
	instance1.y = 185
	instance1:play()
	screenGroup:insert(instance1)
	
	instance1:addEventListener("tap", button1)
	screenGroup: insert(instance1)
	
	-- an image sheet with orange house
	local sheet2 = graphics.newImageSheet( "images/menu/orange.png", { width=188, height=212, numFrames=2 } )
	instance2 = display.newSprite( sheet2, { name="orange", start=1, count=2, time=1000 } )
	instance2.x = 220
	instance2.y = 210
	instance2:play()
	screenGroup:insert(instance2)
	instance2:addEventListener("tap", button2)
	
	
	-- an image sheet with orange house
	local sheet3 = graphics.newImageSheet( "images/menu/blue.png", { width=220, height=160, numFrames=2 } )
	instance3 = display.newSprite( sheet3, { name="blue", start=1, count=2, time=1000 } )
	instance3.x = 410
	instance3.y = 240
	instance3:play()
	screenGroup:insert(instance3)
	instance3:addEventListener("tap", button3)
	
	howtoplay = widget.newButton{
		id = "howtoplay",
		defaultFile = "images/menu/howtoplay.png",
		overFile = "images/menu/howtoplay.png",
		emboss = true,
	}
	howtoplay.x = (display.contentWidth/2) + 20;
	howtoplay.y = (display.contentHeight/2) - 100;
	screenGroup:insert(howtoplay)
	
	scores = widget.newButton{
		id = "scores",
		defaultFile = "images/menu/scores.png",
		overFile = "images/menu/scores.png",
		emboss = true,
	}
	scores.x = (display.contentWidth/2) + 160;
	scores.y = (display.contentHeight/2) - 65;
	screenGroup:insert(scores)
	
	bg_ground = display.newImageRect("images/menu/ground.png", 570, 320)
	bg_ground.x = display.contentWidth/2;
	bg_ground.y = display.contentHeight/2;
	screenGroup:insert(bg_ground)
	
end

scene:addEventListener("createScene", scene)

return scene