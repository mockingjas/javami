
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
local category, gameTimer


function scene:createScene(event)
	local screenGroup = self.view
	gameTimer = event.params.time
	category = event.params.categ
end

function scene:enterScene(event)
	local screenGroup = self.view
	option = {
		effect = "fade",
		time = 50,
		params = {
			categ = category,
			time = gameTimer,
		}
	}

	storyboard.removeScene("secondgame")
	storyboard.gotoScene("secondgame", option)
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene