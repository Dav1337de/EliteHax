local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local loadsave = require( "loadsave" )
local offerScene = composer.newScene()
widget.setTheme( "widget_theme_android_holo_dark" )
local itemsTable = {}
local expandedType=0
local expandedId=0
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local itemsEventListener

local function onAlert( event )
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

function goBackItems (event)
    if (tutOverlay==false) then
        backSound()
        if (itemsLoaded == true) then
            if (tm) then
                timer.cancel(tm)
            end
            if (tm2) then
                timer.cancel(tm2)
            end
            composer.removeScene( "offerScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 100})
        else
            composer.hideOverlay( "fade", 0 )
            itemsLoaded=true
        end
    end
end

local function goBack (event)
    if (event.phase == "ended") then
        if (itemsLoaded == true) then
            if (tm) then
                timer.cancel(tm)
            end
            if (tm2) then
                timer.cancel(tm2)
            end
            backSound()
            composer.removeScene( "offerScene" )
            composer.gotoScene("homeScene", {effect = "fade", time = 100})
        else
            backSound()
            composer.hideOverlay( "fade", 0 )
            itemsLoaded=true
        end
    end
end

local function openPackListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OPS.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )
        print(t)

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OPS.. A network error occured...", { "Close" }, onAlert )
        end
  
        if (t.status == "OK") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getItems.php", "POST", itemsEventListener, params )

            if ((t.type=="sp") or (t.type=="mp") or (t.type=="lp")) then
                local sceneOverlayOptions = 
                {
                    time = 300,
                    effect = "crossFade",
                    params = { 
                       new_money=t.new_money,
                       siem=t.siem,
                       firewall=t.firewall,
                       ips=t.ips,
                       anon=t.anon,
                       webs=t.webs,
                       apps=t.apps,
                       dbs=t.dbs,
                       gpu=t.gpu,
                       av=t.av,
                       malware=t.malware,
                       exploit=t.exploit,
                       scan=t.scan,
                       new_cc=t.new_cc,
                       new_sp=t.new_sp,
                       new_mp=t.new_mp,
                       new_lp=t.new_lp,
                       overclock=t.overclock,
                       type=t.type
                    },
                    isModal = true
                }
                composer.showOverlay( "packRewardScene", sceneOverlayOptions)
            elseif ((t.type=="sm") or (t.type=="mm") or (t.type=="lm")) then
                local sceneOverlayOptions = 
                {
                    time = 300,
                    effect = "crossFade",
                    params = { 
                       new_money=t.new_money,
                       type=t.type
                    },
                    isModal = true
                }
                composer.showOverlay( "packRewardScene", sceneOverlayOptions)
            elseif ((t.type=="so") or (t.type=="mo") or (t.type=="lo")) then
                local sceneOverlayOptions = 
                {
                    time = 300,
                    effect = "crossFade",
                    params = { 
                       new_overclock=t.new_overclock,
                       type=t.type
                    },
                    isModal = true
                }
                composer.showOverlay( "packRewardScene", sceneOverlayOptions)
            end

        end    
        itemsLoaded=true
   end
end

local function openConfirm(type, qty)
    return function(event)
        local i = event.index
        if ( i == 1 ) then
            itemsLoaded = false
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&type="..type.."&qty="..qty
            local params = {}
            params.headers = headers
            params.body = body
            rewardSound()
            network.request( host().."openPack.php", "POST", openPackListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function openBtn( event )
    if (event.phase == "ended") then
        local rowIndex=0
        local itemName=""
        if (event.target.name == "sp") then 
            rowIndex = 1
            itemName = "Small Pack"
        elseif (event.target.name == "mp") then 
            rowIndex = 2
            itemName = "Medium Pack"
        elseif (event.target.name == "lp") then 
            rowIndex = 3
            itemName = "Large Pack"
        elseif (event.target.name == "sm") then 
            rowIndex = 4 
            itemName = "Small Money Pack"
        elseif (event.target.name == "mm") then 
            rowIndex = 5 
            itemName = "Medium Money Pack"
        elseif (event.target.name == "lm") then 
            rowIndex = 6 
            itemName = "Large Money Pack"
        elseif (event.target.name == "so") then 
            rowIndex = 7
            itemName = "Small Overclock Pack"
        elseif (event.target.name == "mo") then 
            rowIndex = 8
            itemName = "Medium Overclock Pack"
        elseif (event.target.name == "lo") then 
            rowIndex = 9 
            itemName = "Large Overclock Pack"
        end
        local qty = tonumber(myData.itemsTable:getRowAtIndex(rowIndex).openQty.text)
        if (qty == 1) then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you want to open "..qty.." "..itemName.."?", { "Yes", "No" }, openConfirm(event.target.name,qty) )
        elseif (qty > 1) then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you want to open "..qty.." "..itemName.."s?", { "Yes", "No" }, openConfirm(event.target.name,qty) )
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
            network.request( host().."buyItem.php", "POST", itemsEventListener, params )
        elseif ( i == 2 ) then
            backSound()
        end
    end
end

local function buyBtn( event )
    if (event.phase == "ended") then
        local rowIndex=0
        local itemName=""
        if (event.target.name == "sp") then 
            rowIndex = 1
            itemName = "Small Pack"
        elseif (event.target.name == "mp") then 
            rowIndex = 2
            itemName = "Medium Pack"
        elseif (event.target.name == "lp") then 
            rowIndex = 3 
            itemName = "Large Pack"
        elseif (event.target.name == "sm") then 
            rowIndex = 4
            itemName = "Small Money Pack"
        elseif (event.target.name == "mm") then 
            rowIndex = 5 
            itemName = "Medium Money Pack"
        elseif (event.target.name == "lm") then 
            rowIndex = 6 
            itemName = "Large Money Pack"
        elseif (event.target.name == "so") then 
            rowIndex = 7
            itemName = "Small Overclock Pack"
        elseif (event.target.name == "mo") then 
            rowIndex = 8
            itemName = "Medium Overclock Pack"
        elseif (event.target.name == "lo") then 
            rowIndex = 9 
            itemName = "Large Overclock Pack"
        elseif (event.target.name == "ic") then 
            rowIndex = 10
            itemName = "IP Change"
        elseif (event.target.name == "str") then 
            rowIndex = 11
            itemName = "Skill Tree Reset"
        end
        local qty = tonumber(myData.itemsTable:getRowAtIndex(rowIndex).buyQty.text)
        local cost = myData.itemsTable:getRowAtIndex(rowIndex).buySlider.cost
        if (qty == 1) then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you want to buy "..qty.." "..itemName.." for "..(qty*cost).." CryptoCoins?", { "Yes", "No" }, buyConfirm(event.target.name,qty) )
        elseif (qty > 1) then
            tapSound()
            local alert = native.showAlert( "EliteHax", "Do you want to buy "..qty.." "..itemName.."s for "..(qty*cost).." CryptoCoins?", { "Yes", "No" }, buyConfirm(event.target.name,qty) )
        end
    end
end

local function buySliderListener( event )
    local value=event.value
    local max=tonumber(myData.ccTextItems.text)/event.target.cost
    if (value>100) then value=100 end
    local qty=math.floor(value*max/100)
    local rowIndex=0
    if (event.target.name == "sp") then rowIndex = 1
    elseif (event.target.name == "mp") then rowIndex = 2
    elseif (event.target.name == "lp") then rowIndex = 3
    elseif (event.target.name == "sm") then rowIndex = 4
    elseif (event.target.name == "mm") then rowIndex = 5
    elseif (event.target.name == "lm") then rowIndex = 6 
    elseif (event.target.name == "so") then rowIndex = 7
    elseif (event.target.name == "mo") then rowIndex = 8
    elseif (event.target.name == "lo") then rowIndex = 9
    elseif (event.target.name == "ic") then rowIndex = 10
    elseif (event.target.name == "str") then rowIndex = 11 end
    local current = myData.itemsTable:getRowAtIndex(rowIndex).buyQty.text
    if ( "moved" == event.phase ) then
        myData.itemsTable:getRowAtIndex(rowIndex).buyQty.text = qty
    end
end

local function openSliderListener( event )
    local value=event.value
    local max=event.target.max
    if (value>100) then value=100 end
    local qty=math.floor(value*max/100)
    local rowIndex=0
    if (event.target.name == "sp") then rowIndex = 1
    elseif (event.target.name == "mp") then rowIndex = 2
    elseif (event.target.name == "lp") then rowIndex = 3
    elseif (event.target.name == "sm") then rowIndex = 4
    elseif (event.target.name == "mm") then rowIndex = 5
    elseif (event.target.name == "lm") then rowIndex = 6
    elseif (event.target.name == "so") then rowIndex = 7
    elseif (event.target.name == "mo") then rowIndex = 8
    elseif (event.target.name == "lo") then rowIndex = 9 end
    local current = myData.itemsTable:getRowAtIndex(rowIndex).openQty.text
    if ( "moved" == event.phase ) then
        myData.itemsTable:getRowAtIndex(rowIndex).openQty.text = qty
    end
end

local function expandRow( event )
    local id=event.target.id
    local expanded=myData.itemsTable._view._rows[id]._view.expandBtn.expanded
    local tempExpanded

    myData.itemsTable:deleteAllRows()
    for count=1,11,1 do
        if (itemsTable[count].id==id) then
            if (expanded==false) then
                tapSound()
                rowHeight=fontSize(760)
                if ((itemsTable[count].type=="ic") or (itemsTable[count].type=="str")) then 
                    rowHeight=fontSize(650)
                end
                tempExpanded=true
                expandedId=count
                expandedType=itemsTable[count].type
            else
                backSound()
                tempExpanded=false
                expandedType=0
            end
        else
            rowHeight=fontSize(270)
            tempExpanded=false
        end
        myData.itemsTable:insertRow(
        {
            isCategory = isCategory,
            rowHeight = rowHeight,
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                id=itemsTable[count].id,
                type=itemsTable[count].type,  
                title=itemsTable[count].title,
                desc=itemsTable[count].desc,  
                cost=itemsTable[count].cost,
                qty=itemsTable[count].qty,
                color=itemsTable[count].color,
                itemImage=itemsTable[count].itemImage,
                expanded=tempExpanded
            }
        })   
    end
    if (myData.itemsTable:getRowAtIndex(expandedId+2)==nil) then
        myData.itemsTable:scrollToIndex( expandedId, 0 )
    end
