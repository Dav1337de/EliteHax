local composer = require( "composer" )
local json = require "json"
local myData = require ("mydata")
local homeScene = composer.newScene()
local loadsave = require( "loadsave" )
local widget = require( "widget" )
local reloadAfterTutorial = nil
local retry=true
local retryCount=5
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

local function chatDetail( event )
    detailsOverlay=true
    local sceneOverlayOptions = 
    {
        time = 200,
        effect = "crossFade",
        params = { 
            id = event.target.username,
            my_gc_role = my_gc_role
        },
        isModal = true
    }
    tapSound()
    composer.showOverlay( "playerDetailsScene", sceneOverlayOptions)
end

function addGChat(objectName, username, message, mine, mod, sup, timestamp)
	local currScene = composer.getSceneName( "current" )
    if (currScene == "homeScene") then
		if (mine == "Y") then
			mine_padding = 160
		else
			mine_padding = 0
		end
		if (myData.gChatRect ~= nil) then
			myData[objectName] = display.newText(message,20+mine_padding,totalHeight ,myData.gChatRect.width-250,0,native.systemFont, fontSize(35))
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
            
            starObjectName = objectName.."Star"
            starObjectName2 = objectName.."Star2"
            myData[starObjectName] = display.newImageRect( "img/sup.png", fontSize(80),fontSize(35))
            myData[starObjectName].anchorX = 0
            myData[starObjectName].anchorY = 0
            myData[starObjectName].x, myData[starObjectName].y = myData[userObjectName].x-82,myData[userObjectName].y
            myData[starObjectName].alpha=0

            myData[starObjectName2] = display.newImageRect( "img/mod.png", fontSize(80),fontSize(35))
            myData[starObjectName2].anchorX = 0
            myData[starObjectName2].anchorY = 0
            myData[starObjectName2].x, myData[starObjectName2].y = myData[userObjectName].x-82,myData[userObjectName].y
            myData[starObjectName2].alpha=0

            if (sup == 1) then
                myData[starObjectName].alpha=1
            end
            if (mod == 2) then
                myData[starObjectName2].alpha=1
                if (sup == 1) then
                    myData[starObjectName].x=myData[userObjectName].x-myData[starObjectName2].width-82
                end
            elseif (mod == 1) then
                local imageA = { type="image", filename="img/dev.png" }
                myData[starObjectName2].fill = imageA  
                myData[starObjectName2].alpha=1
                if (sup == 1) then
                    myData[starObjectName].x=myData[userObjectName].x-myData[starObjectName2].width-82
                end
            end

			rectObjectName = objectName.."Rect"
			myData[rectObjectName] = display.newRoundedRect( myData[objectName].x-20, myData[objectName].y-10, myData[objectName].width+20, myData[objectName].height+myData[userObjectName].height+20, 12 )
			myData[rectObjectName].anchorX = 0
			myData[rectObjectName].anchorY = 0
			myData[rectObjectName].strokeWidth = 5
			myData[rectObjectName]:setFillColor( 0,0,0,0.5 )
			myData[rectObjectName].username = username
			if (mod == 1) then 
				myData[rectObjectName]:setStrokeColor( 0.6, 0, 0 )
			elseif (mod == 2) then
				myData[rectObjectName]:setStrokeColor( 0.6, 0.3, 0 )
            elseif (sup == 1) then
                myData[rectObjectName]:setStrokeColor( 0.9, 0.75, 0 )
			else
				myData[rectObjectName]:setStrokeColor( 0, 0.6, 0 )
			end
			myData[rectObjectName]:addEventListener("tap",chatDetail)

			myData.gChatRect.alpha = 1
            if (myData.scrollAreaGChat) then
                myData.scrollAreaGChat:insert(myData[timestampObjName])
    			myData.scrollAreaGChat:insert(myData[rectObjectName])
    			myData.scrollAreaGChat:insert(myData[userObjectName])
                myData.scrollAreaGChat:insert(myData[starObjectName])
                myData.scrollAreaGChat:insert(myData[starObjectName2])
    			myData.scrollAreaGChat:insert(myData[objectName])
            else
                myData[timestampObjName]:removeSelf()
                myData[timestampObjName]=nil
                myData[rectObjectName]:removeSelf()
                myData[rectObjectName]=nil
                myData[userObjectName]:removeSelf()
                myData[userObjectName]=nil
                myData[starObjectName]:removeSelf()
                myData[starObjectName]=nil
                myData[starObjectName2]:removeSelf()
                myData[starObjectName2]=nil
                myData[objectName]:removeSelf()
                myData[objectName]=nil

            end
		end
	end
end

