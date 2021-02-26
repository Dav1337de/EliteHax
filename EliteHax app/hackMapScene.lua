local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local hackMapScene = composer.newScene()
local pasteboard = require( "plugin.pasteboard" )
local targetAudio1=0
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
refreshHackScenario = nil

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local function hackActivitiesListener( event )
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
        end 
   end
end

local function updateHackActivityTimer(event)
    local secondsLeft = myData.taskTimerT.secondsLeft
    local total_time = myData.taskTimerT.total_time
    secondsLeft = secondsLeft - 1
    if (secondsLeft >0) then
        myData.taskTimerT.text=myData.taskTimerT.desc.."\n\n"..timeText(secondsLeft)
        myData.taskTimerT.secondsLeft = secondsLeft
        local percent=((total_time-secondsLeft)/total_time)
        myData.hackProgressView:setProgress( percent )
    else
        myData.taskTimerT.text="Ready for the next step!\n\n\n"
        timer.cancel(hackActivityCountDownTimer)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        hackScenarioLoaded=false
        network.request( host().."checkHackMissionActivities.php", "POST", hackActivitiesListener, params )
    end
end

local function hackScenarioListener( event )
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

        myData.playerTextLogs.text=t.user
        if (string.len(t.user)>15) then myData.playerTextLogs.size = fontSize(42) end
        myData.moneyTextLogs.text = format_thousand(t.money)

        myData.dmzRect.host=t.dmz_name
        myData.dmzRect.net_id=t.dmz_id
        myData.dmzRect.services=t.dmz_services
        myData.dmzRect.vulns=t.dmz_vulns

        if (t.int_id~=0) then
            myData.intRect.alpha=1
            myData.intRect.hostname=t.int_name
            myData.intRect.net_id=t.int_id
            myData.intRect.services=t.int_services
            myData.intRect.vulns=t.int_vulns
        end

        if (t.client_id~=0) then
            myData.clientRect.alpha=1
            myData.clientRect.hostname=t.client_name
            myData.clientRect.net_id=t.client_id
            myData.clientRect.services=t.client_services
            myData.clientRect.vulns=t.client_vulns
        end

        if (t.int2_id~=0) then
            myData.int2Rect.alpha=1
            myData.int2Rect.hostname=t.int2_name
            myData.int2Rect.net_id=t.int2_id
            myData.int2Rect.services=t.int2_services
            myData.int2Rect.vulns=t.int2_vulns
        end

        local dmzHosts=0
        local intHosts=0
        local clientHosts=0
        local int2Hosts=0

        for i in pairs( t.hosts ) do
            local objName="h"..i
            myData[objName].hostname=t.hosts[i].hostname
            myData[objName].host_id=t.hosts[i].id
            myData[objName].os=t.hosts[i].os
            myData[objName].services=t.hosts[i].services
            myData[objName].vulns=t.hosts[i].vulns
            if (t.hosts[i].hostname~="") then
                local type=0
                myData[objName].alpha=1
                if (i<=3) then
                    dmzHosts=dmzHosts+1
                elseif (i<=6) then
                    intHosts=intHosts+1
                elseif (i<=9) then
                    clientHosts=clientHosts+1
                    local imageA = { type="image", filename="img/host_client.png" }
                    myData[objName].fill=imageA
                    changeImgColor(myData[objName])
                    type=1
                else
                    int2Hosts=int2Hosts+1
                    if (t.hosts[i].os==4) then
                        local imageA = { type="image", filename="img/host_client.png" }
                        myData[objName].fill=imageA
                        changeImgColor(myData[objName])
                        type=1
                    end
                end
                if (type==0) then
                    if (t.hosts[i].down==1) then
                        local imageA = { type="image", filename="img/host_server_down.png" }
                        myData[objName].fill=imageA
                        changeImgColor(myData[objName])
                    elseif (t.hosts[i].proxied==1) then
                        local imageA = { type="image", filename="img/host_server_proxied.png" }
                        myData[objName].fill=imageA
                        changeImgColor(myData[objName])
                        myData[objName].proxy=true
                    end
                elseif (type==1) then
                    if (t.hosts[i].down==1) then
                        local imageA = { type="image", filename="img/host_client_down.png" }
                        myData[objName].fill=imageA
                        changeImgColor(myData[objName])
                    elseif (t.hosts[i].proxied==1) then
                        local imageA = { type="image", filename="img/host_client_proxied.png" }
                        myData[objName].fill=imageA
                        changeImgColor(myData[objName])
                        myData[objName].proxy=true
                    end
                end
            end
        end
        myData.dmzRect.hosts=dmzHosts
        myData.intRect.hosts=intHosts
        myData.clientRect.hosts=clientHosts
        myData.int2Rect.hosts=int2Hosts

        if (t.task_total_time>0) then
            local percent=((t.task_total_time-t.task_time_left)/t.task_total_time)
            myData.hackProgressView:setProgress( percent )
            myData.taskTimerT.text=t.task_description.."\n\n"..timeText(t.task_time_left)
            myData.taskTimerT.secondsLeft=t.task_time_left
            myData.taskTimerT.total_time=t.task_total_time
            myData.taskTimerT.desc=t.task_description

            if (hackActivityCountDownTimer) then
                timer.cancel(hackActivityCountDownTimer)
            end
            hackActivityCountDownTimer = timer.performWithDelay( 1000, updateHackActivityTimer, 10000000 )
        else
            myData.taskTimerT.text="Ready for the next step!\n\n\n"
        end

        hackScenarioLoaded=true
   end
