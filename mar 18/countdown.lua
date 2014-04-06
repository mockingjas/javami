-- REQUIREMENTS --
local widget = require( "widget" )
local storyboard = require ("storyboard")
local scene = storyboard.newScene()

local one, two, three, i, go
local house, category, game

local font
if "Win" == system.getInfo( "platformName" ) then
    font = "Cartwheel"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "Cartwheel"
end

------- Load sounds ---------
local countsound = audio.loadSound("music/countdown.mp3")
local gosound = audio.loadSound("music/go.mp3")

function loadgame()
	local easy =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "easy",
			first = true,
			score = 0,
			time = 3
		}
	}

	local medium =	{
		effect = "fade",
		time = 400,
		params = {
			categ = "medium",
			first = true,
			score = 0,
			time = 122
		}
	}

	local hard =	{
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
		if(category == "easy") then
--			storyboard.removeScene("gameOne")
			storyboard.gotoScene("GameOne", easy)
			storyboard.removeScene("Countdown")
		elseif(category == "medium") then
--			storyboard.removeScene("GameOne")
			storyboard.gotoScene("GameOne", medium)
			storyboard.removeScene("Countdown")
		else
--			storyboard.removeScene("GameOne")
			storyboard.gotoScene("GameOne", hard)	
			storyboard.removeScene("Countdown")
		end
	elseif(game == "two")  then
		if(category == "easy") then
--			storyboard.removeScene("GameTwo")
			storyboard.gotoScene("GameTwo", easy)
			storyboard.removeScene("Countdown")
		elseif(category == "medium") then
--			storyboard.removeScene("GameTwo")
			storyboard.gotoScene("GameTwo", medium)
			storyboard.removeScene("Countdown")
		else
	--		storyboard.removeScene("GameTwo")
			storyboard.gotoScene("GameTwo", hard)	
			storyboard.removeScene("Countdown")
		end	
	else
		if(category == "easy") then
--			storyboard.removeScene("GameThree")
			storyboard.gotoScene("GameThree", easy)
			storyboard.removeScene("Countdown")
		elseif(category == "medium") then
--			storyboard.removeScene("GameThree")
			storyboard.gotoScene("GameThree", medium)
			storyboard.removeScene("Countdown")
		else
--			storyboard.removeScene("GameThree")
			storyboard.gotoScene("GameThree", hard)	
			storyboard.removeScene("Countdown")
		end
	end

end

function show(event)
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
	category = event.params.categ
	game = event.params.game
	i = 3

	local screenGroup = self.view	
	one = display.newText("1", display.contentCenterX, display.contentCenterY, font, 200 )	
	two = display.newText("2", display.contentCenterX, display.contentCenterY, font, 200 )	
	three = display.newText("3", display.contentCenterX, display.contentCenterY, font, 200)
	go = display.newText("GO!", display.contentCenterX, display.contentCenterY, font, 200)

	if(game == "one") then
		bg = display.newImageRect("images/game_one/game3bg.png", 550, 320)
		one:setFillColor(0,0,0)
		two:setFillColor(0,0,0)
		three:setFillColor(0,0,0)
		go:setFillColor(0,0,0)
	elseif(game == "two") then
		bg = display.newImageRect("images/game_two/game2bg.png", 550, 320)
		one:setFillColor(0,0,0)
		two:setFillColor(0,0,0)
		three:setFillColor(0,0,0)
		go:setFillColor(0,0,0)
	else
		bg = display.newImageRect("images/game_three/board.png", 550, 320)
	end

	bg.x = display.contentCenterX;
	bg.y = display.contentCenterY;
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
scene:addEventListener("createScene", scene)

return scene