local function gChatReceiveListener( event )
    if ( event.isError ) then
        --print( "Network error: ", event.response )
        --local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
    else
        --print ( "RESPONSE: " .. event.response )
        --chatOpen = prevChatOpen
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            --local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
        elseif (t.global_chats[1] ~= nil) then  
            --Check if chat has changed  
            --print("Current "..t.global_chats[table.maxn(t.global_chats)].timestamp.." "..t.global_chats[table.maxn(t.global_chats)].username)
            objName1 = "msgText"..table.maxn(t.global_chats)
            userObjName1 = objName1.."Usr"
            timestampObjName1 = objName1.."Timestamp"
            if (myData[objName1]) then
                --print("Previous: "..myData[timestampObjName1].text.." "..myData[userObjName1].text)
                if ((makeTimeStamp(t.global_chats[table.maxn(t.global_chats)].timestamp) == myData[timestampObjName1].text) and (t.global_chats[table.maxn(t.global_chats)].username==myData[userObjName1].text)) then
                    --print("Not Changed")
                    refreshChat=true
                    return true
                end
            end

            totalHeight=20
            chat_changed = true
            for i=1,chatMsg,1 do
                objName1 = "msgText"..i
                if ((i == 1) and (myData[objName1].text == t.global_chats[1].msg)) then chat_changed = false end
                userObjName1 = objName1.."Usr"
                timestampObjName1 = objName1.."Timestamp"
                rectObjName1 = objName1.."Rect"
                starObjName1 = objName1.."Star"
                starObjName2 = objName1.."Star2"
                if (myData[objName1]) then
                    myData[objName1]:removeSelf()
                    myData[objName1] = nil
                end
                if (myData[timestampObjName1]) then
                    myData[timestampObjName1]:removeSelf()
                    myData[timestampObjName1] = nil
                end
                if (myData[userObjName1]) then
                    myData[userObjName1]:removeSelf()
                    myData[userObjName1] = nil
                end
                if (myData[starObjName1]) then
                    myData[starObjName1]:removeSelf()
                    myData[starObjName1] = nil
                end
                if (myData[starObjName2]) then
                    myData[starObjName2]:removeSelf()
                    myData[starObjName2] = nil
                end
                if (myData[rectObjName1]) then
                    myData[rectObjName1]:removeSelf()
                    myData[rectObjName1] = nil
                end
            end
            chatMsg = 0
            for i in pairs( t.global_chats ) do
                objectName = "msgText"..i
                addGChat(objectName,t.global_chats[i].username,t.global_chats[i].msg,t.global_chats[i].mine,t.global_chats[i].mod,t.global_chats[i].supporter,makeTimeStamp(t.global_chats[i].timestamp))
                chatMsg=chatMsg+1
                if (myData[objectName]) then
                    totalHeight = totalHeight + myData[objectName].height+fontSize(70)
                end
            end
            if (myData.scrollAreaGChat) then
                objectName = "msgText51"
                myData[objectName] = display.newText("",20,totalHeight ,native.systemFont, fontSize(50))
                myData[objectName].anchorX = 0
                myData[objectName].anchorY = 0
                myData[objectName]:setFillColor( 0,0.7,0 )
                myData.scrollAreaGChat:insert(myData[objectName])
                totalHeight = totalHeight+myData[objectName].height+fontSize(70)
                myData.scrollAreaGChat:setScrollHeight( totalHeight )
                if ((chat_changed == true) and (disableScroll==false)) then
                    if (myData.gChatRect.y == 90+topPadding()) then
                        myData.scrollAreaGChat:scrollToPosition{y = -myData.scrollAreaGChat._view.height+myData.scrollAreaGChat.height/2,time = 100}
                    else
                        myData.scrollAreaGChat:scrollToPosition{y = (-myData.scrollAreaGChat._view.height+myData.scrollAreaGChat.height+20),time = 100}   
                    end            
                end
            end
        end
    end    
    refreshChat=true
end

local function gChatRefresh ( event )
    --prevChatOpen = chatOpen
	--chatOpen = 1 
    if (refreshChat==true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        refreshChat=false
        network.request( host().."getGChat.php", "POST", gChatReceiveListener, params )
    end
end

local function sendGChatListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 5", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 6", { "Close" }, onAlert )
        end

        if ( t.status == "OK") then
            chatSent=0
            myData.gChatInput.text = ""
        end
    end
end

local function sendGChat( event )
    if ((event.phase == "ended") and (string.len(myData.gChatInput.text) > 0) and (chatSent == 0)) then
        chatSent=1
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&message="..string.urlEncode(myData.gChatInput.text)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."sendGChat.php", "POST", sendGChatListener, params )
    end
end

local function onGChatEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>200) then
            myData.gChatInput.text = string.sub(event.text,1,200)
        end
    end
end

local function closeGCD( event )
    timer.performWithDelay( 100, closeGC )
end

function closeGC( event )
	chatOpen = 0
    backSound()
	local imageA = { type="image", filename="img/home_gc_rectangle.png" }
    myData.gChatRect.fill = imageA	
    changeImgColor(myData.gChatRect)
	myData.gChatRect.y = myData.community_background.y+myData.community_background.height
	myData.gChatRect.height = fontSize(340)
	myData.scrollAreaGChat.y = myData.gChatRect.y+100
	myData.scrollAreaGChat.height = myData.gChatRect.height-140
	myData.scrollAreaGChat:toFront()
	myData.scrollAreaGChat:scrollToPosition{y = (-myData.scrollAreaGChat._view.height+myData.scrollAreaGChat.height+40),time = 200}
    if (myData.closeGCBtn ~= nil) then
	    myData.closeGCBtn:removeSelf()
	    myData.closeGCBtn = nil
	end
	if (myData.sendGChatButton ~= nil) then
	    myData.sendGChatButton:removeSelf()
	    myData.sendGChatButton = nil
	end
    if (myData.gChatInput ~= nil) then
	    myData.gChatInput:removeSelf()
	    myData.gChatInput = nil
	end
