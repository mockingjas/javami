-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require "sqlite3"
local lfs = require "lfs"
local storyboard = require "storyboard"
local path = system.pathForFile("JaVaMiaDb.sqlite3", system.ResourceDirectory)
db = sqlite3.open( path )

storyboard.gotoScene( "startmenu")
--[[for row in db:nrows("DELETE FROM SecondGame") do end
for row in db:nrows("DELETE FROM SecondGameAnalytics") do end
for row in db:nrows("DELETE FROM FirstGame") do end
for row in db:nrows("DELETE FROM FirstGameAnalytics") do end]]

for row in db:nrows("SELECT COUNT(*) as count FROM SecondGame") do
	if row.count == 0 then
		for row in db:nrows("UPDATE SQLITE_SEQUENCE SET seq = -1 WHERE name = 'SecondGame' ") do end		
	end
end

print("**DATABASE**")
for row in db:nrows("SELECT name FROM sqlite_master WHERE type='table';") do
	print(row.name)
end

for row in db:nrows("PRAGMA table_info(Words);") do print(row.name) end

--for row in db:nrows("UPDATE Words SET animalCategory = '1' where name ='show'") do	print(row.name) end
--[[for row in db:nrows("UPDATE Words SET name = 'catch' where name ='chili'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET livingThingCategory = '0' where name ='chili'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET animalCategory = '0' where name ='chili'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET livingThingCategory = '-1' where name ='leaf'") do	print(row.name) end]]

--for row in db:nrows("UPDATE Words SET livingThingCategory = '-1' where name ='fall'") do	print(row.name) end
--for row in db:nrows("UPDATE Words SET livingThingCategory = '0' where name ='key'") do	print(row.name) end
--for row in db:nrows("SELECT * from Words where name = 'key'") do	print(row.shapeCategory) end
--for row in db:nrows("UPDATE Words SET animalCategory = '1' where name ='worm'") do	print(row.name) end
--for row in db:nrows("UPDATE Words SET colorCategory = 'blue' where name ='good'") do	print(row.name) end
--for row in db:nrows("UPDATE Words SET colorCategory = 'blue' where name ='today'") do	print(row.name) end

--[[for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='white'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='brown'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='black'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='blue'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='green'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='orange'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='purple'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='red'") do	print(row.name) end
for row in db:nrows("UPDATE Words SET shapeCategory = 'rectangle' where name ='yellow'") do	print(row.name) end]]


--[[
print("\n\n")
words = ""
for row in db:nrows("SELECT * FROM Words where bodyPartCategory = '1'") do
	words = words .. "\n" .. row.name
	print(row.name)
end
-- Save to file
local path = system.pathForFile( "g2.txt", system.DocumentsDirectory )
local file = io.open( path, "w" )
file:write( words )
io.close( file )
file = nil]]

