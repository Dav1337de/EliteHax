local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local upgrades = require("upgradeName")
local missionScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local getHackScenario

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local function missionAfterCollectEventListener( event )
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

        myData.missionTableView:deleteAllRows()

        if (sorting=='timeD') then
            t.available_missions=quicksortD(t.available_missions,'duration')
        elseif (sorting=='timeA') then
            t.available_missions=quicksortA(t.available_missions,'duration')
        elseif (sorting=='moneyA') then
            t.available_missions=quicksortA(t.available_missions,'reward')
        elseif (sorting=='moneyD') then
            t.available_missions=quicksortD(t.available_missions,'reward')
        elseif (sorting=='xpA') then
            t.available_missions=quicksortA(t.available_missions,'xp')
        elseif (sorting=='xpD') then
            t.available_missions=quicksortD(t.available_missions,'xp')
        elseif (sorting=='statusA') then
            t.available_missions=quicksortA(t.available_missions,'running')
        elseif (sorting=='statusD') then
            t.available_missions=quicksortD(t.available_missions,'running')
        end

        for i in pairs( t.available_missions ) do

        local mc_lvl = t.available_missions[i].mc_lvl
        local upgrade_cost = 0
        if (mc_lvl == 1) then upgrade_cost = 5000
        elseif (mc_lvl == 2) then upgrade_cost = 100000
        elseif (mc_lvl == 3) then upgrade_cost = 1000000
        elseif (mc_lvl == 4) then upgrade_cost = 10000000
        elseif (mc_lvl == 5) then upgrade_cost=0 end

        myData.moneyTextM.text = format_thousand(t.available_missions[i].money)
        if (string.len(t.available_missions[i].user)>15) then myData.playerTextM.size = fontSize(42) end
        myData.playerTextM.text = t.available_missions[i].user
        myData.missionCenterTxt.text = "Level "..t.available_missions[i].mc_lvl
        myData.missionCenterTxt.lvl = mc_lvl
        local percent=(t.available_missions[i].mc_upgrade_lvl/100)
        myData.mc_progress:setProgress( percent )
        myData.missionCenterUpgradeTxt.text = t.available_missions[i].mc_upgrade_lvl.."%"
        myData.upgradeMCButton:setLabel("Upgrade ($"..format_thousand(upgrade_cost)..")")
        if (mc_lvl == 5) then 
            myData.missionCenterUpgradeTxt.text = ""
            myData.upgradeMCButton.collectActive=true
            myData.upgradeMCButton:setLabel("Collect All") 
        end

        local tempText = display.newText("Name\n"..t.available_missions[i].mission_desc.."\nReward\nDuration", 0, 0, myData.missionTableView.width-40, 0, native.systemFont, fontSize(50))
        local tempRowHeight = fontSize(160) + tempText.height
        if (t.available_missions[i].running == 1) then tempRowHeight=tempRowHeight+fontSize(100) end
        tempText : removeSelf()
        tempText = nil

        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        local color=tableColor1
        if (i%2==0) then color=tableColor2 end

        myData.missionTableView:insertRow(
        {
            isCategory = isCategory,
            rowHeight = tempRowHeight,
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                id=t.available_missions[i].mission_id,
                color=color,
                running=t.available_missions[i].running,
                minutes=t.available_missions[i].duration,
                reward=t.available_missions[i].reward,
                xp=t.available_missions[i].xp,
                name=t.available_missions[i].mission_name,   
                desc=t.available_missions[i].mission_desc,  
                time_finish=t.available_missions[i].time_finish,
                difficult=t.available_missions[i].difficult                           
            }  -- Include custom data in the row
        })    
        end
        if (missionCountDownTimer) then
            timer.cancel(missionCountDownTimer)
        end
        missionCountDownTimer = timer.performWithDelay( 1000, updateMissionTimer, 10000000 )
        collected=0
   end
end

local function renewAfterCollectEventListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getMissions.php", "POST", missionAfterCollectEventListener, params )
        end    
   end
end

local function rewardCollected()
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."renewMissions.php", "POST", renewAfterCollectEventListener, params )
end

local function collectMissionEventListener( event )
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
            rewardSound()
            myData.moneyTextM.text = format_thousand(t.money)
            --local alert = native.showAlert( "EliteHax", "Collected $"..format_thousand(t.collected), { "Close" }, rewardCollected )
            if (t.new_lvl>0) then
                local sceneOverlayOptions = 
                {
                    time = 0,
                    effect = "crossFade",
                    params = { },
                    isModal = true
                }
                composer.showOverlay( "newLvlScene", sceneOverlayOptions) 
            end
            rewardCollected()
        end 
   end
