local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local tournamentTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.instruction.text="Hack Tournament leaderboard is based on the money stolen by hacking during the tournament time (1h).\n\nNOTE: Only the first 100 Attacks are evaluated, choose your target wisely!"
            tutPage=2
        elseif (tutPage==2) then
            myData.instruction.text="Hack&Defend Tournament leaderboard is based on the difference between money stolen and money lost by hacking during the tournament time (1h).\n\nOnly the first 100 Attacks are evaluated, choose your target wisely!"
            tutPage=3
        elseif (tutPage==3) then
            myData.instruction.text="Score Tournament leaderboard is based on the score gained during the tournament time (4h).\n\nYou can use overclocks to complete more upgrades and you can also open your packs!"
            tutPage=4
        elseif (tutPage==4) then
            myData.instruction.text="\nNOTE: The rewards shown in the Info tab are based on a minimum of 200 players and 50 crews.\nIf the minimum number is not reached, the rewards will be adjusted automatically."
            tutPage=5
            myData.completeButton:setLabel("Close")
        elseif (tutPage==5) then
            local tutorialStatus = {
                tutTournament = true
            }
            loadsave.saveTable( tutorialStatus, "tournamentTutorialStatus.json" )
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
function tournamentTutScene:create(event)
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
        text = "Welcome to Tournaments!\nEveryday you can join 6 tournaments of different types.\n\nFrom the Info tab you can see if a tournament is running, the tournament type and the rewards.",     
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
function tournamentTutScene:show(event)
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
tournamentTutScene:addEventListener( "create", tournamentTutScene )
tournamentTutScene:addEventListener( "show", tournamentTutScene )
---------------------------------------------------------------------------------

return tournamentTutScene