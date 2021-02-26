local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local store = require("plugin.google.iap.v3")
local nameChangeScene = composer.newScene()
local itemsLoaded=false
local psTimer=nil
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> STORE
---------------------------------------------------------------------------------
local close = function(event)
    if (psTimer) then timer.cancel(psTimer) end
    skinOverlay=false
    backSound()
    composer.hideOverlay( "fade", 0 )
end

local function nameChangeListener( event )
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

        if (t.status == "UE") then
            local alert = native.showAlert( "EliteHax", "The username is already in use!", { "Close" } )
        end

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Username Changed successfully", { "Close" } )
            myData.playerTextPlayerS.text=t.new_name
            close()
        end
    end
end

local function nameChangeBackend( event )
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token).."&new_name="..string.urlEncode(myData.nameChangeNameT.text)
    local params = {}
    params.headers = headers
    params.body = body
    tapSound()
    network.request( host().."changeName.php", "POST", nameChangeListener, params )
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

        if (t.enabled == 1) then
            myData.nameChangeBtn:setLabel("Change")
            myData.nameChangeBtn.fn="change"
        end
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
        else
            -- No errors; proceed
            if ( transaction.state == "purchased" or transaction.state == "restored" ) then
                -- Handle a normal purchase or restored purchase here
                print( transaction.state )
                print( transaction.productIdentifier )
                print( transaction.date )
                if (transaction.state == "purchased") then
                    --Add Item
                    store.consumePurchase("it.elitehax.consumable.name_change")
                    local headers = {}
                    local body = "id="..string.urlEncode(loginInfo.token).."&tid="..string.urlEncode(transaction.identifier).."&tdata="..string.urlEncode(transaction.originalJson).."&tsignature="..string.urlEncode(transaction.signature)
                    local params = {}
                    params.headers = headers
                    params.body = body
                    network.request( host().."buyNameChange.php", "POST", buyListener, params )
                end

            elseif ( transaction.state == "consumed") then
                --nameChangeBackend()
     
            elseif ( transaction.state == "cancelled" ) then
                -- Handle a cancelled transaction here
     
            elseif ( transaction.state == "failed" ) then
                -- Handle a failed transaction here
            end
     
            -- Tell the store that the transaction is complete
            -- If you're providing downloadable content, do not call this until the download has completed
            store.finishTransaction( transaction )
        end
    end
end

