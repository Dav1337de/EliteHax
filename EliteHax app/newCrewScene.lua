local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local newCrewScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
-- Create the widget
-- The "onRowRender" function may go here (see example under "Inserting Rows", above)
local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    if (params.title==false) then
        row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), fontSize(58) )
        row.rowRectangle.strokeWidth = 0
        row.rowRectangle.anchorX=0
        row.rowRectangle.anchorY=0
        row.rowRectangle.x,row.rowRectangle.y=10,5
        row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])
        row.rowRectangle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    end

    row.rowTag = display.newText( row, params.tag, 0, 0, native.systemFont, fontSize(58) )
    row.rowTag.anchorX = 0
    row.rowTag.anchorY = 0
    row.rowTag.x = 30
    row.rowTag.y = 20
    if (params.title == true) then
        row.rowTag:setTextColor( 0.9, 0.9, 0.9 )
    else
        row.rowTag:setTextColor( 0, 0, 0 )
    end

    row.rowName = display.newText( row, params.name, 0, 0, native.systemFont, fontSize(64) )
    row.rowName.anchorX=0
    row.rowName.anchorY=0
    row.rowName.x = 270
    row.rowName.y = 15
    if (params.title == true) then
        row.rowName:setTextColor( 0.9, 0.9, 0.9 )
    else
        row.rowName:setTextColor( 0, 0, 0 )
    end
end

local function onRowTouch( event )
    if (event.phase=="tap") then
        local row = event.row
        local params = event.row.params
        if (params.name ~= "") then
            local sceneOverlayOptions = 
            {
                time = 100,
                effect = "crossFade",
                params = { 
                    id = params.id,
                    type=params.type
                },
                isModal = true
            }
            tapSound()
            composer.showOverlay( "joinCrewScene", sceneOverlayOptions)
        end
    end
end


local function noCrews()
    rowColor = tableColor1
    lineColor = { default = { 1, 0, 0 } }
    myData.crewTableView:insertRow(
    {
        isCategory = false,
        rowHeight = iconSize/2,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            name="",
            tag="No Crew found",
            id="none",
            title=true                           
        }
    }
    )
    searchCompleted=true
end

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

        if (t.crews[1] == nil) then
            noCrews()
        else

        rowColor = { default = { 0, 0, 0, 0 } }
        lineColor = { default = { 1, 0, 0 } }

        for i in pairs( t.crews ) do
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            myData.crewTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = iconSize/2,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        name=t.crews[i].name,
                        color=color,
                        tag=t.crews[i].tag,
                        id=t.crews[i].id,
                        type="request",
                        title=false
                    }
                }
            )    
        end
        searchCompleted=true
       end
    end
end

local function clearTable()
    myData.crewTableView:deleteAllRows()
    rowColor = tableColor2
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.crewTableView:insertRow(
    {
        isCategory = true,
        rowHeight = iconSize/2,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            name="Name",
            tag="TAG",      
            id="none",
            title=true         
        }
    }
    )
end

local function close()
end

local manualSearch = function(event)
if ((event.phase == "ended") and (searchCompleted == true)) then
    if (string.len(myData.manualSearch.text) < 3) then
        local alert = native.showAlert( "EliteHax", "Insert at least 3 characters", { "Close" }, close )
    else
        clearTable()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&types=name&name="..myData.manualSearch.text
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."searchCrew.php", "POST", networkListener, params )
        searchCompleted=false
    end
end
end

local manualSearchTag = function(event)
if ((event.phase == "ended") and (searchCompleted == true)) then
    if (string.len(myData.manualSearch.text) < 3) then
        local alert = native.showAlert( "EliteHax", "Insert at least 3 characters", { "Close" }, close )
    else
        clearTable()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&types=tag&tag="..myData.manualSearch.text
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."searchCrew.php", "POST", networkListener, params )
        searchCompleted=false
    end
end
end

