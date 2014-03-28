require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()
scene.purgeOnSceneChange = true

-- Level Select Modal Variables --
local levelgroup, easy, medium, hard
local instance1, instance2, instance3, scores, howtoplay, bgMusic, about, aboutgroup

------ GAME 1 Level Select Modal -------
local function button1 ( event )

	-- PARAMETERS TO PASS TO NEXT SCENE
	easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
			game = "one"
		}
	}

	medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
			game = "one"
		}
	}
	hard =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "hard",
			game = "one"
		}
	}

	
	function easy_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", easy)
		return true
	end

	function medium_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", medium)
		return true
	end

	function hard_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", hard)
		return true
	end

	function exit_onBtnRelease()
--		howtoplay:setEnabled(true)
--		scores:setEnabled(true)
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
--	howtoplay:setEnabled(false)
--	scores:setEnabled(false)

	easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
			game = "two"
		}
	}

	medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
			game = "two"
		}
	}
	hard =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "hard",
			game = "two"
		}
	}

	
	function easy_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", easy)
		return true
	end

	function medium_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", medium)
		return true
	end

	function hard_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", hard)
		return true
	end

	function exit_onBtnRelease()
--		howtoplay:setEnabled(true)
--		scores:setEnabled(true)
		levelgroup:removeSelf()
		return true
	end
	-- 
	
	showlevelDialog()
	
end
------ END OF GAME 2 -------

------ GAME 3 Level Select Modal -------
local function button3 ( event )

--	howtoplay:setEnabled(false)
--	scores:setEnabled(false)

	-- INSERT PARAMETERS TO PASS TO NEXT SCENE
	easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
			game = "three"
		}
	}

	medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
			game = "three"
		}
	}
	hard =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "hard",
			game = "three"
		}
	}

	
	function easy_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", easy)
		return true
	end

	function medium_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", medium)
		return true
	end

	function hard_onBtnRelease()
		levelgroup:removeSelf()
		audio.stop( bgMusic )
		storyboard.gotoScene("countdown", hard)
		return true
	end

	function exit_onBtnRelease()
--		howtoplay:setEnabled(true)
--		scores:setEnabled(true)
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

function exit_about()
--	howtoplay:setEnabled(true)
--	scores:setEnabled(true)
	aboutgroup.isVisible = false
	return true
end

function showaboutDialog(event)
	physics.pause()
--	howtoplay:setEnabled(false)
--	scores:setEnabled(false)
 	
 	aboutgroup = display.newGroup()

	local rectx = display.newImage("images/modal/gray.png")
 	rectx.x = display.contentWidth/2;
 	rectx:addEventListener("touch", function() return true end)
	rectx:addEventListener("tap", function() return true end)
	aboutgroup:insert(rectx)

	local dialogx = display.newImage("images/modal/about.png")
 	dialogx.x = display.contentWidth/2;
 	aboutgroup:insert(dialogx)

 	local myText1 = display.newText( "Developers", 100, 120, display.contentWidth, display.contentHeight * 0.5, native.systemFont, 16 )
 	myText1:setTextColor( black )
 	local myText = display.newText( "Balayan, Maricia Polene A.\nConoza, Vanessa Viel B.\nTolentino, Jasmine Mae M.", 100, 140, display.contentWidth, display.contentHeight * 0.5, native.systemFont, 14 )
 	aboutgroup:insert(myText)
 	aboutgroup:insert(myText1)

 	local uplogo = display.newImage("images/uplogo.jpg")
 	uplogo.x = 330
 	uplogo.y = 170
 	uplogo.width = 100
 	uplogo.height = 100
 	aboutgroup:insert(uplogo)

 	local upitdc = display.newImage("images/upitdc.png")
 	upitdc.x = 200
 	upitdc.y = 220
 	upitdc.width = 200
 	upitdc.height = 50
 	aboutgroup:insert(upitdc)

 	local disclaimer = "Disclaimer: Some of the photos used for two of the games are from the following sites: www.clipartlord.com, www.freedigitalphotos.net, www.pixabay.com, www.vectorstock.com, www.clker.com, www.clipartsfree.net, and www.alloflife.com. Music used is by Kevin McLeod, owner of Incompetech.com"
 	local myText2 = display.newText( disclaimer, 0, 280, display.contentWidth, display.contentHeight * 0.5, native.systemFont, 8 )
 	aboutgroup:insert(myText2)



	local exit = widget.newButton{
		defaultFile="images/modal/closebutton.png",
		overFile="images/modal/closebutton.png",
		onEvent = exit_about-- event listener function
	}
	exit:setReferencePoint( display.CenterReferencePoint )
	exit.x = bg.x + 170
	exit.y = 85
	aboutgroup:insert(exit)

