-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

require "sqlite3"
local lfs = require "lfs"
--local savePath = system.ResourceDirectory
--local path = system.pathForFile("javamidb.sqlite3")
local db = sqlite3.open("javami_DB.sqlite3")
--db = sqlite3.open( path ) 
local file

local storyboard = require "storyboard"
storyboard.gotoScene( "startmenu" )

--Function for checking if file exists
function existsFile(path)
    x = io.open(path)
    if x == nil then
        io.close()
        return false
    else
        x:close()
        return true
    end
end

--Function for copying contents of file to array
function fileToArray(path)
	if existsFile(path) then
		file = io.open(path, "r");
		local arr= ""
		for line in file:lines() do
			arr = arr.."\n"..line
		end
		return arr
	end
end

--Function for inserting words to DB
function insertToDB(array, category)
	for i=1,#array do
		local insertQuery = [[INSERT INTO Words VALUES (NULL, ']] .. 
		array[i] .. [[',']] .. 
		category .. [[',']] ..
		"false" .. [['); ]]
		db:exec(insertQuery)
	end
end

--FILE HANDLING
--sira pa yung path, pachange nalang muna

--CHA
--local easyPath = "C:/Users/Maricia/Desktop/latest/text/easy_populator.txt" 
--local medPath = "C:/Users/Maricia/Desktop/latest/text/med_populator.txt"
--local hardPath = "C:/Users/Maricia/Desktop/latest/text/hard_populator.txt" 

--JAS
--local easyPath = "/Users/joyamendoza/Desktop/00JAS/00ACADS/4A/198 javami/javami/latest/text/easy_populator.txt" 	-- change this -_-
--local medPath = "/Users/joyamendoza/Desktop/00JAS/00ACADS/4A/198 javami/javami/latest/text/med_populator.txt" 	-- change this -_-
--local hardPath = "/Users/joyamendoza/Desktop/00JAS/00ACADS/4A/198 javami/javami/latest/text/hard_populator.txt" 	-- change this -_-

--VANNY
local easyPath = "C:/Users/y480/Desktop/latest/text/easy_populator.txt" 
local medPath = "C:/Users/y480/Desktop/latest/text/med_populator.txt"
local hardPath = "C:/Users/y480/Desktop/latest/text/hard_populator.txt" 

local easyArray = fileToArray(easyPath)
local easyWords = {}
for j in string.gmatch(easyArray, "[^%s]+") do
	easyWords[#easyWords+1] = j
end
file:close()

local medArray = fileToArray(medPath)
local medWords = {}
for j in string.gmatch(medArray, "[^%s]+") do
	medWords[#medWords+1] = j
end
file:close()

local hardArray = fileToArray(hardPath)
local hardWords = {}
for j in string.gmatch(hardArray, "[^%s]+") do
	hardWords[#hardWords+1] = j
end
file:close()

-- CREATE TABLE
local createTableWords = [[CREATE TABLE IF NOT EXISTS Words(id INTEGER PRIMARY KEY autoincrement, name, category, isCorrect);]]
db:exec(createTableWords)

local createTableGame1 = [[CREATE TABLE IF NOT EXISTS FirstGame(id INTEGER PRIMARY KEY autoincrement, category, score);]]
db:exec(createTableGame1)

-- INSERT WORDS TO DB IF EMPTY
local count
for row in db:nrows("SELECT count(*) AS count FROM Words") do
	count = row.count
end
if count == 0 then
	insertToDB(easyWords, "easy")
	insertToDB(medWords, "medium")
	insertToDB(hardWords, "hard")
end

for row in db:nrows("SELECT * FROM FirstGame") do
	print(row.category..row.score)
end

print("# of db entries:"..count)