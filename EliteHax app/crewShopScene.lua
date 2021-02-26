local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local crewShopScene = composer.newScene()
widget.setTheme( "widget_theme_android_holo_dark" )
local crewShopEventListener
local itemsCSTable = {}
local expandedType=0
local expandedId=0
local start=2
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

function goBackCrewShop (event)
    if (itemsLoaded == true) then
        composer.removeScene( "crewShopScene" )
        backSound()
        composer.gotoScene("crewSettingScene", {effect = "fade", time = 100})
    end
end

local function goBack (event)
    if (event.phase == "ended") and (itemsLoaded == true) then
        composer.removeScene( "crewShopScene" )
        backSound()
        composer.gotoScene("crewSettingScene", {effect = "fade", time = 100})
    end
end

local function buyItemListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OPS.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OPS.. A network error occured...", { "Close" }, onAlert )
        end
  
        if (t.status == "OK") then
            myData.itemsCSTable:deleteAllRows()  
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getCrewShop.php", "POST", crewShopEventListener, params )
        end    
   end
end

local function buyConfirm(type, qty)
    return function(event)
        local i = event.index
        if ( i == 1 ) then
            itemsLoaded = false
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&type="..type.."&qty="..qty
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."buyCrewItem.php", "POST", buyItemListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function buyBtn( event )
    if (event.phase == "ended") then
        local rowIndex=0
        local itemName=""
        if (event.target.name == "new_slot") then 
            rowIndex = 1
            itemName = "a New Slot"
        elseif (event.target.name == "sp") then 
            rowIndex = 2
            itemName = "Small Pack"
        elseif (event.target.name == "mp") then 
            rowIndex = 3
            itemName = "Medium Pack"
        elseif (event.target.name == "lp") then 
            rowIndex = 4 
            itemName = "Large Pack"
        elseif (event.target.name == "sm") then 
            rowIndex = 5
            itemName = "Small Money Pack"
        elseif (event.target.name == "mm") then 
            rowIndex = 6 
            itemName = "Medium Money Pack"
        elseif (event.target.name == "lm") then 
            rowIndex = 7 
            itemName = "Large Money Pack"
        elseif (event.target.name == "so") then 
            rowIndex = 8
            itemName = "Small Overclock Pack"
        elseif (event.target.name == "mo") then 
            rowIndex = 9
            itemName = "Medium Overclock Pack"
        elseif (event.target.name == "lo") then 
            rowIndex = 10 
            itemName = "Large Overclock Pack"
        end
        if (rowIndex==1) then
            local cost = myData.itemsCSTable:getRowAtIndex(rowIndex).buyButton.cost
            if (tonumber(cost)<=tonumber(myData.walletTextItems.value)) then
                tapSound()
                local alert = native.showAlert( "EliteHax", "Do you want to buy one additional slot for $"..format_thousand(cost).."?", { "Yes", "No" }, buyConfirm(event.target.name,1) )
            else
                backSound()
                local alert = native.showAlert( "EliteHax", "You don't have enough money to buy a new slot", { "Close" } )
            end

        else
            local qty = tonumber(myData.itemsCSTable:getRowAtIndex(rowIndex).buyQty.text)
            local cost = myData.itemsCSTable:getRowAtIndex(rowIndex).buySlider.cost
            if (qty == 1) then
                tapSound()
                local alert = native.showAlert( "EliteHax", "Do you want to buy "..qty.." "..itemName.." for $"..format_thousand(qty*cost).."?", { "Yes", "No" }, buyConfirm(event.target.name,qty) )
            elseif (qty > 1) then
                tapSound()
                local alert = native.showAlert( "EliteHax", "Do you want to buy "..qty.." "..itemName.."s for $"..format_thousand(qty*cost).."?", { "Yes", "No" }, buyConfirm(event.target.name,qty) )
            end
        end
    end
end

