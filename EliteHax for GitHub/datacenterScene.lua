local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local upgrades = require("upgradeName")
local datacenterScene = composer.newScene()
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

function goBackRegion(event)
    if (tutOverlay==false) then
        backSound()
        if (cwOverlay==true) then
            composer.hideOverlay( "fade", 100 )
            cwOverlay=false
        else
            composer.removeScene( "datacenterScene" )
            composer.gotoScene("regionScene", {effect = "fade", time = 100})
        end
    end
end

local function goBackRegion(event)
    if ((event.phase=="ended") and (tutOverlay==false)) then
        composer.removeScene( "datacenterScene" )
        backSound()
        composer.gotoScene("regionScene", {effect = "fade", time = 100})
    end
end

local function dcDetailsListener( event )
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

        --Datacenter Name
        myData.dcName.text=t.crew_name

        --cpoints
        myData.cpoints.lvl = t.cpoints
        digit = string.len(tostring(myData.cpoints.lvl))+3
        myData.cpoints.txt.text = myData.cpoints.lvl.."/50"

        --mpoints
        myData.mpoints.lvl = t.mpoints
        digit = string.len(tostring(myData.mpoints.lvl))+2
        myData.mpoints.txt.text = myData.mpoints.lvl.."/2"

        --fwExt
        myData.fwExt.lvl = t.fwext
        digit = string.len(tostring(myData.fwExt.lvl))
        myData.fwExt.txtb.width = 70+(30*digit)
        myData.fwExt.txt.text = myData.fwExt.lvl
        myData.fwExt.anon=t.fwext_anon_c
        myData.fwExt.attack=t.fwext_attack_c

        --ips
        myData.ips.lvl = t.ips
        digit = string.len(tostring(myData.ips.lvl))
        myData.ips.txtb.width = 70+(30*digit)
        myData.ips.txt.text = myData.ips.lvl
        myData.ips.anon=t.ips_anon_c
        myData.ips.attack=t.ips_attack_c

        --siem
        myData.siem.lvl = t.siem
        digit = string.len(tostring(myData.siem.lvl))
        myData.siem.txtb.width = 70+(30*digit)
        myData.siem.txt.text = myData.siem.lvl
        myData.siem.anon=t.siem_anon_c
        myData.siem.attack=t.siem_attack_c

        --fwInt1
        myData.fwInt1.lvl = t.fwint1
        digit = string.len(tostring(myData.fwInt1.lvl))
        myData.fwInt1.txtb.width = 70+(30*digit)
        myData.fwInt1.txt.text = myData.fwInt1.lvl
        myData.fwInt1.anon=t.fwint1_anon_c
        myData.fwInt1.attack=t.fwint1_attack_c

        --fwInt2
        myData.fwInt2.lvl = t.fwint2
        digit = string.len(tostring(myData.fwInt2.lvl))
        myData.fwInt2.txtb.width = 70+(30*digit)
        myData.fwInt2.txt.text = myData.fwInt2.lvl
        myData.fwInt2.anon=t.fwint2_anon_c
        myData.fwInt2.attack=t.fwint2_attack_c

        --mf1
        myData.mf1.lvl = t.mf1
        digit = string.len(tostring(myData.mf1.lvl))
        myData.mf1.txtb.width = 70+(30*digit)
        myData.mf1.txt.text = myData.mf1.lvl
        myData.mf1.anon=t.mf1_anon_c
        myData.mf1.attack=t.mf1_attack_c

        --mf2
        myData.mf2.lvl = t.mf2
        digit = string.len(tostring(myData.mf2.lvl))
        myData.mf2.txtb.width = 70+(30*digit)
        myData.mf2.txt.text = myData.mf2.lvl
        myData.mf2.anon=t.mf2_anon_c
        myData.mf2.attack=t.mf2_attack_c

        if (init==0) then
            init=1
            if (t.fwext_as>0) then
                myData.fwExtC.count=t.fwext_as
                local imageA = { type="image", filename="img/dc-fwext-"..myData.fwExtC.count..".png" }
                myData.fwExtC.fill=imageA
            end
            if (t.fwext_as==3) then
                myData.fwExtC.alpha=0
                myData.fwExt.txtb.alpha=0
                myData.fwExt.txt.alpha=0  
                local imageA = { type="image", filename="img/dc-fwext-r.png" }
                myData.fwExt.fill=imageA
                local imageA = { type="image", filename="img/dc-ips-g.png" }
                myData.ips.fill=imageA
                myData.ipsC.alpha=1
                myData.ips.txtb.alpha=1
                myData.ips.txt.alpha=1
            end
            if (t.ips_as>0) then
                myData.ipsC.count=t.ips_as
                local imageA = { type="image", filename="img/dc-ips-"..myData.ipsC.count..".png" }
                myData.ipsC.fill=imageA
            end
            if (t.ips_as==3) then
                myData.ipsC.alpha=0
                myData.ips.txtb.alpha=0
                myData.ips.txt.alpha=0  
                local imageA = { type="image", filename="img/dc-ips-r.png" }
                myData.ips.fill=imageA
                local imageA = { type="image", filename="img/dc-siem-g.png" }
                myData.siem.fill=imageA
                myData.siemC.alpha=1
                myData.siem.txtb.alpha=1
                myData.siem.txt.alpha=1
                local imageA = { type="image", filename="img/dc-fwint1-g.png" }
                myData.fwInt1.fill=imageA
                myData.fwInt1C.alpha=1
                myData.fwInt1.txtb.alpha=1
                myData.fwInt1.txt.alpha=1
                local imageA = { type="image", filename="img/dc-fwint2-g.png" }
                myData.fwInt2.fill=imageA
                myData.fwInt2C.alpha=1
                myData.fwInt2.txtb.alpha=1
                myData.fwInt2.txt.alpha=1
            end
            if (t.siem_as>0) then
                myData.siemC.count=t.siem_as
                local imageA = { type="image", filename="img/dc-siem-"..myData.siemC.count..".png" }
                myData.siemC.fill=imageA
            end
            if (t.siem_as==3) then
                myData.siemC.alpha=0
                myData.siem.txtb.alpha=0
                myData.siem.txt.alpha=0  
                local imageA = { type="image", filename="img/dc-siem-r.png" }
                myData.siem.fill=imageA
            end
            if (t.fwint1_as>0) then
                myData.fwInt1C.count=t.fwint1_as
                local imageA = { type="image", filename="img/dc-fwint1-"..myData.fwInt1C.count..".png" }
                myData.fwInt1C.fill=imageA
            end
            if (t.fwint1_as==3) then
                myData.fwInt1C.alpha=0
                myData.fwInt1.txtb.alpha=0
                myData.fwInt1.txt.alpha=0  
                local imageA = { type="image", filename="img/dc-fwint1-r.png" }
                myData.fwInt1.fill=imageA
                local imageA = { type="image", filename="img/dc-mf1-g.png" }
                myData.mf1.fill=imageA
                myData.mf1C.alpha=1
                myData.mf1.txtb.alpha=1
                myData.mf1.txt.alpha=1
            end
            if (t.fwint2_as>0) then
                myData.fwInt2C.count=t.fwint2_as
                local imageA = { type="image", filename="img/dc-fwint2-"..myData.fwInt2C.count..".png" }
                myData.fwInt2C.fill=imageA
            end
            if (t.fwint2_as==3) then
                myData.fwInt2C.alpha=0
                myData.fwInt2.txtb.alpha=0
                myData.fwInt2.txt.alpha=0  
                local imageA = { type="image", filename="img/dc-fwint2-r.png" }
                myData.fwInt2.fill=imageA
                local imageA = { type="image", filename="img/dc-mf2-g.png" }
                myData.mf2.fill=imageA
                myData.mf2C.alpha=2
                myData.mf2.txtb.alpha=2
                myData.mf2.txt.alpha=2
            end
            if (t.mf1_as>0) then
                myData.mf1C.count=t.mf1_as
                local imageA = { type="image", filename="img/dc-mf1-"..myData.mf1C.count..".png" }
                myData.mf1C.fill=imageA
            end
            if (t.mf1_as==3) then
                myData.mf1C.alpha=0
                myData.mf1.txtb.alpha=0
                myData.mf1.txt.alpha=0  
                local imageA = { type="image", filename="img/dc-mf1-r.png" }
                myData.mf1.fill=imageA
            end
            if (t.mf2_as>0) then
                myData.mf2C.count=t.mf2_as
                local imageA = { type="image", filename="img/dc-mf2-"..myData.mf2C.count..".png" }
                myData.mf2C.fill=imageA
            end
            if (t.mf2_as==3) then
                myData.mf2C.alpha=0
                myData.mf2.txtb.alpha=0
                myData.mf2.txt.alpha=0  
                local imageA = { type="image", filename="img/dc-mf2-r.png" }
                myData.mf2.fill=imageA
            end
        end

    end
end

local function fadeMf2Red( event )
    if (event.count<10) then  
        mf22.fill.effect.progress=mf22.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-mf2-r.png" }
        myData.mf2.fill=imageA
        mf22:removeSelf()
        mf22=nil
    end
end

local function mf2Complete(event)
    myData.mf2C.alpha=0
    myData.mf2.txtb.alpha=0
    myData.mf2.txt.alpha=0
    mf22 = display.newImageRect( "img/dc-mf2-r.png",fontSize(300), fontSize(300))
    mf22.anchorX = 0.5
    mf22.anchorY = 0.5
    mf22:translate(myData.ips.x,myData.fwInt2.y+myData.fwInt2.height-fontSize(25))
    mf22.rotation=90
    mf22.fill.effect = "filter.linearWipe"
    mf22.fill.effect.direction = { 1, 0 }
    mf22.fill.effect.smoothness = 1
    mf22.fill.effect.progress = 0.1
    timer.performWithDelay(100,fadeMf2Red,10)
end

local function mf2Attack(event)
    if (myData.mf2C.count<=3) then
        local imageA = { type="image", filename="img/dc-mf2-"..myData.mf2C.count..".png" }
        myData.mf2C.fill=imageA
        if (myData.mf2C.count==3) then
            mf2Complete()
        end
    end
end

local function fadeMf1Red( event )
    if (event.count<10) then  
        mf12.fill.effect.progress=mf12.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-mf1-r.png" }
        myData.mf1.fill=imageA
        mf12:removeSelf()
        mf12=nil
    end
end

local function mf1Complete(event)
    myData.mf1C.alpha=0
    myData.mf1.txtb.alpha=0
    myData.mf1.txt.alpha=0
    mf12 = display.newImageRect( "img/dc-mf1-r.png",fontSize(300), fontSize(300))
    mf12.anchorX = 0.5
    mf12.anchorY = 0.5
    mf12:translate(myData.ips.x,myData.fwInt1.y-myData.fwInt1.height+fontSize(25))
    mf12.rotation=90
    mf12.fill.effect = "filter.linearWipe"
    mf12.fill.effect.direction = { -1, 0 }
    mf12.fill.effect.smoothness = 1
    mf12.fill.effect.progress = 0.1
    timer.performWithDelay(100,fadeMf1Red,10)
end

local function mf1Attack(event)
    if (myData.mf1C.count<=3) then
        local imageA = { type="image", filename="img/dc-mf1-"..myData.mf1C.count..".png" }
        myData.mf1C.fill=imageA
        if (myData.mf1C.count==3) then
            mf1Complete()
        end
    end
end

local function fadeMf2Green( event )
    if (event.count<10) then  
        mf22.fill.effect.progress=mf22.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-mf2-g.png" }
        myData.mf2.fill=imageA
        myData.mf2C.alpha=1
        myData.mf2.txtb.alpha=1
        myData.mf2.txt.alpha=1
        mf22:removeSelf()
        mf22=nil
    end
end

local function fadeFwInt2Red( event )
    if (event.count<10) then  
        fwint22.fill.effect.progress=fwint22.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-fwint2-r.png" }
        myData.fwInt2.fill=imageA
        fwint22:removeSelf()
        fwint22=nil
        mf22 = display.newImageRect( "img/dc-mf2-g.png",fontSize(300), fontSize(300))
        mf22.anchorX = 0.5
        mf22.anchorY = 0.5
        mf22:translate(myData.ips.x,myData.fwInt2.y+myData.fwInt2.height-fontSize(25))
        mf22.rotation=90
        mf22.fill.effect = "filter.linearWipe"
        mf22.fill.effect.direction = { 1, 0 }
        mf22.fill.effect.smoothness = 1
        mf22.fill.effect.progress = 0.1
        timer.performWithDelay(100,fadeMf2Green,10)
    end
end

local function fwInt2Complete(event)
    myData.fwInt2C.alpha=0
    myData.fwInt2.txtb.alpha=0
    myData.fwInt2.txt.alpha=0
    fwint22 = display.newImageRect( "img/dc-fwint2-r.png",fontSize(320), fontSize(320))
    fwint22.anchorX = 0.5
    fwint22.anchorY = 0.5
    fwint22:translate(myData.ips.x,display.actualContentHeight/2+myData.ips.height)
    fwint22.rotation=90
    fwint22.fill.effect = "filter.linearWipe"
    fwint22.fill.effect.direction = { 1, 0 }
    fwint22.fill.effect.smoothness = 1
    fwint22.fill.effect.progress = 0.1
    timer.performWithDelay(100,fadeFwInt2Red,10)
end

local function fwInt2Attack(event)
    if (myData.fwInt2C.count<=3) then
        local imageA = { type="image", filename="img/dc-fwint2-"..myData.fwInt2C.count..".png" }
        myData.fwInt2C.fill=imageA
        if (myData.fwInt2C.count==3) then
            fwInt2Complete()
        end
    end
end

local function fadeMf1Green( event )
    if (event.count<10) then  
        mf12.fill.effect.progress=mf12.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-mf1-g.png" }
        myData.mf1.fill=imageA
        myData.mf1C.alpha=1
        myData.mf1.txtb.alpha=1
        myData.mf1.txt.alpha=1
        mf12:removeSelf()
        mf12=nil
    end
end

local function fadeFwInt1Red( event )
    if (event.count<10) then  
        fwint12.fill.effect.progress=fwint12.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-fwint1-r.png" }
        myData.fwInt1.fill=imageA
        fwint12:removeSelf()
        fwint12=nil
        mf12 = display.newImageRect( "img/dc-mf1-g.png",fontSize(300), fontSize(300))
        mf12.anchorX = 0.5
        mf12.anchorY = 0.5
        mf12:translate(myData.ips.x,myData.fwInt1.y-myData.fwInt1.height+fontSize(25))
        mf12.rotation=90
        mf12.fill.effect = "filter.linearWipe"
        mf12.fill.effect.direction = { -1, 0 }
        mf12.fill.effect.smoothness = 1
        mf12.fill.effect.progress = 0.1
        timer.performWithDelay(100,fadeMf1Green,10)
    end
end

local function fwInt1Complete(event)
    myData.fwInt1C.alpha=0
    myData.fwInt1.txtb.alpha=0
    myData.fwInt1.txt.alpha=0
    fwint12 = display.newImageRect( "img/dc-fwint1-r.png",fontSize(320), fontSize(320))
    fwint12.anchorX = 0.5
    fwint12.anchorY = 0.5
    fwint12:translate(myData.ips.x,display.actualContentHeight/2-myData.ips.height)
    fwint12.rotation=90
    fwint12.fill.effect = "filter.linearWipe"
    fwint12.fill.effect.direction = { -1, 0 }
    fwint12.fill.effect.smoothness = 1
    fwint12.fill.effect.progress = 0.1
    timer.performWithDelay(100,fadeFwInt1Red,10)
end

local function fwInt1Attack(event)
    if (myData.fwInt1C.count<=3) then
        local imageA = { type="image", filename="img/dc-fwint1-"..myData.fwInt1C.count..".png" }
        myData.fwInt1C.fill=imageA
        if (myData.fwInt1C.count==3) then
            fwInt1Complete()
        end
    end
end

local function fadeSiemRed( event )
    if (event.count<10) then  
        siem2.fill.effect.progress=siem2.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-siem-r.png" }
        myData.siem.fill=imageA
        siem2:removeSelf()
        siem2=nil
    end
end

local function siemComplete(event)
    myData.siemC.alpha=0
    myData.siem.txtb.alpha=0
    myData.siem.txt.alpha=0
    siem2 = display.newImageRect( "img/dc-siem-r.png",fontSize(300), fontSize(300))
    siem2.anchorX = 0.5
    siem2.anchorY = 0.5
    siem2:translate(myData.ips.x-myData.ips.height+fontSize(15),display.actualContentHeight/2)
    siem2.rotation=90
    siem2.fill.effect = "filter.linearWipe"
    siem2.fill.effect.direction = { 0, 1 }
    siem2.fill.effect.smoothness = 1
    siem2.fill.effect.progress = 0.1
    timer.performWithDelay(100,fadeSiemRed,10)
end

local function siemAttack(event)
    if (myData.siemC.count<=3) then
        local imageA = { type="image", filename="img/dc-siem-"..myData.siemC.count..".png" }
        myData.siemC.fill=imageA
        if (myData.siemC.count==3) then
            siemComplete()
        end
    end
end

local function fadeFwInt2Green( event )
    if (event.count<10) then  
        fwint22.fill.effect.progress=fwint22.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-fwint2-g.png" }
        myData.fwInt2.fill=imageA
        myData.fwInt2C.alpha=1
        myData.fwInt2.txtb.alpha=1
        myData.fwInt2.txt.alpha=1
        fwint22:removeSelf()
        fwint22=nil
    end
end

local function fadeFwInt1Green( event )
    if (event.count<10) then  
        fwint12.fill.effect.progress=fwint12.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-fwint1-g.png" }
        myData.fwInt1.fill=imageA
        myData.fwInt1C.alpha=1
        myData.fwInt1.txtb.alpha=1
        myData.fwInt1.txt.alpha=1
        fwint12:removeSelf()
        fwint12=nil
    end
end

local function fadeSiemGreen( event )
    if (event.count<10) then  
        siem2.fill.effect.progress=siem2.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-siem-g.png" }
        myData.siem.fill=imageA
        myData.siemC.alpha=1
        myData.siem.txtb.alpha=1
        myData.siem.txt.alpha=1
        siem2:removeSelf()
        siem2=nil
    end
end

local function fadeIpsRed( event )
    if (event.count<10) then  
        ips2.fill.effect.progress=ips2.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-ips-r.png" }
        myData.ips.fill=imageA
        ips2:removeSelf()
        ips2=nil

        --Siem
        siem2 = display.newImageRect( "img/dc-siem-g.png",fontSize(300), fontSize(300))
        siem2.anchorX = 0.5
        siem2.anchorY = 0.5
        siem2:translate(myData.ips.x-myData.ips.height+fontSize(15),display.actualContentHeight/2)
        siem2.rotation=90
        siem2.fill.effect = "filter.linearWipe"
        siem2.fill.effect.direction = { 0, 1 }
        siem2.fill.effect.smoothness = 1
        siem2.fill.effect.progress = 0.1
        timer.performWithDelay(100,fadeSiemGreen,10)

        --FwInt1
        fwint12 = display.newImageRect( "img/dc-fwint1-g.png",fontSize(320), fontSize(320))
        fwint12.anchorX = 0.5
        fwint12.anchorY = 0.5
        fwint12:translate(myData.ips.x,display.actualContentHeight/2-myData.ips.height)
        fwint12.rotation=90
        fwint12.fill.effect = "filter.linearWipe"
        fwint12.fill.effect.direction = { -1, 0 }
        fwint12.fill.effect.smoothness = 1
        fwint12.fill.effect.progress = 0.1
        timer.performWithDelay(100,fadeFwInt1Green,10)

        --FwInt2
        fwint22 = display.newImageRect( "img/dc-fwint2-g.png",fontSize(320), fontSize(320))
        fwint22.anchorX = 0.5
        fwint22.anchorY = 0.5
        fwint22:translate(myData.ips.x,display.actualContentHeight/2+myData.ips.height)
        fwint22.rotation=90
        fwint22.fill.effect = "filter.linearWipe"
        fwint22.fill.effect.direction = { 1, 0 }
        fwint22.fill.effect.smoothness = 1
        fwint22.fill.effect.progress = 0.1
        timer.performWithDelay(100,fadeFwInt2Green,10)
    end
end

local function ipsComplete(event)
    myData.ipsC.alpha=0
    myData.ips.txtb.alpha=0
    myData.ips.txt.alpha=0
    ips2 = display.newImageRect( "img/dc-ips-r.png",fontSize(280), fontSize(280))
    ips2.anchorX = 0.5
    ips2.anchorY = 0.5
    ips2:translate(myData.fwExt.x-myData.fwExt.height+fontSize(40),display.actualContentHeight/2)
    ips2.rotation=90
    ips2.fill.effect = "filter.linearWipe"
    ips2.fill.effect.direction = { 0, 1 }
    ips2.fill.effect.smoothness = 1
    ips2.fill.effect.progress = 0.1
    timer.performWithDelay(100,fadeIpsRed,10)
end

local function ipsAttack(event)
    if (myData.ipsC.count<=3) then
        local imageA = { type="image", filename="img/dc-ips-"..myData.ipsC.count..".png" }
        myData.ipsC.fill=imageA
        if (myData.ipsC.count==3) then
            ipsComplete()
        end
    end
end

