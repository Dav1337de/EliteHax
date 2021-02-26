local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local upgrades = require("upgradeName")
local c2cManageScene = composer.newScene()
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

    if (params.type == "bot") then
        row.rowIncome = display.newText( row, "$"..format_thousand(params.income*2).. "/h", 0, 0, native.systemFont, fontSize(60) )
        row.rowIncome.anchorX=0
        row.rowIncome.anchorY=0
        row.rowIncome:translate(40,15)
        row.rowIncome:setTextColor( 0, 0, 0 )

        row.rowLvls = display.newText( row, "Malware Lvl: "..params.malware_lvl.."\nAntivirus Lvl: "..params.av_lvl, 0, 0, native.systemFont, fontSize(50) )
        row.rowLvls.anchorX = 0
        row.rowLvls.anchorY = 0
        row.rowLvls:translate(row.width-row.rowLvls.width-40,20)
        row.rowLvls:setTextColor( 0, 0, 0 )

        local daystxt = "days"
        if (params.days == 1) then daystxt = "day" end
        row.rowDays = display.newText( row, "Active since "..params.days.." "..daystxt, 0, 0, native.systemFont, fontSize(50) )
        row.rowDays.anchorX = 0
        row.rowDays:translate(40,row.rowIncome.y+row.rowIncome.height+20)
        row.rowDays:setTextColor( 0, 0, 0 )

    elseif (params.type == "rat") then
        row.rowIncome = display.newText( row, "User: "..params.user.."\nIP: "..params.ip.."\nMoney: $"..format_thousand(params.money), 0, 0, native.systemFont, fontSize(50) )
        row.rowIncome.anchorX=0
        row.rowIncome.anchorY=0
        row.rowIncome:translate(30,15)
        row.rowIncome:setTextColor( 0, 0, 0 )

        row.rowLvls = display.newText( row, "Malware Lvl: "..params.malware_lvl.."\nAntivirus Lvl: "..params.av_lvl.."\nFirewall Lvl: "..params.fw_lvl, 0, 0, native.systemFont, fontSize(50) )
        row.rowLvls.anchorX = 0
        row.rowLvls.anchorY = 0
        row.rowLvls:translate(row.width-row.rowLvls.width-40,15)
        row.rowLvls:setTextColor( 0, 0, 0 )

        if (params.secs == 0) then timeDisplay = "Now"
        else
            minutes = math.floor( params.secs / 60 )
            timeDisplay = string.format( "%01d", minutes )
            timeDisplay = timeDisplay.."m"
        end
        local daystxt = "days"
        if (params.days == 1) then daystxt = "day" end
        row.rowDays = display.newText( row, "Active since "..params.days.." "..daystxt.. " / Next Attack: "..timeDisplay, 0, 0, native.systemFont, fontSize(50) )
        row.rowDays.anchorX = 0.5
        row.rowDays:translate(display.contentWidth/2-40,row.rowIncome.y+row.rowIncome.height+30)
        row.rowDays:setTextColor( 0, 0, 0 )
    end
end

local function onRowTouch( event )
    local row = event.row
    local params = event.row.params
    if (event.phase == "tap") then
        if (params.income ~= nil) then
            local sceneOverlayOptions = 
            {
                time = 300,
                effect = "crossFade",
                params = { 
                    uuid=params.uuid,
                    y=myData.botTableView.contentHeight/2+row.y/2+iconSize/2
                },
                isModal = true
            }
            malwareOverlay=true
            tapSound()
            composer.showOverlay( "removeBotScene", sceneOverlayOptions)
        else
            local sceneOverlayOptions = 
            {
                time = 300,
                effect = "crossFade",
                params = { 
                    uuid=params.uuid,
                    ip=params.ip,
                    id=params.id,
                    user=params.user,
                    money=params.money
                },
                isModal = true
            }
            malwareOverlay=true
            tapSound()
            composer.showOverlay( "ratAttackScene", sceneOverlayOptions) 
        end
    end
