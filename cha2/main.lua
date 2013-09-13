-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require "sqlite3"
local db = sqlite3.open("JAVAMIADB.sqlite3")
local storyboard = require "storyboard"
storyboard.gotoScene( "startmenu" )

--POPULATE

local easy = {"apple", "apple", "apple"}
local images = {"apple.jpg", "apple.jpg", "apple.jpg"}
local audio = {"1.wav", "2.wav", "3.wav"}
 
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
	insertToDB(easy, "easy")
end
print("COUNT!"..count)


