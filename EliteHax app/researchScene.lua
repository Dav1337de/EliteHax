local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local notifications = require( "plugin.notifications" )
local loadsave = require( "loadsave" )
local researchScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
local updateResearchTimer

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local function boundCheckST(x,y)
    if (myData.infoPanelRT.alpha == 0) then
        return true
    elseif ((x > (myData.infoPanelRT.x-myData.infoPanelRT.width/2)) and (x < myData.infoPanelRT.x+myData.infoPanelRT.width/2) and (y > (myData.infoPanelRT.y)) and (y < (myData.infoPanelRT.y+myData.infoPanelRT.height))) then
        return false
    else
        return true
    end
end

local showRTStat = function(event)
    if ((myData.lastSelectedUpgrade ~= event.target.name) and (boundCheckST(event.x,event.y))) then
        tapSound()
        lvl = event.target.lvl
        if (event.target.enabled==false) then 
            myData.upgradeRTButton.alpha=0 
        elseif (canResearch==true) then
            myData.upgradeRTButton.alpha=1
        end
        if (tonumber(lvl) == 100) then 
            myData.infoTextRT.text = event.target.name .. "\nLevel: "..lvl.."/100 - Maximum level reached"
            myData.upgradeRTButton.alpha = 0
        else
            myData.infoTextRT.text = event.target.name .. "\nLevel: "..lvl.."/100"
            if ((event.target.enabled==true) and (canResearch==true)) then myData.upgradeRTButton.alpha = 1 end
        end

        myData.infoPanelRT.alpha = 1
        myData.infoTextRT2.text=event.target.desc
        if (event.target.enabled==false) then
        	myData.infoTextRT2.text=myData.infoTextRT2.text..""..event.target.req
        end
        myData.lastSelectedUpgrade = event.target.name
        myData.toUpgradeRT = event.target.toUpgradeRT
        myData.infoPanelRT.height = myData.infoTextRT.height+myData.infoTextRT2.height+fontSize(20)
        if ((event.target.name=="Risk Manager") or (event.target.name=="Penetration Tester") or (event.target.name=="Money Chaser") or (event.target.name=="Upgrades Expeditor") or (event.target.name=="Upgrades Negotiator") or (event.target.name=="Money Hider")) then
            myData.infoPanelRT.x,myData.infoPanelRT.y = display.contentWidth/2, event.target.y-myData.infoPanelRT.height-10
        else
            myData.infoPanelRT.x,myData.infoPanelRT.y = display.contentWidth/2, event.target.y+event.target.height+10
        end
        myData.infoTextRT.x,myData.infoTextRT.y=myData.infoPanelRT.x-myData.infoPanelRT.width/2+20,myData.infoPanelRT.y+20
        myData.infoTextRT2.x,myData.infoTextRT2.y=myData.infoTextRT.x,myData.infoTextRT.y+myData.infoTextRT.height+fontSize(30)
        myData.upgradeRTButton.x,myData.upgradeRTButton.y=myData.infoPanelRT.x+myData.infoPanelRT.width/2-200,myData.infoPanelRT.y+fontSize(80)
    elseif (boundCheckST(event.x,event.y) or (myData.lastSelectedUpgrade == event.target.name)) then
        backSound()
        myData.infoPanelRT.alpha = 0
        myData.upgradeRTButton.alpha = 0
        myData.infoTextRT.text = ""
        myData.infoTextRT2.text = ""
        myData.lastSelectedUpgrade = ""
        myData.toUpgradeRT = ""
    end
end