local function productListener( event )
    print( "Valid products:", #event.products )
    print( "Invalid products:", #event.invalidProducts )
    myData.nameChangeBtn:setLabel("Buy ("..event.products[#event.products].localizedPrice..")")
    print("Name Change item succesfully loaded!")
    itemsLoaded=true
end

local function loadStoreProducts( event )
    print("Loading Products")
    if ( store.canLoadProducts ) and ( itemsLoaded==false ) then
     
        local productIdentifiers = {
            "it.elitehax.consumable.name_change"
        }
        store.loadProducts( productIdentifiers, productListener )
    elseif (storeRetries<20) then
        storeRetries=storeRetries+1
        psTimer=timer.performWithDelay(200,loadStoreProducts)
    else
        local alert = native.showAlert( "EliteHax", "Cannot access Google Play Store, try again later or contact support@elitehax.it", { "Close" }, close)

    end
end
---------------------------------------------------------------------------------

local function onAlert()
end

local function nameChange( event )
    local i = event.index
    if ( i == 1 ) then
        nameChangeBackend()
        --store.consumePurchase("it.elitehax.consumable.name_change")
    elseif ( i == 2 ) then
        --Nothing
    end
end

local function nameChangeAlert(event)
    if (event.phase == "ended") then
        if (event.target.fn=="buy") then
            print("Buying..")
            --Buy From Store
            if ( itemsLoaded==true ) then
             
                local productIdentifiers = {
                    "it.elitehax.consumable.name_change"
                }
                store.purchase("it.elitehax.consumable.name_change")
            end
        elseif (event.target.fn=="change") then
            --Check Syntax
            local user=myData.nameChangeNameT.text
            if ((string.len(user) < 4) or (string.len(user) > 18)) then
                local alert = native.showAlert( "EliteHax", "Username must be between 4 and 18 characters!", { "Close" } )
            elseif (string.match(string.sub(user,string.len(user),string.len(user)),"[^%a%d%.%!%_%-%s]")) then
                local alert = native.showAlert( "EliteHax", "Your username contains invalid characters\nAllowed characters (A-Za-z0-9.-_ )!", { "Close" } )
            else
                local alert = native.showAlert( "EliteHax", "Do you really want to change your name to "..user.."?", { "Yes", "No"}, nameChange )
            end
        end
    end
end

local function onNameEdit( event )
    if (event.phase == "editing") then
        if (string.len(event.text)>18) then
            myData.nameChangeNameT.text = string.sub(event.text,1,18)
        end
        if (string.match(string.sub(event.text,string.len(event.text),string.len(event.text)),"[^%a%d%.%!%_%-%s]")) then
            myData.nameChangeNameT.text = string.sub(event.text,1,string.len(event.text)-1)
        end
    end
end

local function ncListener( event )

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

        if (t.enabled == 0) then
            --Init Store
            print("INIT Called")
            store.init( transactionListener )
            myData.nameChangeBtn:setLabel("Buy")
            myData.nameChangeBtn.fn="buy"
            psTimer=timer.performWithDelay(100,loadStoreProducts)
        elseif (t.enabled == 1) then
            myData.nameChangeBtn:setLabel("Change")
            myData.nameChangeBtn.fn="change"
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function nameChangeScene:create(event)
    NCgroup = self.view

    editTargetRx=true
    storeRetries=0

    loginInfo = localToken()

    myData.nameChangeRect =  display.newImageRect( "img/name_change_rect.png",display.contentWidth-70,fontSize(600) )
    myData.nameChangeRect.anchorX = 0
    myData.nameChangeRect.anchorY = 0.5
    myData.nameChangeRect.x,myData.nameChangeRect.y = 40, display.contentHeight/2
    changeImgColor(myData.nameChangeRect)

    myData.nameChangeName = display.newText( "New Name: ", 0, 0, native.systemFont, fontSize(60) )
    myData.nameChangeName.anchorX=0.5
    myData.nameChangeName.anchorY=0
    myData.nameChangeName.x = display.contentWidth/2
    myData.nameChangeName.y = myData.nameChangeRect.y-myData.nameChangeRect.height/2+fontSize(150)
    myData.nameChangeName:setTextColor( 0.9, 0.9, 0.9 )
    myData.nameChangeNameT = native.newTextField( display.contentWidth/2, myData.nameChangeName.y+myData.nameChangeName.height+fontSize(20), display.contentWidth/1.5, fontSize(85) )
    myData.nameChangeNameT.anchorX = 0.5
    myData.nameChangeNameT.anchorY = 0
    myData.nameChangeNameT.placeholder = "New Name (max 18)";

    -- Close Button
    myData.nameChangeClose = display.newImageRect( "img/x.png",iconSize/2.5,iconSize/2.5 )
    myData.nameChangeClose.anchorX = 1
    myData.nameChangeClose.anchorY = 0
    myData.nameChangeClose.x, myData.nameChangeClose.y = myData.nameChangeRect.width, myData.nameChangeRect.y-myData.nameChangeRect.height/2+fontSize(80)
    changeImgColor(myData.nameChangeClose)

    -- Request Button
    myData.nameChangeBtn = widget.newButton(
    {
        left = 40,
        top = myData.nameChangeNameT.y+fontSize(160),
        width = display.contentWidth/2,
        height = fontSize(110),
        defaultFile = buttonColor400,
        -- overFile = "buttonOver.png",
        fontSize = fontSize(60),
        label = "",
        labelColor = tableColor1,
        onEvent = nameChangeAlert
    })
    myData.nameChangeBtn.fn="buy"
    myData.nameChangeBtn.anchorX = 0.5
    myData.nameChangeBtn.x = display.contentWidth/2

    --  Show HUD    
    NCgroup:insert(myData.nameChangeRect)
    NCgroup:insert(myData.nameChangeName)
    NCgroup:insert(myData.nameChangeBtn)
    NCgroup:insert(myData.nameChangeNameT)
    NCgroup:insert(myData.nameChangeClose)

    --  Button Listeners
    myData.nameChangeClose:addEventListener("tap", close)
    myData.nameChangeBtn:addEventListener("tap", nameChangeAlert)
    myData.nameChangeNameT:addEventListener( "userInput", onNameEdit )

end

-- Home Show
function nameChangeScene:show(event)
    local taskNCgroup = self.view
    if event.phase == "will" then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getNameChange.php", "POST", ncListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
nameChangeScene:addEventListener( "create", nameChangeScene )
nameChangeScene:addEventListener( "show", nameChangeScene )
---------------------------------------------------------------------------------

return nameChangeScene