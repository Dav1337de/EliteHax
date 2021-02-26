local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local hackScene = composer.newScene()
local pasteboard = require( "plugin.pasteboard" )
local touchedRow=0
local view="recon"
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local hackActivitiesListener2

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

function goBackHack(event)
    if (tutOverlay==false) then
        backSound()
        composer.removeScene( "hackScene" )
        composer.gotoScene("hackMapScene", {effect = "fade", time = 100})
    end
end

local function updateHackActivityTimer2(event)
    local secondsLeft = myData.taskTimerT2.secondsLeft
    local total_time = myData.taskTimerT2.total_time
    secondsLeft = secondsLeft - 1
    if (secondsLeft >0) then
        myData.taskTimerT2.text=myData.taskTimerT2.desc.."\n\n"..timeText(secondsLeft)
        myData.taskTimerT2.secondsLeft = secondsLeft
        local percent=((total_time-secondsLeft)/total_time)
        myData.hackProgressView2:setProgress( percent )
    else
        myData.taskTimerT2.text="Ready for the next step!\n\n\n"
        timer.cancel(hackActivityCountDownTimer2)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        hackScenarioLoaded=false
        network.request( host().."checkHackMissionActivities.php", "POST", hackActivitiesListener2, params )
    end
end

------------------ ACTIONS --------------------

local function hostActionsNetworkListener( event )
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

        if ((t.keylogger==0) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/keylogger.png" }
            myData.keylogger.fill=imageA
            myData.keylogger.active=true
            changeImgColor(myData.keylogger)
        end

        if ((t.proxy==0) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/proxy.png" }
            myData.proxy.fill=imageA
            myData.proxy.active=true
            changeImgColor(myData.proxy)
        end

        -- if ((t.exploitkit==0) and (t.hacked==1) and (t.web>0)) then
        --     local imageA = { type="image", filename="img/exploitkit.png" }
        --     myData.exploitkit.fill=imageA
        --     myData.exploitkit.active=true
        --     changeImgColor(myData.exploitkit)
        -- end

        if ((t.dataexfiltration==0) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/dataexfiltration.png" }
            myData.dataexfiltration.fill=imageA
            myData.dataexfiltration.active=true
            changeImgColor(myData.dataexfiltration)
        end

        if ((t.dumpdb==0) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/dumpdb.png" }
            myData.dumpdb.fill=imageA
            myData.dumpdb.active=true
            changeImgColor(myData.dumpdb)
        end

        if ((t.alterdata==0) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/alterdata.png" }
            myData.alterdata.fill=imageA
            myData.alterdata.active=true
            changeImgColor(myData.alterdata)
        end

        if ((t.shutdown==0) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/shutdown.png" }
            myData.shutdown.fill=imageA
            myData.shutdown.active=true
            changeImgColor(myData.shutdown)
        end

        -- if ((t.defacement==0) and (t.hacked==1) and (t.web>0)) then
        --     local imageA = { type="image", filename="img/defacement.png" }
        --     myData.defacement.fill=imageA
        --     myData.defacement.active=true
        --     changeImgColor(myData.defacement)
        -- end

        if ((t.ransomware==0) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/ransomware.png" }
            myData.ransomware.fill=imageA
            myData.ransomware.active=true
            changeImgColor(myData.ransomware)
        end

        local message=t.last_message
        if (t.last_message=="") then
            message="None"
        end
        message = string.gsub( message, "<br/>", "\n" )
        myData.actionMessage.text="Last Result:\n\n"..message
       
        hsAgroup.alpha=1

        if (t.task_total_time>0) then
            local percent=((t.task_total_time-t.task_time_left)/t.task_total_time)
            myData.hackProgressView2:setProgress( percent )
            myData.taskTimerT2.text=t.task_description.."\n\n"..timeText(t.task_time_left)
            myData.taskTimerT2.secondsLeft=t.task_time_left
            myData.taskTimerT2.total_time=t.task_total_time
            myData.taskTimerT2.desc=t.task_description

            if (hackActivityCountDownTimer2) then
                timer.cancel(hackActivityCountDownTimer2)
            end
            hackActivityCountDownTimer2 = timer.performWithDelay( 1000, updateHackActivityTimer2, 10000000 )
        else
            myData.taskTimerT2.text="Ready for the next step!\n\n\n"
        end

        tabClick=true
        hsLoaded=true
   end
end

local function actionProxyNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostActions.php", "POST", hostActionsNetworkListener, params )
        end 
   end
end

local function disableActionBtns(event)
    local imageA = { type="image", filename="img/proxy_d.png" }
    myData.proxy.fill=imageA
    myData.proxy.active=false
    local imageA = { type="image", filename="img/alterdata_d.png" }
    myData.alterdata.fill=imageA
    myData.alterdata.active=false
    local imageA = { type="image", filename="img/dumpdb_d.png" }
    myData.dumpdb.fill=imageA
    myData.dumpdb.active=false
    local imageA = { type="image", filename="img/dataexfiltration_d.png" }
    myData.dataexfiltration.fill=imageA
    myData.dataexfiltration.active=false
    local imageA = { type="image", filename="img/shutdown_d.png" }
    myData.shutdown.fill=imageA
    myData.shutdown.active=false
    local imageA = { type="image", filename="img/ransomware_d.png" }
    myData.ransomware.fill=imageA
    myData.ransomware.active=false
    local imageA = { type="image", filename="img/keylogger_d.png" }
    myData.keylogger.fill=imageA
    myData.keylogger.active=false
end

local function proxy(event)
    if ((myData.proxy.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        disableActionBtns()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostActionProxy.php", "POST", actionProxyNetworkListener, params )
    end
end

local function actionAlterdataNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostActions.php", "POST", hostActionsNetworkListener, params )
        end 
   end
end

local function alterdata(event)
    if ((myData.alterdata.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        disableActionBtns()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostActionAlterdata.php", "POST", actionAlterdataNetworkListener, params )
    end
end

local function actionDumpdbNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostActions.php", "POST", hostActionsNetworkListener, params )
        end 
   end
end

local function dumpdb(event)
    if ((myData.dumpdb.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        disableActionBtns()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostActionDumpdb.php", "POST", actionDumpdbNetworkListener, params )
    end
end

local function actionDataexfiltrationNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostActions.php", "POST", hostActionsNetworkListener, params )
        end 
   end
end

local function dataexfiltration(event)
    if ((myData.dataexfiltration.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        disableActionBtns()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostActionDataexfiltration.php", "POST", actionDataexfiltrationNetworkListener, params )
    end
end

local function actionShutdownNetworkListener( event )
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
            if (t.mission_finish==1) then 
                local alert = native.showAlert( "EliteHax", "Congratulation! You have completed your mission!\n\n+100 Reputation!", { "Close" } )
            end
            hsLoaded=true
            goBackHack()
        end 
   end
end

local function shutdown(event)
    if ((myData.shutdown.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        disableActionBtns()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostActionShutdown.php", "POST", actionShutdownNetworkListener, params )
    end
end

local function actionRansomwareNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostActions.php", "POST", hostActionsNetworkListener, params )
        end 
   end
end

local function ransomware(event)
    if ((myData.ransomware.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        disableActionBtns()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostActionRansomware.php", "POST", actionRansomwareNetworkListener, params )
    end
end

local function actionKeyloggerNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostActions.php", "POST", hostActionsNetworkListener, params )
        end 
   end
end

local function keylogger(event)
    if ((myData.keylogger.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        disableActionBtns()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostActionKeylogger.php", "POST", actionKeyloggerNetworkListener, params )
    end
end

------------------ POST-EXPLOITATION --------------------

local function postExploitationNetworkListener( event )
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

        local privilegeEscalatedT="Yes"
        local userDiscoveredT="Yes"
        local connectionDiscoveredT="Yes"
        if (t.user_discovered==0) then userDiscoveredT="No" end
        if (t.user_discovered==2) then userDiscoveredT="No, escalation required!" end
        if (t.escalated==0) then privilegeEscalatedT="No" end
        if (t.connection_discovered==0) then connectionDiscoveredT="No" end
        if (t.connection_discovered==2) then connectionDiscoveredT="No, escalation required!" end

        if (((t.user_discovered==0) or (t.user_discovered==2)) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/discover_user.png" }
            myData.discoverUser.fill=imageA
            myData.discoverUser.active=true
            changeImgColor(myData.discoverUser)
        end

        if ((t.escalated==0) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/privilege_escalation.png" }
            myData.escalatePrivilege.fill=imageA
            myData.escalatePrivilege.active=true
            changeImgColor(myData.escalatePrivilege)
        end

        if (((t.connection_discovered==0) or (t.connection_discovered==2)) and (t.hacked==1) and (t.running_activity==0)) then
            local imageA = { type="image", filename="img/discover_connection.png" }
            myData.discoverConnection.fill=imageA
            myData.discoverConnection.active=true
            changeImgColor(myData.discoverConnection)
        end

        myData.postExploitationDetails.text="\nUsers Discovered:\n"..userDiscoveredT.."\n\nPrivilege Escalated:\n"..privilegeEscalatedT.."\n\nConnections Discovered:\n"..connectionDiscoveredT
        
        hsPgroup.alpha=1

        if (t.task_total_time>0) then
            local percent=((t.task_total_time-t.task_time_left)/t.task_total_time)
            myData.hackProgressView2:setProgress( percent )
            myData.taskTimerT2.text=t.task_description.."\n\n"..timeText(t.task_time_left)
            myData.taskTimerT2.secondsLeft=t.task_time_left
            myData.taskTimerT2.total_time=t.task_total_time
            myData.taskTimerT2.desc=t.task_description

            if (hackActivityCountDownTimer2) then
                timer.cancel(hackActivityCountDownTimer2)
            end
            hackActivityCountDownTimer2 = timer.performWithDelay( 1000, updateHackActivityTimer2, 10000000 )
        else
            myData.taskTimerT2.text="Ready for the next step!\n\n\n"
        end

        hsLoaded=true
        tabClick=true
   end
end

local function discoverConnectionsNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getPostExploitation.php", "POST", postExploitationNetworkListener, params )
        end 
   end
end

local function discoverConnection(event)
    if ((myData.discoverConnection.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        local imageA = { type="image", filename="img/discover_user_d.png" }
        myData.discoverUser.fill=imageA
        myData.discoverUser.active=false
        local imageA = { type="image", filename="img/privilege_escalation_d.png" }
        myData.escalatePrivilege.fill=imageA
        myData.escalatePrivilege.active=false
        local imageA = { type="image", filename="img/discover_connection_d.png" }
        myData.discoverConnection.fill=imageA
        myData.discoverConnection.active=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostDiscoverConnections.php", "POST", discoverConnectionsNetworkListener, params )
    end
end

local function escalatePrivilegeNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getPostExploitation.php", "POST", postExploitationNetworkListener, params )
        end 
   end
end

local function escalatePrivilege(event)
    if ((myData.escalatePrivilege.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        local imageA = { type="image", filename="img/discover_user_d.png" }
        myData.discoverUser.fill=imageA
        myData.discoverUser.active=false
        local imageA = { type="image", filename="img/privilege_escalation_d.png" }
        myData.escalatePrivilege.fill=imageA
        myData.escalatePrivilege.active=false
        local imageA = { type="image", filename="img/discover_connection_d.png" }
        myData.discoverConnection.fill=imageA
        myData.discoverConnection.active=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostEscalatePrivilege.php", "POST", escalatePrivilegeNetworkListener, params )
    end
end

local function discoverUserNetworkListener( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getPostExploitation.php", "POST", postExploitationNetworkListener, params )
        end 
   end
end

local function discoverUser(event)
    if ((myData.discoverUser.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        local imageA = { type="image", filename="img/discover_user_d.png" }
        myData.discoverUser.fill=imageA
        myData.discoverUser.active=false
        local imageA = { type="image", filename="img/privilege_escalation_d.png" }
        myData.escalatePrivilege.fill=imageA
        myData.escalatePrivilege.active=false
        local imageA = { type="image", filename="img/discover_connection_d.png" }
        myData.discoverConnection.fill=imageA
        myData.discoverConnection.active=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostDiscoverUser.php", "POST", discoverUserNetworkListener, params )
    end
end

------------------ EXPLOITATION --------------------

local function vulnsNetworkListener( event )
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

        if (t.down==1) then
            goBackHack()
        else
            myData.vulnsTable:deleteAllRows()
            for i in pairs(t.vulns) do
                rowColor = {
                  default = { 0, 0, 0, 0 }
                }
                lineColor = { 
                  default = { 1, 0, 0 }
                }
                local color=tableColor1
                if (i%2==0) then color=tableColor2 end

                myData.vulnsTable:insertRow(
                    {
                        isCategory = isCategory,
                        rowHeight = fontSize(130),
                        rowColor = rowColor,
                        lineColor = lineColor,
                        params = { 
                            vulnId=t.vulns[i].vuln_id,
                            color=color,
                            vulnName=t.vulns[i].vuln_name,
                            vulnDisc=t.vulns[i].vuln_severity,
                            vulnExploited=t.vulns[i].vuln_exploited,
                            bruteforcedUser=t.vulns[i].bruteforcedUser,
                            bruteforcedPass=t.vulns[i].bruteforcedPass,
                            runningActivity=t.running_activity
                        }
                    }
                )

                if (touchedRow~=0) then
                    if (touchedRow==i) then
                        if (t.vulns[i].vuln_exploited==1) then
                            myData.vulnsDetails.text="Vulnerability Name:\n"..t.vulns[i].vuln_name.."\n\nSuccessfully Exploited"
                        elseif (t.vulns[i].vuln_exploited==2) then
                            myData.vulnsDetails.text="Vulnerability Name:\n"..t.vulns[i].vuln_name.."\n\nExploitation Failed"
                        end
                    end
                end
            end
        end

        hsEgroup.alpha=1

        if (t.task_total_time>0) then
            local percent=((t.task_total_time-t.task_time_left)/t.task_total_time)
            myData.hackProgressView2:setProgress( percent )
            myData.taskTimerT2.text=t.task_description.."\n\n"..timeText(t.task_time_left)
            myData.taskTimerT2.secondsLeft=t.task_time_left
            myData.taskTimerT2.total_time=t.task_total_time
            myData.taskTimerT2.desc=t.task_description

            if (hackActivityCountDownTimer2) then
                timer.cancel(hackActivityCountDownTimer2)
            end
            hackActivityCountDownTimer2 = timer.performWithDelay( 1000, updateHackActivityTimer2, 10000000 )
        else
            myData.taskTimerT2.text="Ready for the next step!\n\n\n"
        end

        hsLoaded=true
        tabClick=true
   end
end

local function vulnExploitNetworkListener( event )
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
            myData.vulnsTable:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostVulns.php", "POST", vulnsNetworkListener, params )
        end 
   end
end

local function bruteforcePass(event)
    if ((myData.vulnBrutePass.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        local imageA = { type="image", filename="img/bruteforcePass_d.png" }
        myData.vulnBrutePass.fill=imageA
        myData.vulnBrutePass.active=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&vuln_id="..myData.vulnBrutePass.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."bruteforcePass.php", "POST", vulnExploitNetworkListener, params )
    end
end

local function bruteforceUserPass(event)
    if ((myData.vulnBruteUserPass.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        local imageA = { type="image", filename="img/bruteforceUser_d.png" }
        myData.vulnBruteUserPass.fill=imageA
        myData.vulnBruteUserPass.active=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&vuln_id="..myData.vulnBruteUserPass.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."bruteforceUser.php", "POST", vulnExploitNetworkListener, params )
    end
end

local function vulnExploit(event)
    if ((myData.vulnExploitBtn.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        local imageA = { type="image", filename="img/host_exploit_d.png" }
        myData.vulnExploitBtn.fill=imageA
        myData.vulnExploitBtn.active=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&vuln_id="..myData.vulnExploitBtn.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."vulnExploit.php", "POST", vulnExploitNetworkListener, params )
    end
end

local function onVulnsRowTouch(event)
    if (event.phase=="tap") then
        touchedRow=event.row.index
        local severityText="Informational"
        if (event.target.params.vulnDisc=="L") then
            severityText="Low"
        elseif (event.target.params.vulnDisc=="M") then
            severityText="Medium"
        elseif (event.target.params.vulnDisc=="H") then
            severityText="High"
        elseif (event.target.params.vulnDisc=="C") then
            severityText="Critical"
        end
        if (event.target.params.vulnExploited==0) then 
            myData.vulnsDetails.text="Vulnerability Name:\n"..event.target.params.vulnName.."\n\nSeverity: "..severityText
        elseif (event.target.params.vulnExploited==1) then
            myData.vulnsDetails.text="Vulnerability Name:\n"..event.target.params.vulnName.."\n\nSuccessfully Exploited"
        elseif (event.target.params.vulnExploited==2) then
            myData.vulnsDetails.text="Vulnerability Name:\n"..event.target.params.vulnName.."\n\nExploitation Failed"
        end
        
        if (event.target.params.vulnDisc=="L") then
            myData.vulnExploitBtn.alpha=0
            myData.vulnBruteUserPass.alpha=1
            myData.vulnBrutePass.alpha=1
            if ((event.target.params.bruteforcedUser==0) and (event.target.params.runningActivity==0)) then
                local imageA = { type="image", filename="img/bruteforceUser.png" }
                myData.vulnBruteUserPass.fill=imageA
                changeImgColor(myData.vulnBruteUserPass)
                myData.vulnBruteUserPass.active=true
                myData.vulnBruteUserPass.id=event.target.params.vulnId
            else
                local imageA = { type="image", filename="img/bruteforceUser_d.png" }
                myData.vulnBruteUserPass.fill=imageA
                myData.vulnBruteUserPass.active=false
            end
            if ((event.target.params.bruteforcedPass==0) and (event.target.params.runningActivity==0)) then
                local imageA = { type="image", filename="img/bruteforcePass.png" }
                myData.vulnBrutePass.fill=imageA
                changeImgColor(myData.vulnBrutePass)
                myData.vulnBrutePass.active=true
                myData.vulnBrutePass.id=event.target.params.vulnId
            else
                local imageA = { type="image", filename="img/bruteforcePass_d.png" }
                myData.vulnBrutePass.fill=imageA
                myData.vulnBrutePass.active=false
            end
        else
            myData.vulnExploitBtn.alpha=1
            myData.vulnBruteUserPass.alpha=0
            myData.vulnBrutePass.alpha=0
            if ((event.target.params.vulnExploited==0) and (event.target.params.runningActivity==0)) then
                local imageA = { type="image", filename="img/host_exploit.png" }
                myData.vulnExploitBtn.fill=imageA
                changeImgColor(myData.vulnExploitBtn)
                myData.vulnExploitBtn.active=true
                myData.vulnExploitBtn.id=event.target.params.vulnId
            else
                local imageA = { type="image", filename="img/host_exploit_d.png" }
                myData.vulnExploitBtn.fill=imageA
                myData.vulnExploitBtn.active=false
            end
        end
    end
end

------------------ SCANNING ------------------------
local function serviceVulnsNetworkListener( event )
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

        for i in pairs(t.vulns) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            myData.targetServiceVulnsTable:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = fontSize(130),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        vulnName=t.vulns[i].vuln_name,
                        color=color,
                        vulnDisc=t.vulns[i].vuln_severity,
                    }
                }
            )
        end
        hsLoaded=true
   end
end

local function servicesNetworkListener( event )
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

        myData.targetServiceTable:deleteAllRows()
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

            myData.targetServiceTable:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = fontSize(130),
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
                    }  -- Include custom data in the row
                }
            )
        end
        hsSgroup.alpha=1

        if (t.task_total_time>0) then
            local percent=((t.task_total_time-t.task_time_left)/t.task_total_time)
            myData.hackProgressView2:setProgress( percent )
            myData.taskTimerT2.text=t.task_description.."\n\n"..timeText(t.task_time_left)
            myData.taskTimerT2.secondsLeft=t.task_time_left
            myData.taskTimerT2.total_time=t.task_total_time
            myData.taskTimerT2.desc=t.task_description

            if (hackActivityCountDownTimer2) then
                timer.cancel(hackActivityCountDownTimer2)
            end
            hackActivityCountDownTimer2 = timer.performWithDelay( 1000, updateHackActivityTimer2, 10000000 )
        else
            myData.taskTimerT2.text="Ready for the next step!\n\n\n"
        end

        hsLoaded=true
        tabClick=true
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
            myData.targetServiceTable:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", servicesNetworkListener, params )
        end 
   end
end

local function vulnScan(event)
    if ((myData.vulnScan.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
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
            myData.targetServiceTable:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", servicesNetworkListener, params )
        end 
   end
end

local function fingerprint(event)
    if ((myData.fingerprint.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
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
            myData.targetServiceTable:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", servicesNetworkListener, params )
        end 
   end
end

local function portScan(event)
    if ((myData.portScan.active==true) and (hsLoaded==true)) then
        tapSound()
        hsLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."hostPortScan.php", "POST", hostPortScanNetworkListener, params )
    end
end

local function serviceActionNetworkListener( event )
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
            myData.targetServiceTable:deleteAllRows()
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getHostDetails.php", "POST", servicesNetworkListener, params )
        end 
   end
end

local function serviceVulnScan(event)
    if (hsLoaded==true) then
        tapSound()
        hsLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&service_id="..event.target.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."serviceVulnScan.php", "POST", serviceActionNetworkListener, params )
    end
end

local function serviceFingerprint(event)
    if (hsLoaded==true) then
        tapSound()
        hsLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&service_id="..event.target.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."serviceFingerprint.php", "POST", serviceActionNetworkListener, params )
    end
end

local function onServiceVulnRowRender( event )

    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])

    --Port Scan
    row.rowTitle = display.newText( row, params.vulnName, 0, 0, native.systemFont, fontSize(55) )
    row.rowTitle.anchorX=0
    row.rowTitle.anchorY=0
    row.rowTitle.x =  40
    row.rowTitle.y = fontSize(25)
    row.rowTitle:setTextColor( 1, 1, 1 )

    --Vulnerability Scan
    row.rowVuln = display.newImageRect( "img/delete.png",iconSize/2.2,iconSize/2.2 )
    row.rowVuln.anchorX = 0
    row.rowVuln.anchorY = 0.5
    row.rowVuln.x, row.rowVuln.y = row.width-(iconSize/2.2)-20, row.height/2
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
        local imageA = { type="image", filename="img/vulnerability_scan.png" }
        row.rowVuln.fill = imageA
        changeImgColor(row.rowVuln)
        row.rowVuln.id=params.id
        row.rowVuln:addEventListener("tap",serviceVulnScan)
    end
end

local function onServiceRowRender( event )

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
    row.rowTitle.y = fontSize(25)
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

local function onServiceRowTouch(event)
    if ((event.phase=="tap") and (hsLoaded==true)) then
        myData.targetServiceVulnsTable:deleteAllRows()
        hsLoaded=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&service_id="..event.target.params.id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getServiceVulns.php", "POST", serviceVulnsNetworkListener, params )
    end
end

------------------ RECON ------------------------
local function reconNetworkListener( event )
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

        myData.reconDetails.text="               Hostname: "..t.hostname.."\n\nDiscovered Services: "..t.services.."\nDiscovered Vulnerabilities: "..t.vulns.."\n\nOperating System: "..t.os   
        hsRgroup.alpha=1

        myData.userTable:deleteAllRows()
        if (t.usersN==0) then
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            myData.userTable:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = fontSize(130),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        firstname="No users found",
                        color=color,
                        lastname="",
                        role=0
                    }  -- Include custom data in the row
                }
            )
        end
        
        for i in pairs(t.users) do
            rowColor = {
              default = { 0, 0, 0, 0 }
            }
            lineColor = { 
              default = { 1, 0, 0 }
            }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end

            myData.userTable:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = fontSize(130),
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        firstname=t.users[i].firstname,
                        color=color,
                        lastname=t.users[i].lastname,
                        role=t.users[i].role
                    }
                }
            )
        end

        if (t.task_total_time>0) then
            local percent=((t.task_total_time-t.task_time_left)/t.task_total_time)
            myData.hackProgressView2:setProgress( percent )
            myData.taskTimerT2.text=t.task_description.."\n\n"..timeText(t.task_time_left)
            myData.taskTimerT2.secondsLeft=t.task_time_left
            myData.taskTimerT2.total_time=t.task_total_time
            myData.taskTimerT2.desc=t.task_description

            if (hackActivityCountDownTimer2) then
                timer.cancel(hackActivityCountDownTimer2)
            end
            hackActivityCountDownTimer2 = timer.performWithDelay( 1000, updateHackActivityTimer2, 10000000 )
        else
            myData.taskTimerT2.text="Ready for the next step!\n\n\n"
        end

        hsLoaded=true
        tabClick=true
   end
end

local function onUserRowRender( event )

    local row = event.row
    local params = event.row.params

    local userRole=" - User"
    if params.role=="2" then userRole=" - Admin"
    elseif params.role==0 then userRole="" end

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])

    row.rowTitle = display.newText( row, params.firstname.." "..params.lastname..userRole, 0, 0, native.systemFont, fontSize(55) )
    row.rowTitle.anchorX=0
    row.rowTitle.anchorY=0
    row.rowTitle.x =  40
    row.rowTitle.y = fontSize(25)
    row.rowTitle:setTextColor( 1, 1, 1 )

end

------------------ TAB HANDLERS ------------------------

hackActivitiesListener2 = function( event )
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
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
            local params = {}
            params.headers = headers
            params.body = body
            if (view=="recon") then
                network.request( host().."getHostRecon.php", "POST", reconNetworkListener, params )
            elseif (view=="scan") then
                network.request( host().."getHostDetails.php", "POST", servicesNetworkListener, params )
            elseif (view=="exploit") then
                network.request( host().."getHostVulns.php", "POST", vulnsNetworkListener, params )
            elseif (view=="post") then
                network.request( host().."getPostExploitation.php", "POST", postExploitationNetworkListener, params )
            elseif (view=="actions") then
                network.request( host().."getHostActions.php", "POST", hostActionsNetworkListener, params )
            end
        end 
   end
end

local function hackRTab(event)
    if ((tabClick==true) and (hsLoaded==true)) then
        tapSound()
        view="recon"
        tabClick=false
        hsLoaded=false
        print("Recon")
        myData.hackPhase.text="Reconnaisance"
        hsSgroup.alpha=0
        hsEgroup.alpha=0
        hsPgroup.alpha=0
        hsAgroup.alpha=0

        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getHostRecon.php", "POST", reconNetworkListener, params )
    end
end

local function hackSTab(event)
    if ((tabClick==true) and (hsLoaded==true)) then
        tapSound()
        view="scan"
        tabClick=false
        hsLoaded=false
        print("Scanning")
        myData.hackPhase.text="Scanning"
        hsRgroup.alpha=0
        hsEgroup.alpha=0
        hsPgroup.alpha=0
        hsAgroup.alpha=0

        myData.targetServiceTable:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getHostDetails.php", "POST", servicesNetworkListener, params )
    end
end

local function hackETab(event)
    if ((tabClick==true) and (hsLoaded==true)) then
        tapSound()
        view="exploit"
        tabClick=false
        hsLoaded=false
        print("Exploitation")
        myData.hackPhase.text="Exploitation"
        hsRgroup.alpha=0
        hsSgroup.alpha=0
        hsPgroup.alpha=0
        hsAgroup.alpha=0

        myData.vulnsTable:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getHostVulns.php", "POST", vulnsNetworkListener, params )
    end
end

local function hackPTab(event)
    if ((tabClick==true) and (hsLoaded==true)) then
        tapSound()
        view="post"
        tabClick=false
        hsLoaded=false
        print("Post-Exploitation")
        myData.hackPhase.text="Post-Exploitation"
        hsRgroup.alpha=0
        hsSgroup.alpha=0
        hsEgroup.alpha=0
        hsAgroup.alpha=0

        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getPostExploitation.php", "POST", postExploitationNetworkListener, params )
    end
end

local function hackATab(event)
    if ((tabClick==true) and (hsLoaded==true)) then
        tapSound()
        view="actions"
        tabClick=false
        hsLoaded=false
        print("Actions")
        myData.hackPhase.text="Actions"
        hsRgroup.alpha=0
        hsSgroup.alpha=0
        hsEgroup.alpha=0
        hsPgroup.alpha=0

        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getHostActions.php", "POST", hostActionsNetworkListener, params )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function hackScene:create(event)
    group = self.view

    tabClick=true

    loginInfo = localToken()
    hsLoaded=false

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

    myData.hackRect = display.newImageRect( "img/hack_rect.png",display.contentWidth-20, fontSize(1660))
    myData.hackRect.anchorX = 0.5
    myData.hackRect.anchorY = 0
    myData.hackRect.x, myData.hackRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height+10
    changeImgColor(myData.hackRect)

    myData.hackName = display.newText(myData.attackBtn.name,display.contentWidth/2,myData.hackRect.y+fontSize(50) ,native.systemFont, fontSize(50))
    myData.hackName.anchorX = 0.5
    myData.hackName.anchorY = 0.5

    myData.hackPhase = display.newText("Reconnaisance",display.contentWidth/2,myData.hackRect.y+fontSize(130) ,native.systemFont, fontSize(50))
    myData.hackPhase.anchorX = 0.5
    myData.hackPhase.anchorY = 0.5

    --Recon
    myData.imageHackR = display.newImageRect( "img/hack_rect.png", display.contentWidth-20, fontSize(1660) )
    myData.imageHackR.anchorX=0.5
    myData.imageHackR.anchorY=0
    myData.imageHackR.x,myData.imageHackR.y = myData.hackRect.x, myData.hackRect.y
    changeImgColor(myData.imageHackR)
    local maskHackR = graphics.newMask( "img/hack_rect_m1.png" )
    myData.imageHackR:setMask( maskHackR )
    myData.imageHackR.maskY=fontSize(55)
    myData.imageHackR.maskScaleY=maskScaleFactor()

    --Scanning
    myData.imageHackS = display.newImageRect( "img/hack_rect.png", display.contentWidth-20, fontSize(1660) )
    myData.imageHackS.anchorX=0.5
    myData.imageHackS.anchorY=0
    myData.imageHackS.x,myData.imageHackS.y = myData.hackRect.x, myData.hackRect.y
    changeImgColor(myData.imageHackS)
    local maskHackS = graphics.newMask( "img/hack_rect_m2.png" )
    myData.imageHackS:setMask( maskHackS )
    myData.imageHackS.maskY=fontSize(55)
    myData.imageHackS.maskScaleY=maskScaleFactor()

    --Exploitation
    myData.imageHackE = display.newImageRect( "img/hack_rect.png", display.contentWidth-20, fontSize(1660) )
    myData.imageHackE.anchorX=0.5
    myData.imageHackE.anchorY=0
    myData.imageHackE.x,myData.imageHackE.y = myData.hackRect.x, myData.hackRect.y
    changeImgColor(myData.imageHackE)
    local maskHackE = graphics.newMask( "img/hack_rect_m3.png" )
    myData.imageHackE:setMask( maskHackE )
    myData.imageHackE.maskY=fontSize(55)
    myData.imageHackE.maskScaleY=maskScaleFactor()

    --Post-Exploitation
    myData.imageHackP = display.newImageRect( "img/hack_rect.png", display.contentWidth-20, fontSize(1660) )
    myData.imageHackP.anchorX=0.5
    myData.imageHackP.anchorY=0
    myData.imageHackP.x,myData.imageHackP.y = myData.hackRect.x, myData.hackRect.y
    changeImgColor(myData.imageHackP)
    local maskHackP = graphics.newMask( "img/hack_rect_m4.png" )
    myData.imageHackP:setMask( maskHackP )
    myData.imageHackP.maskY=fontSize(55)
    myData.imageHackP.maskScaleY=maskScaleFactor()

    --Action
    myData.imageHackA = display.newImageRect( "img/hack_rect.png", display.contentWidth-20, fontSize(1660) )
    myData.imageHackA.anchorX=0.5
    myData.imageHackA.anchorY=0
    myData.imageHackA.x,myData.imageHackA.y = myData.hackRect.x, myData.hackRect.y
    changeImgColor(myData.imageHackA)
    local maskHackA = graphics.newMask( "img/hack_rect_m5.png" )
    myData.imageHackA:setMask( maskHackA )
    myData.imageHackA.maskY=fontSize(55)
    myData.imageHackA.maskScaleY=maskScaleFactor()

    -- Recon Group --
    myData.reconDetails = display.newText("",myData.hackRect.x-myData.hackRect.width/2+40,myData.hackRect.y+fontSize(320) ,native.systemFont, fontSize(55))
    myData.reconDetails.anchorX = 0
    myData.reconDetails.anchorY = 0

    myData.userTableLabel = display.newText("Discovered Users",myData.hackRect.x, myData.hackRect.y+fontSize(380)+fontSize(430)+fontSize(30) ,native.systemFont, fontSize(55))
    myData.userTableLabel.anchorX = 0.5
    myData.userTableLabel.anchorY = 0

    myData.userTable = widget.newTableView(
        {
            left = myData.hackRect.x,
            top = myData.userTableLabel.y+fontSize(80),
            height = fontSize(500),
            width = myData.hackScanRect.width-60,
            onRowRender = onUserRowRender,
            --onRowTouch = onServiceRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.userTable.anchorX=0.5
    myData.userTable.x=myData.hackRect.x

    -- Scanning Group --
    myData.serviceTableLabel = display.newText("Discovered Services",myData.hackRect.x,myData.hackRect.y+fontSize(300) ,native.systemFont, fontSize(55))
    myData.serviceTableLabel.anchorX = 0.5
    myData.serviceTableLabel.anchorY = 0

    myData.targetServiceTable = widget.newTableView(
        {
            left = myData.hackRect.x,
            top = myData.hackRect.y+fontSize(390),
            height = fontSize(580),
            width = myData.hackScanRect.width-60,
            onRowRender = onServiceRowRender,
            onRowTouch = onServiceRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.targetServiceTable.anchorX=0.5
    myData.targetServiceTable.x=myData.hackRect.x

    myData.serviceVulnsTableLabel = display.newText("Discovered Vulnerabilities",myData.hackRect.x,myData.targetServiceTable.y+myData.targetServiceTable.height/2+fontSize(20) ,native.systemFont, fontSize(55))
    myData.serviceVulnsTableLabel.anchorX = 0.5
    myData.serviceVulnsTableLabel.anchorY = 0

    myData.targetServiceVulnsTable = widget.newTableView(
        {
            left = myData.hackRect.x,
            top = myData.serviceVulnsTableLabel.y+fontSize(75),
            height = fontSize(350),
            width = myData.hackScanRect.width-60,
            onRowRender = onServiceVulnRowRender,
            --onRowTouch = onServiceRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.targetServiceVulnsTable.anchorX=0.5
    myData.targetServiceVulnsTable.x=myData.hackRect.x

    -- Explotation Group --
    myData.vulnsTableLabel = display.newText("Exploitable Vulnerabilities",myData.hackRect.x,myData.hackRect.y+fontSize(300) ,native.systemFont, fontSize(55))
    myData.vulnsTableLabel.anchorX = 0.5
    myData.vulnsTableLabel.anchorY = 0

    myData.vulnsTable = widget.newTableView(
        {
            left = myData.hackRect.x,
            top = myData.hackRect.y+fontSize(380),
            height = fontSize(500),
            width = myData.hackScanRect.width-60,
            onRowRender = onServiceVulnRowRender,
            onRowTouch = onVulnsRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.vulnsTable.anchorX=0.5
    myData.vulnsTable.x=myData.hackRect.x

    local options = 
    {
        text = "\n\n\n\n",     
        x = display.contentWidth/2,
        y = myData.vulnsTable.y+myData.vulnsTable.height/2+fontSize(20),
        font = native.systemFont,   
        fontSize = fontSize(55),
        align = "center"
    }

    myData.vulnsDetails = display.newText(options)
    myData.vulnsDetails.anchorX = 0.5
    myData.vulnsDetails.anchorY = 0

    myData.vulnExploitBtn = display.newImageRect( "img/host_exploit_d.png",iconSize,iconSize )
    myData.vulnExploitBtn.anchorX = 0.5
    myData.vulnExploitBtn.anchorY = 0
    myData.vulnExploitBtn.x, myData.vulnExploitBtn.y = myData.vulnsDetails.x,myData.vulnsDetails.y+myData.vulnsDetails.height-fontSize(20)
    myData.vulnExploitBtn.alpha=0
    myData.vulnExploitBtn.active=false

    myData.vulnBruteUserPass = display.newImageRect( "img/bruteforceUser_d.png",iconSize,iconSize )
    myData.vulnBruteUserPass.anchorX = 0.5
    myData.vulnBruteUserPass.anchorY = 0
    myData.vulnBruteUserPass.x, myData.vulnBruteUserPass.y = myData.vulnsDetails.x-iconSize,myData.vulnsDetails.y+myData.vulnsDetails.height-fontSize(20)
    myData.vulnBruteUserPass.alpha=0
    myData.vulnBruteUserPass.active=false

    myData.vulnBrutePass = display.newImageRect( "img/bruteforcePass_d.png",iconSize,iconSize )
    myData.vulnBrutePass.anchorX = 0.5
    myData.vulnBrutePass.anchorY = 0
    myData.vulnBrutePass.x, myData.vulnBrutePass.y = myData.vulnsDetails.x+iconSize,myData.vulnsDetails.y+myData.vulnsDetails.height-fontSize(20)
    myData.vulnBrutePass.alpha=0
    myData.vulnBrutePass.active=false

    -- Post-Exploitation Group --
    myData.discoverUser = display.newImageRect( "img/discover_user_d.png",iconSize,iconSize )
    myData.discoverUser.anchorX = 0.5
    myData.discoverUser.anchorY = 0
    myData.discoverUser.x, myData.discoverUser.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/5,myData.hackRect.y+fontSize(340)
    myData.discoverUser.active=false

    myData.escalatePrivilege = display.newImageRect( "img/privilege_escalation_d.png",iconSize,iconSize )
    myData.escalatePrivilege.anchorX = 0.5
    myData.escalatePrivilege.anchorY = 0
    myData.escalatePrivilege.x, myData.escalatePrivilege.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/2,myData.discoverUser.y
    myData.escalatePrivilege.active=false

    myData.discoverConnection = display.newImageRect( "img/discover_connection_d.png",iconSize,iconSize )
    myData.discoverConnection.anchorX = 0.5
    myData.discoverConnection.anchorY = 0
    myData.discoverConnection.x, myData.discoverConnection.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/5*4,myData.discoverUser.y
    myData.discoverConnection.active=false

    myData.postExploitationDetails = display.newText("",myData.hackRect.x-myData.hackRect.width/2+40,myData.discoverUser.y+myData.discoverUser.height+fontSize(50),native.systemFont, fontSize(55))
    myData.postExploitationDetails.anchorX = 0
    myData.postExploitationDetails.anchorY = 0

    -- Action Group --
    myData.keylogger = display.newImageRect( "img/keylogger_d.png",iconSize,iconSize )
    myData.keylogger.anchorX = 0.5
    myData.keylogger.anchorY = 0
    myData.keylogger.x, myData.keylogger.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/5,myData.hackRect.y+fontSize(340)
    myData.keylogger.active=false

    myData.proxy = display.newImageRect( "img/proxy_d.png",iconSize,iconSize )
    myData.proxy.anchorX = 0.5
    myData.proxy.anchorY = 0
    myData.proxy.x, myData.proxy.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/2,myData.keylogger.y
    myData.proxy.active=false

    myData.exploitkit = display.newImageRect( "img/coming_soon.png",iconSize,iconSize )
    myData.exploitkit.anchorX = 0.5
    myData.exploitkit.anchorY = 0
    myData.exploitkit.x, myData.exploitkit.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/5*4,myData.keylogger.y
    myData.exploitkit.active=false

    myData.dataexfiltration = display.newImageRect( "img/dataexfiltration_d.png",iconSize,iconSize )
    myData.dataexfiltration.anchorX = 0.5
    myData.dataexfiltration.anchorY = 0
    myData.dataexfiltration.x, myData.dataexfiltration.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/5,myData.keylogger.y+myData.keylogger.height+fontSize(30)
    myData.dataexfiltration.active=false

    myData.dumpdb = display.newImageRect( "img/dumpdb_d.png",iconSize,iconSize )
    myData.dumpdb.anchorX = 0.5
    myData.dumpdb.anchorY = 0
    myData.dumpdb.x, myData.dumpdb.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/2,myData.dataexfiltration.y
    myData.dumpdb.active=false

    myData.alterdata = display.newImageRect( "img/alterdata_d.png",iconSize,iconSize )
    myData.alterdata.anchorX = 0.5
    myData.alterdata.anchorY = 0
    myData.alterdata.x, myData.alterdata.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/5*4,myData.dataexfiltration.y
    myData.alterdata.active=false

    myData.shutdown = display.newImageRect( "img/shutdown_d.png",iconSize,iconSize )
    myData.shutdown.anchorX = 0.5
    myData.shutdown.anchorY = 0
    myData.shutdown.x, myData.shutdown.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/5,myData.dataexfiltration.y+myData.dataexfiltration.height+fontSize(30)
    myData.shutdown.active=false

    myData.defacement = display.newImageRect( "img/coming_soon.png",iconSize,iconSize )
    myData.defacement.anchorX = 0.5
    myData.defacement.anchorY = 0
    myData.defacement.x, myData.defacement.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/2,myData.shutdown.y
    myData.defacement.active=false

    myData.ransomware = display.newImageRect( "img/ransomware_d.png",iconSize,iconSize )
    myData.ransomware.anchorX = 0.5
    myData.ransomware.anchorY = 0
    myData.ransomware.x, myData.ransomware.y = myData.hackRect.x-myData.hackRect.width/2+myData.hackRect.width/5*4,myData.shutdown.y
    myData.ransomware.active=false

    local options = 
    {
        text = "",     
        x = display.contentWidth/2,
        y = myData.ransomware.y+myData.ransomware.height+fontSize(50),
        width = myData.hackRect.width-40,
        font = native.systemFont,   
        fontSize = fontSize(50),
        align = "center"
    }

    myData.actionMessage = display.newText(options)
    myData.actionMessage.anchorX = 0.5
    myData.actionMessage.anchorY = 0

    -------------------

    local options = {
        width = 64,
        height = 64,
        numFrames = 6,
        sheetContentWidth = 384,
        sheetContentHeight = 64
    }
    local progressSheet = graphics.newImageSheet( progressColor, options )
    myData.hackProgressView2 = widget.newProgressView(
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
            left = display.contentWidth/2+40,
            top = myData.userTable.y,
            width = myData.hackRect.width-80,
            height = fontSize(100),
            isAnimated = true
        }
    )
    myData.hackProgressView2.anchorX=0.5
    myData.hackProgressView2.anchorY=0.5
    myData.hackProgressView2.x,myData.hackProgressView2.y=display.contentWidth/2,myData.userTable.y+myData.userTable.height/2+fontSize(100)

    local options = 
    {
        text = "",
        x = myData.hackRect.x,
        y = myData.hackProgressView2.y+fontSize(5),
        width = myData.hackRect.width-40,
        font = native.systemFont,   
        fontSize = fontSize(50),
        align = "center"
    }

    myData.taskTimerT2 = display.newText(options)
    myData.taskTimerT2.secondsLeft=0

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
        onEvent = goBackHack
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
    group:insert(myData.hackName)
    group:insert(myData.hackPhase)
    group:insert(myData.imageHackR)
    group:insert(myData.imageHackS)
    group:insert(myData.imageHackE)
    group:insert(myData.imageHackP)
    group:insert(myData.imageHackA)

    hsRgroup=display.newGroup()
    hsRgroup:insert(myData.reconDetails)
    hsRgroup:insert(myData.userTableLabel)
    hsRgroup:insert(myData.userTable)

    hsSgroup=display.newGroup()
    hsSgroup:insert(myData.targetServiceTable)
    hsSgroup:insert(myData.serviceTableLabel)
    hsSgroup:insert(myData.serviceVulnsTableLabel)
    hsSgroup:insert(myData.targetServiceVulnsTable)
    hsSgroup.alpha=0

    hsEgroup=display.newGroup()
    hsEgroup:insert(myData.vulnsTableLabel)
    hsEgroup:insert(myData.vulnsTable)
    hsEgroup:insert(myData.vulnsDetails)
    hsEgroup:insert(myData.vulnExploitBtn)
    hsEgroup:insert(myData.vulnBrutePass)
    hsEgroup:insert(myData.vulnBruteUserPass)
    hsEgroup.alpha=0

    hsPgroup=display.newGroup()
    hsPgroup:insert(myData.discoverUser)
    hsPgroup:insert(myData.escalatePrivilege)
    hsPgroup:insert(myData.discoverConnection)
    hsPgroup:insert(myData.postExploitationDetails)
    hsPgroup.alpha=0

    hsAgroup=display.newGroup()
    hsAgroup:insert(myData.keylogger)
    hsAgroup:insert(myData.proxy)
    hsAgroup:insert(myData.exploitkit)
    hsAgroup:insert(myData.dataexfiltration)
    hsAgroup:insert(myData.dumpdb)
    hsAgroup:insert(myData.alterdata)
    hsAgroup:insert(myData.shutdown)
    hsAgroup:insert(myData.defacement)
    hsAgroup:insert(myData.ransomware)
    hsAgroup:insert(myData.actionMessage)
    hsAgroup.alpha=0

    group:insert(hsRgroup)
    group:insert(hsSgroup)
    group:insert(hsEgroup)
    group:insert(hsPgroup)
    group:insert(hsAgroup)
    group:insert(myData.hackProgressView2)
    group:insert(myData.taskTimerT2)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackHack)
    myData.imageHackR:addEventListener("tap",hackRTab)
    myData.imageHackS:addEventListener("tap",hackSTab)
    myData.imageHackE:addEventListener("tap",hackETab)
    myData.imageHackP:addEventListener("tap",hackPTab)
    myData.imageHackA:addEventListener("tap",hackATab)

    myData.vulnExploitBtn:addEventListener("tap",vulnExploit)
    myData.vulnBruteUserPass:addEventListener("tap",bruteforceUserPass)
    myData.vulnBrutePass:addEventListener("tap",bruteforcePass)

    myData.discoverUser:addEventListener("tap",discoverUser)
    myData.escalatePrivilege:addEventListener("tap",escalatePrivilege)
    myData.discoverConnection:addEventListener("tap",discoverConnection)

    myData.keylogger:addEventListener("tap",keylogger)
    myData.proxy:addEventListener("tap",proxy)
    --myData.exploitkit:addEventListener("tap",exploitkit)
    myData.dataexfiltration:addEventListener("tap",dataexfiltration)
    myData.dumpdb:addEventListener("tap",dumpdb)
    myData.alterdata:addEventListener("tap",alterdata)
    myData.shutdown:addEventListener("tap",shutdown)
    --myData.defacement:addEventListener("tap",defacement)
    myData.ransomware:addEventListener("tap",ransomware)

end

-- Home Show
function hackScene:show(event)
    local logGroup = self.view
    if event.phase == "will" then
        -- local tutCompleted = loadsave.loadTable( "logTutorialStatus.json" )  
        -- if (tutCompleted == nil) or (tutCompleted.tutLog ~= true) then
        --     tutOverlay = true
        --     local sceneOverlayOptions = 
        --     {
        --         time = 0,
        --         effect = "crossFade",
        --         params = { },
        --         isModal = true
        --     }
        --     composer.showOverlay( "logTutScene", sceneOverlayOptions) 
        -- else
        --     tutOverlay = false
        -- end
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&host_id="..params.target_id
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getHostRecon.php", "POST", reconNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
hackScene:addEventListener( "create", hackScene )
hackScene:addEventListener( "show", hackScene )
---------------------------------------------------------------------------------

return hackScene