end

local function collectAllMissionEventListener( event )
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

        if (t.STATUS == "NC") then
            --
        elseif (t.STATUS == "OK") then
            rewardSound()
            myData.moneyTextM.text = format_thousand(t.money)
            --local alert = native.showAlert( "EliteHax", "Collected $"..format_thousand(t.collected), { "Close" }, rewardCollected )
            if (t.new_lvl>0) then
                local sceneOverlayOptions = 
                {
                    time = 0,
                    effect = "crossFade",
                    params = { },
                    isModal = true
                }
                composer.showOverlay( "newLvlScene", sceneOverlayOptions) 
            end
            rewardCollected()
        end 
   end
end

local function collectMission(event)
    if ((event.phase == "ended") and (collected==0)) then
        collected=1
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&mission_id="..event.target.mission_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."collectMission.php", "POST", collectMissionEventListener, params )
    end
end

local function updateMissionTimer()
    local tableViewRows = myData.missionTableView._view._rows
    for i,row in ipairs( tableViewRows ) do
        if ( myData.missionTableView:getRowAtIndex(i) ) then
            local row = myData.missionTableView:getRowAtIndex(i)
            local params = row.params
            if (myData.missionTableView:getRowAtIndex(i).rowTimeLeft ~= nil) then
                local secondsLeft = myData.missionTableView:getRowAtIndex(i).params.time_finish
                secondsLeft = secondsLeft - 1
                if (secondsLeft >0) then
                    myData.missionTableView:getRowAtIndex(i).rowTimeLeft.text="Time Left: "..timeText(secondsLeft)
                    myData.missionTableView:getRowAtIndex(i).params.time_finish = secondsLeft
                    local percent=1-((secondsLeft/60)/myData.missionTableView:getRowAtIndex(i).params.minutes)
                    myData.missionTableView:getRowAtIndex(i).progressView:setProgress( percent )
                else
                    row.collectButton = widget.newButton(
                    {
                        left = row.width-fontSize(450)-20,
                        top = row.rowIncome.y+row.rowIncome.height-fontSize(60)*2,
                        width = fontSize(400),
                        height = display.actualContentHeight/15-5,
                        defaultFile = buttonColor400,
                       -- overFile = "buttonOver.png",
                        fontSize = fontSize(60),
                        label = "Collect",
                        labelColor = tableColor1,
                        onEvent = collectMission
                    })
                    row.collectButton.mission_id=row.params.id
                    row.collectButton:addEventListener("tap",collectMission)
                    row:insert(row.collectButton) 
                end
            end
        else
            local row = myData.missionTableView._view._rows[i]
            local params = row.params
            local secondsLeft = params.time_finish
            secondsLeft = secondsLeft - 1
            if (secondsLeft >0) then
                myData.missionTableView._view._rows[i].params.time_finish = secondsLeft
            end
        end
    end
end

local function updateMissionEventListener( event )
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

        myData.missionTableView:deleteAllRows()

        if (sorting=='timeD') then
            t.available_missions=quicksortD(t.available_missions,'duration')
        elseif (sorting=='timeA') then
            t.available_missions=quicksortA(t.available_missions,'duration')
        elseif (sorting=='moneyA') then
            t.available_missions=quicksortA(t.available_missions,'reward')
        elseif (sorting=='moneyD') then
            t.available_missions=quicksortD(t.available_missions,'reward')
        elseif (sorting=='xpA') then
            t.available_missions=quicksortA(t.available_missions,'xp')
        elseif (sorting=='xpD') then
            t.available_missions=quicksortD(t.available_missions,'xp')
        elseif (sorting=='statusA') then
            t.available_missions=quicksortA(t.available_missions,'running')
        elseif (sorting=='statusD') then
            t.available_missions=quicksortD(t.available_missions,'running')
        end

        for i in pairs( t.available_missions ) do

        myData.moneyTextM.text = format_thousand(t.available_missions[i].money)
        if (string.len(t.available_missions[i].user)>15) then myData.playerTextM.size = fontSize(42) end
        myData.playerTextM.text = t.available_missions[i].user

        local tempText = display.newText("Name\n"..t.available_missions[i].mission_desc.."\nReward\nDuration", 0, 0, myData.missionTableView.width-40, 0, native.systemFont, fontSize(50))
        local tempRowHeight = 160 + tempText.height
        if (t.available_missions[i].running == 1) then tempRowHeight=tempRowHeight+120 end
        tempText : removeSelf()
        tempText = nil

        rowColor = {
          default = { 0, 0, 0, 0 }
        }
        lineColor = { 
          default = { 1, 0, 0 }
        }
        local color=tableColor1
        if (i%2==0) then color=tableColor2 end

        myData.missionTableView:insertRow(
        {
            isCategory = isCategory,
            rowHeight = tempRowHeight,
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                id=t.available_missions[i].mission_id,
                color=color,
                running=t.available_missions[i].running,
                minutes=t.available_missions[i].duration,
                reward=t.available_missions[i].reward,
                xp=t.available_missions[i].xp,
                name=t.available_missions[i].mission_name,   
                desc=t.available_missions[i].mission_desc,  
                time_finish=t.available_missions[i].time_finish,
                difficult=t.available_missions[i].difficult                           
            }
        })    
        end
        if (missionCountDownTimer) then
            timer.cancel(missionCountDownTimer)
        end
        missionCountDownTimer = timer.performWithDelay( 1000, updateMissionTimer, 10000000 )
   end
