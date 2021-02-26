local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local notifications = require( "plugin.notifications" )
local upgrades = require("upgradeName")
local taskScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local updateTimer
updateTasks = nil

local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])

    row.rowTitle = display.newText( row, params.text1, 0, 0, native.systemFont, fontSize(56) )
    row.rowTitle.anchorX=0
    row.rowTitle.anchorY=0
    row.rowTitle.x =  iconSize+40
    row.rowTitle.y = row.contentHeight * 0.15
    row.rowTitle:setTextColor( 0, 0, 0 )

    row.rowTimer = display.newText( row, params.text2, 0, 0, native.systemFont, fontSize(50) )
    row.rowTimer.anchorX = 0
    row.rowTimer.x =  iconSize+40
    row.rowTimer.y = row.contentHeight * 0.56
    row.rowTimer:setTextColor( 0, 0, 0 )

    row.upgradeName = params.upgradeName
    row.upgradeLvl = params.upgradeLvl

    upgradeImage = display.newImageRect(row, params.img, iconSize/1.5, iconSize/1.5)
    upgradeImage.x = (iconSize/2)+20
    upgradeImage.y = (iconSize/2)-15
end

local function onRowTouch( event )
    if (event.phase=="tap") then
        local row = event.row
        local params = event.row.params
        local canAbort=true
        if (params.timer==0) then canAbort=false end
        local taskTableViewRows = myData.taskTableView._view._rows
        for i,row in ipairs( taskTableViewRows ) do
            if ( myData.taskTableView:getRowAtIndex(i) ) then
                local rowName = myData.taskTableView:getRowAtIndex(i).upgradeName
                local rowLvl = myData.taskTableView:getRowAtIndex(i).upgradeLvl
                if ((rowName==params.upgradeName) and (rowLvl>params.upgradeLvl)) then
                    canAbort=false
                end
            end
        end
        if (canAbort==true) then
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { 
                    type=params.upgradeName,
                    lvl=params.upgradeLvl
                },
                isModal = true
            }
            overlayOpen=1
            tapSound()
            composer.showOverlay( "abortTaskScene", sceneOverlayOptions)
        end
    end
end

local function noTask()

    rowTitle = display.newText( "No Task Running", display.contentWidth/2, myData.task_rect.y+fontSize(120), native.systemFont, fontSize(80) )
    rowTitle.anchorX=0.5
    rowTitle.anchorY=0
    rowTitle.x =  display.contentWidth/2
    rowTitle.y = myData.task_rect.y+fontSize(120)
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

local function addOverclockListener( event )

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

        if (t.STATUS == "OK") then
            myData.boosters.text=t.oc
            if (t.secs) then
                myData.overclock.text="Overclock Active for "..timeText(t.secs)
                myData.overclock.secondsLeft=t.secs
                myData.overclock:setTextColor( 0, 0.7, 0 )
            end
            if (myData.instruction) then
                myData.instruction.text="\nDaily Overclocks Used: "..t.new_daily_oc.."/15\n\nSelect an Overclock type:\n"
            end
            updateTasks()
        elseif (t.STATUS == "OC_LIMIT_FINISH") then
            local alert = native.showAlert( "EliteHax", "Cannot use this type of overclock, you have already used too much Overclocks today!", { "Close" } )
            ocReceived=true
        elseif (t.STATUS == "OC_LIMIT") then
            local alert = native.showAlert( "EliteHax", "You have already reached you daily Overclocks limit!", { "Close" } )
            ocReceived=true
        end
    end
end

function addFinishOverclock( event )
    local i = event.index
    if ( i == 1 ) then
        ocReceived=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."addFinishOverclock.php", "POST", addOverclockListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

function addHourOverclock( event )
    local i = event.index
    if ( i == 1 ) then
        ocReceived=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."addHourOverclock.php", "POST", addOverclockListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

function addOverclock( event )
    local i = event.index
    if ( i == 1 ) then
        ocReceived=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."addOverclock.php", "POST", addOverclockListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function addOverclockConfirm( event )
    if ((loaded==true) and (tonumber(myData.boosters.text) > 0)) then
        --local alert = native.showAlert( "EliteHax", "Do you want to use 1 Overclock?", { "Yes", "No"}, addOverclock )
        overclockOverlay=true
        local sceneOverlayOptions = 
        {
            time = 0,
            effect = "crossFade",
            params = { 
                daily_oc=daily_overclock
            },
            isModal = true
        }
        tapSound()
        composer.showOverlay( "overclockScene", sceneOverlayOptions) 
    end
