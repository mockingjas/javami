require "physics"
local storyboard = require ("storyboard")
local widget= require ("widget")
local scene = storyboard.newScene()

-- Level Select Modal Variables --
local bgMusic
local name, email, age-- forward reference (needed for Lua closure)
 
------- Load font ---------
local font
if "Win" == system.getInfo( "platformName" ) then
    font = "Eraser"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "EraserRegular"
else
    -- Mac and iOS
    font = "Eraser-Regular"
end

local function textListener( event )
	if(event.phase == "began") then
		
	elseif(event.phase == "editing") then
	elseif(event.phase == "ended") then
		name.text = event.target.text
	end
end

function scene:createScene(event)

	local screenGroup = self.view

	bgMusic = event.params.music

	bg = display.newImageRect("images/bgemail.png", 570, 320)
	bg.x = display.contentWidth/2;
	bg.y = display.contentHeight/2;
	screenGroup:insert(bg)
	
	-- Create our Text Field
	namelabel = display.newText("Kid's name", 50, 100, font, 25)
	namelabel:setTextColor(0,0,0)
	name = native.newTextField( 220, 100, 180, 30 )    -- passes the text field object
    name:setTextColor( 255,255,255)
    name.hasBackground = false
    name.hintText = "Ross Geller"
   	name.text = name.hintText
   	screenGroup:insert(namelabel)
   	screenGroup:insert(name)

   	agelabel = display.newText("Kid's Age", 50, 140, font, 25)
   	agelabel:setTextColor(0,0,0)
	age = native.newTextField( 220, 140, 100, 30 )    -- passes the text field object
    age:setTextColor( 255,255,255)
    age.hasBackground = false
   	age.inputType = "number"
   	age.hintText = "5"
   	age.text = age.hintText

   	screenGroup:insert(agelabel)
   	screenGroup:insert(age)

   	emaillabel = display.newText("Teacher/Parent's Email", 50, 180, font, 25)
   	emaillabel:setTextColor(0,0,0)
	email = native.newTextField( 50, 210, 300, 30 )    -- passes the text field object
    email:setTextColor( 255,255,255)
    email.hasBackground = false
   	email.inputType = "email"
   	email.hintText = "drgeller@friends.org"
   	email.text = email.hintText
   	screenGroup:insert(emaillabel)
   	screenGroup:insert(email)

   	submit = widget.newButton{
		id = "submit",
		defaultFile = "images/firstgame/submit_button.png",
		fontSize = 15,
		emboss = true,
		--onEvent = checkanswer,
	}
	submit.x = 430; submit.y = 270
	screenGroup:insert(submit)

	name:addEventListener( "userInput", textListener)
	age:addEventListener( "userInput", textListener)
	email:addEventListener( "userInput", textListener)







end

scene:addEventListener("createScene", scene)

return scene