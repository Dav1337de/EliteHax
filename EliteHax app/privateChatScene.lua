local composer = require( "composer" )
local json = require "json"
local myData = require ("mydata")
local privateChatScene = composer.newScene()
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

function addPChat(objectName, message, mine, timestamp)
	local currScene = composer.getSceneName( "current" )	
	if (mine == "Y") then
		mine_padding = 160
	else
		mine_padding = 0
	end
	if (myData.pChatRect ~= nil) then
		myData[objectName] = display.newText(message,20+mine_padding,totalHeight ,myData.pChatRect.width-250,0,native.systemFont, fontSize(35))
		myData[objectName].anchorX = 0
		myData[objectName].anchorY = 0
		myData[objectName]:setFillColor( 0.9,0.9,0.9 )

		timestampObjName = objectName.."Timestamp"
		myData[timestampObjName] = display.newText(timestamp,20+mine_padding,myData[objectName].y+myData[objectName].height+15,600,0,native.systemFont, fontSize(22))
		myData[timestampObjName].anchorX = 0
		myData[timestampObjName].anchorY = 0
		myData[timestampObjName]:setFillColor( 0.9,0.9,0.9 )
		myData[timestampObjName].padding = mine_padding
		myData.scrollAreaPChat:insert(myData[timestampObjName])

		rectObjectName = objectName.."Rect"
		myData[rectObjectName] = display.newRoundedRect( myData[objectName].x-20, myData[objectName].y-10, myData[objectName].width+20, myData[objectName].height+myData[timestampObjName].height+30, 12 )
		myData[rectObjectName].anchorX = 0
		myData[rectObjectName].anchorY = 0
		myData[rectObjectName].strokeWidth = 5
		myData[rectObjectName]:setFillColor( 0,0,0,0.5 )
		myData[rectObjectName]:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )

		myData.pChatRect.alpha = 1
		myData.scrollAreaPChat:insert(myData[rectObjectName])
		myData.scrollAreaPChat:insert(myData[objectName])
	end
end

local function pChatReceiveListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OOops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        --chatOpen = prevChatOpen
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            --local alert = native.showAlert( "EliteHax", "OOops.. A network error occured...", { "Close" }, onAlert )
        elseif (t.private_chats[1] ~= nil) then           
            totalHeight=200
            chat_changed = true
            for i=1,chatMsg,1 do
                objName1 = "msgText"..i
                if ((i == 1) and (myData[objName1].text == t.private_chats[1].msg)) then chat_changed = false end
                timestampObjName1 = objName1.."Timestamp"
                rectObjName1 = objName1.."Rect"
                myData[objName1]:removeSelf()
                myData[objName1] = nil
                myData[timestampObjName1]:removeSelf()
                myData[timestampObjName1] = nil
                myData[rectObjName1]:removeSelf()
                myData[rectObjName1] = nil
            end
            chatMsg = 0
            for i in pairs( t.private_chats ) do
                objectName = "msgText"..i
                addPChat(objectName,t.private_chats[i].msg,t.private_chats[i].mine,makeTimeStamp(t.private_chats[i].timestamp))
                chatMsg=chatMsg+1
                totalHeight = totalHeight + myData[objectName].height+70
            end
            objectName = "msgText51"
            myData[objectName] = display.newText("",20,totalHeight ,native.systemFont, fontSize(50))
            myData[objectName].anchorX = 0
            myData[objectName].anchorY = 0
            myData[objectName]:setFillColor( 0,0.7,0 )
            myData.scrollAreaPChat:insert(myData[objectName])
            totalHeight = totalHeight+myData[objectName].height+fontSize(70)
            myData.scrollAreaPChat:setScrollHeight( totalHeight )
            --if (chat_changed == true) then
                --if (myData.pChatRect.y == 90+topPadding()) then
            if (disableScroll==false) then
                myData.scrollAreaPChat:scrollToPosition{y = -myData.scrollAreaPChat._view.height+myData.scrollAreaPChat.height/3*2,time = 100}
            end
                --else
                    --myData.scrollAreaPChat:scrollToPosition{y = (-myData.scrollAreaPChat._view.height+myData.scrollAreaPChat.height+20),time = 100}   
                --end            
            --end
        end
    end    
end

local function pChatRefresh ( event )
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token).."&username="..params.username
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getPChat.php", "POST", pChatReceiveListener, params )
end

local function sendPChatListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OOops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occured...", { "Close" }, onAlert )
        end

        if ( t.status == "OK") then
            chatSent=0
            myData.pChatInput.text = ""
        end
    end
end

local function sendPChat( event )
    if ((event.phase == "ended") and (string.len(myData.pChatInput.text) > 0) and (chatSent == 0)) then
        chatSent=1
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&message="..string.urlEncode(myData.pChatInput.text).."&dest="..string.urlEncode(params.username)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."sendPChat.php", "POST", sendPChatListener, params )
    end
end

local function onPChatEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>200) then
            myData.pChatInput.text = string.sub(event.text,1,200)
        end
    end
end

local function closePCD( event )
    if (event.phase=="ended") then
        timer.performWithDelay( 100, closePC )
    end
end