end

local function taskNetworkListener( event )
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
        myData.taskTableView:deleteAllRows()

        if (t.tasks[1] == nil) then
            noTask()
        end

        myData.playerTextTask.text=t.user
        if (string.len(t.user)>15) then myData.playerTextTask.size = fontSize(42) end
        myData.moneyTextTask.text = format_thousand(t.money)

        myData.taskTableView:deleteAllRows()
        local taskn = 0
        for i in pairs( t.tasks ) do
            taskn=taskn+1
            task1text="Time Remaining: "
            secondsLeft = t.tasks[i].secs
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            myData.taskTableView:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = fontSize(170),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        text1=upgrades[t.tasks[i].type].name.." LVL "..t.tasks[i].lvl,
                        color=color,
                        text2="Time Remaining: "..timeText(secondsLeft),
                        img=upgrades[t.tasks[i].type].img,
                        upgradeName=t.tasks[i].type,
                        upgradeLvl=t.tasks[i].lvl,
                        timer=secondsLeft
                    }
                }
            )    
        end
        if (taskn>0) then
            --Local Notification
            if ((t.oc_secs>1) and (secondsLeft>t.oc_secs)) then
                secondsLeft=t.oc_secs+(secondsLeft-t.oc_secs)*2
            end
            --Local Notification
            if (taskNotificationActive==true) then
                if (notificationGlobal) then 
                    notifications.cancelNotification(notificationGlobal) 
                    notificationGlobal=nil
                end
                --notifications.cancelNotification()
                local utcTime = os.date( "!*t", os.time() + secondsLeft )
                notificationActive.task=utcTime
                notificationActive.taskTime=os.date(os.time() + secondsLeft)
                loadsave.saveTable( notificationActive, "localNotificationStatus.json" )
                setNewNotifications()
            end
        end
        --------------------
        myData.taskOverview.text=taskn.."/"..t.max_tasks.." Tasks Running"
        myData.boosters.text=t.overclock
        if (t.oc_secs<1) then
            myData.overclock.text="No Active Overclock"
            myData.overclock:setTextColor(0.7,0,0)
        else
            myData.overclock.text="Overclock Active for "..timeText(t.oc_secs)
            myData.overclock.secondsLeft=t.oc_secs
            myData.overclock:setTextColor(0,0.7,0)
        end

        daily_overclock=t.daily_overclock

        if (countDownTimer) then
            timer.cancel(countDownTimer)
        end

        countDownTimer = timer.performWithDelay( 1000, updateTimer, 10000000 )
   end
   loaded=true
   ocReceived=true
end

updateTimer = function()
    if (loaded==true) then
        local taskTableViewRows = myData.taskTableView._view._rows
        for i,row in ipairs( taskTableViewRows ) do
            local currentRow = myData.taskTableView._view._rows[i]
            secondsLeft = currentRow.params.timer
            if ( currentRow._view ) then
                if (secondsLeft >= 1) then
                    secondsLeft = secondsLeft - 1
                    currentRow._view.rowTimer.text=task1text..timeText(secondsLeft)
                    currentRow.params.timer = secondsLeft
                else
                    currentRow._view.rowTimer.text="Finished"
                end
            else
                if (secondsLeft >= 1) then
                    secondsLeft = secondsLeft - 1
                    currentRow.params.timer = secondsLeft
                end
            end
        end
        if (myData.overclock.text~="No Active Overclock") then
            secondsLeft = myData.overclock.secondsLeft
            if (secondsLeft >= 1) then
                secondsLeft=secondsLeft-1
                myData.overclock.text="Overclock Active for "..timeText(secondsLeft)
                myData.overclock.secondsLeft=secondsLeft
            else
                myData.overclock.text="No Active Overclock"
                myData.overclock:setTextColor( 0.7, 0, 0 )
                timer.performWithDelay( 30, updateTasks, 2 )
            end
        end
    end
end

updateTasks = function()
    overlayOpen=0
    loaded=false
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."gettask.php", "POST", taskNetworkListener, params )
end

