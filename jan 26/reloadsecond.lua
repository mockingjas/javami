
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
local text, category, boolFirst, gameTimer, currScore, itemCtr, itemCheck, itemSpeed, boolNew, pauseCtr, roundNumber

function scene:createScene(event)
	local screenGroup = self.view
	print("RELOADING....")
	boolFirst = event.params.first
	gameTimer = event.params.time
	category = event.params.categ
	currScore = event.params.score
	itemCtr = event.params.ctr
	itemCheck = event.params.check
	itemSpeed = event.params.speed
	boolNew = event.params.new
	pauseCtr = event.params.pause
	roundNumber = event.params.round
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
			ctr = itemCtr,
			check = itemCheck,
			speed = itemSpeed,
			new = boolNew,
			music = gameMusic,
			pause = pauseCtr,
			round = roundNumber
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