end

local function missionEventListener( event )
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

        myData.missionTableView:deleteAllRows()

        if (sorting=='timeD') then
            t.available_missions=quicksortD(t.available_missions,'duration')
        elseif (sorting=='timeA') then
            t.available_missions=quicksortA(t.available_missions,'duration')
        elseif (sorting=='moneyA') then
            t.available_missions=quicksortA(t.available_missions,'reward')
        elseif (sorting=='moneyD') then
            t.available_missions=quicksortD(t.available_missions,'reward')
        elseif (sorting=='xpA') then
            t.available_missions=quicksortA(t.available_missions,'xp')
        elseif (sorting=='xpD') then
            t.available_missions=quicksortD(t.available_missions,'xp')
        elseif (sorting=='statusA') then
            t.available_missions=quicksortA(t.available_missions,'running')
        elseif (sorting=='statusD') then
            t.available_missions=quicksortD(t.available_missions,'running')
        end

        for i in pairs( t.available_missions ) do

            local mc_lvl = t.available_missions[i].mc_lvl
            local upgrade_cost = 0
            if (mc_lvl == 1) then upgrade_cost = 5000
            elseif (mc_lvl == 2) then upgrade_cost = 100000
            elseif (mc_lvl == 3) then upgrade_cost = 1000000
            elseif (mc_lvl == 4) then upgrade_cost = 10000000
            elseif (mc_lvl == 5) then upgrade_cost=0 end

            myData.moneyTextM.text = format_thousand(t.available_missions[i].money)
            if (string.len(t.available_missions[i].user)>15) then myData.playerTextM.size = fontSize(42) end
            myData.playerTextM.text = t.available_missions[i].user
            myData.missionCenterTxt.text = "Level "..t.available_missions[i].mc_lvl
            myData.missionCenterTxt.lvl = mc_lvl
            local percent=(t.available_missions[i].mc_upgrade_lvl/100)
            myData.mc_progress:setProgress( percent )
            myData.missionCenterUpgradeTxt.text = t.available_missions[i].mc_upgrade_lvl.."%"
            myData.upgradeMCButton:setLabel("Upgrade ($"..format_thousand(upgrade_cost)..")")
            if (mc_lvl == 5) then 
                myData.missionCenterUpgradeTxt.text = ""
                myData.upgradeMCButton.collectActive=true
                myData.upgradeMCButton:setLabel("Collect All") 
            end

            local tempText = display.newText("Name\n"..t.available_missions[i].mission_desc.."\nReward\nDuration", 0, 0, myData.missionTableView.width-40, 0, native.systemFont, fontSize(50))
            local tempRowHeight = 160 + tempText.height
            if (t.available_missions[i].running == 1) then tempRowHeight=tempRowHeight+120 end
            tempText : removeSelf()
            tempText = nil

            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            myData.missionTableView:insertRow(
            {
                isCategory = isCategory,
                rowHeight = tempRowHeight,
                rowColor = rowColor,
                lineColor = lineColor,
                params = { 
                    id=t.available_missions[i].mission_id,
                    color=color,
                    running=t.available_missions[i].running,
                    minutes=t.available_missions[i].duration,
                    reward=t.available_missions[i].reward,
                    xp=t.available_missions[i].xp,
                    name=t.available_missions[i].mission_name,   
                    desc=t.available_missions[i].mission_desc,  
                    time_finish=t.available_missions[i].time_finish,
                    difficult=t.available_missions[i].difficult                           
                }  -- Include custom data in the row
            })    
        end
        if (missionCountDownTimer) then
            timer.cancel(missionCountDownTimer)
        end
        loaded=true
        missionCountDownTimer = timer.performWithDelay( 1000, updateMissionTimer, 10000000 )
   end
