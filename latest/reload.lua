
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
local text, category, boolFirst, gameTimer, currScore


function scene:createScene(event)
	
	local screenGroup = self.view
	
	print("RELOADING....")
	boolFirst = event.params.first
	gameTimer = event.params.time
	category = event.params.categ
	currScore = event.params.score
	
	bg = display.newImageRect("images/firstgame/blackboard.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
end

function scene:enterScene(event)
	local screenGroup = self.view
	option = {
		effect = "fade",
		time = 50,
		params = {
			categ = category,
			first = boolFirst,
			time = gameTimer,
			score = currScore,
		}
	}

	storyboard.removeScene("firstgame")
	storyboard.gotoScene("firstgame", option)
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