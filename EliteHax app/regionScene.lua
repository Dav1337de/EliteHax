local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local upgrades = require("upgradeName")
local regionScene = composer.newScene()
canScan=false
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local function goToDatacenter( event )
    if (event.phase == "ended") then
        composer.removeScene( "regionScene" )
        tapSound()
        composer.gotoScene("datacenterScene", {effect = "fade", time = 10})
    end
end

local difficulty = { 
    "img/difficult_unknown.png",
    "img/difficult_very_easy.png",
    "img/difficult_easy.png",
    "img/difficult_medium.png",
    "img/difficult_high.png",
    "img/difficult_extreme.png",
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

function goBackmap(event)
    if (tutOverlay==false) then
        composer.removeScene( "regionScene" )
        backSound()
        composer.gotoScene("mapScene", {effect = "fade", time = 10})
    end
end

local function goBackmap(event)
    if ((event.phase=="ended") and (tutOverlay==false)) then
        composer.removeScene( "regionScene" )
        backSound()
        composer.gotoScene("mapScene", {effect = "fade", time = 10})
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

    row.rowTitle = display.newText( row, params.dcName.. " ("..params.dcTag..")", 30, (iconSize/1.5)/2-5, native.systemFont, fontSize(55) )
    row.rowTitle.name=params.dcName
    row.rowTitle.tag=params.dcTag
    row.rowTitle.timestamp=params.dcTimestamp
    row.rowTitle.anchorX=0
    row.rowTitle.anchorY=0.5
    row.rowTitle:setTextColor( 0, 0, 0 )

    if (params.dcTimestamp=="Never") then
        params.difficulty=1
    end
    if ((type(tonumber(params.dcTimestamp)) == "number") and (tonumber(params.dcTimestamp)<0)) then
        params.difficulty=1
    end
    row.dcDifficult = display.newImageRect(row, difficulty[params.difficulty], iconSize/1.6, iconSize/1.6)
    row.dcDifficult.difficult=params.difficulty
    row.dcDifficult.x = row.width-iconSize/1.3
    row.dcDifficult.y = (iconSize/1.6)/2
end

local function onRowTouch( event )
    if (event.phase=="tap") then
        tapSound()
        local row = event.row
        local params = event.row.params

        myData.dcName.alpha=1
        myData.dcDescription.alpha=1
        myData.dcDifficult.alpha=1
        myData.dcScanButton.alpha=1
        myData.dcAttackButton.alpha=1

        myData.dcName.text=params.dcName
        myData.dcDescription.text="Datacenter Name: "..params.dcName.."\nDatacenter TAG: "..params.dcTag.."\nWallet: $"..params.dcWallet.."\nLast Scan: "..params.dcTimestamp.."\nLast Attacked: "..params.dcLastAttack.."\n\nDifficult:"
        myData.dcScanButton.last_attack=params.dcLastAttack
        local imageA = { type="image", filename=difficulty[params.difficulty] }
        myData.dcDifficult.fill=imageA
        myData.dcScanButton.row=event.target.index
        if (params.dcTimestamp=="Never") then
            myData.dcAttackButton.alpha=0
            myData.dcScanButton.alpha=1
            myData.dcScanButton:setLabel("Scan Datacenter")
            myData.dcScanButton.dc=params.dcId
            myData.dcScanButton.name=params.dcName
            myData.dcScanButton.tag=params.dcTag
            myData.dcScanButton.last_attack=params.dcLastAttack
            if (canScan==false) then
                myData.dcScanButton._view._label:setFillColor(0.5,0.5,0.5,1)
                myData.dcScanButton:setFillColor(0.5,0.5,0.5,1)
                myData.dcScanButton.enabled=false
            else
                myData.dcScanButton.enabled=true
            end
        elseif ((type(tonumber(params.dcTimestamp)) == "number") and (tonumber(params.dcTimestamp)<0)) then
            myData.dcAttackButton.alpha=0
            myData.dcScanButton.alpha=0
            myData.dcDescription.text="Datacenter Name: "..params.dcName.."\nDatacenter TAG: "..params.dcTag.."\nWallet: ?????\nLast Scan: In Progress ("..math.ceil(math.abs(tonumber(params.dcTimestamp))/60).."m Left)\nLast Attacked: "..params.dcLastAttack.."\n\nDifficult:"
        else 
            myData.dcScanButton.alpha=1
            myData.dcAttackButton.dc=params.dcId
            myData.dcScanButton:setLabel("Re-Scan Datacenter")
            myData.dcScanButton.dc=params.dcId
            myData.dcScanButton.name=params.dcName
            myData.dcScanButton.tag=params.dcTag
            if (canScan==false) then
                myData.dcScanButton._view._label:setFillColor(0.5,0.5,0.5,1)
                myData.dcScanButton:setFillColor(0.5,0.5,0.5,1)
                myData.dcScanButton.enabled=false
            else
                myData.scanButton.enabled=true
            end
        end
    end
end

local function scanDatacenterNetworkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        if (retry==true) then
            retry=false
            retryTimer=timer.performWithDelay(1000,reloadAfterTutorial,5)
        elseif (retryCount==0) then
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 3", { "Close" }, onAlert )
        end
    else
        print ( "RESPONSE: " .. event.response )
    
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 4", { "Close" }, onAlert )
        end

        if (t.status=="OK") then
            local last_attack="Never"
            myData.dcDescription.text="Datacenter Name: "..myData.dcScanButton.name.."\nDatacenter TAG: "..myData.dcScanButton.tag.."\nWallet: ?????\nLast Scan: In Progress (60m Left)\nLast Attacked: "..last_attack.."\n\nDifficult:"
            myData.crewTableView:getRowAtIndex( myData.dcScanButton.row).params.dcTimestamp="-3600"
            local imageA = { type="image", filename=difficulty[1] }
            myData.dcDifficult.fill=imageA
            myData.dcAttackButton.alpha=0
            myData.dcScanButton.alpha=0
            myData.dcScanButton.enabled=false
            canScan=false
            if (myData.dcScanButton.last_attack) then
                last_attack=makeTimeStamp(myData.dcScanButton.last_attack)
            end
        end
        scanRx=true
    end
end

local function scanDatacenter(event)
    if ((event.phase=="ended") and (scanRx==true)) then
        tapSound()
        if (event.target.enabled==true) then
            scanRx=false
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&dc="..event.target.dc
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."scanDc.php", "POST", scanDatacenterNetworkListener, params )
        else
            myData.dcScanButton._view._label:setFillColor(0.5,0.5,0.5,1)
        end
    end
