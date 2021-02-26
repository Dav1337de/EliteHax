local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local crewLogsTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            tutPage=2
            myData.instruction.text="The Events tab shows the following Crew events:\nPromote/Demote/Kick, Rquest/Join/Leave, Invitation Sent/Accepted/Rejected, Description/Mentor/Wallet % Changed, Item Bought."
        elseif (tutPage==2) then
            tutPage=3
            myData.instruction.text="\n\nThe Tournaments tab shows the Tournament Rewards gained by your Crew during Score Tournaments and Hack Tournaments."
        elseif (tutPage==3) then
            tutPage=4
            myData.instruction.text="From the Crew Wars tab you can see the latest attacks done and received by your Crew.\nYou are attacking\n                  Enemy Mainframe Exploited\n         You are being attacked\n              Your Mainframe Exploited"
            circle1 = display.newCircle( display.contentWidth/2-200, myData.terminalTutRect.y-40, 18 )
            circle1:setFillColor( 0.10, 0.40, 0.75 )
            circle2 = display.newCircle( display.contentWidth/2-200, myData.terminalTutRect.y+10, 18 )
            circle2:setFillColor( 0,0.7,0 )
            circle3 = display.newCircle( display.contentWidth/2-200, myData.terminalTutRect.y+50, 18 )
            circle3:setFillColor( 0.78, 0.40, 0.17 )
            circle4 = display.newCircle( display.contentWidth/2-200, myData.terminalTutRect.y+100, 18 )
            circle4:setFillColor( 0.69, 0.15, 0.17 )
            tutGroup:insert(circle1)
            tutGroup:insert(circle2)
            tutGroup:insert(circle3)
            tutGroup:insert(circle4)
            myData.completeButton:setLabel("Close")
        elseif (tutPage==4) then
            local tutorialStatus = {
                crewLogsTutorial = true
            }
            loadsave.saveTable( tutorialStatus, "crewLogsTutorialStatus.json" )
            tutOverlay = false
            composer.hideOverlay( "fade", 100 )
        end
    end
end

local function onAlert()
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewLogsTutScene:create(event)
    tutGroup = self.view

    loginInfo = localToken()

    tutIconSize=fontSize(300)

    myData.terminalTutRect = display.newImageRect( "img/terminal_tutorial.png",display.contentWidth/1.2, display.contentHeight / 3 )
    myData.terminalTutRect.anchorX = 0.5
    myData.terminalTutRect.anchorY = 0.5
    myData.terminalTutRect.x, myData.terminalTutRect.y = display.contentWidth/2,display.actualContentHeight/2
    changeImgColor(myData.terminalTutRect)

    local options = 
    {
        --text = "From the Log screen you can see the last attacks done and received.\n           Successful\n    Failed\n       Blocked\n        Attacked\nTap on a log entry to copy the IP Address",     
        text = "\n\nIn the Crew Logs screen you can see events related to your Crew, Crew Tournament Rewards and Crew Wars logs.",
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
        label = "Next",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.completeButton.anchorX=0.5
    myData.completeButton.anchorY=1
    myData.completeButton.x = myData.terminalTutRect.x

    --  Show HUD    
    tutGroup:insert(myData.terminalTutRect)
    tutGroup:insert(myData.instruction)
    tutGroup:insert(myData.completeButton)

    --  Button Listeners
    myData.completeButton:addEventListener("tap", close)

end

-- Home Show
function crewLogsTutScene:show(event)
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
crewLogsTutScene:addEventListener( "create", crewLogsTutScene )
crewLogsTutScene:addEventListener( "show", crewLogsTutScene )
---------------------------------------------------------------------------------

return crewLogsTutScene