end

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local function ratEventListener( event )
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
        if (string.len(t.username)>15) then myData.playerTextCNC.size = fontSize(42) end
        myData.playerTextCNC.text=t.username
        myData.moneyTextCNC.text=format_thousand(t.money)

        if (t.rat_on_me == 0) then myData.myInfectionsTxt.text = "It seems that you're not infected"
        elseif (t.rat_on_me == 1) then myData.myInfectionsTxt.text = "You have at least "..t.rat_on_me.." infection!"
        else myData.myInfectionsTxt.text = "You have at least "..t.rat_on_me.." infections!" end

        myData.botSummary.text = t.my_rat_count.."/"..t.max_rats.." RATs Implanted"

        if (sorting=='timeD') then
            t.my_rats=quicksortD(t.my_rats,'secs')
        elseif (sorting=='timeA') then
            t.my_rats=quicksortA(t.my_rats,'secs')
        elseif (sorting=='moneyA') then
            t.my_rats=quicksortA(t.my_rats,'money')
        elseif (sorting=='moneyD') then
            t.my_rats=quicksortD(t.my_rats,'money')
        end

        for i in pairs( t.my_rats ) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            myData.botTableView:insertRow(
            {
                isCategory = isCategory,
                rowHeight = fontSize(270),
                rowColor = rowColor,
                lineColor = lineColor,
                params = { 
                    type="rat",
                    color=color,
                    id=t.my_rats[i].defense_id,
                    user=t.my_rats[i].defense_user,
                    ip=t.my_rats[i].defense_ip,
                    uuid=t.my_rats[i].defense_uuid,
                    fw_lvl=t.my_rats[i].defense_fw,
                    secs=t.my_rats[i].secs,
                    days=t.my_rats[i].days,
                    money=t.my_rats[i].money,
                    av_lvl=t.my_rats[i].defense_av,   
                    malware_lvl=t.my_rats[i].my_malware,                             
                }  -- Include custom data in the row
            })    
        end
        loaded=true
   end
end

local function botEventListener( event )
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
        if (string.len(t.username)>15) then myData.playerTextCNC.size = fontSize(42) end
        myData.playerTextCNC.text=t.username
        myData.moneyTextCNC.text=format_thousand(t.money)

        if (t.bot_on_me == 0) then myData.myInfectionsTxt.text = "It seems that you're not infected"
        elseif (t.bot_on_me == 1) then myData.myInfectionsTxt.text = "You have at least "..t.bot_on_me.." infection!"
        else myData.myInfectionsTxt.text = "You have at least "..t.bot_on_me.." infections!" end

        myData.botSummary.text = t.my_bot_count.."/"..t.max_bots.." Bots Implanted\n$"..format_thousand(t.tot_income).."/Hourly Income"

        for i in pairs( t.my_bots ) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            myData.botTableView:insertRow(
            {
                isCategory = isCategory,
                rowHeight = fontSize(160),
                rowColor = rowColor,
                lineColor = lineColor,
                params = { 
                    type="bot",
                    color=color,
                    uuid=t.my_bots[i].defense_uuid,
                    days=t.my_bots[i].days,
                    income=t.my_bots[i].income,
                    av_lvl=t.my_bots[i].defense_av,   
                    malware_lvl=t.my_bots[i].my_malware,                             
                }
            })    
        end
        loaded=true
   end
end

function ratUpdate()
    myData.botTableView:deleteAllRows()    
    composer.hideOverlay( "fade", 100 )
    malwareOverlay=false
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getRAT.php", "POST", ratEventListener, params )
end

function botUpdate()
    myData.botTableView:deleteAllRows()    
    composer.hideOverlay( "fade", 100 )
    malwareOverlay=false
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getBots.php", "POST", botEventListener, params )
end

local function removeMyBotsEventListener( event )

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
            if (tabBarFocus == "BOT") then
                botUpdate()
            elseif (tabBarFocus == "RAT") then
                ratUpdate()
            end
        end
    end
end

local function removeMyInfections(event)
    if (loaded==true) then
        if (event.phase == "ended") then
            tapSound()
            if (tabBarFocus == "BOT") then
                loaded=false
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."removeMyBots.php", "POST", removeMyBotsEventListener, params )
            elseif (tabBarFocus == "RAT") then
                loaded=false
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token)
                local params = {}
                params.headers = headers
                params.body = body
                network.request( host().."removeMyRats.php", "POST", removeMyBotsEventListener, params )
            end
        end
    end
end

