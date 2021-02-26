local composer = require( "composer" )
local json = require "json"
local myData = require ("mydata")
local hackScanScene = composer.newScene()
local loadsave = require( "loadsave" )
local widget = require( "widget" )
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
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

local function onClose( event )
end

function closePC( event )
    refreshHackScenario()
    scanOverlay=false
    backSound()
    composer.hideOverlay( "fade", 0 )
end

function closePCD( event )
    clearTargets()
    myData.previewPanel.alpha=0
    myData.previewPanelText.alpha=0
    if (attackerLine) then
        attackerLine:removeSelf()
        attackerLine = newLine
    end
    timer.performWithDelay( 100, closePC )
end

local function closePCD( event )
    if (event.phase=="ended") then
        clearTargets()
        myData.previewPanel.alpha=0
        myData.previewPanelText.alpha=0
        if (attackerLine) then
            attackerLine:removeSelf()
            attackerLine = newLine
        end
        timer.performWithDelay( 100, closePC )
    end
end

-- Visual Timer Effect
-- local function rotateMasks(event)
--     rotation=rotation+1
--     if (rotation<180) then
--         myData.fingerprint2.maskRotation=180+rotation
--     elseif (rotation==180) then
--         myData.fingerprint3.alpha=1
--     else
--         myData.fingerprint3.maskRotation=rotation
--     end
-- end

local function hostNetworkListener( event )
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

        if ((t.down==0) and (t.running_activity==0)) then
            if (t.port_scanned==0) then
                local imageA = { type="image", filename="img/port_scan.png" }
                myData.portScan.fill=imageA
                myData.portScan.active=true
                changeImgColor(myData.portScan)
            end
            if (t.fingerprinted==0) then
                local imageA = { type="image", filename="img/fingerprinting.png" }
                myData.fingerprint.fill=imageA
                myData.fingerprint.active=true
                changeImgColor(myData.fingerprint)

                --Animation for action
                -- local maskFingerprint = graphics.newMask( "img/host_semicirclemask1.png" )
                -- local maskFingerprint2 = graphics.newMask( "img/host_semicirclemask2.png" )
                -- myData.fingerprint2:setMask( maskFingerprint )
                -- myData.fingerprint3:setMask( maskFingerprint2 )
                -- myData.fingerprint2.maskRotation=180
                -- myData.fingerprint3.maskRotation=180
                -- myData.fingerprint3.alpha=0

                -- timer.performWithDelay(10,rotateMasks,360)
            end
            if (t.vuln_scanned==0) then
                local imageA = { type="image", filename="img/vulnerability_scan.png" }
                myData.vulnScan.fill=imageA
                myData.vulnScan.active=true
                changeImgColor(myData.vulnScan)
            end
        end

        if (t.running_activity==1) then
            local imageA = { type="image", filename="img/port_scan_d.png" }
            myData.portScan.fill=imageA
            myData.portScan.active=false

            local imageA = { type="image", filename="img/fingerprinting_d.png" }
            myData.fingerprint.fill=imageA
            myData.fingerprint.active=false

            local imageA = { type="image", filename="img/vulnerability_scan_d.png" }
            myData.vulnScan.fill=imageA
            myData.vulnScan.active=false
        end


        for i in pairs(t.services) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            local servDisc=0
            if (t.services[i].service_name~="") then
                servDisc=1
            end

            local rndWebVuln = math.random(10)

            myData.targetPortTable:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = fontSize(140),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        id=t.services[i].id,
                        color=color,
                        port=t.services[i].service_port,
                        servDisc=servDisc,
                        servDesc=t.services[i].service_name,
                        vulnDisc=t.services[i].vulnerability,
                        webVulnDisc=rndWebVuln,
                        runningActivity=t.running_activity
                    } 
                }
            )
        end
        if (t.down==1) then
            myData.hackScanDetails.text="Status: Down"
            myData.attackBtn._view._label:setFillColor(0.5,0.5,0.5,1)
            myData.attackBtn:setFillColor(0.5,0.5,0.5,1)
            myData.attackBtn.active=false
        elseif (t.hacked==1) then
            myData.hackScanDetails.text="Status: Compromised"
        end
        hackScenarioLoaded=true
   end
end

local function goToHack(event)
    if (event.phase=="ended") then
        if ((event.target.active==true) and (hackScenarioLoaded==true)) then
            tapSound()
            --composer.hideOverlay( "fade", 100 )
            composer.removeScene( "hackMapScene" )
            composer.gotoScene("hackScene", {effect = "fade", time = 100, params = { host_id = event.target.id }})
        else
            myData.attackBtn._view._label:setFillColor(0.5,0.5,0.5,1)
        end
    end