end

function goBackHackMap(event)
    if (tutOverlay==false) then
        backSound()
        composer.removeScene( "hackMapScene" )
        composer.gotoScene("missionScene", {effect = "fade", time = 100})
    end
end

function clearTargets(n)
    for i=1,12 do
        local cur = "h"..i
        if (myData[cur].scan ~= true) then
            if (i~=n) then
                if (i<=6) then
                    myData[cur].width=iconSize
                    myData[cur].height=iconSize
                else
                    myData[cur].width=iconSize/1.2
                    myData[cur].height=iconSize/1.2
                end
            end
        end
    end
    if (n~=13) then
        myData.dmzRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    end
    if (n~=14) then
        myData.intRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    end
    if (n~=15) then
        myData.clientRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    end
    if (n~=16) then
        myData.int2Rect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    end
    
end

local function detectTarget(x,y,source)
    myData.dmzRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    myData.intRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    myData.clientRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    myData.int2Rect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    if ((x > myData.h1.x) and (x < myData.h1.x+myData.h1.width) and (y>myData.h1.y) and (y<myData.h1.y+myData.h1.height) and (myData.h1.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h1.width=fontSize(220)
        myData.h1.height=fontSize(220)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h1.previewPanelX
        myData.previewPanel.y=myData.h1.previewPanelY
        myData.previewPanel.alpha=1
        myData.previewPanelText.text=myData.h1.hostname.."\n\n"..myData.h1.services.." Open Ports\n"..myData.h1.vulns.." Vulnerabilities"
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(1)
        return "h1"
    elseif ((x > myData.h2.x) and (x < myData.h2.x+myData.h2.width) and (y>myData.h2.y) and (y<myData.h2.y+myData.h2.height) and (myData.h2.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h2.width=fontSize(220)
        myData.h2.height=fontSize(220)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h2.previewPanelX
        myData.previewPanel.y=myData.h2.previewPanelY
        myData.previewPanel.alpha=1
        myData.previewPanelText.text=myData.h2.hostname.."\n\n"..myData.h2.services.." Open Ports\n"..myData.h2.vulns.." Vulnerabilities"
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(2)
        return "h2"
    elseif ((x > myData.h3.x) and (x < myData.h3.x+myData.h3.width) and (y>myData.h3.y) and (y<myData.h3.y+myData.h3.height) and (myData.h3.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h3.width=fontSize(220)
        myData.h3.height=fontSize(220)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h3.previewPanelX
        myData.previewPanel.y=myData.h3.previewPanelY
        myData.previewPanel.alpha=1
        myData.previewPanelText.text=myData.h3.hostname.."\n\n"..myData.h3.services.." Open Ports\n"..myData.h3.vulns.." Vulnerabilities"
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(3)
        return "h3"
    elseif ((source~="attacker") and (x > myData.h4.x) and (x < myData.h4.x+myData.h4.width) and (y>myData.h4.y) and (y<myData.h4.y+myData.h4.height) and (myData.h4.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h4.width=fontSize(220)
        myData.h4.height=fontSize(220)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h4.previewPanelX
        myData.previewPanel.y=myData.h4.previewPanelY
        myData.previewPanelText.text=myData.h4.hostname.."\n\n"..myData.h4.services.." Open Ports\n"..myData.h4.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(4)
        return "h4"
    elseif ((source~="attacker") and (x > myData.h5.x) and (x < myData.h5.x+myData.h5.width) and (y>myData.h5.y) and (y<myData.h5.y+myData.h5.height) and (myData.h5.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h5.width=fontSize(220)
        myData.h5.height=fontSize(220)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h5.previewPanelX
        myData.previewPanel.y=myData.h5.previewPanelY
        myData.previewPanelText.text=myData.h5.hostname.."\n\n"..myData.h5.services.." Open Ports\n"..myData.h5.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(5)
        return "h5"
    elseif ((source~="attacker") and (x > myData.h6.x) and (x < myData.h6.x+myData.h6.width) and (y>myData.h6.y) and (y<myData.h6.y+myData.h6.height) and (myData.h6.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h6.width=fontSize(220)
        myData.h6.height=fontSize(220)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h6.previewPanelX
        myData.previewPanel.y=myData.h6.previewPanelY
        myData.previewPanelText.text=myData.h6.hostname.."\n\n"..myData.h6.services.." Open Ports\n"..myData.h6.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(6)
        return "h6"
    elseif ((source~="attacker") and (tonumber(string.match(source, "%d+"))>3) and (x > myData.h7.x) and (x < myData.h7.x+myData.h7.width) and (y>myData.h7.y) and (y<myData.h7.y+myData.h7.height) and (myData.h7.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h7.width=iconSize/1.2+fontSize(20)
        myData.h7.height=iconSize/1.2+fontSize(20)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h7.previewPanelX
        myData.previewPanel.y=myData.h7.previewPanelY
        myData.previewPanelText.text=myData.h7.hostname.."\n\n"..myData.h7.services.." Open Ports\n"..myData.h7.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(7)
        return "h7"
    elseif ((source~="attacker") and (tonumber(string.match(source, "%d+"))>3) and (x > myData.h8.x) and (x < myData.h8.x+myData.h8.width) and (y>myData.h8.y) and (y<myData.h8.y+myData.h8.height) and (myData.h8.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h8.width=iconSize/1.2+fontSize(20)
        myData.h8.height=iconSize/1.2+fontSize(20)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h8.previewPanelX
        myData.previewPanel.y=myData.h8.previewPanelY
        myData.previewPanelText.text=myData.h8.hostname.."\n\n"..myData.h8.services.." Open Ports\n"..myData.h8.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(8)
        return "h8"
    elseif ((source~="attacker") and (tonumber(string.match(source, "%d+"))>3) and (x > myData.h9.x) and (x < myData.h9.x+myData.h9.width) and (y>myData.h9.y) and (y<myData.h9.y+myData.h9.height) and (myData.h9.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h9.width=iconSize/1.2+fontSize(20)
        myData.h9.height=iconSize/1.2+fontSize(20)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h9.previewPanelX
        myData.previewPanel.y=myData.h9.previewPanelY
        myData.previewPanelText.text=myData.h9.hostname.."\n\n"..myData.h9.services.." Open Ports\n"..myData.h9.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(9)
        return "h9"
    elseif ((source~="attacker") and (tonumber(string.match(source, "%d+"))>3) and (x > myData.h10.x) and (x < myData.h10.x+myData.h10.width) and (y>myData.h10.y) and (y<myData.h10.y+myData.h10.height) and (myData.h10.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h10.width=iconSize/1.2+fontSize(20)
        myData.h10.height=iconSize/1.2+fontSize(20)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h10.previewPanelX
        myData.previewPanel.y=myData.h10.previewPanelY
        myData.previewPanelText.text=myData.h10.hostname.."\n\n"..myData.h10.services.." Open Ports\n"..myData.h10.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(10)
        return "h10"
    elseif ((source~="attacker") and (tonumber(string.match(source, "%d+"))>3) and (x > myData.h11.x) and (x < myData.h11.x+myData.h11.width) and (y>myData.h11.y) and (y<myData.h11.y+myData.h11.height) and (myData.h11.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h11.width=iconSize/1.2+fontSize(20)
        myData.h11.height=iconSize/1.2+fontSize(20)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h11.previewPanelX
        myData.previewPanel.y=myData.h11.previewPanelY
        myData.previewPanelText.text=myData.h11.hostname.."\n\n"..myData.h11.services.." Open Ports\n"..myData.h11.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(11)
        return "h11"
    elseif ((source~="attacker") and (tonumber(string.match(source, "%d+"))>3) and (x > myData.h12.x) and (x < myData.h12.x+myData.h12.width) and (y>myData.h12.y) and (y<myData.h12.y+myData.h12.height) and (myData.h12.alpha==1)) then
        targetSound()
        if (targetAudio1==2) then
            targetAudio=true
        end
        targetAudio1=1
        myData.h12.width=iconSize/1.2+fontSize(20)
        myData.h12.height=iconSize/1.2+fontSize(20)
        myData.previewPanel.width=400
        myData.previewPanel.x=myData.h12.previewPanelX
        myData.previewPanel.y=myData.h12.previewPanelY
        myData.previewPanelText.text=myData.h12.hostname.."\n\n"..myData.h12.services.." Open Ports\n"..myData.h12.vulns.." Vulnerabilities"
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(12)
        return "h12"
    elseif ((x > myData.dmzRect.x-myData.dmzRect.width/2) and (x < myData.dmzRect.x+myData.dmzRect.width/2) and (y>myData.dmzRect.y) and (y<myData.dmzRect.y+myData.dmzRect.height)) then
        targetSound()
        if (targetAudio1==1) then
            targetAudio=true
        end
        targetAudio1=2
        myData.dmzRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.6 )
        clearTargets(13)
        myData.previewPanel.width=500
        myData.previewPanel.x=myData.dmzRect.previewPanelX
        myData.previewPanel.y=myData.dmzRect.previewPanelY
        if (myData.dmzRect.hosts==0) then
            myData.previewPanelText.text="DMZ Network".."\n\nNot Scanned"
        else
            myData.previewPanelText.text="DMZ Network".."\n\nHosts: "..myData.dmzRect.hosts.."\nOpen Ports: "..myData.dmzRect.services.."\nVulnerabilities: "..myData.dmzRect.vulns
        end
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        return "dmzRect"
    elseif ((source~="attacker") and (x > myData.intRect.x-myData.intRect.width/2) and (x < myData.intRect.x+myData.intRect.width/2) and (y>myData.intRect.y) and (y<myData.intRect.y+myData.intRect.height) and (myData.intRect.alpha==1)) then
        targetSound()
        if (targetAudio1==1) then
            targetAudio=true
        end
        targetAudio1=2
        myData.intRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.6 )
        myData.previewPanel.width=500
        myData.previewPanel.x=myData.intRect.previewPanelX
        myData.previewPanel.y=myData.intRect.previewPanelY
        if (myData.intRect.hosts==0) then
            myData.previewPanelText.text="Internal Network".."\n\nNot Scanned"
        else
            myData.previewPanelText.text="Internal Network".."\n\nHosts: "..myData.intRect.hosts.."\nOpen Ports: "..myData.intRect.services.."\nVulnerabilities: "..myData.intRect.vulns
        end
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(14)
        return "intRect"
    elseif ((source~="attacker") and (tonumber(string.match(source, "%d+"))>3) and (x > myData.clientRect.x-myData.clientRect.width/2) and (x < myData.clientRect.x+myData.clientRect.width/2) and (y>myData.clientRect.y) and (y<myData.clientRect.y+myData.clientRect.height) and (myData.clientRect.alpha==1)) then
        targetSound()
        if (targetAudio1==1) then
            targetAudio=true
        end
        targetAudio1=2
        myData.clientRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.6 )
        myData.previewPanel.width=500
        myData.previewPanel.x=myData.clientRect.previewPanelX
        myData.previewPanel.y=myData.clientRect.previewPanelY
        if (myData.clientRect.hosts==0) then
            myData.previewPanelText.text="Client Network".."\n\nNot Scanned"
        else
            myData.previewPanelText.text="Client Network".."\n\nHosts: "..myData.clientRect.hosts.."\nOpen Ports: "..myData.clientRect.services.."\nVulnerabilities: "..myData.clientRect.vulns
        end
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(15)
        return "clientRect"
    elseif ((source~="attacker") and (tonumber(string.match(source, "%d+"))>3) and (x > myData.int2Rect.x-myData.int2Rect.width/2) and (x < myData.int2Rect.x+myData.int2Rect.width/2) and (y>myData.int2Rect.y) and (y<myData.int2Rect.y+myData.int2Rect.height) and (myData.int2Rect.alpha==1)) then
        targetSound()
        if (targetAudio1==1) then
            targetAudio=true
        end
        targetAudio1=2
        myData.int2Rect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.6 )
        myData.previewPanel.width=500
        myData.previewPanel.x=myData.int2Rect.previewPanelX
        myData.previewPanel.y=myData.int2Rect.previewPanelY
        if (myData.int2Rect.hosts==0) then
            myData.previewPanelText.text="Production Network".."\n\nNot Scanned"
        else
            myData.previewPanelText.text="Production Network".."\n\nHosts: "..myData.int2Rect.hosts.."\nOpen Ports: "..myData.int2Rect.services.."\nVulnerabilities: "..myData.int2Rect.vulns
        end
        myData.previewPanel.alpha=1
        myData.previewPanelText.x=myData.previewPanel.x
        myData.previewPanelText.y=myData.previewPanel.y+fontSize(30)
        myData.previewPanelText.alpha=1
        clearTargets(16)
        return "int2Rect"
    else
        targetAudio=true
        clearTargets()
        myData.previewPanel.alpha=0
        myData.previewPanelText.alpha=0
        return "None"
    end

end

local function onAttackerTouch( event )
    if ((hackScenarioLoaded==true) and (event.target.proxy==true)) then
        if ( event.phase == "began" ) then
            display.getCurrentStage():setFocus(event.target )
            event.target.isFocus = true
        elseif ( event.phase == "moved" ) then
            if (attackerLine) then
                attackerLine:removeSelf()
                attackerLine = nil
            end
            local dX = event.target.x+(event.x - event.target.x) 
            local dY = event.target.y+(event.y - event.target.y+20) 
            local ddX=event.target.width/2
            if (event.target.id=="attacker") then ddX=0 end
            attackerLine = display.newLine( dX,dY, event.target.x+ddX, event.target.y+event.target.height/2+20 )
            attackerLine:setStrokeColor( 0.7, 0, 0, 1 )
            attackerLine.strokeWidth = 10
            group:insert(attackerLine)
            group:insert(event.target)
            detectTarget(dX,dY,event.target.id)
        elseif ( event.phase == "ended" ) then
            display.getCurrentStage():setFocus( nil )
            myData.attacker.isFocus = nil
            local dX = myData.attacker.x+(event.x - myData.attacker.x) 
            local dY = myData.attacker.y+(event.y - myData.attacker.y+20) 
            local visualTarget = detectTarget(dX,dY,event.target.id)
            if (visualTarget ~= "None") then
                myData[visualTarget].scan=true
                --print(myData[visualTarget].id)
                scanOverlay=true
                if ((visualTarget=="dmzRect") or (visualTarget=="intRect") or (visualTarget=="clientRect") or (visualTarget=="int2Rect")) then
                    local sceneOverlayOptions = 
                    {
                        time = 300,
                        effect = "crossFade",
                        params = { 
                            target=myData[visualTarget].hostname,
                            target_id=myData[visualTarget].net_id
                        },
                        isModal = true
                    }
                    composer.showOverlay( "hackNetScene", sceneOverlayOptions)
                else
                    local sceneOverlayOptions = 
                    {
                        time = 300,
                        effect = "crossFade",
                        params = { 
                            target=myData[visualTarget].hostname,
                            target_id=myData[visualTarget].host_id
                        },
                        isModal = true
                    }
                    composer.showOverlay( "hackScanScene", sceneOverlayOptions)
                end
            else
                if (attackerLine) then
                    attackerLine:removeSelf()
                    attackerLine = newLine
                end
            end      
        end
        return true
    end
end

refreshHackScenario = function(event)
    clearTargets()
    myData.previewPanel.alpha=0
    myData.previewPanelText.alpha=0
    if (attackerLine) then
        attackerLine:removeSelf()
        attackerLine = newLine
    end
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getHackScenario.php", "POST", hackScenarioListener, params )
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function hackMapScene:create(event)
    group = self.view

    loginInfo = localToken()
    scanOverlay=false

    iconSize=fontSize(200)
    horizontalDiff=(200-iconSize)/2

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

    myData.hackRect = display.newImageRect( "img/hack_mission_rect.png",display.contentWidth-20, fontSize(1660))
    myData.hackRect.anchorX = 0.5
    myData.hackRect.anchorY = 0
    myData.hackRect.x, myData.hackRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height+10
    changeImgColor(myData.hackRect)

    myData.attacker = display.newImageRect( "img/attacker.png",iconSize*1.3,iconSize*1.3 )
    myData.attacker.id="attacker"
    myData.attacker.anchorX = 0.5
    myData.attacker.anchorY = 0
    myData.attacker.x, myData.attacker.y = display.contentWidth/2,myData.hackRect.y+fontSize(110)
    myData.attacker.proxy=true

    myData.dmzRect = display.newRoundedRect( display.contentWidth/2, myData.attacker.y+myData.attacker.height, myData.hackRect.width-80, fontSize(300), 40 )
    myData.dmzRect.strokeWidth = 7
    myData.dmzRect.anchorY=0
    myData.dmzRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    myData.dmzRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.dmzRect.id="dmz"
    myData.dmzRect.hostname="DMZ Network"
    myData.dmzRect.previewPanelX=myData.dmzRect.x
    myData.dmzRect.previewPanelY=myData.dmzRect.y+myData.dmzRect.height

    myData.intRect = display.newRoundedRect( display.contentWidth/2, myData.dmzRect.y+myData.dmzRect.height+fontSize(20), myData.hackRect.width-80, fontSize(300), 40 )
    myData.intRect.strokeWidth = 7
    myData.intRect.anchorY=0
    myData.intRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    myData.intRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.intRect.id="int"
    myData.intRect.hostname="Internal Network"
    myData.intRect.previewPanelX=myData.intRect.x
    myData.intRect.previewPanelY=myData.intRect.y+myData.intRect.height
    myData.intRect.alpha=0

    myData.clientRect = display.newRoundedRect( display.contentWidth/4+20, myData.intRect.y+myData.intRect.height+fontSize(20), myData.hackRect.width/2-40, fontSize(400), 40 )
    myData.clientRect.strokeWidth = 5
    myData.clientRect.anchorY=0
    myData.clientRect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    myData.clientRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.clientRect.id="client"
    myData.clientRect.hostname="Client Network"
    myData.clientRect.previewPanelX=myData.clientRect.x
    myData.clientRect.previewPanelY=myData.clientRect.y-fontSize(300)
    myData.clientRect.alpha=0

    myData.int2Rect = display.newRoundedRect( display.contentWidth/4*3-20, myData.intRect.y+myData.intRect.height+fontSize(20), myData.hackRect.width/2-40, fontSize(400), 40 )
    myData.int2Rect.strokeWidth = 5
    myData.int2Rect.anchorY=0
    myData.int2Rect:setFillColor( strokeColor1[1], strokeColor1[2], strokeColor1[3], 0.2 )
    myData.int2Rect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.int2Rect.id="int2"
    myData.int2Rect.hostname="Production Network"
    myData.int2Rect.previewPanelX=myData.int2Rect.x
    myData.int2Rect.previewPanelY=myData.int2Rect.y-fontSize(300)
    myData.int2Rect.alpha=0

    myData.h1 = display.newImageRect( "img/host_server.png",iconSize,iconSize )
    myData.h1.id="h1"
    myData.h1.anchorX = 0
    myData.h1.anchorY = 0
    myData.h1.x, myData.h1.y = horizontalDiff+myData.dmzRect.x-myData.dmzRect.width/2+20+math.random(100),myData.dmzRect.y+10+fontSize(math.random(80))
    changeImgColor(myData.h1)
    myData.h1.previewPanelX=myData.h1.x+myData.h1.width/2
    myData.h1.previewPanelY=myData.h1.y+myData.h1.height
    myData.h1.alpha=0
    myData.h1.proxy=false

    myData.h2 = display.newImageRect( "img/host_server.png",iconSize,iconSize )
    myData.h2.id="h2"
    myData.h2.anchorX = 0
    myData.h2.anchorY = 0
    myData.h2.x, myData.h2.y = horizontalDiff*2+myData.dmzRect.x-myData.dmzRect.width/2+iconSize+140+math.random(100),myData.dmzRect.y+10+fontSize(math.random(80))
    changeImgColor(myData.h2)
    myData.h2.previewPanelX=myData.h2.x+myData.h2.width/2
    myData.h2.previewPanelY=myData.h2.y+myData.h2.height
    myData.h2.alpha=0
    myData.h2.proxy=false

    myData.h3 = display.newImageRect( "img/host_server.png",iconSize,iconSize )
    myData.h3.id="h3"
    myData.h3.anchorX = 0
    myData.h3.anchorY = 0
    myData.h3.x, myData.h3.y = horizontalDiff*3+myData.dmzRect.x-myData.dmzRect.width/2+iconSize*2+260+math.random(100),myData.dmzRect.y+10+fontSize(math.random(80))
    changeImgColor(myData.h3)
    myData.h3.previewPanelX=myData.h3.x+myData.h3.width/2
    myData.h3.previewPanelY=myData.h3.y+myData.h3.height
    myData.h3.alpha=0
    myData.h3.proxy=false

    myData.h4 = display.newImageRect( "img/host_server.png",iconSize,iconSize )
    myData.h4.id="h4"
    myData.h4.anchorX = 0
    myData.h4.anchorY = 0
    myData.h4.x, myData.h4.y = horizontalDiff+myData.intRect.x-myData.intRect.width/2+20+math.random(100),myData.intRect.y+10+fontSize(math.random(80))
    changeImgColor(myData.h4)
    myData.h4.previewPanelX=myData.h4.x+myData.h4.width/2
    myData.h4.previewPanelY=myData.h4.y+myData.h4.height
    myData.h4.alpha=0
    myData.h4.proxy=false

    myData.h5 = display.newImageRect( "img/host_server.png",iconSize,iconSize )
    myData.h5.id="h5"
    myData.h5.anchorX = 0
    myData.h5.anchorY = 0
    myData.h5.x, myData.h5.y = horizontalDiff*2+myData.intRect.x-myData.intRect.width/2+iconSize+140+math.random(100),myData.intRect.y+10+fontSize(math.random(80))
    changeImgColor(myData.h5)
    myData.h5.previewPanelX=myData.h5.x+myData.h5.width/2
    myData.h5.previewPanelY=myData.h5.y+myData.h5.height
    myData.h5.alpha=0
    myData.h5.proxy=false

    myData.h6 = display.newImageRect( "img/host_server.png",iconSize,iconSize )
    myData.h6.id="h6"
    myData.h6.anchorX = 0
    myData.h6.anchorY = 0
    myData.h6.x, myData.h6.y = horizontalDiff*3+myData.intRect.x-myData.intRect.width/2+iconSize*2+260+math.random(100),myData.intRect.y+10+fontSize(math.random(80))
    changeImgColor(myData.h6)
    myData.h6.previewPanelX=myData.h6.x+myData.h6.width/2
    myData.h6.previewPanelY=myData.h6.y+myData.h6.height
    myData.h6.alpha=0
    myData.h6.proxy=false

    myData.h7 = display.newImageRect( "img/host_server.png",iconSize/1.2,iconSize/1.2 )
    myData.h7.id="h7"
    myData.h7.anchorX = 0
    myData.h7.anchorY = 0
    myData.h7.x, myData.h7.y = horizontalDiff+myData.clientRect.x-myData.clientRect.width/2+10+math.random(40),myData.clientRect.y+10+fontSize(math.random(35))
    changeImgColor(myData.h7)
    myData.h7.previewPanelX=myData.h7.x+myData.h7.width/2+50
    myData.h7.previewPanelY=myData.h7.y-fontSize(300)
    myData.h7.alpha=0
    myData.h7.proxy=false

    myData.h8 = display.newImageRect( "img/host_server.png",iconSize/1.2,iconSize/1.2 )
    myData.h8.id="h8"
    myData.h8.anchorX = 0
    myData.h8.anchorY = 0
    myData.h8.x, myData.h8.y = horizontalDiff*2+myData.clientRect.x-myData.clientRect.width/2+iconSize+40+math.random(40),myData.clientRect.y+10+fontSize(math.random(35))
    changeImgColor(myData.h8)
    myData.h8.previewPanelX=myData.h8.x+myData.h8.width/2
    myData.h8.previewPanelY=myData.h8.y-fontSize(300)
    myData.h8.alpha=0
    myData.h8.proxy=false

    myData.h9 = display.newImageRect( "img/host_server.png",iconSize/1.2,iconSize/1.2 )
    myData.h9.id="h9"
    myData.h9.anchorX = 0
    myData.h9.anchorY = 0
    myData.h9.x, myData.h9.y = horizontalDiff+myData.clientRect.x-myData.clientRect.width/2+10+math.random(240),myData.clientRect.y+220+fontSize(math.random(15))
    changeImgColor(myData.h9)
    myData.h9.previewPanelX=myData.h9.x+myData.h9.width/2
    myData.h9.previewPanelY=myData.h9.y-fontSize(300)
    myData.h9.alpha=0
    myData.h9.proxy=false

    myData.h10 = display.newImageRect( "img/host_server.png",iconSize/1.2,iconSize/1.2 )
    myData.h10.id="h10"
    myData.h10.anchorX = 0
    myData.h10.anchorY = 0
    myData.h10.x, myData.h10.y = horizontalDiff+myData.int2Rect.x-myData.int2Rect.width/2+10+math.random(240),myData.int2Rect.y+fontSize(math.random(15))
    changeImgColor(myData.h10)
    myData.h10.previewPanelX=myData.h10.x+myData.h10.width/2
    myData.h10.previewPanelY=myData.h10.y-fontSize(300)
    myData.h10.alpha=0
    myData.h10.proxy=false

    myData.h11 = display.newImageRect( "img/host_server.png",iconSize/1.2,iconSize/1.2 )
    myData.h11.id="h11"
    myData.h11.anchorX = 0
    myData.h11.anchorY = 0
    myData.h11.x, myData.h11.y = horizontalDiff+myData.int2Rect.x-myData.int2Rect.width/2+10+math.random(40),myData.int2Rect.y+195+fontSize(math.random(35))
    changeImgColor(myData.h11)
    myData.h11.previewPanelX=myData.h11.x+myData.h11.width/2
    myData.h11.previewPanelY=myData.h11.y-fontSize(300)
    myData.h11.alpha=0
    myData.h11.proxy=false

    myData.h12 = display.newImageRect( "img/host_server.png",iconSize/1.2,iconSize/1.2 )
    myData.h12.id="h12"
    myData.h12.anchorX = 0
    myData.h12.anchorY = 0
    myData.h12.x, myData.h12.y = horizontalDiff*2+myData.int2Rect.x-myData.int2Rect.width/2+iconSize+40+math.random(40),myData.int2Rect.y+195+fontSize(math.random(35))
    changeImgColor(myData.h12)
    myData.h12.previewPanelX=myData.h12.x+myData.h12.width/2-50
    myData.h12.previewPanelY=myData.h12.y-fontSize(300)
    myData.h12.alpha=0
    myData.h12.proxy=false

    myData.previewPanel = display.newRoundedRect( myData.dmzRect.x, myData.dmzRect.y+myData.dmzRect.height-fontSize(20), 500, fontSize(320), 40 )
    myData.previewPanel.strokeWidth = 7
    myData.previewPanel.anchorY=0
    myData.previewPanel:setFillColor( 0, 0, 0, 1 )
    myData.previewPanel:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.previewPanel.alpha=0

    myData.previewPanelText = display.newText("",myData.previewPanel.x,myData.previewPanel.y,native.systemFont, fontSize(48))
    myData.previewPanelText.anchorX = 0.5
    myData.previewPanelText.anchorY = 0
    myData.previewPanelText:setFillColor( 0.9,0.9,0.9 )
    myData.previewPanelText.alpha=0

    local options = {
        width = 64,
        height = 64,
        numFrames = 6,
        sheetContentWidth = 384,
        sheetContentHeight = 64
    }
    local progressSheet = graphics.newImageSheet( progressColor, options )
    myData.hackProgressView = widget.newProgressView(
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
            left = myData.dmzRect.x-myData.dmzRect.width/2+40,
            top = myData.clientRect.y+myData.clientRect.height+fontSize(85),
            width = myData.dmzRect.width-80,
            height = fontSize(100),
            isAnimated = true
        }
    )

    local options = 
    {
        text = "",
        x = myData.hackRect.x,
        y = myData.hackProgressView.y+fontSize(5),
        width = myData.hackRect.width-40,
        font = native.systemFont,   
        fontSize = fontSize(50),
        align = "center"
    }

    myData.taskTimerT = display.newText(options)
    myData.taskTimerT.secondsLeft=0

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
        onEvent = goBackHackMap
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
    group:insert(myData.hackRect)
    group:insert(myData.attacker)
    group:insert(myData.dmzRect)
    group:insert(myData.intRect)
    group:insert(myData.clientRect)
    group:insert(myData.int2Rect)

    group:insert(myData.h1)
    group:insert(myData.h2)
    group:insert(myData.h3)
    group:insert(myData.h4)
    group:insert(myData.h5)
    group:insert(myData.h6)
    group:insert(myData.h7)
    group:insert(myData.h8)
    group:insert(myData.h9)
    group:insert(myData.h10)
    group:insert(myData.h11)
    group:insert(myData.h12)

    group:insert(myData.previewPanel)
    group:insert(myData.previewPanelText)
    group:insert(myData.hackProgressView)
    group:insert(myData.taskTimerT)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackHackMap)
    myData.attacker:addEventListener( "touch", onAttackerTouch )
    myData.h1:addEventListener("touch",onAttackerTouch)
    myData.h2:addEventListener("touch",onAttackerTouch)
    myData.h3:addEventListener("touch",onAttackerTouch)
    myData.h4:addEventListener("touch",onAttackerTouch)
    myData.h5:addEventListener("touch",onAttackerTouch)
    myData.h6:addEventListener("touch",onAttackerTouch)
    myData.h7:addEventListener("touch",onAttackerTouch)
    myData.h8:addEventListener("touch",onAttackerTouch)
    myData.h9:addEventListener("touch",onAttackerTouch)
    myData.h10:addEventListener("touch",onAttackerTouch)
    myData.h11:addEventListener("touch",onAttackerTouch)
    myData.h12:addEventListener("touch",onAttackerTouch)
end

-- Home Show
function hackMapScene:show(event)
    local logGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "hackMissionTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutHackMission ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "hackMissionTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        hackScenarioLoaded=false
        network.request( host().."checkHackMissionActivities.php", "POST", hackActivitiesListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
hackMapScene:addEventListener( "create", hackMapScene )
hackMapScene:addEventListener( "show", hackMapScene )
---------------------------------------------------------------------------------

return hackMapScene