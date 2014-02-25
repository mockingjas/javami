require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()
local gameScreen, tabGroup

function scene:createScene( event )

	local slideView = require("slideView")
	
	local myImages = {
		"images/menu/howtoplay1.png",
		"images/menu/howtoplay2.png",
		"images/menu/howtoplay3.png",
	}		

	slideView.new( myImages )	

end

function scene:enterScene( event )

end

function scene:exitScene( event )

end

function scene:destroyScene( event )

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene