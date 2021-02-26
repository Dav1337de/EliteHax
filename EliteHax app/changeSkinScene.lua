local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local store = require("plugin.google.iap.v3")
local changeSkinScene = composer.newScene()
local psTimer=nil

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local touchListener
local itemsLoaded=false

local price=""
local productName=""
local blue_skin=0
local red_skin=0
local yellow_skin=0
local purple_skin=0
local orange_skin=0
local silver_skin=0
local aqua_skin=0

local pad=0
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------


local close = function(event)
    if (psTimer) then timer.cancel(psTimer) end
    skinOverlay=false
    composer.hideOverlay( "fade",0 )
end

local function onAlert()
end

local function buySkinListener( event )
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

        blue_skin=t.blue_skin
        red_skin=t.red_skin
        yellow_skin=t.yellow_skin
        purple_skin=t.purple_skin
        orange_skin=t.orange_skin
        silver_skin=t.silver_skin
        aqua_skin=t.aqua_skin

        myData.setSkinBtn:setLabel("Set as Skin")
        myData.setSkinBtn.fn="change"

    end
end

local imageSet = {
    "img/skinGreen.PNG",
    "img/skinBlue.PNG",
    "img/skinRed.PNG",
    "img/skinYellow.PNG",
    "img/skinPurple.PNG",
    "img/skinOrange.PNG",
    "img/skinSilver.PNG",
    "img/skinAqua.PNG"
}

local function setSkinListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        else
            skinColor=skin
            applySkin(skin)
            reloadSettings()
            close()
        end
    end
end

local function setSkin( event )
    if (event.phase=="ended") then
        tapSound()
        if (selectedSkin==2) then skin="blue"
        elseif (selectedSkin==3) then skin="red"
        elseif (selectedSkin==4) then skin="yellow"
        elseif (selectedSkin==5) then skin="purple"
        elseif (selectedSkin==6) then skin="orange"
        elseif (selectedSkin==7) then skin="silver"
        elseif (selectedSkin==8) then skin="aqua"
        else skin="green" end
        if (event.target.fn=="change") then
            local skinColorTmp = {
                skinColor = skin
            }
            loadsave.saveTable( skinColorTmp, "skinColor.json" )
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&skin="..skin
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."setSkin.php", "POST", setSkinListener, params )
        elseif (event.target.fn=="buy") then
            print("Buying..")
            --Buy From Store
            if ( itemsLoaded==true ) then 
                store.purchase(productName)
            end
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
                print( transaction.token )
                print( transaction.identifier )
                if (transaction.state == "purchased") then
                    --Add Item
                    local headers = {}
                    local body = "id="..string.urlEncode(loginInfo.token).."&tid="..string.urlEncode(transaction.identifier).."&skin="..skin.."&tdata="..string.urlEncode(transaction.originalJson).."&tsignature="..string.urlEncode(transaction.signature)
                    local params = {}
                    params.headers = headers
                    params.body = body
                    network.request( host().."buySkin.php", "POST", buySkinListener, params )
                end

            elseif ( transaction.state == "consumed") then
     
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
    price = "Buy ("..event.products[1].localizedPrice..")"
    print("Skins item succesfully loaded!")
    itemsLoaded=true
end

local function loadStoreProducts( event )
    print("Loading Products")
    if ( store.canLoadProducts ) and ( itemsLoaded==false ) then
     
        local productIdentifiers = {
            "it.elitehax.skin.blue",
            "it.elitehax.skin.red",
            "it.elitehax.skin.yellow",
            "it.elitehax.skin.purple",
            "it.elitehax.skin.orange",
            "it.elitehax.skin.silver",
            "it.elitehax.skin.aqua"
        }
        store.loadProducts( productIdentifiers, productListener )
    elseif (storeRetries<20) then
        storeRetries=storeRetries+1
        psTimer=timer.performWithDelay(200,loadStoreProducts)
    else
        local alert = native.showAlert( "EliteHax", "Cannot access Google Play Store, try again later or contact support@elitehax.it", { "Close" }, close)
    end
end

local function getSkinsListener( event )
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

        print("INIT Called")
        store.init( transactionListener )
        psTimer=timer.performWithDelay(100,loadStoreProducts)
        
        blue_skin=t.blue_skin
        red_skin=t.red_skin
        yellow_skin=t.yellow_skin
        purple_skin=t.purple_skin
        orange_skin=t.orange_skin
        silver_skin=t.silver_skin
        aqua_skin=t.aqua_skin
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function changeSkinScene:create(event)
    group = self.view
    params = event.params

    loginInfo = localToken()
    selectedSkin=1
    storeRetries=0

    viewableScreenW = display.contentWidth
    viewableScreenH = display.contentHeight - 120 -- status bar + top bar + tabBar

    diconSize=250

    myData.skinRect = display.newImageRect( "img/skin_change_rect.png",display.contentWidth*1.2, fontSize(1350) )
    myData.skinRect.anchorX = 0.5
    myData.skinRect.anchorY = 0.5
    myData.skinRect:translate(display.contentWidth/2,display.actualContentHeight/2)
    changeImgColor(myData.skinRect)
    group:insert(myData.skinRect)
    
----------------------------------------------------------------

    images = {}
    for i = 1,#imageSet do
        local p = display.newImage(imageSet[i])
        local h = viewableScreenH-(200)
        p.anchorX=0.5
        print("Inserting "..i)

        group:insert(p)
        
        if (i == 2) then
            p.x = screenW*1.1
        elseif (i > 1) then
            p.x = screenW*1.5 + pad -- all images offscreen except the first one
        else
            p.x = screenW*.5
        end
        
        p.y = myData.skinRect.y-fontSize(60)
        p.width=657
        p.height=945
        --print("X: "..p.x.." Y: "..p.y.."Width: "..p.width.." Height: "..p.height)
        images[i] = p
    end
    
    imgNum = 1
                
    function touchListener (self, touch) 
        local phase = touch.phase
        print("slides", phase)
        if ( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the contentBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true

            startPos = touch.x
            prevPos = touch.x
            
        elseif( self.isFocus ) then
        
            if ( phase == "moved" ) then
                        
                if tween then transition.cancel(tween) end
    
                print(imgNum)
                
                local delta = touch.x - prevPos
                prevPos = touch.x
                
                images[imgNum].x = images[imgNum].x + delta
                
                if (images[imgNum-1]) then
                    images[imgNum-1].x = images[imgNum-1].x + delta
                end
                
                if (images[imgNum+1]) then
                    images[imgNum+1].x = images[imgNum+1].x + delta
                end

            elseif ( phase == "ended" or phase == "cancelled" ) then
                
                dragDistance = touch.x - startPos
                print("dragDistance: " .. dragDistance.." ImgNum: "..imgNum)
                
                if (dragDistance < -40 and imgNum < #images) then
                    nextImage()
                    selectedSkin=imgNum
                elseif (dragDistance > 40 and imgNum > 1) then
                    prevImage()
                    selectedSkin=imgNum
                else
                    cancelMove()
                    selectedSkin=imgNum
                end

                if (selectedSkin==1) then
                    print("Green")
                    myData.setSkinBtn:setLabel("Set as Skin")
                    myData.setSkinBtn.fn="change"
                elseif (selectedSkin==2) then
                    print("Blue")
                    if (blue_skin==0) then
                        myData.setSkinBtn:setLabel(price)
                        myData.setSkinBtn.fn="buy"
                        productName="it.elitehax.skin.blue"
                    else
                        myData.setSkinBtn:setLabel("Set as Skin")
                        myData.setSkinBtn.fn="change"
                    end
                elseif (selectedSkin==3) then
                    print("Red")
                    if (red_skin==0) then
                        myData.setSkinBtn:setLabel(price)
                        myData.setSkinBtn.fn="buy"
                        productName="it.elitehax.skin.red"
                    else
                        myData.setSkinBtn:setLabel("Set as Skin")
                        myData.setSkinBtn.fn="change"
                    end
                elseif (selectedSkin==4) then
                    print("Yellow")
                    if (yellow_skin==0) then
                        myData.setSkinBtn:setLabel(price)
                        myData.setSkinBtn.fn="buy"
                        productName="it.elitehax.skin.yellow"
                    else
                        myData.setSkinBtn:setLabel("Set as Skin")
                        myData.setSkinBtn.fn="change"
                    end
                elseif (selectedSkin==5) then
                    print("Purple")
                    if (purple_skin==0) then
                        myData.setSkinBtn:setLabel(price)
                        myData.setSkinBtn.fn="buy"
                        productName="it.elitehax.skin.purple"
                    else
                        myData.setSkinBtn:setLabel("Set as Skin")
                        myData.setSkinBtn.fn="change"
                    end
                elseif (selectedSkin==6) then
                    print("Orange")
                    if (orange_skin==0) then
                        myData.setSkinBtn:setLabel(price)
                        myData.setSkinBtn.fn="buy"
                        productName="it.elitehax.skin.orange"
                    else
                        myData.setSkinBtn:setLabel("Set as Skin")
                        myData.setSkinBtn.fn="change"
                    end
                elseif (selectedSkin==7) then
                    print("Silver")
                    if (silver_skin==0) then
                        myData.setSkinBtn:setLabel(price)
                        myData.setSkinBtn.fn="buy"
                        productName="it.elitehax.skin.silver"
                    else
                        myData.setSkinBtn:setLabel("Set as Skin")
                        myData.setSkinBtn.fn="change"
                    end
                elseif (selectedSkin==8) then
                    print("Aqua")
                    if (aqua_skin==0) then
                        myData.setSkinBtn:setLabel(price)
                        myData.setSkinBtn.fn="buy"
                        productName="it.elitehax.skin.aqua"
                    else
                        myData.setSkinBtn:setLabel("Set as Skin")
                        myData.setSkinBtn.fn="change"
                    end
                end      

                if ( phase == "cancelled" ) then        
                    cancelMove()
                    selectedSkin=imgNum
                end

                --print(selectedSkin)

                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
                                                        
            end
        end
                    
        return true
        
    end
    
    function nextImage()
        --tween = transition.to( images[imgNum], {time=400, x=(screenW*.5 + pad)*-1, transition=easing.outExpo } )
        tween = transition.to( images[imgNum], {time=400, x=screenW*.5-screenW*0.6, transition=easing.outExpo } )
        tween = transition.to( images[imgNum+1], {time=400, x=screenW*.5, transition=easing.outExpo } )
        imgNum = imgNum + 1
        initImage(imgNum)
    end
    
    function prevImage()
        tween = transition.to( images[imgNum], {time=400, x=screenW*1.1+pad, transition=easing.outExpo } )
        tween = transition.to( images[imgNum-1], {time=400, x=screenW*.5, transition=easing.outExpo } )
        imgNum = imgNum - 1
        initImage(imgNum)
    end
    
    function cancelMove()
        tween = transition.to( images[imgNum], {time=400, x=screenW*.5, transition=easing.outExpo } )
        tween = transition.to( images[imgNum-1], {time=400, x=screenW*.5-screenW*0.6, transition=easing.outExpo } )
        tween = transition.to( images[imgNum+1], {time=400, x=screenW*1.1+pad, transition=easing.outExpo } )
    end
    
    function initImage(num)
        if (num < #images) then
            images[num+1].x = screenW*1.1 + pad         
        end
        if (num > 1) then
            --images[num-1].x = (screenW*.5 + pad)*-1
            images[num-1].x = screenW*.5-screenW*0.6
        end
    end

    myData.skinRect.touch = touchListener
    myData.skinRect:addEventListener( "touch", myData.skinRect )
---------------------------------------------------------------------------------------------------------




    myData.setSkinBtn = widget.newButton(
    {
        left = display.contentWidth/2,
        top = images[1].y+images[1].height/2+fontSize(40),
        width = 500,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Set as Skin",
        labelColor = tableColor1,
        onEvent = setSkin
    })
    myData.setSkinBtn.anchorX=0.5
    myData.setSkinBtn.x=display.contentWidth/2
    myData.setSkinBtn.fn="change"


    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",diconSize/2.5,diconSize/2.5 )
    myData.closeBtn.anchorX = 1
    myData.closeBtn.anchorY = 0
    myData.closeBtn:translate(myData.skinRect.width+20, myData.skinRect.y-myData.skinRect.height/2+20)
    changeImgColor(myData.closeBtn)

    --  Show HUD    
    group:insert(myData.setSkinBtn)
    group:insert(myData.closeBtn)

    --  Button Listeners
    myData.setSkinBtn:addEventListener("tap", setSkin)
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function changeSkinScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        --if ( system.getInfo( "gpuSupportsHighPrecisionFragmentShaders" ) == false ) then
            -- This device may have problems with certain effects
            --local alert = native.showAlert( "EliteHax", "Unfortunately your device doesn't fully support skins.", { "Close" } )
        --end
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getSkins.php", "POST", getSkinsListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
changeSkinScene:addEventListener( "create", changeSkinScene )
changeSkinScene:addEventListener( "show", changeSkinScene )
---------------------------------------------------------------------------------

return changeSkinScene