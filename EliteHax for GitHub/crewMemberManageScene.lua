local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local crewMemberManageScene = composer.newScene()
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

local function prodemoteListener( event )

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
            membersUpdate()
        end
        
    end
end

local function demoteMember( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&member_id="..params.member_id
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."demoteMember.php", "POST", prodemoteListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function promoteMember( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&member_id="..params.member_id
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."promoteMember.php", "POST", prodemoteListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function kickMember( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&member_id="..params.member_id
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."kickMember.php", "POST", prodemoteListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function demoteMemberAlert( event )
    if (event.phase=="ended") then
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you want to Demote "..params.member_name.."?", { "Yes", "No"}, demoteMember )
    end
end

local function promoteMemberAlert( event )
    if (event.phase=="ended") then
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you want to Promote "..params.member_name.."?", { "Yes", "No"}, promoteMember )
    end
end

local function kickMemberAlert( event )
    if (event.phase=="ended") then
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you want to Kick "..params.member_name.."?", { "Yes", "No"}, kickMember )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewMemberManageScene:create(event)
    group = self.view
    params = event.params

    loginInfo = localToken()

    iconSize=250

    myData.crewRect = display.newRoundedRect( display.contentWidth/2, display.contentHeight/2, display.contentWidth/1.5, display.contentHeight / 2.8, 15 )
    myData.crewRect.anchorX = 0.5
    myData.crewRect.anchorY = 0.5
    myData.crewRect.strokeWidth = 5
    myData.crewRect:setFillColor( 0,0,0 )
    myData.crewRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.crewRect.alpha = 1

    -- Crew Name
    myData.memberName = display.newText( params.member_name, 0, 0, native.systemFont, fontSize(62) )
    myData.memberName.anchorX=0.5
    myData.memberName.anchorY=0
    myData.memberName.x =  display.contentWidth/2
    myData.memberName.y = myData.crewRect.y-myData.crewRect.height/2+fontSize(140)
    myData.memberName:setTextColor( 0.9, 0.9, 0.9 )

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.closeBtn.anchorX = 0
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.crewRect.width+iconSize/3-20, myData.crewRect.y-myData.crewRect.height/2+20
    changeImgColor(myData.closeBtn)

    --  Show HUD    
    group:insert(myData.crewRect)
    group:insert(myData.memberName)
    group:insert(myData.closeBtn)

    local items=0
    if ((params.member_role>2) and (params.my_role < (params.member_role-1))) then
        myData.promoteButton = widget.newButton(
        {
            left = myData.crewRect.x-myData.crewRect.width/2+20,
            top = myData.memberName.y+100,
            width = myData.crewRect.width-40,
            height = display.contentHeight/15-5,
            defaultFile = buttonColor400,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(80),
            label = "Promote",
            labelColor = tableColor1,
            onEvent = promoteMemberAlert
        })
        group:insert(myData.promoteButton)
        myData.promoteButton:addEventListener("tap", promoteMemberAlert)
        items=items+1
    end
    
    if (params.member_role < 5) then
        myData.demoteButton = widget.newButton(
        {
            left = myData.crewRect.x-myData.crewRect.width/2+20,
            top = (myData.memberName.y+100)+(display.contentHeight/15-5)*items+20*items,
            width = myData.crewRect.width-40,
            height = display.contentHeight/15-5,
            defaultFile = buttonColor400,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(80),
            label = "Demote",
            labelColor = tableColor1,
            onEvent = demoteMemberAlert
        })
        group:insert(myData.demoteButton)
        myData.demoteButton:addEventListener("tap", demoteMemberAlert)
        items=items+1
    end

    if (params.my_role < 3) then
        myData.kickButton = widget.newButton(
        {
            left = myData.crewRect.x-myData.crewRect.width/2+20,
            top = (myData.memberName.y+100)+(display.contentHeight/15-5)*items+20*items,
            width = myData.crewRect.width-40,
            height = display.contentHeight/15-5,
            defaultFile = buttonColor400,
           -- overFile = "buttonOver.png",
            fontSize = 80,
            label = "Kick",
            labelColor = tableColor1,
            onEvent = kickMemberAlert
        })
        group:insert(myData.kickButton)
        myData.kickButton:addEventListener("tap", kickMemberAlert)
        items=items+1
    end
    items=items-1
    myData.crewRect.height = (myData.memberName.y/2)+(display.contentHeight/15-5)*items+20*items
    if (items == 1) then myData.crewRect.y = display.contentHeight/2-(display.contentHeight/15-5)+20*(items+1) end
    if (items == 0) then myData.crewRect.y = display.contentHeight/2-(display.contentHeight/15-5)-20*(items+1) end
    myData.closeBtn.y = myData.crewRect.y-myData.crewRect.height/2+20

    --  Button Listeners
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function crewMemberManageScene:show(event)
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
crewMemberManageScene:addEventListener( "create", crewMemberManageScene )
crewMemberManageScene:addEventListener( "show", crewMemberManageScene )
---------------------------------------------------------------------------------

return crewMemberManageScene