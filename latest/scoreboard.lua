local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
local db = sqlite3.open("javami_DB.sqlite3")
local scores

local game1scores = function(event)
	i = 70
	for row in db:nrows("SELECT * FROM FirstGame") do
		scores = display.newText(row.category.." "..row.score, 0, 0, native.systemFont, 20)
		scores.x = 380; scores.y = i
		scores:setTextColor(0,0,0)
		screenGroup:insert(scores)
		i = i + 20
	end

end

-- IM COMING HOME
local backToMenu = function(event)
	screenGroup:removeSelf()
  	storyboard.gotoScene("mainmenu", "fade", 400)
end

function scene:createScene(event)

	screenGroup = self.view
	bg = display.newImageRect("images/firstgame/scores.png", 550, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)	

	game1 = widget.newButton{
		id = "game1",
		defaultFile = "game1.png",
		overFile = "game1over.png",
		emboss = true,
		onEvent = game1scores,
	}
	game1.x = 0; game1.y = 40
	screenGroup:insert(game1);

	game2 = display.newImageRect("game2.png", 70, 80)
	game2.x = 0
	game2.y = 120
	screenGroup:insert(game2);

	game3 = display.newImageRect("game3.png", 70, 80)
	game3.x = 0
	game3.y = 200
	screenGroup:insert(game3);

	back = widget.newButton{
		id = "home",
		defaultFile = "overall.png",
		label = "HOME",
		fontSize = 15,
		emboss = true,
		onEvent = backToMenu,
	}
	back.x = 0; back.y = 280
	screenGroup:insert(back);
	
end

function scene:enterScene(event)
	
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


