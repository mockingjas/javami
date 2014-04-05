module(..., package.seeall)

local trueDestroy;
local bg;

function trueDestroy(toast)
    if bg ~= nil then
        bg.setVisible = false
    end
    toast:removeSelf();
    toast = nil;
end

function new(pText, pTime, xcoord, ycoord, game)

    local text = pText or "nil";
    local pTime = pTime;
    local toast = display.newGroup();

    if game == "firstgame_text" then 
        toast.text                      = display.newText(toast, pText, xcoord + 10, ycoord, native.systemFont, 12);
        toast.text.align                = "center"
        toast.background                = display.newRoundedRect( toast, xcoord, -115, toast.text.width + 24, toast.text.height + 24, 16 );
        toast.background.strokeWidth    = 4
        toast.background:setFillColor(72, 64, 72)
        toast.background:setStrokeColor(96, 88, 96)
        toast.text:toFront();
        toast.x = display.contentWidth * .5
        toast.y = display.contentHeight * .9
    elseif game == "secondgame" then
        bg = display.newImage( text )
        bg.xScale = bg.xScale * 1.5
        bg.yScale = bg.yScale * 1.5
        rect = display.newImage("images/modal/gray.png")
        toast:insert(rect)
        toast:insert(bg)
        toast:insert(bg)
        toast.anchorChildren = true
        toast.x = display.contentCenterX
        toast.y = display.contentCenterY
    else
        bg = display.newImage( text, 10, 10 )
        toast:insert(bg)
        toast.x = xcoord
        toast.y = ycoord
    end

    toast.alpha = 0;
    toast.transition = transition.to(toast, {time=150, alpha = 1});

    if pTime ~= nil then
        timer.performWithDelay(pTime, function() destroy(toast) end);
    end

    return toast;
end

function destroy(toast)
    toast.transition = transition.to(toast, {time=150, alpha = 0, onComplete = function() trueDestroy(toast) end});
end