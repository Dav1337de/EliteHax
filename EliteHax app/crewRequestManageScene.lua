local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local crewRequestManageScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    backSound()
    composer.hideOverlay( "fade", 100 )
    overlayOpen=0
end

local function onAlert()
end

local function acceptrejectListener( event )

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

        if (t.status == "NE") then
            local alert = native.showAlert( "EliteHax", "Cannot find the request!", { "Close" } )
        end

        if (t.status == "OK") then
            requestsUpdate()
        end

        if (t.status == "FULL") then
            local alert = native.showAlert( "EliteHax", "Your Crew is full", { "Close" }, onAlert )
            requestsUpdate()
        end
        
    end
end

local function acceptMember( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&member_id="..params.member_id
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."acceptMember.php", "POST", acceptrejectListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function rejectMember( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&member_id="..params.member_id
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."rejectMember.php", "POST", acceptrejectListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function acceptMemberAlert( event )
    if (event.phase=="ended") then
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you want to Accept "..params.member_name.."?", { "Yes", "No"}, acceptMember )
    end
end

local function rejectMemberAlert( event )
    if (event.phase=="ended") then
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you want to Reject "..params.member_name.."?", { "Yes", "No"}, rejectMember )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewRequestManageScene:create(event)
    group = self.view
    params = event.params

    loginInfo = localToken()

    iconSize=250

    myData.crewRequestRect = display.newRoundedRect( display.contentWidth/2, display.contentHeight/2, display.contentWidth/1.5, display.contentHeight / 3.7, 15 )
    myData.crewRequestRect.anchorX = 0.5
    myData.crewRequestRect.anchorY = 0.5
    myData.crewRequestRect.strokeWidth = 5
    myData.crewRequestRect:setFillColor( 0,0,0 )
    myData.crewRequestRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.crewRequestRect.alpha = 1

    -- Crew Name
    myData.memberName = display.newText( params.member_name, 0, 0, native.systemFont, fontSize(62) )
    myData.memberName.anchorX=0.5
    myData.memberName.anchorY=0
    myData.memberName.x =  display.contentWidth/2
    myData.memberName.y = myData.crewRequestRect.y-myData.crewRequestRect.height/2+fontSize(140)
    myData.memberName:setTextColor( 0.9, 0.9, 0.9 )

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.closeBtn.anchorX = 0
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.crewRequestRect.width+iconSize/3-20, myData.crewRequestRect.y-myData.crewRequestRect.height/2+20
    changeImgColor(myData.closeBtn)

    --  Show HUD    
    group:insert(myData.crewRequestRect)
    group:insert(myData.memberName)
    group:insert(myData.closeBtn)


    myData.acceptButton = widget.newButton(
    {
        left = myData.crewRequestRect.x-myData.crewRequestRect.width/2+20,
        top = myData.memberName.y+100,
        width = myData.crewRequestRect.width-40,
        height = display.contentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = 80,
        label = "Accept",
        labelColor = tableColor1,
        onEvent = acceptMemberAlert
    })
    group:insert(myData.acceptButton)
    myData.acceptButton:addEventListener("tap", acceptMemberAlert)

    
    myData.rejectButton = widget.newButton(
    {
        left = myData.crewRequestRect.x-myData.crewRequestRect.width/2+20,
        top = (myData.memberName.y+100)+(display.contentHeight/15-5)+20,
        width = myData.crewRequestRect.width-40,
        height = display.contentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = 80,
        label = "Reject",
        labelColor = tableColor1,
        onEvent = rejectMemberAlert
    })
    group:insert(myData.rejectButton)
    myData.rejectButton:addEventListener("tap", rejectMemberAlert)

    --  Button Listeners
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function crewRequestManageScene:show(event)
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
crewRequestManageScene:addEventListener( "create", crewRequestManageScene )
crewRequestManageScene:addEventListener( "show", crewRequestManageScene )
---------------------------------------------------------------------------------

return crewRequestManageScene