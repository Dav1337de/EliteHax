local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local logTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            local tutorialStatus = {
                tutLog = true
            }
            loadsave.saveTable( tutorialStatus, "logTutorialStatus.json" )
            tutOverlay = false
            composer.hideOverlay( "fade", 200 )
        end
    end
end

local function onAlert()
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function logTutScene:create(event)
    tutGroup = self.view

    loginInfo = localToken()

    tutIconSize=fontSize(300)

    myData.terminalTutRect = display.newImageRect( "img/terminal_tutorial.png",display.contentWidth/1.2, display.contentHeight / 3 )
    myData.terminalTutRect.anchorX = 0.5
    myData.terminalTutRect.anchorY = 0.5
    myData.terminalTutRect.x, myData.terminalTutRect.y = display.contentWidth/2,display.actualContentHeight/2
    changeImgColor(myData.terminalTutRect)

    circle1 = display.newCircle( display.contentWidth/2-80, myData.terminalTutRect.y-95, 18 )
    circle1:setFillColor( 0,0.7,0 )
    circle2 = display.newCircle( display.contentWidth/2-80, myData.terminalTutRect.y-50, 18 )
    circle2:setFillColor( 0.78, 0.40, 0.17 )
    circle3 = display.newCircle( display.contentWidth/2-80, myData.terminalTutRect.y-5, 18 )
    circle3:setFillColor( 0.10, 0.40, 0.75 )
    circle4 = display.newCircle( display.contentWidth/2-80, myData.terminalTutRect.y+45, 18 )
    circle4:setFillColor( 0.69, 0.15, 0.17 )

    local options = 
    {
        text = "From the Log screen you can see the last attacks done and received.\n           Successful\n    Failed\n       Blocked\n        Attacked\nTap on a log entry to copy the IP Address",     
        x = myData.terminalTutRect.x,
        y = myData.terminalTutRect.y-myData.terminalTutRect.height/2+fontSize(100),
        width = myData.terminalTutRect.width-80,
        font = native.systemFont,   
        fontSize = 42,
        align = "center"
    }
     
    myData.instruction = display.newText( options )
    myData.instruction:setFillColor( 0.9,0.9,0.9 )
    myData.instruction.anchorX=0.5
    myData.instruction.anchorY=0

    myData.completeButton = widget.newButton(
    {
        left = myData.terminalTutRect.x-myData.terminalTutRect.width/2+60,
        top = myData.terminalTutRect.y+myData.terminalTutRect.height/2-fontSize(120),
        width = 400,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Close",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.completeButton.anchorX=0.5
    myData.completeButton.anchorY=1
    myData.completeButton.x = myData.terminalTutRect.x

    --  Show HUD    
    tutGroup:insert(myData.terminalTutRect)
    tutGroup:insert(myData.instruction)
    tutGroup:insert(circle1)
    tutGroup:insert(circle2)
    tutGroup:insert(circle3)
    tutGroup:insert(circle4)
    tutGroup:insert(myData.completeButton)

    --  Button Listeners
    myData.completeButton:addEventListener("tap", close)

end

-- Home Show
function logTutScene:show(event)
    local tasktutGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
logTutScene:addEventListener( "create", logTutScene )
logTutScene:addEventListener( "show", logTutScene )
---------------------------------------------------------------------------------

return logTutScene