local function RTnetworkListener( event )
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

        myData.playerTextRC.text=t.username
        if (string.len(t.username)>15) then myData.playerTextRC.size = fontSize(42) end
        myData.moneyTextRC.text = format_thousand(t.money)

        myData.coolR1.lvl=t.coolR1
        myData.missionR1.lvl=t.missionR1
        myData.missionR2.lvl=t.missionR2
        myData.missionR3.lvl=t.missionR3
        myData.upgradeR1.lvl=t.upgradeR1
        myData.upgradeR2.lvl=t.upgradeR2
        myData.botR1.lvl=t.botR1
        myData.scannerR1.lvl=t.scannerR1
        myData.scannerR2.lvl=t.scannerR2
        myData.anonR1.lvl=t.anonR1
        myData.anonR2.lvl=t.anonR2
        myData.exploitR1.lvl=t.exploitR1
        myData.exploitR2.lvl=t.exploitR2
        myData.malwareR1.lvl=t.malwareR1
        myData.malwareR2.lvl=t.malwareR2
        myData.fwR1.lvl=t.fwR1
        myData.fwR2.lvl=t.fwR2
        myData.siemR1.lvl=t.siemR1
        myData.siemR2.lvl=t.siemR2
        myData.ipsR1.lvl=t.ipsR1
        myData.ipsR2.lvl=t.ipsR2
        myData.avR1.lvl=t.avR1
        myData.avR2.lvl=t.avR2
        myData.progR1.lvl=t.progR1
        myData.progR2.lvl=t.progR2

        if (tonumber(t.secondsLeft)>0) then
        	myData[t.current_r].lvl=myData[t.current_r].lvl-1
        	t[t.current_r]=t[t.current_r]-1
        end

        myData.coolR1.txt.text=t.coolR1.."/100"
        myData.missionR1.txt.text=t.missionR1.."/100"
        myData.missionR2.txt.text=t.missionR2.."/100"
        myData.missionR3.txt.text=t.missionR3.."/100"
        myData.upgradeR1.txt.text=t.upgradeR1.."/100"
        myData.upgradeR2.txt.text=t.upgradeR2.."/100"
        myData.botR1.txt.text=t.botR1.."/100"
        myData.scannerR1.txt.text=t.scannerR1.."/100"
        myData.scannerR2.txt.text=t.scannerR2.."/100"
        myData.anonR1.txt.text=t.anonR1.."/100"
        myData.anonR2.txt.text=t.anonR2.."/100"
        myData.exploitR1.txt.text=t.exploitR1.."/100"
        myData.exploitR2.txt.text=t.exploitR2.."/100"
        myData.malwareR1.txt.text=t.malwareR1.."/100"
        myData.malwareR2.txt.text=t.malwareR2.."/100"
        myData.fwR1.txt.text=t.fwR1.."/100"
        myData.fwR2.txt.text=t.fwR2.."/100"
        myData.siemR1.txt.text=t.siemR1.."/100"
        myData.siemR2.txt.text=t.siemR2.."/100"
        myData.ipsR1.txt.text=t.ipsR1.."/100"
        myData.ipsR2.txt.text=t.ipsR2.."/100"
        myData.avR1.txt.text=t.avR1.."/100"
        myData.avR2.txt.text=t.avR2.."/100"
        myData.progR1.txt.text=t.progR1.."/100"
        myData.progR2.txt.text=t.progR2.."/100"

        digit = string.len(tostring(myData.coolR1.lvl))
        myData.coolR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.missionR1.lvl))
        myData.missionR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.missionR2.lvl))
        myData.missionR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.missionR3.lvl))
        myData.missionR3.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.upgradeR1.lvl))
        myData.upgradeR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.upgradeR2.lvl))
        myData.upgradeR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.botR1.lvl))
        myData.botR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.scannerR1.lvl))
        myData.scannerR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.scannerR2.lvl))
        myData.scannerR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.anonR1.lvl))
        myData.anonR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.anonR2.lvl))
        myData.anonR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.exploitR1.lvl))
        myData.exploitR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.exploitR2.lvl))
        myData.exploitR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.malwareR1.lvl))
        myData.malwareR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.malwareR2.lvl))
        myData.malwareR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.fwR1.lvl))
        myData.fwR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.fwR2.lvl))
        myData.fwR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.siemR1.lvl))
        myData.siemR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.siemR2.lvl))
        myData.siemR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.ipsR1.lvl))
        myData.ipsR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.ipsR2.lvl))
        myData.ipsR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.avR1.lvl))
        myData.avR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.avR2.lvl))
        myData.avR2.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.progR1.lvl))
        myData.progR1.txtb.width=100+(30*digit)
        digit = string.len(tostring(myData.progR2.lvl))
        myData.progR2.txtb.width=100+(30*digit)

        if (view=="general") then
            if (tonumber(t.missionR1)>=10) then
                local imageA = { type="image", filename=myData.upgradeR1.src}
                myData.upgradeR1.fill=imageA
                myData.upgradeR1.txtb.alpha=1
                myData.upgradeR1.txt.alpha=1
                myData.upgradeR1.enabled=1
            end
            if (tonumber(t.missionR2)>=10) then
                local imageA = { type="image", filename=myData.upgradeR2.src}
                myData.upgradeR2.fill=imageA
                myData.upgradeR2.txtb.alpha=1
                myData.upgradeR2.txt.alpha=1
                myData.upgradeR2.enabled=1
            end
            if ((tonumber(t.missionR1)>=50) and (tonumber(t.missionR2)>=50)) then
                local imageA = { type="image", filename=myData.missionR3.src}
                myData.missionR3.fill=imageA
                myData.missionR3.txtb.alpha=1
                myData.missionR3.txt.alpha=1
                myData.missionR3.enabled=1
            end
            if (tonumber(t.coolR1)>=10) then
                local imageA = { type="image", filename=myData.missionR1.src}
                myData.missionR1.fill=imageA
                myData.missionR1.txtb.alpha=1
                myData.missionR1.txt.alpha=1
                myData.missionR1.enabled=1
                local imageA = { type="image", filename=myData.missionR2.src}
                myData.missionR2.fill=imageA
                myData.missionR2.txtb.alpha=1
                myData.missionR2.txt.alpha=1
                myData.missionR2.enabled=1
            end    
        elseif (view=="attack") then
            if (tonumber(t.exploitR1)>=100) then
                local imageA = { type="image", filename=myData.exploitR2.src}
                myData.exploitR2.fill=imageA
                myData.exploitR2.txtb.alpha=1
                myData.exploitR2.txt.alpha=1
                myData.exploitR2.enabled=1
            end
            if (tonumber(t.malwareR1)>=100) then
                local imageA = { type="image", filename=myData.malwareR2.src}
                myData.malwareR2.fill=imageA
                myData.malwareR2.txtb.alpha=1
                myData.malwareR2.txt.alpha=1
                myData.malwareR2.enabled=1
            end
            if (tonumber(t.scannerR1)>=100) then
                local imageA = { type="image", filename=myData.scannerR2.src}
                myData.scannerR2.fill=imageA
                myData.scannerR2.txtb.alpha=1
                myData.scannerR2.txt.alpha=1
                myData.scannerR2.enabled=1
            end
            if (tonumber(t.anonR1)>=100) then
                local imageA = { type="image", filename=myData.anonR2.src}
                myData.anonR2.fill=imageA
                myData.anonR2.txtb.alpha=1
                myData.anonR2.txt.alpha=1
                myData.anonR2.enabled=1
            end
            if (tonumber(t.scannerR1)>=10) then
                local imageA = { type="image", filename=myData.exploitR1.src}
                myData.exploitR1.fill=imageA
                myData.exploitR1.txtb.alpha=1
                myData.exploitR1.txt.alpha=1
                myData.exploitR1.enabled=1
            end
            if (tonumber(t.anonR1)>=10) then
                local imageA = { type="image", filename=myData.malwareR1.src}
                myData.malwareR1.fill=imageA
                myData.malwareR1.txtb.alpha=1
                myData.malwareR1.txt.alpha=1
                myData.malwareR1.enabled=1
            end
            if (tonumber(t.botR1)>=10) then
                local imageA = { type="image", filename=myData.scannerR1.src}
                myData.scannerR1.fill=imageA
                myData.scannerR1.txtb.alpha=1
                myData.scannerR1.txt.alpha=1
                myData.scannerR1.enabled=1
            end
            if (tonumber(t.botR1)>=10) then
                local imageA = { type="image", filename=myData.anonR1.src}
                myData.anonR1.fill=imageA
                myData.anonR1.txtb.alpha=1
                myData.anonR1.txt.alpha=1
                myData.anonR1.enabled=1
            end
        elseif (view=="defense") then
            if (tonumber(t.progR1)>=100) then
                local imageA = { type="image", filename=myData.progR2.src}
                myData.progR2.fill=imageA
                myData.progR2.txtb.alpha=1
                myData.progR2.txt.alpha=1
                myData.progR2.enabled=1
            end
            if (tonumber(t.avR1)>=100) then
                local imageA = { type="image", filename=myData.avR2.src}
                myData.avR2.fill=imageA
                myData.avR2.txtb.alpha=1
                myData.avR2.txt.alpha=1
                myData.avR2.enabled=1
            end
            if (tonumber(t.siemR1)>=100) then
                local imageA = { type="image", filename=myData.siemR2.src}
                myData.siemR2.fill=imageA
                myData.siemR2.txtb.alpha=1
                myData.siemR2.txt.alpha=1
                myData.siemR2.enabled=1
            end
            if (tonumber(t.ipsR1)>=100) then
                local imageA = { type="image", filename=myData.ipsR2.src}
                myData.ipsR2.fill=imageA
                myData.ipsR2.txtb.alpha=1
                myData.ipsR2.txt.alpha=1
                myData.ipsR2.enabled=1
            end
            if (tonumber(t.siemR1)>=10) then
                local imageA = { type="image", filename=myData.avR1.src}
                myData.avR1.fill=imageA
                myData.avR1.txtb.alpha=1
                myData.avR1.txt.alpha=1
                myData.avR1.enabled=1
            end
            if (tonumber(t.ipsR1)>=10) then
                local imageA = { type="image", filename=myData.progR1.src}
                myData.progR1.fill=imageA
                myData.progR1.txtb.alpha=1
                myData.progR1.txt.alpha=1
                myData.progR1.enabled=1
            end
            if (tonumber(t.fwR1)>=10) then
                local imageA = { type="image", filename=myData.siemR1.src}
                myData.siemR1.fill=imageA
                myData.siemR1.txtb.alpha=1
                myData.siemR1.txt.alpha=1
                myData.siemR1.enabled=1
            end
            if (tonumber(t.fwR1)>=10) then
                local imageA = { type="image", filename=myData.ipsR1.src}
                myData.ipsR1.fill=imageA
                myData.ipsR1.txtb.alpha=1
                myData.ipsR1.txt.alpha=1
                myData.ipsR1.enabled=1
            end
            if (tonumber(t.fwR1)>=100) then
                local imageA = { type="image", filename=myData.fwR2.src}
                myData.fwR2.fill=imageA
                myData.fwR2.txtb.alpha=1
                myData.fwR2.txt.alpha=1
                myData.fwR2.enabled=1
            end
        end

        rSecondsLeft=tonumber(t.secondsLeft)
        if (rSecondsLeft<=0) then
        	myData.noResearchText.alpha=1
        	myData.researchText.alpha=0
        	myData.researchProgressView.alpha=0
        	myData.researchTimer.alpha=0
        	canResearch=true
        else
        	canResearch=false
        	myData.noResearchText.alpha=0
        	myData.researchText.alpha=1
        	myData.researchProgressView.alpha=1
        	myData.researchTimer.alpha=1
        	myData.researchText.text=myData[t.current_r].name.." Lvl "..t.current_l
        	myData.researchTimer.text=timeText(rSecondsLeft)
	        local percent=((t.duration-rSecondsLeft)/t.duration)
	        myData.researchProgressView:setProgress( percent )
	        if (researchCountdownTimer) then
	            timer.cancel(researchCountdownTimer)
	        end

	        researchCountdownTimer = timer.performWithDelay( 1000, updateResearchTimer, 10000000 )
            if (researchNotificationActive==true) then
                if (notificationGlobalResearch) then 
                    notifications.cancelNotification(notificationGlobalResearch) 
                    notificationGlobalResearch=nil
                end
                --notifications.cancelNotification()
                local utcTime = os.date( "!*t", os.time() + rSecondsLeft )
                notificationActive.research=utcTime
                notificationActive.researchTime=os.date(os.time() + rSecondsLeft)
                loadsave.saveTable( notificationActive, "localNotificationStatus.json" )
                setNewNotifications()
            end
        end
  		upgradeRTClicked = 0
   end
end

updateResearchTimer = function()
    if (rSecondsLeft >= 1) then
        rSecondsLeft = rSecondsLeft - 1
        myData.researchTimer.text=timeText(rSecondsLeft)
    else
        if (researchCountdownTimer) then
            timer.cancel(researchCountdownTimer)
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRT.php", "POST", RTnetworkListener, params )
    end
end

local function upgradeRTListener( event )
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
        if ( t.status == "MAX_LVL") then
            myData.infoTextRT.text =  myData.lastSelectedUpgrade  .. "\nLevel: 100/100 - Maximum level reached"
            myData.upgradeRTButton.alpha=0
        elseif ( t.status == "NO_MONEY") then
        	local alert = native.showAlert( "EliteHax", "Oops.. It seems you don't have enough money...", { "Ok" } )
        elseif ( t.status == "AR") then
        	local alert = native.showAlert( "EliteHax", "You already have a research running!", { "Ok" } )
        elseif ( t.status == "OK") then
        	myData.upgradeRTButton.alpha = 0
            if (t.new_lvl == 100) then 
                myData.infoTextRT.text = myData.lastSelectedUpgrade .. "\nLevel: 100/100 - Maximum level reached"
            end
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRT.php", "POST", RTnetworkListener, params )
    end
