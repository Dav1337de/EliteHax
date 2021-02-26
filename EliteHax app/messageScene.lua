local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local loadsave = require( "loadsave" )
local messageScene = composer.newScene()
local view = "player"
refreshMsgRequestList = nil
refreshContactList = nil
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local function clearRequests( event )
    if (myData.requestTextM) then
        myData.requestTextM:removeSelf()
        myData.requestTextM=nil
    end
    if (myData.newRequestInput) then
        myData.newRequestInput:removeSelf()
        myData.newRequestInput=nil
    end
    if (myData.newRequestText) then
        myData.newRequestText:removeSelf()
        myData.newRequestText=nil
    end
    if (myData.sendRequestButton) then
        myData.sendRequestButton:removeSelf()
        myData.sendRequestButton=nil
    end
end

--Reject Request
local function sendMsgRequestListener( event )
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

        if (t.status == "AA") then
            local alert = native.showAlert( "EliteHax", "Username already in Contact List!", { "Close" } )
        end

        if (t.status == "AS") then
            local alert = native.showAlert( "EliteHax", "Request already sent!", { "Close" } )
        end

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Request sent!", { "Close" } )
            refreshMsgRequestList()            
        end
    end
end

local function sendMsgRequest( username )
    return function(event)
        local i = event.index
        if ( i == 1 ) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&username="..string.urlEncode(username)
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."sendMsgRequest.php", "POST", sendMsgRequestListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function sendRequestAlert( event )
    if (event.phase == "ended") then
        local user=myData.newRequestInput.text
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you want to send the message request to "..user.."?", { "Yes", "No"}, sendMsgRequest(user) )
    end
end

local function noMessages()
    myData.requestTextM = display.newText( "No Messages", display.contentWidth/2, myData.messageRect.y+fontSize(50), native.systemFont, fontSize(70) )
    myData.requestTextM.anchorX=0.5
    myData.requestTextM.anchorY=0
    myData.requestTextM.x =  display.contentWidth/2
    myData.requestTextM:setTextColor( 0.9, 0.9, 0.9 )
    group:insert(myData.requestTextM)
end

local function myMessagesEventListener( event )
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
        if (string.len(t.username)>15) then myData.playerTextMessage.size = fontSize(42) end
        myData.playerTextMessage.text=t.username
        myData.moneyTextMessage.text=format_thousand(t.money)

        myData.msgTableView:deleteAllRows()

        if (t.messages[1] == nil) then
            noMessages()
        end

        for i in pairs( t.messages ) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color = tableColor1
            if (t.messages[i].seen==0) then 
                color=tableColor2 
            end
            myData.msgTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = fontSize(220),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        type="messages",
                        color=color,
                        username=t.messages[i].username,
                        msg=t.messages[i].message,
                        timestamp=makeTimeStamp(t.messages[i].timestamp)
                    }  -- Include custom data in the row
                }
            ) 
        end

        myData.messageText.text=t.new_msg
        myData.requestText.text=t.new_req

        loaded=true
   end
end

local function noContacts()
    myData.requestTextM = display.newText( "Contact List is empty", display.contentWidth/2, myData.messageRect.y+fontSize(50), native.systemFont, fontSize(70) )
    myData.requestTextM.anchorX=0.5
    myData.requestTextM.anchorY=0
    myData.requestTextM.x =  display.contentWidth/2
    myData.requestTextM:setTextColor( 0.9, 0.9, 0.9 )
    group:insert(myData.requestTextM)
end

local function myContactsEventListener( event )
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
        if (string.len(t.username)>15) then myData.playerTextMessage.size = fontSize(42) end
        myData.playerTextMessage.text=t.username
        myData.moneyTextMessage.text=format_thousand(t.money)

        myData.msgTableView:deleteAllRows()
        if (t.contacts[1] == nil) then
            noContacts()
        end

        for i in pairs( t.contacts ) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end
            myData.msgTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = fontSize(130),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        type="contacts",
                        color=color,
                        username=t.contacts[i].username,
                    }  -- Include custom data in the row
                }
            ) 
        end
        loaded=true
   end