local function buySliderListener( event )
    local value=event.value
    local max=tonumber(myData.walletTextItems.value)/event.target.cost
    if (value>100) then value=100 end
    local qty=math.floor(value*max/100)
    local rowIndex=0
    if (event.target.name == "sp") then rowIndex = 2
    elseif (event.target.name == "mp") then rowIndex = 3
    elseif (event.target.name == "lp") then rowIndex = 4
    elseif (event.target.name == "sm") then rowIndex = 5
    elseif (event.target.name == "mm") then rowIndex = 6
    elseif (event.target.name == "lm") then rowIndex = 7 
    elseif (event.target.name == "so") then rowIndex = 8
    elseif (event.target.name == "mo") then rowIndex = 9
    elseif (event.target.name == "lo") then rowIndex = 10 end
    local current = myData.itemsCSTable:getRowAtIndex(rowIndex).buyQty.text
    if ( "moved" == event.phase ) then
        myData.itemsCSTable:getRowAtIndex(rowIndex).buyQty.text = qty
    end
end

local function expandRow( event )
    local id=event.target.id
    local expanded=myData.itemsCSTable._view._rows[id]._view.expandBtn.expanded
    local tempExpanded

    myData.itemsCSTable:deleteAllRows()
    for count=start,10,1 do
        if (itemsCSTable[count].id==id) then
            if (expanded==false) then
                tapSound()
                rowHeight=itemsCSTable[count].height
                tempExpanded=true
                expandedId=count
                expandedType=itemsCSTable[count].type
            else
                backSound()
                tempExpanded=false
                expandedType=0
            end
        else
            rowHeight=fontSize(220)
            tempExpanded=false
        end
        myData.itemsCSTable:insertRow(
        {
            isCategory = isCategory,
            rowHeight = rowHeight,
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                id=itemsCSTable[count].id,
                color=itemsCSTable[count].color,
                height=itemsCSTable[count].height,  
                type=itemsCSTable[count].type,
                title=itemsCSTable[count].title,
                desc=itemsCSTable[count].desc,  
                cost=itemsCSTable[count].cost,
                itemImage=itemsCSTable[count].itemImage,
                expanded=tempExpanded
            }
        })   
    end
    if (myData.itemsCSTable:getRowAtIndex(expandedId+2)==nil) then
        myData.itemsCSTable:scrollToIndex( expandedId, 0 )
    end
end