local function fadeIpsGreen( event )
    if (event.count<10) then  
        ips2.fill.effect.progress=ips2.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-ips-g.png" }
        myData.ips.fill=imageA
        myData.ipsC.alpha=1
        myData.ips.txtb.alpha=1
        myData.ips.txt.alpha=1
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getDcDetails.php", "POST", dcDetailsListener, params )
        ips2:removeSelf()
        ips2=nil
    end
end

local function fadeFwExtRed( event )
    if (event.count<10) then  
        fwExt2.fill.effect.progress=fwExt2.fill.effect.progress+0.1
    else
        local imageA = { type="image", filename="img/dc-fwext-r.png" }
        myData.fwExt.fill=imageA
        fwExt2:removeSelf()
        fwExt2=nil
        ips2 = display.newImageRect( "img/dc-ips-g.png",fontSize(280), fontSize(280))
        group:insert(ips2)
        ips2.anchorX = 0.5
        ips2.anchorY = 0.5
        ips2:translate(myData.fwExt.x-myData.fwExt.height+fontSize(40),display.actualContentHeight/2)
        ips2.rotation=90
        ips2.fill.effect = "filter.linearWipe"
        ips2.fill.effect.direction = { 0, 1 }
        ips2.fill.effect.smoothness = 1
        ips2.fill.effect.progress = 0.1
        timer.performWithDelay(100,fadeIpsGreen,10)
    end
end

local function fwExtComplete(event)
    myData.fwExtC.alpha=0
    myData.fwExt.txtb.alpha=0
    myData.fwExt.txt.alpha=0
    fwExt2 = display.newImageRect( "img/dc-fwext-r.png",fontSize(300), fontSize(300))
    fwExt2.anchorX = 0.5
    fwExt2.anchorY = 0.5
    fwExt2:translate(myData.top_background.x+fontSize(230),display.actualContentHeight/2)
    fwExt2.rotation=90
    fwExt2.fill.effect = "filter.linearWipe"
    fwExt2.fill.effect.direction = { 0, 1 }
    fwExt2.fill.effect.smoothness = 1
    fwExt2.fill.effect.progress = 0.1
    timer.performWithDelay(100,fadeFwExtRed,10)
end

local function fwExtAttack(event)
    if (myData.fwExtC.count<=3) then  
        --myData.fwExtC.count=myData.fwExtC.count+1
        local imageA = { type="image", filename="img/dc-fwext-"..myData.fwExtC.count..".png" }
        myData.fwExtC.fill=imageA
        if (myData.fwExtC.count==3) then
            fwExtComplete()
        end
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

local function crewWarsReward(alert,money,cc)
    if (cwOverlay==false) then
        local sceneOverlayOptions = 
        {
            time = 0,
            effect = "crossFade",
            params = { 
                text=alert,
                money=money,
                cc=cc
            },
            isModal = true
        }
        cwOverlay=true
        composer.showOverlay( "crewWarsRewardScene", sceneOverlayOptions) 
    end
end

local function dcAttackListener( event )
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
            loseSound()
            crewWarsAlert("You have already used all your hourly points!")
        elseif (t.status == "CMAX") then
            --local alert = native.showAlert( "EliteHax", "Your crew has already used all the daily points!", { "Close" } )
            loseSound()
            crewWarsAlert("Your crew has already used all the daily points!")
        elseif (t.status == "REFRESH") then
            --local alert = native.showAlert( "EliteHax", "Your need to refresh the page!", { "Close" } )
            loseSound()
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

            if (t.attack_result==1) then 
                winSound()
                myData.attack.txt.text="Successful"
                myData.attack.txt:setFillColor(0,0.7,0)
            else
                loseSound()
                myData.attack.txt.text="Failed"
                myData.attack.txt:setFillColor(0.7,0,0)
            end

            if (t.anon_result==1) then 
                myData.anonymous.txt.text="Yes"
                myData.anonymous.txt:setFillColor(0,0.7,0)
            else
                myData.anonymous.txt.text="No"
                myData.anonymous.txt:setFillColor(0.7,0,0)
            end

            if (attackType=='fwext') then
                myData.fwExtC.count=t.current_as
                myData.fwExt.clicked=0
                fwExtAttack()
            elseif (attackType=='ips') then
                myData.ipsC.count=t.current_as
                myData.ips.clicked=0
                ipsAttack()
            elseif (attackType=='siem') then
                myData.siemC.count=t.current_as
                myData.siem.clicked=0
                siemAttack()
            elseif (attackType=='fwint1') then
                myData.fwInt1C.count=t.current_as
                myData.fwInt1.clicked=0
                fwInt1Attack()
            elseif (attackType=='fwint2') then
                myData.fwInt2C.count=t.current_as
                myData.fwInt2.clicked=0
                fwInt2Attack()
            elseif (attackType=='mf1') then
                myData.mf1C.count=t.current_as
                myData.mf1.clicked=0
                mf1Attack()
            elseif (attackType=='mf2') then
                myData.mf2C.count=t.current_as
                myData.mf2.clicked=0
                mf2Attack()
            end

            if (t.mf_hack=="y") then
                --local alert = native.showAlert( "EliteHax", "Congratulations! You successfully exploited "..myData.dcName.text.."'s Mainframe!", { "Close" } )
                crewWarsReward("Congratulations! You have successfully exploited "..myData.dcName.text.."'s Mainframe!",t.money_reward,t.cc_reward)  
            elseif (t.mf_hack=="t") then
                --local alert = native.showAlert( "EliteHax", "Unfortunately this was the "..myData.dcName.text.. " test environment!", { "Close" } )
                crewWarsAlert("Unfortunately this was the "..myData.dcName.text.. "'s' test environment!")
            end

        end
        attackReceived=1
    end