end

local function noRequests()
    myData.requestTextM = display.newText( "No New Requests", display.contentWidth/2, myData.messageRect.y+fontSize(50), native.systemFont, fontSize(70) )
    myData.requestTextM.anchorX=0.5
    myData.requestTextM.anchorY=0
    myData.requestTextM.x =  display.contentWidth/2
    myData.requestTextM:setTextColor( 0.9, 0.9, 0.9 )
    group:insert(myData.requestTextM)
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

local function myRequestsEventListener( event )
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
        if (string.len(t.username)>15) then myData.playerTextMessage.size = fontSize(42) end
        myData.playerTextMessage.text=t.username
        myData.moneyTextMessage.text=format_thousand(t.money)

        myData.msgTableView:deleteAllRows()
        if (t.requests[1] == nil) then
            noRequests()
        end

        for i in pairs( t.requests ) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end
            myData.msgTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = fontSize(120),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        type="requests",
                        color=color,
                        username=t.requests[i].username,
                    }  -- Include custom data in the row
                }
            ) 
        end

        myData.newRequestText = display.newText( "Send a new request", display.contentWidth/2, myData.messageRect.y+myData.messageRect.height-fontSize(250), native.systemFont, fontSize(70) )
        myData.newRequestText.anchorX=0.5
        myData.newRequestText.anchorY=0
        myData.newRequestText.x =  display.contentWidth/2
        myData.newRequestText:setTextColor( 0.9, 0.9, 0.9 )
        
        myData.newRequestInput = native.newTextField( myData.messageRect.x-myData.messageRect.width/2+50, myData.messageRect.y+myData.messageRect.height-fontSize(150), 670, fontSize(75) )
        myData.newRequestInput.anchorX = 0
        myData.newRequestInput.anchorY = 0
        myData.newRequestInput.placeholder = "Username";
        myData.newRequestInput:addEventListener("userInput", onNameEdit )

        myData.sendRequestButton = widget.newButton(
        {
            left = myData.newRequestInput.x+myData.newRequestInput.width+20,
            top = myData.newRequestInput.y-fontSize(5),
            width = 250,
            height = fontSize(90),
            defaultFile = buttonColor400,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(72),
            label = "Send",
            labelColor = tableColor1,
            onEvent = sendRequestAlert
        })

        myData.messageText.text=t.new_msg
        myData.requestText.text=t.new_req

        loaded=true
   end
end

-- Function to handle tab button events
local function handleTabBarEvent( event )
    if (event.target.id == "messages") then
        view = "messages"
        tapSound()
        clearRequests()
        loaded=false
        myData.msgTableView:deleteAllRows()
        myData.msgTableView.height=fontSize(1500)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getMessages.php", "POST", myMessagesEventListener, params )
    elseif (event.target.id == "contacts") then
        view = "contacts"
        tapSound()
        clearRequests()
        loaded=false
        myData.msgTableView:deleteAllRows()
        myData.msgTableView.height=fontSize(1500)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getMsgContacts.php", "POST", myContactsEventListener, params )
    elseif (event.target.id == "requests") then
        view = "requests"
        tapSound()
        clearRequests()
        loaded=false
        myData.msgTableView:deleteAllRows()
        myData.msgTableView.height=fontSize(1300)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getMsgRequests.php", "POST", myRequestsEventListener, params )
    end
end

