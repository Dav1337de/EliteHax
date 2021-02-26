local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local newLvlScene = composer.newScene()
local progress=0
local level=0
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase == "ended") then
        timer.performWithDelay(100, function () composer.hideOverlay( "fade",100 ) chatOpen=0 backSound() return true end,1 )
    end
end

local function onAlert()
end

local function progressAnimation (event)
    if (progress<100) then
        progress=progress+5
        myData.xpProgressView:setProgress( progress/100 )
        timer.performWithDelay(5,progressAnimation)
    else
        rewardSound()
        myData.drInstruction.text="Level "..level
        timer.performWithDelay(500,function () myData.drCloseButton.alpha=1 return true end)
    end       
end

local function newLvlNetworkListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        elseif (t.status == "AC") then
            close()
        elseif (t.status == "OK") then
            myData.drName.text="Congratulations "..myData.playerTextHome.text.."!"
            myData.drDays.text="You have reached a new level!" 
            level=t.lvl
            --Animate ProgressView
            progressAnimation()
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function newLvlScene:create(event)
    drGroup = self.view
    params = event.params

    loginInfo = localToken()

    diconSize=350

    myData.newLvlRect = display.newImageRect( "img/new_level.png",display.contentWidth*0.9, 720 )
    myData.newLvlRect.anchorX = 0.5
    myData.newLvlRect.anchorY = 0.5
    myData.newLvlRect.x, myData.newLvlRect.y = display.contentWidth/2,display.actualContentHeight/2
    changeImgColor(myData.newLvlRect)

    -- Welcome Message
    myData.drName = display.newText( "", 0, 0, native.systemFont, fontSize(58) )
    myData.drName.anchorX=0.5
    myData.drName.anchorY=0
    myData.drName.x =  display.contentWidth/2
    myData.drName.y = myData.newLvlRect.y-myData.newLvlRect.height/2+fontSize(130)
    myData.drName:setTextColor( 0.9, 0.9, 0.9 )

    -- Consecutive Days
    local options = 
    {
        text = "",     
        x = display.contentWidth/2,
        y = myData.drName.y+myData.drName.height+fontSize(20),
        width = 0,
        font = native.systemFont,   
        fontSize = fontSize(58),
        align = "center"  -- Alignment parameter
    }
    myData.drDays = display.newText( options )
    myData.drDays.anchorX=0.5
    myData.drDays.anchorY=0
    myData.drDays.x =  display.contentWidth/2
    myData.drDays.y = myData.drName.y+myData.drName.height+fontSize(20)
    myData.drDays:setTextColor( 0.9, 0.9, 0.9 )

    local options = {
        width = 64,
        height = 64,
        numFrames = 6,
        sheetContentWidth = 384,
        sheetContentHeight = 64
    }
    local progressSheet = graphics.newImageSheet( progressColor, options )
    myData.xpProgressView = widget.newProgressView(
        {
            sheet = progressSheet,
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillOuterWidth = 50,
            fillOuterHeight = 50,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            fillWidth = 50,
            fillHeight = 50,
            left = display.contentWidth/2,
            top = myData.drDays.y+myData.drDays.height+fontSize(40),
            width = myData.newLvlRect.width-200,
            isAnimated = true
        }
    )   
    myData.xpProgressView.anchorX=0.5
    myData.xpProgressView.x=display.contentWidth/2

    -- Instructions
    local options = 
    {
        text = "",     
        x = display.contentWidth/2,
        y = myData.drName.y+myData.drName.height+fontSize(10),
        width = 0,
        font = native.systemFont,   
        fontSize = fontSize(70),
        align = "center"  -- Alignment parameter
    }
    myData.drInstruction = display.newText( options )
    myData.drInstruction.anchorX=0.5
    myData.drInstruction.anchorY=0
    myData.drInstruction.x =  display.contentWidth/2
    myData.drInstruction.y = myData.xpProgressView.y+myData.xpProgressView.height+fontSize(20)
    myData.drInstruction:setTextColor( 0.9, 0.9, 0.9 )

    -- Close Button
    myData.drCloseButton = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.drInstruction.y+myData.drInstruction.height+fontSize(30),
        width = 500,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(75),
        label = "Close",
        labelColor = tableColor1,
        onRelease = close
    })
    myData.drCloseButton.x=display.contentWidth/2
    myData.drCloseButton.alpha=0

    --  Show HUD    
    drGroup:insert(myData.newLvlRect)
    drGroup:insert(myData.drName)
    drGroup:insert(myData.drDays)
    drGroup:insert(myData.xpProgressView)
    drGroup:insert(myData.drInstruction)
    drGroup:insert(myData.drCloseButton)

    --  Button Listeners
    --myData.drCloseButton:addEventListener("tap", close)

end

-- Home Show
function newLvlScene:show(event)
    local taskdrGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getNewLvl.php", "POST", newLvlNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
newLvlScene:addEventListener( "create", newLvlScene )
newLvlScene:addEventListener( "show", newLvlScene )
---------------------------------------------------------------------------------

return newLvlScene