local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local loadsave = require( "loadsave" )
local terminalScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
function goBackTerminal(event)
    if (tutOverlay == false) then
        if (myData.manualInput) then
            myData.manualInput:removeSelf()
            myData.manualInput=nil
        end
        backSound()
        composer.removeScene( "terminalScene" )
        composer.gotoScene("homeScene", {effect = "fade", time = 0})
    end
end

function goBackScan(event)
    if (scanOverlay == true) then
        if (attackerLine) then
            attackerLine:removeSelf()
            attackerLine = newLine
        end
        backSound()
        scanOverlay=false
        composer.hideOverlay( "fade", 100 )
    end
end

function goBackAddEdit(event)
    if (addTargetOverlay == true) then
        addTargetOverlay=false
        backSound()
        composer.hideOverlay( "fade", 100 )
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

function closeTL( event )
    backSound()
    myData.backButton:setLabel("Back")
    myData.targetsListRect:removeSelf()
    myData.targetsListRect=nil
    myData.closeTLBtn:removeSelf()
    myData.closeTLBtn=nil
    myData.targetsListTable:removeSelf()
    myData.targetsListTable=nil
    myData.addTargetButton:removeSelf()
    myData.addTargetButton=nil
    myData.attacker.alpha=1
    myData.refreshButton.alpha=1
    myData.globalButton.alpha=1
    targetListOverlay=false
end

function goBack (event)
    if (event.phase == "ended") then
        if (targetListOverlay==false) then
            if (myData.manualInput) then
                myData.manualInput:removeSelf()
                myData.manualInput=nil
            end
            backSound()
            composer.removeScene( "terminalScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 300})
        else
            closeTL()
        end
    end
end

local function manualScanListener( event )

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

        if (t.status == "KO") then
            if (typewriterTimer) then 
                timer.cancel(typewriterTimer)
            end
            local sceneOverlayOptions = 
            {
                time = 300,
                effect = "crossFade",
                params = { 
                   manual=true,
                   target="NO"
                },
                isModal = true
            }
            composer.showOverlay( "scanAttackScene", sceneOverlayOptions)           
        else
            if (typewriterTimer) then 
                timer.cancel(typewriterTimer)
            end
            local sceneOverlayOptions = 
            {
                time = 300,
                effect = "crossFade",
                params = { 
                   manual=true,
                   target=t.id
                },
                isModal = true
            }
            composer.showOverlay( "scanAttackScene", sceneOverlayOptions)
        end
        scanOverlay = true
        manualScanRx = true
    end
end

function manualScan( event )
    if (scanOverlay==true) then
        if (attackerLine) then
            attackerLine:removeSelf()
            attackerLine = newLine
        end
        if (typewriterTimer) then 
            timer.cancel(typewriterTimer)
        end
        scanOverlay=false
        composer.hideOverlay( "fade", 0 )
    end
    if ((event.phase == "ended") and (manualScanRx == true) and (addTargetOverlay==false) and (targetListOverlay==false)) then
        if (isIpAddress(myData.manualInput.text)) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&target="..myData.manualInput.text
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."getUuid.php", "POST", manualScanListener, params )
            manualScanRx=false
        end
    end
end

