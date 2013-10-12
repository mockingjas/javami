
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
local text
local category
local boolFirst
local gameTimer
local currScore

function restartLevel(target)
	option = {
		effect = "fade",
		time = 250,
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

function scene:createScene(event)
	
	local screenGroup = self.view
	
	print("RELOADING....")
	gameTimer = event.params.time
	category = event.params.categ
	currScore = event.params.score
	
	bg = display.newImageRect("images/firstgame/blackboard.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	text= display.newText("Correct!", 0, 0, native.systemFont, 20)
	text.x = display.contentCenterX
	text.y = display.contentCenterY
	text:setTextColor(255, 255, 255, 255)
	screenGroup:insert(text)
	
end

function scene:enterScene(event)
	local screenGroup = self.view
	
	text.alpha = 1.0
	transition.to(text, {time = 500, alpha= 0.0, onComplete = restartLevel})
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