local createCrew = function (event)
    if (event.phase == "ended") then
        if (myData.moneyTextHome.money < 1000000) then
            local alert = native.showAlert( "EliteHax", "Not enough money!\nYou need $1.000.000 to create a new Crew", { "Close" }, close )
        else
            local sceneOverlayOptions = 
            {
                time = 100,
                effect = "crossFade",
                isModal = true
            }
            createOverlay=1
            tapSound()
            composer.showOverlay( "createCrewScene", sceneOverlayOptions)
        end
    end
end

local goBack = function(event)
    if (event.phase=="ended") then
       if myData.manualSearch then
            myData.manualSearch:removeSelf()
            myData.manualSearch = nil
       end
       backSound()
       composer.removeScene( "newCrewScene" )
       composer.gotoScene("homeScene", {effect = "fade", time = 300})
   end
end

function goBackNewCrew(event)
    if (tutOverlay==false) then
        backSound()
        if (createOverlay==1) then
            createOverlay=0
            composer.hideOverlay( "fade", 100 )
        else
            if myData.manualSearch then
                myData.manualSearch:removeSelf()
                myData.manualSearch = nil
            end
            composer.removeScene( "newCrewScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 300})
        end
    end
end

local function invitationNetworkListener( event )

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
        myData.moneyTextNC.text = format_thousand(t.money)

        --Player Name
        if (string.len(t.user)>15) then myData.playerTextNC.size = fontSize(42) end
        myData.playerTextNC.text = t.user

        rowColor = { default = { 0, 0, 0, 0 } }
        lineColor = { default = { 1, 0, 0 } }
        for i in pairs( t.invitation ) do
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            myData.inviteTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = iconSize/2,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        name=t.invitation[i].name,
                        color=color,
                        tag=t.invitation[i].tag,
                        id=t.invitation[i].id,
                        type="invitation",
                        title=false
                    }
                }
            )    
        end

    end
end

