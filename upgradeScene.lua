local composer = require( "composer" )
local json = require "json"
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local widget = require( "widget" )
local notifications = require( "plugin.notifications" )
local upgradeScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local function boundCheck(x,y)
	if (myData.infoPanel.alpha == 0) then
		return true
	elseif ((x > (myData.infoPanel.x-myData.infoPanel.width/2)) and (x < myData.infoPanel.x+myData.infoPanel.width/2) and (y > (myData.infoPanel.y-myData.infoPanel.height/2)) and (y < (myData.infoPanel.y+myData.infoPanel.height/2))) then
		return false
	else
		return true
	end
end

local showStats = function(event)
	if ((myData.lastSelectedUpgrade ~= event.target.name) and (boundCheck(event.x,event.y))) then
		tapSound()
		myData.infoPanel.alpha = 1
		myData.upgradeButton.alpha = 1
		lvl = event.target.lvl
		if ((event.target.name == "Internet") or (event.target.name == "C&C Server")) then
			if (lvl == 10) then 
				if (event.target.name == "Internet") then lvl = internetLvltoName(lvl) end
				myData.upgradeButton.alpha = 0 
				myData.infoText.text = event.target.name .. "\nLevel: "..lvl.."\nMaximum level reached\n\n"..event.target.desc
			else
				if (event.target.name == "Internet") then lvl = internetLvltoName(lvl) end
				myData.infoText.text = event.target.name .. "\nLevel: "..lvl.."\nCost: $"..format_thousand(event.target.cost).."\nDuration: "..timeText(event.target.time).."\n\n"..event.target.desc
			end
		else
			local lvlrtext = ""
			if (event.target.lvlr>0) then
				lvlrtext=" ("..event.target.lvlr..")"
			end
			myData.infoText.text = event.target.name .. "\nLevel: "..lvl..""..lvlrtext.."\nCost: $"..format_thousand(event.target.cost).."\nDuration: "..timeText(event.target.time).."\n\n"..event.target.desc
		end
		myData.lastSelectedUpgrade = event.target.name
		myData.toUpgrade = event.target.toUpgrade
		myData.infoPanel.height = myData.infoText.height
		myData.infoPanel.x,myData.infoPanel.y = event.target.panelX, event.target.panelY
		myData.infoText.x,myData.infoText.y=myData.infoPanel.x-myData.infoPanel.width/2+20,myData.infoPanel.y-myData.infoPanel.height/2+20
		myData.upgradeButton.x,myData.upgradeButton.y=myData.infoPanel.x+myData.infoPanel.width/2-(iconSize/1.8),myData.infoPanel.y-myData.infoPanel.height/2+iconSize/2+10
	elseif (boundCheck(event.x,event.y)) then
		backSound()
		myData.infoPanel.alpha = 0
		myData.upgradeButton.alpha = 0
		myData.infoText.text = ""
		myData.lastSelectedUpgrade = ""
		myData.toUpgrade = ""
	end
end

function goBackUpgrade(event)
	if (tutOverlay==false) then
		if (upgradeClicked == 0) then
			backSound()
			if (myData.infoPanel.alpha == 1) then
				myData.infoPanel.alpha = 0
				myData.upgradeButton.alpha = 0
				myData.infoText.text = ""
				myData.lastSelectedUpgrade = ""
				--myData.infoImg:removeSelf()
				--myData.infoImg = nil
			else
				backTransition=true
				composer.removeScene( "upgradeScene" )
				composer.gotoScene("homeScene", {effect = "fade", time = 0})
			end
		end
	end
end

local function goBack(event)
	if (event.phase=="ended") then
		if (tutOverlay==false) then
			if (upgradeClicked == 0) then
				backSound()
				if (myData.infoPanel.alpha == 1) then
					myData.infoPanel.alpha = 0
					myData.upgradeButton.alpha = 0
					myData.infoText.text = ""
					myData.lastSelectedUpgrade = ""
					--myData.infoImg:removeSelf()
					--myData.infoImg = nil
					backTransition=true
					composer.removeScene( "upgradeScene" )
					composer.gotoScene("homeScene", {effect = "fade", time = 0})
				end
			end
		end
	end