-- Function to handle tab button events
local function handleTabBarEvent( event )
    if (loaded==true) then
        if (event.target.id == "bot") then
            myData.botSortM.alpha=0
            myData.botSortA.alpha=0
            myData.botSortN.alpha=0
            myData.botSortO.alpha=0
            loaded=false
            tapSound()
            tabBarFocus = "BOT"
            myData.botTableView:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getBots.php", "POST", botEventListener, params )
        end
        if (event.target.id == "rat") then
            myData.botSortM.alpha=1
            myData.botSortA.alpha=1
            myData.botSortN.alpha=1
            myData.botSortO.alpha=1
            loaded=false
            tapSound()
            tabBarFocus = "RAT"
            myData.botTableView:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getRAT.php", "POST", ratEventListener, params )
        end
    end
end

function goBackC2C(event)
    if (tutOverlay==false) then
        if (malwareOverlay==true) then
            composer.hideOverlay( "fade", 0 )
            malwareOverlay=false
        else
            backSound()
            composer.removeScene( "c2cManageScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 100})
        end
    end
end

local goBack = function(event)
    if (event.phase=="ended") then
        backSound()
        composer.removeScene( "c2cManageScene" )
        composer.gotoScene("homeScene", {effect = "fade", time = 100})
    end
end

local function sortRat(event)
    myData.botTableView:deleteAllRows()
    sorting=event.target.next
    local sort_temp=sorting
    if ((sort_temp=='timeA') or (sort_temp=='timeD')) then
        sort_temp='ageD'
    end
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token).."&sort="..sort_temp
    if (event.target.next=="nameA") then
        event.target.next="nameD"
    elseif (event.target.next=="nameD") then
        event.target.next="nameA"
    elseif (event.target.next=="moneyD") then
        event.target.next="moneyA"
    elseif (event.target.next=="moneyA") then
        event.target.next="moneyD"
    elseif (event.target.next=="timeA") then
        event.target.next="timeD"
    elseif (event.target.next=="timeD") then
        event.target.next="timeA"
    elseif (event.target.next=="ageA") then
        event.target.next="ageD"
    elseif (event.target.next=="ageD") then
        event.target.next="ageA"
    end
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getRAT.php", "POST", ratEventListener, params )
    myData.botSortM._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    myData.botSortA._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    myData.botSortN._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    myData.botSortO._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    event.target._view._label._labelColor=tableColor3
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function c2cManageScene:create(event)
    group = self.view

    loginInfo = localToken()
    loaded=true
    malwareOverlay=false
    sorting="ageD"

    iconSize=200*display.actualContentHeight/display.contentHeight

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background:translate(display.contentWidth/2,5+topPadding())
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextCNC = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextCNC.anchorX = 0
    myData.moneyTextCNC.anchorY = 0.5
    myData.moneyTextCNC:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextCNC = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextCNC.anchorX = 0.5
    myData.playerTextCNC.anchorY = 0.5
    myData.playerTextCNC:setFillColor( 0.9,0.9,0.9 )

    tabBarFocus = "BOT"
 
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
        label = "Bot",
        id = "bot",
        selected = true,
        size = fontSize(60),
        labelYOffset = -20,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    },
    {
        defaultFrame = 5,
        overFrame = 6,
        label = "RAT",
        id = "rat",
        size = fontSize(60),
        labelYOffset = -20,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    }
}
 
    -- Create the widget
    myData.tabBar = widget.newTabBar(
        {
            sheet = tabBarSheet,
            top = myData.top_background.y+myData.top_background.height,
            left = 20,
            width = display.contentWidth-40,
            height = 120,
            backgroundFrame = 1,
            tabSelectedLeftFrame = 2,
            tabSelectedMiddleFrame = 3,
            tabSelectedRightFrame = 4,
            tabSelectedFrameWidth = 120,
            tabSelectedFrameHeight = 160,
            buttons = tabButtons
        }
    )

    myData.cncRect = display.newImageRect( "img/leaderboard_rect.png",display.contentWidth-20,fontSize(1580) )
    myData.cncRect.anchorX = 0.5
    myData.cncRect.anchorY = 0
    myData.cncRect:translate(display.contentWidth/2,myData.tabBar.y+myData.tabBar.height/2-fontSize(22))
    changeImgColor(myData.cncRect)

    --My BOT/RAT Infections Rect
    myData.myInfections = display.newImageRect( "img/rect_300.png",display.contentWidth-80,fontSize(260) )
    myData.myInfections.anchorX = 0.5
    myData.myInfections.anchorY = 0
    myData.myInfections:translate(display.contentWidth/2,myData.tabBar.y+myData.tabBar.height/2+20)
    changeImgColor(myData.myInfections)

    --My BOT/RAT Infections Text
    myData.myInfectionsTxt = display.newText("",display.contentWidth/2,myData.myInfections.y+20,native.systemFont, fontSize(60))
    myData.myInfectionsTxt.anchorX = 0.5
    myData.myInfectionsTxt.anchorY = 0
    myData.myInfectionsTxt:setFillColor( 0.9, 0.9, 0.9 )

    --Remove Infections Button
    myData.removeMyInfectionsBtn = widget.newButton(
    {
        left = 60,
        top = myData.myInfectionsTxt.y+myData.myInfectionsTxt.height+20,
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(70),
        label = "Remove Infections",
        labelColor = tableColor1,
        onEvent = removeMyInfections
    })

    --BOT Summary
    local options = 
    {
        text = "\n",     
        x = display.contentWidth/2,
        y = myData.myInfections.y+myData.myInfections.height+20,
        width = fontSize(800),
        font = native.systemFont,   
        fontSize = fontSize(60),
        align = "center"  -- Alignment parameter
    }
    myData.botSummary = display.newText( options )
    myData.botSummary.anchorX=0.5
    myData.botSummary.anchorY=0
    myData.botSummary:setTextColor( 0.9, 0.9, 0.9 )

    myData.botSortN = widget.newButton(
    {
        left = 40,
        top = myData.botSummary.y+myData.botSummary.height/2,
        width = 250,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Name",
        labelColor = tableColor1,
        onRelease = sortRat
    })
    myData.botSortN.next="nameA"
    myData.botSortN.alpha=0

    myData.botSortM = widget.newButton(
    {
        left = myData.botSortN.x+myData.botSortN.width/2,
        top = myData.botSortN.y-myData.botSortN.height/2,
        width = 250,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Money",
        labelColor = tableColor1,
        onRelease = sortRat
    })
    myData.botSortM.next="moneyD"
    myData.botSortM.alpha=0

    myData.botSortA = widget.newButton(
    {
        left = myData.botSortM.x+myData.botSortM.width/2,
        top = myData.botSortN.y-myData.botSortN.height/2,
        width = 250,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Attack",
        labelColor = tableColor1,
        onRelease = sortRat
    })
    myData.botSortA.next="timeA"
    myData.botSortA.alpha=0

    myData.botSortO = widget.newButton(
    {
        left = myData.botSortA.x+myData.botSortA.width/2,
        top = myData.botSortN.y-myData.botSortN.height/2,
        width = 250,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Age",
        labelColor = tableColor3,
        onRelease = sortRat
    })
    myData.botSortO.next="ageA"
    myData.botSortO.alpha=0

    -- Create the widget
    myData.botTableView = widget.newTableView(
        {
            left = myData.cncRect.x,
            top = myData.botSummary.y+myData.botSummary.height,
            height = fontSize(1070),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.botTableView.anchorX=0.5
    myData.botTableView.x=display.contentWidth/2

    myData.backButton = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15)+topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = 80,
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
    group:insert(myData.playerTextCNC)
    group:insert(myData.moneyTextCNC)
    group:insert(myData.cncRect)
    group:insert(myData.backButton)
    group:insert(myData.botTableView)
    group:insert(myData.botSummary)
    group:insert(myData.myInfections)
    group:insert(myData.myInfectionsTxt)
    group:insert(myData.removeMyInfectionsBtn)
    group:insert(myData.tabBar)
    group:insert(myData.botSortN)
    group:insert(myData.botSortA)
    group:insert(myData.botSortM)
    group:insert(myData.botSortO)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
end

-- Home Show
function c2cManageScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "c2cTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutc2c ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "c2cTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getBots.php", "POST", botEventListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
c2cManageScene:addEventListener( "create", c2cManageScene )
c2cManageScene:addEventListener( "show", c2cManageScene )
---------------------------------------------------------------------------------

return c2cManageScene