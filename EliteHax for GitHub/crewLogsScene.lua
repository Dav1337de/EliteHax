local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local loadsave = require( "loadsave" )
local crewLogsScene = composer.newScene()
local view = "player"
refreshMsgRequestList = nil
refreshContactList = nil
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------

local regionNames = {
    "Northern America",
    "Central America",
    "Southern America",
    "Northern Europe",
    "Central Europe",
    "Southern Europe",
    "Eastern Europe",
    "Western Africa",
    "Northern Africa",
    "Middle Africa",
    "Eastern Africa",
    "Southern Africa",
    "Western Asia",
    "Central Asia",
    "Eastern Asia",
    "Southern Asia",
    "Southerneast Asia",
    "Australia & New Zeland"
}

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local function warLogsListener( event )
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
        if (string.len(t.username)>15) then myData.playerTextMessage.size = fontSize(42) end
        myData.playerTextMessage.text=t.username
        myData.moneyTextMessage.text=format_thousand(t.money)

        myData.eventTableView:deleteAllRows()

        for i in pairs( t.crew_wars ) do
            rowColor = { default = { 0, 0, 0, 0 } }
            lineColor = { default = { 1, 0, 0 } }

            if (t.crew_wars[i].log_type=="WAR") then
                if (t.crew_wars[i].mf_hack=="y") then  
                    if (t.crew_wars[i].type=="attack") then
                        rowHeight=fontSize(440)
                        color = { default = { 0.15, 0.69, 0.17, 0.9 },over = { 0.15, 0.69, 0.17, 0.9 }}
                    else
                        rowHeight=fontSize(330)
                        color = { default = { 0.69, 0.15, 0.17, 0.9 },over = { 0.69, 0.15, 0.17, 0.9 } }
                    end 
                else
                    if (t.crew_wars[i].type=="attack") then
                        rowHeight=fontSize(330)
                        color = { default = { 0.10, 0.40, 0.75, 0.9 },over = { 0.10, 0.40, 0.75, 0.9 } }
                    else
                        rowHeight=fontSize(280)
                        color = { default = { 0.78, 0.40, 0.17, 0.9 },over = { 0.78, 0.40, 0.17, 0.9 } }
                    end 
                end   
            else
                if (t.crew_wars[i].type=="defense") then
                    rowHeight=fontSize(200)
                    color = tableAqua1
                elseif (t.crew_wars[i].type=="upgrade") then
                    rowHeight=fontSize(200)
                    color = tablePurple1
                elseif (t.crew_wars[i].type=="attack_d") then
                    rowHeight=fontSize(200)
                    color = tableYellow1
                end
            end

            lineColor = { 
              default = { 1, 0, 0 }
            }
            myData.eventTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = rowHeight,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        log_type=t.crew_wars[i].log_type,
                        color=color,
                        type=t.crew_wars[i].type,
                        attack_type=t.crew_wars[i].attack_type,
                        attacking_crew=t.crew_wars[i].attacking_crew,
                        target_crew=t.crew_wars[i].target_crew,
                        mf_hack=t.crew_wars[i].mf_hack,
                        region=t.crew_wars[i].region,
                        cc_reward=t.crew_wars[i].cc_reward,
                        money_reward=t.crew_wars[i].money_reward,
                        anon=t.crew_wars[i].anon,
                        timestamp=makeTimeStamp(t.crew_wars[i].timestamp)
                    }
                }
            ) 
        end

        myData.eventsText.text=t.new_events
        myData.tournamentText.text=t.new_tournaments
        myData.cwText.text=t.new_cw

        loaded=true
   end
end

local function crewRewardsListener( event )
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
        if (string.len(t.username)>15) then myData.playerTextMessage.size = fontSize(42) end
        myData.playerTextMessage.text=t.username
        myData.moneyTextMessage.text=format_thousand(t.money)

        myData.eventTableView:deleteAllRows()

        for i in pairs( t.crew_rewards ) do
            rowHeight=fontSize(200)
            rowColor = { default = { 0, 0, 0, 0 } }
            lineColor = { default = { 1, 0, 0 } }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end
            myData.eventTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = rowHeight,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        type=t.crew_rewards[i].type,
                        color=color,
                        subtype=t.crew_rewards[i].subtype,
                        field1=t.crew_rewards[i].field1,
                        field2=t.crew_rewards[i].field2,
                        field3=t.crew_rewards[i].field3,
                        timestamp=makeTimeStamp(t.crew_rewards[i].timestamp)
                    }
                }
            ) 
        end

        myData.eventsText.text=t.new_events
        myData.tournamentText.text=t.new_tournaments
        myData.cwText.text=t.new_cw

        loaded=true
   end
