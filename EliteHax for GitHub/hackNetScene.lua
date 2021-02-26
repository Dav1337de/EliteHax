local composer = require( "composer" )
local json = require "json"
local myData = require ("mydata")
local hackNetScene = composer.newScene()
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

local function goToHack(event)
    if (event.phase=="ended") then
        tapSound()
        composer.hideOverlay( "fade", 0 )
        composer.removeScene( "hackMapScene" )
        composer.gotoScene("hackScene", {effect = "fade", time = 100})
    end
end

local function netNetworkListener( event )
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

        local hosts="Not Scanned"
        if (t.hosts~=0) then
            hosts=t.hosts
        end
        local services="Not Scanned"
        if (t.services~=0) then
            services=t.services
        end
        local users="Not Scanned"
        if (t.users~=0) then
            users=t.users
        end
        myData.hackScanDetails.text="Detect Hosts: "..hosts.."\nDetected Open Ports: "..services.."\nDetected Target People: "..users.."\n"

        if (t.running_activity==0) then
            if (t.host_scan==0) then
                local imageA = { type="image", filename="img/host_scan.png" }
                myData.hostScan.fill=imageA
                myData.hostScan.active=true
                changeImgColor(myData.hostScan)
            end
            if (t.port_scan==0) then
                local imageA = { type="image", filename="img/port_scan.png" }
                myData.portScan.fill=imageA
                myData.portScan.active=true
                changeImgColor(myData.portScan)
            end
            if (t.social_engineering==0) then
                local imageA = { type="image", filename="img/social_engineering.png" }
                myData.socialEng.fill=imageA
                myData.socialEng.active=true
                changeImgColor(myData.socialEng)
            end
        end
   end
end

local function netPortScanNetworkListener( event )
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
            composer.hideOverlay( "fade", 0 )
            loaded=true
            refreshHackScenario()
        end 
   end
end

local function portScan(event)
    if ((myData.portScan.active==true) and (loaded==true)) then
        tapSound()
        loaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&net_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."netPortScan.php", "POST", netPortScanNetworkListener, params )
    end
end

local function netHostScanNetworkListener( event )
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
            composer.hideOverlay( "fade", 0 )
            loaded=true
            refreshHackScenario()
        end 
   end
end

local function hostScan(event)
    if ((myData.hostScan.active==true) and (loaded==true)) then
        tapSound()
        loaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&net_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."netHostScan.php", "POST", netHostScanNetworkListener, params )
    end
end

local function netSocialEngNetworkListener( event )
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
            composer.hideOverlay( "fade", 0 )
            loaded=true
            refreshHackScenario()
        end 
   end
end

local function socialEng(event)
    if ((myData.socialEng.active==true) and (loaded==true)) then
        tapSound()
        loaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&net_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."netSocialEng.php", "POST", netSocialEngNetworkListener, params )
    end
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--	Scene Creation
function hackNetScene:create(event)
	hsgroup = self.view
    params = event.params
    disableScroll=false

    loaded=true

	--Global Chat
	myData.hackScanRect = display.newImageRect( "img/hack_net_rect.png", display.contentWidth-40, fontSize(700))
	myData.hackScanRect.anchorX = 0
	myData.hackScanRect.anchorY = 0.5
	myData.hackScanRect.x,myData.hackScanRect.y = 20, display.actualContentHeight/2
    changeImgColor(myData.hackScanRect)

	myData.hackScanName = display.newText(params.target,display.contentWidth/2,myData.hackScanRect.y-myData.hackScanRect.height/2+fontSize(50) ,native.systemFont, fontSize(50))
    myData.hackScanName.anchorX = 0.5
    myData.hackScanName.anchorY = 0.5

    myData.hostScan = display.newImageRect( "img/host_scan_d.png",iconSize,iconSize )
    myData.hostScan.anchorX = 0.5
    myData.hostScan.anchorY = 0
    myData.hostScan.x, myData.hostScan.y = myData.hackScanRect.x+myData.hackScanRect.width/5,myData.hackScanRect.y-myData.hackScanRect.height/2+fontSize(150)
    myData.hostScan.active=false

    myData.portScan = display.newImageRect( "img/port_scan_d.png",iconSize,iconSize )
    myData.portScan.anchorX = 0.5
    myData.portScan.anchorY = 0
    myData.portScan.x, myData.portScan.y = myData.hackScanRect.x+myData.hackScanRect.width/2,myData.hackScanRect.y-myData.hackScanRect.height/2+fontSize(150)
    myData.hostScan.active=false

    myData.socialEng = display.newImageRect( "img/social_engineering_d.png",iconSize,iconSize )
    myData.socialEng.anchorX = 0.5
    myData.socialEng.anchorY = 0
    myData.socialEng.x, myData.socialEng.y = myData.hackScanRect.x+myData.hackScanRect.width/5*4,myData.hackScanRect.y-myData.hackScanRect.height/2+fontSize(150)
    myData.hostScan.active=false

    myData.hackScanDetails = display.newText("Detect Hosts: Not Scanned\nDetected Open Ports: Not Scanned\nDetected Target People: Not Scanned\n",80,myData.hostScan.y+myData.hostScan.height+fontSize(100) ,native.systemFont, fontSize(50))
    myData.hackScanDetails.anchorX=0
    myData.hackScanDetails.anchorY=0

    myData.attackBtn = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.hackScanDetails.y+myData.hackScanDetails.height+fontSize(80),
        width = 800,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Attack Company!",
        labelColor = tableColor1,
        onEvent = goToHack
    })
    myData.attackBtn.name=params.target
    myData.attackBtn.anchorX=0.5
    myData.attackBtn.x=display.contentWidth/2
    myData.attackBtn.alpha=0

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
    hsgroup:insert(myData.hostScan)
    hsgroup:insert(myData.socialEng)
    hsgroup:insert(myData.hackScanDetails)
    hsgroup:insert(myData.attackBtn)
	hsgroup:insert(myData.closePCBtn)

    myData.hostScan:addEventListener("tap",hostScan)
    myData.portScan:addEventListener("tap",portScan)
    myData.socialEng:addEventListener("tap",socialEng)
end

-- Home Show
function hackNetScene:show(event)
	local homehsgroup = self.view
	if event.phase == "will" then
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token).."&net_id="..params.target_id
		local params = {}
		params.headers = headers
		params.body = body
		network.request( host().."getNetDetails.php", "POST", netNetworkListener, params )
	end
	if event.phase == "did" then
		-- 		
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
hackNetScene:addEventListener( "create", hackNetScene )
hackNetScene:addEventListener( "show", hackNetScene )
---------------------------------------------------------------------------------

return hackNetScene