end

local goUpgradeAttacker = function(event)
	if (boundCheck(event.x,event.y)) then
		if ((upgradeClicked == 0) and (backTransition==false)) then
			if (myData.infoPanel.alpha == 1) then
				myData.infoPanel.alpha = 0
				myData.upgradeButton.alpha = 0
				myData.infoText.text = ""
				myData.lastSelectedUpgrade = ""
				--myData.infoImg:removeSelf()
				--myData.infoImg = nil
			end
			tapSound()
			composer.gotoScene("upgradeAttackerScene", {effect = "fade", time = 100})
		end
	end
end

local goResearchCenter = function(event)
	if (event.phase=="ended") then
		if (boundCheck(event.x,event.y)) then
			if ((upgradeClicked == 0) and (backTransition==false)) then
				if (myData.infoPanel.alpha == 1) then
					myData.infoPanel.alpha = 0
					myData.upgradeButton.alpha = 0
					myData.infoText.text = ""
					myData.lastSelectedUpgrade = ""
					--myData.infoImg:removeSelf()
					--myData.infoImg = nil
				end
				tapSound()
				composer.gotoScene("researchScene", {effect = "fade", time = 100})
			end
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
----------------------------
local function lastTaskNetworkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        else
	        if ((t.oc_secs>1) and (t.secs>t.oc_secs)) then
	            t.secs=t.oc_secs+(t.secs-t.oc_secs)*2
	        end
            --Local Notification
            if ((taskNotificationActive==true) and (t.secs>0)) then
                if (notificationGlobal) then 
                    notifications.cancelNotification(notificationGlobal) 
                    notificationGlobal=nil
                end
                --notifications.cancelNotification()
                local utcTime = os.date( "!*t", os.time() + t.secs )
                notificationActive.task=utcTime
                notificationActive.taskTime=os.date(os.time() + t.secs)
                loadsave.saveTable( notificationActive, "localNotificationStatus.json" )
                setNewNotifications()
            end
        end
   end
end
----------------------------
local function networkUpgradeListener( event )
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

        if ( t.status == "NO_MONEY") then
        	local alert = native.showAlert( "EliteHax", "Oops.. It seems you don't have enough money...", { "Ok" }, nil )
        end

        if ( t.status == "MAX_TASK") then
        	local alert = native.showAlert( "EliteHax", "Max task number reached", { "Ok" }, nil )
        end

        if ( t.status == "MAX_LVL") then
            myData.infoText.text =  myData.lastSelectedUpgrade .. "\nLevel: MAX\n\n"..myData[myData.toUpgrade].desc
        end

    	if ( t.status == "OK") then
    		myData[myData.toUpgrade].lvl = t.new_lvl
    		
			if (myData.toUpgrade == "internet") then
				t.new_lvl = internetLvltoName(t.new_lvl)
			end
			if ((myData.toUpgrade == "internet") or (myData.toUpgrade == "c2c")) then
				if (myData[myData.toUpgrade].lvl == 10) then 
					myData.upgradeButton.alpha = 0 
					myData.infoText.text = myData.lastSelectedUpgrade .. "\nLevel: "..t.new_lvl.."\nMaximum level reached\n\n"..myData[myData.toUpgrade].desc
				else
			   		myData.infoText.text =  myData.lastSelectedUpgrade .. "\nLevel: " .. t.new_lvl.."\nCost: $"..format_thousand(t.new_cost).."\nDuration: "..timeText(t.new_time).."\n\n"..myData[myData.toUpgrade].desc
			   	end
			else
				local lvlrtext = ""
				if (myData[myData.toUpgrade].lvlr>0) then
					myData[myData.toUpgrade].lvlr=myData[myData.toUpgrade].lvlr+1
					lvlrtext=" ("..(myData[myData.toUpgrade].lvlr)..")"
				end
	   			myData.infoText.text =  myData.lastSelectedUpgrade .. "\nLevel: " .. t.new_lvl..""..lvlrtext.."\nCost: $"..format_thousand(t.new_cost).."\nDuration: "..timeText(t.new_time).."\n\n"..myData[myData.toUpgrade].desc
    		end
    		myData[myData.toUpgrade].txt.text = t.new_lvl
    		myData[myData.toUpgrade].cost = t.new_cost
    		myData.moneyTextU.text = format_thousand(t.money)

    		--Get Last Task for Local Notification
	        local headers = {}
	        local body = "id="..string.urlEncode(loginInfo.token)
	        local params = {}
	        params.headers = headers
	        params.body = body
	        network.request( host().."getLastTask.php", "POST", lastTaskNetworkListener, params )
    	end
        upgradeClicked = 0
	end
