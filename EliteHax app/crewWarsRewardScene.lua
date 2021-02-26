local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local crewWarsRewardScene = composer.newScene()
i=0
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        cwOverlay=false
        backSound()
        timer.performWithDelay(100,composer.hideOverlay( "fade", 100 ))
    end
end

local function onAlert()
end

local function showReward(event)
    if (event.count<=20) then
        rewardSound()
        local newText=params.text.."\n\nCrew Wallet stolen: $"..format_thousand(math.round(params.money/(21-event.count))).."\nCryptocoins per member: "..format_thousand(math.round(params.cc/(21-event.count)))
        myData.alertText.text=newText
    end
    if (event.count==20) then
        myData.completeButton.alpha=1
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewWarsRewardScene:create(event)
    alertGroup = self.view

    loginInfo = localToken()
    params = event.params

    tutIconSize=fontSize(300)

    myData.alertRect = display.newRoundedRect( display.contentWidth/2, display.contentHeight/2, display.contentWidth/1.2, fontSize(500), 15 )
    myData.alertRect.anchorX = 0.5
    myData.alertRect.anchorY = 0.5
    myData.alertRect.strokeWidth = 5
    myData.alertRect:setFillColor( 0,0,0 )
    myData.alertRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.alertRect.rotation=90

    local options = 
    {
        text = params.text.."\n\nCrew Wallet stolen: $0\nCryptocoins per member: 0",     
        x = myData.alertRect.x+fontSize(220),
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

    myData.completeButton = widget.newButton(
    {
        left = myData.alertRect.x-myData.alertText.height,
        top = myData.alertRect.y,
        width = 400,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Close",
        labelColor = tableColor1,
        onEvent = close
    })
    myData.completeButton.anchorX=0.5
    myData.completeButton.anchorY=0
    myData.completeButton.x = myData.alertRect.x-myData.alertText.height/2
    myData.completeButton.y = myData.alertRect.y
    myData.completeButton.alpha=0
    myData.completeButton.rotation=90

    --  Show HUD    
    alertGroup:insert(myData.alertRect)
    alertGroup:insert(myData.alertText)
    alertGroup:insert(myData.completeButton)

    --  Button Listeners
    myData.completeButton:addEventListener("tap", close)

end

-- Home Show
function crewWarsRewardScene:show(event)
    local taskalertGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
    end

    if event.phase == "did" then
        --      
        timer.performWithDelay(50,showReward,20)
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
crewWarsRewardScene:addEventListener( "create", crewWarsRewardScene )
crewWarsRewardScene:addEventListener( "show", crewWarsRewardScene )
---------------------------------------------------------------------------------

return crewWarsRewardScene