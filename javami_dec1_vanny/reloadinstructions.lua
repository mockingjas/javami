
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()

function scene:createScene(event)

end

function scene:enterScene(event)
	storyboard.removeScene("instructions")
	storyboard.gotoScene("mainmenu", "fade", 400)
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