end

function scene:createScene(event)
	storyboard.removeAll()
	local screenGroup = self.view

	bgMusic = event.params.music

	bg = display.newImageRect("images/menu/bg.png", 570, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	-- an image sheet with purple house
	local sheet1 = graphics.newImageSheet( "images/menu/purple.png", { width=158, height=212, numFrames=2 } )
	instance1 = display.newSprite( sheet1, { name="purple", start=1, count=2, time=1000 } )
	instance1.x = 420
	instance1.y = 205
	instance1:play()
	screenGroup:insert(instance1)
	
	instance1:addEventListener("tap", button1)
	screenGroup: insert(instance1)
	
	-- an image sheet with orange house
	local sheet2 = graphics.newImageSheet( "images/menu/orange.png", { width=188, height=212, numFrames=2 } )
	instance2 = display.newSprite( sheet2, { name="orange", start=1, count=2, time=1000 } )
	instance2.x = 245
	instance2.y = 220
	instance2:play()
	screenGroup:insert(instance2)
	instance2:addEventListener("tap", button2)
	
	
	-- an image sheet with orange house
	local sheet3 = graphics.newImageSheet( "images/menu/blue.png", { width=220, height=160, numFrames=2 } )
	instance3 = display.newSprite( sheet3, { name="blue", start=1, count=2, time=1000 } )
	instance3.x = 60
	instance3.y = 210
	instance3:play()
	screenGroup:insert(instance3)
	instance3:addEventListener("tap", button3)
	
	howtoplay = widget.newButton{
		id = "howtoplay",
		defaultFile = "images/menu/howtoplay.png",
		overFile = "images/menu/howtoplay.png",
		emboss = true,
		onEvent = function() storyboard.gotoScene( "instructions", "fade", 400 ); end,
	}
	howtoplay.x = (display.contentWidth/2);
	howtoplay.y = (display.contentHeight/2) - 100;
	screenGroup:insert(howtoplay)
	
	option =	{
		effect = "fade",
		time = 100,
		params = {
			music = bgMusic
		}
	}

	scores = widget.newButton{
		id = "scores",
		defaultFile = "images/menu/scores.png",
		overFile = "images/menu/scores.png",
		emboss = true,
		onEvent = function() storyboard.gotoScene( "scoreboard", option); end,
	}
	scores.x = (display.contentWidth/2) + 130;
	scores.y = (display.contentHeight/2) - 75;
	screenGroup:insert(scores)

	about = display.newImage("images/menu/about.png", 45, 45)
	about.x = (display.contentWidth/2) + 220;
	about.y = (display.contentHeight/2) - 100;
	about.width = 60
	about.height = 60
	about:addEventListener("tap", showaboutDialog)
	screenGroup:insert(about)

	bg_ground = display.newImageRect("images/menu/ground2.png", 570, 320)
	bg_ground.x = display.contentWidth/2;
	bg_ground.y = display.contentHeight/2;
	screenGroup:insert(bg_ground)
	
end

scene:addEventListener("createScene", scene)

return scene