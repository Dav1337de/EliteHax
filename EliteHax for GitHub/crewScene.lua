local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local crewScene = composer.newScene()
local adding=false
local removing=false
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function addChat(objectName, username, message, mine, system, timestamp)
    local currScene = composer.getSceneName( "current" )
    if (currScene == "crewScene") then
        if (mine == "Y") then
            mine_padding = 140
        else
            mine_padding = 0
        end
        if (myData.chatRect ~= nil) then
            myData[objectName] = display.newText(message,20+mine_padding,totalHeight ,myData.chatRect.width-250,0,native.systemFont, fontSize(35))
            myData[objectName].anchorX = 0
            myData[objectName].anchorY = 0
            myData[objectName]:setFillColor( 0.9,0.9,0.9 )

            timestampObjName = objectName.."Timestamp"
            myData[timestampObjName] = display.newText(timestamp,20+mine_padding,myData[objectName].y+myData[objectName].height+15,600,0,native.systemFont, fontSize(22))
            myData[timestampObjName].anchorX = 0
            myData[timestampObjName].anchorY = 0
            myData[timestampObjName]:setFillColor( 0.9,0.9,0.9 )
            myData[timestampObjName].padding = mine_padding

            user_length = string.len(username)+2
            userObjectName = objectName.."Usr"
            myData[userObjectName] = display.newText(username,myData[objectName].width-(user_length*2)*7+mine_padding,myData[objectName].y+myData[objectName].height+10,300,0,native.systemFont, fontSize(26))
            myData[userObjectName].anchorX = 0
            myData[userObjectName].anchorY = 0
            myData[userObjectName]:setFillColor( 0.9,0.9,0.9 )
            myData[userObjectName].padding = mine_padding

            rectObjectName = objectName.."Rect"
            myData[rectObjectName] = display.newRoundedRect( myData[objectName].x-20, myData[objectName].y-10, myData[objectName].width+20, myData[objectName].height+myData[userObjectName].height+20, 12 )
            myData[rectObjectName].anchorX = 0
            myData[rectObjectName].anchorY = 0
            myData[rectObjectName].strokeWidth = 5
            myData[rectObjectName]:setFillColor( 0,0,0,0.5 )
            if (system == "Y") then 
                myData[rectObjectName]:setStrokeColor( 0.7, 0, 0 )
            else
                myData[rectObjectName]:setStrokeColor( 0, 0.7, 0 )

            end
            --myData.chatRect.alpha = 1
            if (myData.scrollAreaCrewChat) then
                myData.scrollAreaCrewChat:insert(myData[rectObjectName])
                myData.scrollAreaCrewChat:insert(myData[userObjectName])
                myData.scrollAreaCrewChat:insert(myData[timestampObjName])
                myData.scrollAreaCrewChat:insert(myData[objectName])
            else
                myData[timestampObjName]:removeSelf()
                myData[timestampObjName]=nil
                myData[rectObjectName]:removeSelf()
                myData[rectObjectName]=nil
                myData[userObjectName]:removeSelf()
                myData[userObjectName]=nil
                myData[objectName]:removeSelf()
                myData[objectName]=nil
            end
        end
    end
end

local function scrollToBottom(event)
    if (myData.scrollAreaCrewChat) then
        myData.scrollAreaCrewChat:scrollToPosition{y = (-myData.scrollAreaCrewChat._view._scrollHeight+myData.scrollAreaCrewChat.height+20),time = 100} 
    end
end