local function detectTarget(x,y)
    if ((x > myData.fw1.x) and (x < myData.fw1.x+myData.fw1.width) and (y>myData.fw1.y) and (y<myData.fw1.y+myData.fw1.height)) then
        targetSound()
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fw1.fill = imageA
        myData.fw1.txtb.alpha=1
        myData.fw1.txt.alpha=1
        myData.fw1.ip.alpha=1
        return "fw1"
    elseif ((x > myData.fw2.x) and (x < myData.fw2.x+myData.fw2.width) and (y>myData.fw2.y) and (y<myData.fw2.y+myData.fw2.height)) then
        targetSound()
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fw2.fill = imageA
        myData.fw2.txtb.alpha=1
        myData.fw2.txt.alpha=1
        myData.fw2.ip.alpha=1
        return "fw2"
    elseif ((x > myData.fw3.x) and (x < myData.fw3.x+myData.fw3.width) and (y>myData.fw3.y) and (y<myData.fw3.y+myData.fw3.height)) then
        targetSound()
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fw3.fill = imageA
        myData.fw3.txtb.alpha=1
        myData.fw3.txt.alpha=1
        myData.fw3.ip.alpha=1
        return "fw3"
    elseif ((x > myData.fw4.x) and (x < myData.fw4.x+myData.fw4.width) and (y>myData.fw4.y) and (y<myData.fw4.y+myData.fw4.height)) then
        targetSound()
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fw4.fill = imageA
        myData.fw4.txtb.alpha=1
        myData.fw4.txt.alpha=1
        myData.fw4.ip.alpha=1
        return "fw4"
    elseif ((x > myData.fw5.x) and (x < myData.fw5.x+myData.fw5.width) and (y>myData.fw5.y) and (y<myData.fw5.y+myData.fw5.height)) then
        targetSound()
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fw5.fill = imageA
        myData.fw5.txtb.alpha=1
        myData.fw5.txt.alpha=1
        myData.fw5.ip.alpha=1
        return "fw5"
    elseif ((x > myData.fw6.x) and (x < myData.fw6.x+myData.fw6.width) and (y>myData.fw6.y) and (y<myData.fw6.y+myData.fw6.height)) then
        targetSound()
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fw6.fill = imageA
        myData.fw6.txtb.alpha=1
        myData.fw6.txt.alpha=1
        myData.fw6.ip.alpha=1
        return "fw6"
    elseif ((x > myData.fw7.x) and (x < myData.fw7.x+myData.fw7.width) and (y>myData.fw7.y) and (y<myData.fw7.y+myData.fw7.height)) then
        targetSound()
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fw7.fill = imageA
        myData.fw7.txtb.alpha=1
        myData.fw7.txt.alpha=1
        myData.fw7.ip.alpha=1
        return "fw7"
    elseif ((x > myData.fw8.x) and (x < myData.fw8.x+myData.fw8.width) and (y>myData.fw8.y) and (y<myData.fw8.y+myData.fw8.height)) then
        targetSound()
        local imageA = { type="image", filename="img/firewall.png" }
        myData.fw8.fill = imageA
        myData.fw8.txtb.alpha=1
        myData.fw8.txt.alpha=1
        myData.fw8.ip.alpha=1
        return "fw8"
    else
        targetAudio=true
        local imageA = { type="image", filename="img/terminal_unknown.png" }
        for i=1,8 do
            local cur = "fw"..i
            if (myData[cur].scan ~= true) then
                myData[cur].fill = imageA
                myData[cur].txtb.alpha=0
                myData[cur].txt.alpha=0
                myData[cur].ip.alpha=0
                changeImgColor(myData[cur])
            end
        end
        return "None"
    end
end

local function onAttackerTouch( event )
    if ( event.phase == "began" ) then
        display.getCurrentStage():setFocus( myData.attacker )
        myData.attacker.isFocus = true
    elseif ( event.phase == "moved" ) then
        if (attackerLine) then
            attackerLine:removeSelf()
            attackerLine = nil
        end
        local dX = myData.attacker.x+(event.x - myData.attacker.x) 
        local dY = myData.attacker.y+(event.y - myData.attacker.y+20) 
        attackerLine = display.newLine( dX,dY, myData.attacker.x, myData.attacker.y+20 )
        attackerLine:setStrokeColor( 0.7, 0, 0, 1 )
        attackerLine.strokeWidth = 10
        group:insert(attackerLine)
        group:insert(myData.attacker)
        detectTarget(dX,dY)
    elseif ( event.phase == "ended" ) then
        display.getCurrentStage():setFocus( nil )
        myData.attacker.isFocus = nil
        local dX = myData.attacker.x+(event.x - myData.attacker.x) 
        local dY = myData.attacker.y+(event.y - myData.attacker.y+20) 
        local visualTarget = detectTarget(dX,dY)
        if (visualTarget ~= "None") then
            myData[visualTarget].scan=true
            myData.manualInput.text=myData[visualTarget].ip.text
            local sceneOverlayOptions = 
            {
                time = 300,
                effect = "crossFade",
                params = { 
                    manual=false,
                    target=myData[visualTarget].id,
                    fw=visualTarget,
                    attacked=myData[visualTarget].atk
                },
                isModal = true
            }
            composer.showOverlay( "scanAttackScene", sceneOverlayOptions)
            scanOverlay=true
        else
            if (attackerLine) then
            attackerLine:removeSelf()
            attackerLine = newLine
            end
        end      
    end
    return true
end

local function terminalNetworkListener( event )

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

        for i in pairs( t.targets ) do
            if (i < 9) then
                local cur = "fw"..i
                myData[cur].id = t.targets[i].id
                myData[cur].txt.text=t.targets[i].firewall
                local digit = string.len(tostring(myData[cur].txt.text))
                myData[cur].txtb.width=70+(30*digit)
                if (t.targets[i].attacked == "Y") then 
                    myData[cur].atk=true
                    myData[cur].txt:setFillColor( 0.84,0.15,0.15 )
                    myData[cur].txtb:setStrokeColor( 0.84, 0.15, 0.15 )
                    myData[cur].ip:setFillColor( 0.84,0.15,0.15 )
                end
                myData[cur].ip.text=t.targets[i].ip
            end
        end

        refreshTargetsRx = true
        manualScanRx = true

        --Money
        myData.moneyTextTerminal.text = format_thousand(t.money)

        --Player
        if (string.len(t.user)>15) then myData.playerTextTerminal.size = fontSize(42) end
        myData.playerTextTerminal.text = t.user

    end
end