function goBackMessages(event)
    if ((tutOverlay==false) and (loaded==true)) then
        backSound()
        if (msgOverlay==true) then
            composer.hideOverlay( "fade", 100 )
            msgOverlay=0
        else
            clearRequests()
            backSound()
            composer.removeScene( "messageScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 100})
        end
    end
end

refreshMsgRequestList = function(event)
    clearRequests()
    loaded=false
    myData.msgTableView:deleteAllRows()
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getMsgRequests.php", "POST", myRequestsEventListener, params )
end

refreshContactList = function(event)
    clearRequests()
    loaded=false
    myData.msgTableView:deleteAllRows()
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getMsgContacts.php", "POST", myContactsEventListener, params )
end

--Accept Request
local function acceptMsgRequestListener( event )
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
            refreshMsgRequestList()            
        end
    end
end

local function acceptMsgRequest( username )
    return function(event)
        local i = event.index
        if ( i == 1 ) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&username="..string.urlEncode(username)
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."acceptMsgRequest.php", "POST", acceptMsgRequestListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function acceptMsgRequestAlert( event )
    tapSound()
    local alert = native.showAlert( "EliteHax", "Do you want to accept the message request from "..event.target.user.."?", { "Yes", "No"}, acceptMsgRequest(event.target.user) )
end

--Reject Request
local function rejectMsgRequestListener( event )
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
            refreshMsgRequestList()            
        end
    end
end

local function rejectMsgRequest( username )
    return function(event)
        local i = event.index
        if ( i == 1 ) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&username="..string.urlEncode(username)
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."rejectMsgRequest.php", "POST", rejectMsgRequestListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function rejectMsgRequestAlert( event )
    tapSound()
    local alert = native.showAlert( "EliteHax", "Do you want to reject the message request from "..event.target.user.."?", { "Yes", "No"}, rejectMsgRequest(event.target.user) )
end

--Reject Request
local function removeContactListener( event )
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
            refreshContactList()            
        end
    end
end

local function removeContact( username )
    return function(event)
        local i = event.index
        if ( i == 1 ) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&username="..string.urlEncode(username)
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."removeContact.php", "POST", removeContactListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function removeContactAlert( event )
    tapSound()
    local alert = native.showAlert( "EliteHax", "Do you want to remove "..event.target.user.." from your contacts?", { "Yes", "No"}, removeContact(event.target.user) )
end

local function msgFromContact( event )
    msgOverlay=true
    local sceneOverlayOptions = 
    {
        time = 200,
        effect = "crossFade",
        params = { 
            username = event.target.user,
        },
        isModal = true
    }
    tapSound()
    composer.showOverlay( "privateChatScene", sceneOverlayOptions)
end

local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])

    row.rowUsername = display.newText( row, params.username, 0, 0, native.systemFont, fontSize(64) )
    row.rowUsername.anchorX = 0
    row.rowUsername.anchorY = 0
    row.rowUsername.x = 40
    row.rowUsername.y = 10
    row.rowUsername:setTextColor( 0, 0, 0 )

    if (params.type=="requests") then
        row.rowUsername.y=15
        row.removeBtn = display.newImageRect( "img/delete.png",iconSize/2.5,iconSize/2.5 )
        row.removeBtn.user = params.username
        row.removeBtn.anchorX = 0
        row.removeBtn.anchorY = 0.5
        row.removeBtn.x, row.removeBtn.y = row.x+row.width-(iconSize/2.5)*2-100, row.height/2
        row.removeBtn:addEventListener("tap",rejectMsgRequestAlert)

        row.acceptBtn = display.newImageRect( "img/accept.png",iconSize/2.5,iconSize/2.5 )
        row.acceptBtn.user = params.username
        row.acceptBtn.anchorX = 0
        row.acceptBtn.anchorY = 0.5
        row.acceptBtn.x, row.acceptBtn.y = row.removeBtn.x+row.removeBtn.width+50, row.height/2
        row.acceptBtn:addEventListener("tap",acceptMsgRequestAlert)

        row:insert(row.removeBtn)
        row:insert(row.acceptBtn)
    elseif (params.type=="contacts") then
        row.rowUsername.y=20
        row.removeBtn = display.newImageRect( "img/delete.png",iconSize/2.5,iconSize/2.5 )
        row.removeBtn.user = params.username
        row.removeBtn.anchorX = 0
        row.removeBtn.anchorY = 0.5
        row.removeBtn.x, row.removeBtn.y = row.x+row.width-(iconSize/2.5)*2-100, row.height/2
        row.removeBtn:addEventListener("tap",removeContactAlert)

        row.acceptBtn = display.newImageRect( "img/sendmail.png",iconSize/1.8,iconSize/2.5 )
        row.acceptBtn.user = params.username
        row.acceptBtn.anchorX = 0
        row.acceptBtn.anchorY = 0.5
        row.acceptBtn.x, row.acceptBtn.y = row.removeBtn.x+row.removeBtn.width+30, row.height/2
        changeImgColor(row.acceptBtn)
        row.acceptBtn:addEventListener("tap",msgFromContact)

        row:insert(row.removeBtn)
        row:insert(row.acceptBtn)
    elseif (params.type=="messages") then
        row.rowMessage = display.newText( row, params.msg, 0, 0, native.systemFont, fontSize(52) )
        row.rowMessage.anchorX = 0
        row.rowMessage.anchorY = 0
        row.rowMessage.x = 25
        row.rowMessage.y = row.rowUsername.y+row.rowUsername.height-3
        row.rowMessage:setTextColor( 0, 0, 0 )

        row.rowTimestamp = display.newText( row, params.timestamp, 0, 0, native.systemFont, fontSize(40) )
        row.rowTimestamp.anchorX = 1
        row.rowTimestamp.anchorY = 0
        row.rowTimestamp.x = myData.msgTableView.width-45
        row.rowTimestamp.y = row.rowMessage.y+row.rowMessage.height
        row.rowTimestamp:setTextColor( 0, 0, 0 )
    end
