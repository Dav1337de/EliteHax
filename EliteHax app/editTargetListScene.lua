local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local editTargetListScene = composer.newScene()
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

local function editTargetListListener( event )

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
            composer.hideOverlay( "fade", 100 )
            editTargetRx=true
            refreshTargetList()
        end
    end
end

local function editTargetList(event)
    if ((event.phase == "ended") and (editTargetRx == true)) then
        if (isIpAddress(myData.editTargetListIPT.text)) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&t_name="..myData.editTargetListNameT.text.."&t_ip="..myData.editTargetListIPT.text.."&t_desc="..myData.editTargetListDescT.text
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."editTargetList.php", "POST", editTargetListListener, params )    
            editTargetRx=false
        end
    end
end

local function onNameEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.editTargetListNameT.text = string.sub(event.text,1,18)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.editTargetListNameT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

local function onDescEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>20) then
            myData.editTargetListDescT.text = string.sub(event.text,1,20)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.editTargetListDescT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function editTargetListScene:create(event)
    ATLgroup = self.view
    ATLparams = event.params

    editTargetRx=true

    loginInfo = localToken()

    myData.editTargetListRect =  display.newImageRect( "img/terminal_edit_target_list.png",display.contentWidth-70,fontSize(800) )
    myData.editTargetListRect.anchorX = 0
    myData.editTargetListRect.anchorY = 0.5
    myData.editTargetListRect.x,myData.editTargetListRect.y = 40, display.contentHeight/2
    changeImgColor(myData.editTargetListRect)

    myData.editTargetListName = display.newText( "Name: ", 0, 0, native.systemFont, fontSize(60) )
    myData.editTargetListName.anchorX=0
    myData.editTargetListName.anchorY=0
    myData.editTargetListName.x =  80
    myData.editTargetListName.y = myData.editTargetListRect.y-myData.editTargetListRect.height/2+fontSize(230)
    myData.editTargetListName:setTextColor( 0.9, 0.9, 0.9 )
    myData.editTargetListNameT = native.newTextField( myData.editTargetListName.x+myData.editTargetListName.width+150, myData.editTargetListName.y-10, display.contentWidth/2+20, fontSize(85) )
    myData.editTargetListNameT.anchorX = 0
    myData.editTargetListNameT.anchorY = 0
    myData.editTargetListNameT.placeholder = "Name (max 18)";
    myData.editTargetListNameT.text=ATLparams.name

    myData.editTargetListIP = display.newText( "IP: ", 0, 0, native.systemFont, fontSize(60) )
    myData.editTargetListIP.anchorX=0
    myData.editTargetListIP.anchorY=0
    myData.editTargetListIP.x =  myData.editTargetListName.x
    myData.editTargetListIP.y = myData.editTargetListName.y+myData.editTargetListName.height+fontSize(50)
    myData.editTargetListIP:setTextColor( 0.9, 0.9, 0.9 )
    myData.editTargetListIPT = display.newText(ATLparams.ip, myData.editTargetListNameT.x, myData.editTargetListIP.y, display.contentWidth/2+20, fontSize(85) )
    myData.editTargetListIPT.anchorX = 0
    myData.editTargetListIPT.anchorY = 0

    myData.editTargetListDesc = display.newText( "Description", 0, 0, native.systemFont, fontSize(60) )
    myData.editTargetListDesc.anchorX=0
    myData.editTargetListDesc.anchorY=0
    myData.editTargetListDesc.x =  myData.editTargetListName.x
    myData.editTargetListDesc.y = myData.editTargetListIP.y+myData.editTargetListIP.height+fontSize(50)
    myData.editTargetListDesc:setTextColor( 0.9, 0.9, 0.9 )
    myData.editTargetListDescT = native.newTextField( myData.editTargetListIPT.x, myData.editTargetListDesc.y-10, display.contentWidth/2+20, fontSize(85) )
    myData.editTargetListDescT.anchorX = 0
    myData.editTargetListDescT.anchorY = 0
    myData.editTargetListDescT.placeholder = "Description (max 20)";
    myData.editTargetListDescT.text=ATLparams.desc

    -- Close Button
    myData.editTargetListClose = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.editTargetListClose.anchorX = 1
    myData.editTargetListClose.anchorY = 0
    myData.editTargetListClose.x, myData.editTargetListClose.y = myData.editTargetListRect.width-10, myData.editTargetListRect.y-myData.editTargetListRect.height/2+fontSize(80)
    changeImgColor(myData.editTargetListClose)

    -- Request Button
    myData.editTargetListBtn = widget.newButton(
    {
        left = 40,
        top = myData.editTargetListDescT.y+fontSize(160),
        width = display.contentWidth/2,
        height = fontSize(110),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Edit Target",
        labelColor = tableColor1,
        onEvent = editTargetList
    })
    myData.editTargetListBtn.anchorX = 0.5
    myData.editTargetListBtn.x = display.contentWidth/2

    --  Show HUD    
    ATLgroup:insert(myData.editTargetListRect)
    ATLgroup:insert(myData.editTargetListName)
    ATLgroup:insert(myData.editTargetListIP)
    ATLgroup:insert(myData.editTargetListDesc)
    ATLgroup:insert(myData.editTargetListBtn)
    ATLgroup:insert(myData.editTargetListNameT)
    ATLgroup:insert(myData.editTargetListIPT)
    ATLgroup:insert(myData.editTargetListDescT)
    ATLgroup:insert(myData.editTargetListClose)

    --  Button Listeners
    myData.editTargetListClose:addEventListener("tap", close)
    myData.editTargetListBtn:addEventListener("tap", editTargetList)
    myData.editTargetListNameT:addEventListener( "userInput", onNameEdit )
    myData.editTargetListDescT:addEventListener( "userInput", onDescEdit )

end

-- Home Show
function editTargetListScene:show(event)
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
editTargetListScene:addEventListener( "create", editTargetListScene )
editTargetListScene:addEventListener( "show", editTargetListScene )
---------------------------------------------------------------------------------

return editTargetListScene