end

local function hostVulnScanNetworkListener( event )
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
            local imageA = { type="image", filename="img/vulnerability_scan_d.png" }
            myData.vulnScan.fill=imageA
            myData.vulnScan.active=false
            local imageA = { type="image", filename="img/fingerprinting_d.png" }
            myData.fingerprint.fill=imageA
            myData.fingerprint.active=false
            myData.targetPortTable:deleteAllRows()
            refreshHackScenario()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", hostNetworkListener, params )
        end 
   end
end

local function vulnScan(event)
    if ((myData.vulnScan.active==true) and (hackScenarioLoaded==true)) then
        tapSound()
        hackScenarioLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostVulnScan.php", "POST", hostVulnScanNetworkListener, params )
    end
end

local function hostFingerprintNetworkListener( event )
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
            local imageA = { type="image", filename="img/vulnerability_scan_d.png" }
            myData.vulnScan.fill=imageA
            myData.vulnScan.active=false
            local imageA = { type="image", filename="img/fingerprinting_d.png" }
            myData.fingerprint.fill=imageA
            myData.fingerprint.active=false
            myData.targetPortTable:deleteAllRows()
            refreshHackScenario()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", hostNetworkListener, params )
        end 
   end
end

local function fingerprint(event)
    if ((myData.fingerprint.active==true) and (hackScenarioLoaded==true)) then
        tapSound()
        hackScenarioLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostFingerprint.php", "POST", hostFingerprintNetworkListener, params )
    end
end

local function hostPortScanNetworkListener( event )
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
            local imageA = { type="image", filename="img/port_scan_d.png" }
            myData.portScan.fill=imageA
            myData.portScan.active=false
            myData.targetPortTable:deleteAllRows()
            refreshHackScenario()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", hostNetworkListener, params )
        end 
   end
end

local function portScan(event)
    if ((myData.portScan.active==true) and (hackScenarioLoaded==true)) then
        tapSound()
        hackScenarioLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostPortScan.php", "POST", hostPortScanNetworkListener, params )
    end
end

local function serviceVulnScanNetworkListener( event )
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
            local imageA = { type="image", filename="img/vulnerability_scan_d.png" }
            myData.vulnScan.fill=imageA
            myData.vulnScan.active=false
            myData.targetPortTable:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", hostNetworkListener, params )
        end 
   end
end

local function serviceVulnScan(event)
    if (hackScenarioLoaded==true) then
        tapSound()
        hackScenarioLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&service_id="..event.target.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."serviceVulnScan.php", "POST", serviceVulnScanNetworkListener, params )
    end
end

local function serviceFingerprintNetworkListener( event )
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
           local imageA = { type="image", filename="img/fingerprinting_d.png" }
            myData.fingerprint.fill=imageA
            myData.fingerprint.active=false
            myData.targetPortTable:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", hostNetworkListener, params )
        end 
   end
end

local function serviceFingerprint(event)
    if (hackScenarioLoaded==true) then
        tapSound()
        hackScenarioLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&service_id="..event.target.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."serviceFingerprint.php", "POST", serviceFingerprintNetworkListener, params )
    end
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

    --Port Scan
    row.rowTitle = display.newText( row, params.port, 0, 0, native.systemFont, fontSize(55) )
    row.rowTitle.anchorX=0
    row.rowTitle.anchorY=0
    row.rowTitle.x =  40
    row.rowTitle.y = fontSize(35)
    row.rowTitle:setTextColor( 1, 1, 1 )

    --Fingerprint
    if (params.servDisc==1) then
        row.rowDesc = display.newText( row, params.servDesc, 0, 0, row.width-40, 0, native.systemFont, fontSize(55) )
        row.rowDesc.anchorX = 0.5
        row.rowDesc.anchorY = 0
        row.rowDesc.x =  850
        row.rowDesc.y = row.rowTitle.y
        row.rowDesc:setTextColor( 1, 1, 1 )
    else
        row.rowDesc = display.newImageRect( "img/fingerprinting_d.png",iconSize/2,iconSize/2 )
        row.rowDesc.anchorX = 0.5
        row.rowDesc.anchorY = 0.5
        row.rowDesc.x, row.rowDesc.y = 450, row.height/2
        row.rowDesc.id=params.id
        row:insert(row.rowDesc)
        if (params.runningActivity==0) then
            local imageA = { type="image", filename="img/fingerprinting.png" }
            row.rowDesc.fill=imageA
            changeImgColor(row.rowDesc)
            row.rowDesc:addEventListener("tap",serviceFingerprint)
        end
    end

    --Vulnerability Scan
    row.rowVuln = display.newImageRect( "img/delete.png",iconSize/2.2,iconSize/2.2 )
    row.rowVuln.anchorX = 0
    row.rowVuln.anchorY = 0.5
    row.rowVuln.x, row.rowVuln.y = 650, row.height/2
    row:insert(row.rowVuln)

    if (params.vulnDisc=="I") then
        local imageA = { type="image", filename="img/severity_i.png" }
        row.rowVuln.fill = imageA
    elseif (params.vulnDisc=="L") then
        local imageA = { type="image", filename="img/severity_l.png" }
        row.rowVuln.fill = imageA
    elseif (params.vulnDisc=="M") then
        local imageA = { type="image", filename="img/severity_m.png" }
        row.rowVuln.fill = imageA
    elseif (params.vulnDisc=="H") then
        local imageA = { type="image", filename="img/severity_h.png" }
        row.rowVuln.fill = imageA
    elseif (params.vulnDisc=="C") then
        local imageA = { type="image", filename="img/severity_c.png" }
        row.rowVuln.fill = imageA
    else
        if (params.runningActivity==1) then
            local imageA = { type="image", filename="img/vulnerability_scan_d.png" }
            row.rowVuln.fill = imageA
        else
            local imageA = { type="image", filename="img/vulnerability_scan.png" }
            row.rowVuln.fill = imageA
            changeImgColor(row.rowVuln)
            row.rowVuln.id=params.id
            row.rowVuln:addEventListener("tap",serviceVulnScan)
        end
    end

    if ((params.servDesc=="HTTP") or (params.servDesc=="HTTPS")) then
        -- if (params.webVulnDisc>3) then
        --     row.rowWebVuln = display.newImageRect( "img/webapp_scan.png",iconSize/2.2,iconSize/2.2 )
        --     row.rowWebVuln.anchorX = 0
        --     row.rowWebVuln.anchorY = 0.5
        --     row.rowWebVuln.x, row.rowWebVuln.y = 820, row.height/2
        --     --row.rowWebVuln:addEventListener("tap",scanFromList)
        --     row:insert(row.rowWebVuln)
        -- end

        -- --Web Vulnerability Scan

        -- if (params.webVulnDisc==4) then
        --     changeImgColor(row.rowWebVuln)
        -- elseif (params.webVulnDisc==5) then        
        --     local imageA = { type="image", filename="img/delete.png" }
        --     row.rowWebVuln.fill = imageA
        -- elseif (params.webVulnDisc==6) then        
        --     local imageA = { type="image", filename="img/severity_i.png" }
        --     row.rowWebVuln.fill = imageA
        -- elseif (params.webVulnDisc==7) then        
        --     local imageA = { type="image", filename="img/severity_l.png" }
        --     row.rowWebVuln.fill = imageA
        -- elseif (params.webVulnDisc==8) then        
        --     local imageA = { type="image", filename="img/severity_m.png" }
        --     row.rowWebVuln.fill = imageA
        -- elseif (params.webVulnDisc==9) then        
        --     local imageA = { type="image", filename="img/severity_h.png" }
        --     row.rowWebVuln.fill = imageA
        -- elseif (params.webVulnDisc==10) then        
        --     local imageA = { type="image", filename="img/severity_c.png" }
        --     row.rowWebVuln.fill = imageA
        -- end
    end
end