end

local function setClickedZero(event)
    myData.fwExt.clicked=0
    myData.ips.clicked=0
    myData.siem.clicked=0
    myData.fwInt1.clicked=0
    myData.fwInt2.clicked=0
    myData.mf1.clicked=0
    myData.mf2.clicked=0
end

local function mf2Tap(event)
    if ((attackReceived==1) and (myData.fwInt2C.count==3)) then
        if ((event.target.clicked==0) and (myData.mf2C.count<3)) then
            myData.anonymous.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.attack.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.anonymous.txt.text=myData.mf2.anon.."%"
            myData.attack.txt.text=myData.mf2.attack.."%"
            setClickedZero()
            event.target.clicked=1
        elseif (myData.mf2C.count<3) then
            attackReceived=0
            attackType=event.target.name
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc.."&type="..event.target.name
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."attackDc.php", "POST", dcAttackListener, params )
        end
    end
end

local function mf1Tap(event)
    if ((attackReceived==1) and (myData.fwInt1C.count==3)) then
        if ((event.target.clicked==0) and (myData.mf1C.count<3)) then
            myData.anonymous.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.attack.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.anonymous.txt.text=myData.mf1.anon.."%"
            myData.attack.txt.text=myData.mf1.attack.."%"
            setClickedZero()
            event.target.clicked=1
        elseif (myData.mf1C.count<3) then
            attackReceived=0
            attackType=event.target.name
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc.."&type="..event.target.name
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."attackDc.php", "POST", dcAttackListener, params )
        end
    end
end

local function fwInt2Tap(event)
    if ((attackReceived==1) and (myData.ipsC.count==3)) then
        if ((event.target.clicked==0) and (myData.fwInt2C.count<3)) then
            myData.anonymous.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.attack.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.anonymous.txt.text=myData.fwInt2.anon.."%"
            myData.attack.txt.text=myData.fwInt2.attack.."%"
            setClickedZero()
            event.target.clicked=1
        elseif (myData.fwInt2C.count<3) then
            attackReceived=0
            attackType=event.target.name
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc.."&type="..event.target.name
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."attackDc.php", "POST", dcAttackListener, params )
        end
    end
end

local function fwInt1Tap(event)
    if ((attackReceived==1) and (myData.ipsC.count==3)) then
        if ((event.target.clicked==0) and (myData.fwInt1C.count<3)) then
            myData.anonymous.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.attack.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.anonymous.txt.text=myData.fwInt1.anon.."%"
            myData.attack.txt.text=myData.fwInt1.attack.."%"
            setClickedZero()
            event.target.clicked=1
        elseif (myData.fwInt1C.count<3) then
            attackReceived=0
            attackType=event.target.name
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc.."&type="..event.target.name
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."attackDc.php", "POST", dcAttackListener, params )
        end
    end
end

local function siemTap(event)
    if ((attackReceived==1) and (myData.ipsC.count==3)) then
        if ((event.target.clicked==0) and (myData.siemC.count<3)) then
            myData.anonymous.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.attack.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.anonymous.txt.text=myData.siem.anon.."%"
            myData.attack.txt.text=myData.siem.attack.."%"
            setClickedZero()
            event.target.clicked=1
        elseif (myData.siemC.count<3) then
            attackReceived=0
            attackType=event.target.name
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc.."&type="..event.target.name
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."attackDc.php", "POST", dcAttackListener, params )
        end
    end
end

local function ipsTap(event)
    if ((attackReceived==1) and (myData.fwExtC.count==3)) then
        if ((event.target.clicked==0) and (myData.ipsC.count<3)) then
            myData.anonymous.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.attack.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.anonymous.txt.text=myData.ips.anon.."%"
            myData.attack.txt.text=myData.ips.attack.."%"
            setClickedZero()
            event.target.clicked=1
        elseif (myData.ipsC.count<3) then
            attackReceived=0
            attackType=event.target.name
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc.."&type="..event.target.name
            local params = {}
            params.headers = headers
            params.body = body
            tapSound()
            network.request( host().."attackDc.php", "POST", dcAttackListener, params )
        end
    end
end

local function fwExtTap(event)
    if (attackReceived==1) then
        tapSound()
        if ((event.target.clicked==0) and (myData.fwExtC.count<3)) then
            myData.anonymous.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.attack.txt:setFillColor(textColor1[1],textColor1[2],textColor1[3])
            myData.anonymous.txt.text=myData.fwExt.anon.."%"
            myData.attack.txt.text=myData.fwExt.attack.."%"
            setClickedZero()
            event.target.clicked=1
        elseif (myData.fwExtC.count<3) then
            attackReceived=0
            attackType=event.target.name
            local headers = {}
            local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc.."&type="..event.target.name
            local params = {}
            params.headers = headers
            params.body = body
            network.request( host().."attackDc.php", "POST", dcAttackListener, params )
        end
    end