local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(20), fontSize(58) )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,10
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])
    row.rowRectangle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )

    row.rowTitle = display.newText( row, params.title, 0, 0, native.systemFont, fontSize(60) )
    row.rowTitle.anchorX=0
    row.rowTitle.anchorY=0
    row.rowTitle.x =  iconSize+30
    row.rowTitle.y = fontSize(30)
    row.rowTitle:setTextColor( 0, 0, 0 )
    row:insert(row.rowTitle)

    row.rowQty = display.newText( row, "Cost: $"..format_thousand(math.round(params.cost)).."\n", 0, 0, native.systemFont, fontSize(52) )
    row.rowQty.anchorX = 0
    row.rowQty.anchorY = 0
    row.rowQty.x =  iconSize+30
    row.rowQty.y = row.rowTitle.y+row.rowTitle.height+10
    row.rowQty:setTextColor( 0, 0, 0 )
    row:insert(row.rowQty)

    upgradeImage = display.newImageRect(row, params.itemImage, iconSize*0.9, iconSize*0.9)
    upgradeImage.x = (iconSize/2)+20
    upgradeImage.y = (iconSize/2)+10
    if ((params.itemImage ~= "img/large_overclock_pack.png") and (params.itemImage ~= "img/medium_overclock_pack.png") and (params.itemImage ~= "img/small_overclock_pack.png")) then
        changeImgColor(upgradeImage)
    end
    row:insert(upgradeImage)

    row.expandBtn = display.newImageRect( row, "img/expand.png",iconSize/2.5, iconSize/2.5)
    row.expandBtn.anchorX = 0.5
    row.expandBtn.anchorY = 0
    row.expandBtn:translate(row.width-iconSize/2.5-30,fontSize(25))
    changeImgColor(row.expandBtn)
    row.expandBtn.id=params.id
    row.expandBtn.expanded=params.expanded
    if (params.expanded==true) then 
        row.expandBtn:rotate(180)
        row.expandBtn.y=row.expandBtn.y+row.expandBtn.height
    end
    row.expandBtn:addEventListener("tap",expandRow)

    if (params.expanded==true) then
        row.rowDesc = display.newText( row, params.desc.."\n", 0, 0, row.width-40, 0, native.systemFont, fontSize(50) )
        row.rowDesc.anchorX = 0
        row.rowDesc.anchorY = 0
        row.rowDesc.x =  40
        row.rowDesc.y = row.rowQty.y+row.rowQty.height+10
        row.rowDesc:setTextColor( 0, 0, 0 )
        row:insert(row.rowDesc)

        if (params.type ~= "new_slot") then
            row.buyQty = display.newText( row, "0", 0, 0, native.systemFont, fontSize(60) )
            row.buyQty.anchorX = 0.5
            row.buyQty.anchorY = 0
            row.buyQty.x = (row.width/3*2)/2+40
            row.buyQty.y = row.rowDesc.y+row.rowDesc.height/2+fontSize(50)
            row.buyQty:setTextColor( 0, 0, 0 )
            row:insert(row.buyQty)

            -- Image sheet options and declaration
            -- For testing, you may copy/save the image under "Visual Customization" above
            local options = {
                frames = {
                    { x=0, y=0, width=36, height=64 },
                    { x=40, y=0, width=36, height=64 },
                    { x=80, y=0, width=36, height=64 },
                    { x=124, y=0, width=36, height=64 },
                    { x=168, y=0, width=64, height=64 }
                },
                sheetContentWidth = 232,
                sheetContentHeight = 50
            }
            local sliderSheet = graphics.newImageSheet( sliderColor, options )
             
            -- Create the widget
            row.buySlider = widget.newSlider(
                {
                    sheet = sliderSheet,
                    leftFrame = 1,
                    middleFrame = 2,
                    rightFrame = 3,
                    fillFrame = 4,
                    frameWidth = 36,
                    frameHeight = 64,
                    handleFrame = 5,
                    handleWidth = 50,
                    handleHeight = fontSize(64),
                    value=0,
                    top = row.buyQty.y+row.buyQty.height,
                    left= 40,
                    orientation = "horizontal",
                    width = row.width/3*2,
                    listener = buySliderListener
                }
            )
            row.buySlider.max = params.qty
            row.buySlider.cost = params.cost
            row.buySlider.name = params.type
            row:insert(row.buySlider)

            row.buyButton = widget.newButton(
            {
                left = row.buySlider.x+row.buySlider.width-50,
                top = row.buyQty.y-fontSize(10),
                width = 200,
                height = fontSize(100),
                defaultFile = buttonColor400,
               -- overFile = "buttonOver.png",
                fontSize = fontSize(60),
                label = "Buy",
                labelColor = tableColor1,
                onEvent = buyBtn
            })
            row.buyButton.anchorX=0
            row.buyButton.anchorY=0
            row.buyButton.name = params.type
            row:insert(row.buyButton)
        else
            row.buyButton = widget.newButton(
            {
                left = row.width/3*2,
                top = row.rowDesc.y,
                width = 200,
                height = fontSize(100),
                defaultFile = buttonColor400,
               -- overFile = "buttonOver.png",
                fontSize = fontSize(60),
                label = "Buy",
                labelColor = tableColor1,
                onEvent = buyBtn
            })
            row.buyButton.anchorX=0
            row.buyButton.anchorY=1
            row.buyButton.cost=params.cost
            row.buyButton.name = params.type
            row:insert(row.buyButton)
        end
    end
end

