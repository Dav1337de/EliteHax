local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local myCrewMembersScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
memberLvltoName = function(lvl)
    name = "Newbies"
    if (lvl == 1) then 
        name = "Crew Mentor"
    elseif (lvl == 2) then
        name = "The Elite"
    elseif (lvl == 3) then
        name = "Experts"
    elseif (lvl == 4) then
        name = "Hackers"
    elseif (lvl == 5) then
        name = "Rookies"
    end
    return name
end

local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    if (params.title == true) then
        row.rowUsername = display.newText( row, params.username, 0, 0, native.systemFont, fontSize(70) )
        row.rowUsername:setTextColor( 0.9, 0.9, 0.9 )
        row.rowUsername.anchorX = 0.5
        row.rowUsername.anchorY = 0
        row.rowUsername.x = row.width/2 - (row.rowUsername.width/4)
        row.rowUsername.y = 10

        row.line = display.newLine( row, 0, row.contentHeight-5, row.width, row.contentHeight-5 )
        row.line.anchorY = 1
        row.line:setStrokeColor( 0, 0, 0, 1 )
        row.line.strokeWidth = 8
    else
        row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), fontSize(58) )
        row.rowRectangle.strokeWidth = 0
        row.rowRectangle.anchorX=0
        row.rowRectangle.anchorY=0
        row.rowRectangle.x,row.rowRectangle.y=10,5
        row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])
        row.rowRectangle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )

        row.upgradeImage = display.newImageRect(row, "img/profile.png", iconSize/1.6, iconSize/1.6)
        row.upgradeImage.x = iconSize/4+40
        row.upgradeImage.y = iconSize/4+fontSize(55)

        row.rowUsername = display.newText( row, params.username, 0, 0, native.systemFont, fontSize(62) )
        row.rowUsername.anchorX = 0
        row.rowUsername.anchorY = 0
        row.rowUsername.x = row.upgradeImage.x+iconSize/2-20
        row.rowUsername.y = 20
        row.rowUsername:setTextColor( 0, 0, 0 )

        local s="s"
        if (params.last_active==1) then s="" end
        row.rowScore = display.newText( row, "Score: "..format_thousand(params.score).."   Rep: "..format_thousand(params.rep).."\nLast Active: "..params.last_active.." day"..s.." ago", 0, 0, native.systemFont, fontSize(54) )
        row.rowScore.anchorX=0
        row.rowScore.anchorY=0
        row.rowScore.x = row.upgradeImage.x+iconSize/2-20
        row.rowScore.y = 100
        row.rowScore:setTextColor( 0, 0, 0 )
    end
end

local function membersTableListener(event)
    if ((event.phase == "ended") and (math.abs(event.y-event.yStart)<50)) then
        local row = event.target
        local params = event.target.params
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
            if (params.title == true) then
            elseif ((my_role < 4) and (my_role<params.role)) then
                local sceneOverlayOptions = 
                {
                    time = 100,
                    effect = "crossFade",
                    params = { 
                        member_id = params.id,
                        member_role = params.role,
                        my_role = my_role,
                        member_name = params.username,
                    },
                    isModal = true
                }
                overlayOpen=1
                tapSound()
                composer.showOverlay( "crewMemberManageScene", sceneOverlayOptions)
            end
        end
    end
end

function goBackCrewM(event)
    backSound()
    if (overlayOpen==1) then
        composer.hideOverlay( "fade", 400 )
        overlayOpen=0
    else
        composer.removeScene( "myCrewMembersScene" )
        composer.gotoScene("crewScene", {effect = "fade", time = 300})
    end
end

local function onAlert()
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
        myData.moneyTextCrewM.text = format_thousand(t.money)
        myData.moneyTextCrewM.money = t.money

        --Player
        if (string.len(t.username)>15) then myData.playerTextCrewM.size = fontSize(42) end
        myData.playerTextCrewM.text = t.username
        
        myData.crewName.text = t.crew_name.." Members"
        my_role = t.my_role

        rowColor2 = tableColor3
        rowColor = { default = { 0, 0, 0, 0 } }
        lineColor = { default = { 1, 0, 0 } }
        cur_role=0
        for i in pairs( t.members ) do
            if (t.members[i].crew_role > cur_role) then
                for j = cur_role+1, t.members[i].crew_role,1 do
                    cur_role=cur_role+1
                    myData.membersTableView:insertRow(
                    {
                        isCategory = false,
                        rowHeight = iconSize/2.2,
                        rowColor = rowColor2,
                        lineColor = lineColor,
                        params = { 
                            username=memberLvltoName(cur_role),
                            score="",        
                            rep="",
                            id="",
                            role="",
                            title=true                   
                        }  -- Include custom data in the row
                    }
                    )
                end
            end
            myData.membersTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = iconSize/2+120,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        username=t.members[i].username,
                        color=tableColor1,
                        score=t.members[i].score,        
                        rep=t.members[i].reputation,
                        id=t.members[i].player_id,
                        role=t.members[i].crew_role,
                        last_active=t.members[i].last_active,
                        title=false
                    }  -- Include custom data in the row
                }
            ) 
        end
        for i = cur_role+1, 5, 1 do
            myData.membersTableView:insertRow(
            {
                isCategory = false,
                rowHeight = iconSize/2.2,
                rowColor = rowColor2,
                lineColor = lineColor,
                params = { 
                    username=memberLvltoName(i),
                    score="",        
                    rep="",
                    id="",
                    role="",
                    title=true                   
                }  -- Include custom data in the row
            }
            )
        end
    end
end

function membersUpdate()
    myData.membersTableView:deleteAllRows()    
    composer.hideOverlay( "fade", 100 )
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getMyCrewMembers.php", "POST", networkListener, params )
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function myCrewMembersScene:create(event)
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
    myData.moneyTextCrewM = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextCrewM.anchorX = 0
    myData.moneyTextCrewM.anchorY = 0.5
    myData.moneyTextCrewM:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextCrewM = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextCrewM.anchorX = 0.5
    myData.playerTextCrewM.anchorY = 0.5
    myData.playerTextCrewM:setFillColor( 0.9,0.9,0.9 )

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

    myData.membersTableView = widget.newTableView(
    {
        left = 40,
        top = myData.top_background.y+myData.top_background.height+fontSize(110),
        height = myData.crewRect.height-fontSize(130),
        width = display.contentWidth-80,
        onRowRender = onRowRender,
        --onRowTouch = onRowTouch,
        listener = membersTableListener,
        hideBackground = true
    })
    myData.membersTableView.anchorX=0.5
    myData.membersTableView.x=display.contentWidth/2

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
        onEvent = goBackCrewM
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextCrewM)
    group:insert(myData.playerTextCrewM)
    group:insert(myData.crewRect)
    group:insert(myData.crewName)
    group:insert(myData.backButton)
    group:insert(myData.membersTableView)

    --  Button Listeners
    myData.backButton:addEventListener("tap", goBackCrewM)

end

-- Home Show
function myCrewMembersScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getMyCrewMembers.php", "POST", networkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
myCrewMembersScene:addEventListener( "create", myCrewMembersScene )
myCrewMembersScene:addEventListener( "show", myCrewMembersScene )
---------------------------------------------------------------------------------

return myCrewMembersScene