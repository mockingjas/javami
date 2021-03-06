
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()

function scene:createScene(event)
	
end

function scene:enterScene(event)
	storyboard.removeScene("scoreboard")

	mainMusic = audio.loadSound("Happy Boy.mp3")
	backgroundMusicChannel = audio.play( mainMusic, { loops=-1}  )
	option =	{
		effect = "fade",
		time = 400,
		params = {
			music = backgroundMusicChannel
		}
	}
	storyboard.gotoScene("mainmenu", option)
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