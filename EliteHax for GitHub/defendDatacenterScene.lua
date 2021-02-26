local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local upgrades = require("upgradeName")
local defendDatacenterScene = composer.newScene()
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

function goBackCrew(event)
    if (tutOverlay==false) then
        backSound()
        if (cwOverlay==true) then
            composer.hideOverlay( "fade", 100 )
            cwOverlay=false
        else
            composer.removeScene( "defendDatacenterScene" )
            composer.gotoScene("crewScene", {effect = "fade", time = 100})
        end
    end
end

local function goBackCrew(event)
    if ((event.phase=="ended") and (tutOverlay==false)) then
        composer.removeScene( "defendDatacenterScene" )
        backSound()
        composer.gotoScene("crewScene", {effect = "fade", time = 100})
    end
end

local function dcDefenseListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 3", { "Close" }, onAlert )
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
        if (string.len(t.user)>15) then myData.playerTextCW.size = fontSize(42) end
        myData.playerTextCW.text = t.user

        --cpoints
        myData.cpoints.lvl = t.cpoints
        digit = string.len(tostring(myData.cpoints.lvl))+3
        myData.cpoints.txt.text = myData.cpoints.lvl.."/50"

        --mpoints
        myData.mpoints.lvl = t.mpoints
        digit = string.len(tostring(myData.mpoints.lvl))+2
        myData.mpoints.txt.text = myData.mpoints.lvl.."/2"

        if (t.fwext_as>0) then
            myData.fwExt.active=1
            myData.fwExt.count=t.fwext_as
            local imageA = { type="image", filename="img/dc-fwext-"..myData.fwExt.count..".png" }
            myData.fwExtC.fill=imageA
        end
        if (t.ips_as>0) then
            myData.fwExt.active=0
            myData.ips.active=1
            myData.ips.count=t.ips_as
            local imageA = { type="image", filename="img/dc-ips-"..myData.ips.count..".png" }
            myData.ipsC.fill=imageA
        end
        if (t.siem_as>0) then
            myData.fwExt.active=0
            myData.ips.active=0
            myData.siem.active=1
            myData.siem.count=t.siem_as
            local imageA = { type="image", filename="img/dc-siem-"..myData.siem.count..".png" }
            myData.siemC.fill=imageA
        end
        if (t.fwint1_as>0) then
            myData.fwExt.active=0
            myData.ips.active=0
            myData.fwInt1.active=1
            myData.fwInt1.count=t.fwint1_as
            local imageA = { type="image", filename="img/dc-fwint1-"..myData.fwInt1.count..".png" }
            myData.fwInt1C.fill=imageA
        end
        if (t.fwint2_as>0) then
            myData.fwExt.active=0
            myData.ips.active=0
            myData.fwInt2.active=1
            myData.fwInt2.count=t.fwint2_as
            local imageA = { type="image", filename="img/dc-fwint2-"..myData.fwInt2.count..".png" }
            myData.fwInt2C.fill=imageA
        end
        if (t.mf1_as>0) then
            myData.fwExt.active=0
            myData.ips.active=0
            myData.fwInt1.active=0
            myData.mf1.active=1
            myData.mf1.count=t.mf1_as
            local imageA = { type="image", filename="img/dc-mf1-"..myData.mf1.count..".png" }
            myData.mf1C.fill=imageA
        end
        if (t.mf2_as>0) then
            myData.fwExt.active=0
            myData.ips.active=0
            myData.fwInt2.active=0
            myData.mf2.active=1
            myData.mf2.count=t.mf2_as
            local imageA = { type="image", filename="img/dc-mf2-"..myData.mf2.count..".png" }
            myData.mf2C.fill=imageA
        end

        if (t.mf_prod==1) then
            myData.mf1_testprod.alpha=1
        elseif (t.mf_prod==2) then
            myData.mf2_testprod.alpha=1
        end

    end
end

local function mf2Attack(event)
    if (myData.mf2C.count<=3) then
        local imageA = { type="image", filename="img/dc-mf2-"..myData.mf2C.count..".png" }
        myData.mf2C.fill=imageA
    end
