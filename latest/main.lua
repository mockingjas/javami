-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

require "sqlite3"
local lfs = require "lfs"
local db = sqlite3.open("Game1_DB.sqlite3")
local file

local storyboard = require "storyboard"
storyboard.gotoScene( "startmenu" )

--
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
local easyPath = "C:/Users/Maricia/Desktop/latest/text/easy_populator.txt" 	-- change this -_-
local medPath = "C:/Users/Maricia/Desktop/latest/text/med_populator.txt" 	-- change this -_-
local hardPath = "C:/Users/Maricia/Desktop/latest/text/hard_populator.txt" 	-- change this -_-

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
local createTable = [[CREATE TABLE IF NOT EXISTS Words(id INTEGER PRIMARY KEY autoincrement, name, category, isCorrect);]]
db:exec(createTable)

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
print("# of db entries:"..count)