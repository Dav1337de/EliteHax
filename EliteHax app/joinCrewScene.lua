local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local joinCrewScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    backSound()
    composer.hideOverlay( "fade", 100 )
end

local function onAlert()
end

local function requestListener( event )

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

        if (t.status == "AS") then
            local alert = native.showAlert( "EliteHax", "Request Already Sent!", { "Close" }, onAlert )
        end

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Request Sent!", { "Close" }, close )
        end
    end
end

local function goToCrew(event)
    if (myData.manualSearch) then
        myData.manualSearch:removeSelf()
        myData.manualSearch = nil
    end
    backSound()
    composer.removeScene( "newCrewScene" )
    composer.gotoScene("crewScene", {effect = "fade", time = 100})
end

local function invitationListener( event )
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
            local alert = native.showAlert( "EliteHax", "Cannot find the invitation!", { "Close" }, refreshInvitation )
        end

        if (t.status == "FULL") then
            local alert = native.showAlert( "EliteHax", "The crew is currently full!", { "Close" } )
        end

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Invitation Accepted!", { "Close" }, goToCrew )
        end
    end
end

local function rejectInvitationListener( event )
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
            local alert = native.showAlert( "EliteHax", "Cannot find the invitation!", { "Close" }, refreshInvitation )
        end

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Invitation Rejected!", { "Close" }, refreshInvitation )
        end
    end
end

local request = function(event)
    if (event.phase == "ended") then
        if (params.type=="request") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&crew_id="..params.id
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."joinCrew.php", "POST", requestListener, params )    
        elseif (params.type=="invitation") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&crew_id="..params.id
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."acceptInvitation.php", "POST", invitationListener, params )   
        end
    end
end

local function rejectInvitation(event)
    if (event.phase == "ended") then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&crew_id="..params.id
        local params = {}
        params.headers = headers
        params.body = body
        backSound()
        network.request( host().."rejectInvitation.php", "POST", rejectInvitationListener, params )   
    end
end

local function networkListener( event )

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

        --Details
        myData.crewName.text = t.name
        myData.crewTag.text = "("..t.tag..")"
        myData.crewDesc.text = t.desc
        myData.crewStats.text = "Rank: "..format_thousand(t.crank).."\nMembers: "..t.members.."\nScore: "..format_thousand(t.cscore).."\nRep: "..format_thousand(t.creputation)

    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function joinCrewScene:create(event)
    group = self.view
    params = event.params

    loginInfo = localToken()

    iconSize=250

    myData.crewRect = display.newRoundedRect( 40, display.actualContentHeight/2, display.contentWidth-70, display.actualContentHeight /2, 12 )
    myData.crewRect.anchorX = 0
    myData.crewRect.anchorY = 0.5
    myData.crewRect.strokeWidth = 5
    myData.crewRect:setFillColor( 0,0,0 )
    myData.crewRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.crewRect.alpha = 1

    -- Crew Name
    myData.crewName = display.newText( "", 0, 0, native.systemFont, fontSize(70) )
    myData.crewName.anchorX=0.5
    myData.crewName.anchorY=0
    myData.crewName.x =  display.contentWidth/2
    myData.crewName.y = myData.crewRect.y-myData.crewRect.height/2+fontSize(60)
    myData.crewName:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Tag
    myData.crewTag = display.newText( "", 0, 0, native.systemFont, fontSize(70) )
    myData.crewTag.anchorX=0.5
    myData.crewTag.anchorY=0
    myData.crewTag.x =  display.contentWidth/2
    myData.crewTag.y = myData.crewName.y+myData.crewName.height+fontSize(20)
    myData.crewTag:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Desc
    myData.crewDesc = display.newText( "", 0, 0, native.systemFont, fontSize(60) )
    myData.crewDesc.anchorX=0.5
    myData.crewDesc.anchorY=0
    myData.crewDesc.x =  display.contentWidth/2
    myData.crewDesc.y = myData.crewTag.y+myData.crewTag.height+fontSize(30)
    myData.crewDesc:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Stats
    myData.crewStats = display.newText( "\n\n\n\n", 0, 0, native.systemFont, fontSize(55) )
    myData.crewStats.anchorX=0
    myData.crewStats.anchorY=0
    myData.crewStats.x =  80
    myData.crewStats.y = myData.crewDesc.y+myData.crewDesc.height+fontSize(30)
    myData.crewStats:setTextColor( 0.9, 0.9, 0.9 )

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.closeBtn.anchorX = 1
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.crewRect.width+20, myData.crewRect.y-myData.crewRect.height/2+20
    changeImgColor(myData.closeBtn)

    -- Request Button
    myData.requestButton = widget.newButton(
    {
        left = 40,
        top = myData.crewStats.y+myData.crewStats.height+fontSize(30),
        width = display.contentWidth/2,
        height = fontSize(100),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Send Request",
        labelColor = tableColor1,
        onEvent = request
    })
    myData.requestButton.anchorX = 0.5
    myData.requestButton.x = display.contentWidth/2

    --  Show HUD    
    group:insert(myData.crewRect)
    group:insert(myData.crewName)
    group:insert(myData.crewTag)
    group:insert(myData.crewDesc)
    group:insert(myData.crewStats)
    group:insert(myData.requestButton)
    group:insert(myData.closeBtn)

    if (params.type=="invitation") then
        myData.requestButton:setLabel("Accept Invitation")
        myData.rejectButton = widget.newButton(
        {
            left = 40,
            top = myData.requestButton.y+myData.requestButton.height,
            width = display.contentWidth/2,
            height = fontSize(100),
            defaultFile = buttonColor400,
            -- overFile = "buttonOver.png",
            fontSize = fontSize(60),
            label = "Reject Invitation",
            labelColor = tableColor1,
            onEvent = rejectInvitation
        })
        myData.rejectButton.anchorX = 0.5
        myData.rejectButton.x = display.contentWidth/2
        myData.rejectButton:addEventListener("tap",rejectInvitation)
        group:insert(myData.rejectButton)
    else
        myData.requestButton.y=myData.requestButton.y+fontSize(50)
    end

    --  Button Listeners
    myData.closeBtn:addEventListener("tap", close)
    myData.requestButton:addEventListener("tap", request)

end

-- Home Show
function joinCrewScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&crew_id="..params.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getCrewDetails.php", "POST", networkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
joinCrewScene:addEventListener( "create", joinCrewScene )
joinCrewScene:addEventListener( "show", joinCrewScene )
---------------------------------------------------------------------------------

return joinCrewScene