end

local function upgrade( event )
	if ((upgradeClicked == 0) and (event.phase == "ended") and ( backTransition==false)) then
		upgradeClicked = 1	
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token).."&type="..myData.toUpgrade.."&data="..string.urlEncode(generateNonce())
		local params = {}
		params.headers = headers
		params.body = body
		tapSound()
		network.request( host().."doupgrade.php", "POST", networkUpgradeListener, params )
	end
end
--------------------------------
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

        --Internet
		myData.internet.lvl = t.internet
		myData.internet.lvlr = t.internet_r
        digit = string.len(internetLvltoName(myData.internet.lvl))
        myData.internet.txtb.width = 70+(30*digit)
        myData.internet.txt.text = internetLvltoName(myData.internet.lvl) 
        myData.internet.cost = t.internet_cost
        myData.internet.time = t.internet_time

        --SIEM
        myData.siem.lvl = t.siem
        myData.siem.lvlr = t.siem_r
        digit = string.len(tostring(myData.siem.lvl))
        myData.siem.txtb.width = 70+(30*digit)
        myData.siem.txt.text = myData.siem.lvl    
        myData.siem.cost = t.siem_cost
        myData.siem.time = t.siem_time

        --Firewall
        myData.firewall.lvl = t.firewall
        myData.firewall.lvlr = t.firewall_r
        digit = string.len(tostring(myData.firewall.lvl))
        myData.firewall.txtb.width = 70+(30*digit)
        myData.firewall.txt.text = myData.firewall.lvl
        myData.firewall.cost = t.firewall_cost
        myData.firewall.time = t.firewall_time

        --IPS
        myData.ips.lvl = t.ips
        myData.ips.lvlr = t.ips_r
        digit = string.len(tostring(myData.ips.lvl))
        myData.ips.txtb.width = 70+(30*digit)
        myData.ips.txt.text = myData.ips.lvl
        myData.ips.cost = t.ips_cost
        myData.ips.time = t.ips_time

        --C2C
        myData.c2c.lvl = t.c2c
        myData.c2c.lvlr = t.c2c_r
        digit = string.len(tostring(myData.c2c.lvl))
        myData.c2c.txtb.width = 70+(30*digit)
        myData.c2c.txt.text = myData.c2c.lvl
        myData.c2c.cost = t.c2c_cost
        myData.c2c.time = t.c2c_time

        --Anon
        myData.anon.lvl = t.anon
        myData.anon.lvlr = t.anon_r
        digit = string.len(tostring(myData.anon.lvl))
        myData.anon.txtb.width = 70+(30*digit)
        myData.anon.txt.text = myData.anon.lvl
        myData.anon.cost = t.anon_cost
        myData.anon.time = t.anon_time
        
        --Web Server
        myData.webs.lvl = t.webs
        myData.webs.lvlr = t.webs_r
        digit = string.len(tostring(myData.webs.lvl))
        myData.webs.txtb.width = 70+(30*digit)
        myData.webs.txt.text = myData.webs.lvl
        myData.webs.cost = t.webs_cost
        myData.webs.time = t.webs_time

        --Application Server
        myData.apps.lvl = t.apps
        myData.apps.lvlr = t.apps_r
        digit = string.len(tostring(myData.apps.lvl))
        myData.apps.txtb.width = 70+(30*digit)
        myData.apps.txt.text = myData.apps.lvl
        myData.apps.cost = t.apps_cost
        myData.apps.time = t.apps_time

        --Database Server
        myData.dbs.lvl = t.dbs
        myData.dbs.lvlr = t.dbs_r
        digit = string.len(tostring(myData.dbs.lvl))
        myData.dbs.txtb.width = 70+(30*digit)
        myData.dbs.txt.text = myData.dbs.lvl
        myData.dbs.cost = t.dbs_cost
        myData.dbs.time = t.dbs_time

        --Money
        myData.moneyTextU.text = format_thousand(t.money)
        --Player
        if (string.len(t.user)>15) then myData.playerTextU.size = fontSize(42) end
        myData.playerTextU.text = t.user

    end
