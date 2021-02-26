local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local cwDefendTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.instruction.text="Next to each datacenter upgrade you can see it's current attack status.\nTap on the item to remove all the detected attacks at that level."
            myData.tutImage = display.newImageRect( "img/dc-mf1-0.png",fontSize(300), fontSize(300) )
            myData.tutImage.anchorX = 0.5
            myData.tutImage.anchorY = 0
            myData.tutImage.x, myData.tutImage.y = display.contentWidth/2+fontSize(140),myData.instruction.y-myData.tutImage.width/2
            myData.tutImage.rotation=90
            myData.tutImage2 = display.newImageRect( "img/dc-mf1-1.png",fontSize(300), fontSize(300) )
            myData.tutImage2.anchorX = 0.5
            myData.tutImage2.anchorY = 0
            myData.tutImage2.x, myData.tutImage2.y = display.contentWidth/2+fontSize(140),myData.instruction.y
            myData.tutImage2.rotation=90
            myData.tutImage3 = display.newImageRect( "img/dc-mf1-2.png",fontSize(300), fontSize(300) )
            myData.tutImage3.anchorX = 0.5
            myData.tutImage3.anchorY = 0
            myData.tutImage3.x, myData.tutImage3.y = display.contentWidth/2+fontSize(140),myData.instruction.y+myData.tutImage2.width/2
            myData.tutImage3.rotation=90
            myData.tutImage4 = display.newImageRect( "img/dc-mf1-3.png",fontSize(300), fontSize(300) )
            myData.tutImage4.anchorX = 0.5
            myData.tutImage4.anchorY = 0
            myData.tutImage4.x, myData.tutImage4.y = display.contentWidth/2+fontSize(140),myData.instruction.y+myData.tutImage4.width
            myData.tutImage4.rotation=90
            tutPage=2
        elseif (tutPage==2) then
            myData.tutImage:removeSelf()
            myData.tutImage=nil
            myData.tutImage2:removeSelf()
            myData.tutImage2=nil
            myData.tutImage3:removeSelf()
            myData.tutImage3=nil
            myData.tutImage4:removeSelf()
            myData.tutImage4=nil
            myData.instruction.text="\nNOTE: You can only remove the most advanced attacks.\nExample: if you have an attack in progress at your internal firewall, you must remove that before removing an attack from the IPS or External Firewall."
            tutPage=3
        elseif (tutPage==3) then
            myData.instruction.text="Defending from attacks consumes 1 point.\nYou can use 2 points per hour and your Crew can use a total of 50 daily points.\nPoints can be used for Upgrade, Defend and Attack, choose the best strategy with your crew members!."
            tutPage=4
            myData.completeButton:setLabel("Close")
        elseif (tutPage==4) then
            local tutorialStatus = {
                cwDefendTutorial = true
            }
            loadsave.saveTable( tutorialStatus, "cwDefendTutorialStatus.json" )
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
function cwDefendTutScene:create(event)
    alertGroup = self.view

    loginInfo = localToken()
    params = event.params

    tutIconSize=fontSize(300)

    myData.alertRect = display.newRoundedRect( display.contentWidth/2, display.contentHeight/2, display.contentHeight/1.3, fontSize(500), 15 )
    myData.alertRect.anchorX = 0.5
    myData.alertRect.anchorY = 0.5
    myData.alertRect.strokeWidth = 5
    myData.alertRect:setFillColor( 0,0,0 )
    myData.alertRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.alertRect.rotation=90

    local options = 
    {
        text = "\nThe Defend Datacenter screen allows you to view the status of the attacks in progress against your Crew Datacenter and defend from them.\n",     
        x = myData.alertRect.x+fontSize(200),
        y = myData.alertRect.y,
        width = myData.alertRect.width-80,
        font = native.systemFont,   
        fontSize = fontSize(42),
        align = "center"
    }
     
    myData.instruction = display.newText( options )
    myData.instruction:setFillColor( 0.9,0.9,0.9 )
    myData.instruction.anchorX=0.5
    myData.instruction.anchorY=0
    myData.instruction.rotation=90

    myData.completeButton = widget.newButton(
    {
        left = myData.alertRect.x-myData.alertRect.width,
        top = myData.alertRect.y,
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
    myData.completeButton.anchorY=0
    myData.completeButton.x = myData.alertRect.x-myData.alertRect.height/2+myData.completeButton.height+fontSize(30)
    myData.completeButton.y = myData.alertRect.y
    myData.completeButton.rotation=90

    --  Show HUD    
    alertGroup:insert(myData.alertRect)
    alertGroup:insert(myData.instruction)
    alertGroup:insert(myData.completeButton)

    --  Button Listeners
    myData.completeButton:addEventListener("tap", close)

end

-- Home Show
function cwDefendTutScene:show(event)
    local taskalertGroup = self.view
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
cwDefendTutScene:addEventListener( "create", cwDefendTutScene )
cwDefendTutScene:addEventListener( "show", cwDefendTutScene )
---------------------------------------------------------------------------------

return cwDefendTutScene