local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local store = require("plugin.google.iap.v3")
local supporterScene = composer.newScene()
local itemsLoaded=false
local psTimer=nil
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function goBackPlayerSupporter( event )
    if (tutOverlay==false) then
        if (skinOverlay==true) then
            backSound()
            composer.hideOverlay( "fade", 0 )
            skinOverlay=false
        else
            backSound()
            composer.removeScene( "supporterScene" )
            composer.gotoScene("playerSettingScene", {effect = "fade", time = 100})
        end
    end
end

local function goBackPS( event )
    if (event.phase=="ended") then
        if (tutOverlay==false) then
            if (skinOverlay==true) then
                backSound()
                composer.hideOverlay( "fade", 0 )
                skinOverlay=false
            else
                backSound()
                composer.removeScene( "supporterScene" )
                composer.gotoScene("playerSettingScene", {effect = "fade", time = 100})
            end
        end
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

local function buyListener( event )
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

        if (t.enabled == "supporter_bronze") then
            myData.buyBronzeBtn:setLabel("30 Days Left")
            myData.buyBronzeBtn.fn="none"
        elseif (t.enabled == "supporter_silver") then
            myData.buyBronzeBtn.alpha=0
            myData.buySilverBtn:setLabel("30 Days Left")
            myData.buySilverBtn.fn="none"
        elseif (t.enabled == "supporter_gold") then
            myData.buyBronzeBtn.alpha=0
            myData.buySilverBtn.alpha=0
            myData.buyGoldBtn:setLabel("30 Days Left")
            myData.buyGoldBtn.fn="none"
        end
        canBuy=true
    end
end

local function transactionListener( event )
    print("Store Transaction Listener")
    -- Google IAP initialization event
    if ( event.name == "init" ) then
        print("Using Google's Android In-App Billing system.")
        if not ( event.transaction.isError ) then
            -- Perform steps to enable IAP, load products, etc.
            print("Store INIT successfully!")
 
        else  -- Unsuccessful initialization; output error details
            print( event.transaction.errorType )
            print( event.transaction.errorString )
        end
 
    -- Store transaction event
    elseif ( event.name == "storeTransaction" ) then
        local transaction = event.transaction
         
        if ( transaction.isError ) then
            print( transaction.errorType )
            print( transaction.errorString )
            canBuy=true
        else
            -- No errors; proceed
            if ( transaction.state == "purchased" or transaction.state == "restored" ) then
                -- Handle a normal purchase or restored purchase here
                print( transaction.state )
                print( transaction.productIdentifier )
                print( transaction.date )
                if (transaction.state == "purchased") then
                    print(transaction.productIdentifier.." PURCHASED!")
                    store.consumePurchase(transaction.productIdentifier)
                end

            elseif ( transaction.state == "consumed") then
                --nameChangeBackend()
                print(transaction.productIdentifier.." CONSUMED!")
                --Add Item
                local headers = {}
                local body = "id="..string.urlEncode(loginInfo.token).."&tid="..string.urlEncode(transaction.identifier).."&tdata="..string.urlEncode(transaction.originalJson).."&tsignature="..string.urlEncode(transaction.signature)
                local params = {}
                params.headers = headers
                params.body = body
                print(body)
                network.request( host().."buySupporter.php", "POST", buyListener, params )
     
            elseif ( transaction.state == "cancelled" ) then
                -- Handle a cancelled transaction here
                canBuy=true
     
            elseif ( transaction.state == "failed" ) then
                -- Handle a failed transaction here
                canBuy=true
            end
     
            -- Tell the store that the transaction is complete
            -- If you're providing downloadable content, do not call this until the download has completed
            store.finishTransaction( transaction )
        end
    end
end

local function buySubscription(event)
    if ((event.phase=="ended") and (itemsLoaded==true) and (event.target.fn=="buy") and (canBuy==true)) then
        canBuy=false
        store.purchase(event.target.value)
    end
end

