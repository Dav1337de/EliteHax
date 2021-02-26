local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local OneSignal = require("plugin.OneSignal")
local myData = require ("mydata")
local achievementTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.instruction.text="\nTap on the down arrow to expand an achievement, see the description and collect your reward when you reach it!"
            tutPage=2
            myData.completeButton:setLabel("Close")
        elseif (tutPage==2) then
            local tutorialStatus = {
                tutAchievement = true
            }
            loadsave.saveTable( tutorialStatus, "achievementTutorialStatus.json" )
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
function achievementTutScene:create(event)
    tutGroup = self.view

    loginInfo = localToken()

    tutIconSize=fontSize(300)

    OneSignal.SendTag("TournamentNotification", "true")

    myData.achievementTutRect = display.newImageRect( "img/terminal_tutorial.png",display.contentWidth/1.2, display.contentHeight / 3 )
    myData.achievementTutRect.anchorX = 0.5
    myData.achievementTutRect.anchorY = 0.5
    myData.achievementTutRect:translate(display.contentWidth/2,display.actualContentHeight/2)
    changeImgColor(myData.achievementTutRect)

    local options = 
    {
        text = "\nIn the Achievement screen you can keep track of some important goals to reach in the game and collect XP rewards for any new achievement!",     
        x = myData.achievementTutRect.x,
        y = myData.achievementTutRect.y-myData.achievementTutRect.height/2+fontSize(100),
        width = myData.achievementTutRect.width-80,
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
        left = myData.achievementTutRect.x-myData.achievementTutRect.width/2+60,
        top = myData.achievementTutRect.y+myData.achievementTutRect.height/2-fontSize(120),
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
    myData.completeButton.x = myData.achievementTutRect.x

    --  Show HUD    
    tutGroup:insert(myData.achievementTutRect)
    tutGroup:insert(myData.instruction)
    tutGroup:insert(myData.completeButton)

    --  Button Listeners
    myData.completeButton:addEventListener("tap", close)

end

-- Home Show
function achievementTutScene:show(event)
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
achievementTutScene:addEventListener( "create", achievementTutScene )
achievementTutScene:addEventListener( "show", achievementTutScene )
---------------------------------------------------------------------------------

return achievementTutScene