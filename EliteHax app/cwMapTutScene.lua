local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local cwMapTutScene = composer.newScene()
local tutPage=1
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        if (tutPage==1) then
            myData.instruction.text="\nTap on a region to see its details, including Region Name, Last Scan Time and Available Crews discovered during last scan.\n\nIf the scan is still in progress, the region is highlighted in orange."
            tutPage=2
        elseif (tutPage==2) then
            myData.instruction.text="\nWhen a region is selected, you can Scan/Re-Scan it to detect new datacenters in that region.\nUse the Explore Region button to see the discovered datacenters of the selected region."
            tutPage=3
        elseif (tutPage==3) then
            myData.instruction.text="\n\nCooperate with your Crew members to routinely scan the world to find the latest and newly relocated datacenters!"
            tutPage=4
            myData.completeButton:setLabel("Close")
        elseif (tutPage==4) then
            local tutorialStatus = {
                cwMapTutorial = true
            }
            loadsave.saveTable( tutorialStatus, "cwMapTutorialStatus.json" )
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
function cwMapTutScene:create(event)
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
        text = "\nWelcome to Crew Wars!\n\nFrom this screen you can scan regions to find other Crews datacenters.\nEvery crew member can scan a single region every hour.",     
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
function cwMapTutScene:show(event)
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
cwMapTutScene:addEventListener( "create", cwMapTutScene )
cwMapTutScene:addEventListener( "show", cwMapTutScene )
---------------------------------------------------------------------------------

return cwMapTutScene