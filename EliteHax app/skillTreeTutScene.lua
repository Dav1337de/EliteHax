local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local skillTreeTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.instruction.text="\nComplete Missions or rank in Tournaments to receive XP and reach new Player Levels!\nYou earn 1 Skill Point for each new level!\nChoose the right path based on your play style!"
            tutPage=2
            myData.completeButton:setLabel("Close")
        elseif (tutPage==2) then
            local tutorialStatus = {
                tutSkillTree = true
            }
            loadsave.saveTable( tutorialStatus, "skillTreeTutorialStatus.json" )
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
function skillTreeTutScene:create(event)
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
        text = "\n\n\nIn the Skill Tree screen you can unlock important skills to give you an advantage in the game.",     
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
function skillTreeTutScene:show(event)
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
skillTreeTutScene:addEventListener( "create", skillTreeTutScene )
skillTreeTutScene:addEventListener( "show", skillTreeTutScene )
---------------------------------------------------------------------------------

return skillTreeTutScene