local function refreshTargets(event)
if ((event.phase == "ended") and (refreshTargetsRx == true)) then
    tapSound()
    myData.manualInput.text=""
    myData.fw1.x, myData.fw1.y = horizontalDiff+myData.targetsRect.x-myData.targetsRect.width/2+40+math.random(100),myData.targetsRect.y+fontSize(170)+fontSize(math.random(130))
    myData.fw2.x, myData.fw2.y = horizontalDiff*2+myData.targetsRect.x-myData.targetsRect.width/2+iconSize+140+math.random(120),myData.targetsRect.y+fontSize(170)+fontSize(math.random(170))
    myData.fw3.x, myData.fw3.y = horizontalDiff*3+myData.targetsRect.x-myData.targetsRect.width/2+iconSize*2+260+math.random(100),myData.targetsRect.y+fontSize(170)+fontSize(math.random(130))
    myData.fw4.x, myData.fw4.y = horizontalDiff+myData.targetsRect.x-myData.targetsRect.width/2+40+math.random(100),myData.targetsRect.y+fontSize(310)+iconSize+fontSize(math.random(170))
    myData.fw5.x, myData.fw5.y = horizontalDiff*3+myData.targetsRect.x-myData.targetsRect.width/2+iconSize*2+300+math.random(100),myData.targetsRect.y+fontSize(300)+iconSize+fontSize(math.random(170))
    myData.fw6.x, myData.fw6.y = horizontalDiff+myData.targetsRect.x-myData.targetsRect.width/2+40+math.random(100),myData.targetsRect.y+fontSize(300)+iconSize*2+fontSize(180)+fontSize(math.random(110))
    myData.fw7.x, myData.fw7.y = horizontalDiff*2+myData.targetsRect.x-myData.targetsRect.width/2+iconSize+140+math.random(120),myData.targetsRect.y+fontSize(300)+iconSize*2+fontSize(120)+fontSize(math.random(170))
    myData.fw8.x, myData.fw8.y = horizontalDiff*3+myData.targetsRect.x-myData.targetsRect.width/2+iconSize*2+260+math.random(100),myData.targetsRect.y+fontSize(300)+iconSize*2+fontSize(180)+fontSize(math.random(110))
    local imageA = { type="image", filename="img/terminal_unknown.png" }
    for i=1,8 do
        local cur = "fw"..i
        myData[cur].fill = imageA
        myData[cur].scan = false
        myData[cur].atk = false
        myData[cur].txtb.alpha=0
        myData[cur].txt.alpha=0
        myData[cur].ip.alpha=0
        myData[cur].txtb:setStrokeColor(0,0.7,0)
        myData[cur].txt:setFillColor(0,0.7,0)
        myData[cur].ip:setFillColor(textColor1[1],textColor1[2],textColor1[3])
        myData[cur].txtb.x,myData[cur].txtb.y = myData[cur].x+myData[cur].width/2,myData[cur].y
        myData[cur].txt.x,myData[cur].txt.y = myData[cur].x+myData[cur].width/2,myData[cur].txtb.y-10
        myData[cur].ip.x,myData[cur].ip.y = myData[cur].x+myData[cur].width/2,myData[cur].y+myData[cur].height+10
        changeImgColor(myData[cur])
    end
    local isOn = "false"
    if (myData.globalButton.isOn == true) then isOn="true" end
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token).."&global="..isOn.."&data="..string.urlEncode(generateNonce())
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getTargets.php", "POST", terminalNetworkListener, params )
    refreshTargetsRx = false
end
end

local function scanFromList( event )
    myData.manualInput.text=event.target.ip
    if (isIpAddress(event.target.ip)) then
        closeTL()
        manualScanRx=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&target="..event.target.ip
        print("Scanning: "..myData.manualInput.text)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getUuid.php", "POST", manualScanListener, params )
    end
end

local function targetListListener( event )

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

        for i in pairs( t.targets ) do
            local color = tableColor1
            if (math.mod(i, 2) == 0) then
                rowColor = tableColor2
            end
            rowColor = {
                default = { 0, 0, 0, 0 }
            }
            lineColor = { 
                default = { 1, 1, 0.17 }
            }
            myData.targetsListTable:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = fontSize(230),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        name=t.targets[i].name,
                        color=color,
                        ip=t.targets[i].ip,
                        desc=t.targets[i].desc
                    }
                }
            )
        end
    end
end

function refreshTargetList(event)
    myData.targetsListTable:deleteAllRows()
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getTargetList.php", "POST", targetListListener, params )
end

local function removeFromTargetListListener( event )

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
            refreshTargetList()            
        end
    end
end

local function editTargetList(event)
    local sceneOverlayOptions = 
    {
        time = 100,
        effect = "crossFade",
        params = { 
            name=event.target.name,
            ip=event.target.ip,
            desc=event.target.desc
        },
        isModal = true
    }
    tapSound()
    composer.showOverlay( "editTargetListScene", sceneOverlayOptions)
    addTargetOverlay=true
end