end

local function msgTableViewListener( event )
    if ((event.phase == "ended") and (math.abs(event.y-event.yStart)<50)) then
        if (view=="messages") then
            local row = event.target
            local params = event.target.params
            if (params.username ~= "") and (msgOverlay==false) then
                --row:setRowColor( tableColor1 )
                --myData.msgTableView:reloadData()
                msgOverlay=true
                local sceneOverlayOptions = 
                {
                    time = 200,
                    effect = "crossFade",
                    params = { 
                        tab = "messages",
                        username = params.username,
                    },
                    isModal = true
                }
                tapSound()
                composer.showOverlay( "privateChatScene", sceneOverlayOptions)
            end
        elseif ((view=="contacts") or (view=="requests")) then     
            local row = event.target
            local params = event.target.params 
            if (event.x<row.removeBtn.x) then      
                detailsOverlay=true
                local sceneOverlayOptions = 
                {
                    time = 200,
                    effect = "crossFade",
                    params = { 
                        id = params.username,
                    },
                    isModal = true
                }
                tapSound()
                composer.showOverlay( "playerDetailsScene", sceneOverlayOptions)
            end
        end
    end
end

function reloadMessages()
    loaded=false
    print("RELOADING")
    myData.msgTableView:deleteAllRows()
    myData.msgTableView.height=fontSize(1500)
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getMessages.php", "POST", myMessagesEventListener, params )
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function messageScene:create(event)
    group = self.view

    loginInfo = localToken()
    loaded = false
    msgOverlay = false
    iconSize=fontSize(200)

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextMessage = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextMessage.anchorX = 0
    myData.moneyTextMessage.anchorY = 0.5
    myData.moneyTextMessage:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextMessage = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextMessage.anchorX = 0.5
    myData.playerTextMessage.anchorY = 0.5
    myData.playerTextMessage:setFillColor( 0.9,0.9,0.9 )
 
-- Configure the tab buttons to appear within the bar
local options = {
    frames =
    {
        { x=4, y=0, width=24, height=120 },
        { x=32, y=0, width=40, height=120 },
        { x=72, y=0, width=40, height=120 },
        { x=112, y=0, width=40, height=120 },
        { x=152, y=0, width=328, height=120 },
        { x=480, y=0, width=328, height=120 }
    },
    sheetContentWidth = 812,
    sheetContentHeight = 120
}
local tabBarSheet = graphics.newImageSheet( tabBarColor, options )

