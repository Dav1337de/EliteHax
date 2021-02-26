local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local myCrewRequestsScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), fontSize(58) )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])
    row.rowRectangle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )

    row.upgradeImage = display.newImageRect(row, "img/profile.png", iconSize/2, iconSize/2)
    row.upgradeImage.x = iconSize/4+40
    row.upgradeImage.y = iconSize/4+30

    row.rowUsername = display.newText( row, params.username, 0, 0, native.systemFont, fontSize(64) )
    row.rowUsername.anchorX = 0
    row.rowUsername.anchorY = 0
    row.rowUsername.x = row.upgradeImage.x+iconSize/2-20
    row.rowUsername.y = 20
    row.rowUsername:setTextColor( 0, 0, 0 )

    row.rowScore = display.newText( row, "Score: "..format_thousand(params.score).."   Rep: "..format_thousand(params.rep), 0, 0, native.systemFont, fontSize(58) )
    row.rowScore.anchorX=0
    row.rowScore.anchorY=0
    row.rowScore.x = row.upgradeImage.x+iconSize/2-20
    row.rowScore.y = 100
    row.rowScore:setTextColor( 0, 0, 0 )
end

local function requestTableListener(event)
    if (event.phase == "ended") then        
        local row = event.target
        local params = event.target.params
        if (event.target.upgradeImage) then
            if ((event.x>event.target.upgradeImage.x) and (event.x<(event.target.upgradeImage.x+event.target.upgradeImage.width))) then
                detailsOverlay=true
                local sceneOverlayOptions = 
                {
                    time = 100,
                    effect = "crossFade",
                    params = { 
                        id = params.username,
                    },
                    isModal = true
                }
                tapSound()
                composer.showOverlay( "playerDetailsScene", sceneOverlayOptions)
            else
                if (my_role < 4) then
                    local sceneOverlayOptions = 
                    {
                        time = 100,
                        effect = "crossFade",
                        params = { 
                            member_id = params.id,
                            member_name = params.username,
                        },
                        isModal = true
                    }
                    overlayOpen=1
                    tapSound()
                    composer.showOverlay( "crewRequestManageScene", sceneOverlayOptions)
                end
            end
        end
    end
end


function goBackCrewR(event)
    backSound()
    if (overlayOpen==1) then
        composer.hideOverlay( "fade", 400 )
        overlayOpen=0
    else
        if (myData.newRequestInput) then
            myData.newRequestInput:removeSelf()
            myData.newRequestInput=nil
        end
        composer.removeScene( "myCrewRequestsScene" )
        composer.gotoScene("crewScene", {effect = "fade", time = 100})
    end
end

local function onAlert()
end

local function onNameEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.newRequestInput.text = string.sub(event.text,1,18)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.newRequestInput.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
    if (event.phase == "ended") then
        if ((string.len(myData.newRequestInput.text) < 4) or (string.len(myData.newRequestInput.text) > 18)) then
            local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" } )
        end
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

        --Money
        myData.moneyTextCrewR.text = format_thousand(t.money)
        myData.moneyTextCrewR.money = t.money

        --Player
        if (string.len(t.username)>15) then myData.playerTextCrewR.size = fontSize(42) end
        myData.playerTextCrewR.text = t.username
        
        myData.crewName.text = t.crew_name.." Requests"
        my_role = t.my_role
        if (my_role<4) then
            if (myData.newRequestInput) then
                myData.newRequestInput:removeSelf()
                myData.newRequestInput=nil
            end
            myData.newRequestText.alpha=1
            myData.newRequestInput = native.newTextField( myData.crewRect.x-myData.crewRect.width/2+50, myData.crewRect.y+myData.crewRect.height-fontSize(150), 670, fontSize(75) )
            myData.newRequestInput.anchorX = 0
            myData.newRequestInput.anchorY = 0
            myData.newRequestInput.placeholder = "Username";
            myData.newRequestInput:addEventListener("userInput", onNameEdit )
            myData.sendRequestButton.alpha=1
        end

        rowColor = { default = { 0, 0, 0, 0 } }
        lineColor = { default = { 1, 0, 0 } }
        for i in pairs( t.requests ) do
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end
            myData.requestsTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = iconSize/2+60,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        color=color,
                        username=t.requests[i].username,
                        score=t.requests[i].score,        
                        rep=t.requests[i].reputation,
                        id=t.requests[i].player_id
                    }
                }
            ) 
        end
    end
end

function requestsUpdate()
    myData.requestsTableView:deleteAllRows()    
    composer.hideOverlay( "fade", 100 )
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getMyCrewRequests.php", "POST", networkListener, params )
end