local function productListener( event )
    print( "Valid products:", #event.products )
    print( "Invalid products:", #event.invalidProducts )

    local price=""
    for i=1, #event.products do
        --print(event.products[i].productIdentifier.." "..event.products[i].localizedPrice)
        if (event.products[i].productIdentifier=="it.elitehax.supporter_bronze") then
            if (myData.buyBronzeBtn.fn=="buy") then
                myData.buyBronzeBtn.alpha=1
                myData.buyBronzeBtn:setLabel("Buy ("..event.products[i].localizedPrice.."/30 days)")
            end
        elseif (event.products[i].productIdentifier=="it.elitehax.supporter_silver") then
            if (myData.buySilverBtn.fn=="buy") then
                myData.buySilverBtn.alpha=1
                myData.buySilverBtn:setLabel("Buy ("..event.products[i].localizedPrice.."/30 days)")
            end
        elseif (event.products[i].productIdentifier=="it.elitehax.supporter_gold") then
            if (myData.buyGoldBtn.fn=="buy") then
                myData.buyGoldBtn.alpha=1
                myData.buyGoldBtn:setLabel("Buy ("..event.products[i].localizedPrice.."/30 days)")
            end
        end
    end
    itemsLoaded=true
end

local function loadStoreProducts( event )
    print("Loading Products")
    if ( store.canLoadProducts ) and ( itemsLoaded==false ) then
     
        local productIdentifiers = {
            "it.elitehax.supporter_bronze",
            "it.elitehax.supporter_silver",
            "it.elitehax.supporter_gold"
        }
        store.loadProducts( productIdentifiers, productListener )
    elseif (storeRetries<20) then
        storeRetries=storeRetries+1
        psTimer=timer.performWithDelay(200,loadStoreProducts)
    else
        local alert = native.showAlert( "EliteHax", "Cannot access Google Play Store, try again later or contact support@elitehax.it", { "Close" }, close)

    end
end

local function supporterNetworkListener( event )
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
        myData.moneyTextPlayerS.text = format_thousand(t.money)
        myData.moneyTextPlayerS.money = t.money

        --Player
        if (string.len(t.username)>15) then myData.playerTextPlayerS.size = fontSize(42) end
        myData.playerTextPlayerS.text = t.username

        store.init( transactionListener )
        psTimer=timer.performWithDelay(100,loadStoreProducts)

        if (t.bronze>0) then
            myData.buyBronzeBtn.fn="none"
            myData.buyBronzeBtn.alpha=1
            myData.buyBronzeBtn:setLabel(t.bronze.." Days Left")
        end
        if (t.silver>0) then
            myData.buyBronzeBtn.fn="none"
            myData.buySilverBtn.fn="none"
            myData.buySilverBtn.alpha=1
            myData.buySilverBtn:setLabel(t.silver.." Days Left")
        end
        if (t.gold>0) then
            myData.buyBronzeBtn.fn="none"
            myData.buySilverBtn.fn="none"
            myData.buyGoldBtn.fn="none"
            myData.buyGoldBtn.alpha=1
            myData.buyGoldBtn:setLabel(t.gold.." Days Left")
        end

        loaded=true

    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function supporterScene:create(event)
    group = self.view

    loginInfo = localToken()

    storeRetries=0
    canBuy=true
    iconSize=fontSize(200)

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background.x, myData.top_background.y = display.contentWidth/2,5+topPadding()
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextPlayerS = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextPlayerS.anchorX = 0
    myData.moneyTextPlayerS.anchorY = 0.5
    myData.moneyTextPlayerS:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextPlayerS = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextPlayerS.anchorX = 0.5
    myData.playerTextPlayerS.anchorY = 0.5
    myData.playerTextPlayerS:setFillColor( 0.9,0.9,0.9 )

    --Player Setting Rect
    myData.playerSRect = display.newImageRect( "img/player_subscriptions_rect.png",display.contentWidth-20, fontSize(1680))
    myData.playerSRect.anchorX = 0.5
    myData.playerSRect.anchorY = 0
    myData.playerSRect.x, myData.playerSRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height
    changeImgColor(myData.playerSRect)

    myData.supporterBronzeRect = display.newImageRect( "img/supporter_bronze_rect.png",myData.playerSRect.width-80, fontSize(450))
    myData.supporterBronzeRect.anchorX = 0.5
    myData.supporterBronzeRect.anchorY = 0
    myData.supporterBronzeRect.x, myData.supporterBronzeRect.y = display.contentWidth/2,myData.playerSRect.y+fontSize(110)

    myData.descBronze = display.newText(" - Bronze Supporter Badge in Player Profile",myData.supporterBronzeRect.x-myData.supporterBronzeRect.width/2+30,myData.supporterBronzeRect.y+fontSize(110),native.systemFont, fontSize(48))
    myData.descBronze.anchorX = 0
    myData.descBronze.anchorY = 0
    myData.descBronze:setFillColor( 0.9,0.9,0.9 )

    myData.buyBronzeBtn = widget.newButton(
    {
        left = display.contentWidth/2-display.contentWidth/3.2,
        top = myData.supporterBronzeRect.y+myData.supporterBronzeRect.height-fontSize(130),
        width = display.contentWidth/1.6,
        height = fontSize(110),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "",
        labelColor = tableColor1,
        onEvent = buySubscription
    })
    myData.buyBronzeBtn.alpha=0
    myData.buyBronzeBtn.value="it.elitehax.supporter_bronze"
    myData.buyBronzeBtn.fn="buy"

    myData.supporterSilverRect = display.newImageRect( "img/supporter_silver_rect.png",myData.playerSRect.width-80, fontSize(450))
    myData.supporterSilverRect.anchorX = 0.5
    myData.supporterSilverRect.anchorY = 0
    myData.supporterSilverRect.x, myData.supporterSilverRect.y = display.contentWidth/2,myData.supporterBronzeRect.y+myData.supporterBronzeRect.height+fontSize(30)

    myData.descSilver = display.newText(" - Silver Supporter Badge in Player Profile\n - Silver Sign under Profile Picture",myData.supporterSilverRect.x-myData.supporterSilverRect.width/2+30,myData.supporterSilverRect.y+fontSize(110),native.systemFont, fontSize(48))
    myData.descSilver.anchorX = 0
    myData.descSilver.anchorY = 0
    myData.descSilver:setFillColor( 0.9,0.9,0.9 )

    myData.buySilverBtn = widget.newButton(
    {
        left = display.contentWidth/2-display.contentWidth/3.2,
        top = myData.supporterSilverRect.y+myData.supporterSilverRect.height-fontSize(130),
        width = display.contentWidth/1.6,
        height = fontSize(110),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "",
        labelColor = tableColor1,
        onEvent = buySubscription
    })
    myData.buySilverBtn.alpha=0
    myData.buySilverBtn.value="it.elitehax.supporter_silver"
    myData.buySilverBtn.fn="buy"

    myData.supporterGoldRect = display.newImageRect( "img/supporter_gold_rect.png",myData.playerSRect.width-80, fontSize(450))
    myData.supporterGoldRect.anchorX = 0.5
    myData.supporterGoldRect.anchorY = 0
    myData.supporterGoldRect.x, myData.supporterGoldRect.y = display.contentWidth/2,myData.supporterSilverRect.y+myData.supporterSilverRect.height+fontSize(30)

    myData.descGold = display.newText(" - Gold chatbox and SUP chat badge\n - Gold Supporter Badge in Player Profile\n - Gold Sign under Profile Picture",myData.supporterGoldRect.x-myData.supporterGoldRect.width/2+30,myData.supporterGoldRect.y+fontSize(110),native.systemFont, fontSize(48))
    myData.descGold.anchorX = 0
    myData.descGold.anchorY = 0
    myData.descGold:setFillColor( 0.9,0.9,0.9 )

    myData.buyGoldBtn = widget.newButton(
    {
        left = display.contentWidth/2-display.contentWidth/3.2,
        top = myData.supporterGoldRect.y+myData.supporterGoldRect.height-fontSize(130),
        width = display.contentWidth/1.6,
        height = fontSize(110),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "",
        labelColor = tableColor1,
        onEvent = buySubscription
    })
    myData.buyGoldBtn.alpha=0
    myData.buyGoldBtn.value="it.elitehax.supporter_gold"
    myData.buyGoldBtn.fn="buy"

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
        onEvent = goBackPS
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(myData.playerTextPlayerS)
    group:insert(myData.moneyTextPlayerS)
    group:insert(myData.backButton)
    group:insert(myData.playerSRect)
    group:insert(myData.supporterBronzeRect)
    group:insert(myData.supporterSilverRect)
    group:insert(myData.supporterGoldRect)
    group:insert(myData.buyBronzeBtn)
    group:insert(myData.buySilverBtn)
    group:insert(myData.buyGoldBtn)
    group:insert(myData.descBronze)
    group:insert(myData.descSilver)
    group:insert(myData.descGold)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackPS)

end

-- Home Show
function supporterScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        loaded=false
        local tutCompleted = loadsave.loadTable( "supporterTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutSupporter ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "supporterTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getSupporter.php", "POST", supporterNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end

---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
supporterScene:addEventListener( "create", supporterScene )
supporterScene:addEventListener( "show", supporterScene )
supporterScene:addEventListener( "destroy", supporterScene )
---------------------------------------------------------------------------------

return supporterScene