end

local function GChatScroll(event)
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

local function openGChat( event )
	if ((event.phase == "ended") and (chatOpen == 0))  then
		chatOpen = 1
        tapSound()
		local imageA = { type="image", filename="img/home_gc_ext_rectangle.png" }
        myData.gChatRect.fill = imageA	
        changeImgColor(myData.gChatRect)
	    myData.gChatRect.y = 90+topPadding()
	    myData.gChatRect.height = display.actualContentHeight-150
	    myData.gChatRect:toFront()
	    myData.scrollAreaGChat.height = myData.gChatRect.height-200
	    myData.scrollAreaGChat.y = myData.gChatRect.y+100
	    myData.scrollAreaGChat:toFront()
	    myData.scrollAreaGChat:scrollToPosition{y = -myData.scrollAreaGChat._view.height,time = 200}
	    -- Close Button
	    if (myData.closeGCBtn) then
	    	myData.closeGCBtn:removeSelf()
	    	myData.closeGCBtn=nil
	    end
	    myData.closeGCBtn = display.newImageRect( "img/x.png",iconSize/5,iconSize/5 )
	    myData.closeGCBtn.anchorX = 0
	    myData.closeGCBtn.anchorY = 0
        myData.closeGCBtn:translate(myData.gChatRect.width-iconSize/5-15, myData.gChatRect.y+fontSize(55))
        changeImgColor(myData.closeGCBtn)
	    group:insert(myData.closeGCBtn)
    	myData.closeGCBtn:addEventListener("tap", closeGCD)

    	if (banned==false) then
	    	--Input
		    myData.sendGChatButton = widget.newButton(
		    {
		        left = myData.gChatRect.x+(myData.gChatRect.width-220),
		        top = myData.gChatRect.y+myData.gChatRect.height-110,
		        width = 180,
		        height = 90,
		        defaultFile = buttonColor400,
		       -- overFile = "buttonOver.png",
		        fontSize = fontSize(68),
		        label = "Send",
		        labelColor = tableColor1,
		        onEvent = sendGChat
		    })

		    --Chat Input
		    myData.gChatInput = native.newTextField( myData.gChatRect.x+30, myData.gChatRect.y+myData.gChatRect.height-110, myData.gChatRect.width-260, fontSize(75) )
		    myData.gChatInput.anchorX = 0
		    myData.gChatInput.anchorY = 0
		    myData.gChatInput.placeholder = "Send Message to Global Chat";
		    myData.gChatInput:addEventListener("userInput", onGChatEdit )
		end
	elseif ((event.phase=="moved") and (chatOpen==1)) then
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

