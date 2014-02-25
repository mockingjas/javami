
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
local text, category, boolFirst, gameTimer, currScore, roundNumber, correctCtr, roundSpeed, pauseCtr


function scene:createScene(event)
	
	local screenGroup = self.view
	print("RELOADING....")
	boolFirst = event.params.first
	gameTimer = event.params.time
	category = event.params.categ
	currScore = event.params.score
	roundNumber = event.params.roundctr
	correctCtr = event.params.correctcount
	roundSpeed = event.params.roundspeed
	pauseCtr = event.params.pausecount

	print("CUUUUURTIME SA RELOAD "..gameTimer)
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
			roundctr = roundNumber,
			first = boolFirst,
			correctcount = correctCtr,
			roundspeed = roundSpeed,
			pausecount = pauseCtr
		}
	}

	storyboard.removeScene("thirdgame")
	storyboard.gotoScene("thirdgame", option)
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