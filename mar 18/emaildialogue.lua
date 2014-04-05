require "physics"
local storyboard = require ("storyboard")
local widget = require( "widget" )
local scene = storyboard.newScene()

-- Level Select Modal Variables --
local bgMusic
local name, email, age, namedisplay, agedisplay, emaildisplay-- forward reference (needed for Lua closure)
 
------- Load font ---------
local font
if "Win" == system.getInfo( "platformName" ) then
    font = "Cartwheel"
elseif "Android" == system.getInfo( "platformName" ) then
    font = "Cartwheel Regular"
end

--temp
local userAge = 12
local username = "Cha"
local emailaddress = "mariciabalayan@gmail.com"

local function onSendEmail( event )
	local options =
	{
	   to = emailaddress,
	   subject = "Game Analytics",
	   body = "Name: "..username.."/nAge: "..userAge,
	   attachment = { baseDir=system.ResourceDirectory, filename="Game 1 Analytics.txt", type="text" },
	}
	native.showPopup("mail", options)
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
	namelabel:setFillColor(0,0,0)
	name = native.newTextField( 220, 100, 180, 30 )    -- passes the text field object
    name:setFillColor( 255,255,255)
    name.hasBackground = false
    name.hintText = "Ross Geller"
   	name.text = name.hintText
   	screenGroup:insert(namelabel)
   	screenGroup:insert(name)

   	agelabel = display.newText("Kid's Age", 50, 140, font, 25)
   	agelabel:setFillColor(0,0,0)
	age = native.newTextField( 220, 140, 100, 30 )    -- passes the text field object
    age:setFillColor( 255,255,255)
    age.hasBackground = false
   	age.inputType = "number"
   	age.hintText = "5"
   	age.text = age.hintText

   	screenGroup:insert(agelabel)
   	screenGroup:insert(age)

   	emaillabel = display.newText("Teacher/Parent's Email", 50, 180, font, 25)
   	emaillabel:setFillColor(0,0,0)
	email = native.newTextField( 50, 210, 300, 30 )    -- passes the text field object
    email:setFillColor( 255,255,255)
    email.hasBackground = false
   	email.inputType = "email"
   	email.hintText = "drgeller@friends.org"
   	email.text = email.hintText
   	screenGroup:insert(emaillabel)
   	screenGroup:insert(email)

   	local sendEmail = widget.newButton{
		defaultFile = "images/firstgame/submit_button.png",
		fontSize = 15,
		emboss = true,
		onRelease = onSendEmail
	}
	sendEmail.x = 430; sendEmail.y = 270
	screenGroup:insert(sendEmail)

	name:addEventListener( "userInput", textListener)
	age:addEventListener( "userInput", textListener)
	email:addEventListener( "userInput", textListener)

end

scene:addEventListener("createScene", scene)

return scene