end

local function upgradeRT( event )
    if ((upgradeRTClicked == 0) and (event.phase == "ended")) then
        print("Researching "..myData.toUpgradeRT)
        upgradeRTClicked = 1  
        canResearch=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type="..myData.toUpgradeRT
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."upgradeRT.php", "POST", upgradeRTListener, params )
    end
end

local function hidePanel(event)
    myData.infoPanelRT.alpha = 0
    myData.upgradeRTButton.alpha = 0
    myData.infoTextRT.text = ""
    myData.infoTextRT2.text = ""
    myData.lastSelectedUpgrade = ""
    myData.toUpgradeRT = ""
end

-- Function to handle tab button events
local function handleTabBarEvent( event )
    if (event.target.id == "general") then
        tapSound()
        view = "general"
        --loaded=false
        group1.alpha=1
        group2.alpha=0
        group3.alpha=0
        hidePanel()
        local imageA = { type="image", filename="img/research_tree_2.png" }
        myData.st_bg.fill = imageA
        changeImgColor(myData.st_bg)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRT.php", "POST", RTnetworkListener, params )
    elseif (event.target.id == "attack") then
        tapSound()
        view = "attack"
        local imageA = { type="image", filename="img/research_tree_3.png" }
        myData.st_bg.fill = imageA
        changeImgColor(myData.st_bg)
        group1.alpha=0
        group2.alpha=1
        group3.alpha=0
        hidePanel()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRT.php", "POST", RTnetworkListener, params )
    elseif (event.target.id == "defense") then
        tapSound()
        view = "defense"
        local imageA = { type="image", filename="img/research_tree_1.png" }
        myData.st_bg.fill = imageA
        changeImgColor(myData.st_bg)
        group1.alpha=0
        group2.alpha=0
        group3.alpha=1
        hidePanel()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRT.php", "POST", RTnetworkListener, params )
    end
end