local function chatReceiveListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" } )
    else
        --print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
        end
        if (cRefreshChat==false) then
            if (t.crew_chats[1] ~= nil) then            
                totalHeight=20
                chat_changed = true
                for i=1,chatMsg,1 do
                    cObjName1 = "msgText"..i
                    if ((i == 1) and (myData[cObjName1] == t.crew_chats[1].msg)) then chat_changed = false end
                    usercObjName1 = cObjName1.."Usr"
                    timestampcObjName1 = cObjName1.."Timestamp"
                    rectcObjName1 = cObjName1.."Rect"
                    if ((myData[cObjName1]) and (myData[cObjName1].text ~= nil)) then
                        myData[cObjName1]:removeSelf()
                        myData[cObjName1] = nil
                        myData[usercObjName1]:removeSelf()
                        myData[usercObjName1] = nil
                        myData[timestampcObjName1]:removeSelf()
                        myData[timestampcObjName1] = nil
                        myData[rectcObjName1]:removeSelf()
                        myData[rectcObjName1] = nil
                    end
                end
                chatMsg = 0
                adding=true
                for i in pairs( t.crew_chats ) do
                    objectName = "msgText"..i
                    addChat(objectName,t.crew_chats[i].username,t.crew_chats[i].msg,t.crew_chats[i].mine,t.crew_chats[i].system,makeTimeStamp(t.crew_chats[i].timestamp))
                    chatMsg=chatMsg+1
                    if (myData[objectName]) then
                        totalHeight = totalHeight + myData[objectName].height+fontSize(70)
                    end
                end
                if (myData.scrollAreaCrewChat) then
                    objectName = "msgText51"
                    myData[objectName] = display.newText("",20,totalHeight ,native.systemFont, fontSize(50))
                    myData[objectName].anchorX = 0
                    myData[objectName].anchorY = 0
                    myData[objectName]:setFillColor( 0,0.7,0 )
                    myData.scrollAreaCrewChat:insert(myData[objectName])
                    totalHeight = totalHeight+myData[objectName].height+fontSize(70)
                    myData.scrollAreaCrewChat:setScrollHeight( totalHeight )
                end
                if (disableScroll==false) then
                    timer.performWithDelay(10,scrollToBottom,1)
                end
                adding=false
            end
        end
    end    
    cRefreshChat=true
end