end

local function onRowRender( event )

    local row = event.row
    local params = event.row.params

    row.rowRectangle = display.newRoundedRect( row, 0, 0, row.width-20, row.height-fontSize(20), 60 )
    row.rowRectangle.strokeWidth = 0
    row.rowRectangle.anchorX=0
    row.rowRectangle.anchorY=0
    row.rowRectangle.x,row.rowRectangle.y=10,10
    row.rowRectangle:setFillColor(params.color.default[1],params.color.default[2],params.color.default[3])
    row.rowRectangle:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )

    row.rowTitle = display.newText( row, params.title, 0, 0, native.systemFont, fontSize(58) )
    row.rowTitle.anchorX=0
    row.rowTitle.anchorY=0
    row.rowTitle.x =  iconSize+30
    row.rowTitle.y = fontSize(30)
    row.rowTitle:setTextColor( 0, 0, 0 )

    row.rowQty = display.newText( row, "Q.ty: "..params.qty.."\nCost: "..params.cost.." Cryptocoins", 0, 0, native.systemFont, fontSize(50) )
    row.rowQty.anchorX = 0
    row.rowQty.anchorY = 0
    row.rowQty.x =  iconSize+30
    row.rowQty.y = row.rowTitle.y+row.rowTitle.height+10
    row.rowQty:setTextColor( 0, 0, 0 )

    upgradeImage = display.newImageRect(row, params.itemImage, iconSize*0.9, iconSize*0.9)
    upgradeImage.x = (iconSize/2)+20
    upgradeImage.y = (iconSize/2)+fontSize(40)
    if ((params.type ~= "so") and (params.type ~= "mo") and (params.type ~= "lo")) then
        changeImgColor(upgradeImage)
    end

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

        if ((params.type ~= "ic") and (params.type ~= "str")) then
            row.openQty = display.newText( row, "0", 0, 0, native.systemFont, fontSize(60) )
            row.openQty.anchorX = 0.5
            row.openQty.anchorY = 0
            row.openQty.x = (row.width/3*2)/2+40
            row.openQty.y = row.rowDesc.y+row.rowDesc.height/2+fontSize(50)
            row.openQty:setTextColor( 0, 0, 0 )

            -- Image sheet options and declaration
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
            row.openSlider = widget.newSlider(
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
                    top = row.openQty.y+row.openQty.height,
                    left= 40,
                    orientation = "horizontal",
                    width = row.width/3*2,
                    listener = openSliderListener
                }
            )
            row.openSlider.max = params.qty
            row.openSlider.name = params.type
            row:insert(row.openSlider)


            row.openButton = widget.newButton(
            {
                left = row.openSlider.x+row.openSlider.width-50,
                top = row.openQty.y-fontSize(10),
                width = 200,
                height = fontSize(100),
                defaultFile = buttonColor400,
               -- overFile = "buttonOver.png",
                fontSize = fontSize(60),
                label = "Open",
                labelColor = tableColor1,
                onEvent = openBtn
            })
            row.openButton.anchorX=0
            row.openButton.anchorY=0
            row.openButton.name = params.type
            row:insert(row.openButton)

            row.buyQty = display.newText( row, "0", 0, 0, native.systemFont, fontSize(60) )
            row.buyQty.anchorX = 0.5
            row.buyQty.anchorY = 0
            row.buyQty.x = (row.width/3*2)/2+40
            row.buyQty.y = row.openButton.y+row.openButton.height/2+fontSize(60)
            row.buyQty:setTextColor( 0, 0, 0 )
        else
            row.buyQty = display.newText( row, "0", 0, 0, native.systemFont, fontSize(60) )
            row.buyQty.anchorX = 0.5
            row.buyQty.anchorY = 0
            row.buyQty.x = (row.width/3*2)/2+40
            row.buyQty.y = row.rowDesc.y+row.rowDesc.height/2+fontSize(50)
            row.buyQty:setTextColor( 0, 0, 0 )
        end

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

        row.line = display.newLine( row, 0, row.contentHeight-5, row.width, row.contentHeight-5 )
        row.line.anchorY = 1
        row.line:setStrokeColor( 0, 0, 0, 1 )
        row.line.strokeWidth = 8
    end
