
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
scene.purgeOnSceneChange = true
local category, boolFirst, gameTimer, currScore, boolNew, pauseCtr, roundNumber, muted, gameMusic

function scene:createScene(event)
	local screenGroup = self.view
	print("RELOADING....")
	category = event.params.categ
	boolFirst = event.params.first
	gameTimer = event.params.time
	currScore = event.params.score
	boolNew = event.params.new
	gameMusic = event.params.music
	pauseCtr = event.params.pause
	roundNumber = event.params.round
	muted = event.params.mute
end
function scene:enterScene(event)
	local screenGroup = self.view	
	option = {
		effect = "fade",
		time = 400,
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
			round = roundNumber,
			mute = muted
		}
	}

	storyboard.removeScene("secondgame")
	storyboard.gotoScene("secondgame", option)
	storyboard.removeScene("reloadsecond")

end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)

return scene