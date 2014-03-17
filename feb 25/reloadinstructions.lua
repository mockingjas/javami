
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
local bgMusic = audio.loadSound("music/MainSong.mp3")
local backgroundMusicChannel

function scene:createScene(event)

end

function scene:enterScene(event)
	option =	{
		effect = "fade",
		time = 400,
		params = {
			music = backgroundMusicChannel
		}
	}
	storyboard.removeScene("instructions")
	storyboard.gotoScene("mainmenu", option)
	storyboard.removeScene("reloadinstructions")
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