end

local function taskupdateListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OOops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
        	print ("EMPTY T")
        --local alert = native.showAlert( "EliteHax", "OOops.. A network error occured...", { "Close" }, onAlert )
        end
    end
end

internetLvltoName = function(lvl)
	name = "1 Gbps"
	if (lvl == 1) then 
		name = "56 Kbps"
	elseif (lvl == 2) then
		name = "128 Kbps"
	elseif (lvl == 3) then
		name = "256 Kbps"
	elseif (lvl == 4) then
		name = "1 Mbps"
	elseif (lvl == 5) then
		name = "10 Mbps"
	elseif (lvl == 6) then
		name = "20 Mbps"
	elseif (lvl == 7) then
		name = "100 Mbps"
	elseif (lvl == 8) then
		name = "200 Mbps"
	elseif (lvl == 9) then
		name = "500 Mbps"
	end
	return name
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
-- Scene Creation
function upgradeScene:create(event)
	local group = self.view

	loginInfo = localToken()

	upgradeClicked = 0
	iconSize=(display.contentWidth-200)/4*display.actualContentHeight/display.contentHeight

	-- Background
	myData.background = display.newImage("img/background.jpg")
	myData.background:scale(4,8)
	myData.background.alpha = 0.2
	changeImgColor(myData.background)

	-- Internet
	myData.internet = display.newImageRect( "img/internet.png",iconSize,iconSize )
	myData.internet.name = "Internet"
	myData.internet.toUpgrade = "internet"
	myData.internet.src = "img/internet.png"
	myData.internet.desc = "Internet upgrades reduce upgrade time\n "
	myData.internet.cost = 0
	myData.internet.time = 0
	myData.internet.lvl = 1
	myData.internet.anchorX = 1
	myData.internet.anchorY = 1
	myData.internet.x, myData.internet.y = (display.contentWidth/2)+(iconSize/2), iconSize+fontSize(180)+topPadding()
	myData.internet.panelX = myData.internet.x-myData.internet.width/2
	myData.internet.panelY = myData.internet.y+myData.internet.height+15
	digit = string.len(internetLvltoName(myData.internet.lvl))
	myData.internet.txtb = display.newRoundedRect(myData.internet.x-50-(15*digit),myData.internet.y-30,70+(30*digit),70,12)
	myData.internet.txtb.strokeWidth = 5
	myData.internet.txtb:setFillColor( 0,0,0 )
	myData.internet.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.internet.txt = display.newText(internetLvltoName(myData.internet.lvl),myData.internet.x-50-(15*digit),myData.internet.y-30 ,native.systemFont, fontSize(72))
	myData.internet.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	-- Firewall
	myData.firewall = display.newImageRect( "img/firewall.png",iconSize,iconSize )
	myData.firewall.name = "Firewall"
	myData.firewall.toUpgrade = "firewall"
	myData.firewall.src = "img/firewall.png"
	myData.firewall.desc = "Firewall blocks other players from scanning you and see detailed info about your defenses\n "
	myData.firewall.cost = 0
	myData.firewall.time = 0
	myData.firewall.lvl = 0
	myData.firewall.anchorX = 1
	myData.firewall.anchorY = 1
	myData.firewall.x, myData.firewall.y = (display.contentWidth/2)+(iconSize/2), myData.internet.y+iconSize+fontSize(175)
	myData.firewall.panelX = myData.firewall.x-myData.firewall.width/2
	myData.firewall.panelY = myData.firewall.y+myData.firewall.height+35
	digit = string.len(tostring(myData.firewall.lvl))
	myData.firewall.txtb = display.newRoundedRect(myData.firewall.x-50-(15*digit),myData.firewall.y-30,70+(30*digit),70,12)
	myData.firewall.txtb.strokeWidth = 5
	myData.firewall.txtb:setFillColor( 0,0,0 )
	myData.firewall.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.firewall.txt = display.newText(myData.firewall.lvl,myData.firewall.x-50-(15*digit),myData.firewall.y-30 ,native.systemFont, fontSize(72))
	myData.firewall.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	-- IPS
	myData.ips = display.newImageRect( "img/ips.png",iconSize,iconSize )
	myData.ips.name = "IPS"
	myData.ips.toUpgrade = "ips"
	myData.ips.src = "img/ips.png"
	myData.ips.desc = "IPS prevents exploit attempts to your servers\n "
	myData.ips.cost = 0
	myData.ips.time = 0
	myData.ips.lvl = 0
	myData.ips.anchorX = 1
	myData.ips.anchorY = 1
	myData.ips.x, myData.ips.y = myData.firewall.x + iconSize+50, myData.firewall.y
	myData.ips.panelX = myData.ips.x-myData.ips.width*1.5
	myData.ips.panelY = myData.ips.y+myData.ips.height+15
	digit = string.len(tostring(myData.ips.lvl))
	myData.ips.txtb = display.newRoundedRect(myData.ips.x-50-(15*digit),myData.ips.y-30,70+(30*digit),70,12)
	myData.ips.txtb.strokeWidth = 5
	myData.ips.txtb:setFillColor( 0,0,0 )
	myData.ips.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.ips.txt = display.newText(myData.ips.lvl,myData.ips.x-50-(15*digit),myData.ips.y-30 ,native.systemFont, fontSize(72))
	myData.ips.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	-- SIEM
	myData.siem = display.newImageRect( "img/siem.png",iconSize,iconSize )
	myData.siem.name = "SIEM"
	myData.siem.toUpgrade = "siem"
	myData.siem.src = "img/siem.png"
	myData.siem.desc = "SIEM increases the chance of detecting the attacker IP, Bot and RAT\n "
	myData.siem.cost = 0
	myData.siem.time = 0
	myData.siem.lvl = 0
	myData.siem.anchorX = 1
	myData.siem.anchorY = 1
	myData.siem.x, myData.siem.y = myData.firewall.x - iconSize-50, myData.firewall.y
	myData.siem.panelX = myData.siem.x+myData.siem.width/2
	myData.siem.panelY = myData.siem.y+myData.siem.height+35
	digit = string.len(tostring(myData.siem.lvl))
	myData.siem.txtb = display.newRoundedRect(myData.siem.x-50-(15*digit),myData.siem.y-30,70+(30*digit),70,12)
	myData.siem.txtb.strokeWidth = 5
	myData.siem.txtb:setFillColor( 0,0,0 )
	myData.siem.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.siem.txt = display.newText(myData.siem.lvl,myData.siem.x-50-(15*digit),myData.siem.y-30 ,native.systemFont, fontSize(72))
	myData.siem.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	-- Attacker Server
	myData.attacker = display.newImageRect( "img/attacker.png",iconSize,iconSize )
	myData.attacker.anchorX = 1
	myData.attacker.anchorY = 1
	myData.attacker.x, myData.attacker.y = (display.contentWidth/2)-(iconSize/2)-50, myData.firewall.y+iconSize+fontSize(200)

	-- C2C Server
	myData.c2c = display.newImageRect( "img/c2c-server.png",iconSize,iconSize )
	myData.c2c.name = "C&C Server"
	myData.c2c.toUpgrade = "c2c"
	myData.c2c.src = "img/c2c-server.png"
	myData.c2c.desc = "C&C allows you to have more Bot and RAT installed\n "
	myData.c2c.cost = 0
	myData.c2c.time = 0
	myData.c2c.lvl = 0
	myData.c2c.anchorX = 1
	myData.c2c.anchorY = 1
	myData.c2c.x, myData.c2c.y = (display.contentWidth/2)-iconSize-70, myData.attacker.y+iconSize+50
	myData.c2c.panelX = myData.c2c.x+myData.c2c.width
	myData.c2c.panelY = myData.c2c.y-myData.c2c.height*2
	digit = string.len(tostring(myData.c2c.lvl))
	myData.c2c.txtb = display.newRoundedRect(myData.c2c.x-50-(15*digit),myData.c2c.y-30,70+(30*digit),70,12)
	myData.c2c.txtb.strokeWidth = 5
	myData.c2c.txtb:setFillColor( 0,0,0 )
	myData.c2c.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.c2c.txt = display.newText(myData.c2c.lvl,myData.c2c.x-50-(15*digit),myData.c2c.y-30 ,native.systemFont, fontSize(72))
	myData.c2c.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	-- Anonymizer
	myData.anon = display.newImageRect( "img/anon.png",iconSize,iconSize )
	myData.anon.name = "Anonymizer"
	myData.anon.toUpgrade = "anon"
	myData.anon.src = "img/anon.png"
	myData.anon.desc = "Anonymizer uses a combo of Proxy Chain, IP Spoofing and TOR to hide your IP when attacking other players\n "
	myData.anon.cost = 0
	myData.anon.time = 0
	myData.anon.lvl = 0
	myData.anon.anchorX = 1
	myData.anon.anchorY = 1
	myData.anon.x, myData.anon.y = myData.c2c.x+iconSize+20, myData.attacker.y+iconSize+50
	myData.anon.panelX = myData.anon.x+myData.anon.width/2
	myData.anon.panelY = myData.anon.y-myData.anon.height*2-50
	digit = string.len(tostring(myData.anon.lvl))
	myData.anon.txtb = display.newRoundedRect(myData.anon.x-50-(15*digit),myData.anon.y-30,70+(30*digit),70,12)
	myData.anon.txtb.strokeWidth = 5
	myData.anon.txtb:setFillColor( 0,0,0 )
	myData.anon.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.anon.txt = display.newText(myData.anon.lvl,myData.anon.x-50-(15*digit),myData.anon.y-30 ,native.systemFont, fontSize(72))
	myData.anon.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	-- Web Server
	myData.webs = display.newImageRect( "img/web-server.png",iconSize,iconSize )
	myData.webs.name = "Web Server"
	myData.webs.toUpgrade = "webs"
	myData.webs.src = "img/web-server.png"
	myData.webs.desc = "Patching the Web Server protect it from exploits\n "
	myData.webs.cost = 0
	myData.webs.time = 0
	myData.webs.lvl = 0
	myData.webs.anchorX = 1
	myData.webs.anchorY = 1
	myData.webs.x, myData.webs.y = (display.contentWidth/2)+iconSize+40, myData.attacker.y
	myData.webs.panelX = myData.webs.x-myData.webs.width
	myData.webs.panelY = myData.webs.y-myData.webs.height*2-20
	digit = string.len(tostring(myData.webs.lvl))
	myData.webs.txtb = display.newRoundedRect(myData.webs.x-50-(15*digit),myData.webs.y-30,70+(30*digit),70,12)
	myData.webs.txtb.strokeWidth = 5
	myData.webs.txtb:setFillColor( 0,0,0 )
	myData.webs.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.webs.txt = display.newText(myData.webs.lvl,myData.webs.x-50-(15*digit),myData.webs.y-30 ,native.systemFont, fontSize(72))
	myData.webs.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	-- Application Server
	myData.apps = display.newImageRect( "img/application-server.png",iconSize,iconSize )
	myData.apps.name = "Application Server"
	myData.apps.toUpgrade = "apps"
	myData.apps.src = "img/application-server.png"
	myData.apps.desc = "Patching the Application Server protect it from exploits\n "
	myData.apps.cost = 0
	myData.apps.time = 0 
	myData.apps.lvl = 0
	myData.apps.anchorX = 1
	myData.apps.anchorY = 1
	myData.apps.x, myData.apps.y = myData.webs.x+iconSize+20, myData.attacker.y
	myData.apps.panelX = myData.apps.x-myData.apps.width*2
	myData.apps.panelY = myData.apps.y-myData.apps.height*2-20
	digit = string.len(tostring(myData.apps.lvl))
	myData.apps.txtb = display.newRoundedRect(myData.apps.x-50-(15*digit),myData.apps.y-30,70+(30*digit),70,12)
	myData.apps.txtb.strokeWidth = 5
	myData.apps.txtb:setFillColor( 0,0,0 )
	myData.apps.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.apps.txt = display.newText(myData.apps.lvl,myData.apps.x-50-(15*digit),myData.apps.y-30 ,native.systemFont, fontSize(72))
	myData.apps.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	-- DB Server
	myData.dbs = display.newImageRect( "img/db-server.png",iconSize,iconSize )
	myData.dbs.name = "Database Server"
	myData.dbs.toUpgrade = "dbs"
	myData.dbs.src = "img/db-server.png"
	myData.dbs.desc = "Patching the Database Server protect it from exploits\n "
	myData.dbs.cost = 0
	myData.dbs.time = 0
	myData.dbs.lvl = 0
	myData.dbs.anchorX = 1
	myData.dbs.anchorY = 1
	myData.dbs.x, myData.dbs.y = myData.webs.x + (iconSize/2)+15, myData.webs.y+iconSize+50
	myData.dbs.panelX = myData.dbs.x-myData.dbs.width*1.5
	myData.dbs.panelY = myData.dbs.y-myData.dbs.height*2-20
	digit = string.len(tostring(myData.dbs.lvl))
	myData.dbs.txtb = display.newRoundedRect(myData.dbs.x-50-(15*digit),myData.dbs.y-30,70+(30*digit),70,12)
	myData.dbs.txtb.strokeWidth = 5
	myData.dbs.txtb:setFillColor( 0,0,0 )
	myData.dbs.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.dbs.txt = display.newText(myData.dbs.lvl,myData.dbs.x-50-(15*digit),myData.dbs.y-30 ,native.systemFont, fontSize(72))
	myData.dbs.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	myData.defenseRect = display.newImageRect( "img/upgrades_defenses.png",(iconSize*3)+220,iconSize+fontSize(150))
	myData.defenseRect.anchorX=0.5
	myData.defenseRect.x, myData.defenseRect.y = display.contentWidth/2,myData.internet.y+iconSize+fontSize(30)

	-- Attacking Rectangle
	myData.attackerRect = display.newImageRect( "img/upgrades_attacking.png",(iconSize*2)+80,(iconSize*2)+fontSize(210))
	myData.attackerRect.x, myData.attackerRect.y = myData.c2c.x+20,myData.attacker.y-10

	-- Asset Rectangle
	myData.assetRect = display.newImageRect( "img/upgrades_assets.png",(iconSize*2)+80,(iconSize*2)+fontSize(210))
	myData.assetRect.x, myData.assetRect.y = myData.webs.x+20,myData.attackerRect.y

	--TOP
	myData.top_backgroundU = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
	myData.top_backgroundU.anchorX = 0.5
	myData.top_backgroundU.anchorY = 0
	myData.top_backgroundU.x, myData.top_backgroundU.y = display.contentWidth/2,5+topPadding()
	changeImgColor(myData.top_backgroundU)

	--Money
	myData.moneyTextU = display.newText("",115,myData.top_backgroundU.y+myData.top_backgroundU.height/2,native.systemFont, fontSize(48))
	myData.moneyTextU.anchorX = 0
	myData.moneyTextU.anchorY = 0.5
	myData.moneyTextU:setFillColor( 0.9,0.9,0.9 )

	--Player Name
	myData.playerTextU = display.newText("",display.contentWidth-250,myData.top_backgroundU.y+myData.top_backgroundU.height/2,native.systemFont, fontSize(48))
	myData.playerTextU.anchorX = 0.5
	myData.playerTextU.anchorY = 0.5
	myData.playerTextU:setFillColor( 0.9,0.9,0.9 )

	-- Research Button
	myData.researchButton = widget.newButton(
	    {
	    	left = 20,
	    	top = myData.attackerRect.y+myData.attackerRect.height/2+fontSize(30),
			width = display.contentWidth - 40,
	        height = display.actualContentHeight/15-5,
	        defaultFile = buttonColor1080,
	       -- overFile = "buttonOver.png",
	        fontSize = 80,
	        label = "Research Center",
	        labelColor = tableColor1,
	        onEvent = goResearchCenter
	    }
	)

	-- Back Button
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
	    }
	)
	
	-- Info Panel - Modificare posizione in base a elemento
	sizey=display.actualContentHeight /4.5
	myData.infoPanel = display.newRoundedRect( 10000, 10000, display.contentWidth/1.3, sizey-20, 12 )
	myData.infoPanel.anchorX = 0.5
	myData.infoPanel.anchorY = 0.5
	myData.infoPanel.strokeWidth = 5
	myData.infoPanel:setFillColor( 0,0,0 )
	myData.infoPanel:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
	myData.infoPanel.alpha = 0

	myData.infoText = display.newText("",40,20,myData.infoPanel.width-60,0,native.systemFont, fontSize(52))
	myData.infoText.anchorX = 0
	myData.infoText.anchorY = 0
	myData.infoText:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
	myData.upgradeButton = widget.newButton(
	    {
	    	left = myData.infoPanel.width-(iconSize/1.2)-60,
	    	top = 20,
			width = iconSize/1.1,
	        height = iconSize/1.1,
	        defaultFile = "img/upgrade.png",
	        onEvent = upgrade
	    })
	myData.upgradeButton.alpha = 0