function refreshInvitation(event)
    composer.hideOverlay( "fade", 100 )
    myData.inviteTableView:deleteAllRows()
    rowColor = tableColor2
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.inviteTableView:insertRow(
    {
        isCategory = true,
        rowHeight = iconSize/2,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            name="Name",
            tag="TAG",      
            id="none",
            title=true         
        }
    }
    )
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getCrewInvitation.php", "POST", invitationNetworkListener, params )
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function newCrewScene:create(event)
    group = self.view

    loginInfo = localToken()
    createOverlay=0

    searchCompleted = true

    iconSize=fontSize(200)

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextNC = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextNC.anchorX = 0
    myData.moneyTextNC.anchorY = 0.5
    myData.moneyTextNC:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextNC = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextNC.anchorX = 0.5
    myData.playerTextNC.anchorY = 0.5
    myData.playerTextNC:setFillColor( 0.9,0.9,0.9 )

    myData.joinCrewRect = display.newImageRect( "img/crew_search_rect.png",display.contentWidth-20,fontSize(900) )
    myData.joinCrewRect.anchorX = 0.5
    myData.joinCrewRect.anchorY = 0
    myData.joinCrewRect.x, myData.joinCrewRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.joinCrewRect)

    myData.manualSearch = native.newTextField( 50, myData.joinCrewRect.y+fontSize(120), display.contentWidth-100, fontSize(85) )
    myData.manualSearch.anchorX = 0
    myData.manualSearch.anchorY = 0
    myData.manualSearch.placeholder = "Insert Crew name or tag";
    myData.manualSearchTagButton = widget.newButton(
    {
        left = display.contentWidth/2+10,
        top = myData.manualSearch.y+120,
        width = display.contentWidth/2-60,
        height = myData.manualSearch.height,
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Search by Tag",
        labelColor = tableColor1,
        onEvent = manualSearchTag
    })
    myData.manualSearchButton = widget.newButton(
    {
        left = myData.manualSearchTagButton.x-myData.manualSearchTagButton.width*1.5-20,
        top = myData.manualSearch.y+120,
        width = display.contentWidth/2-60,
        height = myData.manualSearch.height,
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Search by Name",
        labelColor = tableColor1,
        onEvent = manualSearch
    })
    myData.crewTableView = widget.newTableView(
    {
        left = 40,
        top = myData.manualSearchButton.y+myData.manualSearchButton.height,
        height =  fontSize(500),
        width = display.contentWidth-80,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
        listener = scrollListener,
        hideBackground = true
    })
    rowColor = tableColor2
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.crewTableView:insertRow(
    {
        isCategory = true,
        rowHeight = iconSize/2,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            name="Name",
            tag="TAG",        
            id="none",
            title=true                   
        }  -- Include custom data in the row
    }
    )

    myData.acceptCrewRect = display.newImageRect( "img/crew_invite_rect.png",display.contentWidth-20,fontSize(600) )
    myData.acceptCrewRect.anchorX = 0.5
    myData.acceptCrewRect.anchorY = 0
    myData.acceptCrewRect.x, myData.acceptCrewRect.y = display.contentWidth/2,myData.joinCrewRect.y+myData.joinCrewRect.height+fontSize(10)
    changeImgColor(myData.acceptCrewRect)

    myData.inviteTableView = widget.newTableView(
    {
        left = 40,
        top = myData.acceptCrewRect.y+fontSize(100),
        height =  fontSize(470),
        width = display.contentWidth-80,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
        listener = scrollListener,
        hideBackground = true
    })
    rowColor = tableColor2
    lineColor = { 
      default = { 1, 0, 0 }
    }
    myData.inviteTableView:insertRow(
    {
        isCategory = true,
        rowHeight = iconSize/2,
        rowColor = rowColor,
        lineColor = lineColor,
        params = { 
            name="Name",
            tag="TAG",        
            id="none",
            title=true                   
        }  -- Include custom data in the row
    }
    )

    myData.createCrewButton = widget.newButton(
    {
        left = 40,
        top =  display.actualContentHeight-iconSize*1.5+topPadding(),
        width = display.contentWidth-40,
        height = myData.manualSearch.height*2,
        defaultFile = buttonColor1080,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "Create a new Crew\n     ($1.000.000)",
        labelColor = tableColor1,
        onEvent = createCrew
    })
    myData.createCrewButton.anchorX = 0.5
    myData.createCrewButton.x = display.contentWidth/2

    myData.backButton = widget.newButton(
    {
        left = 20,
        top =  display.actualContentHeight - ( display.actualContentHeight/15)+topPadding(),
        width = display.contentWidth - 40,
        height =  display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Back",
        labelColor = tableColor1,
        onEvent = goBack
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextNC)
    group:insert(myData.playerTextNC)
    group:insert(myData.joinCrewRect)
    group:insert(myData.manualSearch)
    group:insert(myData.manualSearchButton)
    group:insert(myData.manualSearchTagButton)
    group:insert(myData.crewTableView)
    group:insert(myData.acceptCrewRect)
    group:insert(myData.inviteTableView)
    group:insert(myData.createCrewButton)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
    myData.manualSearchButton:addEventListener("tap",manualSearch)
    myData.manualSearchTagButton:addEventListener("tap",manualSearchTag)
    myData.createCrewButton:addEventListener("tap",createCrew)
end

-- Home Show
function newCrewScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "crew2TutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutCrew2 ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "crew2TutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getCrewInvitation.php", "POST", invitationNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end

function newCrewScene:destroy(event)
   if myData.manualSearch then
        myData.manualSearch:removeSelf()
        myData.manualSearch = nil
   end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
newCrewScene:addEventListener( "create", newCrewScene )
newCrewScene:addEventListener( "show", newCrewScene )
newCrewScene:addEventListener( "destroy" , newCrewScene)
---------------------------------------------------------------------------------

return newCrewScene