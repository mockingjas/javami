-- slideView.lua
-- 
-- Version 1.0 
--
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.

module(..., package.seeall)
local storyboard = require ("storyboard")
local scene = storyboard.newScene()

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local imgNum = nil
local images = nil
local touchListener, nextImage, prevImage, cancelMove, initImage
local background
local imageNumberText, imageNumberTextShadow
local g

--------------  FUNCTION FOR GO BACK TO MENU --------------------
function home(event)
	audio.stop()
	g.isVisible = false
	storyboard.removeScene("mainmenu")
	storyboard.removeScene("slideView")
	storyboard.gotoScene("reloadinstructions")
end

function new( imageSet, slideBackground, top, bottom )	
	local pad = 25
	local top = top or 0 
	local bottom = bottom or 0

	g = display.newGroup()
	background = display.newRect( 0, 0, 570, 320)
	background:setFillColor(0, 0, 0)
	g:insert(background)
	
	images = {}
	for i = 1,#imageSet do
		local p = display.newImage(imageSet[i])
		g:insert(p)
	    p.x = display.contentWidth/2;
	    p.y = display.contentHeight/2;

	    if (i > 1) then
			p.x = screenW * 2 + pad-- all images offscreen except the first one
		end

		images[i] = p
	end
	
	imgNum = 1

	-- home button
	homeBtn = display.newImage( "images/firstgame/home_button.png")
	homeBtn.x = 0
	homeBtn.y = 30
	homeBtn:addEventListener("touch", home)
	g:insert(homeBtn)
	
	function touchListener (self, touch) 
		local phase = touch.phase
		if ( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the contentBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true

			startPos = touch.x
			prevPos = touch.x
									
        elseif( self.isFocus ) then
        
			if ( phase == "moved" ) then
						
				if tween then transition.cancel(tween) end			
				local delta = touch.x - prevPos
				prevPos = touch.x
				
				images[imgNum].x = images[imgNum].x + delta
				
				if (images[imgNum-1]) then
					images[imgNum-1].x = images[imgNum-1].x + delta
				end
				
				if (images[imgNum+1]) then
					images[imgNum+1].x = images[imgNum+1].x + delta
				end

			elseif ( phase == "ended" or phase == "cancelled" ) then
				
				dragDistance = touch.x - startPos
				
				
				if (dragDistance < -40 and imgNum < #images and dragDistance ~= 0) then
				
					nextImage()
				elseif (dragDistance > 40 and imgNum > 1 and dragDistance ~= 0) then
					if(imgNum ~= 1) then
						
						prevImage()
					end
				else
				
					--cancelMove()
					if(dragDistance ~= 0) then
						cancelMove()
					end
				end
									
				if ( phase == "cancelled" ) then	
				
					--cancelMove()
				end

                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
														
			end
		end
					
		return true
		
	end
	
	function cancelTween()
		if prevTween then 
			transition.cancel(prevTween)
		end
		prevTween = tween 
	end
	
	function nextImage()
		tween = transition.to( images[imgNum], {time=400, x=(screenW*.5 + 110)*-1, transition=easing.outExpo } )
		tween = transition.to( images[imgNum+1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		imgNum = imgNum + 1
		--initImage(imgNum)
	end
	
	function prevImage()
		tween = transition.to( images[imgNum], {time=400, x=(screenW*2)+pad+ 110, transition=easing.outExpo } )
		tween = transition.to( images[imgNum-1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		imgNum = imgNum - 1
		--initImage(imgNum)
	end
	
	function cancelMove()
		tween = transition.to( images[imgNum], {time=400, x=screenW*.5, transition=easing.outExpo } )
		--tween = transition.to( images[imgNum-1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		--tween = transition.to( images[imgNum+1], {time=400, x=screenW*.5, transition=easing.outExpo } )
	end
	
	function initImage(num)
		if (num < #images) then
			images[num+1].x = screenW*1.5 + pad			
		end
		if (num > 1) then
			images[num-1].x = (screenW*.5 + pad)*-1
		end
		--setSlideNumber()
	end

	background.touch = touchListener
	background:addEventListener( "touch", background )

	------------------------
	-- Define public methods
	
	function g:jumpToImage(num)
		local i
		for i = 1, #images do
			if i < num then
				images[i].x = -screenW*.5;
			elseif i > num then
				images[i].x = screenW*1.5 + pad
			else
				images[i].x = screenW*.5 - pad
			end
		end
		imgNum = num
		initImage(imgNum)
	end

	function g:cleanUp()
		background:removeEventListener("touch", touchListener)
	end

	return g	
end