local function chatRefresh ( event )
    if (cRefreshChat==true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        cRefreshChat=false
        network.request( host().."getCrewChat.php", "POST", chatReceiveListener, params )
    end
end

local function crewLogRefresh ( event )
    if (cRefreshChat==true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        cRefreshChat=false
        network.request( host().."getCrewLog.php", "POST", chatReceiveListener, params )
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

local function sendChatListener( event )
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

        if ( t.status == "OK") then
            chatSent=0
            myData.crewChatInput.text = ""
        end
    end
end

local function sendChat( event )
    if ((event.phase == "ended") and (string.len(myData.crewChatInput.text) > 0) and (chatSent == 0)) then
        chatSent=1
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&message="..string.urlEncode(myData.crewChatInput.text)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."sendCrewChat.php", "POST", sendChatListener, params )
    end
end

local function closeCC( event )
    if (adding==true) then 
        timer.performWithDelay(50,closeCC,1)
    else
        if (myData.chatRect.alpha==1) then
            backSound()
        end
        removing=true
        if (chatTimer) then
            timer.cancel(chatTimer)
        end
        cRefreshChat=true
        myData.chatRect.alpha=0
        myData.sendChatButton.alpha=0
        --myData.crewChatInput.alpha=0
        native.setKeyboardFocus(nil)
        for i=1,chatMsg,1 do
            cObjName1 = "msgText"..i
            usercObjName1 = cObjName1.."Usr"
            timestampcObjName1 = cObjName1.."Timestamp"
            rectcObjName1 = cObjName1.."Rect"
            if (myData[cObjName1].text ~= nil) then
                myData[cObjName1]:removeSelf()
                myData[cObjName1] = nil
                myData[usercObjName1]:removeSelf()
                myData[usercObjName1] = nil
                myData[timestampcObjName1]:removeSelf()
                myData[timestampcObjName1] = nil
                myData[rectcObjName1]:removeSelf()
                myData[rectcObjName1] = nil
            end
        end
        chatMsg=0
        if (myData.scrollAreaCrewChat) then
            myData.scrollAreaCrewChat:removeSelf()
            myData.scrollAreaCrewChat=nil
        end
        if (myData.closeCCBtn ~= nil) then
            myData.closeCCBtn:removeSelf()
            myData.closeCCBtn = nil
        end
        if (myData.crewChatInput) then
            myData.crewChatInput:removeSelf()
            myData.crewChatInput=nil
        end
        chatOpen=0
        removing=false
    end
end

local function cChatScroll(event)
    if (event.phase=="moved") then
        if (event.direction=="down") then
            --print("Scroll Disabled")
            disableScroll=true
        end
    end
    if ((event.limitReached==true) and (event.direction=="up")) then
        disableScroll=false
        --print("Scroll Enabled")
    end
end

local function openTournamentLogs(event)
    chatOpen=1
    myData.crewLogsText.text="0"
    local imageA = { type="image", filename="img/crew_logs_rect.png" }
    myData.chatRect.fill = imageA  
    changeImgColor(myData.chatRect)
    myData.chatRect:toFront()
    myData.sendChatButton:toFront()

    myData.scrollAreaCrewChat = widget.newScrollView(
    {
        top = myData.chatRect.y-myData.chatRect.height/4+fontSize(90),
        left = myData.chatRect.x-myData.chatRect.width/2+40,
        width = display.contentWidth,
        height = myData.chatRect.height-fontSize(250),
        scrollWidth = 520,
        scrollHeight = 2000,
        backgroundColor = { 0, 0, 0, 0},
        horizontalScrollDisabled = true,
        isBounceEnabled = true,
        listener = cChatScroll
    })
    myData.scrollAreaCrewChat.alpha=0
    myData.scrollAreaCrewChat.anchorY=0
    group:insert(myData.scrollAreaCrewChat)
    myData.scrollAreaCrewChat.y = myData.chatRect.y+fontSize(110)
    myData.scrollAreaCrewChat.height = myData.chatRect.height-fontSize(275)
    myData.scrollAreaCrewChat:toFront()
    disableScroll=false
    myData.scrollAreaCrewChat:addEventListener("touch",cChatScroll)

    -- Close Button
    if (myData.closeCCBtn) then
        myData.closeCCBtn:removeSelf()
        myData.closeCCBtn=nil
    end
    -- Close Button
    myData.closeCCBtn = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.closeCCBtn.anchorX = 0
    myData.closeCCBtn.anchorY = 0
    myData.closeCCBtn.x, myData.closeCCBtn.y = myData.chatRect.width-iconSize/2.5-15, myData.chatRect.y+fontSize(55)
    changeImgColor(myData.closeCCBtn)
    group:insert(myData.closeCCBtn)
    myData.closeCCBtn:addEventListener("tap", closeCC)
    myData.chatRect.alpha=1
    myData.scrollAreaCrewChat.alpha=1

    cRefreshChat=true
    crewLogRefresh()
    if (chatTimer) then
        timer.cancel(chatTimer)
    end
    chatTimer = timer.performWithDelay( 2000, crewLogRefresh, 0 )
end

local function onChatEdit( event )
    if (event.phase == "began") then

    end
    if (event.phase == "editing") then
        if (string.len(event.text)>200) then
            myData.crewChatInput.text = string.sub(event.text,1,200)
        end
        --if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s%?]")) then
        --    myData.crewChatInput.text = string.sub(event.text,1,string.len(event.text)-1)
        --end
    end
    if (event.phase == "ending") then  
    end
end

local function openCChat(event)
    tapSound()
    chatOpen=1
    myData.crewChatText.text="0"
    local imageA = { type="image", filename="img/crew_chat_ext.png" }
    myData.chatRect.fill = imageA  
    changeImgColor(myData.chatRect)
    myData.chatRect:toFront()
    myData.sendChatButton:toFront()

    --myData.scrollAreaCrewChat:setScrollHeight( myData.chatRect.height+2000 )
    --myData.scrollAreaCrewChat:scrollToPosition{y = -myData.scrollAreaCrewChat._view.height,time = 200}
    myData.scrollAreaCrewChat = widget.newScrollView(
    {
        top = myData.chatRect.y-myData.chatRect.height/4+fontSize(90),
        left = myData.chatRect.x-myData.chatRect.width/2+40,
        width = display.contentWidth,
        height = myData.chatRect.height-fontSize(250),
        scrollWidth = 520,
        scrollHeight = 2000,
        backgroundColor = { 0, 0, 0, 0},
        horizontalScrollDisabled = true,
        isBounceEnabled = true,
        listener = cChatScroll
    })
    myData.scrollAreaCrewChat.alpha=0
    myData.scrollAreaCrewChat.anchorY=0
    group:insert(myData.scrollAreaCrewChat)
    myData.scrollAreaCrewChat.y = myData.chatRect.y+fontSize(110)
    myData.scrollAreaCrewChat.height = myData.chatRect.height-fontSize(275)
    myData.scrollAreaCrewChat:toFront()
    disableScroll=false
    myData.scrollAreaCrewChat:addEventListener("touch",cChatScroll)

    -- Close Button
    if (myData.closeCCBtn) then
        myData.closeCCBtn:removeSelf()
        myData.closeCCBtn=nil
    end
    -- Close Button
    myData.closeCCBtn = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.closeCCBtn.anchorX = 0
    myData.closeCCBtn.anchorY = 0
    myData.closeCCBtn.x, myData.closeCCBtn.y = myData.chatRect.width-iconSize/2.5-15, myData.chatRect.y+fontSize(55)
    changeImgColor(myData.closeCCBtn)
    group:insert(myData.closeCCBtn)
    myData.closeCCBtn:addEventListener("tap", closeCC)

    --Chat Input
    chatMsg = 0
    if (myData.crewChatInput) then
        myData.crewChatInput:removeSelf()
        myData.crewChatInput=nil
    end
    myData.crewChatInput = native.newTextField( myData.chatRect.x-myData.chatRect.width/2+40, myData.chatRect.y+myData.chatRect.height-fontSize(120), myData.chatRect.width-300, fontSize(75) )
    myData.crewChatInput.anchorX = 0
    myData.crewChatInput.anchorY = 0
    myData.crewChatInput.placeholder = "Send Message to Crew";
    myData.crewChatInput:addEventListener("userInput", onChatEdit )

    myData.chatRect.alpha=1
    myData.scrollAreaCrewChat.alpha=1
    myData.sendChatButton.alpha=1

    cRefreshChat=true
    chatRefresh()
    if (chatTimer) then
        timer.cancel(chatTimer)
    end
    chatTimer = timer.performWithDelay( 1000, chatRefresh, 0 )
end

local function leaveListener( event )
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

        if ( t.status == "OK") then
            goBackCrew()
        end
    end
end


local function dontLeave( event )
end

local function leaveCrew( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."leaveCrew.php", "POST", leaveListener, params )
    elseif ( i == 2 ) then
        backSound()
        dontLeave()    
    end
end

local function goMembers( event)
    if (chatOpen==0) then
        print("goMembers")
        if (cRefreshChat==false) then 
            timer.performWithDelay(100,goMembers)
        else
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            local sceneOverlayOptions = 
            {
                time = 100,
                effect = "crossFade",
                --isModal = true
            }
            composer.removeScene( "crewScene" )
            closeCC()
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            if (chatTimer) then
                timer.cancel( chatTimer )
            end
            tapSound()
            composer.gotoScene( "myCrewMembersScene", sceneOverlayOptions)
        end
    end
end

local function comingSoon( event )
    local i = event.index
    if ( i == 1 ) then
        
    elseif ( i == 2 ) then
        system.openURL( "https://youtu.be/XCUcyIbi5FM" )
    end
end

local function goSettings( event)
    if ((chatOpen==0) and (event.target.active==true)) then
        if (cRefreshChat==false) then 
            timer.performWithDelay(100,goSettings)
        else
            local sceneOverlayOptions = 
            {
                time = 100,
                effect = "crossFade",
                --isModal = true
            }
            closeCC()
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            if (chatTimer) then
                timer.cancel( chatTimer )
            end
            tapSound()
            composer.removeScene( "crewScene" )
            composer.gotoScene( "crewSettingScene", {effect = "fade", time = 100})
        end
    end
end

local function goToDefendDatacenter( event)
    if ((chatOpen==0) and (event.target.active==true)) then
        --local alert = native.showAlert( "EliteHax", "Coming Soon!", { "Close","Watch Trailer!" }, comingSoon )
        if (cRefreshChat==false) then 
            timer.performWithDelay(100,goSettings)
        else
            local sceneOverlayOptions = 
            {
                time = 100,
                effect = "crossFade",
                --isModal = true
            }
            closeCC()
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            if (chatTimer) then
                timer.cancel( chatTimer )
            end
            tapSound()
            composer.removeScene( "crewScene" )
            composer.gotoScene( "defendDatacenterScene", {effect = "fade", time = 100})
        end
    end
end

local function goToDatacenter( event)
    if ((chatOpen==0) and (event.target.active==true)) then
        --local alert = native.showAlert( "EliteHax", "Coming Soon!", { "Close","Watch Trailer!" }, comingSoon )
        if (cRefreshChat==false) then 
            timer.performWithDelay(100,goSettings)
        else
            local sceneOverlayOptions = 
            {
                time = 100,
                effect = "crossFade",
                --isModal = true
            }
            closeCC()
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            if (chatTimer) then
                timer.cancel( chatTimer )
            end
            tapSound()
            composer.removeScene( "crewScene" )
            composer.gotoScene( "myDatacenterScene", {effect = "fade", time = 100})
        end
    end
end

local function goToMap( event)
    if ((chatOpen==0) and (event.target.active==true)) then
        --local alert = native.showAlert( "EliteHax", "Coming Soon!", { "Close","Watch Trailer!" }, comingSoon )
        if (cRefreshChat==false) then 
            timer.performWithDelay(100,goSettings)
        else
            local sceneOverlayOptions = 
            {
                time = 100,
                effect = "crossFade",
                --isModal = true
            }
            closeCC()
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            if (chatTimer) then
                timer.cancel( chatTimer )
            end
            tapSound()
            composer.removeScene( "crewScene" )
            composer.gotoScene( "mapScene", {effect = "fade", time = 100})
        end
    end
end

local function goRequests( event)
    if ((chatOpen==0) and (event.target.active==true)) then
        if (cRefreshChat==false) then 
            timer.performWithDelay(100,goRequests)
        else
            local sceneOverlayOptions = 
            {
                time = 100,
                effect = "crossFade",
                --isModal = true
            }
            composer.removeScene( "crewScene" )
            closeCC()
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            if (chatTimer) then
                timer.cancel( chatTimer )
            end
            tapSound()
            composer.gotoScene( "myCrewRequestsScene", sceneOverlayOptions)
        end
    end
end

local function goToCrewLogs(event)
    if (chatOpen==0) then
        if (cRefreshChat==false) then 
            timer.performWithDelay(100,goToCrewLogs)
        else
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            closeCC()
            if (chatTimer) then
                timer.cancel( chatTimer )
            end
            tapSound()
            composer.removeScene( "crewScene" )
            composer.gotoScene( "crewLogsScene", sceneOverlayOptions)
        end
    end
end

local function leaveAlert ( event )
    if (chatOpen==0) then
        if (myData.crewName.role == 1) then
            backSound()
            local alert = native.showAlert( "EliteHax", "You are the Crew Mentor!\nYou cannot leave the Crew!", { "Ok" }, dontLeave )
        else
            tapSound()
            local alert = native.showAlert( "EliteHax", "Are you sure you want to leave the Crew?", { "Yes", "No" }, leaveCrew )     
        end
    end
end

local function crewNetworkListener( event )
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

        --Money
        myData.moneyTextCrew.text = format_thousand(t.money)
        myData.moneyTextCrew.money = t.money

        --Player
        if (string.len(t.username)>15) then myData.playerTextCrew.size = fontSize(42) end
        myData.playerTextCrew.text = t.username

        --Details
        myData.crewName.text = t.name
        myData.crewTag.text = "("..t.tag..")"
        if (string.len(t.desc)>20) then myData.crewDesc.size = fontSize(52) end
        myData.crewDesc.text = t.desc
        myData.crewStats.text = "Rank: "..format_thousand(t.crank).."\nMembers: "..t.members.." / "..t.slot.."\nScore: "..format_thousand(t.cscore).."\n"
        if (t.tournament_best>1) then
            myData.crewStats.text=myData.crewStats.text.."Best Tournament Rank: "..t.tournament_best.."\n"
        else
            myData.crewStats.text=myData.crewStats.text.."Tournaments Won: "..t.tournament_won.."\n"
        end
        myData.crewStats.text = myData.crewStats.text.."Crew Wallet: $ "..format_thousand(t.wallet).."\nDaily Crew Wallet: $ "..format_thousand(t.daily_wallet).."/"..format_thousand(5000000*t.members).."\nYour daily contribution: $ "..format_thousand(t.crew_daily_contribution).."/"..format_thousand(5000000)
        myData.crewName.role = t.crew_role
        myData.requestsText.text=t.requests
        
        --Crew Wars Buttons
        if (t.crew_role <= 4) then
            myData.crewWarsDefend.active=true
            myData.crewWarsAttack.active=true
        else
            myData.crewWarsDefend.fill.effect="filter.desaturate"
            myData.crewWarsDefend.fill.effect.intensity=1
            myData.crewWarsAttack.fill.effect="filter.desaturate"
            myData.crewWarsAttack.fill.effect.intensity=1
        end
        if (t.crew_role <= 3) then
            myData.crewDatacenter.active=true
        else
            myData.crewDatacenter.fill.effect="filter.desaturate"
            myData.crewDatacenter.fill.effect.intensity=1
        end
        --Crew Settings
        if (t.crew_role <= 2) then
            myData.crewSetting.active=true
        else
            myData.crewSetting.fill.effect="filter.desaturate"
            myData.crewSetting.fill.effect.intensity=1
        end
        --Crew Requests
        if (t.crew_role <= 4) then
            myData.crewRequests.active=true
        else
            myData.crewRequests.fill.effect="filter.desaturate"
            myData.crewRequests.fill.effect.intensity=1
            myData.requestsCircle:setStrokeColor(80,80,80)
            myData.requestsText:setTextColor(80,80,80)
        end

        --Chat & Logs counters
        myData.crewChatText.text=t.crew_chats
        myData.crewLogsText.text=t.crew_logs
    end
    loaded = true
end

function goBackCrew(event)
    if (cRefreshChat==false) then 
        timer.performWithDelay(100,goBackCrew)
    else
        if (tutOverlay==false) then
            if (chatOpen==1) then
                backSound()
                closeCC()
            else
                closeCC()
                if (myData.crewChatInput) then
                    myData.crewChatInput:removeSelf()
                    myData.crewChatInput = nil
                end
                if (chatTimer) then
                    timer.cancel( chatTimer )
                end
                backSound()
                composer.removeScene( "crewScene" )
                composer.gotoScene("homeScene", {effect = "fade", time = 100})
            end
        end
    end
end

local function goBack(event)
    if ((event.phase == "ended") and (loaded == true)) then
        if (cRefreshChat==false) then 
            timer.performWithDelay(100,goBackCrew)
        else
            if (chatTimer) then
                timer.cancel( chatTimer )
            end
            closeCC()
            if (myData.crewChatInput) then
                myData.crewChatInput:removeSelf()
                myData.crewChatInput = nil
            end
            backSound()
            composer.removeScene( "crewScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 100})
        end
    end
end
---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewScene:create(event)
    loaded = false

    group = self.view

    loginInfo = localToken()

    chatOpen=0
    chatSent=0
    cRefreshChat=true

    iconSize=fontSize(200)

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextCrew = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextCrew.anchorX = 0
    myData.moneyTextCrew.anchorY = 0.5
    myData.moneyTextCrew:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextCrew = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextCrew.anchorX = 0.5
    myData.playerTextCrew.anchorY = 0.5
    myData.playerTextCrew:setFillColor( 0.9,0.9,0.9 )

    --Crew Rect
    myData.crewRect = display.newImageRect( "img/crew_members_rect.png",display.contentWidth-20, fontSize(1660))
    myData.crewRect.anchorX = 0.5
    myData.crewRect.anchorY = 0
    myData.crewRect.x, myData.crewRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.crewRect)

    -- Crew Name
    myData.crewName = display.newText( "", 0, 0, native.systemFont, fontSize(65) )
    myData.crewName.anchorX=0.5
    myData.crewName.anchorY=0
    myData.crewName.x =  display.contentWidth/2
    myData.crewName.y = myData.crewRect.y+fontSize(8)
    myData.crewName:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Tag
    myData.crewTag = display.newText( "", 0, 0, native.systemFont, fontSize(60) )
    myData.crewTag.anchorX=0.5
    myData.crewTag.anchorY=0
    myData.crewTag.x =  display.contentWidth/2
    myData.crewTag.y = myData.crewName.y+myData.crewName.height+fontSize(10)
    myData.crewTag:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Desc
    myData.crewDesc = display.newText( "", 0, 0, native.systemFont, fontSize(60) )
    myData.crewDesc.anchorX=0.5
    myData.crewDesc.anchorY=0
    myData.crewDesc.x =  display.contentWidth/2
    myData.crewDesc.y = myData.crewTag.y+myData.crewTag.height+fontSize(10)
    myData.crewDesc:setTextColor( 0.9, 0.9, 0.9 )

    -- Crew Stats
    myData.crewStats = display.newText( "\n\n\n\n\n\n", 0, 0, native.systemFont, fontSize(48) )
    myData.crewStats.anchorX=0
    myData.crewStats.anchorY=0
    myData.crewStats.x =  40
    myData.crewStats.y = myData.crewDesc.y+myData.crewDesc.height+fontSize(20)
    myData.crewStats:setTextColor( 0.9, 0.9, 0.9 )

    myData.crewMembers = display.newImageRect( "img/crew_members.png",iconSize*1.3,iconSize*1.3 )
    myData.crewMembers.anchorX = 0.5
    myData.crewMembers.anchorY = 0
    myData.crewMembers.x, myData.crewMembers.y = display.contentWidth/2,myData.crewStats.y+myData.crewStats.height+fontSize(30)
    changeImgColor(myData.crewMembers)
    myData.crewMembers:addEventListener("tap",goMembers)

    myData.crewRequests = display.newImageRect( "img/crew_requests.png",iconSize*1.3,iconSize*1.3 )
    myData.crewRequests.anchorX = 0.5
    myData.crewRequests.anchorY = 0
    myData.crewRequests.x,myData.crewRequests.y = display.contentWidth/5*4,myData.crewStats.y+myData.crewStats.height+fontSize(30)
    changeImgColor(myData.crewRequests)
    myData.crewRequests.active=false
    myData.crewRequests:addEventListener("tap",goRequests)
    myData.requestsCircle = display.newCircle( myData.crewRequests.x+myData.crewRequests.width/2-40,myData.crewRequests.y+fontSize(40), fontSize(40) )
    myData.requestsCircle:setFillColor( 0 )
    myData.requestsCircle.strokeWidth = 5
    myData.requestsCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.requestsText = display.newText("",myData.crewRequests.x+myData.crewRequests.width/2-40,myData.crewRequests.y+fontSize(40),native.systemFont, fontSize(52))
    myData.requestsText.anchorX = 0.5
    myData.requestsText.anchorY = 0.5
    myData.requestsText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    myData.crewSetting = display.newImageRect( "img/crew_setting.png",iconSize*1.3,iconSize*1.3 )
    myData.crewSetting.anchorX = 0.5
    myData.crewSetting.anchorY = 0
    myData.crewSetting.x,myData.crewSetting.y = display.contentWidth/5,myData.crewStats.y+myData.crewStats.height+fontSize(30)
    changeImgColor(myData.crewSetting)
    myData.crewSetting.active=false
    myData.crewSetting:addEventListener("tap",goSettings)

    myData.crewLogs = display.newImageRect( "img/crew_logs.png",iconSize*1.3,iconSize*1.3 )
    myData.crewLogs.anchorX = 0.5
    myData.crewLogs.anchorY = 0
    myData.crewLogs.x, myData.crewLogs.y = display.contentWidth/5,myData.crewMembers.y+myData.crewMembers.height+fontSize(40)
    changeImgColor(myData.crewLogs)
    myData.crewLogs:addEventListener("tap",goToCrewLogs)
    myData.crewLogsCircle = display.newCircle( myData.crewLogs.x+myData.crewLogs.width/2-40,myData.crewLogs.y+fontSize(40), fontSize(40) )
    myData.crewLogsCircle:setFillColor( 0 )
    myData.crewLogsCircle.strokeWidth = 5
    myData.crewLogsCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.crewLogsText = display.newText("",myData.crewLogs.x+myData.crewLogs.width/2-40,myData.crewLogs.y+fontSize(40),native.systemFont, fontSize(52))
    myData.crewLogsText.anchorX = 0.5
    myData.crewLogsText.anchorY = 0.5
    myData.crewLogsText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    myData.crewChat = display.newImageRect( "img/crew_chat.png",iconSize*1.3,iconSize*1.3 )
    myData.crewChat.anchorX = 0.5
    myData.crewChat.anchorY = 0
    myData.crewChat.x, myData.crewChat.y = display.contentWidth/2,myData.crewLogs.y
    changeImgColor(myData.crewChat)
    myData.crewChat:addEventListener("tap",openCChat)
    myData.crewChatCircle = display.newCircle( myData.crewChat.x+myData.crewChat.width/2-40,myData.crewChat.y+fontSize(40), fontSize(40) )
    myData.crewChatCircle:setFillColor( 0 )
    myData.crewChatCircle.strokeWidth = 5
    myData.crewChatCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.crewChatText = display.newText("",myData.crewChat.x+myData.crewChat.width/2-40,myData.crewChat.y+fontSize(40),native.systemFont, fontSize(52))
    myData.crewChatText.anchorX = 0.5
    myData.crewChatText.anchorY = 0.5
    myData.crewChatText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    myData.crewLeave = display.newImageRect( "img/crew_leave.png",iconSize*1.3,iconSize*1.3 )
    myData.crewLeave.anchorX = 0.5
    myData.crewLeave.anchorY = 0
    myData.crewLeave.x, myData.crewLeave.y = display.contentWidth/5*4,myData.crewLogs.y
    changeImgColor(myData.crewLeave)
    myData.crewLeave:addEventListener("tap",leaveAlert)

    myData.crewDatacenter = display.newImageRect( "img/datacenter-icon.png",iconSize*1.3,iconSize*1.3 )
    myData.crewDatacenter.anchorX = 0.5
    myData.crewDatacenter.anchorY = 0
    myData.crewDatacenter.x, myData.crewDatacenter.y = display.contentWidth/2,myData.crewLogs.y+myData.crewLogs.height+fontSize(40)
    changeImgColor(myData.crewDatacenter)
    myData.crewDatacenter.active=false
    myData.crewDatacenter:addEventListener("tap",goToDatacenter)

    myData.crewWarsDefend = display.newImageRect( "img/datacenter-defend.png",iconSize*1.3,iconSize*1.3 )
    myData.crewWarsDefend.anchorX = 0.5
    myData.crewWarsDefend.anchorY = 0
    myData.crewWarsDefend.x, myData.crewWarsDefend.y = display.contentWidth/5,myData.crewDatacenter.y
    changeImgColor(myData.crewWarsDefend)
    myData.crewWarsDefend.active=false
    myData.crewWarsDefend:addEventListener("tap",goToDefendDatacenter)

    myData.crewWarsAttack = display.newImageRect( "img/crew_wars.png",iconSize*1.3,iconSize*1.3 )
    myData.crewWarsAttack.anchorX = 0.5
    myData.crewWarsAttack.anchorY = 0
    myData.crewWarsAttack.x, myData.crewWarsAttack.y = display.contentWidth/5*4,myData.crewDatacenter.y
    changeImgColor(myData.crewWarsAttack)
    myData.crewWarsAttack.active=false
    myData.crewWarsAttack:addEventListener("tap",goToMap)

    --Crew Chat Rect
    myData.chatRect = display.newImageRect( "img/crew_chat_ext.png",display.contentWidth-20, display.actualContentHeight-fontSize(220))
    myData.chatRect.anchorX = 0.5
    myData.chatRect.anchorY = 0
    myData.chatRect.x, myData.chatRect.y = display.contentWidth/2,90+topPadding()
    changeImgColor(myData.chatRect)
    myData.chatRect.alpha=0

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
        onEvent = goBack
    })

    myData.sendChatButton = widget.newButton(
    {
        left = myData.chatRect.x+myData.chatRect.width/2-240,
        top = myData.chatRect.y+myData.chatRect.height-fontSize(120),
        width = 200,
        height = 90,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(72),
        label = "Send",
        labelColor = tableColor1,
        onEvent = sendChat
    })
    myData.sendChatButton.alpha=0

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextCrew)
    group:insert(myData.playerTextCrew)
    group:insert(myData.backButton)
    group:insert(myData.crewRect)
    group:insert(myData.crewName)
    group:insert(myData.crewTag)
    group:insert(myData.crewDesc)
    group:insert(myData.crewStats)
    group:insert(myData.chatRect)
    group:insert(myData.crewMembers)
    group:insert(myData.crewRequests)
    group:insert(myData.requestsCircle)
    group:insert(myData.requestsText)
    group:insert(myData.crewSetting)
    group:insert(myData.crewLogs)
    group:insert(myData.crewLogsCircle)
    group:insert(myData.crewLogsText)
    group:insert(myData.sendChatButton)
    group:insert(myData.crewChat)
    group:insert(myData.crewChatCircle)
    group:insert(myData.crewChatText)
    group:insert(myData.crewLeave)
    group:insert(myData.crewWarsAttack)
    group:insert(myData.crewWarsDefend)
    group:insert(myData.crewDatacenter)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
    myData.sendChatButton:addEventListener("tap",sendChat)
end

-- Home Show
function crewScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local tutCompleted = loadsave.loadTable( "crewTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutCrew ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "crewTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getMyCrewDetails.php", "POST", crewNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end

function crewScene:destroy(event)
    if (myData.crewChatInput) then
        myData.crewChatInput:removeSelf()
        myData.crewChatInput = nil
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
crewScene:addEventListener( "create", crewScene )
crewScene:addEventListener( "show", crewScene )
crewScene:addEventListener( "destroy", crewScene )
---------------------------------------------------------------------------------

return crewScene