local function hackScanActivitiesListener( event )
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
            refreshHackScenario()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", hostNetworkListener, params )
        end 
   end
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--	Scene Creation
function hackScanScene:create(event)
	hsgroup = self.view
    params = event.params
    disableScroll=false
    rotation=0

	--Global Chat
	myData.hackScanRect = display.newImageRect( "img/private_chat_rect.png", display.contentWidth-40, fontSize(1680))
	myData.hackScanRect.anchorX = 0
	myData.hackScanRect.anchorY = 0
	myData.hackScanRect.x,myData.hackScanRect.y = 20, fontSize(110)+topPadding()
    changeImgColor(myData.hackScanRect)

	myData.hackScanName = display.newText(params.target,display.contentWidth/2,myData.hackScanRect.y+fontSize(50) ,native.systemFont, fontSize(50))
    myData.hackScanName.anchorX = 0.5
    myData.hackScanName.anchorY = 0.5

    myData.portScan = display.newImageRect( "img/port_scan_d.png",iconSize,iconSize )
    myData.portScan.anchorX = 0.5
    myData.portScan.anchorY = 0
    myData.portScan.x, myData.portScan.y = myData.hackScanRect.x+myData.hackScanRect.width/5,myData.hackScanRect.y+fontSize(110)
    myData.portScan.active=false

    myData.fingerprint = display.newImageRect( "img/fingerprinting_d.png",iconSize,iconSize )
    myData.fingerprint.anchorX = 0.5
    myData.fingerprint.anchorY = 0
    myData.fingerprint.x, myData.fingerprint.y = myData.hackScanRect.x+myData.hackScanRect.width/2,myData.hackScanRect.y+fontSize(110)
    myData.fingerprint.active=false

    -- myData.fingerprint2 = display.newImageRect( "img/fingerprinting_d1.png",iconSize,iconSize )
    -- myData.fingerprint2.anchorX = 0.5
    -- myData.fingerprint2.anchorY = 0
    -- myData.fingerprint2.x, myData.fingerprint2.y = myData.hackScanRect.x+myData.hackScanRect.width/2,myData.hackScanRect.y+fontSize(110)
    -- changeImgColor(myData.fingerprint2)
    -- myData.fingerprint2.active=false
    -- myData.fingerprint3 = display.newImageRect( "img/fingerprinting_d2.png",iconSize,iconSize )
    -- myData.fingerprint3.anchorX = 0.5
    -- myData.fingerprint3.anchorY = 0
    -- myData.fingerprint3.x, myData.fingerprint3.y = myData.hackScanRect.x+myData.hackScanRect.width/2,myData.hackScanRect.y+fontSize(110)
    -- changeImgColor(myData.fingerprint3)
    -- myData.fingerprint3.active=false

    myData.vulnScan = display.newImageRect( "img/vulnerability_scan_d.png",iconSize,iconSize )
    myData.vulnScan.anchorX = 0.5
    myData.vulnScan.anchorY = 0
    myData.vulnScan.x, myData.vulnScan.y = myData.hackScanRect.x+myData.hackScanRect.width/5*4,myData.hackScanRect.y+fontSize(110)
    myData.fingerprint.active=false

    --Target Table
    myData.targetPortTable = widget.newTableView(
        {
            left = myData.hackScanRect.x,
            top = myData.portScan.y+myData.portScan.height+fontSize(30),
            height = fontSize(930),
            width = myData.hackScanRect.width-60,
            onRowRender = onRowRender,
            --onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.targetPortTable.anchorX=0.5
    myData.targetPortTable.x=myData.hackScanRect.x+myData.hackScanRect.width/2

    myData.hackScanDetails = display.newText("Status: Not compromised",display.contentWidth/2,myData.targetPortTable.y+myData.targetPortTable.height/2+fontSize(30) ,native.systemFont, fontSize(55))
    myData.hackScanDetails.anchorX = 0.5
    myData.hackScanDetails.anchorY = 0

    myData.attackBtn = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.hackScanDetails.y+myData.hackScanDetails.height+fontSize(30),
        width = 500,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Attack Host!",
        labelColor = tableColor1,
        onEvent = goToHack
    })
    myData.attackBtn.active=true
    myData.attackBtn.name=params.target
    myData.attackBtn.id=params.target_id
    myData.attackBtn.anchorX=0.5
    myData.attackBtn.x=display.contentWidth/2

    myData.closePCBtn = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15)+topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Close",
        labelColor = tableColor1,
        onEvent = closePCD
    })

	loginInfo = localToken()

--	Show HUD	
	hsgroup:insert(myData.hackScanRect)
	hsgroup:insert(myData.hackScanName)
    hsgroup:insert(myData.portScan)
    hsgroup:insert(myData.fingerprint)
    -- hsgroup:insert(myData.fingerprint2)
    -- hsgroup:insert(myData.fingerprint3)
    hsgroup:insert(myData.vulnScan)
    hsgroup:insert(myData.targetPortTable)
    hsgroup:insert(myData.hackScanDetails)
    hsgroup:insert(myData.attackBtn)
	hsgroup:insert(myData.closePCBtn)

    myData.portScan:addEventListener("tap",portScan)
    myData.fingerprint:addEventListener("tap",fingerprint)
    myData.vulnScan:addEventListener("tap",vulnScan)
    myData.attackBtn:addEventListener("tap",goToHack)

end

-- Home Show
function hackScanScene:show(event)
	local homehsgroup = self.view
	if event.phase == "will" then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        hackScenarioLoaded=false
        network.request( host().."checkHackMissionActivities.php", "POST", hackScanActivitiesListener, params )
	end
	if event.phase == "did" then
		-- 		
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
hackScanScene:addEventListener( "create", hackScanScene )
hackScanScene:addEventListener( "show", hackScanScene )
---------------------------------------------------------------------------------

return hackScanScene