end

local function crewEventsListener( event )
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
        if (string.len(t.username)>15) then myData.playerTextMessage.size = fontSize(42) end
        myData.playerTextMessage.text=t.username
        myData.moneyTextMessage.text=format_thousand(t.money)

        myData.eventTableView:deleteAllRows()

        for i in pairs( t.crew_events ) do
            rowHeight=fontSize(220)
            if (t.crew_events[i].subtype=="promote") then rowHeight=fontSize(270)
            elseif (t.crew_events[i].subtype=="demote") then rowHeight=fontSize(270)  
            elseif (t.crew_events[i].subtype=="leave") then rowHeight=fontSize(150)
            elseif (t.crew_events[i].subtype=="description") then rowHeight=fontSize(150)
            elseif (t.crew_events[i].subtype=="request") then rowHeight=fontSize(150) end 
            rowColor = { default = { 0, 0, 0, 0 } }
            lineColor = { default = { 1, 0, 0 } }
            local color=tableColor1
            if (i%2==0) then color=tableColor2 end
            myData.eventTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = rowHeight,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        type=t.crew_events[i].type,
                        color=color,
                        subtype=t.crew_events[i].subtype,
                        field1=t.crew_events[i].field1,
                        field2=t.crew_events[i].field2,
                        field3=t.crew_events[i].field3,
                        timestamp=makeTimeStamp(t.crew_events[i].timestamp)
                    }
                }
            ) 
        end

        myData.eventsText.text=t.new_events
        myData.tournamentText.text=t.new_tournaments
        myData.cwText.text=t.new_cw

        loaded=true
   end
end

-- Function to handle tab button events
local function handleTabBarEvent( event )
    if (event.target.id == "events") then
        tapSound()
        view = "events"
        loaded=false
        myData.eventTableView:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getCrewEvents.php", "POST", crewEventsListener, params )
    elseif (event.target.id == "tournaments") then
        tapSound()
        view = "tournaments"
        loaded=false
        myData.eventTableView:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getCrewRewards.php", "POST", crewRewardsListener, params )
    elseif (event.target.id == "wars") then
        tapSound()
        view = "wars"
        loaded=false
        myData.eventTableView:deleteAllRows()
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getWarLogs.php", "POST", warLogsListener, params )
    end
end

function goBackCrewLogs(event)
    if ((tutOverlay==false) and (loaded==true)) then
        composer.removeScene( "crewLogsScene" )
        backSound()
        composer.gotoScene("crewScene", {effect = "fade", time = 100})
    end
end

