local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()
local easy, one, two, three, i, go
local easy, medium, hard, house, categ, game

local font
if "Win" == system.getInfo( "platformName" ) then
    font = "Eraser"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "EraserRegular"
else
    -- Mac and iOS
    font = "Eraser-Regular"
end

------- Load sounds ---------
local countsound = audio.loadSound("music/countdown.mp3")
local gosound = audio.loadSound("music/go.mp3")


function loadgame()
	easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
			first = true,
			score = 0,
			time = 62
		}
	}

	medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
			first = true,
			score = 0,
			time = 122
		}
	}

	hard =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "hard",
			first = true,	
			score = 0,
			time = 182
		}
	}

	if(game == "one")  then
		if(categ == "easy") then
			storyboard.removeScene("firstgame")
			storyboard.gotoScene("firstgame", easy)
			storyboard.removeScene("countdown")
		elseif(categ == "medium") then
			storyboard.removeScene("firstgame")
			storyboard.gotoScene("firstgame", medium)
			storyboard.removeScene("countdown")
		else
			storyboard.removeScene("firstgame")
			storyboard.gotoScene("firstgame", hard)	
			storyboard.removeScene("countdown")
		end
	elseif(game == "two")  then
		if(categ == "easy") then
			storyboard.removeScene("secondgame")
			storyboard.gotoScene("secondgame", easy)
			storyboard.removeScene("countdown")
		elseif(categ == "medium") then
			storyboard.removeScene("secondgame")
			storyboard.gotoScene("secondgame", medium)
			storyboard.removeScene("countdown")
		else
			storyboard.removeScene("secondgame")
			storyboard.gotoScene("secondgame", hard)	
			storyboard.removeScene("countdown")
		end	
	else
		if(categ == "easy") then
			storyboard.removeScene("thirdgame")
			storyboard.gotoScene("thirdgame", easy)
			storyboard.removeScene("countdown")
		elseif(categ == "medium") then
			storyboard.removeScene("thirdgame")
			storyboard.gotoScene("thirdgame", medium)
			storyboard.removeScene("countdown")
		else
			storyboard.removeScene("thirdgame")
			storyboard.gotoScene("thirdgame", hard)	
			storyboard.removeScene("countdown")
		end
	end


end



function show(event)
	print("in function show".. i)
	if(i == 1) then
		two.isVisible = false
		one.isVisible = true
		one.alpha = 0
		transition.to(one, {time=2000, alpha=1, effect ="zoomInOut"})
		audio.play(countsound)
		i = i - 1
	elseif(i == 2) then
		three.isVisible = false
		two.isVisible = true
		two.alpha = 0
		transition.to(two, {time=2000, alpha=1, effect ="zoomInOut"})
		audio.play(countsound)
		i = i - 1
	elseif(i == 3) then
		three.isVisible = true
		three.alpha = 0
		transition.to(three, {time=2000, alpha=1, effect ="zoomInOut"})
		audio.play(countsound)
		i = i - 1
	elseif(i == 0) then
		one.isVisible = false
		go.isVisible = true
		go.alpha = 1
		transition.to(go, {time=1000, alpha=1, effect ="zoomInOut"})
		audio.play(gosound)
		i = i - 1
	else
		loadgame()
	end
end


function scene:createScene(event)
	
	--Params
	categ = event.params.categ
	game = event.params.game
	i = 3
	print(i)

	-- Screen Elements
	local screenGroup = self.view
	
	--countdown
	one = display.newText("1", display.contentWidth/2 - 40, display.contentHeight/2 - 100, font, 180 )	
	two = display.newText("2", display.contentWidth/2 - 60, display.contentHeight/2 - 110, font, 180 )	
	three = display.newText("3", display.contentWidth/2 - 60, display.contentHeight/2 - 100, font, 180)
	go = display.newText("GO", display.contentWidth/2 - 110, display.contentHeight/2 - 100, font, 160)

	if(game == "one") then
		bg = display.newImageRect("images/firstgame/board.png", 550, 320)
	elseif(game == "two") then
		bg = display.newImageRect("images/secondgame/game2bg.png", 550, 320)
		one:setTextColor(0,0,0)
		two:setTextColor(0,0,0)
		three:setTextColor(0,0,0)
		go:setTextColor(0,0,0)
	else
		bg = display.newImageRect("images/thirdgame/game3bg.png", 550, 320)
		one:setTextColor(0,0,0)
		two:setTextColor(0,0,0)
		three:setTextColor(0,0,0)
		go:setTextColor(0,0,0)
	end


	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	screenGroup:insert(one)
	screenGroup:insert(two)	
	screenGroup:insert(three)
	screenGroup:insert(go)

	three.isVisible = false
	two.isVisible = false
	one.isVisible = false
	go.isVisible = false

	timer.performWithDelay(1000, show, 5)

end

function scene:enterScene(event)
	local screenGroup = self.view

	--storyboard.removeScene("firstgame")
	--storyboard.gotoScene("firstgame", option)
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