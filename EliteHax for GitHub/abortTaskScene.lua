local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local abortTaskScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    overlayOpen=0
    backSound()
    composer.hideOverlay( "fade", 100 )
end

local function onAlert()
end

local function abortTaskListener( event )

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

        if (t.status == "MAX_ABORT") then
            local alert = native.showAlert( "EliteHax", "You already aborted too much tasks in the last 24 hours", { "Close" } )
            updateTasks()
            close()
        elseif (t.status == "TOURNAMENT_ACTIVE") then
            local alert = native.showAlert( "EliteHax", "You cannot abort tasks during Hack or Hack&Defend Tournaments", { "Close" } )
            updateTasks()
            close()            
        elseif (t.status == "OK") then
            updateTasks()
            close()
        end
    end
end

local function abortTask( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type="..params.type.."&lvl="..params.lvl
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."abortTask.php", "POST", abortTaskListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function abortTaskAlert( event )
    if (event.phase=="ended") then
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you really want to abort this Task?", { "Yes", "No"}, abortTask )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function abortTaskScene:create(event)
    agroup = self.view
    params = event.params

    loginInfo = localToken()

    botIconSize=200

    myData.abortTaskRect = display.newRoundedRect( display.contentWidth/2, display.actualContentHeight/2, display.contentWidth/1.5, display.actualContentHeight / 7, 12 )
    myData.abortTaskRect.anchorX = 0.5
    myData.abortTaskRect.anchorY = 0.5
    --myData.abortTaskRect.y = params.y
    myData.abortTaskRect.strokeWidth = 5
    myData.abortTaskRect:setFillColor( 0,0,0 )
    myData.abortTaskRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.abortTaskRect.alpha = 1

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",botIconSize/2.5,botIconSize/2.5 )
    myData.closeBtn.anchorX = 0
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.abortTaskRect.width+botIconSize/3, myData.abortTaskRect.y-myData.abortTaskRect.height/2+20
    changeImgColor(myData.closeBtn)

    --  Show HUD    
    agroup:insert(myData.abortTaskRect)
    agroup:insert(myData.closeBtn)
    
    myData.abortTaskBtn = widget.newButton(
    {
        left = myData.abortTaskRect.x-myData.abortTaskRect.width/2+20,
        top = myData.closeBtn.y+myData.closeBtn.height+20,
        width = myData.abortTaskRect.width-40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Abort",
        labelColor = tableColor1,
        onEvent = abortTaskAlert
    })
    agroup:insert(myData.abortTaskBtn)
    myData.abortTaskBtn:addEventListener("tap", abortTaskAlert)

    --  Button Listeners
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function abortTaskScene:show(event)
    local taskagroup = self.view
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
abortTaskScene:addEventListener( "create", abortTaskScene )
abortTaskScene:addEventListener( "show", abortTaskScene )
---------------------------------------------------------------------------------

return abortTaskScene