end

itemsEventListener=function( event )
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
            myData.moneyTextItems.text = format_thousand(t.money)
            myData.moneyTextItems.money = t.money

            myData.ccTextItems.text = t.cc
            myData.ccIcon.x=myData.ccTextItems.x-myData.ccTextItems.width/2-10

            rowColor = {
                default = { 0, 0, 0, 0 }
            }
            lineColor = { 
                default = { 1, 1, 0.17 }
            }

            myData.itemsTable:deleteAllRows()
            itemsTable={}


            --Small Packs - 100cc
            local value = { 
                id=1,
                type="sp",
                title="Small Packs",
                desc="Inside Small Packs you can find a small amount of money, upgrades for your arsenal or overclocks.",
                cost=100,
                qty=t.sp,
                color=tableColor1,
                itemImage = "img/small_packs.png"
            }
            itemsTable[value.id]=value

            --Medium Packs - 200cc
            local value = { 
                id=2,
                type="mp",
                title="Medium Packs",
                desc="Inside Medium Packs you can find a medium amount of money, cryptocoins, upgrades for your arsenal or overclocks.",
                cost=200,
                qty=t.mp,
                color=tableColor2,
                itemImage = "img/medium_packs.png"
            }
            itemsTable[value.id]=value

            --Large Packs - 400cc
            local value = {
                id=3,
                type="lp",
                title="Large Packs",
                desc="Inside Large Packs you can find a large amount of money, cryptocoins, upgrades for your arsenal, overclocks or a special item.",
                cost=400,
                qty=t.lp,
                color=tableColor1,
                itemImage = "img/large_packs.png"
            }
            itemsTable[value.id]=value

            --Small Money - 50cc
            local value = { 
                id=4,
                type="sm",
                title="Small Money Packs",
                desc="Inside Small Money Packs you can find a small amount of money.",
                cost=50,
                qty=t.sm,
                color=tableColor2,
                itemImage = "img/small_money_packs.png"
            }
            itemsTable[value.id]=value

            --Medium Packs - 100cc
            local value = { 
                id=5,
                type="mm",
                title="Medium Money Packs",
                desc="Inside Medium Money Packs you can find a medium amount of money.",
                cost=100,
                qty=t.mm,
                color=tableColor1,
                itemImage = "img/medium_money_packs.png"
            }
            itemsTable[value.id]=value

            --Large Packs - 400cc
            local value = { 
                id=6,
                type="lm",
                title="Large Money Packs",
                desc="Inside Large Money Packs you can find a large amount of money.",
                cost=200,
                qty=t.lm,
                color=tableColor2,
                itemImage = "img/large_money_packs.png"
            }
            itemsTable[value.id]=value

            --Small Overclock Pack
            local value = { 
                id=7,
                type="so",
                title="Small Overclock Packs",
                desc="Inside Small Overclock Packs you can find a small amount of overclocks.",
                cost=75,
                qty=t.small_oc_packs,
                color=tableColor1,
                itemImage = "img/small_overclock_pack.png"
            }
            itemsTable[value.id]=value

            --Medium Overclock Pack
            local value = { 
                id=8,
                type="mo",
                title="Medium Overclock Packs",
                desc="Inside Medium Overclock Packs you can find a medium amount of overclocks.",
                cost=150,
                qty=t.medium_oc_packs,
                color=tableColor2,
                itemImage = "img/medium_overclock_pack.png"
            }
            itemsTable[value.id]=value

            --Large Overclock Pack
            local value = { 
                id=9,
                type="lo",
                title="Large Overclock Packs",
                desc="Inside Large Overclock Packs you can find a large amount of overclocks.",
                cost=300,
                qty=t.large_oc_packs,
                color=tableColor1,
                itemImage = "img/large_overclock_pack.png"
            }
            itemsTable[value.id]=value

            --IP Change
            local value = { 
                id=10,
                type="ic",
                title="IP Change",
                desc="IP Change lets you change your in-game IP Address. Note that if someone have a RAT on you, they will see your new IP Address.",
                cost=2500,
                qty=t.ip_change,
                color=tableColor2,
                itemImage = "img/ip_change.png"
            }
            itemsTable[value.id]=value

            --Skill Tree Reset
            local value = { 
                id=11,
                type="str",
                title="Skill Tree Reset",
                desc="Skill Tree Reset lets you reset your Skill Tree, giving back your Skill Points to choose a different path.",
                cost=5000,
                qty=t.st_reset,
                color=tableColor1,
                itemImage = "img/st_reset.png"
            }
            itemsTable[value.id]=value

            for count=1,11,1 do
                local tempExpanded=false
                local rowHeight=fontSize(270)
                if (expandedType==itemsTable[count].type) then 
                    expandedId=count
                    tempExpanded=true 
                    rowHeight=fontSize(800)
                end
                myData.itemsTable:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = rowHeight,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = { 
                        id=itemsTable[count].id,
                        type=itemsTable[count].type,  
                        title=itemsTable[count].title,
                        desc=itemsTable[count].desc,  
                        cost=itemsTable[count].cost,
                        qty=itemsTable[count].qty,
                        color=itemsTable[count].color,
                        itemImage=itemsTable[count].itemImage,
                        expanded=tempExpanded
                    }
                })   
            end

            --Player
            if (string.len(t.username)>15) then myData.playerTextItems.size = fontSize(42) end
            myData.playerTextItems.text = t.username

            myData.ccCollectBtn:setLabel("Collect "..t.new_cryptocoins.." Cryptocoins")
            myData.ccCollectBtn.new_cc=t.new_cryptocoins
        end    
        itemsLoaded=true
   end