end
---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function datacenterScene:create(event)
    group = self.view
    mgroup = display.newGroup()
    dotGroup = display.newGroup()

    loginInfo = localToken()

    iconSize=200
    attackReceived=1
    attackType='fwext'
    init=0
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
    myData.dcName = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
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
    myData.fwExt.lvl=0
    myData.fwExt.anon="???"
    myData.fwExt.attack = "???"
    myData.fwExt.clicked=0
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

    myData.fwExtC = display.newImageRect( "img/dc-fwext-0.png",fontSize(300), fontSize(300))
    myData.fwExtC.anchorX = 0.5
    myData.fwExtC.anchorY = 0.5
    myData.fwExtC:translate(myData.top_background.x+fontSize(230),display.actualContentHeight/2+topPadding())
    myData.fwExtC.rotation=90
    myData.fwExtC.count=0

    myData.ips = display.newImageRect( "img/dc-ips-d.png",fontSize(280), fontSize(280))
    myData.ips.anchorX = 0.5
    myData.ips.anchorY = 0.5
    myData.ips:translate(myData.fwExt.x-myData.fwExt.height+fontSize(40),display.actualContentHeight/2+topPadding())
    myData.ips.rotation=90
    myData.ips.name="ips"
    myData.ips.lvl=0    
    myData.ips.anon="???"
    myData.ips.attack = "???"
    myData.ips.clicked=0
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
    myData.ips.txtb.alpha=0
    myData.ips.txt.alpha=0

    myData.ipsC = display.newImageRect( "img/dc-ips-0.png",fontSize(280), fontSize(280))
    myData.ipsC.anchorX = 0.5
    myData.ipsC.anchorY = 0.5
    myData.ipsC:translate(myData.fwExt.x-myData.fwExt.height+fontSize(40),display.actualContentHeight/2+topPadding())
    myData.ipsC.rotation=90
    myData.ipsC.alpha=0
    myData.ipsC.count=0

    myData.siem = display.newImageRect( "img/dc-siem-d.png",fontSize(300), fontSize(300))
    myData.siem.anchorX = 0.5
    myData.siem.anchorY = 0.5
    myData.siem:translate(myData.ips.x-myData.ips.height+fontSize(15),display.actualContentHeight/2+topPadding())
    myData.siem.rotation=90
    myData.siem.name="siem"
    myData.siem.lvl=0
    myData.siem.anon="???"
    myData.siem.attack = "???"
    myData.siem.clicked=0
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
    myData.siem.txtb.alpha=0
    myData.siem.txt.alpha=0

    myData.siemC = display.newImageRect( "img/dc-siem-0.png",fontSize(300), fontSize(300))
    myData.siemC.anchorX = 0.5
    myData.siemC.anchorY = 0.5
    myData.siemC:translate(myData.ips.x-myData.ips.height+fontSize(15),display.actualContentHeight/2+topPadding())
    myData.siemC.rotation=90
    myData.siemC.alpha=0
    myData.siemC.count=0

    myData.fwInt1 = display.newImageRect( "img/dc-fwint1-d.png",fontSize(320), fontSize(320))
    myData.fwInt1.anchorX = 0.5
    myData.fwInt1.anchorY = 0.5
    myData.fwInt1:translate(myData.ips.x,display.actualContentHeight/2-myData.ips.height+topPadding())
    myData.fwInt1.rotation=90
    myData.fwInt1.name="fwint1"
    myData.fwInt1.lvl=0
    myData.fwInt1.anon="???"
    myData.fwInt1.attack = "???"
    myData.fwInt1.clicked=0
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
    myData.fwInt1.txtb.alpha=0
    myData.fwInt1.txt.alpha=0

    myData.fwInt1C = display.newImageRect( "img/dc-fwint1-0.png",fontSize(320), fontSize(320))
    myData.fwInt1C.anchorX = 0.5
    myData.fwInt1C.anchorY = 0.5
    myData.fwInt1C:translate(myData.ips.x,display.actualContentHeight/2-myData.ips.height+topPadding())
    myData.fwInt1C.rotation=90
    myData.fwInt1C.alpha=0
    myData.fwInt1C.count=0

    myData.fwInt2 = display.newImageRect( "img/dc-fwint2-d.png",fontSize(320), fontSize(320))
    myData.fwInt2.anchorX = 0.5
    myData.fwInt2.anchorY = 0.5
    myData.fwInt2:translate(myData.ips.x,display.actualContentHeight/2+myData.ips.height+topPadding())
    myData.fwInt2.rotation=90
    myData.fwInt2.name="fwint2"
    myData.fwInt2.lvl=0
    myData.fwInt2.anon="???"
    myData.fwInt2.attack = "???"
    myData.fwInt2.clicked=0
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
    myData.fwInt2.txtb.alpha=0
    myData.fwInt2.txt.alpha=0

    myData.fwInt2C = display.newImageRect( "img/dc-fwint2-0.png",fontSize(320), fontSize(320))
    myData.fwInt2C.anchorX = 0.5
    myData.fwInt2C.anchorY = 0.5
    myData.fwInt2C:translate(myData.ips.x,display.actualContentHeight/2+myData.ips.height+topPadding())
    myData.fwInt2C.rotation=90
    myData.fwInt2C.alpha=0
    myData.fwInt2C.count=0

    myData.mf1 = display.newImageRect( "img/dc-mf1-d.png",fontSize(300), fontSize(300))
    myData.mf1.anchorX = 0.5
    myData.mf1.anchorY = 0.5
    myData.mf1:translate(myData.ips.x,myData.fwInt1.y-myData.fwInt1.height+fontSize(25))
    myData.mf1.rotation=90
    myData.mf1.name="mf1"
    myData.mf1.lvl=0
    myData.mf1.anon="???"
    myData.mf1.attack = "???"
    myData.mf1.clicked=0
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
    myData.mf1.txtb.alpha=0
    myData.mf1.txt.alpha=0

    myData.mf1C = display.newImageRect( "img/dc-mf1-0.png",fontSize(300), fontSize(300))
    myData.mf1C.anchorX = 0.5
    myData.mf1C.anchorY = 0.5
    myData.mf1C:translate(myData.ips.x,myData.fwInt1.y-myData.fwInt1.height+fontSize(25))
    myData.mf1C.rotation=90
    myData.mf1C.alpha=0
    myData.mf1C.count=0

    myData.mf2 = display.newImageRect( "img/dc-mf2-d.png",fontSize(300), fontSize(300))
    myData.mf2.anchorX = 0.5
    myData.mf2.anchorY = 0.5
    myData.mf2:translate(myData.ips.x,myData.fwInt2.y+myData.fwInt2.height-fontSize(25))
    myData.mf2.rotation=90
    myData.mf2.name="mf2"
    myData.mf2.lvl=0
    myData.mf2.anon="???"
    myData.mf2.attack = "???"
    myData.mf2.clicked=0
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
    myData.mf2.txtb.alpha=0
    myData.mf2.txt.alpha=0

    myData.mf2C = display.newImageRect( "img/dc-mf2-0.png",fontSize(300), fontSize(300))
    myData.mf2C.anchorX = 0.5
    myData.mf2C.anchorY = 0.5
    myData.mf2C:translate(myData.ips.x,myData.fwInt2.y+myData.fwInt2.height-fontSize(25))
    myData.mf2C.rotation=90
    myData.mf2C.alpha=0
    myData.mf2C.count=0

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

    myData.anonymous = display.newImageRect( "img/dc_anon.png",fontSize(550), fontSize(200))
    myData.anonymous.anchorX = 0.5
    myData.anonymous.anchorY = 0.5
    myData.anonymous:translate(myData.siem.x-fontSize(40),display.actualContentHeight/2-myData.anonymous.height*2.4+topPadding())
    changeImgColor(myData.anonymous)
    myData.anonymous.rotation=90
    myData.anonymous.name="anonymous"
    myData.anonymous.lvl=0
    digit = string.len(tostring(myData.anonymous.lvl))+2
    myData.anonymous.txt = display.newText("",myData.anonymous.x-fontSize(25),myData.anonymous.y,native.systemFont, fontSize(72))
    myData.anonymous.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.anonymous.txt.anchorY=0.5
    myData.anonymous.txt.rotation=90

    myData.attack = display.newImageRect( "img/dc_attack.png",fontSize(550), fontSize(200))
    myData.attack.anchorX = 0.5
    myData.attack.anchorY = 0.5
    myData.attack:translate(myData.siem.x-fontSize(40),display.actualContentHeight/2+myData.attack.height*2.4+topPadding())
    changeImgColor(myData.attack)
    myData.attack.rotation=90
    myData.attack.name="attack"
    myData.attack.lvl=0
    digit = string.len(tostring(myData.attack.lvl))+2
    myData.attack.txt = display.newText("",myData.attack.x-fontSize(25),myData.attack.y,native.systemFont, fontSize(72))
    myData.attack.txt:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    myData.attack.txt.anchorY=0.5
    myData.attack.txt.rotation=90

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
        onEvent = goBackRegion
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
    group:insert(myData.fwExt.txtb)
    group:insert(myData.mf1.txtb)
    group:insert(myData.mf2.txtb)
    group:insert(myData.fwInt1.txtb)
    group:insert(myData.fwInt2.txtb)
    group:insert(myData.siem.txtb)
    group:insert(myData.ips.txtb)
    group:insert(myData.fwExt.txt)
    group:insert(myData.mf1.txt)
    group:insert(myData.mf2.txt)
    group:insert(myData.fwInt1.txt)
    group:insert(myData.fwInt2.txt)
    group:insert(myData.siem.txt)
    group:insert(myData.ips.txt)
    group:insert(myData.cpoints)
    group:insert(myData.cpoints.txt)
    group:insert(myData.mpoints)
    group:insert(myData.mpoints.txt)
    group:insert(myData.anonymous)
    group:insert(myData.anonymous.txt)
    group:insert(myData.attack)
    group:insert(myData.attack.txt)
    group:insert(myData.fwExtC)
    group:insert(myData.mf1C)
    group:insert(myData.mf2C)
    group:insert(myData.fwInt1C)
    group:insert(myData.fwInt2C)
    group:insert(myData.siemC)
    group:insert(myData.ipsC)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackRegion)
    myData.fwExt:addEventListener("tap",fwExtTap)
    myData.ips:addEventListener("tap",ipsTap)
    myData.siem:addEventListener("tap",siemTap)
    myData.fwInt1:addEventListener("tap",fwInt1Tap)
    myData.fwInt2:addEventListener("tap",fwInt2Tap)
    myData.mf1:addEventListener("tap",mf1Tap)
    myData.mf2:addEventListener("tap",mf2Tap)
end

-- Home Show
function datacenterScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "cwAttackTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.cwAttackTutorial ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "cwAttackTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&dc="..myData.dcAttackButton.dc
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getDcDetails.php", "POST", dcDetailsListener, params )
    end

    if event.phase == "did" then
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
datacenterScene:addEventListener( "create", datacenterScene )
datacenterScene:addEventListener( "show", datacenterScene )
---------------------------------------------------------------------------------

return datacenterScene