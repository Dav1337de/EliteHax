local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local logScene = composer.newScene()
local pasteboard = require( "plugin.pasteboard" )
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
-- The "onRowRender" function may go here (see example under "Inserting Rows", above)

local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])

    row.rowTitle1 = display.newText( row, params.text1, 40, 15, native.systemFont, fontSize(42) )
    row.rowTitle1.anchorX=0
    row.rowTitle1.anchorY=0
    row.rowTitle1:setTextColor( 0, 0, 0 )

    row.rowTitle2 = display.newText( row, params.text2, 40, 25, native.systemFont, fontSize(42) )
    row.rowTitle2.anchorX=0
    row.rowTitle2.anchorY=0
    row.rowTitle2:setTextColor( 0, 0, 0 )

    row.rowTitle3 = display.newText( row, params.text3, display.contentWidth/2-30, 25, native.systemFont, fontSize(42) )
    row.rowTitle3.anchorX=0
    row.rowTitle3.anchorY=0
    row.rowTitle3:setTextColor( 0, 0, 0 )
end

local function removeIPC(event)
    if (myData.IPCopied) then
        myData.IPCopied:removeSelf()
        myData.IPCopied=nil
    end
end

local function onRowTouch( event )

    local row = event.row
    local params = event.row.params

    if ((params.ip ~= "Anonymous") and (params.ip ~= "You")) then
        tapSound()
        pasteboard.copy( "string", params.ip )

        if (myData.IPCopied) then
            myData.IPCopied:removeSelf()
            myData.IPCopied=nil
        end

        myData.IPCopied = widget.newButton(
        {
            left = 20,
            top = display.actualContentHeight - (display.actualContentHeight/15)*3+topPadding(),
            width = 350,
            height = fontSize(90),
            defaultFile = buttonColor400,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(60),
            label = "IP Copied",
            labelColor = tableColor1,
            --onEvent = goBack
        })
        myData.IPCopied.anchorX=0.5
        myData.IPCopied.x=display.contentWidth/2
        timerIPC = timer.performWithDelay( 1000, removeIPC, 1 )
    end
end

local function noLogs()

    rowTitle = display.newText( "No Logs", display.contentWidth/2, myData.logs_rect.y+fontSize(120), native.systemFont, fontSize(80) )
    rowTitle.anchorX=0.5
    rowTitle.anchorY=0
    rowTitle.x =  display.contentWidth/2
    rowTitle.y = myData.logs_rect.y+fontSize(120)
    rowTitle:setTextColor( 0.9, 0.9, 0.9 )

    group:insert(rowTitle)
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

        if (t.logs[1] == nil) then
            noLogs()
        end

    myData.playerTextLogs.text=t.user
    if (string.len(t.user)>15) then myData.playerTextLogs.size = fontSize(42) end
    myData.moneyTextLogs.text = format_thousand(t.money)

    for i in pairs( t.logs ) do
    if (t.logs[i].type == "webs") then t.logs[i].type = "Web Server" end
    if (t.logs[i].type == "apps") then t.logs[i].type = "App Server" end
    if (t.logs[i].type == "dbs") then t.logs[i].type = "DB Server" end
    if (t.logs[i].type == "money") then t.logs[i].type = "Money Malware" end
    if ((t.logs[i].result == 1) and (t.logs[i].attacker == "You")) then 
        --Green
        rowColor = { default = { 0.15, 0.69, 0.17, 0.9 },over = { 0.15, 0.69, 0.17, 0.9 }}
        res = "Successful"
        moneySign = "+"
        copyIp = t.logs[i].defense
    end
    if ((t.logs[i].result == 1) and (t.logs[i].attacker ~= "You")) then 
        --Red
        rowColor = { default = { 0.69, 0.15, 0.17, 0.9 },over = { 0.69, 0.15, 0.17, 0.9 } }
        res = "Attacked"
        moneySign = "-"
        copyIp = t.logs[i].attacker
    end
    if ((t.logs[i].result == 0) and (t.logs[i].defense == "You")) then 
        rowColor = { default = { 0.10, 0.40, 0.75, 0.9 },over = { 0.10, 0.40, 0.75, 0.9 } }
        --Blue
        res = "Blocked"
        moneySign=""
        copyIp = t.logs[i].attacker
    end
    if ((t.logs[i].result == 0) and (t.logs[i].defense ~= "You")) then 
        rowColor = { default = { 0.78, 0.40, 0.17, 0.9 },over = { 0.78, 0.40, 0.17, 0.9 } }
        --Amber
        res = "Failed"
        moneySign=""
        copyIp = t.logs[i].defense
    end
    lineColor = { 
        default = { 1, 1, 0.17 }
    }

   myData.logTableView:insertRow(
        {
            isCategory = isCategory,
            rowHeight = iconSize-10,
            rowColor = { default = { 0, 0, 0, 0 },over = { 0, 0, 0, 0 } },
            lineColor = lineColor,
            params = { 
                text1="["..makeTimeStamp(t.logs[i].timestamp).."] "..res,
                text2="\nFrom: "..t.logs[i].attacker.."\nType: "..t.logs[i].type,
                text3="\nTo: "..t.logs[i].defense.."\nMoney: "..moneySign.."$"..format_thousand(t.logs[i].money_stolen),
                ip = copyIp,
                color=rowColor
            }
        }
    ) 
   end
  myData.logTableView:reloadData()

   end
end

function goBackLogs(event)
    if (tutOverlay==false) then
        if (timerIPC) then
            timer.cancel(timerIPC)
        end
        removeIPC()
        backSound()
        composer.removeScene( "logScene" )
        composer.gotoScene("homeScene", {effect = "fade", time = 300})
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function logScene:create(event)
    group = self.view

    loginInfo = localToken()

    iconSize=fontSize(200)

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextLogs = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextLogs.anchorX = 0
    myData.moneyTextLogs.anchorY = 0.5
    myData.moneyTextLogs:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextLogs = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextLogs.anchorX = 0.5
    myData.playerTextLogs.anchorY = 0.5
    myData.playerTextLogs:setFillColor( 0.9,0.9,0.9 )

    myData.logs_rect = display.newImageRect( "img/attack_logs_rect.png",display.contentWidth-20, fontSize(1660))
    myData.logs_rect.anchorX = 0.5
    myData.logs_rect.anchorY = 0
    myData.logs_rect.x, myData.logs_rect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height+10
    changeImgColor(myData.logs_rect)

    -- Create the widget
    myData.logTableView = widget.newTableView(
        {
            left = 20,
            top = myData.top_background.y+myData.top_background.height+fontSize(100),
            height = myData.logs_rect.height-fontSize(110),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.logTableView.anchorX=0.5
    myData.logTableView.x=display.contentWidth/2

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
        onEvent = goBackLogs
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.backButton)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextLogs)
    group:insert(myData.playerTextLogs)
    group:insert(myData.logs_rect)
    group:insert(myData.logTableView)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackLogs)
end

-- Home Show
function logScene:show(event)
    local logGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "logTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutLog ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "logTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getLog.php", "POST", networkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
logScene:addEventListener( "create", logScene )
logScene:addEventListener( "show", logScene )
---------------------------------------------------------------------------------

return logScene