local tabButtons = {
    {
        defaultFrame = 5,
        overFrame = 6,
        label = "Messages",
        id = "messages",
        selected = true,
        size = fontSize(50),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    },
    {
        defaultFrame = 5,
        overFrame = 6,
        label = "Contacts",
        id = "contacts",
        size = fontSize(50),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    },
    {
        defaultFrame = 5,
        overFrame = 6,
        label = "Requests",
        id = "requests",
        size = fontSize(50),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    }
}
view = "messages" 
    -- Create the widget
    myData.messageTabBar = widget.newTabBar(
        {
            sheet = tabBarSheet,
            left = 20,
            top = 20,
            width = display.contentWidth-40,
            height = 120,
            backgroundFrame = 1,
            tabSelectedLeftFrame = 2,
            tabSelectedMiddleFrame = 3,
            tabSelectedRightFrame = 4,
            tabSelectedFrameWidth = 40,
            tabSelectedFrameHeight = 120,
            buttons = tabButtons
        }
    )
    myData.messageTabBar.anchorX=0.5
    myData.messageTabBar.anchorY=0
    myData.messageTabBar.x,myData.messageTabBar.y=display.contentWidth/2,myData.top_background.y+myData.top_background.height

    myData.messageCircle = display.newCircle( myData.messageTabBar.x-myData.messageTabBar.width/2+myData.messageTabBar.width/3-20,myData.messageTabBar.y+fontSize(40), fontSize(36) )
    myData.messageCircle:setFillColor( 0 )
    myData.messageCircle.strokeWidth = 5
    myData.messageCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.messageText = display.newText("",myData.messageCircle.x,myData.messageCircle.y,native.systemFont, fontSize(50))
    myData.messageText.anchorX = 0.5
    myData.messageText.anchorY = 0.5
    myData.messageText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    myData.requestCircle = display.newCircle( myData.messageTabBar.x-myData.messageTabBar.width/2+myData.messageTabBar.width-20,myData.messageTabBar.y+fontSize(40), fontSize(36) )
    myData.requestCircle:setFillColor( 0 )
    myData.requestCircle.strokeWidth = 5
    myData.requestCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.requestText = display.newText("",myData.requestCircle.x,myData.requestCircle.y,native.systemFont, fontSize(50))
    myData.requestText.anchorX = 0.5
    myData.requestText.anchorY = 0.5
    myData.requestText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    myData.messageRect = display.newImageRect( "img/leaderboard_rect.png",display.contentWidth-20,fontSize(1580) )
    myData.messageRect.anchorX = 0.5
    myData.messageRect.anchorY = 0
    myData.messageRect.x, myData.messageRect.y = display.contentWidth/2,myData.messageTabBar.y+myData.messageTabBar.height-fontSize(22)
    changeImgColor(myData.messageRect)

    -- Create the widget
    myData.msgTableView = widget.newTableView(
        {
            left = 20,
            top = myData.messageRect.y-myData.messages.height/2+fontSize(25),
            height = fontSize(1500),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            --onRowTouch = onRowTouch,
            listener = msgTableViewListener,
            hideBackground = true
        }
    )
    myData.msgTableView.anchorX=0.5
    myData.msgTableView.anchorY=0
    myData.msgTableView.x,myData.msgTableView.y=display.contentWidth/2,myData.messageRect.y+fontSize(25)

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
        onEvent = goBackMessages
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextMessage)
    group:insert(myData.playerTextMessage)
    group:insert(myData.messageRect)
    group:insert(myData.messageTabBar)
    group:insert(myData.messageCircle)
    group:insert(myData.messageText)
    group:insert(myData.requestCircle)
    group:insert(myData.requestText)
    group:insert(myData.backButton)
    group:insert(myData.msgTableView)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackMessages)
end

-- Home Show
function messageScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "messageTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutMessage ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "messageTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        loaded=false
        myData.msgTableView:deleteAllRows()
        myData.msgTableView.height=fontSize(1500)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getMessages.php", "POST", myMessagesEventListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
messageScene:addEventListener( "create", messageScene )
messageScene:addEventListener( "show", messageScene )
---------------------------------------------------------------------------------

return messageScene