end

local function mf1Attack(event)
    if (myData.mf1C.count<=3) then
        local imageA = { type="image", filename="img/dc-mf1-"..myData.mf1C.count..".png" }
        myData.mf1C.fill=imageA
    end
end

local function fwInt2Attack(event)
    if (myData.fwInt2C.count<=3) then
        local imageA = { type="image", filename="img/dc-fwint2-"..myData.fwInt2C.count..".png" }
        myData.fwInt2C.fill=imageA
    end
end

local function fwInt1Attack(event)
    if (myData.fwInt1C.count<=3) then
        local imageA = { type="image", filename="img/dc-fwint1-"..myData.fwInt1C.count..".png" }
        myData.fwInt1C.fill=imageA
    end
end

local function siemAttack(event)
    if (myData.siemC.count<=3) then
        local imageA = { type="image", filename="img/dc-siem-"..myData.siemC.count..".png" }
        myData.siemC.fill=imageA
    end
end

local function ipsAttack(event)
    if (myData.ipsC.count<=3) then
        local imageA = { type="image", filename="img/dc-ips-"..myData.ipsC.count..".png" }
        myData.ipsC.fill=imageA
    end
end

local function fwExtAttack(event)
    if (myData.fwExtC.count<=3) then  
        local imageA = { type="image", filename="img/dc-fwext-"..myData.fwExtC.count..".png" }
        myData.fwExtC.fill=imageA
    end
end

local function updateDefenseCount(type)
    if (myData[type].count<=3) then
        local typeC=type.."C"
        local imageA = { type="image", filename="img/dc-"..type.."-"..myData[type].count..".png" }
        myData[typeC].fill=imageA
    end
end

local function crewWarsAlert(alert)
    if (cwOverlay==false) then
        local sceneOverlayOptions = 
        {
            time = 0,
            effect = "crossFade",
            params = { 
                text=alert,
            },
            isModal = true
        }
        cwOverlay=true
        composer.showOverlay( "crewWarsAlertScene", sceneOverlayOptions) 
    end
end

local function dcDefendListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 3", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
    
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred... Err: 4", { "Close" }, onAlert )
        end

        if (t.status == "MAX") then
            --local alert = native.showAlert( "EliteHax", "You have already used all your hourly points!", { "Close" } )
            crewWarsAlert("You have already used all your hourly points!")
        elseif (t.status == "CMAX") then
            --local alert = native.showAlert( "EliteHax", "Your crew has already used all the daily points!", { "Close" } )
            crewWarsAlert("Your crew has already used all the daily points!")
        elseif (t.status == "REFRESH") then
            --local alert = native.showAlert( "EliteHax", "Your need to refresh the page!", { "Close" } )
            crewWarsAlert("Your need to refresh the page!")
        else
            --cpoints
            myData.cpoints.lvl = t.cpoints
            digit = string.len(tostring(myData.cpoints.lvl))+3
            myData.cpoints.txt.text = myData.cpoints.lvl.."/50"

            --mpoints
            myData.mpoints.lvl = t.mpoints
            digit = string.len(tostring(myData.mpoints.lvl))+2
            myData.mpoints.txt.text = myData.mpoints.lvl.."/2" 

            if (defenseType=='fwext') then
                myData.fwExt.count=t.current_as
                myData.fwExt.clicked=0
                updateDefenseCount('fwExt')
            elseif (defenseType=='ips') then
                myData.ips.count=t.current_as
                myData.ips.clicked=0
                updateDefenseCount('ips')
            elseif (defenseType=='siem') then
                myData.siem.count=t.current_as
                myData.siem.clicked=0
                updateDefenseCount('siem')
            elseif (defenseType=='fwint1') then
                myData.fwInt1.count=t.current_as
                myData.fwInt1.clicked=0
                updateDefenseCount('fwInt1')
            elseif (defenseType=='fwint2') then
                myData.fwInt2.count=t.current_as
                myData.fwInt2.clicked=0
                updateDefenseCount('fwInt2')
            elseif (defenseType=='mf1') then
                myData.mf1.count=t.current_as
                myData.mf1.clicked=0
                updateDefenseCount('mf1')
            elseif (defenseType=='mf2') then
                myData.mf2.count=t.current_as
                myData.mf2.clicked=0
                updateDefenseCount('mf2')
            end

            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getDcDefense.php", "POST", dcDefenseListener, params )

        end
        defenseReceived=1
    end
