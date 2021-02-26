local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local upgrades = require("upgradeName")
local myDatacenterScene = composer.newScene()
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

local dcImg = { 
    ips = { img="img/dc-ips-" }
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

function goBackCrew (event)
    if (tutOverlay==false) then
        backSound()
        if (cwOverlay==true) then
            composer.hideOverlay( "fade", 100 )
            cwOverlay=false
        else
            composer.removeScene( "myDatacenterScene" )
            composer.gotoScene("crewScene", {effect = "fade", time = 100})
        end
    end
end

local function goBackCrew(event)
    if ((event.phase=="ended") and (tutOverlay==false)) then
        composer.removeScene( "myDatacenterScene" )
        backSound()
        composer.gotoScene("crewScene", {effect = "fade", time = 100})
    end
end

local function dcUpgradesListener( event )

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

        --fwExt
        myData.fwExt.lvl = t.fwext
        digit = string.len(tostring(myData.fwExt.lvl))
        myData.fwExt.txtb.width = 70+(30*digit)
        myData.fwExt.txt.text = myData.fwExt.lvl

        --IPS
        myData.ips.lvl = t.ips
        digit = string.len(tostring(myData.ips.lvl))
        myData.ips.txtb.width = 70+(30*digit)
        myData.ips.txt.text = myData.ips.lvl

        --SIEM
        myData.siem.lvl = t.siem
        digit = string.len(tostring(myData.siem.lvl))
        myData.siem.txtb.width = 70+(30*digit)
        myData.siem.txt.text = myData.siem.lvl    

        --fwInt1
        myData.fwInt1.lvl = t.fwint1
        digit = string.len(tostring(myData.fwInt1.lvl))
        myData.fwInt1.txtb.width = 70+(30*digit)
        myData.fwInt1.txt.text = myData.fwInt1.lvl

        --fwInt2
        myData.fwInt2.lvl = t.fwint2
        digit = string.len(tostring(myData.fwInt2.lvl))
        myData.fwInt2.txtb.width = 70+(30*digit)
        myData.fwInt2.txt.text = myData.fwInt2.lvl

        --mf1
        myData.mf1.lvl = t.mf1
        digit = string.len(tostring(myData.mf1.lvl))
        myData.mf1.txtb.width = 70+(30*digit)
        myData.mf1.txt.text = myData.mf1.lvl

        --mf2
        myData.mf2.lvl = t.mf2
        digit = string.len(tostring(myData.mf2.lvl))
        myData.mf2.txtb.width = 70+(30*digit)
        myData.mf2.txt.text = myData.mf2.lvl

        --relocate
        if (tonumber(t.relocation)>0) then
            myData.relocate.txt.text="Relocate!"
            myData.relocate.txtb.width = 70+(30*9)
            myData.relocate.lvl = 100
        else
            myData.relocate.lvl = t.relocate.."/100"
            digit = string.len(tostring(myData.relocate.lvl))
            myData.relocate.txtb.width = 70+(30*digit)
            myData.relocate.txt.text = myData.relocate.lvl
        end

        --My Region
        digit = string.len(tostring(regionNames[t.my_region]))
        myData.relocate.txtmrb.width = 70+(14*digit)
        myData.relocate.txtmr.text = regionNames[t.my_region]

        if (t.mf_prod==1) then
            myData.mf1_testprod.txtb.alpha=0
            myData.mf1_testprod.txt.alpha=0
            myData.mf2_testprod.txtb.alpha=1
            myData.mf2_testprod.txt.alpha=1
            if (t.mf2_testprod==49) then
                myData.mf2_testprod.txt.text="Prod"
            else
                myData.mf2_testprod.lvl=t.mf2_testprod
                digit = string.len(tostring(myData.mf2_testprod.lvl))+3
                myData.mf2_testprod.txtb.width = 62+(20*digit)
                myData.mf2_testprod.txt.text=myData.mf2_testprod.lvl.."/50"
            end            
            local imageA = { type="image", filename="img/dc-prod.png" }
            myData.mf1_testprod.fill=imageA
            local imageA = { type="image", filename="img/dc-test.png" }
            myData.mf2_testprod.fill=imageA
            myData.mf1_testprod.active=false
            myData.mf2_testprod.active=true
        elseif (t.mf_prod==2) then
            myData.mf1_testprod.txtb.alpha=1
            myData.mf1_testprod.txt.alpha=1
            myData.mf2_testprod.txtb.alpha=0
            myData.mf2_testprod.txt.alpha=0
            if (t.mf1_testprod==49) then
                myData.mf1_testprod.txt.text="Prod"
            else
                myData.mf1_testprod.lvl=t.mf1_testprod
                digit = string.len(tostring(myData.mf1_testprod.lvl))+3
                myData.mf1_testprod.txtb.width = 62+(20*digit)
                myData.mf1_testprod.txt.text=myData.mf1_testprod.lvl.."/50"
            end
            local imageA = { type="image", filename="img/dc-test.png" }
            myData.mf1_testprod.fill=imageA
            local imageA = { type="image", filename="img/dc-prod.png" }
            myData.mf2_testprod.fill=imageA
            myData.mf1_testprod.active=true
            myData.mf2_testprod.active=false
        end

        --Anon
        myData.anon.lvl = t.anon
        digit = string.len(tostring(myData.anon.lvl))
        myData.anon.txtb.width = 70+(30*digit)
        myData.anon.txt.text = myData.anon.lvl

        --scanner
        myData.scanner.lvl = t.scanner
        digit = string.len(tostring(myData.scanner.lvl))
        myData.scanner.txtb.width = 70+(30*digit)
        myData.scanner.txt.text = myData.scanner.lvl

        --exploit
        myData.exploit.lvl = t.exploit
        digit = string.len(tostring(myData.exploit.lvl))
        myData.exploit.txtb.width = 70+(30*digit)
        myData.exploit.txt.text = myData.exploit.lvl

        --cpoints
        myData.cpoints.lvl = t.cpoints
        myData.cpoints.txt.text = myData.cpoints.lvl.."/50"

        --mpoints
        myData.mpoints.lvl = t.mpoints
        myData.mpoints.txt.text = myData.mpoints.lvl.."/2"

        --Money
        myData.moneyTextCW.text = format_thousand(t.money)
        --Player
        if (string.len(t.user)>15) then myData.playerTextCW.size = fontSize(42) end
        myData.playerTextCW.text = t.user

    end
end

local function refreshDcUpgrades(event)
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token)
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getDcUpgrades.php", "POST", dcUpgradesListener, params )
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