crewShopEventListener=function(event)
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OPS.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OPS.. A network error occured...", { "Close" }, onAlert )
        end
  
        if (t.status == "OK") then

            --Money
            myData.moneyTextCS.text = format_thousand(t.money)
            myData.moneyTextCS.money = t.money

            myData.walletTextItems.text = format_thousand(t.wallet)
            myData.walletTextItems.value=t.wallet

            rowColor = {
                default = { 0, 0, 0, 0 }
            }
            lineColor = { 
                default = { 1, 1, 0.17 }
            }

            myData.itemsCSTable:deleteAllRows()
            itemsCSTable={}

            local slot=0
            if (tonumber(t.slot) < 25) then
                --New Slot
                slot=1
                local value = { 
                    id=1,
                    color=tableColor1,
                    height=fontSize(360),
                    type="new_slot",
                    title="Slot #"..(t.slot+1),
                    desc="Add the Slot #"..(t.slot+1).." to your crew.",
                    cost=math.pow(1.5,(t.slot-10))*50000000,
                    itemImage = "img/crew_slot.png"
                }
                itemsCSTable[value.id]=value

            end

            --Small Packs - 150cc
            local value = { 
                id=2,
                color=tableColor2,
                height=fontSize(600),
                type="sp",
                title="Small Pack",
                desc="Inside Small Packs you can find a small amount of money or upgrades for your arsenal.",
                cost=(10000000*t.members),
                itemImage = "img/small_packs.png"
            }
            itemsCSTable[value.id]=value

            --Medium Packs - 250cc
            local value = { 
                id=3,
                color=tableColor1,
                height=fontSize(600),
                type="mp",
                title="Medium Pack",
                desc="Inside Medium Packs you can find a medium amount of money, cryptocoins or upgrades for your arsenal.",
                cost=(20000000*t.members),
                itemImage = "img/medium_packs.png"
            }
            itemsCSTable[value.id]=value 

            --Large Packs - 600cc
            local value = { 
                id=4,
                color=tableColor2,
                height=fontSize(600),
                type="lp",
                title="Large Packs",
                desc="Inside Large Packs you can find a large amount of money, cryptocoins, upgrades for your arsenal or a special item.",
                cost=(40000000*t.members),
                itemImage = "img/large_packs.png"
            }
            itemsCSTable[value.id]=value

            --Small Money - 50cc
            local value = { 
                id=5,
                color=tableColor1,
                height=fontSize(570),
                type="sm",
                title="Small Money Pack",
                desc="Inside Small Money Packs you can find a small amount of money.",
                cost=(5000000*t.members),
                itemImage = "img/small_money_packs.png"
            }
            itemsCSTable[value.id]=value

            --Medium Packs - 100cc
            local value = { 
                id=6,
                color=tableColor2,
                height=fontSize(570),
                type="mm",
                title="Medium Money Pack",
                desc="Inside Medium Money Packs you can find a medium amount of money.",
                cost=(10000000*t.members),
                itemImage = "img/medium_money_packs.png"
            } 
            itemsCSTable[value.id]=value

            --Large Packs - 400cc
            local value = { 
                id=7,
                color=tableColor1,
                height=fontSize(600),
                type="lm",
                title="Large Money Pack",
                desc="Inside Large Money Packs you can find a large amount of money.",
                cost=(20000000*t.members),
                itemImage = "img/large_money_packs.png"
            }
            itemsCSTable[value.id]=value

            --Small Overclock Pack
            local value = { 
                id=8,
                color=tableColor2,
                height=fontSize(570),
                type="so",
                title="Small Overclock Pack",
                desc="Inside Small Overclock Packs you can find a small amount of overclocks.",
                cost=(7500000*t.members),
                itemImage = "img/small_overclock_pack.png"
            }
            itemsCSTable[value.id]=value

            --Medium Overclock Pack
            local value = { 
                id=9,
                color=tableColor1,
                height=fontSize(570),
                type="mo",
                title="Medium Overclock Pack",
                desc="Inside Medium Overclock Packs you can find a medium amount of overclocks.",
                cost=(15000000*t.members),
                itemImage = "img/medium_overclock_pack.png"
            }
            itemsCSTable[value.id]=value

            --Large Overclock Pack
            local value = { 
                id=10,
                color=tableColor2,
                height=fontSize(570),
                type="lo",
                title="Large Overclock Pack",
                desc="Inside Large Overclock Packs you can find a large amount of overclocks.",
                cost=(30000000*t.members),
                itemImage = "img/large_overclock_pack.png"
            }
            itemsCSTable[value.id]=value

            start=2
            if (slot==1) then start=1 end

            for count=start,10,1 do
                local tempExpanded=false
                local rowHeight=fontSize(220)
                if (expandedType==itemsCSTable[count].type) then 
                    expandedId=count
                    tempExpanded=true 
                    rowHeight=itemsCSTable[count].height
                end
                myData.itemsCSTable:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = rowHeight,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        id=itemsCSTable[count].id,
                        color=itemsCSTable[count].color,
                        height=itemsCSTable[count].height,  
                        type=itemsCSTable[count].type,
                        title=itemsCSTable[count].title,
                        desc=itemsCSTable[count].desc,  
                        cost=itemsCSTable[count].cost,
                        itemImage=itemsCSTable[count].itemImage,
                        expanded=tempExpanded
                    }
                })   
            end

            --Player
            if (string.len(t.username)>15) then myData.playerTextItems.size = fontSize(42) end
            myData.playerTextItems.text = t.username
        end    
        itemsLoaded=true
   end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function crewShopScene:create(event)
    group = self.view

    loginInfo = localToken()
    itemsLoaded = false

    isRewarded=true
    rewardRx=true

    iconSize=200

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextCS = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextCS.anchorX = 0
    myData.moneyTextCS.anchorY = 0.5
    myData.moneyTextCS:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextItems = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextItems.anchorX = 0.5
    myData.playerTextItems.anchorY = 0.5
    myData.playerTextItems:setFillColor( 0.9,0.9,0.9 )

    myData.ccRect = display.newImageRect( "img/crew_wallet_rect.png",display.contentWidth-20,fontSize(250) )
    myData.ccRect.anchorX = 0.5
    myData.ccRect.anchorY = 0
    myData.ccRect.x, myData.ccRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.ccRect)

    myData.walletTextItems = display.newText("",myData.ccRect.x,myData.ccRect.y+fontSize(100),native.systemFont, fontSize(80))
    myData.walletTextItems.anchorX = 0.5
    myData.walletTextItems.anchorY = 0
    myData.walletTextItems:setFillColor( 0.9,0.9,0.9 )

    myData.itemsRect = display.newImageRect( "img/items_rect.png",display.contentWidth-20,fontSize(1420) )
    myData.itemsRect.anchorX = 0.5
    myData.itemsRect.anchorY = 0
    myData.itemsRect.x, myData.itemsRect.y = display.contentWidth/2,myData.ccRect.y+myData.ccRect.height
    changeImgColor(myData.itemsRect)

    -- Create the widget
    myData.itemsCSTable = widget.newTableView(
        {
            left = myData.itemsRect.x,
            top = myData.itemsRect.y+fontSize(110),
            height = fontSize(1280),
            width = myData.itemsRect.width-60,
            onRowRender = onRowRender,
            --onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.itemsCSTable.anchorX=0.5
    myData.itemsCSTable.x=myData.itemsRect.x

    myData.backButton = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15) + topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Back",
        labelColor = tableColor1,
        onEvent = goBack
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextCS)
    group:insert(myData.playerTextItems)
    group:insert(myData.ccRect)
    group:insert(myData.walletTextItems)
    group:insert(myData.itemsRect)
    group:insert(myData.itemsCSTable)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
end

-- Home Show
function crewShopScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getCrewShop.php", "POST", crewShopEventListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
crewShopScene:addEventListener( "create", crewShopScene )
crewShopScene:addEventListener( "show", crewShopScene )
---------------------------------------------------------------------------------

return crewShopScene