--	Show HUD	
	group:insert(myData.background)
	group:insert(myData.top_backgroundU)
	group:insert(myData.attackerRect)
	group:insert(myData.defenseRect)
	group:insert(myData.assetRect)
	group:insert(myData.internet)
	group:insert(myData.internet.txtb)
	group:insert(myData.internet.txt)
	group:insert(myData.siem)
	group:insert(myData.siem.txtb)
	group:insert(myData.siem.txt)
	group:insert(myData.firewall)
	group:insert(myData.firewall.txtb)
	group:insert(myData.firewall.txt)
	group:insert(myData.ips)
	group:insert(myData.ips.txtb)
	group:insert(myData.ips.txt)
	group:insert(myData.attacker)
	group:insert(myData.c2c)
	group:insert(myData.c2c.txtb)
	group:insert(myData.c2c.txt)
	group:insert(myData.anon)
	group:insert(myData.anon.txtb)
	group:insert(myData.anon.txt)
	group:insert(myData.webs)
	group:insert(myData.webs.txtb)
	group:insert(myData.webs.txt)
	group:insert(myData.apps)
	group:insert(myData.apps.txtb)
	group:insert(myData.apps.txt)
	group:insert(myData.dbs)
	group:insert(myData.dbs.txtb)
	group:insert(myData.dbs.txt)	
	group:insert(myData.infoPanel)
	--group:insert(myData.infoText)
	group:insert(myData.researchButton)
	group:insert(myData.backButton)
	--group:insert(myData.upgradeButton)
	group:insert(myData.moneyTextU)
	group:insert(myData.playerTextU)