local function removeFromTargetList( ip )
    return function(event)
        local i = event.index
        if ( i == 1 ) then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&ip="..ip
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."removeFromTargetList.php", "POST", removeFromTargetListListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function removeFromTargetListAlert( event )
    tapSound()
    local alert = native.showAlert( "EliteHax", "Do you want to remove this target from the list?", { "Yes", "No"}, removeFromTargetList(event.target.ip) )
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

    row.rowTitle = display.newText( row, params.name.."\n"..params.ip, 0, 0, native.systemFont, fontSize(52) )
    row.rowTitle.anchorX=0
    row.rowTitle.anchorY=0
    row.rowTitle.x =  40
    row.rowTitle.y = fontSize(15)
    row.rowTitle:setTextColor( 0, 0, 0 )

    row.rowDesc = display.newText( row, params.desc.."\n", 0, 0, row.width-40, 0, native.systemFont, fontSize(46) )
    row.rowDesc.anchorX = 0
    row.rowDesc.anchorY = 0
    row.rowDesc.x =  40
    row.rowDesc.y = row.rowTitle.y+row.rowTitle.height+3
    row.rowDesc:setTextColor( 0, 0, 0 )

    row.editListBtn = display.newImageRect( "img/edit.png",iconSize/2.2,iconSize/2.2 )
    row.editListBtn.name=params.name
    row.editListBtn.ip=params.ip
    row.editListBtn.desc=params.desc.."\n"
    row.editListBtn.anchorX = 0
    row.editListBtn.anchorY = 0.5
    row.editListBtn.x, row.editListBtn.y = row.x+row.width-(iconSize/2.2)*3-60, row.height/2-20
    changeImgColor(row.editListBtn)
    row.editListBtn:addEventListener("tap",editTargetList)

    row.removeBtn = display.newImageRect( "img/delete.png",iconSize/2.2,iconSize/2.2 )
    row.removeBtn.ip = params.ip
    row.removeBtn.anchorX = 0
    row.removeBtn.anchorY = 0.5
    row.removeBtn.x, row.removeBtn.y = row.editListBtn.x+row.editListBtn.width+20, row.height/2-20
    row.removeBtn:addEventListener("tap",removeFromTargetListAlert)

    row.listScanBtn = display.newImageRect( "img/scan.png",iconSize/2.2,iconSize/2.2 )
    row.listScanBtn.ip = params.ip
    row.listScanBtn.anchorX = 0
    row.listScanBtn.anchorY = 0.5
    row.listScanBtn.x, row.listScanBtn.y = row.removeBtn.x+row.removeBtn.width+20, row.height/2-20
    changeImgColor(row.listScanBtn)
    row.listScanBtn:addEventListener("tap",scanFromList)

    row:insert(row.editListBtn)
    row:insert(row.removeBtn)
    row:insert(row.listScanBtn)
end

local function addTargetBtn(event)
    if (event.phase == "ended") then
        local sceneOverlayOptions = 
        {
            time = 300,
            effect = "crossFade",
            params = { 
            },
            isModal = true
        }
        tapSound()
        composer.showOverlay( "addTargetListScene", sceneOverlayOptions)
        addTargetOverlay=true
    end
end

function targetListOpen(event)
    if (scanOverlay==true) then
        if (attackerLine) then
            attackerLine:removeSelf()
            attackerLine = newLine
        end
        if (typewriterTimer) then 
            timer.cancel(typewriterTimer)
        end
        scanOverlay=false
        composer.hideOverlay( "fade", 400 )
    end
    if (event.phase == "ended") and (targetListOverlay==false) then
        tapSound()
        targetListOverlay=true
        myData.backButton:setLabel("Close")
        myData.attacker.alpha=0
        myData.refreshButton.alpha=0
        myData.globalButton.alpha=0
        myData.targetsListRect = display.newImageRect( "img/terminal_targets_list.png",display.contentWidth-20,fontSize(1300) )
        myData.targetsListRect.anchorX = 0.5
        myData.targetsListRect.anchorY = 0
        myData.targetsListRect.x, myData.targetsListRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
        changeImgColor(myData.targetsListRect)

        -- Close Button
        myData.closeTLBtn = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
        myData.closeTLBtn.anchorX = 0
        myData.closeTLBtn.anchorY = 0
        myData.closeTLBtn.x, myData.closeTLBtn.y = myData.targetsListRect.x+myData.targetsListRect.width/2-iconSize/2.5-40, myData.targetsListRect.y+fontSize(80)
        changeImgColor(myData.closeTLBtn)
        myData.closeTLBtn:addEventListener("tap",closeTL)

        --Target Table
        myData.targetsListTable = widget.newTableView(
            {
                left = myData.targetsListRect.x,
                top = myData.closeTLBtn.y+myData.closeTLBtn.height+10,
                height = fontSize(960),
                width = myData.targetsListRect.width-60,
                onRowRender = onRowRender,
                --onRowTouch = onRowTouch,
                listener = scrollListener,
                hideBackground = true
            }
        )
        myData.targetsListTable.anchorX=0.5
        myData.targetsListTable.x=myData.targetsListRect.x

        myData.addTargetButton = widget.newButton(
        {
            left = 20,
            top = myData.targetsListTable.y+myData.targetsListTable.height/2+20,
            width = display.contentWidth - 80,
            height = display.actualContentHeight/15-5,
            defaultFile = buttonColor1080,
           -- overFile = "buttonOver.png",
            fontSize = fontSize(80),
            label = "Add Target",
            labelColor = tableColor1,
            onEvent = addTargetBtn
        })
        myData.addTargetButton.anchorX=0.5
        myData.addTargetButton.x=myData.targetsListRect.x
        myData.addTargetButton:addEventListener("tap",addTargetBtn)

        group:insert(myData.targetsListRect)
        group:insert(myData.closeTLBtn)
        group:insert(myData.targetsListTable)
        group:insert(myData.addTargetButton)

        --Get Target List
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getTargetList.php", "POST", targetListListener, params )
    end
