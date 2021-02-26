local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local relocationConfirmScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        cwOverlay=false
        backSound()
        composer.hideOverlay( "fade", 0 )
    end
end

local function onAlert()
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function relocationConfirmScene:create(event)
    relocationGroup = self.view

    loginInfo = localToken()
    params = event.params

    tutIconSize=fontSize(300)

    myData.alertRect = display.newRoundedRect( display.contentWidth/2, display.contentHeight/2, display.contentWidth/1.2, fontSize(300), 15 )
    myData.alertRect.anchorX = 0.5
    myData.alertRect.anchorY = 0.5
    myData.alertRect.strokeWidth = 5
    myData.alertRect:setFillColor( 0,0,0 )
    myData.alertRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.alertRect.rotation=90

    local options = 
    {
        text = params.text,     
        x = myData.alertRect.x+fontSize(110),
        y = myData.alertRect.y,
        width = myData.alertRect.width-80,
        font = native.systemFont,   
        fontSize = fontSize(42),
        align = "center"
    }
     
    myData.alertText = display.newText( options )
    myData.alertText:setFillColor( 0.9,0.9,0.9 )
    myData.alertText.anchorX=0.5
    myData.alertText.anchorY=0
    myData.alertText.rotation=90

    myData.noButton = widget.newButton(
    {
        left = myData.alertRect.x-myData.alertText.height,
        top = myData.alertRect.y-fontSize(200),
        width = 200,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "No",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.noButton.anchorX=0.5
    myData.noButton.anchorY=0
    myData.noButton.x = myData.alertRect.x-myData.alertText.height/2
    myData.noButton.y = myData.alertRect.y-fontSize(200)
    myData.noButton.rotation=90

    myData.yesButton = widget.newButton(
    {
        left = myData.alertRect.x-myData.alertText.height,
        top = myData.alertRect.y+fontSize(200),
        width = 200,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Yes",
        labelColor = tableColor1,
        onEvent = datacenterRelocate
    })
    myData.yesButton.anchorX=0.5
    myData.yesButton.anchorY=0
    myData.yesButton.x = myData.alertRect.x-myData.alertText.height/2
    myData.yesButton.y = myData.alertRect.y+fontSize(200)
    myData.yesButton.rotation=90

    --  Show HUD    
    relocationGroup:insert(myData.alertRect)
    relocationGroup:insert(myData.alertText)
    relocationGroup:insert(myData.noButton)
    relocationGroup:insert(myData.yesButton)

    --  Button Listeners
    myData.noButton:addEventListener("tap",close)
    myData.yesButton:addEventListener("tap",datacenterRelocate)

end

-- Home Show
function relocationConfirmScene:show(event)
    local taskrelocationGroup = self.view
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
relocationConfirmScene:addEventListener( "create", relocationConfirmScene )
relocationConfirmScene:addEventListener( "show", relocationConfirmScene )
---------------------------------------------------------------------------------

return relocationConfirmScene