local function taskupdateListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        --local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
    else
        print ( "RESPONSE1: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
        	print ("EMPTY T")
        	--local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
        end
    end
end

local function feedbackListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        --local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
    else
        print ( "RESPONSE1: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            --local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
        else
            print("OK")
        end
    end
end

--Q2 Like
local function Q2AnswerV1( event )
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&q=2&a=y&f="..base64Encode("rate")
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."sendFeedback.php", "POST", feedbackListener, params )
        system.openURL( "https://play.google.com/store/apps/details?id=it.EliteHax" )
    elseif ( i == 2 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&q=2&a=y&f="..base64Encode("none")
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."sendFeedback.php", "POST", feedbackListener, params )
    end
end

--Q2 Don't Like
local function Q2AnswerV2( event )
    local i = event.index
    if ( i == 1 ) then
        local sceneOverlayOptions = 
        {
            time = 100,
            effect = "crossFade",
            params = { 
                q = 2,
                a = "n"
            },
            isModal = true
        }
        composer.showOverlay( "feedbackScene", sceneOverlayOptions)
    elseif ( i == 2 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&q=2&a=n&f="..base64Encode("none")
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."sendFeedback.php", "POST", feedbackListener, params )
    end
end

local function Q2Answer( event )
    local i = event.index
    if ( i == 1 ) then
        timer.performWithDelay(500, function()
            alert2 = native.showAlert( "EliteHax", "Would you like to rate EliteHax to help the game grow?", { "Sure!", "No" }, Q2AnswerV1 )
            end,1)
    elseif ( i == 2 ) then
        timer.performWithDelay(500, function()
            alert2 = native.showAlert( "EliteHax", "Would you like to tell us what you don't like?", { "Yes!", "No" }, Q2AnswerV2 )
            end,1)
    end
end

--Q1 Like
local function Q1AnswerV1( event2 )
    local i = event2.index
    if ( i == 1 ) then
        local sceneOverlayOptions = 
        {
            time = 100,
            effect = "crossFade",
            params = { 
                q = 1,
                a = "y"
            },
            isModal = true
        }
        composer.showOverlay( "feedbackScene", sceneOverlayOptions)
    elseif ( i == 2 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&q=1&a=y&f="..base64Encode("none")
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."sendFeedback.php", "POST", feedbackListener, params )
    end
end

--Q1 Don't Like
local function Q1AnswerV2( event2 )
    local i = event2.index
    if ( i == 1 ) then
        local sceneOverlayOptions = 
        {
            time = 100,
            effect = "crossFade",
            params = { 
                q = 1,
                a = "n"
            },
            isModal = true
        }
        composer.showOverlay( "feedbackScene", sceneOverlayOptions)
    elseif ( i == 2 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&q=1&a=n&f="..base64Encode("none")
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."sendFeedback.php", "POST", feedbackListener, params )
    end
end

local function Q1Answer( event )
    local j = event.index
    if ( j == 1 ) then
        timer.performWithDelay(500, function()
            alert2 = native.showAlert( "EliteHax", "Would you like to suggest us any improvement?", { "Yes!", "No" }, Q1AnswerV1 )
            end,1)
    elseif ( j == 2 ) then
        timer.performWithDelay(500, function()
            alert2 = native.showAlert( "EliteHax", "Would you like to tell us what you don't like?", { "Yes!", "No" }, Q1AnswerV2 )
            end,1)
    end
end

local function networkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        if (retry==true) then
            retry=false
            retryTimer=timer.performWithDelay(1000,reloadAfterTutorial,5)
        elseif (retryCount==0) then
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 3", { "Close" }, onAlert )
        end
    else
        print ( "RESPONSE2: " .. event.response )
    
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
        	print ("EMPTY T")
        	local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 4", { "Close" }, onAlert )
        end

        crew = t.crew
        
        --Money
        myData.moneyTextHome.text = format_thousand(t.money)
        myData.moneyTextHome.money = t.money

        --Player
        if (string.len(t.user)>15) then myData.playerTextHome.size = fontSize(42) end
        myData.playerTextHome.text = t.user

        --Cryptocoins
        myData.boostersCount.text = t.overclock
        myData.cryptocoinsCount.text = t.cryptocoins
        myData.packsCount.text = t.packs

        --Tasks
        myData.taskmText.text = t.task_n

        --Missions
        myData.missionText.text = t.mission_n

        --Logs
        myData.logText.text = t.log_n

        --Tournaments
        if (t.tournament=="0") then
        	myData.tournamentsCircle:setStrokeColor( strokeRed1[1], strokeRed1[2], strokeRed1[3] )
    	    myData.tournamentsText:setFillColor( textRed1[1], textRed1[2], textRed1[3] )
        	myData.tournamentsText.text = "Not Active"
        else
            myData.tournamentsCircle:setStrokeColor( strokeGreen1[1], strokeGreen1[2], strokeGreen1[3] )
    	    myData.tournamentsText:setFillColor( textGreen1[1], textGreen1[2], textGreen1[3] )
        	myData.tournamentsText.text = "Active"
        end

        --Messages
        if (tonumber(t.new_msg)>99) then
        	myData.messagesText.text = "99+"
        	myData.messagesText.size = fontSize(40)
        else
	        myData.messagesText.text = t.new_msg
	    end

        --Achievements
        myData.achievementsText.text = t.achievements

        --Skill Points
        myData.profileText.text=t.skill_points

        --Crew Counter
        if (t.invitations) then
            myData.crewText.text=t.invitations
        elseif ((tonumber(t.requests)>0) or (t.crew_logs>0) or (t.crew_chats>0)) then
            myData.crewText.text="+"
        else
            myData.crewText.text="0"
        end

	    my_gc_role=t.gc_role
	    banned=false
	    if (t.gc_role==99) then
	    	banned=true
	    end

	    if ((t.today_reward=="0") and (tutOverlay==false)) then
            chatOpen = 1
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "dailyRewardScene", sceneOverlayOptions) 
	    elseif ((t.new_lvl>0) and (tutOverlay==false)) then
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "newLvlScene", sceneOverlayOptions) 
        elseif ((t.question=="Q1") and (tutOverlay==false)) then
            local alert = native.showAlert( "EliteHax", "Are you enjoying EliteHax?", { "Yes!", "No" }, Q1Answer )
        elseif ((t.question=="Q2") and (tutOverlay==false)) then
            local alert = native.showAlert( "EliteHax", "Are you still enjoying EliteHax?", { "Yes!", "No" }, Q2Answer )
        end

        if (retryTimer) then
            timer.cancel(retryTimer)
        end

    end
end

reloadAfterTutorial = function(event)
    if (retryTimer) then
        retryCount=retryCount-1
    end
	local headers = {}
	local body = "id="..string.urlEncode(loginInfo.token)
	local params = {}
	params.headers = headers
	params.body = body
	network.request( host().."gethome.php", "POST", networkListener, params )
end

