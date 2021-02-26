local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local loadsave = require( "loadsave" )
local myData = require ("mydata")
local store = require("plugin.google.iap.v3")
local changeProfilePicScene = composer.newScene()
local psTimer=nil

local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local touchListener
local itemsLoaded=false

local price=""
local productName=""
local black_pic=0
local gray_pic=0
local ghost_pic=0
local pirate_pic=0
local ninja_pic=0
local anon_pic=0
local cyborg_pic=0
local wolf_pic=0
local tiger_pic=0
local santa_pic=1
local gas_mask_pic=0

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

        black_pic=t.black_pic
        gray_pic=t.gray_pic
        ghost_pic=t.ghost_pic
        pirate_pic=t.pirate_pic
        ninja_pic=t.ninja_pic
        anon_pic=t.anon_pic
        cyborg_pic=t.cyborg_pic
        wolf_pic=t.wolf_pic
        tiger_pic=t.tiger_pic
        gas_mask_pic=t.gas_mask_pic

        myData.setPicBtn:setLabel("Change")
        myData.setPicBtn.fn="change"

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
                    local headers = {}
                    local body = "id="..string.urlEncode(loginInfo.token).."&tid="..string.urlEncode(transaction.identifier).."&pic="..string.urlEncode(selectedPic).."&tdata="..string.urlEncode(transaction.originalJson).."&tsignature="..string.urlEncode(transaction.signature)
                    local params = {}
                    params.headers = headers
                    params.body = body
                    network.request( host().."buyProfilePic.php", "POST", buyListener, params )
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
    print("Profile Pictures item succesfully loaded!")
    itemsLoaded=true
end

local function loadStoreProducts( event )
    print("Loading Products")
    if ( store.canLoadProducts ) and ( itemsLoaded==false ) then
     
        local productIdentifiers = {
            "it.elitehax.black_pic",
            "it.elitehax.gray_pic",
            "it.elitehax.ghost_pic",
            "it.elitehax.pirate_pic",
            "it.elitehax.ninja_pic",
            "it.elitehax.anon_pic",
            "it.elitehax.cyborg_pic",
            "it.elitehax.wolf_pic",
            "it.elitehax.tiger_pic",
            "it.elitehax.gas_mask_pic"
        }
        store.loadProducts( productIdentifiers, productListener )
    elseif (storeRetries<20) then
        storeRetries=storeRetries+1
        psTimer=timer.performWithDelay(300,loadStoreProducts)
    else
        local alert = native.showAlert( "EliteHax", "Cannot access Google Play Store, try again later or contact support@elitehax.it", { "Close" }, close)
    end
end

local function getPPListener( event )
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
        
        black_pic=t.black_pic
        gray_pic=t.gray_pic
        ghost_pic=t.ghost_pic
        pirate_pic=t.pirate_pic
        ninja_pic=t.ninja_pic
        anon_pic=t.anon_pic
        cyborg_pic=t.cyborg_pic
        wolf_pic=t.wolf_pic
        tiger_pic=t.tiger_pic
        gas_mask_pic=t.gas_mask_pic
    end
end

local function onAlert()
end

local imageSet = {
    "img/profile_pic.png",
    "img/profile_pic_black.png",
    "img/profile_pic_gray.png",
    "img/profile_pic_ghost.png",
    "img/profile_pic_pirate.png",
    "img/profile_pic_ninja.png",
    "img/profile_pic_anon.png",
    "img/profile_pic_cyborg.png",
    "img/profile_pic_wolf.png",
    "img/profile_pic_tiger.png",
    "img/profile_pic_santa.png",
    "img/profile_pic_gas_mask.png"
}

local function setProfilePicListener( event )
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
            local alert = native.showAlert( "EliteHax", "New Profile Picture set", { "Close" }, close )
        end
    end
end

local function setProfilePic( event )
    if (event.phase=="ended") then
        tapSound()
        if (event.target.fn=="change") then
            local selectedPicTmp=selectedPic-1
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&pic="..selectedPicTmp
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."setProfilePic.php", "POST", setProfilePicListener, params )
        elseif (event.target.fn=="buy") then
            print("Buying..")
            --Buy From Store
            if ( itemsLoaded==true ) then 
                store.purchase(productName)
            end
        end
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function changeProfilePicScene:create(event)
    group = self.view
    params = event.params
    storeRetries=0

    loginInfo = localToken()
    selectedPic=1

    viewableScreenW = display.contentWidth
    viewableScreenH = display.contentHeight - 120 -- status bar + top bar + tabBar

    diconSize=250

    myData.picRect = display.newImageRect( "img/pic_change_rect.png",display.contentWidth*1.2, fontSize(1050) )
    myData.picRect.anchorX = 0.5
    myData.picRect.anchorY = 0.5
    myData.picRect:translate(display.contentWidth/2,display.actualContentHeight/2)
    changeImgColor(myData.picRect)
    group:insert(myData.picRect)
    