local function sendInvitationListener( event )
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

        if (t.status == "NA") then
            local alert = native.showAlert( "EliteHax", "Username not found!", { "Close" } )
        end

        if (t.status == "AC") then
            local alert = native.showAlert( "EliteHax", "Username already in a crew!", { "Close" } )
        end

        if (t.status == "AS") then
            local alert = native.showAlert( "EliteHax", "Invitation already sent!", { "Close" } )
        end

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Invitation sent!", { "Close" } )
            requestsUpdate()           
        end
    end
end

local function sendInvitation( username )
    return function(event)
        local i = event.index
        if ( i == 1 ) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&username="..string.urlEncode(username)
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."sendInvitation.php", "POST", sendInvitationListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function sendInvitationAlert( event )
    if (event.phase == "ended") then
        if (my_role<4) then
            if ((string.len(myData.newRequestInput.text) < 4) or (string.len(myData.newRequestInput.text) > 18)) then
                backSound()
                local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" } )
            else
                local user=myData.newRequestInput.text
                tapSound()
                local alert = native.showAlert( "EliteHax", "Do you want to send an invitation to "..user.."?", { "Yes", "No"}, sendInvitation(user) )
            end
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function myCrewRequestsScene:create(event)
    group = self.view
    params = event.params

    loginInfo = localToken()
    overlayOpen=0

    iconSize=250

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextCrewR = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextCrewR.anchorX = 0
    myData.moneyTextCrewR.anchorY = 0.5
    myData.moneyTextCrewR:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextCrewR = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextCrewR.anchorX = 0.5
    myData.playerTextCrewR.anchorY = 0.5
    myData.playerTextCrewR:setFillColor( 0.9,0.9,0.9 )

    --Crew Rect
    myData.crewRect = display.newImageRect( "img/crew_members_rect.png",display.contentWidth-20, fontSize(1660))
    myData.crewRect.anchorX = 0.5
    myData.crewRect.anchorY = 0
    myData.crewRect.x, myData.crewRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.crewRect)

    -- Crew Name
    myData.crewName = display.newText( "", 0, 0, native.systemFont, fontSize(60) )
    myData.crewName.anchorX=0.5
    myData.crewName.anchorY=0
    myData.crewName.x =  display.contentWidth/2
    myData.crewName.y = myData.crewRect.y+fontSize(8)
    myData.crewName:setTextColor( 0.9, 0.9, 0.9 )

    myData.requestsTableView = widget.newTableView(
    {
        left = 40,
        top = myData.top_background.y+myData.top_background.height+fontSize(100),
        height = fontSize(1310),
        width = display.contentWidth-80,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
        listener = requestTableListener,
        hideBackground = true
    })
    myData.requestsTableView.anchorX=0.5
    myData.requestsTableView.x=display.contentWidth/2

    myData.newRequestText = display.newText( "Send an invitation", display.contentWidth/2, myData.crewRect.y+myData.crewRect.height-fontSize(250), native.systemFont, fontSize(70) )
    myData.newRequestText.anchorX=0.5
    myData.newRequestText.anchorY=0
    myData.newRequestText.x =  display.contentWidth/2
    myData.newRequestText:setTextColor( 0.9, 0.9, 0.9 )
    myData.newRequestText.alpha=0
    
    myData.sendRequestButton = widget.newButton(
    {
        left = (myData.crewRect.x-myData.crewRect.width/2+50)+670+20,
        top = (myData.crewRect.y+myData.crewRect.height-fontSize(150))-fontSize(5),
        width = 250,
        height = fontSize(90),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(72),
        label = "Send",
        labelColor = tableColor1,
        onEvent = sendInvitationAlert
    })
    myData.sendRequestButton.alpha=0

    myData.backButton = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15)+topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Back",
        labelColor = tableColor1,
        onEvent = goBackCrewR
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextCrewR)
    group:insert(myData.playerTextCrewR)
    group:insert(myData.crewRect)
    group:insert(myData.crewName)
    group:insert(myData.backButton)
    group:insert(myData.requestsTableView)
    group:insert(myData.newRequestText)
    group:insert(myData.sendRequestButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap", goBackCrewR)

end

-- Home Show
function myCrewRequestsScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getMyCrewRequests.php", "POST", networkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
myCrewRequestsScene:addEventListener( "create", myCrewRequestsScene )
myCrewRequestsScene:addEventListener( "show", myCrewRequestsScene )
---------------------------------------------------------------------------------

return myCrewRequestsScene