local function goToC2CManage(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToC2CManage)
        else
    		timer.pause( gChatTimer )
    		chatOpen = 1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("c2cManageScene", {effect = "fade", time = 100})
        end
	end
end

local function goToTournaments(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToTournaments)
        else
    		timer.pause( gChatTimer )
    		chatOpen = 1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("tournamentScene", {effect = "fade", time = 100})
        end
	end
end

local function goToAchievement(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToAchievement)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
            composer.gotoScene("achievementScene", {effect = "fade", time = 100})
        end
	end
end

local function goToMessages(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToMessages)
        else
    		timer.pause( gChatTimer )
    		chatOpen = 1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("messageScene", {effect = "fade", time = 100})
        end
	end
end

local function goToItems(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToItems)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("offerScene", {effect = "fade", time = 100})
        end
	end
end

local function goToUpgrades(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToUpgrades)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("upgradeScene", {effect = "fade", time = 100})
        end
	end
end

local function goToTask(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToTask)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("taskScene", {effect = "fade", time = 100})
        end
	end
end

local function goToPlayer(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToPlayer)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("playerScene", {effect = "fade", time = 100})
        end
	end
end

local function goToLeaderboard(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToLeaderboard)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("leaderboardScene", {effect = "fade", time = 100})
        end
	end
end

local function goToTerminal(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToTerminal)
        else
    		chatOpen=1
    		timer.pause( gChatTimer )
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("terminalScene", {effect = "fade", time = 100})
        end
	end
end

local function goToLog(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToLog)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("logScene", {effect = "fade", time = 100})
        end
	end
end

local function goToMission(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToMission)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
    		composer.gotoScene("missionScene", {effect = "fade", time = 100})
        end
	end
end