end

local function collectCCEventListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OPS.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )
        print(t)

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OPS.. A network error occured...", { "Close" }, onAlert )
        end
  
        if (t.status == "OK") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getItems.php", "POST", itemsEventListener, params )
        end    
   end
end

local function collectCC( event )
    if ((event.phase == "ended") and (itemsLoaded==true) and (tonumber(event.target.new_cc)>0)) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."collectCC.php", "POST", collectCCEventListener, params )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function offerScene:create(event)
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
    myData.moneyTextItems = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextItems.anchorX = 0
    myData.moneyTextItems.anchorY = 0.5
    myData.moneyTextItems:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextItems = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextItems.anchorX = 0.5
    myData.playerTextItems.anchorY = 0.5
    myData.playerTextItems:setFillColor( 0.9,0.9,0.9 )

    myData.ccRect = display.newImageRect( "img/cryptocoins_rect.png",display.contentWidth-20,fontSize(340) )
    myData.ccRect.anchorX = 0.5
    myData.ccRect.anchorY = 0
    myData.ccRect.x, myData.ccRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.ccRect)

    myData.ccTextItems = display.newText("",myData.ccRect.x+40,myData.ccRect.y+fontSize(100),native.systemFont, fontSize(60))
    myData.ccTextItems.anchorX = 0.5
    myData.ccTextItems.anchorY = 0
    myData.ccTextItems:setFillColor( 0.9,0.9,0.9 )

    myData.ccIcon = display.newImageRect( "img/cryptocoin.png",fontSize(70),fontSize(70) )
    myData.ccIcon.anchorX = 1
    myData.ccIcon.anchorY = 0
    myData.ccIcon.x, myData.ccIcon.y = myData.ccTextItems.x-myData.ccTextItems.width/2-10,myData.ccTextItems.y+10

    myData.ccCollectBtn = widget.newButton(
    {
        left = display.contentWidth/2,
        top = myData.ccTextItems.y+myData.ccTextItems.height+fontSize(25),
        width = myData.ccRect.width-300,
        height = fontSize(100),
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "",
        labelColor = tableColor1,
        onEvent = collectCC
    })
    myData.ccCollectBtn.anchorX=0.5
    myData.ccCollectBtn.x=display.contentWidth/2
    myData.ccCollectBtn.new_cc=0
    myData.ccCollectBtn:addEventListener("tap",collectCC)

    myData.itemsRect = display.newImageRect( "img/items_rect.png",display.contentWidth-20,fontSize(1350) )
    myData.itemsRect.anchorX = 0.5
    myData.itemsRect.anchorY = 0
    myData.itemsRect.x, myData.itemsRect.y = display.contentWidth/2,myData.ccRect.y+myData.ccRect.height
    changeImgColor(myData.itemsRect)

    -- Create the widget
    myData.itemsTable = widget.newTableView(
        {
            left = myData.itemsRect.x,
            top = myData.itemsRect.y+fontSize(110),
            height = fontSize(1210),
            width = myData.itemsRect.width-60,
            onRowRender = onRowRender,
            --onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.itemsTable.anchorX=0.5
    myData.itemsTable.x=myData.itemsRect.x

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
    group:insert(myData.moneyTextItems)
    group:insert(myData.playerTextItems)
    group:insert(myData.ccRect)
    group:insert(myData.ccTextItems)
    group:insert(myData.ccIcon)
    group:insert(myData.ccCollectBtn)
    group:insert(myData.itemsRect)
    group:insert(myData.itemsTable)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBack)
end

-- Home Show
function offerScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "itemsTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutItems ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "offerTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getItems.php", "POST", itemsEventListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
offerScene:addEventListener( "create", offerScene )
offerScene:addEventListener( "show", offerScene )
---------------------------------------------------------------------------------

return offerScene