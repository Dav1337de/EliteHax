local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local removeBotScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    composer.hideOverlay( "fade", 400 )
end

local function onAlert()
end

local function removeBotListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        end

        if (t.status == "OK") then
            botUpdate()
        end
    end
end

local function removeBot( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&bot_id="..params.uuid
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."removeBot.php", "POST", removeBotListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function removeBotAlert( event )
    if (event.phase=="ended") then
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you really want to remove this Bot?", { "Yes", "No"}, removeBot )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function removeBotScene:create(event)
    group = self.view
    params = event.params

    loginInfo = localToken()

    botIconSize=250

    myData.removeBotRect = display.newRoundedRect( display.contentWidth/2, display.actualContentHeight/2, display.contentWidth/1.5, display.actualContentHeight / 7, 12 )
    myData.removeBotRect.anchorX = 0.5
    myData.removeBotRect.anchorY = 0.5
    --myData.removeBotRect.y = params.y
    myData.removeBotRect.strokeWidth = 5
    myData.removeBotRect:setFillColor( 0,0,0 )
    myData.removeBotRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.removeBotRect.alpha = 1

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",botIconSize/2.5,botIconSize/2.5 )
    myData.closeBtn.anchorX = 0
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.removeBotRect.width+botIconSize/3-20, myData.removeBotRect.y-myData.removeBotRect.height/2+20
    changeImgColor(myData.closeBtn)

    --  Show HUD    
    group:insert(myData.removeBotRect)
    group:insert(myData.closeBtn)
    
    myData.removeBotBtn = widget.newButton(
    {
        left = myData.removeBotRect.x-myData.removeBotRect.width/2+20,
        top = myData.closeBtn.y+myData.closeBtn.height+20,
        width = myData.removeBotRect.width-40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Remove",
        labelColor = tableColor1,
        onEvent = removeBotAlert
    })
    group:insert(myData.removeBotBtn)
    myData.removeBotBtn:addEventListener("tap", removeBotAlert)

    --  Button Listeners
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function removeBotScene:show(event)
    local taskGroup = self.view
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
removeBotScene:addEventListener( "create", removeBotScene )
removeBotScene:addEventListener( "show", removeBotScene )
---------------------------------------------------------------------------------

return removeBotScene