end

local function renewMissionsEventListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getMissions.php", "POST", missionEventListener, params )
        end    
   end
end

local function startMissionEventListener( event )
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
  
        if (t.STATUS == "MAX_CC") then
            local alert = native.showAlert( "EliteHax", "Max concurrent missions reached", { "Close" } )
        end

        if (t.STATUS == "OK") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getMissions.php", "POST", missionEventListener, params )
        end    
   end
end

local function startMission(event)
    if (event.phase == "ended") then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&mission_id="..event.target.mission_id
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."startMission.php", "POST", startMissionEventListener, params )
    end
end

local function onRowRender( event )

    local row = event.row
    local params = event.row.params
    local difficult=""
    if (params.difficult==1) then difficult="Very Easy"
    elseif (params.difficult==2) then difficult="Easy"
    elseif (params.difficult==3) then difficult="Medium"
    elseif (params.difficult==4) then difficult="High"
    elseif (params.difficult==5) then difficult="Extreme" end

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(20), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,10
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])

    row.rowLvls = display.newText( row, params.name.." ("..difficult..")", 0, 0, native.systemFont, fontSize(47) )
    row.rowLvls.anchorX = 0
    row.rowLvls.anchorY = 0
    row.rowLvls.x = 40
    row.rowLvls.y = 20
    row.rowLvls:setTextColor( 0, 0, 0 )
    row.rowIncome = display.newText( row, params.desc.."\n\nReward: $"..format_thousand(params.reward).."\nXP: "..params.xp.."\nDuration: "..timeText(params.minutes*60), 0, 0, row.width-40, 0, native.systemFont, fontSize(48) )
    row.rowIncome.anchorX=0
    row.rowIncome.anchorY=0
    row.rowIncome.x =  40
    row.rowIncome.y = row.rowLvls.y+row.rowLvls.height+15
    row.rowIncome:setTextColor( 0, 0, 0 )

    if (params.running == 0) then
        row.startButton = widget.newButton(
        {
            left = row.width-fontSize(400)-20,
            top = row.rowIncome.y+row.rowIncome.height-fontSize(80)*2,
            width = fontSize(400),
            height = display.actualContentHeight/15-5,
            defaultFile = buttonColor400,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(60),
            label = "Start",
            labelColor = tableColor1,
            onEvent = startMission
        })
        row.startButton.mission_id=params.id
        row.startButton:addEventListener("tap",startMission)
        row:insert(row.startButton)
    else
        local options = {
            width = 64,
            height = 64,
            numFrames = 6,
            sheetContentWidth = 384,
            sheetContentHeight = 64
        }
        local progressSheet = graphics.newImageSheet( progressColor, options )
        row.progressView = widget.newProgressView(
            {
                sheet = progressSheet,
                fillOuterLeftFrame = 1,
                fillOuterMiddleFrame = 2,
                fillOuterRightFrame = 3,
                fillOuterWidth = 50,
                fillOuterHeight = 50,
                fillInnerLeftFrame = 4,
                fillInnerMiddleFrame = 5,
                fillInnerRightFrame = 6,
                fillWidth = 50,
                fillHeight = 50,
                left = 40,
                top = row.rowIncome.y+row.rowIncome.height+20,
                width = row.width-80,
                isAnimated = true
            }
        )
        local percent=1-((params.time_finish/60)/params.minutes)
        row.progressView:setProgress( percent )
        row:insert(row.progressView)
        if (timeText(params.time_finish) == "Finished") then
            row.collectButton = widget.newButton(
            {
                left = row.width-fontSize(400)-20,
                top = row.rowIncome.y+row.rowIncome.height-fontSize(80)*2,
                width = fontSize(400),
                height = display.actualContentHeight/15-5,
                defaultFile = buttonColor400,
               -- overFile = "buttonOver.png",
                fontSize = fontSize(60),
                label = "Collect",
                labelColor = tableColor1,
                onEvent = collectMission
            })
            row.collectButton.mission_id=params.id
            row.collectButton:addEventListener("tap",collectMission)
            row:insert(row.collectButton)
        else
            row.rowTimeLeft = display.newText( row, "Time Left: "..timeText(params.time_finish), 0, 0, native.systemFont, fontSize(50) )
            row.rowTimeLeft.anchorX=1        
            row.rowTimeLeft.anchorY=1
            row.rowTimeLeft.x = row.width-row.rowTimeLeft.width-40
            row.rowTimeLeft.y = row.rowIncome.y+row.rowIncome.height
            row.rowTimeLeft:setTextColor( 0, 0, 0 )
        end

    end

    row.line = display.newLine( row, 0, row.contentHeight, row.width, row.contentHeight )
    row.line.anchorY = 1
    row.line:setStrokeColor( 0, 0, 0, 1 )
    row.line.strokeWidth = 16