----------------------------------------------------------------

    images = {}
    for i = 1,#imageSet do
        local p = display.newImage(imageSet[i])
        local h = viewableScreenH-(200)
        p.anchorX=0.5
        --print("Inserting "..i)

        group:insert(p)
        
        if (i == 2) then
            p.x = screenW*1.1
        elseif (i > 1) then
            p.x = screenW*1.5 + pad -- all images offscreen except the first one
        else
            p.x = screenW*.5
        end
        
        p.y = myData.picRect.y-fontSize(60)
        p.width=657
        p.height=657
        --print("X: "..p.x.." Y: "..p.y.."Width: "..p.width.." Height: "..p.height)
        images[i] = p
    end
    
    imgNum = 1
                
    function touchListener (self, touch) 
        local phase = touch.phase
        --print("slides", phase)
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
                    selectedPic=imgNum
                elseif (dragDistance > 40 and imgNum > 1) then
                    prevImage()
                    selectedPic=imgNum
                else
                    cancelMove()
                    selectedPic=imgNum
                end

                if (selectedPic==1) then
                    print("White")
                    myData.setPicBtn:setLabel("Set as Profile Picture")
                    myData.setPicBtn.fn="change"
                elseif (selectedPic==2) then
                    print("Black")
                    if (black_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.black_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==3) then
                    print("Gray")
                    if (gray_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.gray_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==4) then
                    print("Ghost")
                    if (ghost_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.ghost_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==5) then
                    print("Pirate")
                    if (pirate_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.pirate_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==6) then
                    print("Ninja")
                    if (ninja_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.ninja_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==7) then
                    print("Anonymous")
                    if (anon_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.anon_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==8) then
                    print("Cyborg")
                    if (cyborg_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.cyborg_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==9) then
                    print("Wolf")
                    if (wolf_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.wolf_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==10) then
                    print("Tiger")
                    if (tiger_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.tiger_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                elseif (selectedPic==11) then
                    print("Santa")
                    myData.setPicBtn:setLabel("Set as Profile Picture")
                    myData.setPicBtn.fn="change"
                elseif (selectedPic==12) then
                    print("Gas Mask")
                    if (gas_mask_pic==0) then
                        myData.setPicBtn:setLabel(price)
                        myData.setPicBtn.fn="buy"
                        productName="it.elitehax.gas_mask_pic"
                    else
                        myData.setPicBtn:setLabel("Set as Profile Picture")
                        myData.setPicBtn.fn="change"
                    end
                end              
                                    
                if ( phase == "cancelled" ) then        
                    cancelMove()
                    selectedPic=imgNum
                end

                --print(selectedPic)

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

    myData.picRect.touch = touchListener
    myData.picRect:addEventListener( "touch", myData.picRect )
---------------------------------------------------------------------------------------------------------




    myData.setPicBtn = widget.newButton(
    {
        left = display.contentWidth/2,
        top = images[1].y+images[1].height/2+fontSize(40),
        width = 800,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Set as Profile Picture",
        labelColor = tableColor1,
        onEvent = setProfilePic
    })
    myData.setPicBtn.anchorX=0.5
    myData.setPicBtn.x=display.contentWidth/2
    myData.setPicBtn.fn="change"


    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",diconSize/2.5,diconSize/2.5 )
    myData.closeBtn.anchorX = 1
    myData.closeBtn.anchorY = 0
    myData.closeBtn:translate(myData.picRect.width+20, myData.picRect.y-myData.picRect.height/2+20)
    changeImgColor(myData.closeBtn)

    --  Show HUD    
    group:insert(myData.setPicBtn)
    group:insert(myData.closeBtn)

    --  Button Listeners
    myData.setPicBtn:addEventListener("tap", setProfilePic)
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function changeProfilePicScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getProfilePics.php", "POST", getPPListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
changeProfilePicScene:addEventListener( "create", changeProfilePicScene )
changeProfilePicScene:addEventListener( "show", changeProfilePicScene )
---------------------------------------------------------------------------------

return changeProfilePicScene