end

local function onSwitchPress(event)
    if (event.target.isOn==true) then
        tapSound()
    else
        backSound()
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function terminalScene:create(event)
    group = self.view

    loginInfo = localToken()
    scanOverlay=false
    targetListOverlay=false
    addTargetOverlay=false

    iconSize=fontSize(220)
    horizontalDiff=(200-iconSize)/2

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextTerminal = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextTerminal.anchorX = 0
    myData.moneyTextTerminal.anchorY = 0.5
    myData.moneyTextTerminal:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextTerminal = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextTerminal.anchorX = 0.5
    myData.playerTextTerminal.anchorY = 0.5
    myData.playerTextTerminal:setFillColor( 0.9,0.9,0.9 )

    myData.targetsRect = display.newImageRect( "img/terminal_targets.png",display.contentWidth-20,fontSize(1300) )
    myData.targetsRect.anchorX = 0.5
    myData.targetsRect.anchorY = 0
    myData.targetsRect.x, myData.targetsRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.targetsRect)

    -- Global Checkbox
    myData.globalT = display.newText("Global",50,myData.targetsRect.y+fontSize(80),native.systemFont, fontSize(65))
    myData.globalT.anchorX = 0
    myData.globalT.anchorY = 0
    myData.globalT:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    local options = {
    width = 200,
    height = 200,
    numFrames = 2,
    sheetContentWidth = 400,
    sheetContentHeight = 200
    }
    local checkboxSheet = graphics.newImageSheet( checkboxColor, options )
    myData.globalButton = widget.newSwitch(
        {
            left = myData.globalT.x+200,
            top = myData.globalT.y+5,
            width = fontSize(80),
            height = fontSize(80),
            style = "checkbox",
            id = "Checkbox",
            onPress = onSwitchPress,
            sheet = checkboxSheet,
            frameOff = 1,
            frameOn = 2
        }
    )

    -- Refresh
    myData.refreshButton = widget.newButton(
    {
        left = display.contentWidth-150,
        top = myData.targetsRect.y+fontSize(80),
        width = fontSize(80),
        height = fontSize(80),
        defaultFile = refreshColor,
       -- overFile = "buttonOver.png",
        onEvent = refreshTargets
    })   

    myData.attacker = display.newImageRect( "img/attacker.png",iconSize*1.3,iconSize*1.3 )
    myData.attacker.id="attacker"
    myData.attacker.anchorX = 0.5
    myData.attacker.anchorY = 0.5
    myData.attacker.x, myData.attacker.y = display.contentWidth/2,myData.targetsRect.y+myData.targetsRect.height/2+fontSize(80)

    myData.fw1 = display.newImageRect( "img/terminal_unknown.png",iconSize,iconSize )
    myData.fw1.id="fw1"
    myData.fw1.anchorX = 0
    myData.fw1.anchorY = 0
    myData.fw1.x, myData.fw1.y = horizontalDiff+myData.targetsRect.x-myData.targetsRect.width/2+40+math.random(100),myData.targetsRect.y+fontSize(170)+fontSize(math.random(130))
    changeImgColor(myData.fw1)
    myData.fw1.txtb = display.newRoundedRect(myData.fw1.x+myData.fw1.width/2,myData.fw1.y,70,70,12)
    myData.fw1.txtb.anchorX=0.5
    myData.fw1.txtb.anchorY=0
    myData.fw1.txtb.strokeWidth = 5
    myData.fw1.txtb:setFillColor( 0,0,0 )
    myData.fw1.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw1.txtb.alpha=0
    myData.fw1.txt = display.newText("",myData.fw1.x+myData.fw1.width/2,myData.fw1.txtb.y-10 ,native.systemFont, fontSize(72))
    myData.fw1.txt:setFillColor( 0,0.7,0 )
    myData.fw1.txt.anchorY=0
    myData.fw1.txt.alpha=0
    myData.fw1.ip = display.newText("",myData.fw1.x+myData.fw1.width/2,myData.fw1.y+myData.fw1.height+10,native.systemFont, fontSize(32))
    myData.fw1.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fw1.ip.alpha=0

    myData.fw2 = display.newImageRect( "img/terminal_unknown.png",iconSize,iconSize )
    myData.fw2.id="fw2"
    myData.fw2.anchorX = 0
    myData.fw2.anchorY = 0
    myData.fw2.x, myData.fw2.y = horizontalDiff*2+myData.targetsRect.x-myData.targetsRect.width/2+iconSize+140+math.random(120),myData.targetsRect.y+fontSize(170)+fontSize(math.random(170))
    changeImgColor(myData.fw2)
    myData.fw2.txtb = display.newRoundedRect(myData.fw2.x+myData.fw2.width/2,myData.fw2.y,70,70,12)
    myData.fw2.txtb.anchorX=0.5
    myData.fw2.txtb.anchorY=0
    myData.fw2.txtb.strokeWidth = 5
    myData.fw2.txtb:setFillColor( 0,0,0 )
    myData.fw2.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw2.txtb.alpha=0
    myData.fw2.txt = display.newText("",myData.fw2.x+myData.fw2.width/2,myData.fw2.txtb.y-10 ,native.systemFont, fontSize(72))
    myData.fw2.txt:setFillColor( 0,0.7,0 )
    myData.fw2.txt.anchorY=0
    myData.fw2.txt.alpha=0
    myData.fw2.ip = display.newText("",myData.fw2.x+myData.fw2.width/2,myData.fw2.y+myData.fw2.height+10 ,native.systemFont, fontSize(32))
    myData.fw2.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fw2.ip.alpha=0

    myData.fw3 = display.newImageRect( "img/terminal_unknown.png",iconSize,iconSize )
    myData.fw3.id="fw3"
    myData.fw3.anchorX = 0
    myData.fw3.anchorY = 0
    myData.fw3.x, myData.fw3.y = horizontalDiff*3+myData.targetsRect.x-myData.targetsRect.width/2+iconSize*2+260+math.random(100),myData.targetsRect.y+fontSize(170)+fontSize(math.random(130))
    changeImgColor(myData.fw3)
    myData.fw3.txtb = display.newRoundedRect(myData.fw3.x+myData.fw3.width/2,myData.fw3.y,70,70,12)
    myData.fw3.txtb.anchorX=0.5
    myData.fw3.txtb.anchorY=0
    myData.fw3.txtb.strokeWidth = 5
    myData.fw3.txtb:setFillColor( 0,0,0 )
    myData.fw3.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw3.txtb.alpha=0
    myData.fw3.txt = display.newText("",myData.fw3.x+myData.fw3.width/2,myData.fw3.txtb.y-10 ,native.systemFont, fontSize(72))
    myData.fw3.txt:setFillColor( 0,0.7,0 )
    myData.fw3.txt.anchorY=0
    myData.fw3.txt.alpha=0
    myData.fw3.ip = display.newText("",myData.fw3.x+myData.fw3.width/2,myData.fw3.y+myData.fw3.height+10 ,native.systemFont, fontSize(32))
    myData.fw3.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fw3.ip.alpha=0

    myData.fw4 = display.newImageRect( "img/terminal_unknown.png",iconSize,iconSize )
    myData.fw4.id="fw4"
    myData.fw4.anchorX = 0
    myData.fw4.anchorY = 0
    myData.fw4.x, myData.fw4.y = horizontalDiff+myData.targetsRect.x-myData.targetsRect.width/2+40+math.random(100),myData.targetsRect.y+fontSize(310)+iconSize+fontSize(math.random(170))
    changeImgColor(myData.fw4)
    myData.fw4.txtb = display.newRoundedRect(myData.fw4.x+myData.fw4.width/2,myData.fw4.y,70,70,12)
    myData.fw4.txtb.anchorX=0.5
    myData.fw4.txtb.anchorY=0
    myData.fw4.txtb.strokeWidth = 5
    myData.fw4.txtb:setFillColor( 0,0,0 )
    myData.fw4.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw4.txtb.alpha=0
    myData.fw4.txt = display.newText("",myData.fw4.x+myData.fw4.width/2,myData.fw4.txtb.y-10 ,native.systemFont, fontSize(72))
    myData.fw4.txt:setFillColor( 0,0.7,0 )
    myData.fw4.txt.anchorY=0
    myData.fw4.txt.alpha=0
    myData.fw4.ip = display.newText("",myData.fw4.x+myData.fw4.width/2,myData.fw4.y+myData.fw4.height+10 ,native.systemFont, fontSize(32))
    myData.fw4.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fw4.ip.alpha=0

    myData.fw5 = display.newImageRect( "img/terminal_unknown.png",iconSize,iconSize )
    myData.fw5.id="fw5"
    myData.fw5.anchorX = 0
    myData.fw5.anchorY = 0
    myData.fw5.x, myData.fw5.y = horizontalDiff*3+myData.targetsRect.x-myData.targetsRect.width/2+iconSize*2+300+math.random(100),myData.targetsRect.y+fontSize(310)+iconSize+fontSize(math.random(170))
    changeImgColor(myData.fw5)
    myData.fw5.txtb = display.newRoundedRect(myData.fw5.x+myData.fw5.width/2,myData.fw5.y,70,70,12)
    myData.fw5.txtb.anchorX=0.5
    myData.fw5.txtb.anchorY=0
    myData.fw5.txtb.strokeWidth = 5
    myData.fw5.txtb:setFillColor( 0,0,0 )
    myData.fw5.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw5.txtb.alpha=0
    myData.fw5.txt = display.newText("",myData.fw5.x+myData.fw5.width/2,myData.fw5.txtb.y-10 ,native.systemFont, fontSize(72))
    myData.fw5.txt:setFillColor( 0,0.7,0 )
    myData.fw5.txt.anchorY=0
    myData.fw5.txt.alpha=0
    myData.fw5.ip = display.newText("",myData.fw5.x+myData.fw5.width/2,myData.fw5.y+myData.fw5.height+10 ,native.systemFont, fontSize(32))
    myData.fw5.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fw5.ip.alpha=0

    myData.fw6 = display.newImageRect( "img/terminal_unknown.png",iconSize,iconSize )
    myData.fw6.id="fw6"
    myData.fw6.anchorX = 0
    myData.fw6.anchorY = 0
    myData.fw6.x, myData.fw6.y = horizontalDiff+myData.targetsRect.x-myData.targetsRect.width/2+40+math.random(100),myData.targetsRect.y+fontSize(310)+iconSize*2+fontSize(180)+fontSize(math.random(80))
    changeImgColor(myData.fw6)
    myData.fw6.txtb = display.newRoundedRect(myData.fw6.x+myData.fw6.width/2,myData.fw6.y,70,70,12)
    myData.fw6.txtb.anchorX=0.5
    myData.fw6.txtb.anchorY=0
    myData.fw6.txtb.strokeWidth = 5
    myData.fw6.txtb:setFillColor( 0,0,0 )
    myData.fw6.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw6.txtb.alpha=0
    myData.fw6.txt = display.newText("",myData.fw6.x+myData.fw6.width/2,myData.fw6.txtb.y-10 ,native.systemFont, fontSize(72))
    myData.fw6.txt:setFillColor( 0,0.7,0 )
    myData.fw6.txt.anchorY=0
    myData.fw6.txt.alpha=0
    myData.fw6.ip = display.newText("",myData.fw6.x+myData.fw6.width/2,myData.fw6.y+myData.fw6.height+10 ,native.systemFont, fontSize(32))
    myData.fw6.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fw6.ip.alpha=0

    myData.fw7 = display.newImageRect( "img/terminal_unknown.png",iconSize,iconSize )
    myData.fw7.id="fw7"
    myData.fw7.anchorX = 0
    myData.fw7.anchorY = 0
    myData.fw7.x, myData.fw7.y = horizontalDiff*2+myData.targetsRect.x-myData.targetsRect.width/2+iconSize+140+math.random(120),myData.targetsRect.y+fontSize(310)+iconSize*2+fontSize(120)+fontSize(math.random(140))
    changeImgColor(myData.fw7)
    myData.fw7.txtb = display.newRoundedRect(myData.fw7.x+myData.fw7.width/2,myData.fw7.y,70,70,12)
    myData.fw7.txtb.anchorX=0.5
    myData.fw7.txtb.anchorY=0
    myData.fw7.txtb.strokeWidth = 5
    myData.fw7.txtb:setFillColor( 0,0,0 )
    myData.fw7.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw7.txtb.alpha=0
    myData.fw7.txt = display.newText("",myData.fw7.x+myData.fw7.width/2,myData.fw7.txtb.y-10 ,native.systemFont, fontSize(72))
    myData.fw7.txt:setFillColor( 0,0.7,0 )
    myData.fw7.txt.anchorY=0
    myData.fw7.txt.alpha=0
    myData.fw7.ip = display.newText("",myData.fw7.x+myData.fw7.width/2,myData.fw7.y+myData.fw7.height+10 ,native.systemFont, fontSize(32))
    myData.fw7.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fw7.ip.alpha=0

    myData.fw8 = display.newImageRect( "img/terminal_unknown.png",iconSize,iconSize )
    myData.fw8.id="fw8"
    myData.fw8.anchorX = 0
    myData.fw8.anchorY = 0
    myData.fw8.x, myData.fw8.y = horizontalDiff*3+myData.targetsRect.x-myData.targetsRect.width/2+iconSize*2+260+math.random(100),myData.targetsRect.y+fontSize(310)+iconSize*2+fontSize(180)+fontSize(math.random(80))
    changeImgColor(myData.fw8)
    myData.fw8.txtb = display.newRoundedRect(myData.fw8.x+myData.fw8.width/2,myData.fw8.y,70,70,12)
    myData.fw8.txtb.anchorX=0.5
    myData.fw8.txtb.anchorY=0
    myData.fw8.txtb.strokeWidth = 5
    myData.fw8.txtb:setFillColor( 0,0,0 )
    myData.fw8.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw8.txtb.alpha=0
    myData.fw8.txt = display.newText("",myData.fw8.x+myData.fw8.width/2,myData.fw8.txtb.y-10,native.systemFont, fontSize(72))
    myData.fw8.txt:setFillColor( 0,0.7,0 )
    myData.fw8.txt.anchorY=0
    myData.fw8.txt.alpha=0
    myData.fw8.ip = display.newText("",myData.fw8.x+myData.fw8.width/2,myData.fw8.y+myData.fw8.height+10 ,native.systemFont, fontSize(32))
    myData.fw8.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fw8.ip.alpha=0

    myData.manualScanRect = display.newImageRect( "img/terminal_manualscan.png",display.contentWidth-20,fontSize(400) )
    myData.manualScanRect.anchorX = 0.5
    myData.manualScanRect.anchorY = 0
    myData.manualScanRect.x, myData.manualScanRect.y = display.contentWidth/2,myData.targetsRect.y+myData.targetsRect.height-10
    changeImgColor(myData.manualScanRect)

    --Manual IP Insert
    myData.manualT = display.newText("IP:",60,myData.manualScanRect.y+fontSize(140),native.systemFont, fontSize(60))
    myData.manualT.anchorX = 0
    myData.manualT.anchorY = 0
    myData.manualT:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    myData.manualInput = native.newTextField( myData.manualT.x+130, myData.manualT.y+myData.manualT.height/2, 540, fontSize(75))
    myData.manualInput.anchorX = 0
    myData.manualInput.anchorY = 0.5
    myData.manualInput.placeholder = "IP Address";
    myData.manualScanButton = widget.newButton(
    {
        left = myData.manualInput.x+myData.manualInput.width+20,
        top = myData.manualInput.y-myData.manualInput.height/2-fontSize(10),
        width = display.contentWidth/4,
        height = fontSize(90),
        defaultFile = buttonColor400,
            -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Scan",
        labelColor = tableColor1,
        onEvent = manualScan
    })     
    myData.manualScanButton.anchorX=0.5

    myData.targetListButton = widget.newButton(
    {
        left = 35,
        top = myData.manualT.y+myData.manualT.height+30,
        width = display.contentWidth - 80,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Target List",
        labelColor = tableColor1,
        onEvent = targetListOpen
    }) 
    myData.targetListButton.anchorX=0.5

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
    group:insert(myData.top_background)
    group:insert(myData.moneyTextTerminal)
    group:insert(myData.playerTextTerminal)
    group:insert(myData.targetsRect)
    group:insert(myData.globalT)
    group:insert(myData.globalButton)
    group:insert(myData.refreshButton)
    group:insert(myData.manualScanRect)
    group:insert(myData.manualT)
    group:insert(myData.manualInput)
    group:insert(myData.manualScanButton)
    group:insert(myData.targetListButton)
    group:insert(myData.attacker)
    group:insert(myData.fw1)
    group:insert(myData.fw2)
    group:insert(myData.fw3)
    group:insert(myData.fw4)
    group:insert(myData.fw5)
    group:insert(myData.fw6)
    group:insert(myData.fw7)
    group:insert(myData.fw8)
    group:insert(myData.fw1.txtb)
    group:insert(myData.fw2.txtb)
    group:insert(myData.fw3.txtb)
    group:insert(myData.fw4.txtb)
    group:insert(myData.fw5.txtb)
    group:insert(myData.fw6.txtb)
    group:insert(myData.fw7.txtb)
    group:insert(myData.fw8.txtb)
    group:insert(myData.fw1.txt)
    group:insert(myData.fw2.txt)
    group:insert(myData.fw3.txt)
    group:insert(myData.fw4.txt)
    group:insert(myData.fw5.txt)
    group:insert(myData.fw6.txt)
    group:insert(myData.fw7.txt)
    group:insert(myData.fw8.txt)
    group:insert(myData.fw1.ip)
    group:insert(myData.fw2.ip)
    group:insert(myData.fw3.ip)
    group:insert(myData.fw4.ip)
    group:insert(myData.fw5.ip)
    group:insert(myData.fw6.ip)
    group:insert(myData.fw7.ip)
    group:insert(myData.fw8.ip)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.attacker:addEventListener( "touch", onAttackerTouch )
    myData.refreshButton:addEventListener("tap",refreshTargets)
    myData.manualScanButton:addEventListener("tap",manualScan)
    myData.backButton:addEventListener("tap",goBack)
end

-- Home Show
function terminalScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "terminalTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutTerminal ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "terminalTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&data="..string.urlEncode(generateNonce())
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getTargets.php", "POST", terminalNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
terminalScene:addEventListener( "create", terminalScene )
terminalScene:addEventListener( "show", terminalScene )
---------------------------------------------------------------------------------

return terminalScene