end

local function regionDCNetworkListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        if (retry==true) then
            retry=false
            retryTimer=timer.performWithDelay(1000,reloadAfterTutorial,5)
        elseif (retryCount==0) then
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 3", { "Close" }, onAlert )
        end
    else
        print ( "RESPONSE: " .. event.response )
    
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 4", { "Close" }, onAlert )
        end

        --Money
        myData.moneyTextCW.text = format_thousand(t.money)
        myData.moneyTextCW.money = t.money

        --Player
        if (string.len(t.username)>15) then myData.playerTextCW.size = fontSize(42) end
        myData.playerTextCW.text = t.username

        rowColor = { default = { 0, 0, 0, 0 } }
        lineColor = { default = { 1, 0, 0 } }

        for count=1,t.dcs,1 do 
            local color=tableColor1
            if (count%2==0) then color=tableColor2 end
            local dcWalletTemp=t["dc"..count.."_wallet"]
            local dcTimestampTemp=t["dc"..count.."_timestamp"]
            local dcLastAttackTemp=t["dc"..count.."_last_attack"]

            if (dcWalletTemp~="?????") then dcWalletTemp=format_thousand(dcWalletTemp) end
            if ((dcTimestampTemp~="Never") and (tonumber(dcTimestampTemp)~=nil) and (tonumber(dcTimestampTemp)>0)) then dcTimestampTemp=makeTimeStamp(dcTimestampTemp) end
            if (dcLastAttackTemp~="Never") then dcLastAttackTemp=makeTimeStamp(dcLastAttackTemp) end
            myData.crewTableView:insertRow(
                {
                    isCategory = false,
                    rowHeight = iconSize/1.6,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        dcId=t["dc"..count.."_id"],
                        dcName=t["dc"..count.."_name"],
                        dcTag=t["dc"..count.."_tag"],
                        dcTimestamp=dcTimestampTemp,
                        dcNextAttack=t["dc"..count.."_next_attack"],
                        dcLastAttack=dcLastAttackTemp,
                        dcWallet=dcWalletTemp,
                        difficulty=t["dc"..count.."_difficult"]+1,
                        color=color
                    }
                }
            ) 
        end
        if (t.can_scan==1) then 
            canScan=true
        else 
            canScan=false 
        end

    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function regionScene:create(event)
    group = self.view
    mgroup = display.newGroup()
    dotGroup = display.newGroup()

    loginInfo = localToken()
    scanRx=true

    iconSize=200

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/region_details_rect.png",display.actualContentHeight-40, display.contentWidth-(display.actualContentHeight/15-5))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0.5
    myData.top_background:translate(display.contentWidth/2+(display.actualContentHeight/15-5)/2,display.actualContentHeight/2+topPadding())
    changeImgColor(myData.top_background)
    myData.top_background.rotation=90

    --Money
    myData.moneyTextCW = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextCW.anchorX = 0
    myData.moneyTextCW.anchorY = 0.5
    myData.moneyTextCW:translate(display.contentWidth-fontSize(155)-topPadding()/8,-display.actualContentHeight/1.45-topPadding()/2)
    myData.moneyTextCW:setFillColor( 0.9,0.9,0.9 )
    myData.moneyTextCW.rotation=90

    --Player Name
    myData.playerTextCW = display.newText("",display.contentWidth,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextCW.anchorX = 0.5
    myData.playerTextCW.anchorY = 0.5
    myData.playerTextCW:translate(-fontSize(40),fontSize(215)-topPadding()/2)
    myData.playerTextCW:setFillColor( 0.9,0.9,0.9 )
    myData.playerTextCW.rotation=90

    --Region Name
    myData.regionName = display.newText(myData.exploreButton.region,115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.regionName.anchorX = 0.5
    myData.regionName.anchorY = 0.5
    myData.regionName:translate(display.contentWidth-fontSize(155)-topPadding()/8,-display.actualContentHeight/4-topPadding()/2)
    myData.regionName:setFillColor( 0.9,0.9,0.9 )
    myData.regionName.rotation=90

    -----CUSTOM TABLEVIEW-----
    -- Function to retrieve a widget's theme settings
    local function _getTheme( widgetTheme, options )    
        local theme = nil
            
        -- If a theme has been set
        if widget.theme then
            theme = widget.theme[widgetTheme]
        end
        
        -- If a theme exists
        if theme then
            -- Style parameter optionally set by user
            if options and options.style then
                local style = theme[options.style]
                
                -- For themes that support various "styles" per widget
                if style then
                    theme = style
                end
            end
        end
        
        return theme
    end
    function newTableView( options )
        local theme = _getTheme( "tableView", options )
        local _tableView = require( "customTableView" )
        return _tableView.new( options, theme ) 
    end
    ------------------------
    -- Create the widget
    myData.crewTableView = newTableView(
        {
            left = 0,
            top = myData.top_background.y+fontSize(120),
            height = display.contentWidth-fontSize(250),
            width = myData.top_background.height-topPadding(),
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.crewTableView.anchorX=0
    myData.crewTableView.anchorY=0
    myData.crewTableView:translate(display.contentWidth/2-fontSize(30)+topPadding()/2,-display.actualContentHeight/1.33-topPadding()/2)
    myData.crewTableView.rotation=90

    --Details Rect
    myData.crewDetailsRect = display.newImageRect( "img/crew_empty_rect.png",display.actualContentHeight/2-fontSize(80), display.contentWidth-(display.actualContentHeight/15-5)*2)
    myData.crewDetailsRect.anchorX = 0.5
    myData.crewDetailsRect.anchorY = 0.5
    myData.crewDetailsRect:translate(display.contentWidth/2+(display.actualContentHeight/15-5)/3.5,display.actualContentHeight/1.325+topPadding())
    changeImgColor(myData.crewDetailsRect)
    myData.crewDetailsRect.rotation=90

    --Datacenter Name
    myData.dcName = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.dcName.anchorX = 0.5
    myData.dcName.anchorY = 0.5
    myData.dcName:translate(myData.crewDetailsRect.y-myData.crewDetailsRect.height*0.66-fontSize(60)+topPadding()/2,myData.crewDetailsRect.x-myData.crewDetailsRect.width*0.63-topPadding())
    myData.dcName:setFillColor( 0.9,0.9,0.9 )
    myData.dcName.rotation=90
    myData.dcName.alpha=0

    --Datacenter Description
    myData.dcDescription = display.newText("Datacenter Name: \nDatacenter TAG: \nWallet: ?????\nLast Scan: Never\nLast Attacked: Never\n\nDifficult:",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.dcDescription.anchorX = 0
    myData.dcDescription.anchorY = 0
    myData.dcDescription:translate(myData.crewDetailsRect.y-myData.crewDetailsRect.height*0.66-fontSize(120)+topPadding()/2,myData.crewDetailsRect.x-myData.crewDetailsRect.width-fontSize(80)-topPadding()/2)
    myData.dcDescription:setFillColor( 0.9,0.9,0.9 )
    myData.dcDescription.rotation=90 
    myData.dcDescription.alpha=0   

    myData.dcDifficult = display.newImageRect(difficulty[3], iconSize/1.4, iconSize/1.4)
    myData.dcDifficult.anchorX=0.5
    myData.dcDifficult.anchorY=0.5
    myData.dcDifficult:translate(myData.crewDetailsRect.y-myData.crewDetailsRect.height*0.66-myData.dcDescription.height+fontSize(50)+topPadding()/2,display.actualContentHeight/1.325-fontSize(80)+topPadding()*2)
    myData.dcDifficult.rotation=90
    myData.dcDifficult.alpha=0

    myData.dcScanButton = widget.newButton(
    {
        left = myData.crewDetailsRect.y-myData.crewDetailsRect.height*0.66-myData.dcDescription.height-myData.dcDifficult.height,
        top = display.actualContentHeight/1.325-fontSize(80),
        width = fontSize(650),
        height = fontSize(100),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Scan Datacenter",
        labelColor = tableColor1,
        onEvent = scanDatacenter
    })
    myData.dcScanButton.anchorX=0.5
    myData.dcScanButton.anchorY=0
    myData.dcScanButton.rotation=90
    myData.dcScanButton:translate(-myData.dcDifficult.y/4+fontSize(100)+topPadding()/2,myData.crewDetailsRect.x-myData.crewDetailsRect.width*0.6)
    myData.dcScanButton.alpha=0
    myData.dcScanButton.enabled=true

    myData.dcAttackButton = widget.newButton(
    {
        left = myData.crewDetailsRect.y-myData.crewDetailsRect.height*0.66-myData.dcDescription.height-myData.dcDifficult.height,
        top = display.actualContentHeight/1.325-fontSize(80),
        width = fontSize(650),
        height = fontSize(100),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(65),
        label = "Attack Datacenter",
        labelColor = tableColor1,
        onEvent = goToDatacenter
    })
    myData.dcAttackButton.anchorX=0.5
    myData.dcAttackButton.anchorY=0
    myData.dcAttackButton.rotation=90
    myData.dcAttackButton:translate(-myData.dcDifficult.y/4-fontSize(30)+topPadding()/2,myData.crewDetailsRect.x-myData.crewDetailsRect.width*0.6)
    myData.dcAttackButton.alpha=0

    myData.backButton = widget.newButton(
    {
        left = 0-display.contentWidth+(display.actualContentHeight/15-5)*2-fontSize(40)+topPadding(),
        top = display.actualContentHeight/2-60+topPadding(),
        width = display.actualContentHeight-40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Back",
        labelColor = tableColor1,
        onEvent = goBackmap
    })
    myData.backButton.rotation=90

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD   
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.playerTextCW)
    group:insert(myData.moneyTextCW)
    group:insert(myData.regionName)
    group:insert(myData.crewTableView)
    group:insert(myData.crewDetailsRect)
    group:insert(myData.dcName)
    group:insert(myData.dcDescription)
    group:insert(myData.dcDifficult)
    group:insert(myData.dcScanButton)
    group:insert(myData.dcAttackButton)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackmap)
    myData.dcAttackButton:addEventListener("tap",goToDatacenter)
    myData.dcScanButton:addEventListener("tap",scanDatacenter)
end

-- Home Show
function regionScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "cwRegionTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.cwRegionTutorial ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "cwRegionTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&region="..myData.exploreButton.regionN
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRegionDC.php", "POST", regionDCNetworkListener, params )
    end

    if event.phase == "did" then
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
regionScene:addEventListener( "create", regionScene )
regionScene:addEventListener( "show", regionScene )
---------------------------------------------------------------------------------

return regionScene