function goBackRC(event)
    if (tutOverlay==false) then
        backSound()
        composer.removeScene( "researchScene" )
        composer.gotoScene("upgradeScene", {effect = "fade", time = 100})
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function researchScene:create(event)
    group = self.view

    loginInfo = localToken()

    iconSize=fontSize(190)

    upgradeRTClicked=0
    canResearch=false

    --Top Money/Name Background
    myData.top_backgroundST = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_backgroundST.anchorX = 0.5
    myData.top_backgroundST.anchorY = 0
    myData.top_backgroundST.x, myData.top_backgroundST.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_backgroundST)

    --Money
    myData.moneyTextRC = display.newText("",115,myData.top_backgroundST.y+myData.top_backgroundST.height/2,native.systemFont, fontSize(48))
    myData.moneyTextRC.anchorX = 0
    myData.moneyTextRC.anchorY = 0.5
    myData.moneyTextRC:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextRC = display.newText("",display.contentWidth-250,myData.top_backgroundST.y+myData.top_backgroundST.height/2,native.systemFont, fontSize(48))
    myData.playerTextRC.anchorX = 0.5
    myData.playerTextRC.anchorY = 0.5
    myData.playerTextRC:setFillColor( 0.9,0.9,0.9 )

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
        label = "General",
        id = "general",
        selected = true,
        size = fontSize(50),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    },
    {
        defaultFrame = 5,
        overFrame = 6,
        label = "Attack",
        id = "attack",
        size = fontSize(50),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    },
    {
        defaultFrame = 5,
        overFrame = 6,
        label = "Defense",
        id = "defense",
        size = fontSize(50),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    }
}
view = "general" 
    -- Create the widget
    myData.researchTabBar = widget.newTabBar(
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
            tabSelectedFrameWidth = 40,
            tabSelectedFrameHeight = 120,
            buttons = tabButtons
        }
    )
    myData.researchTabBar.anchorX=0.5
    myData.researchTabBar.anchorY=0
    myData.researchTabBar.x,myData.researchTabBar.y=display.contentWidth/2,myData.top_background.y+myData.top_background.height

    --Skill Tree Rectangle
    myData.st_rect = display.newImageRect( "img/leaderboard_rect.png",display.contentWidth-20, fontSize(1580))
    myData.st_rect.anchorX = 0.5
    myData.st_rect.anchorY = 0
    myData.st_rect.x, myData.st_rect.y = display.contentWidth/2,myData.researchTabBar.y+myData.researchTabBar.height-fontSize(22)
    changeImgColor(myData.st_rect)

    myData.st_bg = display.newImageRect( "img/research_tree_2.png",1000, fontSize(1300))
    myData.st_bg.anchorX = 0.5
    myData.st_bg.anchorY = 0
    myData.st_bg.x, myData.st_bg.y = display.contentWidth/2,myData.st_rect.y+fontSize(70)
    changeImgColor(myData.st_bg)

    -- General Researches --
    myData.coolR1 = display.newImageRect( "img/r_coolR1.png",iconSize, iconSize)
    myData.coolR1.anchorX = 0.5
    myData.coolR1.anchorY = 0
    myData.coolR1.x, myData.coolR1.y = display.contentWidth/2,myData.st_bg.y+fontSize(10)
    myData.coolR1.name="Liquid Cooling"
    myData.coolR1.src="img/r_coolR1.png"
    myData.coolR1.srch="img/r_coolR1_hidden.png"
    myData.coolR1.enabled=true
    myData.coolR1.toUpgradeRT="coolR1"
    myData.coolR1.desc="Liquid Cooling increase the effect of your Cooling System.\n\nEffect: Overclock +30s\nResearch Duration: 1h\nCost: 1M\n"
    myData.coolR1.lvl = 0
    myData.coolR1.txtb = display.newRoundedRect(myData.coolR1.x,myData.coolR1.y+myData.coolR1.height/2,120,fontSize(52),12)
    myData.coolR1.txtb.anchorX=0.5
    myData.coolR1.txtb.anchorY=1
    myData.coolR1.txtb.strokeWidth = 5
    myData.coolR1.txtb:setFillColor( 0,0,0 )
    myData.coolR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.coolR1.txt = display.newText(myData.coolR1.lvl.."/100",myData.coolR1.txtb.x,myData.coolR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.coolR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    myData.missionR1 = display.newImageRect( "img/r_missionR1_hidden.png",iconSize, iconSize)
    myData.missionR1.anchorX = 0.5
    myData.missionR1.anchorY = 0
    myData.missionR1.x, myData.missionR1.y = display.contentWidth/4+18,myData.coolR1.y+myData.coolR1.height+fontSize(78)
    myData.missionR1.name="Project Management"
    myData.missionR1.src="img/r_missionR1.png"
    myData.missionR1.srch="img/r_missionR1_hidden.png"
    myData.missionR1.enabled=false
    myData.missionR1.toUpgradeRT="missionR1"
    myData.missionR1.desc="Project Management increases your Missions speed.\n\nEffect: Mission Duration -0,2%\nResearch Duration: 1h\nCost: 1M\n"
    myData.missionR1.req="Requires Liquid Cooling Level 10\n"
    myData.missionR1.lvl = 0
    myData.missionR1.txtb = display.newRoundedRect(myData.missionR1.x,myData.missionR1.y+myData.missionR1.height/2,120,fontSize(52),12)
    myData.missionR1.txtb.anchorX=0.5
    myData.missionR1.txtb.anchorY=1
    myData.missionR1.txtb.strokeWidth = 5
    myData.missionR1.txtb:setFillColor( 0,0,0 )
    myData.missionR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.missionR1.txtb.alpha=0
    myData.missionR1.txt = display.newText(myData.missionR1.lvl.."/100",myData.missionR1.txtb.x,myData.missionR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.missionR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.missionR1.txt.alpha=0

    myData.missionR3 = display.newImageRect( "img/r_missionR3_hidden.png",iconSize, iconSize)
    myData.missionR3.anchorX = 0.5
    myData.missionR3.anchorY = 0
    myData.missionR3.x, myData.missionR3.y = myData.coolR1.x,myData.missionR1.y+myData.missionR1.height/2+fontSize(20)
    myData.missionR3.name="Experiencer"
    myData.missionR3.src="img/r_missionR3.png"
    myData.missionR3.srch="img/r_missionR3_hidden.png"
    myData.missionR3.enabled=false
    myData.missionR3.toUpgradeRT="missionR3"
    myData.missionR3.desc="Experiencer increases Missions XP rewards.\n\nEffect: Mission XP +0,5%\nResearch Duration: 3h\nCost: 10M\n"
    myData.missionR3.req="Requires Project Management Level 50 and Negotiation Strategies Level 50\n"
    myData.missionR3.lvl = 0
    myData.missionR3.txtb = display.newRoundedRect(myData.missionR3.x,myData.missionR3.y+myData.missionR3.height/2,120,fontSize(52),12)
    myData.missionR3.txtb.anchorX=0.5
    myData.missionR3.txtb.anchorY=1
    myData.missionR3.txtb.strokeWidth = 5
    myData.missionR3.txtb:setFillColor( 0,0,0 )
    myData.missionR3.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.missionR3.txtb.alpha=0
    myData.missionR3.txt = display.newText(myData.missionR3.lvl.."/100",myData.missionR3.txtb.x,myData.missionR3.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.missionR3.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.missionR3.txt.alpha=0

    myData.missionR2 = display.newImageRect( "img/r_missionR2_hidden.png",iconSize, iconSize)
    myData.missionR2.anchorX = 0.5
    myData.missionR2.anchorY = 0
    myData.missionR2.x, myData.missionR2.y = display.contentWidth/4*3-20,myData.missionR1.y
    myData.missionR2.name="Negotiation Strategies"
    myData.missionR2.src="img/r_missionR2.png"
    myData.missionR2.srch="img/r_missionR2_hidden.png"
    myData.missionR2.enabled=false
    myData.missionR2.toUpgradeRT="missionR2"
    myData.missionR2.desc="Negotiation Strategies increases your Missions money rewards.\n\nEffect: Mission Money Reward +0,2%\nResearch Duration: 1h\nCost: 1M\n"
    myData.missionR2.req="Requires Liquid Cooling Level 10\n"
    myData.missionR2.lvl = 0
    myData.missionR2.txtb = display.newRoundedRect(myData.missionR2.x,myData.missionR2.y+myData.missionR2.height/2,120,fontSize(52),12)
    myData.missionR2.txtb.anchorX=0.5
    myData.missionR2.txtb.anchorY=1
    myData.missionR2.txtb.strokeWidth = 5
    myData.missionR2.txtb:setFillColor( 0,0,0 )
    myData.missionR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.missionR2.txtb.alpha=0
    myData.missionR2.txt = display.newText(myData.missionR2.lvl.."/100",myData.missionR2.txtb.x,myData.missionR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.missionR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.missionR2.txt.alpha=0

    myData.upgradeR1 = display.newImageRect( "img/r_upgradeR1_hidden.png",iconSize, iconSize)
    myData.upgradeR1.anchorX = 0.5
    myData.upgradeR1.anchorY = 0
    myData.upgradeR1.x, myData.upgradeR1.y = myData.missionR1.x,myData.missionR2.y+myData.missionR2.height+fontSize(70)
    myData.upgradeR1.name="Sales Psychology"
    myData.upgradeR1.src="img/r_upgradeR1.png"
    myData.upgradeR1.srch="img/r_upgradeR1_hidden.png"
    myData.upgradeR1.enabled=false
    myData.upgradeR1.toUpgradeRT="upgradeR1"
    myData.upgradeR1.desc="Sales Psychology decreases all your upgrades costs.\n\nEffect: Upgrades Cost -0,2%\nResearch Duration: 1h\nCost: 1M\n"
    myData.upgradeR1.req="Requires Project Management Level 10\n"
    myData.upgradeR1.lvl = 0
    myData.upgradeR1.txtb = display.newRoundedRect(myData.upgradeR1.x,myData.upgradeR1.y+myData.upgradeR1.height/2,120,fontSize(52),12)
    myData.upgradeR1.txtb.anchorX=0.5
    myData.upgradeR1.txtb.anchorY=1
    myData.upgradeR1.txtb.strokeWidth = 5
    myData.upgradeR1.txtb:setFillColor( 0,0,0 )
    myData.upgradeR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.upgradeR1.txtb.alpha=0
    myData.upgradeR1.txt = display.newText(myData.upgradeR1.lvl.."/100",myData.upgradeR1.txtb.x,myData.upgradeR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.upgradeR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.upgradeR1.txt.alpha=0

    myData.upgradeR2 = display.newImageRect( "img/r_upgradeR2_hidden.png",iconSize, iconSize)
    myData.upgradeR2.anchorX = 0.5
    myData.upgradeR2.anchorY = 0
    myData.upgradeR2.x, myData.upgradeR2.y = myData.missionR2.x,myData.upgradeR1.y
    myData.upgradeR2.name="Deployment Strategies"
    myData.upgradeR2.src="img/r_upgradeR2.png"
    myData.upgradeR2.srch="img/r_upgradeR2_hidden.png"
    myData.upgradeR2.enabled=false
    myData.upgradeR2.toUpgradeRT="upgradeR2"
    myData.upgradeR2.desc="Deployment Strategies decreases all your upgrades duration.\n\nEffect: Upgrades Duration -0,2%\nResearch Duration: 1h\nCost: 1M\n"
    myData.upgradeR2.req="Requires Negotiation Strategies Level 10\n"
    myData.upgradeR2.lvl = 0
    myData.upgradeR2.txtb = display.newRoundedRect(myData.upgradeR2.x,myData.upgradeR2.y+myData.upgradeR2.height/2,120,fontSize(52),12)
    myData.upgradeR2.txtb.anchorX=0.5
    myData.upgradeR2.txtb.anchorY=1
    myData.upgradeR2.txtb.strokeWidth = 5
    myData.upgradeR2.txtb:setFillColor( 0,0,0 )
    myData.upgradeR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.upgradeR2.txtb.alpha=0
    myData.upgradeR2.txt = display.newText(myData.upgradeR2.lvl.."/100",myData.upgradeR2.txtb.x,myData.upgradeR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.upgradeR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.upgradeR2.txt.alpha=0

    ------------------------------------------------------------------------------

    -- Attacking Researches --
    myData.botR1 = display.newImageRect( "img/r_botR1.png",iconSize, iconSize)
    myData.botR1.anchorX = 0.5
    myData.botR1.anchorY = 0
    myData.botR1.x, myData.botR1.y = display.contentWidth/2,myData.st_bg.y+fontSize(10)
    myData.botR1.name="Bot Clustering"
    myData.botR1.src="img/r_botR1.png"
    myData.botR1.srch="img/r_botR1_hidden.png"
    myData.botR1.enabled=true
    myData.botR1.toUpgradeRT="botR1"
    myData.botR1.desc="Bot Clustering enhances the effect of your Bot Malware.\n\nEffect: Bot Income +0,2%\nResearch Duration: 1h\nCost: 1M\n"
    myData.botR1.lvl = 0
    myData.botR1.txtb = display.newRoundedRect(myData.botR1.x,myData.botR1.y+myData.botR1.height/2,120,fontSize(52),12)
    myData.botR1.txtb.anchorX=0.5
    myData.botR1.txtb.anchorY=1
    myData.botR1.txtb.strokeWidth = 5
    myData.botR1.txtb:setFillColor( 0,0,0 )
    myData.botR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.botR1.txt = display.newText(myData.botR1.lvl.."/100",myData.botR1.txtb.x,myData.botR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.botR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    myData.scannerR1 = display.newImageRect( "img/r_scannerR1_hidden.png",iconSize, iconSize)
    myData.scannerR1.anchorX = 0.5
    myData.scannerR1.anchorY = 0
    myData.scannerR1.x, myData.scannerR1.y = display.contentWidth/4+18,myData.botR1.y+myData.botR1.height+fontSize(78)
    myData.scannerR1.name="Fingerprinting Techniques"
    myData.scannerR1.src="img/r_scannerR1.png"
    myData.scannerR1.srch="img/r_scannerR1_hidden.png"
    myData.scannerR1.enabled=false
    myData.scannerR1.toUpgradeRT="scannerR1"
    myData.scannerR1.desc="Fingerprinting Techniques increases the efficacy of your Scanner.\n\nEffect: Scanner +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.scannerR1.req="Requires Bot Clustering Level 10\n"
    myData.scannerR1.lvl = 0
    myData.scannerR1.txtb = display.newRoundedRect(myData.scannerR1.x,myData.scannerR1.y+myData.scannerR1.height/2,120,fontSize(52),12)
    myData.scannerR1.txtb.anchorX=0.5
    myData.scannerR1.txtb.anchorY=1
    myData.scannerR1.txtb.strokeWidth = 5
    myData.scannerR1.txtb:setFillColor( 0,0,0 )
    myData.scannerR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.scannerR1.txtb.alpha=0
    myData.scannerR1.txt = display.newText(myData.scannerR1.lvl.."/100",myData.scannerR1.txtb.x,myData.scannerR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.scannerR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.scannerR1.txt.alpha=0

    myData.anonR1 = display.newImageRect( "img/r_anonR1_hidden.png",iconSize, iconSize)
    myData.anonR1.anchorX = 0.5
    myData.anonR1.anchorY = 0
    myData.anonR1.x, myData.anonR1.y = display.contentWidth/4*3-20,myData.scannerR1.y
    myData.anonR1.name="Proxychains"
    myData.anonR1.src="img/r_anonR1.png"
    myData.anonR1.srch="img/r_anonR1_hidden.png"
    myData.anonR1.enabled=false
    myData.anonR1.toUpgradeRT="anonR1"
    myData.anonR1.desc="Proxychains research enhances the efficacy of your Anonymizer.\n\nEffect: Anonymizer +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.anonR1.req="Requires Bot Clustering Level 10\n"
    myData.anonR1.lvl = 0
    myData.anonR1.txtb = display.newRoundedRect(myData.anonR1.x,myData.anonR1.y+myData.anonR1.height/2,120,fontSize(52),12)
    myData.anonR1.txtb.anchorX=0.5
    myData.anonR1.txtb.anchorY=1
    myData.anonR1.txtb.strokeWidth = 5
    myData.anonR1.txtb:setFillColor( 0,0,0 )
    myData.anonR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.anonR1.txtb.alpha=0
    myData.anonR1.txt = display.newText(myData.anonR1.lvl.."/100",myData.anonR1.txtb.x,myData.anonR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.anonR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.anonR1.txt.alpha=0

    myData.scannerR2 = display.newImageRect( "img/r_scannerR2_hidden.png",iconSize, iconSize)
    myData.scannerR2.anchorX = 0.5
    myData.scannerR2.anchorY = 0
    myData.scannerR2.x, myData.scannerR2.y = display.contentWidth/8*3+20,myData.anonR1.y+myData.anonR1.height+fontSize(70)
    myData.scannerR2.name="Vulnerability Database"
    myData.scannerR2.src="img/r_scannerR2.png"
    myData.scannerR2.srch="img/r_scannerR2_hidden.png"
    myData.scannerR2.enabled=false
    myData.scannerR2.toUpgradeRT="scannerR2"
    myData.scannerR2.desc="Vulnerability Scanner research greatly increases the efficacy of your Scanner.\n\nEffect: Scanner +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.scannerR2.req="Requires Fingerprinting Techniques Level 100\n"
    myData.scannerR2.lvl = 0
    myData.scannerR2.txtb = display.newRoundedRect(myData.scannerR2.x,myData.scannerR2.y+myData.scannerR2.height/2,120,fontSize(52),12)
    myData.scannerR2.txtb.anchorX=0.5
    myData.scannerR2.txtb.anchorY=1
    myData.scannerR2.txtb.strokeWidth = 5
    myData.scannerR2.txtb:setFillColor( 0,0,0 )
    myData.scannerR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.scannerR2.txtb.alpha=0
    myData.scannerR2.txt = display.newText(myData.scannerR2.lvl.."/100",myData.scannerR2.txtb.x,myData.scannerR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.scannerR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.scannerR2.txt.alpha=0

    myData.exploitR1 = display.newImageRect( "img/r_exploitR1_hidden.png",iconSize, iconSize)
    myData.exploitR1.anchorX = 0.5
    myData.exploitR1.anchorY = 0
    myData.exploitR1.x, myData.exploitR1.y = display.contentWidth/8+20,myData.scannerR2.y
    myData.exploitR1.name="Custom Payload"
    myData.exploitR1.src="img/r_exploitR1.png"
    myData.exploitR1.srch="img/r_exploitR1_hidden.png"
    myData.exploitR1.enabled=false
    myData.exploitR1.toUpgradeRT="exploitR1"
    myData.exploitR1.desc="Custom Payload research increases the efficacy of your Exploit Framework.\n\nEffect: Exploit Framework +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.exploitR1.req="Requires Fingerprinting Techniques Level 10\n"
    myData.exploitR1.lvl = 0
    myData.exploitR1.txtb = display.newRoundedRect(myData.exploitR1.x,myData.exploitR1.y+myData.exploitR1.height/2,120,fontSize(52),12)
    myData.exploitR1.txtb.anchorX=0.5
    myData.exploitR1.txtb.anchorY=1
    myData.exploitR1.txtb.strokeWidth = 5
    myData.exploitR1.txtb:setFillColor( 0,0,0 )
    myData.exploitR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.exploitR1.txtb.alpha=0
    myData.exploitR1.txt = display.newText(myData.exploitR1.lvl.."/100",myData.exploitR1.txtb.x,myData.exploitR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.exploitR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.exploitR1.txt.alpha=0

    myData.malwareR1 = display.newImageRect( "img/r_malwareR1_hidden.png",iconSize, iconSize)
    myData.malwareR1.anchorX = 0.5
    myData.malwareR1.anchorY = 0
    myData.malwareR1.x, myData.malwareR1.y = display.contentWidth/8*7-20,myData.scannerR2.y
    myData.malwareR1.name="Malware Coding"
    myData.malwareR1.src="img/r_malwareR1.png"
    myData.malwareR1.srch="img/r_malwareR1_hidden.png"
    myData.malwareR1.enabled=false
    myData.malwareR1.toUpgradeRT="malwareR1"
    myData.malwareR1.desc="Malware Coding research improves your Malware Framework.\n\nEffect: Malware Framework +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.malwareR1.req="Requires Proxychains Level 10\n"
    myData.malwareR1.lvl = 0
    myData.malwareR1.txtb = display.newRoundedRect(myData.malwareR1.x,myData.malwareR1.y+myData.malwareR1.height/2,120,fontSize(52),12)
    myData.malwareR1.txtb.anchorX=0.5
    myData.malwareR1.txtb.anchorY=1
    myData.malwareR1.txtb.strokeWidth = 5
    myData.malwareR1.txtb:setFillColor( 0,0,0 )
    myData.malwareR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.malwareR1.txtb.alpha=0
    myData.malwareR1.txt = display.newText(myData.malwareR1.lvl.."/100",myData.malwareR1.txtb.x,myData.malwareR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.malwareR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.malwareR1.txt.alpha=0

    myData.anonR2 = display.newImageRect( "img/r_anonR2_hidden.png",iconSize, iconSize)
    myData.anonR2.anchorX = 0.5
    myData.anonR2.anchorY = 0
    myData.anonR2.x, myData.anonR2.y = display.contentWidth/8*5-20,myData.scannerR2.y
    myData.anonR2.name="Custom Encryption"
    myData.anonR2.src="img/r_anonR2.png"
    myData.anonR2.srch="img/r_anonR2_hidden.png"
    myData.anonR2.enabled=false
    myData.anonR2.toUpgradeRT="anonR2"
    myData.anonR2.desc="Custom Encryption greatly improves the efficacy of your Anonymizer.\n\nEffect: Anonymizer +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.anonR2.req="Requires Proxychains Level 100\n"
    myData.anonR2.lvl = 0
    myData.anonR2.txtb = display.newRoundedRect(myData.anonR2.x,myData.anonR2.y+myData.anonR2.height/2,120,fontSize(52),12)
    myData.anonR2.txtb.anchorX=0.5
    myData.anonR2.txtb.anchorY=1
    myData.anonR2.txtb.strokeWidth = 5
    myData.anonR2.txtb:setFillColor( 0,0,0 )
    myData.anonR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.anonR2.txtb.alpha=0
    myData.anonR2.txt = display.newText(myData.anonR2.lvl.."/100",myData.anonR2.txtb.x,myData.anonR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.anonR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.anonR2.txt.alpha=0

    myData.exploitR2 = display.newImageRect( "img/r_exploitR2_hidden.png",iconSize, iconSize)
    myData.exploitR2.anchorX = 0.5
    myData.exploitR2.anchorY = 0
    myData.exploitR2.x, myData.exploitR2.y = display.contentWidth/8+20,myData.scannerR2.y+myData.scannerR2.height+fontSize(70)
    myData.exploitR2.name="Shellcoding"
    myData.exploitR2.src="img/r_exploitR2.png"
    myData.exploitR2.srch="img/r_exploitR2_hidden.png"
    myData.exploitR2.enabled=false
    myData.exploitR2.toUpgradeRT="exploitR2"
    myData.exploitR2.desc="Shellcoding research greatly enhances the effect of your Exploit Framework.\n\nEffect: Exploit Framework +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.exploitR2.req="Requires Custom Payload Level 100\n"
    myData.exploitR2.lvl = 0
    myData.exploitR2.txtb = display.newRoundedRect(myData.exploitR2.x,myData.exploitR2.y+myData.exploitR2.height/2,120,fontSize(52),12)
    myData.exploitR2.txtb.anchorX=0.5
    myData.exploitR2.txtb.anchorY=1
    myData.exploitR2.txtb.strokeWidth = 5
    myData.exploitR2.txtb:setFillColor( 0,0,0 )
    myData.exploitR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.exploitR2.txtb.alpha=0
    myData.exploitR2.txt = display.newText(myData.exploitR2.lvl.."/100",myData.exploitR2.txtb.x,myData.exploitR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.exploitR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.exploitR2.txt.alpha=0

    myData.malwareR2 = display.newImageRect( "img/r_malwareR2_hidden.png",iconSize, iconSize)
    myData.malwareR2.anchorX = 0.5
    myData.malwareR2.anchorY = 0
    myData.malwareR2.x, myData.malwareR2.y = display.contentWidth/8*7-20,myData.exploitR2.y
    myData.malwareR2.name="APT"
    myData.malwareR2.src="img/r_malwareR2.png"
    myData.malwareR2.srch="img/r_malwareR2_hidden.png"
    myData.malwareR2.enabled=false
    myData.malwareR2.toUpgradeRT="malwareR2"
    myData.malwareR2.desc="APT research greatly enhances the efficacy of your Malware Framework.\n\nEffect: Malware Framework +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.malwareR2.req="Requires Malware Coding Level 100\n"
    myData.malwareR2.lvl = 0
    myData.malwareR2.txtb = display.newRoundedRect(myData.malwareR2.x,myData.malwareR2.y+myData.malwareR2.height/2,120,fontSize(52),12)
    myData.malwareR2.txtb.anchorX=0.5
    myData.malwareR2.txtb.anchorY=1
    myData.malwareR2.txtb.strokeWidth = 5
    myData.malwareR2.txtb:setFillColor( 0,0,0 )
    myData.malwareR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.malwareR2.txtb.alpha=0
    myData.malwareR2.txt = display.newText(myData.malwareR2.lvl.."/100",myData.malwareR2.txtb.x,myData.malwareR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.malwareR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.malwareR2.txt.alpha=0

    ------------------------------------------------------------------------

    -- Defending Researches --
    myData.fwR1 = display.newImageRect( "img/r_fwR1.png",iconSize, iconSize)
    myData.fwR1.anchorX = 0.5
    myData.fwR1.anchorY = 0
    myData.fwR1.x, myData.fwR1.y = display.contentWidth/2,myData.st_bg.y+fontSize(10)
    myData.fwR1.name="Unifed Threat Management"
    myData.fwR1.src="img/r_fwR1.png"
    myData.fwR1.srch="img/r_fwR1_hidden.png"
    myData.fwR1.enabled=true
    myData.fwR1.toUpgradeRT="fwR1"
    myData.fwR1.desc="Unifed Threat Management (UTM) increases the effect of your firewall.\n\nEffect: Firewall +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.fwR1.lvl = 0
    myData.fwR1.txtb = display.newRoundedRect(myData.fwR1.x,myData.fwR1.y+myData.fwR1.height/2,120,fontSize(52),12)
    myData.fwR1.txtb.anchorX=0.5
    myData.fwR1.txtb.anchorY=1
    myData.fwR1.txtb.strokeWidth = 5
    myData.fwR1.txtb:setFillColor( 0,0,0 )
    myData.fwR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.fwR1.txt = display.newText(myData.fwR1.lvl.."/100",myData.fwR1.txtb.x,myData.fwR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.fwR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

    myData.siemR1 = display.newImageRect( "img/r_siemR1_hidden.png",iconSize, iconSize)
    myData.siemR1.anchorX = 0.5
    myData.siemR1.anchorY = 0
    myData.siemR1.x, myData.siemR1.y = display.contentWidth/4+18,myData.fwR1.y+myData.fwR1.height+fontSize(78)
    myData.siemR1.name="Correlation Rules"
    myData.siemR1.src="img/r_siemR1.png"
    myData.siemR1.srch="img/r_siemR1_hidden.png"
    myData.siemR1.enabled=false
    myData.siemR1.toUpgradeRT="siemR1"
    myData.siemR1.desc="Correlation Rules research enhances the efficacy of your SIEM.\n\nEffect: SIEM +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.siemR1.req="Requires Unifed Threat Management Level 10\n"
    myData.siemR1.lvl = 0
    myData.siemR1.txtb = display.newRoundedRect(myData.siemR1.x,myData.siemR1.y+myData.siemR1.height/2,120,fontSize(52),12)
    myData.siemR1.txtb.anchorX=0.5
    myData.siemR1.txtb.anchorY=1
    myData.siemR1.txtb.strokeWidth = 5
    myData.siemR1.txtb:setFillColor( 0,0,0 )
    myData.siemR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.siemR1.txtb.alpha=0
    myData.siemR1.txt = display.newText(myData.siemR1.lvl.."/100",myData.siemR1.txtb.x,myData.siemR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.siemR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.siemR1.txt.alpha=0

    myData.fwR2 = display.newImageRect( "img/r_fwR2_hidden.png",iconSize, iconSize)
    myData.fwR2.anchorX = 0.5
    myData.fwR2.anchorY = 0
    myData.fwR2.x, myData.fwR2.y = myData.fwR1.x,myData.siemR1.y
    myData.fwR2.name="Next Generation Firewall"
    myData.fwR2.src="img/r_fwR2.png"
    myData.fwR2.srch="img/r_fwR2_hidden.png"
    myData.fwR2.enabled=false
    myData.fwR2.toUpgradeRT="fwR2"
    myData.fwR2.desc="Next Generation Firewall (NGFW) greatly increases the effect of your firewall.\n\nEffect: Firewall +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.fwR2.req="Requires Unifed Threat Management Level 100\n"
    myData.fwR2.lvl = 0
    myData.fwR2.txtb = display.newRoundedRect(myData.fwR2.x,myData.fwR2.y+myData.fwR2.height/2,120,fontSize(52),12)
    myData.fwR2.txtb.anchorX=0.5
    myData.fwR2.txtb.anchorY=1
    myData.fwR2.txtb.strokeWidth = 5
    myData.fwR2.txtb:setFillColor( 0,0,0 )
    myData.fwR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.fwR2.txtb.alpha=0
    myData.fwR2.txt = display.newText(myData.fwR2.lvl.."/100",myData.fwR2.txtb.x,myData.fwR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.fwR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fwR2.txt.alpha=0

    myData.ipsR1 = display.newImageRect( "img/r_ipsR1_hidden.png",iconSize, iconSize)
    myData.ipsR1.anchorX = 0.5
    myData.ipsR1.anchorY = 0
    myData.ipsR1.x, myData.ipsR1.y = display.contentWidth/4*3-20,myData.siemR1.y
    myData.ipsR1.name="Anomaly Detection"
    myData.ipsR1.src="img/r_ipsR1.png"
    myData.ipsR1.srch="img/r_ipsR1_hidden.png"
    myData.ipsR1.enabled=false
    myData.ipsR1.toUpgradeRT="ipsR1"
    myData.ipsR1.desc="Anomaly Detection increases the effect of your IPS.\n\nEffect: IPS +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.ipsR1.req="Requires Unifed Threat Management Level 10\n"
    myData.ipsR1.lvl = 0
    myData.ipsR1.txtb = display.newRoundedRect(myData.ipsR1.x,myData.ipsR1.y+myData.ipsR1.height/2,120,fontSize(52),12)
    myData.ipsR1.txtb.anchorX=0.5
    myData.ipsR1.txtb.anchorY=1
    myData.ipsR1.txtb.strokeWidth = 5
    myData.ipsR1.txtb:setFillColor( 0,0,0 )
    myData.ipsR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.ipsR1.txtb.alpha=0
    myData.ipsR1.txt = display.newText(myData.ipsR1.lvl.."/100",myData.ipsR1.txtb.x,myData.ipsR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.ipsR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.ipsR1.txt.alpha=0

    myData.siemR2 = display.newImageRect( "img/r_siemR2_hidden.png",iconSize, iconSize)
    myData.siemR2.anchorX = 0.5
    myData.siemR2.anchorY = 0
    myData.siemR2.x, myData.siemR2.y = display.contentWidth/8*3+20,myData.ipsR1.y+myData.ipsR1.height+fontSize(70)
    myData.siemR2.name="Machine Learning"
    myData.siemR2.src="img/r_siemR2.png"
    myData.siemR2.srch="img/r_siemR2_hidden.png"
    myData.siemR2.enabled=false
    myData.siemR2.toUpgradeRT="siemR2"
    myData.siemR2.desc="Machine Learning greatly enhances the efficacy of your SIEM.\n\nEffect: SIEM +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.siemR2.req="Requires Correlation Rules Level 100\n"
    myData.siemR2.lvl = 0
    myData.siemR2.txtb = display.newRoundedRect(myData.siemR2.x,myData.siemR2.y+myData.siemR2.height/2,120,fontSize(52),12)
    myData.siemR2.txtb.anchorX=0.5
    myData.siemR2.txtb.anchorY=1
    myData.siemR2.txtb.strokeWidth = 5
    myData.siemR2.txtb:setFillColor( 0,0,0 )
    myData.siemR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.siemR2.txtb.alpha=0
    myData.siemR2.txt = display.newText(myData.siemR2.lvl.."/100",myData.siemR2.txtb.x,myData.siemR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.siemR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.siemR2.txt.alpha=0

    myData.avR1 = display.newImageRect( "img/r_avR1_hidden.png",iconSize, iconSize)
    myData.avR1.anchorX = 0.5
    myData.avR1.anchorY = 0
    myData.avR1.x, myData.avR1.y = display.contentWidth/8+20,myData.siemR2.y
    myData.avR1.name="Heuristic"
    myData.avR1.src="img/r_avR1.png"
    myData.avR1.srch="img/r_avR1_hidden.png"
    myData.avR1.enabled=false
    myData.avR1.toUpgradeRT="avR1"
    myData.avR1.desc="Heuristic increases the effect of your Antivirus.\n\nEffect: Antivirus +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.avR1.req="Requires Correlation Rules Level 10\n"
    myData.avR1.lvl = 0
    myData.avR1.txtb = display.newRoundedRect(myData.avR1.x,myData.avR1.y+myData.avR1.height/2,120,fontSize(52),12)
    myData.avR1.txtb.anchorX=0.5
    myData.avR1.txtb.anchorY=1
    myData.avR1.txtb.strokeWidth = 5
    myData.avR1.txtb:setFillColor( 0,0,0 )
    myData.avR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.avR1.txtb.alpha=0
    myData.avR1.txt = display.newText(myData.avR1.lvl.."/100",myData.avR1.txtb.x,myData.avR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.avR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.avR1.txt.alpha=0

    myData.progR1 = display.newImageRect( "img/r_progR1_hidden.png",iconSize, iconSize)
    myData.progR1.anchorX = 0.5
    myData.progR1.anchorY = 0
    myData.progR1.x, myData.progR1.y = display.contentWidth/8*7-20,myData.siemR2.y
    myData.progR1.name="Secure Coding"
    myData.progR1.src="img/r_progR1.png"
    myData.progR1.srch="img/r_progR1_hidden.png"
    myData.progR1.enabled=false
    myData.progR1.toUpgradeRT="progR1"
    myData.progR1.desc="Secure Coding enhances the efficacy of your Web Server, Application Server and Database Server.\n\nEffect: Web/App/DB Server +0,1%\nResearch Duration: 1h\nCost: 1M\n"
    myData.progR1.req="Requires Anomaly Detection Level 10\n"
    myData.progR1.lvl = 0
    myData.progR1.txtb = display.newRoundedRect(myData.progR1.x,myData.progR1.y+myData.progR1.height/2,120,fontSize(52),12)
    myData.progR1.txtb.anchorX=0.5
    myData.progR1.txtb.anchorY=1
    myData.progR1.txtb.strokeWidth = 5
    myData.progR1.txtb:setFillColor( 0,0,0 )
    myData.progR1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.progR1.txtb.alpha=0
    myData.progR1.txt = display.newText(myData.progR1.lvl.."/100",myData.progR1.txtb.x,myData.progR1.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.progR1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.progR1.txt.alpha=0

    myData.ipsR2 = display.newImageRect( "img/r_ipsR2_hidden.png",iconSize, iconSize)
    myData.ipsR2.anchorX = 0.5
    myData.ipsR2.anchorY = 0
    myData.ipsR2.x, myData.ipsR2.y = display.contentWidth/8*5-20,myData.siemR2.y
    myData.ipsR2.name="Threat Intelligence"
    myData.ipsR2.src="img/r_ipsR2.png"
    myData.ipsR2.srch="img/r_ipsR2_hidden.png"
    myData.ipsR2.enabled=false
    myData.ipsR2.toUpgradeRT="ipsR2"
    myData.ipsR2.desc="Threat Intelligence greatly increases the efficacy of your IPS.\n\nEffect: IPS +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.ipsR2.req="Requires Anomaly Detection Level 100\n"
    myData.ipsR2.lvl = 0
    myData.ipsR2.txtb = display.newRoundedRect(myData.ipsR2.x,myData.ipsR2.y+myData.ipsR2.height/2,120,fontSize(52),12)
    myData.ipsR2.txtb.anchorX=0.5
    myData.ipsR2.txtb.anchorY=1
    myData.ipsR2.txtb.strokeWidth = 5
    myData.ipsR2.txtb:setFillColor( 0,0,0 )
    myData.ipsR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.ipsR2.txtb.alpha=0
    myData.ipsR2.txt = display.newText(myData.ipsR2.lvl.."/100",myData.ipsR2.txtb.x,myData.ipsR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.ipsR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.ipsR2.txt.alpha=0

    myData.avR2 = display.newImageRect( "img/r_avR2_hidden.png",iconSize, iconSize)
    myData.avR2.anchorX = 0.5
    myData.avR2.anchorY = 0
    myData.avR2.x, myData.avR2.y = display.contentWidth/8+20,myData.siemR2.y+myData.siemR2.height+fontSize(70)
    myData.avR2.name="Sandboxing"
    myData.avR2.src="img/r_avR2.png"
    myData.avR2.srch="img/r_avR2_hidden.png"
    myData.avR2.enabled=false
    myData.avR2.toUpgradeRT="avR2"
    myData.avR2.desc="Sandboxing greatly increases the efficacy of your Antivirus.\n\nEffect: Antivirus +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.avR2.req="Requires Heuristic Level 100\n"
    myData.avR2.lvl = 0
    myData.avR2.txtb = display.newRoundedRect(myData.avR2.x,myData.avR2.y+myData.avR2.height/2,120,fontSize(52),12)
    myData.avR2.txtb.anchorX=0.5
    myData.avR2.txtb.anchorY=1
    myData.avR2.txtb.strokeWidth = 5
    myData.avR2.txtb:setFillColor( 0,0,0 )
    myData.avR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.avR2.txtb.alpha=0
    myData.avR2.txt = display.newText(myData.avR2.lvl.."/100",myData.avR2.txtb.x,myData.avR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.avR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.avR2.txt.alpha=0

    myData.progR2 = display.newImageRect( "img/r_progR2_hidden.png",iconSize, iconSize)
    myData.progR2.anchorX = 0.5
    myData.progR2.anchorY = 0
    myData.progR2.x, myData.progR2.y = display.contentWidth/8*7-20,myData.avR2.y
    myData.progR2.name="Secure SDLC"
    myData.progR2.src="img/r_progR2.png"
    myData.progR2.srch="img/r_progR2_hidden.png"
    myData.progR2.enabled=false
    myData.progR2.toUpgradeRT="progR2"
    myData.progR2.desc="Secure Software Development Lifecycle greatly increases the efficacy of your Web/App/DB Server.\n\nEffect: Web/App/DB Server +0,2%\nResearch Duration: 2h\nCost: 10M\n"
    myData.progR2.req="Requires Secure Coding Level 100\n"
    myData.progR2.lvl = 0
    myData.progR2.txtb = display.newRoundedRect(myData.progR2.x,myData.progR2.y+myData.progR2.height/2,120,fontSize(52),12)
    myData.progR2.txtb.anchorX=0.5
    myData.progR2.txtb.anchorY=1
    myData.progR2.txtb.strokeWidth = 5
    myData.progR2.txtb:setFillColor( 0,0,0 )
    myData.progR2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.progR2.txtb.alpha=0
    myData.progR2.txt = display.newText(myData.progR2.lvl.."/100",myData.progR2.txtb.x,myData.progR2.txtb.y-fontSize(30),native.systemFont, fontSize(46))
    myData.progR2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.progR2.txt.alpha=0

    ---------------------------------------------------------------------------

    myData.researchRect = display.newImageRect( "img/research_center.png",display.contentWidth-60, fontSize(480))
    myData.researchRect.anchorX = 0.5
    myData.researchRect.anchorY = 0
    myData.researchRect.x, myData.researchRect.y = display.contentWidth/2, myData.progR2.y+myData.progR2.height+fontSize(20)
    changeImgColor(myData.researchRect)

    myData.noResearchText = display.newText("Research Center Ready",display.contentWidth/2,myData.researchRect.y+fontSize(200),native.systemFont, fontSize(72))
    myData.noResearchText.anchorX=0.5
    myData.noResearchText.anchorY=0
    myData.noResearchText.x=display.contentWidth/2
    myData.noResearchText:setFillColor( 1,1,1 )
    myData.noResearchText.alpha=0

    myData.researchText = display.newText("",display.contentWidth/2,myData.researchRect.y+fontSize(150),native.systemFont, fontSize(60))
    myData.researchText.anchorX=0.5
    myData.researchText.anchorY=0
    myData.researchText.x=display.contentWidth/2
    myData.researchText:setFillColor( 1,1,1 )
    myData.researchText.alpha=0

    local options = {
        width = 64,
        height = 64,
        numFrames = 6,
        sheetContentWidth = 384,
        sheetContentHeight = 64
    }
    local progressSheet = graphics.newImageSheet( progressColor, options )
    myData.researchProgressView = widget.newProgressView(
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
            left = myData.researchRect.x-myData.researchRect.width/2+fontSize(40),
            top = myData.researchText.y+myData.researchText.height+fontSize(30),
            width = myData.researchRect.width-80,
            isAnimated = true
        }
    )    
    myData.researchProgressView.alpha=0

    myData.researchTimer = display.newText("",display.contentWidth/2,myData.researchProgressView.y+myData.researchProgressView.height,native.systemFont, fontSize(60))
    myData.researchTimer.anchorX=0.5
    myData.researchTimer.anchorY=0
    myData.researchTimer.x=display.contentWidth/2
    myData.researchTimer:setFillColor( 1,1,1 )
    myData.researchTimer.alpha=0

    myData.infoPanelRT = display.newRoundedRect( 10000, 10000, display.contentWidth-100, fontSize(200), 12 )
    myData.infoPanelRT.anchorX = 0.5
    myData.infoPanelRT.anchorY = 0
    myData.infoPanelRT.strokeWidth = 5
    myData.infoPanelRT:setFillColor( 0,0,0 )
    myData.infoPanelRT:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.infoPanelRT.alpha = 1

    myData.infoTextRT = display.newText("",40,20,myData.infoPanelRT.width-60,0,native.systemFont, fontSize(45))
    myData.infoTextRT.anchorX = 0
    myData.infoTextRT.anchorY = 0
    myData.infoTextRT:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.infoTextRT2 = display.newText("",40,20,myData.infoPanelRT.width-60,0,native.systemFont, fontSize(42))
    myData.infoTextRT2.anchorX = 0
    myData.infoTextRT2.anchorY = 0
    myData.infoTextRT2:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.upgradeRTButton = widget.newButton(
        {
            left = myData.infoPanelRT.width-(iconSize/1.2)-60,
            top = 20,
            width = 300,
            height = fontSize(90),
            defaultFile = buttonColor400,
            fontSize = fontSize(60),
            label = "Research",
            labelColor = { default=textColor1 },
            onEvent = upgradeRT
        })
    myData.upgradeRTButton.alpha = 0
    
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
        labelColor = { default=textColor1 },
        onEvent = goBackRC
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD   
    group1=display.newGroup() 
    group1:insert(myData.coolR1)
    group1:insert(myData.missionR1)
    group1:insert(myData.missionR2)
    group1:insert(myData.upgradeR1)
    group1:insert(myData.upgradeR2)
    group1:insert(myData.missionR3)
    group1:insert(myData.coolR1.txtb)
    group1:insert(myData.missionR1.txtb)
    group1:insert(myData.missionR2.txtb)
    group1:insert(myData.upgradeR1.txtb)
    group1:insert(myData.upgradeR2.txtb)
    group1:insert(myData.missionR3.txtb)
    group1:insert(myData.coolR1.txt)
    group1:insert(myData.missionR1.txt)
    group1:insert(myData.missionR2.txt)
    group1:insert(myData.upgradeR1.txt)
    group1:insert(myData.upgradeR2.txt)
    group1:insert(myData.missionR3.txt)
    group1.alpha=1

    group2=display.newGroup() 
    group2:insert(myData.botR1)
    group2:insert(myData.scannerR1)
    group2:insert(myData.anonR1)
    group2:insert(myData.scannerR2)
    group2:insert(myData.exploitR1)
    group2:insert(myData.malwareR1)
    group2:insert(myData.anonR2)
    group2:insert(myData.exploitR2)
    group2:insert(myData.malwareR2)
    group2:insert(myData.botR1.txtb)
    group2:insert(myData.scannerR1.txtb)
    group2:insert(myData.anonR1.txtb)
    group2:insert(myData.scannerR2.txtb)
    group2:insert(myData.exploitR1.txtb)
    group2:insert(myData.malwareR1.txtb)
    group2:insert(myData.anonR2.txtb)
    group2:insert(myData.exploitR2.txtb)
    group2:insert(myData.malwareR2.txtb)
    group2:insert(myData.botR1.txt)
    group2:insert(myData.scannerR1.txt)
    group2:insert(myData.anonR1.txt)
    group2:insert(myData.scannerR2.txt)
    group2:insert(myData.exploitR1.txt)
    group2:insert(myData.malwareR1.txt)
    group2:insert(myData.anonR2.txt)
    group2:insert(myData.exploitR2.txt)
    group2:insert(myData.malwareR2.txt)
    group2.alpha=0

    group3=display.newGroup() 
    group3:insert(myData.fwR1)
    group3:insert(myData.siemR1)
    group3:insert(myData.ipsR1)
    group3:insert(myData.siemR2)
    group3:insert(myData.avR1)
    group3:insert(myData.progR1)
    group3:insert(myData.ipsR2)
    group3:insert(myData.avR2)
    group3:insert(myData.progR2)
    group3:insert(myData.fwR2)
    group3:insert(myData.fwR1.txtb)
    group3:insert(myData.siemR1.txtb)
    group3:insert(myData.ipsR1.txtb)
    group3:insert(myData.siemR2.txtb)
    group3:insert(myData.avR1.txtb)
    group3:insert(myData.progR1.txtb)
    group3:insert(myData.ipsR2.txtb)
    group3:insert(myData.avR2.txtb)
    group3:insert(myData.progR2.txtb)
    group3:insert(myData.fwR2.txtb)
    group3:insert(myData.fwR1.txt)
    group3:insert(myData.siemR1.txt)
    group3:insert(myData.ipsR1.txt)
    group3:insert(myData.siemR2.txt)
    group3:insert(myData.avR1.txt)
    group3:insert(myData.progR1.txt)
    group3:insert(myData.ipsR2.txt)
    group3:insert(myData.avR2.txt)
    group3:insert(myData.progR2.txt)
    group3:insert(myData.fwR2.txt)
    group3.alpha=0

    group:insert(myData.background)
    group:insert(myData.backButton)
    group:insert(myData.top_backgroundST)
    group:insert(myData.moneyTextRC)
    group:insert(myData.playerTextRC)
    group:insert(myData.st_rect)
    group:insert(myData.researchTabBar) 
    group:insert(myData.st_bg)
    group:insert(group1)
    group:insert(group2)
    group:insert(group3)
    group:insert(myData.researchRect)
    group:insert(myData.noResearchText)
    group:insert(myData.researchProgressView)
    group:insert(myData.researchText)
    group:insert(myData.researchTimer)
    group:insert(myData.infoPanelRT)
    group:insert(myData.infoTextRT)
    group:insert(myData.infoTextRT2)
    group:insert(myData.upgradeRTButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackRC)
    myData.upgradeRTButton:addEventListener("tap",upgradeRT)

    myData.coolR1:addEventListener("tap",showRTStat)
    myData.missionR1:addEventListener("tap",showRTStat)
    myData.missionR2:addEventListener("tap",showRTStat)
    myData.missionR3:addEventListener("tap",showRTStat)
    myData.upgradeR1:addEventListener("tap",showRTStat)
    myData.upgradeR2:addEventListener("tap",showRTStat)

    myData.botR1:addEventListener("tap",showRTStat)
    myData.scannerR1:addEventListener("tap",showRTStat)
    myData.anonR1:addEventListener("tap",showRTStat)
    myData.scannerR2:addEventListener("tap",showRTStat)
    myData.exploitR1:addEventListener("tap",showRTStat)
    myData.malwareR1:addEventListener("tap",showRTStat)
    myData.anonR2:addEventListener("tap",showRTStat)
    myData.exploitR2:addEventListener("tap",showRTStat)
    myData.malwareR2:addEventListener("tap",showRTStat)

    myData.fwR1:addEventListener("tap",showRTStat)
    myData.fwR2:addEventListener("tap",showRTStat)
    myData.siemR1:addEventListener("tap",showRTStat)
    myData.siemR2:addEventListener("tap",showRTStat)
    myData.ipsR1:addEventListener("tap",showRTStat)
    myData.ipsR2:addEventListener("tap",showRTStat)
    myData.progR1:addEventListener("tap",showRTStat)
    myData.progR2:addEventListener("tap",showRTStat)
    myData.avR1:addEventListener("tap",showRTStat)
    myData.avR2:addEventListener("tap",showRTStat)

end

-- Home Show
function researchScene:show(event)
    local logGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "researchTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutResearch ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "researchTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRT.php", "POST", RTnetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
researchScene:addEventListener( "create", researchScene )
researchScene:addEventListener( "show", researchScene )
---------------------------------------------------------------------------------

return researchScene