function closePC( event )
	if (myData.sendPChatButton ~= nil) then
	    myData.sendPChatButton:removeSelf()
	    myData.sendPChatButton = nil
	end
    if (myData.pChatInput ~= nil) then
	    myData.pChatInput:removeSelf()
	    myData.pChatInput = nil
	end
    if (pChatTimer) then
       timer.cancel(pChatTimer)
    end
    if (params.tab == "messages") then reloadMessages() end
	chatMsg = 0
    msgOverlay=false
    --myData.msgTableView:reloadData()
    backSound()
    composer.hideOverlay( "fade", 0 )
end

local function pChatListener(event)
    if (event.phase=="moved") then
        if (event.direction=="down") then
            print("Scroll Disabled")
            disableScroll=true
        end
    end
    if ((event.limitReached==true) and (event.direction=="up")) then
        disableScroll=false
        print("Scroll Enabled")
    end
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--	Scene Creation
function privateChatScene:create(event)
	pcgroup = self.view
    params = event.params
    disableScroll=false

	--Global Chat
	myData.pChatRect = display.newImageRect( "img/private_chat_rect.png", display.contentWidth-40, fontSize(1680))
	myData.pChatRect.anchorX = 0
	myData.pChatRect.anchorY = 0
	myData.pChatRect.x,myData.pChatRect.y = 20, fontSize(110)+topPadding()
    changeImgColor(myData.pChatRect)

	myData.pChatName = display.newText(params.username,display.contentWidth/2,myData.pChatRect.y+fontSize(50) ,native.systemFont, fontSize(50))
    myData.pChatName.anchorX = 0.5
    myData.pChatName.anchorY = 0.5
	
	myData.scrollAreaPChat = widget.newScrollView(
	{
	    top = myData.pChatRect.y+100,
	    left = myData.pChatRect.x+30,
	    width = display.contentWidth,
	    height = myData.pChatRect.height-200,
	    scrollWidth = 600,
	    scrollHeight = 2000,
	    backgroundColor = { 0, 0, 0, 0},
	    horizontalScrollDisabled = true,
	    isBounceEnabled = true,
        listener = pChatListener
	})
	myData.scrollAreaPChat.anchorY = 0
	myData.scrollAreaPChat.y=myData.pChatRect.y+fontSize(110)

    objectName = "msgText51"
    myData[objectName] = display.newText("Private chat with "..params.username,20,20 ,native.systemFont, fontSize(50))
    myData[objectName].anchorX = 0
    myData[objectName].anchorY = 0
    myData[objectName]:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.scrollAreaPChat:insert(myData[objectName])
	myData.scrollAreaPChat:scrollToPosition{y = -myData.scrollAreaPChat._view.height+fontSize(30),time = 200}

	--Input
	if (params.username ~= "EliteHax") then
	    myData.sendPChatButton = widget.newButton(
	    {
	        left = myData.pChatRect.x+(myData.pChatRect.width-220),
	        top = myData.pChatRect.y+myData.pChatRect.height-110,
	        width = 180,
	        height = 90,
	        defaultFile = buttonColor400,
	       -- overFile = "buttonOver.png",
	        fontSize = fontSize(68),
	        label = "Send",
	        labelColor = tableColor1,
	        onEvent = sendPChat
	    })

	    --Chat Input
	    myData.pChatInput = native.newTextField( myData.pChatRect.x+30, myData.pChatRect.y+myData.pChatRect.height-110, myData.pChatRect.width-260, fontSize(75) )
	    myData.pChatInput.anchorX = 0
	    myData.pChatInput.anchorY = 0
	    myData.pChatInput.placeholder = "Send Message to "..params.username;
	    myData.pChatInput:addEventListener("userInput", onPChatEdit )
	end

 --    myData.closePCBtn = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
 --    myData.closePCBtn.anchorX = 0
 --    myData.closePCBtn.anchorY = 0
 --    myData.closePCBtn.x, myData.closePCBtn.y = myData.pChatRect.x+myData.pChatRect.width-iconSize/2.5-30, myData.pChatRect.y+fontSize(55)
 --    myData.closePCBtn.fill.effect="filter.hue"
 --    myData.closePCBtn.fill.effect.angle=angleColor
	-- myData.closePCBtn:addEventListener("tap", closePCD)

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
	pcgroup:insert(myData.pChatRect)
	pcgroup:insert(myData.scrollAreaPChat)
	pcgroup:insert(myData.pChatName)
	pcgroup:insert(myData.closePCBtn)

end

-- Home Show
function privateChatScene:show(event)
	local homepcgroup = self.view
	if event.phase == "will" then
		chatSent = 0
	 	chatMsg = 0
		chatOpen = 0
		local headers = {}
		local body = "id="..string.urlEncode(loginInfo.token)
		local params = {}
		params.headers = headers
		params.body = body
		network.request( host().."gethome.php", "POST", networkListener, params )
		pChatRefresh()
        if (pChatTimer) then
           timer.cancel(pChatTimer)
        end
		pChatTimer = timer.performWithDelay( 1500, pChatRefresh, 0 )
        timer.resume( pChatTimer )
	end
	if event.phase == "did" then
		-- 		
	end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
privateChatScene:addEventListener( "create", privateChatScene )
privateChatScene:addEventListener( "show", privateChatScene )
---------------------------------------------------------------------------------

return privateChatScene