local function goToCrew(event)
	if (chatOpen == 0) then
        if (refreshChat==false) then 
            timer.performWithDelay(100,goToCrew)
        else
    		timer.pause( gChatTimer )
    		chatOpen=1
            tapSound()
    		composer.removeScene( "homeScene" )
    		if (crew == "N") then
    			composer.gotoScene("newCrewScene", {effect = "fade", time = 100})
    		elseif (crew == "Y") then
    			composer.gotoScene("crewScene", {effect = "fade", time = 100})
    		end
        end
	end
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--	Scene Creation
function homeScene:create(event)
	group = self.view
	iconSize=((display.actualContentWidth-100)/3.2)*display.actualContentHeight/display.contentHeight
	chatOpen = 0
    refreshChat=true
	disableScroll=false

	horizontalDiff=(((display.actualContentWidth-100)/3.2)-iconSize)/2
	verticalDiff=horizontalDiff*9

	--Top Money/Name Background
	myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
	myData.top_background.anchorX = 0.5
	myData.top_background.anchorY = 0
    myData.top_background:translate(display.contentWidth/2,5+topPadding())
    changeImgColor(myData.top_background)

	--Money
	myData.moneyTextHome = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
	myData.moneyTextHome.anchorX = 0
	myData.moneyTextHome.anchorY = 0.5
	myData.moneyTextHome:setFillColor( 0.9,0.9,0.9 )

	--Player Name
	myData.playerTextHome = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
	myData.playerTextHome.anchorX = 0.5
	myData.playerTextHome.anchorY = 0.5
	myData.playerTextHome:setFillColor( 0.9,0.9,0.9 )

	--Items
	myData.items = display.newImageRect( "img/items.png",display.contentWidth-80,iconSize/3.5 )
	myData.items.anchorX = 0
	myData.items.anchorY = 0
    myData.items:translate(40,myData.top_background.y+myData.top_background.height+10)
    changeImgColor(myData.items)

	myData.boostersCount = display.newText("0",myData.items.x+100,myData.items.y+myData.items.height/2,native.systemFont, fontSize(65))
	myData.boostersCount.anchorX = 0
	myData.boostersCount.anchorY = 0.5
	myData.boostersCount:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	myData.packsCount = display.newText("",myData.items.x+430,myData.items.y+myData.items.height/2,native.systemFont, fontSize(65))
	myData.packsCount.anchorX = 0
	myData.packsCount.anchorY = 0.5
	myData.packsCount:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	myData.cryptocoinsCount = display.newText("",myData.items.x+740,myData.items.y+myData.items.height/2,native.systemFont, fontSize(65))
	myData.cryptocoinsCount.anchorX = 0
	myData.cryptocoinsCount.anchorY = 0.5
	myData.cryptocoinsCount:setFillColor( textColor1[1],textColor1[2],textColor1[3] )

	myData.itemsOC = display.newImageRect( "img/overclock.png",fontSize(77),fontSize(77) )
	myData.itemsOC.anchorX = 0
	myData.itemsOC.anchorY = 0.5
    myData.itemsOC:translate(myData.boostersCount.x-fontSize(77)-10,myData.boostersCount.y)

	myData.itemsPacks = display.newImageRect( "img/packs.png",fontSize(77),fontSize(77) )
	myData.itemsPacks.anchorX = 0
	myData.itemsPacks.anchorY = 0.5
    myData.itemsPacks:translate(myData.packsCount.x-fontSize(77)-18,myData.packsCount.y)
    changeImgColor(myData.itemsPacks)

	myData.itemsCC = display.newImageRect( "img/cryptocoin.png",fontSize(77),fontSize(77) )
	myData.itemsCC.anchorX = 0
	myData.itemsCC.anchorY = 0.5
    myData.itemsCC:translate(myData.cryptocoinsCount.x-fontSize(77)-10,myData.cryptocoinsCount.y)

	--Attacker&Defense Rectangle
	myData.ad_background = display.newImageRect( "img/home_ad_rectangle.png",display.contentWidth-40, fontSize(660))
	myData.ad_background.anchorX = 0.5
	myData.ad_background.anchorY = 0
    myData.ad_background:translate(display.contentWidth/2,myData.items.y+myData.items.height)
    changeImgColor(myData.ad_background)

	--C2C Manage
	myData.c2cManage = display.newImageRect( "img/c2c-manage.png",iconSize/1.2,iconSize/1.2 )
	myData.c2cManage.anchorX = 0
	myData.c2cManage.anchorY = 0
    myData.c2cManage:translate(myData.ad_background.x-myData.ad_background.width/2+60+horizontalDiff,myData.ad_background.y+fontSize(100))

	-- Terminal
	myData.terminal = display.newImageRect( "img/terminal.png",iconSize/1.2,iconSize/1.2 )
	myData.terminal.anchorX = 0
	myData.terminal.anchorY = 0
    myData.terminal:translate(myData.c2cManage.x+myData.c2cManage.width+horizontalDiff+60,myData.c2cManage.y)
    changeImgColor(myData.terminal)

	-- Attack Log
	myData.log = display.newImageRect( "img/log.png",iconSize/1.2,iconSize/1.2 )
	myData.log.anchorX = 0
	myData.log.anchorY = 0
    myData.log:translate(myData.terminal.x+myData.terminal.width+horizontalDiff+60,myData.c2cManage.y)
    changeImgColor(myData.log)
	myData.logCircle = display.newCircle( myData.log.x+myData.log.width-40,myData.log.y+fontSize(40), fontSize(40) )
	myData.logCircle:setFillColor( 0 )
	myData.logCircle.strokeWidth = 5
	myData.logCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
	myData.logText = display.newText("",myData.log.x+myData.log.width-40,myData.log.y+fontSize(40),native.systemFont, fontSize(52))
	myData.logText.anchorX = 0.5
	myData.logText.anchorY = 0.5
	myData.logText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

	-- Upgrades
	myData.upgrades = display.newImageRect( "img/upgrades.png",iconSize/1.2,iconSize/1.2 )
	myData.upgrades.anchorX = 0
	myData.upgrades.anchorY = 0
    myData.upgrades:translate(myData.c2cManage.x,myData.c2cManage.y+myData.c2cManage.height+20)
    changeImgColor(myData.upgrades)

	-- Task Manager
	myData.taskm = display.newImageRect( "img/task.png",iconSize/1.2,iconSize/1.2 )
	myData.taskm.anchorX = 0
	myData.taskm.anchorY = 0
    myData.taskm:translate(myData.terminal.x,myData.upgrades.y)
    changeImgColor(myData.taskm)
	myData.taskmCircle = display.newCircle( myData.taskm.x+myData.taskm.width-40,myData.taskm.y+fontSize(40), fontSize(40) )
	myData.taskmCircle:setFillColor( 0 )
	myData.taskmCircle.strokeWidth = 5
	myData.taskmCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
	myData.taskmText = display.newText("",myData.taskm.x+myData.taskm.width-40,myData.taskm.y+fontSize(40),native.systemFont, fontSize(50))
	myData.taskmText.anchorX = 0.5
	myData.taskmText.anchorY = 0.5
	myData.taskmText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

	--Missions
	myData.mission = display.newImageRect( "img/mission.png",iconSize/1.2,iconSize/1.2 )
	myData.mission.anchorX = 0
	myData.mission.anchorY = 0
    myData.mission:translate(myData.log.x,myData.upgrades.y)
    changeImgColor(myData.mission)
	myData.missionCircle = display.newCircle( myData.mission.x+myData.mission.width-40,myData.mission.y+fontSize(40), fontSize(40) )
	myData.missionCircle:setFillColor( 0 )
	myData.missionCircle.strokeWidth = 5
	myData.missionCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
	myData.missionText = display.newText("",myData.mission.x+myData.mission.width-40,myData.mission.y+fontSize(40),native.systemFont, fontSize(52))
	myData.missionText.anchorX = 0.5
	myData.missionText.anchorY = 0.5
	myData.missionText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

	--Community Rectangle
	myData.community_background = display.newImageRect( "img/home_community_rectangle.png",display.contentWidth-40, fontSize(660))
	myData.community_background.anchorX = 0.5
	myData.community_background.anchorY = 0
    myData.community_background:translate(display.contentWidth/2,myData.ad_background.y+myData.ad_background.height-15)
    changeImgColor(myData.community_background)

	-- Profile
	myData.profile = display.newImageRect( "img/profile.png",iconSize/1.2,iconSize/1.2 )
	myData.profile.anchorX = 0
	myData.profile.anchorY = 0
    myData.profile:translate(myData.c2cManage.x,myData.community_background.y+fontSize(100))
    myData.profileCircle = display.newCircle( myData.profile.x+myData.profile.width-40,myData.profile.y+fontSize(60), fontSize(40) )
    myData.profileCircle:setFillColor( 0 )
    myData.profileCircle.strokeWidth = 5
    myData.profileCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.profileText = display.newText("",myData.profile.x+myData.profile.width-40,myData.profile.y+fontSize(60),native.systemFont, fontSize(50))
    myData.profileText.anchorX = 0.5
    myData.profileText.anchorY = 0.5
    myData.profileText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

	-- Crew
	myData.crew = display.newImageRect( "img/crew.png",iconSize/1.2,iconSize/1.2 )
	myData.crew.anchorX = 0
	myData.crew.anchorY = 0
    myData.crew:translate(myData.taskm.x,myData.profile.y)
    changeImgColor(myData.crew)
    myData.crewCircle = display.newCircle( myData.crew.x+myData.crew.width-40,myData.crew.y+fontSize(60), fontSize(40) )
    myData.crewCircle:setFillColor( 0 )
    myData.crewCircle.strokeWidth = 5
    myData.crewCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.crewText = display.newText("",myData.crew.x+myData.crew.width-40,myData.crew.y+fontSize(60),native.systemFont, fontSize(50))
    myData.crewText.anchorX = 0.5
    myData.crewText.anchorY = 0.5
    myData.crewText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

	--Messages
	myData.messages = display.newImageRect( "img/mail.png",iconSize/1.2,iconSize/1.2 )
	myData.messages.anchorX = 0
	myData.messages.anchorY = 0
    myData.messages:translate(myData.mission.x,myData.profile.y)
    changeImgColor(myData.messages)
	myData.messagesCircle = display.newCircle( myData.messages.x+myData.messages.width-40,myData.messages.y+fontSize(60), fontSize(40) )
	myData.messagesCircle:setFillColor( 0 )
	myData.messagesCircle.strokeWidth = 5
	myData.messagesCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
	myData.messagesText = display.newText("",myData.messages.x+myData.messages.width-40,myData.messages.y+fontSize(60),native.systemFont, fontSize(50))
	myData.messagesText.anchorX = 0.5
	myData.messagesText.anchorY = 0.5
	myData.messagesText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

	--Ranking
	myData.ranking = display.newImageRect( "img/ranking.png",iconSize/1.2,iconSize/1.2 )
	myData.ranking.anchorX = 0
	myData.ranking.anchorY = 0
    myData.ranking:translate(myData.profile.x,myData.profile.y+myData.profile.height+fontSize(20))
    changeImgColor(myData.ranking)

	--Tournaments
	myData.tournaments = display.newImageRect( "img/tournaments.png",iconSize/1.2,iconSize/1.2 )
	myData.tournaments.anchorX = 0
	myData.tournaments.anchorY = 0
    myData.tournaments:translate(myData.crew.x,myData.ranking.y)
    changeImgColor(myData.tournaments)
	myData.tournamentsCircle = display.newRoundedRect( myData.tournaments.x+myData.tournaments.width/2,myData.tournaments.y+fontSize(160), 200, fontSize(45), 12 )
	myData.tournamentsCircle:setFillColor( 0 )
	myData.tournamentsCircle.strokeWidth = 5
	myData.tournamentsCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
	myData.tournamentsText = display.newText("",myData.tournaments.x+myData.tournaments.width/2,myData.tournaments.y+fontSize(160),native.systemFont, fontSize(40))
	myData.tournamentsText.anchorX = 0.5
	myData.tournamentsText.anchorY = 0.5
	myData.tournamentsText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

	--Tutorial
	--myData.achievement = display.newImageRect( "img/tutorial.png",iconSize/1.2,iconSize/1.2 )
    myData.achievement = display.newImageRect( "img/achievement.png",iconSize/1.2,iconSize/1.2 )
	myData.achievement.anchorX = 0
	myData.achievement.anchorY = 0
    myData.achievement:translate(myData.messages.x,myData.ranking.y)
    changeImgColor(myData.achievement)
    myData.achievementsCircle = display.newCircle( myData.achievement.x+myData.achievement.width-40,myData.achievement.y+fontSize(60), fontSize(40) )
    myData.achievementsCircle:setFillColor( 0 )
    myData.achievementsCircle.strokeWidth = 5
    myData.achievementsCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.achievementsText = display.newText("",myData.achievement.x+myData.achievement.width-40,myData.achievement.y+fontSize(60),native.systemFont, fontSize(50))
    myData.achievementsText.anchorX = 0.5
    myData.achievementsText.anchorY = 0.5
    myData.achievementsText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

	--Global Chat
	myData.gChatRect = display.newImageRect( "img/home_gc_rectangle.png", display.contentWidth-40, fontSize(340))
	myData.gChatRect.anchorX = 0
	myData.gChatRect.anchorY = 0
    myData.gChatRect:translate(20, myData.community_background.y+myData.community_background.height-10)
    changeImgColor(myData.gChatRect)
	myData.gChatRect:addEventListener("tap",openGChat)
	myData.scrollAreaGChat = widget.newScrollView(
	{
	    top = myData.gChatRect.y-myData.gChatRect.height/2+165,
	    left = myData.gChatRect.x+30,
	    width = display.contentWidth,
	    height = myData.gChatRect.height-140,
	    scrollWidth = 600,
	    scrollHeight = 2000,
	    backgroundColor = { 0, 0, 0, 0},
	    horizontalScrollDisabled = true,
	    isBounceEnabled = true,
	    listener = openGChat
	})
	myData.scrollAreaGChat.anchorY = 0
    objectName = "msgText51"
    myData[objectName] = display.newText("Connected to Global Chat",20,20 ,native.systemFont, fontSize(42))
    myData[objectName].anchorX = 0
    myData[objectName].anchorY = 0
    myData[objectName]:setFillColor( 0,0.7,0 )
    myData.scrollAreaGChat:insert(myData[objectName])
	myData.scrollAreaGChat:addEventListener("touch",openGChat)

	loginInfo = localToken()

