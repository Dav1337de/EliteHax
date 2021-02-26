local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local aboutScene = composer.newScene()

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        skinOverlay = false
        backSound()
        composer.hideOverlay( "fade", 100 )
    end
end

local function onAlert()
end
---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function aboutScene:create(event)
    ocGroup = self.view

    loginInfo = localToken()

    tutIconSize=fontSize(300)

    myData.aboutRect = display.newImageRect( "img/about_rect.png",display.contentWidth/1.1, display.contentHeight / 1.6 )
    myData.aboutRect.anchorX = 0.5
    myData.aboutRect.anchorY = 0.5
    myData.aboutRect.x, myData.aboutRect.y = display.contentWidth/2,display.actualContentHeight/2
    changeImgColor(myData.aboutRect)

    print("Height: "..myData.aboutRect.height)

    local options = 
    {
        text = "\nEliteHax - Hacker World",
        x = myData.aboutRect.x,
        y = myData.aboutRect.y-myData.aboutRect.height/2+fontSize(70),
        width = myData.aboutRect.width-80,
        font = native.systemFont,   
        fontSize = fontSize(72),
        align = "center"
    }
     
    myData.instruction = display.newText( options )
    myData.instruction:setFillColor( 0.9,0.9,0.9 )
    myData.instruction.anchorX=0.5
    myData.instruction.anchorY=0

    myData.gameIconBtn = display.newImageRect( "img/icon.png",fontSize(400), fontSize(400))
    myData.gameIconBtn.anchorX = 0.5
    myData.gameIconBtn.anchorY = 0
    myData.gameIconBtn.x, myData.gameIconBtn.y = myData.aboutRect.x,myData.instruction.y+myData.instruction.height+fontSize(20)

    local options = 
    {
        text = appVersion().."\nDeveloped by Dav1337de\n\nMusic and Sounds Effects by Eric Matyas (www.soundimage.org)",
        x = myData.gameIconBtn.x,
        y = myData.gameIconBtn.y+myData.gameIconBtn.height+fontSize(50),
        width = myData.aboutRect.width-80,
        font = native.systemFont,   
        fontSize = fontSize(52),
        align = "center"
    }
    myData.gameIconBtn.txt = display.newText( options )
    myData.gameIconBtn.txt.anchorY=0

    myData.closeButton = widget.newButton(
    {
        left = myData.aboutRect.x-myData.aboutRect.width/2+60,
        top = myData.gameIconBtn.txt.y+myData.gameIconBtn.txt.height+fontSize(60),
        width = 400,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Close",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.closeButton.anchorX=0.5
    myData.closeButton.anchorY=1
    myData.closeButton.x = myData.aboutRect.x

    --  Show HUD    
    ocGroup:insert(myData.aboutRect)
    ocGroup:insert(myData.instruction)
    ocGroup:insert(myData.gameIconBtn)
    ocGroup:insert(myData.gameIconBtn.txt)
    ocGroup:insert(myData.closeButton)

    --  Button Listeners
    myData.closeButton:addEventListener("tap", close)
end

-- Home Show
function aboutScene:show(event)
    local taskocGroup = self.view
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
aboutScene:addEventListener( "create", aboutScene )
aboutScene:addEventListener( "show", aboutScene )
---------------------------------------------------------------------------------

return aboutScene