module(..., package.seeall)

-------------------------------
-- imports
-------------------------------
--local utils = require("utils")

-------------------------------
-- variables
-------------------------------
--- public

--- private

--- functions
local trueDestroy;
local bg;

-------------------------------
-- private functions
-------------------------------
function trueDestroy(toast)
    bg.setVisible = false
    toast:removeSelf();
    toast = nil;
end

-------------------------------
-- public functions
-------------------------------
function new(pText, pTime)

    local text = pText or "nil";
    local pTime = pTime;
    local toast = display.newGroup();

    bg = display.newImage( "images/wrong.png", 10, 10 )
    bg:setFillColor(72, 64, 72)
    toast:insert(bg)

    toast.text                      = display.newText(toast, pText, 15, -105, native.systemFont, 12);
    toast.text.align                = "center"
    toast.background                = display.newRoundedRect( toast, 0, -115, toast.text.width + 24, toast.text.height + 24, 16 );
    toast.background.strokeWidth    = 4
    toast.background:setFillColor(72, 64, 72)
    toast.background:setStrokeColor(96, 88, 96)
--    toast.background:setStrokeColor(96, 88, 96)

  --  toast.text:toFront();

--    toast:setReferencePoint(toast.width*.5, toast.height*.5)
    --utils.maintainRatio(toast);

    toast.alpha = 0;
    toast.transition = transition.to(toast, {time=250, alpha = 1});

    if pTime ~= nil then
        timer.performWithDelay(pTime, function() destroy(toast) end);
    end

    toast.x = 0
    toast.y = 0

    return toast;
end

function destroy(toast)
    toast.transition = transition.to(toast, {time=250, alpha = 0, onComplete = function() trueDestroy(toast) end});
end