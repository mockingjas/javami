-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require "sqlite3"
local db = sqlite3.open("JAVAMIADB.sqlite3")
local file
local storyboard = require "storyboard"
storyboard.gotoScene( "startmenu" )

--File handling functions
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

function fileToArray(path)
	if existsFile(path) then
		file = io.open(path, "r");
		local arr=""
		for line in file:lines() do
			arr = arr.."\n"..line
		end
		return arr
	end
end

--File handling 
--local path = "C:\\Users\\Maricia\\Documents\\GitHub\\javami\\cha2\\populator.txt" -- change -__-
local path = "populator.txt"
print(existsFile(path))
local wordsFromFile = fileToArray(path)
local words = {}
local images = {}
local audio = {}

i = 1
for j in string.gmatch(wordsFromFile, "[^%s]+") do
	words[i] = j
	images[i] = words[i]..".jpg"
	audio[i] = words[i]..".wav"
	print(words[i].." "..images[i].." "..audio[i])
	i = i+1
end
file:close()
 
function insertToDB(array, category)
	for i=1,#array do
		local insertQuery = [[INSERT INTO Words VALUES (NULL, ']] .. 
		array[i] .. [[',']] .. 
		category .. [[',']] .. 
		images[i] .. [[', ']] .. 
		audio[i] .. [['); ]]
		db:exec(insertQuery)
	end
end

-- CREATE TABLE
local createTable = [[CREATE TABLE IF NOT EXISTS Words(id INTEGER PRIMARY KEY autoincrement, name, category, imageFN, audioFN);]]
db:exec(createTable)

-- INSERT TO DB IF EMPTY
local count
for row in db:nrows("SELECT count(*) AS count FROM Words") do
count = row.count
end

if count == 0 then
	insertToDB(words, "easy")
end
print("COUNT!"..count)