--	Graphical Order
	group:toFront()

--	Button Listeners
	myData.firewall:addEventListener("tap",showStats)
	myData.internet:addEventListener("tap",showStats)
	myData.ips:addEventListener("tap",showStats)
	myData.attacker:addEventListener("tap",goUpgradeAttacker)
	myData.c2c:addEventListener("tap",showStats)
	myData.siem:addEventListener("tap",showStats)
	myData.anon:addEventListener("tap",showStats)
	myData.webs:addEventListener("tap",showStats)
	myData.apps:addEventListener("tap",showStats)
	myData.dbs:addEventListener("tap",showStats)
	myData.backButton:addEventListener("tap",goBackUpgrade)
	myData.researchButton:addEventListener("tap",goResearchCenter)
	myData.upgradeButton:addEventListener("tap",upgrade)

end

-- Upgrade Show
function upgradeScene:show(event)
	local upgradeGroup = self.view
	if event.phase == "will" then
		-- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "upgradeTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutUpgrade ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "upgradeTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
		backTransition=false
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token)
		local params = {}
		params.headers = headers
		params.body = body
        network.request( host().."updatetask.php", "POST", taskupdateListener , params )
		network.request( host().."getupgrades.php", "POST", networkListener, params )
	end
	if event.phase == "did" then
		--
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
upgradeScene:addEventListener( "create", upgradeScene )
upgradeScene:addEventListener( "show", upgradeScene )
---------------------------------------------------------------------------------

return upgradeScene