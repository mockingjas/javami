
local storyboard = require ("storyboard")
local widget = require( "widget" )

local scene = storyboard.newScene()
local bgMusic = audio.loadSound("music/MainSong.mp3")
local backgroundMusicChannel

local startGame = function( event )
	option =	{
		effect = "fade",
		time = 400,
		params = {
			music = backgroundMusicChannel
		}
	}
	storyboard.gotoScene("mainmenu", option)
end

function scene:createScene(event)

	local screenGroup = self.view
	backgroundMusicChannel = audio.play( bgMusic, { loops=-1}  )

	bg = display.newImageRect("images/menu/bg_back.png", 570, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	buildings = display.newImage( "images/menu/ground.png" )
	buildings.x = display.contentWidth/2;
	buildings.y =  display.contentHeight/2;
	screenGroup:insert(buildings)
	
	clouds = display.newImage( "images/menu/bg2.png" )
	clouds.x = 0
	clouds.y =  display.contentHeight/2;
	clouds.speed = 2
	screenGroup:insert(clouds)

	clouds2 = display.newImage( "images/menu/bg2.png" )
	clouds2.x = 570
	clouds2.y = display.contentHeight/2;
	clouds2.speed = 2
	screenGroup:insert(clouds2)
	
	
	title = widget.newButton{
		id = "title",
		defaultFile = "images/menu/title.png",
		overFile = "images/menu/title_over.png",
		emboss = true,
		onEvent = startGame,
	}
	title.x = (display.contentWidth/2);
	title.y = (display.contentHeight/2) + 10;
	screenGroup:insert(title)

	helpText = display.newText("Tap the title to start game", 130, 210, Arial, 18)
	helpText:setTextColor(255, 255, 255)
	screenGroup:insert(helpText)
	
end

function moveBG(self,event)
	if self.x == -300 then
		self.x = 830
	else
		self.x = self.x - (self.speed)
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