local function doDcUpgradeListener(event)
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

        if (t.status == "NA") then
            --local alert = native.showAlert( "EliteHax", "You are not authorized to upgrade the datacenter!", { "Close" } )
            crewWarsAlert("You are not authorized to upgrade the datacenter!")
        elseif (t.status == "MAX") then
            --local alert = native.showAlert( "EliteHax", "You have already used all your hourly points!", { "Close" } )
            crewWarsAlert("You have already used all your hourly points!")
        elseif (t.status == "CMAX") then
            --local alert = native.showAlert( "EliteHax", "Your crew has already used all the daily points!", { "Close" } )
            crewWarsAlert("Your crew has already used all the daily points!")
        elseif (t.status == "REFRESH") then
            --local alert = native.showAlert( "EliteHax", "Your need to refresh the page!", { "Close" } )
            crewWarsAlert("Your need to refresh the page!")
        elseif (t.status == "OK") then
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token)
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."getDcUpgrades.php", "POST", dcUpgradesListener, params )
        end
        upgradeRx=true
    end
end

local function dcUpgradeTap(event)
    if ((event.target.name=="relocate") and (myData.relocate.lvl==100)) then    
        tapSound()    
        composer.removeScene( "myDatacenterScene" )
        composer.gotoScene("dcLocationScene", {effect = "fade", time = 100})
    elseif ((event.target.name=="mf1_testprod") and (myData.mf1_testprod.active==false)) then
        --
    elseif ((event.target.name=="mf2_testprod") and (myData.mf2_testprod.active==false)) then
        --
    elseif (upgradeRx==true) then
        upgradeRx=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type="..event.target.name
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."doDcUpgrade.php", "POST", doDcUpgradeListener, params )
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function myDatacenterScene:create(event)
    group = self.view
    mgroup = display.newGroup()
    dotGroup = display.newGroup()

    loginInfo = localToken()
    cwOverlay=false
    upgradeRx=true

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
    myData.regionName = display.newText("My Datacenter",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.regionName.anchorX = 0.5
    myData.regionName.anchorY = 0.5
    myData.regionName:translate(display.contentWidth-fontSize(155)-topPadding()/8,-display.actualContentHeight/4-topPadding()/2)
    myData.regionName:setFillColor( 0.9,0.9,0.9 )
    myData.regionName.rotation=90

    myData.fwExt = display.newImageRect( "img/dc-fwext-g.png",fontSize(300), fontSize(300))
    myData.fwExt.anchorX = 0.5
    myData.fwExt.anchorY = 0.5
    myData.fwExt:translate(myData.top_background.x+fontSize(230),display.actualContentHeight/2+topPadding())
    myData.fwExt.rotation=90
    myData.fwExt.name="fwext"
    myData.fwExt.lvl=0
    digit = string.len(tostring(myData.fwExt.lvl))
    myData.fwExt.txtb = display.newRoundedRect(myData.fwExt.x+fontSize(20),myData.fwExt.y,70+(30*digit),70,12)
    myData.fwExt.txtb.strokeWidth = 5
    myData.fwExt.txtb:setFillColor( 0,0,0 )
    myData.fwExt.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.fwExt.txtb.anchorY=0.5
    myData.fwExt.txt = display.newText(myData.fwExt.lvl,myData.fwExt.x+fontSize(20),myData.fwExt.y,native.systemFont, fontSize(68))
    myData.fwExt.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fwExt.txt.anchorY=0.5
    myData.fwExt.txtb.rotation=90
    myData.fwExt.txt.rotation=90

    myData.ips = display.newImageRect( "img/dc-ips-g.png",fontSize(280), fontSize(280))
    myData.ips.anchorX = 0.5
    myData.ips.anchorY = 0.5
    myData.ips:translate(myData.fwExt.x-myData.fwExt.height+fontSize(40),display.actualContentHeight/2+topPadding())
    myData.ips.rotation=90
    myData.ips.name="ips"    
    myData.ips.lvl=0
    digit = string.len(tostring(myData.ips.lvl))
    myData.ips.txtb = display.newRoundedRect(myData.ips.x-fontSize(70),myData.ips.y,70+(30*digit),70,12)
    myData.ips.txtb.strokeWidth = 5
    myData.ips.txtb:setFillColor( 0,0,0 )
    myData.ips.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.ips.txtb.anchorY=0.5
    myData.ips.txt = display.newText(myData.ips.lvl,myData.ips.x-fontSize(70),myData.ips.y ,native.systemFont, fontSize(68))
    myData.ips.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.ips.txt.anchorY=0.5
    myData.ips.txtb.rotation=90
    myData.ips.txt.rotation=90

    myData.siem = display.newImageRect( "img/dc-siem-g.png",fontSize(300), fontSize(300))
    myData.siem.anchorX = 0.5
    myData.siem.anchorY = 0.5
    myData.siem:translate(myData.ips.x-myData.ips.height+fontSize(15),display.actualContentHeight/2+topPadding())
    myData.siem.rotation=90
    myData.siem.name="siem"    
    myData.siem.lvl=0
    digit = string.len(tostring(myData.siem.lvl))
    myData.siem.txtb = display.newRoundedRect(myData.siem.x-fontSize(90),myData.siem.y,70+(30*digit),70,12)
    myData.siem.txtb.strokeWidth = 5
    myData.siem.txtb:setFillColor( 0,0,0 )
    myData.siem.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.siem.txtb.anchorY=0.5
    myData.siem.txt = display.newText(myData.siem.lvl,myData.siem.x-fontSize(90),myData.siem.y ,native.systemFont, fontSize(68))
    myData.siem.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.siem.txt.anchorY=0.5
    myData.siem.txtb.rotation=90
    myData.siem.txt.rotation=90

    myData.fwInt1 = display.newImageRect( "img/dc-fwint1-g.png",fontSize(320), fontSize(320))
    myData.fwInt1.anchorX = 0.5
    myData.fwInt1.anchorY = 0.5
    myData.fwInt1:translate(myData.ips.x,display.actualContentHeight/2-myData.ips.height+topPadding())
    myData.fwInt1.rotation=90
    myData.fwInt1.name="fwint1"
    myData.fwInt1.lvl=0
    digit = string.len(tostring(myData.fwInt1.lvl))
    myData.fwInt1.txtb = display.newRoundedRect(myData.fwInt1.x,myData.fwInt1.y-fontSize(22),70+(30*digit),70,12)
    myData.fwInt1.txtb.strokeWidth = 5
    myData.fwInt1.txtb:setFillColor( 0,0,0 )
    myData.fwInt1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.fwInt1.txtb.anchorY=0.5
    myData.fwInt1.txt = display.newText(myData.fwInt1.lvl,myData.fwInt1.x,myData.fwInt1.y-fontSize(22),native.systemFont, fontSize(68))
    myData.fwInt1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fwInt1.txt.anchorY=0.5
    myData.fwInt1.txtb.rotation=90
    myData.fwInt1.txt.rotation=90

    myData.fwInt2 = display.newImageRect( "img/dc-fwint2-g.png",fontSize(320), fontSize(320))
    myData.fwInt2.anchorX = 0.5
    myData.fwInt2.anchorY = 0.5
    myData.fwInt2:translate(myData.ips.x,display.actualContentHeight/2+myData.ips.height+topPadding())
    myData.fwInt2.rotation=90
    myData.fwInt2.name="fwint2"
    myData.fwInt2.lvl=0
    digit = string.len(tostring(myData.fwInt2.lvl))
    myData.fwInt2.txtb = display.newRoundedRect(myData.fwInt2.x,myData.fwInt2.y+fontSize(28),70+(30*digit),70,12)
    myData.fwInt2.txtb.strokeWidth = 5
    myData.fwInt2.txtb:setFillColor( 0,0,0 )
    myData.fwInt2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.fwInt2.txtb.anchorY=0.5
    myData.fwInt2.txt = display.newText(myData.fwInt2.lvl,myData.fwInt2.x,myData.fwInt2.y+fontSize(28),native.systemFont, fontSize(68))
    myData.fwInt2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.fwInt2.txt.anchorY=0.5
    myData.fwInt2.txtb.rotation=90
    myData.fwInt2.txt.rotation=90

    myData.mf1 = display.newImageRect( "img/dc-mf1-g.png",fontSize(300), fontSize(300))
    myData.mf1.anchorX = 0.5
    myData.mf1.anchorY = 0.5
    myData.mf1:translate(myData.ips.x,myData.fwInt1.y-myData.fwInt1.height+fontSize(25))
    myData.mf1.rotation=90
    myData.mf1.name="mf1"
    myData.mf1.lvl=0
    digit = string.len(tostring(myData.mf1.lvl))
    myData.mf1.txtb = display.newRoundedRect(myData.mf1.x,myData.mf1.y-fontSize(40),70+(30*digit),70,12)
    myData.mf1.txtb.strokeWidth = 5
    myData.mf1.txtb:setFillColor( 0,0,0 )
    myData.mf1.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.mf1.txtb.anchorY=0.5
    myData.mf1.txt = display.newText(myData.mf1.lvl,myData.mf1.x,myData.mf1.y-fontSize(40),native.systemFont, fontSize(68))
    myData.mf1.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.mf1.txt.anchorY=0.5
    myData.mf1.txtb.rotation=90
    myData.mf1.txt.rotation=90

    myData.mf1_testprod = display.newImageRect( "img/dc-prod.png",fontSize(150), fontSize(300))
    myData.mf1_testprod.anchorX = 0.5
    myData.mf1_testprod.anchorY = 0.5
    myData.mf1_testprod:translate(myData.ips.x,myData.mf1.y-myData.mf1.height+fontSize(55))
    myData.mf1_testprod.rotation=90
    myData.mf1_testprod.name="mf1_testprod"
    myData.mf1_testprod.lvl=0
    myData.mf1_testprod.active=false
    digit = string.len(tostring(myData.mf1_testprod.lvl))+3
    myData.mf1_testprod.txtb = display.newRoundedRect(myData.mf1_testprod.x-myData.mf1_testprod.width/2-fontSize(20),myData.mf1_testprod.y,62+(20*digit),70,12)
    myData.mf1_testprod.txtb.strokeWidth = 5
    myData.mf1_testprod.txtb:setFillColor( 0,0,0 )
    myData.mf1_testprod.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.mf1_testprod.txtb.anchorY=0.5
    myData.mf1_testprod.txtb.alpha=0
    myData.mf1_testprod.txt = display.newText(myData.mf1_testprod.lvl.."/50",myData.mf1_testprod.x-myData.mf1_testprod.width/2-fontSize(20),myData.mf1_testprod.y,native.systemFont, fontSize(60))
    myData.mf1_testprod.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.mf1_testprod.txt.anchorY=0.5
    myData.mf1_testprod.txt.alpha=0
    myData.mf1_testprod.txtb.rotation=90
    myData.mf1_testprod.txt.rotation=90

    myData.mf2 = display.newImageRect( "img/dc-mf2-g.png",fontSize(300), fontSize(300))
    myData.mf2.anchorX = 0.5
    myData.mf2.anchorY = 0.5
    myData.mf2:translate(myData.ips.x,myData.fwInt2.y+myData.fwInt2.height-fontSize(25))
    myData.mf2.rotation=90
    myData.mf2.name="mf2"
    myData.mf2.lvl=0
    digit = string.len(tostring(myData.mf2.lvl))
    myData.mf2.txtb = display.newRoundedRect(myData.mf2.x,myData.mf2.y+fontSize(40),70+(30*digit),70,12)
    myData.mf2.txtb.strokeWidth = 5
    myData.mf2.txtb:setFillColor( 0,0,0 )
    myData.mf2.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.mf2.txtb.anchorY=0.5
    myData.mf2.txt = display.newText(myData.mf2.lvl,myData.mf2.x,myData.mf2.y+fontSize(40),native.systemFont, fontSize(68))
    myData.mf2.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.mf2.txt.anchorY=0.5
    myData.mf2.txtb.rotation=90
    myData.mf2.txt.rotation=90

    myData.mf2_testprod = display.newImageRect( "img/dc-test.png",fontSize(150), fontSize(300))
    myData.mf2_testprod.anchorX = 0.5
    myData.mf2_testprod.anchorY = 0.5
    myData.mf2_testprod:translate(myData.ips.x,myData.mf2.y+myData.mf2.height-fontSize(55))
    myData.mf2_testprod.rotation=90
    myData.mf2_testprod.name="mf2_testprod"
    myData.mf2_testprod.lvl=0
    myData.mf2_testprod.active=false
    digit = string.len(tostring(myData.mf2_testprod.lvl))+3
    myData.mf2_testprod.txtb = display.newRoundedRect(myData.mf2_testprod.x-myData.mf2_testprod.width/2-fontSize(20),myData.mf2_testprod.y,62+(20*digit),70,12)
    myData.mf2_testprod.txtb.strokeWidth = 5
    myData.mf2_testprod.txtb:setFillColor( 0,0,0 )
    myData.mf2_testprod.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.mf2_testprod.txtb.anchorY=0.5
    myData.mf2_testprod.txtb.alpha=0
    myData.mf2_testprod.txt = display.newText(myData.mf2_testprod.lvl.."/50",myData.mf2_testprod.x-myData.mf2_testprod.width/2-fontSize(20),myData.mf2_testprod.y,native.systemFont, fontSize(60))
    myData.mf2_testprod.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.mf2_testprod.txt.anchorY=0.5
    myData.mf2_testprod.txt.alpha=0
    myData.mf2_testprod.txtb.rotation=90
    myData.mf2_testprod.txt.rotation=90

    myData.scanner = display.newImageRect( "img/dc-scanner.png",fontSize(300), fontSize(300))
    myData.scanner.anchorX = 0.5
    myData.scanner.anchorY = 0.5
    myData.scanner:translate(myData.siem.x-fontSize(40),display.actualContentHeight/2+myData.scanner.height+topPadding())
    myData.scanner.rotation=90
    myData.scanner.name="scanner"
    myData.scanner.lvl=0
    digit = string.len(tostring(myData.scanner.lvl))
    myData.scanner.txtb = display.newRoundedRect(myData.scanner.x+fontSize(100)-myData.scanner.width/2,myData.scanner.y,70+(30*digit),70,12)
    myData.scanner.txtb.strokeWidth = 5
    myData.scanner.txtb:setFillColor( 0,0,0 )
    myData.scanner.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.scanner.txtb.anchorY=0.5
    myData.scanner.txt = display.newText(myData.scanner.lvl,myData.scanner.x+fontSize(100)-myData.scanner.width/2,myData.scanner.y,native.systemFont, fontSize(68))
    myData.scanner.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.scanner.txt.anchorY=0.5
    myData.scanner.txtb.rotation=90
    myData.scanner.txt.rotation=90

    myData.exploit = display.newImageRect( "img/dc-exploit.png",fontSize(300), fontSize(300))
    myData.exploit.anchorX = 0.5
    myData.exploit.anchorY = 0.5
    myData.exploit:translate(myData.siem.x-fontSize(40),display.actualContentHeight/2+myData.exploit.height*2+fontSize(20)+topPadding())
    myData.exploit.rotation=90
    myData.exploit.name="exploit"
    myData.exploit.lvl=0
    digit = string.len(tostring(myData.exploit.lvl))
    myData.exploit.txtb = display.newRoundedRect(myData.exploit.x+fontSize(100)-myData.exploit.width/2,myData.exploit.y,70+(30*digit),70,12)
    myData.exploit.txtb.strokeWidth = 5
    myData.exploit.txtb:setFillColor( 0,0,0 )
    myData.exploit.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.exploit.txtb.anchorY=0.5
    myData.exploit.txt = display.newText(myData.exploit.lvl,myData.exploit.x+fontSize(100)-myData.exploit.width/2,myData.exploit.y,native.systemFont, fontSize(68))
    myData.exploit.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.exploit.txt.anchorY=0.5
    myData.exploit.txtb.rotation=90
    myData.exploit.txt.rotation=90

    myData.relocate = display.newImageRect( "img/dc-relocate.png",fontSize(300), fontSize(300))
    myData.relocate.anchorX = 0.5
    myData.relocate.anchorY = 0.5
    myData.relocate:translate(myData.siem.x-fontSize(40),display.actualContentHeight/2-myData.relocate.height*2-fontSize(20)+topPadding())
    myData.relocate.rotation=90
    myData.relocate.name="relocate"
    myData.relocate.lvl=0
    digit = string.len("")
    myData.relocate.txtmrb = display.newRoundedRect(myData.relocate.x+fontSize(250)-myData.relocate.width/2,myData.relocate.y,70+(14*digit),70,12)
    myData.relocate.txtmrb.strokeWidth = 5
    myData.relocate.txtmrb:setFillColor( 0,0,0 )
    myData.relocate.txtmrb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.relocate.txtmrb.anchorY=0.5
    myData.relocate.txtmr = display.newText("",myData.relocate.x+fontSize(250)-myData.relocate.width/2,myData.relocate.y,native.systemFont, fontSize(34))
    myData.relocate.txtmr:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.relocate.txtmr.anchorY=0.5
    myData.relocate.txtmrb.rotation=90
    myData.relocate.txtmr.rotation=90
    digit = string.len(tostring(myData.relocate.lvl))+4
    myData.relocate.txtb = display.newRoundedRect(myData.relocate.x+fontSize(100)-myData.relocate.width/2,myData.relocate.y,70+(30*digit),70,12)
    myData.relocate.txtb.strokeWidth = 5
    myData.relocate.txtb:setFillColor( 0,0,0 )
    myData.relocate.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.relocate.txtb.anchorY=0.5
    myData.relocate.txt = display.newText(myData.relocate.lvl.."/100",myData.relocate.x+fontSize(100)-myData.relocate.width/2,myData.relocate.y,native.systemFont, fontSize(58))
    myData.relocate.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.relocate.txt.anchorY=0.5
    myData.relocate.txtb.rotation=90
    myData.relocate.txt.rotation=90

    myData.anon = display.newImageRect( "img/dc-anon.png",fontSize(300), fontSize(300))
    myData.anon.anchorX = 0.5
    myData.anon.anchorY = 0.5
    myData.anon:translate(myData.siem.x-fontSize(40),display.actualContentHeight/2-myData.anon.height+topPadding())
    myData.anon.rotation=90
    myData.anon.name="anon"
    myData.anon.lvl=0
    digit = string.len(tostring(myData.anon.lvl))
    myData.anon.txtb = display.newRoundedRect(myData.anon.x+fontSize(100)-myData.anon.width/2,myData.anon.y,70+(30*digit),70,12)
    myData.anon.txtb.strokeWidth = 5
    myData.anon.txtb:setFillColor( 0,0,0 )
    myData.anon.txtb:setStrokeColor( strokeColor1[1],strokeColor1[2],strokeColor1[3] )
    myData.anon.txtb.anchorY=0.5
    myData.anon.txt = display.newText(myData.anon.lvl,myData.anon.x+fontSize(100)-myData.anon.width/2,myData.anon.y,native.systemFont, fontSize(72))
    myData.anon.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.anon.txt.anchorY=0.5
    myData.anon.txtb.rotation=90
    myData.anon.txt.rotation=90

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
    group:insert(myData.regionName)
    group:insert(myData.fwExt)
    group:insert(myData.mf1)
    group:insert(myData.mf2)
    group:insert(myData.fwInt1)
    group:insert(myData.fwInt2)
    group:insert(myData.siem)
    group:insert(myData.ips)
    group:insert(myData.relocate)
    group:insert(myData.anon)
    group:insert(myData.scanner)
    group:insert(myData.exploit)
    group:insert(myData.cpoints)
    group:insert(myData.mpoints)
    group:insert(myData.fwExt.txtb)
    group:insert(myData.mf1.txtb)
    group:insert(myData.mf2.txtb)
    group:insert(myData.fwInt1.txtb)
    group:insert(myData.fwInt2.txtb)
    group:insert(myData.siem.txtb)
    group:insert(myData.ips.txtb)
    group:insert(myData.relocate.txtb)
    group:insert(myData.anon.txtb)
    group:insert(myData.scanner.txtb)
    group:insert(myData.exploit.txtb)
    group:insert(myData.fwExt.txt)
    group:insert(myData.mf1.txt)
    group:insert(myData.mf2.txt)
    group:insert(myData.fwInt1.txt)
    group:insert(myData.fwInt2.txt)
    group:insert(myData.siem.txt)
    group:insert(myData.ips.txt)
    group:insert(myData.relocate.txt)
    group:insert(myData.anon.txt)
    group:insert(myData.scanner.txt)
    group:insert(myData.exploit.txt)
    group:insert(myData.mf1_testprod)
    group:insert(myData.mf1_testprod.txtb)
    group:insert(myData.mf1_testprod.txt)
    group:insert(myData.mf2_testprod)
    group:insert(myData.mf2_testprod.txtb)
    group:insert(myData.mf2_testprod.txt)
    group:insert(myData.cpoints.txt)
    group:insert(myData.mpoints.txt)
    group:insert(myData.relocate.txtmrb)
    group:insert(myData.relocate.txtmr)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackCrew)
    myData.fwExt:addEventListener("tap",dcUpgradeTap)
    myData.ips:addEventListener("tap",dcUpgradeTap)
    myData.siem:addEventListener("tap",dcUpgradeTap)
    myData.fwInt1:addEventListener("tap",dcUpgradeTap)
    myData.fwInt2:addEventListener("tap",dcUpgradeTap)
    myData.mf1:addEventListener("tap",dcUpgradeTap)
    myData.mf2:addEventListener("tap",dcUpgradeTap)
    myData.relocate:addEventListener("tap",dcUpgradeTap)
    myData.anon:addEventListener("tap",dcUpgradeTap)
    myData.scanner:addEventListener("tap",dcUpgradeTap)
    myData.exploit:addEventListener("tap",dcUpgradeTap)
    myData.mf1_testprod:addEventListener("tap",dcUpgradeTap)
    myData.mf2_testprod:addEventListener("tap",dcUpgradeTap)
end

-- Home Show
function myDatacenterScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "cwUpgradeTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.cwUpgradeTutorial ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "cwUpgradeTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getDcUpgrades.php", "POST", dcUpgradesListener, params )
    end

    if event.phase == "did" then
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
myDatacenterScene:addEventListener( "create", myDatacenterScene )
myDatacenterScene:addEventListener( "show", myDatacenterScene )
---------------------------------------------------------------------------------

return myDatacenterScene