-- LAYOUT: bgsize: 480 x 320 px
local bg = display.newImage( "images/bg2.png" )
bg.width = display.contentWidth;
bg.height = display.contentHeight;
bg.x = display.contentWidth/2;
bg.y = display.contentHeight/2;

-- WHITE BOUNDS ----------------------------------------------
local leftBound = display.newImage( "images/bound.png" )
leftBound.x = 7;
leftBound.y = bg.y;

local rightBound = display.newImage( "images/bound.png" )
rightBound.x = bg.width - 7;
rightBound.y = bg.y;

local upperBound = display.newImage( "images/horBound.png" )
upperBound.x = bg.x;
upperBound.y = 7;

local lowerBound = display.newImage( "images/horBound.png" )
lowerBound.x = bg.x;
lowerBound.y = bg.height - 7;
------------------------------------------------------------------

-- BLACK BOUNDS ---------------------------------------------------------
-- Below category
local categoryLine = display.newImage( "images/horizontal3.png" )
categoryLine.x = bg.x;
categoryLine.y = 50;

-- Above hints
local lettersLine = display.newImage( "images/horizontal3.png" )
lettersLine.x = bg.x;
lettersLine.y = 205;

local verticalLine = display.newImage( "images/vertical2.png" )
verticalLine.x = 130;
verticalLine.y = lettersLine.y /2;

-- Dotted image line
local imageArea = display.newImage( "images/image2.png" )
imageArea.x = (verticalLine.x + leftBound.x)/2;
imageArea.y = (lettersLine.y + categoryLine.y)/2;
------------------------------------------------------------------

local image = display.newImage( "images/apple2.png" )
image.x = imageArea.x;
image.y = imageArea.y;

local instructions = display.newText( "Drag the correct letters into the blanks!", 0, 0, native.systemFont, 20 )
instructions.x = (leftBound.x + rightBound.x)/2;
instructions.y = lettersLine.y + 15;

local category = display.newText( "CATEGORY", 0, 0, native.systemFont, 20 )
category.x = (verticalLine.x + leftBound.x)/2;
category.y = 30;

-- Upper blank
local score = display.newText( "005", 0, 0, native.systemFont, 30 )
score.x = rightBound.x - 40;
score.y = (upperBound.y + categoryLine.y)/2;

--LETTERS--------------------------------------------------------
local screenSize = rightBound.x - verticalLine.x - 50;
local numberOfLetters = 4				-- Depends on category
local letterSize = (screenSize / numberOfLetters) + 10;
local lettersX = verticalLine.x + 50 	-- x position ng current letter
local lettersY = (lettersLine.y + categoryLine.y)/2;
local fontSize = 80;

-- A
--local letter1 = display.newImage("images/blank2.png")
local letter1 = display.newText( "A", 0, 0, native.systemFont, fontSize )
letter1.x = lettersX
letter1.y = lettersY

-- P
local letter2 = display.newImage("images/blank2.png")
lettersX = lettersX + letterSize
letter2.x = lettersX
letter2.y = lettersY

-- P
local letter3 = display.newText( "P", 0, 0, native.systemFont, fontSize )
lettersX = lettersX + letterSize
letter3.x = lettersX
letter3.y = lettersY

-- L
local letter4 = display.newText( "L", 0, 0, native.systemFont, fontSize )
lettersX = lettersX + letterSize
letter4.x = lettersX
letter4.y = lettersY

--HINTS--------------------------------------------------------
local hintScreen = rightBound.x - leftBound.x;
local numberOfHints = 3	-- change per category
local hintSize = hintScreen / numberOfHints;
local hintsX = leftBound.x + 50;
local hintY = lowerBound.y - 40;

local hint1 = display.newText( "P", 0, 0, native.systemFont, fontSize )
hint1.x = hintsX
hint1.y = hintY

local hint2 = display.newText( "S", 0, 0, native.systemFont, fontSize )
hintsX = hintsX + hintSize
hint2.x = hintsX
hint2.y = hintY

local hint2 = display.newText( "S", 0, 0, native.systemFont, fontSize )
hintsX = hintsX + hintSize
hint2.x = hintsX
hint2.y = hintY