end

local function upgradeMCEventListener( event )
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

        upgradeMCClicked = 0
  
        if (t.STATUS == "NO_MONEY") then
            local alert = native.showAlert( "EliteHax", "Oops.. It seems you don't have enough money...", { "Ok" } )
        end

        if (t.STATUS == "OK") then
            myData.moneyTextM.text = format_thousand(t.new_money)
            local percent=(t.mc_upgrade_lvl/100)
            myData.mc_progress:setProgress( percent )
            myData.missionCenterUpgradeTxt.text = t.mc_upgrade_lvl.."%"
        end 

        if (t.STATUS == "OK_NEW_LVL") then
            local alert = native.showAlert( "EliteHax", "Congratulations!\nNew Mission Center level reached!", { "Ok" } )
            local mc_lvl = t.new_lvl
            local upgrade_cost = 0
            if (mc_lvl == 1) then upgrade_cost = 5000
            elseif (mc_lvl == 2) then upgrade_cost = 100000
            elseif (mc_lvl == 3) then upgrade_cost = 1000000
            elseif (mc_lvl == 4) then upgrade_cost = 10000000
            elseif (mc_lvl == 5) then upgrade_cost=0 end

            myData.moneyTextM.text = format_thousand(t.new_money)
            myData.missionCenterTxt.text = "Mission Center Lvl "..mc_lvl
            myData.missionCenterTxt.lvl = mc_lvl
            local percent=(t.mc_upgrade_lvl/100)
            myData.mc_progress:setProgress( percent )
            myData.missionCenterUpgradeTxt.text = t.mc_upgrade_lvl.."%"
            myData.upgradeMCButton:setLabel("Upgrade ($"..format_thousand(upgrade_cost)..")")
            if (mc_lvl == 5) then 
                myData.missionCenterUpgradeTxt.text = ""
                myData.upgradeMCButton.collectActive=true
                myData.upgradeMCButton:setLabel("Collect All") 
            end
        end    
   end
end

local function upgradeMC(event)
    if ((upgradeMCClicked == 0) and (event.phase == "ended")) then
        if (myData.missionCenterTxt.lvl < 5) then
            upgradeMCClicked = 1
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."upgradeMC.php", "POST", upgradeMCEventListener, params )
        elseif ((myData.upgradeMCButton.collectActive==true) and (collected==0)) then
            collected=1
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."collectAllMission.php", "POST", collectAllMissionEventListener, params )
        end
    end
end

local function sortMission(event)
    sorting=event.target.next
    if (event.target.next=="xpA") then
        event.target.next="xpD"
    elseif (event.target.next=="xpD") then
        event.target.next="xpA"
    elseif (event.target.next=="moneyD") then
        event.target.next="moneyA"
    elseif (event.target.next=="moneyA") then
        event.target.next="moneyD"
    elseif (event.target.next=="timeA") then
        event.target.next="timeD"
    elseif (event.target.next=="timeD") then
        event.target.next="timeA"
    elseif (event.target.next=="statusA") then
        event.target.next="statusD"
    elseif (event.target.next=="statusD") then
        event.target.next="statusA"
    end
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getMissions.php", "POST", missionEventListener, params )
    myData.missionSortM._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    myData.missionSortD._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    myData.missionSortX._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    myData.missionSortS._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    event.target._view._label._labelColor=tableColor3
end

local function hackScenarioRenewListener( event )
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

        if (t.status=="OK") then
            getHackScenario()
        end
    end
end

local function renewHackScenario(event)
    if ((event.phase=="ended") and (loaded==true)) then
        loaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."renewHackScenario.php", "POST", hackScenarioRenewListener, params )
    end
end

local function updateHackMissionTimer(event)
    local secondsLeft = myData.missionTimerT.secondsLeft
    secondsLeft = secondsLeft - 1
    if (secondsLeft >0) then
        myData.missionTimerT.text="Time Left\n\n"..timeText(secondsLeft)
        myData.missionTimerT.secondsLeft = secondsLeft
        local percent=1-(secondsLeft/172800)
        myData.hackMissionProgressView:setProgress( percent )
    else
        myData.missionTimerT.text="Time Left\n\nMission Expired"
        myData.goToHackButton.alpha=0
        myData.renewHackScenarioButton.alpha=1
    end
