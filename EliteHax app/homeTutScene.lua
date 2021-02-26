local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local homeTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local function openTos(event)
    system.openURL( "https://www.elitehax.it/tos.html" )
end

local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.instruction.text="\nYou can gain Score and Reputation by upgrading your defensive and offensive arsenal (see Upgrades) and attacking other hackers to steal their money (see Terminal)."
            tutPage=2
        elseif (tutPage==2) then
            myData.instruction.text="\nOn the top of the Home Screen you can see your current amount of Dollars on the left and your nickname on the right."
            myData.tutImage = display.newImageRect( "img/home_top.png",600, fontSize(80) )
            myData.tutImage.anchorX = 0.5
            myData.tutImage.anchorY = 0
            myData.tutImage.x, myData.tutImage.y = display.contentWidth/2,myData.instruction.y+myData.instruction.height+fontSize(40)
            tutPage=3
        elseif (tutPage==3) then
            myData.instruction.text="\nIn the upmost section, you can see your items and CryptoCoins.\nYou can click on any item to open the Items Screen"
            local imageA = { type="image", filename="img/home_high_buttons.png" }
            myData.tutImage.fill = imageA
            tutPage=4
        elseif (tutPage==4) then
            myData.instruction.text="In the Attack&Defense rectangle you have access to your defensive and offensive arsenal.\nIn the community rectangle you have access to the social features.\n\nTap on any icon to discover more!"
            myData.tutImage.alpha=0
            tutPage=5    
        elseif (tutPage==5) then
            myData.instruction.text="By clicking I Accept, you confirm that you have read EliteHax Terms & Conditions, that you understand them and that you agree to be bound by them."
            tutPage=6
            myData.tosButton = widget.newButton(
            {
                left = myData.terminalTutRect.x-myData.terminalTutRect.width/2+60,
                top = myData.terminalTutRect.y+myData.terminalTutRect.height/2-fontSize(120)*2.5,
                width = 800,
                height = fontSize(90),
                defaultFile = buttonColor1080,
               -- overFile = "buttonOver.png",
                fontSize = fontSize(60),
                label = "Read Terms & Conditions",
                labelColor = tableColor1,
                onEvent = openTos
            })
            myData.tosButton.anchorX=0.5
            myData.tosButton.x = myData.terminalTutRect.x   
            tutGroup:insert(myData.tosButton) 
            myData.completeButton:setLabel("I Accept")
        elseif (tutPage==6) then
            myData.instruction.text="\nTap on the Global Chat to start chatting with other EliteHax users!\n\nDon't post IP Addresses and please behave properly :)"
            tutPage=7
            myData.tosButton.alpha=0
            myData.completeButton:setLabel("Next")
        elseif (tutPage==7) then
            myData.instruction.text="\nExplore all the game features, read the complete tutorial from Profile->Settings and most importantly..\n\nEnjoy EliteHax!!!"
            tutPage=8
            myData.completeButton:setLabel("Close")
        elseif (tutPage==8) then
            local tutorialStatus = {
                tutHome = true
            }
            loadsave.saveTable( tutorialStatus, "homeTosTutorialStatus.json" )
            tutOverlay = false
            composer.hideOverlay( "fade", 200 )
            timer.performWithDelay(100, function () chatOpen=0 return true end,1 )
            timer.performWithDelay(100, reloadAfterTutorial,1 )
        end
    end
end

local function onAlert()
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function homeTutScene:create(event)
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
        text = "\nWelcome to EliteHax!\n\nYour main goal is to gain Score and Reputation in order to climb the leaderboard and become the best hacker in the game.",     
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
function homeTutScene:show(event)
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
homeTutScene:addEventListener( "create", homeTutScene )
homeTutScene:addEventListener( "show", homeTutScene )
---------------------------------------------------------------------------------

return homeTutScene