end

local function dcTap(event)
    if ((defenseReceived==1) and (event.target.count>0) and (event.target.active==1)) then
        defenseReceived=0
        defenseType=event.target.name
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type="..event.target.name
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."defendDc.php", "POST", dcDefendListener, params )
    end
end
---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function defendDatacenterScene:create(event)
    group = self.view
    mgroup = display.newGroup()
    dotGroup = display.newGroup()

    loginInfo = localToken()

    iconSize=200
    defenseReceived=1
    defenseType='fwext'
    cwOverlay=false

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
    myData.dcName = display.newText("My Datacenter",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.dcName.anchorX = 0.5
    myData.dcName.anchorY = 0.5
    myData.dcName:translate(display.contentWidth-fontSize(155)-topPadding()/8,-display.actualContentHeight/4-topPadding()/2)
    myData.dcName:setFillColor( 0.9,0.9,0.9 )
    myData.dcName.rotation=90

    myData.fwExt = display.newImageRect( "img/dc-fwext-g.png",fontSize(300), fontSize(300))
    myData.fwExt.anchorX = 0.5
    myData.fwExt.anchorY = 0.5
    myData.fwExt:translate(myData.top_background.x+fontSize(230),display.actualContentHeight/2+topPadding())
    myData.fwExt.rotation=90
    myData.fwExt.name="fwext"
    myData.fwExt.count=0
    myData.fwExt.clicked=0
    myData.fwExt.active=0

    myData.fwExtC = display.newImageRect( "img/dc-fwext-0.png",fontSize(300), fontSize(300))
    myData.fwExtC.anchorX = 0.5
    myData.fwExtC.anchorY = 0.5
    myData.fwExtC:translate(myData.top_background.x+fontSize(230),display.actualContentHeight/2+topPadding())
    myData.fwExtC.rotation=90
    myData.fwExtC.count=0

    myData.ips = display.newImageRect( "img/dc-ips-g.png",fontSize(280), fontSize(280))
    myData.ips.anchorX = 0.5
    myData.ips.anchorY = 0.5
    myData.ips:translate(myData.fwExt.x-myData.fwExt.height+fontSize(40),display.actualContentHeight/2+topPadding())
    myData.ips.rotation=90
    myData.ips.name="ips"
    myData.ips.count=0    
    myData.ips.clicked=0
    myData.ips.active=0

    myData.ipsC = display.newImageRect( "img/dc-ips-0.png",fontSize(280), fontSize(280))
    myData.ipsC.anchorX = 0.5
    myData.ipsC.anchorY = 0.5
    myData.ipsC:translate(myData.fwExt.x-myData.fwExt.height+fontSize(40),display.actualContentHeight/2+topPadding())
    myData.ipsC.rotation=90
    myData.ipsC.count=0

    myData.siem = display.newImageRect( "img/dc-siem-g.png",fontSize(300), fontSize(300))
    myData.siem.anchorX = 0.5
    myData.siem.anchorY = 0.5
    myData.siem:translate(myData.ips.x-myData.ips.height+fontSize(15),display.actualContentHeight/2+topPadding())
    myData.siem.rotation=90
    myData.siem.name="siem"
    myData.siem.count=0
    myData.siem.clicked=0
    myData.siem.active=0

    myData.siemC = display.newImageRect( "img/dc-siem-0.png",fontSize(300), fontSize(300))
    myData.siemC.anchorX = 0.5
    myData.siemC.anchorY = 0.5
    myData.siemC:translate(myData.ips.x-myData.ips.height+fontSize(15),display.actualContentHeight/2+topPadding())
    myData.siemC.rotation=90
    myData.siemC.count=0

    myData.fwInt1 = display.newImageRect( "img/dc-fwint1-g.png",fontSize(320), fontSize(320))
    myData.fwInt1.anchorX = 0.5
    myData.fwInt1.anchorY = 0.5
    myData.fwInt1:translate(myData.ips.x,display.actualContentHeight/2-myData.ips.height+topPadding())
    myData.fwInt1.rotation=90
    myData.fwInt1.name="fwint1"
    myData.fwInt1.count=0
    myData.fwInt1.clicked=0
    myData.fwInt1.active=0

    myData.fwInt1C = display.newImageRect( "img/dc-fwint1-0.png",fontSize(320), fontSize(320))
    myData.fwInt1C.anchorX = 0.5
    myData.fwInt1C.anchorY = 0.5
    myData.fwInt1C:translate(myData.ips.x,display.actualContentHeight/2-myData.ips.height+topPadding())
    myData.fwInt1C.rotation=90
    myData.fwInt1C.count=0

    myData.fwInt2 = display.newImageRect( "img/dc-fwint2-g.png",fontSize(320), fontSize(320))
    myData.fwInt2.anchorX = 0.5
    myData.fwInt2.anchorY = 0.5
    myData.fwInt2:translate(myData.ips.x,display.actualContentHeight/2+myData.ips.height+topPadding())
    myData.fwInt2.rotation=90
    myData.fwInt2.name="fwint2"
    myData.fwInt2.count=0
    myData.fwInt2.clicked=0
    myData.fwInt2.active=0

    myData.fwInt2C = display.newImageRect( "img/dc-fwint2-0.png",fontSize(320), fontSize(320))
    myData.fwInt2C.anchorX = 0.5
    myData.fwInt2C.anchorY = 0.5
    myData.fwInt2C:translate(myData.ips.x,display.actualContentHeight/2+myData.ips.height+topPadding())
    myData.fwInt2C.rotation=90
    myData.fwInt2C.count=0

    myData.mf1 = display.newImageRect( "img/dc-mf1-g.png",fontSize(300), fontSize(300))
    myData.mf1.anchorX = 0.5
    myData.mf1.anchorY = 0.5
    myData.mf1:translate(myData.ips.x,myData.fwInt1.y-myData.fwInt1.height+fontSize(25))
    myData.mf1.rotation=90
    myData.mf1.name="mf1"
    myData.mf1.count=0
    myData.mf1.clicked=0
    myData.mf1.active=0

    myData.mf1C = display.newImageRect( "img/dc-mf1-0.png",fontSize(300), fontSize(300))
    myData.mf1C.anchorX = 0.5
    myData.mf1C.anchorY = 0.5
    myData.mf1C:translate(myData.ips.x,myData.fwInt1.y-myData.fwInt1.height+fontSize(25))
    myData.mf1C.rotation=90
    myData.mf1C.count=0

    myData.mf1_testprod = display.newImageRect( "img/dc-prod.png",fontSize(150), fontSize(300))
    myData.mf1_testprod.anchorX = 0.5
    myData.mf1_testprod.anchorY = 0.5
    myData.mf1_testprod:translate(myData.ips.x,myData.mf1.y-myData.mf1.height+fontSize(55))
    myData.mf1_testprod.rotation=90
    myData.mf1_testprod.name="mf1_testprod"
    myData.mf1_testprod.alpha=0

    myData.mf2 = display.newImageRect( "img/dc-mf2-g.png",fontSize(300), fontSize(300))
    myData.mf2.anchorX = 0.5
    myData.mf2.anchorY = 0.5
    myData.mf2:translate(myData.ips.x,myData.fwInt2.y+myData.fwInt2.height-fontSize(25))
    myData.mf2.rotation=90
    myData.mf2.name="mf2"
    myData.mf2.count=0
    myData.mf2.clicked=0
    myData.mf2.active=0

    myData.mf2C = display.newImageRect( "img/dc-mf2-0.png",fontSize(300), fontSize(300))
    myData.mf2C.anchorX = 0.5
    myData.mf2C.anchorY = 0.5
    myData.mf2C:translate(myData.ips.x,myData.fwInt2.y+myData.fwInt2.height-fontSize(25))
    myData.mf2C.rotation=90
    myData.mf2C.count=0

    myData.mf2_testprod = display.newImageRect( "img/dc-prod.png",fontSize(150), fontSize(300))
    myData.mf2_testprod.anchorX = 0.5
    myData.mf2_testprod.anchorY = 0.5
    myData.mf2_testprod:translate(myData.ips.x,myData.mf2.y+myData.mf2.height-fontSize(55))
    myData.mf2_testprod.rotation=90
    myData.mf2_testprod.name="mf2_testprod"
    myData.mf2_testprod.alpha=0

    myData.cpoints = display.newImageRect( "img/dc-crewpoints.png",fontSize(550), fontSize(200))
    myData.cpoints.anchorX = 0.5
    myData.cpoints.anchorY = 0.5
    myData.cpoints:translate(myData.fwExt.x+fontSize(40),display.actualContentHeight/2-myData.cpoints.height*2.4+topPadding())
    changeImgColor(myData.cpoints)
    myData.cpoints.rotation=90
    myData.cpoints.name="cpoints"
    myData.cpoints.lvl=0
    digit = string.len(tostring(myData.cpoints.lvl))+3
    myData.cpoints.txt = display.newText(myData.cpoints.lvl.."/50",myData.cpoints.x-fontSize(25),myData.cpoints.y,native.systemFont, fontSize(72))
    myData.cpoints.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.cpoints.txt.anchorY=0.5
    myData.cpoints.txt.rotation=90

    myData.mpoints = display.newImageRect( "img/dc-mypoints.png",fontSize(550), fontSize(200))
    myData.mpoints.anchorX = 0.5
    myData.mpoints.anchorY = 0.5
    myData.mpoints:translate(myData.fwExt.x+fontSize(40),display.actualContentHeight/2+myData.mpoints.height*2.4+topPadding())
    changeImgColor(myData.mpoints)
    myData.mpoints.rotation=90
    myData.mpoints.name="mpoints"
    myData.mpoints.lvl=0
    digit = string.len(tostring(myData.mpoints.lvl))+2
    myData.mpoints.txt = display.newText(myData.mpoints.lvl.."/2",myData.mpoints.x-fontSize(25),myData.mpoints.y,native.systemFont, fontSize(72))
    myData.mpoints.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.mpoints.txt.anchorY=0.5
    myData.mpoints.txt.rotation=90

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
        onEvent = goBackCrew
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
    group:insert(myData.dcName)
    group:insert(myData.fwExt)
    group:insert(myData.mf1)
    group:insert(myData.mf2)
    group:insert(myData.fwInt1)
    group:insert(myData.fwInt2)
    group:insert(myData.siem)
    group:insert(myData.ips)
    group:insert(myData.cpoints)
    group:insert(myData.cpoints.txt)
    group:insert(myData.mpoints)
    group:insert(myData.mpoints.txt)
    group:insert(myData.fwExtC)
    group:insert(myData.mf1C)
    group:insert(myData.mf2C)
    group:insert(myData.fwInt1C)
    group:insert(myData.fwInt2C)
    group:insert(myData.siemC)
    group:insert(myData.ipsC)
    group:insert(myData.mf1_testprod)
    group:insert(myData.mf2_testprod)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackCrew)
    myData.fwExt:addEventListener("tap",dcTap)
    myData.ips:addEventListener("tap",dcTap)
    myData.siem:addEventListener("tap",dcTap)
    myData.fwInt1:addEventListener("tap",dcTap)
    myData.fwInt2:addEventListener("tap",dcTap)
    myData.mf1:addEventListener("tap",dcTap)
    myData.mf2:addEventListener("tap",dcTap)
end

-- Home Show
function defendDatacenterScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "cwDefendTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.cwDefendTutorial ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "cwDefendTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getDcDefense.php", "POST", dcDefenseListener, params )
    end

    if event.phase == "did" then
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
defendDatacenterScene:addEventListener( "create", defendDatacenterScene )
defendDatacenterScene:addEventListener( "show", defendDatacenterScene )
---------------------------------------------------------------------------------

return defendDatacenterScene