local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(10), fontSize(58) )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,5
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])
    row.rowRectangle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )

    if (params.type=="tournament") then
        local subtype=""
        local msg=""
        if (params.subtype=="hack") then
            subtype="Hack Tournament"
        elseif (params.subtype=="score") then
            subtype="Score Tournament"
        elseif (params.subtype=="hackdefend") then
            subtype="Hack&Defend Tourn."
        end
        msg="Rank: "..params.field3.."\nCrew Reward: "..params.field1.." CC ("..params.field2.." CC per member)"

        row.rowMessage = display.newText( row, "["..params.timestamp.."] "..subtype.."\n"..msg, 0, 0, native.systemFont, fontSize(48) )
        row.rowMessage.anchorX = 0
        row.rowMessage.anchorY = 0
        row.rowMessage.x = 30
        row.rowMessage.y = 15
        row.rowMessage:setTextColor( 0, 0, 0 )

    elseif (params.type=="defense") then

        msg=params.attacking_crew.." spent 1 point to defend your Datacenter\n"

        row.rowMessage = display.newText( row, "["..params.timestamp.."]\n"..msg, 0, 0, row.width-15, row.height-30, native.systemFont, fontSize(44) )
        row.rowMessage.anchorX = 0
        row.rowMessage.anchorY = 0
        row.rowMessage.x = 25
        row.rowMessage.y = 25
        row.rowMessage:setTextColor( 0, 0, 0 )

    elseif (params.type=="upgrade") then
        local type
        if (params.attack_type=='fwext') then
            type="External Firewall"
        elseif (params.attack_type=="ips") then
            type="IPS"
        elseif (params.attack_type=="siem") then
            type="SIEM"
        elseif (params.attack_type=="fwint1") then
            type="Left Internal Firewall"
        elseif (params.attack_type=="fwint2") then
            type="Right Internal Firewall"
        elseif (params.attack_type=="mf1") then
            type="Left Mainframe"
        elseif (params.attack_type=="mf2") then
            type="Right Mainframe"
        elseif (params.attack_type=="scanner") then
            type="Scanner"
        elseif (params.attack_type=="exploit") then
            type="Exploit"
        elseif (params.attack_type=="relocate") then
            type="Relocation"
        elseif (params.attack_type=="anon") then
            type="Anonymizer"
        elseif (params.attack_type=="mf1_testprod") then
            type="Test Environment"
        elseif (params.attack_type=="mf2_testprod") then
            type="Test Environment"
        end

        msg=params.attacking_crew.." spent 1 point to upgrade your "..type.."\n"

        row.rowMessage = display.newText( row, "["..params.timestamp.."]\n"..msg, 0, 0, row.width-15, row.height-30, native.systemFont, fontSize(44) )
        row.rowMessage.anchorX = 0
        row.rowMessage.anchorY = 0
        row.rowMessage.x = 25
        row.rowMessage.y = 25
        row.rowMessage:setTextColor( 0, 0, 0 )

    elseif (params.type=="attack_d") then
        local type
        if (params.attack_type=='fwext') then
            type="External Firewall"
        elseif (params.attack_type=="ips") then
            type="IPS"
        elseif (params.attack_type=="siem") then
            type="SIEM"
        elseif (params.attack_type=="fwint1") then
            type="Left Internal Firewall"
        elseif (params.attack_type=="fwint2") then
            type="Right Internal Firewall"
        elseif (params.attack_type=="mf1") then
            type="Left Mainframe"
        elseif (params.attack_type=="mf2") then
            type="Right Mainframe"
        end

        msg=params.attacking_crew.." spent 1 point to attack "..params.target_crew.." "..type.."\n"

        row.rowMessage = display.newText( row, "["..params.timestamp.."]\n"..msg, 0, 0, row.width-15, row.height-30, native.systemFont, fontSize(44) )
        row.rowMessage.anchorX = 0
        row.rowMessage.anchorY = 0
        row.rowMessage.x = 25
        row.rowMessage.y = 25
        row.rowMessage:setTextColor( 0, 0, 0 )

    elseif (params.type=="attack") then
        local anon=""
        local type=""
        if (params.anon==1) then 
            anon="Yes"
        else
            anon="No"
        end
        if (params.attack_type=='fwext') then
            type="External Firewall"
        elseif (params.attack_type=="ips") then
            type="IPS"
        elseif (params.attack_type=="siem") then
            type="SIEM"
        elseif (params.attack_type=="fwint1") then
            type="Internal Firewall"
        elseif (params.attack_type=="fwint2") then
            type="Internal Firewall"
        elseif (params.attack_type=="mf1") then
            if (params.mf_hack=="t") then
                type="Mainframe - Test"
            elseif (params.mf_hack=="y") then
                type="Mainframe - Production"
            end
        elseif (params.attack_type=="mf2") then
            if (params.mf_hack=="t") then
                type="Mainframe - Test"
            elseif (params.mf_hack=="y") then
                type="Mainframe - Production"
            end
        end

        msg="Target: "..params.target_crew.."\nTarget Region: "..regionNames[params.region].."\nType: "..type.."\nAnonymous: "..anon
        if (params.mf_hack=="y") then
            msg=msg.."\nCryptocoins: "..params.cc_reward.." per member\nMoney stolen: $"..format_thousand(params.money_reward)
        end

        row.rowMessage = display.newText( row, "["..params.timestamp.."] Attack successful!\n"..msg, 0, 0, native.systemFont, fontSize(44) )
        row.rowMessage.anchorX = 0
        row.rowMessage.anchorY = 0
        row.rowMessage.x = 25
        row.rowMessage.y = 25
        row.rowMessage:setTextColor( 0, 0, 0 )

    elseif (params.type=="defend") then
        local attacker=""
        local region=""
        local type=""
        if (params.anon==1) then 
            attacker="Unknown"
            region="Unknown"
        else
            attacker=params.attacking_crew
            region=regionNames[params.region]
        end
        if (params.attack_type=='fwext') then
            type="External Firewall"
        elseif (params.attack_type=="ips") then
            type="IPS"
        elseif (params.attack_type=="siem") then
            type="SIEM"
        elseif (params.attack_type=="fwint1") then
            type="Internal Firewall"
        elseif (params.attack_type=="fwint2") then
            type="Internal Firewall"
        elseif (params.attack_type=="mf1") then
            if (params.mf_hack=="t") then
                type="Mainframe - Test"
            elseif (params.mf_hack=="y") then
                type="Mainframe - Production"
            end
        elseif (params.attack_type=="mf2") then
            if (params.mf_hack=="t") then
                type="Mainframe - Test"
            elseif (params.mf_hack=="y") then
                type="Mainframe - Production"
            end
        end

        msg="Attacker: "..attacker.."\nTarget Region: "..region.."\nType: "..type
        if (params.mf_hack=="y") then
            msg=msg.."\nMoney lost: $"..format_thousand(params.money_reward)
        end

        row.rowMessage = display.newText( row, "["..params.timestamp.."] Attack received!\n"..msg, 0, 0, native.systemFont, fontSize(44) )
        row.rowMessage.anchorX = 0
        row.rowMessage.anchorY = 0
        row.rowMessage.x = 25
        row.rowMessage.y = 25
        row.rowMessage:setTextColor( 0, 0, 0 )
    elseif (params.type=="action") then
        local subtype=""
        local msg=""
        if (params.subtype=="promote") then
            subtype="Promotion"
            msg=params.field1.." has been promoted!\nNew Role: "..params.field3.."\nPromoted By: "..params.field2
        elseif (params.subtype=="demote") then
            subtype="Demotion"
            msg=params.field1.." has been demoted!\nNew Role: "..params.field3.."\nDemoted By: "..params.field2
        elseif (params.subtype=="leave") then
            subtype="Leave"
            msg=params.field1.." has left the Crew!"
        elseif (params.subtype=="reject_invite") then
            subtype="Invitation Rejected"
            msg=params.field1.." has rejected the invitation\nSent by: "..params.field2
        elseif (params.subtype=="accept_invite") then
            subtype="Invitation Accepted"
            msg=params.field1.." has accepted the invitation!\nSent by: "..params.field2
        elseif (params.subtype=="mentor") then
            subtype="New Crew Mentor"
            msg=params.field1.." is the new Crew Mentor!\nPrevious: "..params.field2
        elseif (params.subtype=="wallet_p") then
            subtype="Crew Wallet %"
            msg="New Crew Wallet Percentage: "..params.field1.."%\nSet by: "..params.field2
        elseif (params.subtype=="buy") then
            subtype="New Item Bought"
            msg="Item: "..params.field1.."\nBought by: "..params.field2
        elseif (params.subtype=="description") then
            subtype="New Description"
            msg=params.field1.." has changed the Crew Description"
        elseif (params.subtype=="invitation") then
            subtype="Invitation Sent"
            msg="Invited user: "..params.field1.."\nSent by: "..params.field2
        elseif (params.subtype=="request") then
            subtype="New Request"
            msg="Requestor: "..params.field1
        elseif (params.subtype=="join") then
            subtype="Request Accepted"
            msg=params.field1.." has joined the Crew\nAccepted by: "..params.field2   
        elseif (params.subtype=="kick") then
            subtype="Kick"
            msg=params.field1.." has been kicked out\nKicked out by: "..params.field2      
        end

        row.rowMessage = display.newText( row, "["..params.timestamp.."] "..subtype.."\n"..msg, 0, 0, native.systemFont, fontSize(48) )
        row.rowMessage.anchorX = 0
        row.rowMessage.anchorY = 0
        row.rowMessage.x = 30
        row.rowMessage.y = 15
        row.rowMessage:setTextColor( 0, 0, 0 )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewLogsScene:create(event)
    group = self.view

    loginInfo = localToken()
    loaded = false
    msgOverlay = false
    iconSize=fontSize(200)

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextMessage = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextMessage.anchorX = 0
    myData.moneyTextMessage.anchorY = 0.5
    myData.moneyTextMessage:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextMessage = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextMessage.anchorX = 0.5
    myData.playerTextMessage.anchorY = 0.5
    myData.playerTextMessage:setFillColor( 0.9,0.9,0.9 )
 
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
        label = "Events",
        id = "events",
        selected = true,
        size = fontSize(48),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    },
    {
        defaultFrame = 5,
        overFrame = 6,
        label = "Tournaments",
        id = "tournaments",
        size = fontSize(48),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    },
    {
        defaultFrame = 5,
        overFrame = 6,
        label = "Crew Wars",
        id = "wars",
        size = fontSize(48),
        labelYOffset = -25,
        labelColor = { default={ 0.9, 0.9, 0.9 }, over={ 0.9, 0.9, 0.9 } },
        onPress = handleTabBarEvent
    }
}
view = "events" 
    -- Create the widget
    myData.messageTabBar = widget.newTabBar(
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
    myData.messageTabBar.anchorX=0.5
    myData.messageTabBar.anchorY=0
    myData.messageTabBar.x,myData.messageTabBar.y=display.contentWidth/2,myData.top_background.y+myData.top_background.height

    myData.eventsCircle = display.newCircle( myData.messageTabBar.x-myData.messageTabBar.width/2+myData.messageTabBar.width/3-20,myData.messageTabBar.y+fontSize(40), fontSize(36) )
    myData.eventsCircle:setFillColor( 0 )
    myData.eventsCircle.strokeWidth = 5
    myData.eventsCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.eventsText = display.newText("",myData.eventsCircle.x,myData.eventsCircle.y,native.systemFont, fontSize(50))
    myData.eventsText.anchorX = 0.5
    myData.eventsText.anchorY = 0.5
    myData.eventsText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    myData.tournamentCircle = display.newCircle( myData.messageTabBar.x-myData.messageTabBar.width/2+myData.messageTabBar.width/3*2-20,myData.messageTabBar.y+fontSize(40), fontSize(36) )
    myData.tournamentCircle:setFillColor( 0 )
    myData.tournamentCircle.strokeWidth = 5
    myData.tournamentCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.tournamentText = display.newText("",myData.tournamentCircle.x,myData.tournamentCircle.y,native.systemFont, fontSize(50))
    myData.tournamentText.anchorX = 0.5
    myData.tournamentText.anchorY = 0.5
    myData.tournamentText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    myData.cwCircle = display.newCircle( myData.messageTabBar.x-myData.messageTabBar.width/2+myData.messageTabBar.width-20,myData.messageTabBar.y+fontSize(40), fontSize(36) )
    myData.cwCircle:setFillColor( 0 )
    myData.cwCircle.strokeWidth = 5
    myData.cwCircle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )
    myData.cwText = display.newText("",myData.cwCircle.x,myData.cwCircle.y,native.systemFont, fontSize(50))
    myData.cwText.anchorX = 0.5
    myData.cwText.anchorY = 0.5
    myData.cwText:setFillColor( textColor1[1], textColor1[2], textColor1[3] )

    myData.messageRect = display.newImageRect( "img/leaderboard_rect.png",display.contentWidth-20,fontSize(1580) )
    myData.messageRect.anchorX = 0.5
    myData.messageRect.anchorY = 0
    myData.messageRect.x, myData.messageRect.y = display.contentWidth/2,myData.messageTabBar.y+myData.messageTabBar.height-fontSize(22)
    changeImgColor(myData.messageRect)

    -- Create the widget
    myData.eventTableView = widget.newTableView(
        {
            left = 20,
            top = myData.messageRect.y-myData.messages.height/2+fontSize(25),
            height = fontSize(1510),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.eventTableView.anchorX=0.5
    myData.eventTableView.anchorY=0
    myData.eventTableView.x,myData.eventTableView.y=display.contentWidth/2,myData.messageRect.y+fontSize(25)

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
        onEvent = goBackCrewLogs
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextMessage)
    group:insert(myData.playerTextMessage)
    group:insert(myData.messageRect)
    group:insert(myData.messageTabBar)
    group:insert(myData.eventsCircle)
    group:insert(myData.eventsText)
    group:insert(myData.tournamentCircle)
    group:insert(myData.tournamentText)
    group:insert(myData.cwCircle)
    group:insert(myData.cwText)
    group:insert(myData.backButton)
    group:insert(myData.eventTableView)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackCrewLogs)
end

-- Home Show
function crewLogsScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "crewLogsTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.crewLogsTutorial ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "crewLogsTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        loaded=false
        myData.eventTableView:deleteAllRows()
        myData.eventTableView.height=fontSize(1500)
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getCrewEvents.php", "POST", crewEventsListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
crewLogsScene:addEventListener( "create", crewLogsScene )
crewLogsScene:addEventListener( "show", crewLogsScene )
---------------------------------------------------------------------------------

return crewLogsScene