end

local function hackScenarioOverviewListener( event )
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

        if (t.status=="RENEW") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."renewHackScenario.php", "POST", hackScenarioRenewListener, params )
        else
            myData.moneyTextM.text = format_thousand(t.money) 
            
            local status="Not Completed"
            if (t.completed==1) then status="Completed" end
            myData.missionOverviewT.text="Objective:\n\n"..t.desc..".\n\nStatus: "..status.."\n\nReputation Won: "..t.rep

            local missionSecondsLeft=t["end"]
            local percent=1-(missionSecondsLeft/172800)
            myData.hackMissionProgressView:setProgress( percent )
            myData.missionTimerT.text="Time Left\n\n"..timeText(missionSecondsLeft)
            myData.missionTimerT.secondsLeft=missionSecondsLeft

            if (missionSecondsLeft>0) then
                myData.renewHackScenarioButton.alpha=0
                myData.goToHackButton.alpha=1
            else
                myData.renewHackScenarioButton.alpha=1
                myData.goToHackButton.alpha=0
            end

            if (hackMissionCountDownTimer) then
                timer.cancel(hackMissionCountDownTimer)
            end
            hackMissionCountDownTimer = timer.performWithDelay( 1000, updateHackMissionTimer, 10000000 )
        end

        loaded=true

    end
end

getHackScenario = function(event)
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getHackScenarioOverview.php", "POST", hackScenarioOverviewListener, params )
end

local function handleTabBarEvent( event )
    if (loaded==true) then
        if (event.target.id == "time") then
            sbGroup.alpha=0
            tbGroup.alpha=1
            loaded=false
            tapSound()
            tabBarFocus = "time"
            myData.missionTableView:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getMissions.php", "POST", missionEventListener, params )
        elseif (event.target.id == "skill") then
            tbGroup.alpha=0
            sbGroup.alpha=1
            loaded=false
            tapSound()
            tabBarFocus = "skill"
            getHackScenario()
        end
    end
end

local function goToHack(event)
    if ((event.phase=="ended") and (loaded==true)) then
        tapSound()
        if (hackMissionCountDownTimer) then
            timer.cancel(hackMissionCountDownTimer)
        end
        composer.removeScene( "missionScene" )
        composer.gotoScene("hackMapScene", {effect = "fade", time = 100})
    end
end

function goBackMission(event)
    if (tutOverlay==false) then
        backSound()
        if (hackMissionCountDownTimer) then
            timer.cancel(hackMissionCountDownTimer)
        end
        composer.removeScene( "missionScene" )
        composer.gotoScene("homeScene", {effect = "fade", time = 300})
    end
end

local goBack = function(event)
    backSound()
    if (hackMissionCountDownTimer) then
        timer.cancel(hackMissionCountDownTimer)
    end
    composer.removeScene( "missionScene" )
    composer.gotoScene("homeScene", {effect = "fade", time = 300})
