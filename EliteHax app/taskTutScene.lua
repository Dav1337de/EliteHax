local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local taskTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.instruction.text="\nTo abort a task, tap on it and tap on Abort.\n\nYou can only abort the highest task of each type and a limited amount of tasks per 24 hour. You cannot abort tasks during Hack and Hack&Defend Tournaments."
            tutPage=2
        elseif (tutPage==2) then
            myData.instruction.text="\nTo speed up your tasks, you can tap on the Overclock button on the bottom left.\nThere are three types of Overclocks.\nYou can buy more Overclocks from the Items screen."
            tutPage=3
        elseif (tutPage==3) then
            myData.instruction.text="When the 'Overclock' is active your tasks will run at double speed for a limited amount of time. Additional Overclocks will extend the Overclock time."
            myData.tutImage = display.newImageRect( "img/overclock.png",150, 150 )
            myData.tutImage.anchorX = 0.5
            myData.tutImage.anchorY = 0
            myData.tutImage.x, myData.tutImage.y = display.contentWidth/2,myData.instruction.y+myData.instruction.height+fontSize(10)
            tutGroup:insert(myData.tutImage)
            tutPage=4
        elseif (tutPage==4) then
            myData.instruction.text="\nWith 'Skip 1h' Overclock you can decrease by one hour the duration of all your running tasks."
            local imageA = { type="image", filename="img/overclockHour.png" }
            myData.tutImage.fill = imageA
            tutPage=5
        elseif (tutPage==5) then
            myData.instruction.text="\nThe 'Finish Tasks' Overclock will instantly finish all your running tasks, but it will consume 5 Overclocks!"
            local imageA = { type="image", filename="img/overclockFinish.png" }
            myData.tutImage.fill = imageA
            tutPage=6
            myData.completeButton:setLabel("Close")
        elseif (tutPage==6) then
            local tutorialStatus = {
                tutTask = true
            }
            loadsave.saveTable( tutorialStatus, "taskNewTutorialStatus.json" )
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
function taskTutScene:create(event)
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
        text = "\n\nIn the Task screen you can see your running task with the estimated finishing time, you can abort them and you can speed them up.",     
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
function taskTutScene:show(event)
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
taskTutScene:addEventListener( "create", taskTutScene )
taskTutScene:addEventListener( "show", taskTutScene )
---------------------------------------------------------------------------------

return taskTutScene