--	Show HUD
	group:insert(myData.top_background)
	group:insert(myData.ad_background)
	group:insert(myData.community_background)
	group:insert(myData.upgrades)
	group:insert(myData.terminal)
	group:insert(myData.taskm)
	group:insert(myData.taskmCircle)
	group:insert(myData.taskmText)
	group:insert(myData.log)
	group:insert(myData.logCircle)
	group:insert(myData.logText)
	group:insert(myData.profile)
    group:insert(myData.profileCircle)
    group:insert(myData.profileText)
	group:insert(myData.crew)
    group:insert(myData.crewCircle)
    group:insert(myData.crewText)
	group:insert(myData.ranking)
	group:insert(myData.mission)
	group:insert(myData.missionCircle)
	group:insert(myData.missionText)
	group:insert(myData.moneyTextHome)
	group:insert(myData.playerTextHome)
	group:insert(myData.c2cManage)
	group:insert(myData.messages)
	group:insert(myData.messagesCircle)
	group:insert(myData.messagesText)
	group:insert(myData.tournaments)
	group:insert(myData.tournamentsCircle)
	group:insert(myData.tournamentsText)
	group:insert(myData.achievement)
    group:insert(myData.achievementsCircle)
    group:insert(myData.achievementsText)
	group:insert(myData.gChatRect)
	group:insert(myData.scrollAreaGChat)
	group:insert(myData.items)
	group:insert(myData.boostersCount)
	group:insert(myData.packsCount)
	group:insert(myData.cryptocoinsCount)
	group:insert(myData.itemsOC)
	group:insert(myData.itemsCC)
	group:insert(myData.itemsPacks)

	myData.upgrades:addEventListener("tap",goToUpgrades)
	myData.taskm:addEventListener("tap",goToTask)	
	myData.profile:addEventListener("tap",goToPlayer)
	myData.ranking:addEventListener("tap",goToLeaderboard)
	myData.terminal:addEventListener("tap",goToTerminal)
	myData.log:addEventListener("tap",goToLog)
	myData.crew:addEventListener("tap",goToCrew)
	myData.c2cManage:addEventListener("tap",goToC2CManage)
	myData.mission:addEventListener("tap",goToMission)
	myData.messages:addEventListener("tap",goToMessages)
	myData.achievement:addEventListener("tap",goToAchievement)
	myData.tournaments:addEventListener("tap",goToTournaments)
	myData.items:addEventListener("tap",goToItems)
end

-- Home Show
function homeScene:show(event)
	local homeGroup = self.view
	if event.phase == "will" then
		-- Called when the scene is still off screen (but is about to come on screen).
        backgroundSound()

		chatSent = 0
	 	chatMsg = 0
		chatOpen = 0
		local tutCompleted = loadsave.loadTable( "homeTosTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutHome ~= true) then
            tutOverlay = true
            chatOpen=1
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "homeTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
	    if myData.manualSearch then
	        myData.manualSearch:removeSelf()
	        myData.manualSearch = nil
	    end
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token)
		local params = {}
		params.headers = headers
		params.body = body
		network.request( host().."updatetask.php", "POST", taskupdateListener, params )
		network.request( host().."gethome.php", "POST", networkListener, params )
		gChatRefresh()
        if (gChatTimer) then
            timer.cancel(gChatTimer)
        end
		gChatTimer = timer.performWithDelay( 1500, gChatRefresh, 0 )
        timer.resume( gChatTimer )
	end
	if event.phase == "did" then
		-- 		
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
homeScene:addEventListener( "create", homeScene )
homeScene:addEventListener( "show", homeScene )
---------------------------------------------------------------------------------

return homeScene