end
---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function missionScene:create(event)
    group = self.view

    loginInfo = localToken()

    iconSize=200

    upgradeMCClicked = 0
    collected = 0
    sorting="statusD"
    loaded=true

    --TOP
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextM = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextM.anchorX = 0
    myData.moneyTextM.anchorY = 0.5
    myData.moneyTextM:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextM = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextM.anchorX = 0.5
    myData.playerTextM.anchorY = 0.5
    myData.playerTextM:setFillColor( 0.9,0.9,0.9 )

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
            label = "Time-Based",
            id = "time",
            selected = true,
            size = fontSize(50),
            labelYOffset = -25,
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent
        },
        {
            defaultFrame = 5,
            overFrame = 6,
            label = "Hack-Based",
            id = "skill",
            size = fontSize(50),
            labelYOffset = -25,
            labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
            onPress = handleTabBarEvent
        }
    }
    view = "time" 

    myData.missionTabBar = widget.newTabBar(
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
            tabSelectedFrameWidth = 120,
            tabSelectedFrameHeight = 120,
            buttons = tabButtons
        }
    )
    myData.missionTabBar.anchorX=0.5
    myData.missionTabBar.anchorY=0
    myData.missionTabBar.x,myData.missionTabBar.y=display.contentWidth/2,myData.top_background.y+myData.top_background.height

    -- Beta badge
    myData.betaImg = display.newImageRect( "img/beta.png", 120, fontSize(90))
    myData.betaImg.anchorX = 0.5
    myData.betaImg.anchorY = 0
    myData.betaImg.x, myData.betaImg.y = display.contentWidth/4*3+95,myData.top_background.y+myData.top_background.height+5

    --Time Based Items
    myData.missions_rect = display.newImageRect( "img/leaderboard_rect.png",display.contentWidth-20, fontSize(1100))
    myData.missions_rect.anchorX = 0.5
    myData.missions_rect.anchorY = 0
    myData.missions_rect.x, myData.missions_rect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height+10+fontSize(110)
    changeImgColor(myData.missions_rect)

    myData.missionSortM = widget.newButton(
    {
        left = 40,
        top = myData.missions_rect.y+fontSize(10),
        width = 250,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Money",
        labelColor = tableColor1,
        onRelease = sortMission
    })
    myData.missionSortM.next="moneyD"

    myData.missionSortD = widget.newButton(
    {
        left = myData.missionSortM.x+myData.missionSortM.width/2,
        top = myData.missionSortM.y-myData.missionSortM.height/2,
        width = 250,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Time",
        labelColor = tableColor1,
        onRelease = sortMission
    })
    myData.missionSortD.next="timeA"

    myData.missionSortX = widget.newButton(
    {
        left = myData.missionSortD.x+myData.missionSortD.width/2,
        top = myData.missionSortM.y-myData.missionSortM.height/2,
        width = 250,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "XP",
        labelColor = tableColor1,
        onRelease = sortMission
    })
    myData.missionSortX.next="xpD"

    myData.missionSortS = widget.newButton(
    {
        left = myData.missionSortX.x+myData.missionSortX.width/2,
        top = myData.missionSortM.y-myData.missionSortM.height/2,
        width = 250,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Status",
        labelColor = tableColor3,
        onRelease = sortMission
    })
    myData.missionSortS.next="statusD"

    -- Create the widget
    myData.missionTableView = widget.newTableView(
        {
            left = 20,
            top = myData.missionSortM.y+myData.missionSortM.height/2,
            height = myData.missions_rect.height-fontSize(105),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            --onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.missionTableView.anchorX=0.5
    myData.missionTableView.x=display.contentWidth/2

    --Mission Center
    myData.missionCenterRect = display.newImageRect( "img/missions_mc.png",display.contentWidth-20, fontSize(480))
    myData.missionCenterRect.anchorX = 0.5
    myData.missionCenterRect.anchorY = 0
    myData.missionCenterRect.x, myData.missionCenterRect.y = display.contentWidth/2, myData.missionTableView.y+myData.missionTableView.height/2+fontSize(20)
    changeImgColor(myData.missionCenterRect)

    myData.missionCenterTxt = display.newText("Level ",display.contentWidth/2,myData.missionCenterRect.y+fontSize(120),native.systemFont, fontSize(60))
    myData.missionCenterTxt.anchorX = 0.5
    myData.missionCenterTxt.anchorY = 0
    myData.missionCenterTxt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    local options = {
            width = 64,
            height = 64,
            numFrames = 6,
            sheetContentWidth = 384,
            sheetContentHeight = 64
        }
    local progressSheet = graphics.newImageSheet( progressColor, options )
    myData.mc_progress = widget.newProgressView(
        {
            sheet = progressSheet,
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillOuterWidth = 64,
            fillOuterHeight = 64,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            fillWidth = 64,
            fillHeight = 64,
            left = 50,
            top = myData.missionCenterTxt.y+myData.missionCenterTxt.height,
            width = myData.missionCenterRect.width-80,
            isAnimated = true
        }
    )
    myData.missionCenterUpgradeTxt = display.newText("",display.contentWidth/2,myData.mc_progress.y+30,native.systemFont, fontSize(58))
    myData.missionCenterUpgradeTxt.anchorX = 0.5
    myData.missionCenterUpgradeTxt.anchorY = 0
    myData.missionCenterUpgradeTxt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.upgradeMCButton = widget.newButton(
    {
        left = 60,
        top = myData.missionCenterUpgradeTxt.y+myData.missionCenterUpgradeTxt.height,
        width = display.contentWidth - 120,
        height = display.actualContentHeight/15-15,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "",
        labelColor = tableColor1,
        onEvent = upgradeMC
    })
    myData.upgradeMCButton.collectActive=false

    --Skill-Based Items
    myData.sbmRect = display.newImageRect( "img/leaderboard_rect.png",display.contentWidth-20,fontSize(1580) )
    myData.sbmRect.anchorX = 0.5
    myData.sbmRect.anchorY = 0
    myData.sbmRect:translate(display.contentWidth/2,myData.missionTabBar.y+myData.missionTabBar.height/2+fontSize(44))
    changeImgColor(myData.sbmRect)

    local options = 
    {
        text = "\n\n\n\n\n\n\n\n\n\n",
        x = myData.sbmRect.x-myData.sbmRect.width/2+40,
        y = myData.sbmRect.y+fontSize(100),
        width = myData.sbmRect.width-70,
        font = native.systemFont,   
        fontSize = fontSize(56),
        align = "left"
    }

    myData.missionOverviewT = display.newText(options)
    myData.missionOverviewT.anchorX = 0
    myData.missionOverviewT.anchorY = 0

    local options = {
        width = 64,
        height = 64,
        numFrames = 6,
        sheetContentWidth = 384,
        sheetContentHeight = 64
    }
    local progressSheet = graphics.newImageSheet( progressColor, options )
    myData.hackMissionProgressView = widget.newProgressView(
        {
            sheet = progressSheet,
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillOuterWidth = 50,
            fillOuterHeight = 50,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            fillWidth = 50,
            fillHeight = 50,
            left = myData.sbmRect.x-myData.sbmRect.width/2+40,
            top = myData.missionOverviewT.y+myData.missionOverviewT.height+fontSize(250),
            width = myData.sbmRect.width-80,
            height = fontSize(100),
            isAnimated = true
        }
    )

    local options = 
    {
        text = "",
        x = myData.sbmRect.x,
        y = myData.hackMissionProgressView.y,
        width = myData.sbmRect.width-40,
        font = native.systemFont,   
        fontSize = fontSize(58),
        align = "center"
    }

    myData.missionTimerT = display.newText(options)
    myData.missionTimerT.secondsLeft=0

    myData.goToHackButton = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.hackMissionProgressView.y+myData.hackMissionProgressView.height+fontSize(200),
        width = 800,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = 80,
        label = "Go to Mission!",
        labelColor = tableColor1,
        onEvent = goToHack
    })
    myData.goToHackButton.anchorX=0.5
    myData.goToHackButton.x=display.contentWidth/2
    myData.goToHackButton.alpha=0

    myData.renewHackScenarioButton = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.hackMissionProgressView.y+myData.hackMissionProgressView.height+fontSize(200),
        width = 800,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = 80,
        label = "Get a new mission!",
        labelColor = tableColor1,
        onEvent = renewHackScenario
    })
    myData.renewHackScenarioButton.anchorX=0.5
    myData.renewHackScenarioButton.x=display.contentWidth/2
    myData.renewHackScenarioButton.alpha=0

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
    group:insert(myData.moneyTextM)
    group:insert(myData.playerTextM)
    group:insert(myData.missionTabBar)
    group:insert(myData.betaImg)
    group:insert(myData.backButton)

    --Time-Base items
    tbGroup=display.newGroup()
    tbGroup:insert(myData.missions_rect)
    tbGroup:insert(myData.missionSortM)
    tbGroup:insert(myData.missionSortX)
    tbGroup:insert(myData.missionSortD)
    tbGroup:insert(myData.missionSortS)
    tbGroup:insert(myData.missionTableView)
    tbGroup:insert(myData.missionCenterRect)
    tbGroup:insert(myData.missionCenterTxt)
    tbGroup:insert(myData.mc_progress)
    tbGroup:insert(myData.missionCenterUpgradeTxt)
    tbGroup:insert(myData.upgradeMCButton)

    --Skill-Base items
    sbGroup=display.newGroup()
    sbGroup:insert(myData.sbmRect)
    sbGroup:insert(myData.missionOverviewT)
    sbGroup:insert(myData.missionTimerT)
    sbGroup:insert(myData.hackMissionProgressView)
    sbGroup:insert(myData.goToHackButton)
    sbGroup:insert(myData.renewHackScenarioButton)
    sbGroup.alpha=0

    group:insert(tbGroup)
    group:insert(sbGroup)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
    myData.upgradeMCButton:addEventListener("tap",upgradeMC)
    myData.goToHackButton:addEventListener("tap",goToHack)
end

-- Home Show
function missionScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "missionTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutMission ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "missionTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."renewMissions.php", "POST", renewMissionsEventListener, params )
        network.request( host().."getMissions.php", "POST", missionEventListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
missionScene:addEventListener( "create", missionScene )
missionScene:addEventListener( "show", missionScene )
---------------------------------------------------------------------------------

return missionScene