function goBackTasks(event)
    if (loaded==true) then
        backSound()
        if (overlayOpen==1) then
            overlayOpen=0
            composer.hideOverlay( "fade", 100 )
        elseif (overclockOverlay==true) then
            overclockOverlay=0
            composer.hideOverlay( "fade", 100 )
        else
            if (countDownTimer) then
                timer.cancel(countDownTimer)
            end
            composer.removeScene( "taskScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 100})
        end
    end
end

local function goBack (event)
    if (event.phase == "ended") and (loaded==true) then
        if (countDownTimer) then
            timer.cancel(countDownTimer)
        end
        backSound()
        composer.removeScene( "taskScene" )
        composer.gotoScene("homeScene", {effect = "fade", time = 100})
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function taskScene:create(event)
    loaded=false

    group = self.view

    loginInfo = localToken()
    overlayOpen=0
    overclockOverlay=false
    ocReceived=true

    iconSize=200

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextTask = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextTask.anchorX = 0
    myData.moneyTextTask.anchorY = 0.5
    myData.moneyTextTask:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextTask = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextTask.anchorX = 0.5
    myData.playerTextTask.anchorY = 0.5
    myData.playerTextTask:setFillColor( 0.9,0.9,0.9 )

    myData.task_rect = display.newImageRect( "img/task_rect.png",display.contentWidth-20, fontSize(1660))
    myData.task_rect.anchorX = 0.5
    myData.task_rect.anchorY = 0
    myData.task_rect.x, myData.task_rect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height+10
    changeImgColor(myData.task_rect)

    -- Create the widget
    myData.taskTableView = widget.newTableView(
        {
            left = 20,
            top = myData.top_background.y+myData.top_background.height+fontSize(100),
            height = myData.task_rect.height-fontSize(310),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.taskTableView.anchorX=0.5
    myData.taskTableView.x=display.contentWidth/2

    myData.overclockBtn = display.newImageRect( "img/overclock.png",fontSize(80), fontSize(80))
    myData.overclockBtn.anchorX = 0
    myData.overclockBtn.anchorY = 1
    myData.overclockBtn.x, myData.overclockBtn.y = myData.task_rect.x-myData.task_rect.width/2+35,myData.task_rect.y+myData.task_rect.height-fontSize(25)

    myData.overclock = display.newText( "", display.contentWidth/2, myData.task_rect.y+fontSize(120), native.systemFont, fontSize(60) )
    myData.overclock.anchorX=0.5
    myData.overclock.anchorY=1
    myData.overclock.x =  display.contentWidth/2
    myData.overclock.y = myData.task_rect.y+myData.task_rect.height-fontSize(125)

    myData.boosters = display.newText( "", display.contentWidth/2, myData.task_rect.y+fontSize(120), native.systemFont, fontSize(65) )
    myData.boosters.anchorX=0
    myData.boosters.anchorY=1
    myData.boosters.x =  myData.task_rect.x-myData.task_rect.width/2+130
    myData.boosters.y = myData.task_rect.y+myData.task_rect.height-fontSize(30)
    myData.boosters:setTextColor( 0.9, 0.9, 0.9 )

    myData.taskOverview = display.newText( "", display.contentWidth/2, myData.task_rect.y+fontSize(120), native.systemFont, fontSize(60) )
    myData.taskOverview.anchorX=1
    myData.taskOverview.anchorY=1
    myData.taskOverview.x =  myData.task_rect.x+myData.task_rect.width/2-50
    myData.taskOverview.y = myData.task_rect.y+myData.task_rect.height-fontSize(30)
    myData.taskOverview:setTextColor( 0.9, 0.9, 0.9 )

    myData.backButton = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15) + topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
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
    group:insert(myData.backButton)
    group:insert(myData.task_rect)
    group:insert(myData.taskTableView)
    group:insert(myData.top_background)
    group:insert(myData.playerTextTask)
    group:insert(myData.moneyTextTask)
    group:insert(myData.boosters)
    group:insert(myData.overclock)
    group:insert(myData.overclockBtn)
    group:insert(myData.taskOverview)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
    myData.overclockBtn:addEventListener("tap",addOverclockConfirm)

end

-- Home Show
function taskScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "taskNewTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutTask ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "taskTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."gettask.php", "POST", taskNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
taskScene:addEventListener( "create", taskScene )
taskScene:addEventListener( "show", taskScene )
---------------------------------------------------------------------------------

return taskScene