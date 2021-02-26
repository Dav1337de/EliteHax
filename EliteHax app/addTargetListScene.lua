local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local addTargetListScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    backSound()
    composer.hideOverlay( "fade", 100 )
    addTargetOverlay=false
end

local function onAlert()
end

local function addToTargetListListener( event )

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

        if (t.status == "TL") then
            local alert = native.showAlert( "EliteHax", "You already have 15 targets on your list!", { "Close" } )
            addTargetRx=true
        elseif (t.status == "AA") then
            local alert = native.showAlert( "EliteHax", "IP Address already in Target List!", { "Close" } )
            addTargetRx=true
        elseif (t.status == "OK") then
            composer.hideOverlay( "fade", 100 )
            addTargetRx=true
            refreshTargetList()
        end
    end
end

local function addTargetList(event)
    if ((event.phase == "ended") and (addTargetRx == true)) then
        if (isIpAddress(myData.addTargetListIPT.text)) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&t_name="..myData.addTargetListNameT.text.."&t_ip="..myData.addTargetListIPT.text.."&t_desc="..myData.addTargetListDescT.text
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."addToTargetList.php", "POST", addToTargetListListener, params )    
            addTargetRx=false
        end
    end
end

local function onNameEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.addTargetListNameT.text = string.sub(event.text,1,18)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.addTargetListNameT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

local function onIPEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>15) then
            myData.addTargetListIPT.text = string.sub(event.text,1,15)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%d%.]")) then
            myData.addTargetListIPT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

local function onDescEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>20) then
            myData.addTargetListDescT.text = string.sub(event.text,1,20)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.addTargetListDescT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function addTargetListScene:create(event)
    ATLgroup = self.view

    addTargetRx=true

    loginInfo = localToken()

    myData.addTargetListRect =  display.newImageRect( "img/terminal_add_target_list.png",display.contentWidth-70,fontSize(800) )
    myData.addTargetListRect.anchorX = 0
    myData.addTargetListRect.anchorY = 0.5
    myData.addTargetListRect:translate(40, display.contentHeight/2)
    changeImgColor(myData.addTargetListRect)

    myData.addTargetListName = display.newText( "Name: ", 0, 0, native.systemFont, fontSize(60) )
    myData.addTargetListName.anchorX=0
    myData.addTargetListName.anchorY=0
    myData.addTargetListName:translate(80,myData.addTargetListRect.y-myData.addTargetListRect.height/2+fontSize(230))
    myData.addTargetListName:setTextColor( 0.9, 0.9, 0.9 )
    myData.addTargetListNameT = native.newTextField( myData.addTargetListName.x+myData.addTargetListName.width+150, myData.addTargetListName.y-10, display.contentWidth/2+20, fontSize(85) )
    myData.addTargetListNameT.anchorX = 0
    myData.addTargetListNameT.anchorY = 0
    myData.addTargetListNameT.placeholder = "Name (max 18)";

    myData.addTargetListIP = display.newText( "IP: ", 0, 0, native.systemFont, fontSize(60) )
    myData.addTargetListIP.anchorX=0
    myData.addTargetListIP.anchorY=0
    myData.addTargetListIP:translate(myData.addTargetListName.x,myData.addTargetListName.y+myData.addTargetListName.height+fontSize(50))
    myData.addTargetListIP:setTextColor( 0.9, 0.9, 0.9 )
    myData.addTargetListIPT = native.newTextField( myData.addTargetListNameT.x, myData.addTargetListIP.y-10, display.contentWidth/2+20, fontSize(85) )
    myData.addTargetListIPT.anchorX = 0
    myData.addTargetListIPT.anchorY = 0
    myData.addTargetListIPT.placeholder = "Target IP";

    myData.addTargetListDesc = display.newText( "Description", 0, 0, native.systemFont, fontSize(60) )
    myData.addTargetListDesc.anchorX=0
    myData.addTargetListDesc.anchorY=0
    myData.addTargetListDesc:translate(myData.addTargetListName.x,myData.addTargetListIP.y+myData.addTargetListIP.height+fontSize(50))
    myData.addTargetListDesc:setTextColor( 0.9, 0.9, 0.9 )
    myData.addTargetListDescT = native.newTextField( myData.addTargetListIPT.x, myData.addTargetListDesc.y-10, display.contentWidth/2+20, fontSize(85) )
    myData.addTargetListDescT.anchorX = 0
    myData.addTargetListDescT.anchorY = 0
    myData.addTargetListDescT.placeholder = "Description (max 20)";

    -- Close Button
    myData.addTargetListClose = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.addTargetListClose.anchorX = 1
    myData.addTargetListClose.anchorY = 0
    myData.addTargetListClose:translate(myData.addTargetListRect.width-10, myData.addTargetListRect.y-myData.addTargetListRect.height/2+fontSize(80))
    changeImgColor(myData.addTargetListClose)

    -- Request Button
    myData.addTargetListBtn = widget.newButton(
    {
        left = 40,
        top = myData.addTargetListDescT.y+fontSize(160),
        width = display.contentWidth/2,
        height = fontSize(110),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Add Target",
        labelColor = tableColor1,
        onEvent = addTargetList
    })
    myData.addTargetListBtn.anchorX = 0.5
    myData.addTargetListBtn.x = display.contentWidth/2

    --  Show HUD    
    ATLgroup:insert(myData.addTargetListRect)
    ATLgroup:insert(myData.addTargetListName)
    ATLgroup:insert(myData.addTargetListIP)
    ATLgroup:insert(myData.addTargetListDesc)
    ATLgroup:insert(myData.addTargetListBtn)
    ATLgroup:insert(myData.addTargetListNameT)
    ATLgroup:insert(myData.addTargetListIPT)
    ATLgroup:insert(myData.addTargetListDescT)
    ATLgroup:insert(myData.addTargetListClose)

    --  Button Listeners
    myData.addTargetListClose:addEventListener("tap", close)
    myData.addTargetListBtn:addEventListener("tap", addTargetList)
    myData.addTargetListNameT:addEventListener( "userInput", onNameEdit )
    myData.addTargetListIPT:addEventListener( "userInput", onIPEdit )
    myData.addTargetListDescT:addEventListener( "userInput", onDescEdit )

end

-- Home Show
function addTargetListScene:show(event)
    local taskATLgroup = self.view
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
addTargetListScene:addEventListener( "create", addTargetListScene )
addTargetListScene:addEventListener( "show", addTargetListScene )
---------------------------------------------------------------------------------

return addTargetListScene