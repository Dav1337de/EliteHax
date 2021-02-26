local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local upgrades = require("upgradeName")
local dcLocationScene = composer.newScene()
regionN=0
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

function goBackmap (event)
    backSound()
    if (cwOverlay==true) then
        composer.hideOverlay( "fade", 100 )
        cwOverlay=false
    else
        composer.removeScene( "dcLocationScene" )
        composer.gotoScene("myDatacenterScene", {effect = "fade", time = 100})
    end
end

local function goBackmap(event)
    if (event.phase=="ended") then
        backSound()
        composer.removeScene( "dcLocationScene" )
        composer.gotoScene("myDatacenterScene", {effect = "fade", time = 100})
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

local function dcLocationListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        if (retry==true) then
            retry=false
            retryTimer=timer.performWithDelay(1000,reloadAfterTutorial,5)
        elseif (retryCount==0) then
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
        end
    else
        print ( "RESPONSE: " .. event.response )
    
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "OOops.. A network error occurred...", { "Close" }, onAlert )
        elseif (t.status=="OK") then
            crewWarsAlert("Datacenter successfully located in "..regionName)
        elseif (t.status=="CL") then
            crewWarsAlert("You can't relocate the Datacenter!")
        end
    end
end

function datacenterRelocate( event )
    if (event.phase == "ended") then
        composer.hideOverlay( "fade", 0 )
        cwOverlay=false
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&region="..regionN
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."setDcLocation.php", "POST", dcLocationListener, params )
    end
end

local function mapClick(event)
    if (event.phase=="began") then
    end
    if (event.phase=="moved") then
        --
    end
    if (event.phase=="ended") then
        tapSound()
        regionName=""
        myData.worldMap.touchList=nil
        myData.imageNam.fill.effect = ""
        myData.imageCam.fill.effect = ""
        myData.imageSam.fill.effect = ""
        myData.imageNE.fill.effect = ""
        myData.imageCE.fill.effect = ""
        myData.imageSE.fill.effect = ""
        myData.imageEE.fill.effect = ""
        myData.imageNaf.fill.effect = ""
        myData.imageWaf.fill.effect = ""
        myData.imageMaf.fill.effect = ""
        myData.imageEaf.fill.effect = ""
        myData.imageSaf.fill.effect = ""
        myData.imageWas.fill.effect = ""
        myData.imageCas.fill.effect = ""
        myData.imageEas.fill.effect = ""
        myData.imageSas.fill.effect = ""
        myData.imageSea.fill.effect = ""
        myData.imageAnz.fill.effect = ""
        if (event.target.region=="NAM") then
            myData.imageNam.fill.effect="filter.monotone"
            myData.imageNam.fill.effect.r,myData.imageNam.fill.effect.g,myData.imageNam.fill.effect.b=0.7,0,0
            regionName="Northern America"
        elseif (event.target.region=="CAM") then
            myData.imageCam.fill.effect="filter.monotone"
            myData.imageCam.fill.effect.r,myData.imageCam.fill.effect.g,myData.imageCam.fill.effect.b=0.7,0,0
            regionName="Central America"
        elseif (event.target.region=="SAM") then
            myData.imageSam.fill.effect="filter.monotone"
            myData.imageSam.fill.effect.r,myData.imageSam.fill.effect.g,myData.imageSam.fill.effect.b=0.7,0,0
            regionName="Southern America"
        elseif (event.target.region=="NE") then
            myData.imageNE.fill.effect="filter.monotone"
            myData.imageNE.fill.effect.r,myData.imageNE.fill.effect.g,myData.imageNE.fill.effect.b=0.7,0,0
            regionName="Northern Europe"
        elseif (event.target.region=="CE") then
            myData.imageCE.fill.effect="filter.monotone"
            myData.imageCE.fill.effect.r,myData.imageCE.fill.effect.g,myData.imageCE.fill.effect.b=0.7,0,0
            regionName="Central Europe"
        elseif (event.target.region=="SE") then
            myData.imageSE.fill.effect="filter.monotone"
            myData.imageSE.fill.effect.r,myData.imageSE.fill.effect.g,myData.imageSE.fill.effect.b=0.7,0,0
            regionName="Southern Europe"
        elseif (event.target.region=="EE") then
            myData.imageEE.fill.effect="filter.monotone"
            myData.imageEE.fill.effect.r,myData.imageEE.fill.effect.g,myData.imageEE.fill.effect.b=0.7,0,0
            regionName="Eastern Europe"
        elseif (event.target.region=="WAF") then
            myData.imageWaf.fill.effect="filter.monotone"
            myData.imageWaf.fill.effect.r,myData.imageWaf.fill.effect.g,myData.imageWaf.fill.effect.b=0.7,0,0
            regionName="Western Africa"
        elseif (event.target.region=="NAF") then
            myData.imageNaf.fill.effect="filter.monotone"
            myData.imageNaf.fill.effect.r,myData.imageNaf.fill.effect.g,myData.imageNaf.fill.effect.b=0.7,0,0
            regionName="Northern Africa"
        elseif (event.target.region=="MAF") then
            myData.imageMaf.fill.effect="filter.monotone"
            myData.imageMaf.fill.effect.r,myData.imageMaf.fill.effect.g,myData.imageMaf.fill.effect.b=0.7,0,0
            regionName="Middle Africa"
        elseif (event.target.region=="EAF") then
            myData.imageEaf.fill.effect="filter.monotone"
            myData.imageEaf.fill.effect.r,myData.imageEaf.fill.effect.g,myData.imageEaf.fill.effect.b=0.7,0,0
            regionName="Eastern Africa"
        elseif (event.target.region=="SAF") then
            myData.imageSaf.fill.effect="filter.monotone"
            myData.imageSaf.fill.effect.r,myData.imageSaf.fill.effect.g,myData.imageSaf.fill.effect.b=0.7,0,0
            regionName="Southern Africa"
        elseif (event.target.region=="WAS") then
            myData.imageWas.fill.effect="filter.monotone"
            myData.imageWas.fill.effect.r,myData.imageWas.fill.effect.g,myData.imageWas.fill.effect.b=0.7,0,0
            regionName="Western Asia"
        elseif (event.target.region=="CAS") then
            myData.imageCas.fill.effect="filter.monotone"
            myData.imageCas.fill.effect.r,myData.imageCas.fill.effect.g,myData.imageCas.fill.effect.b=0.7,0,0
            regionName="Central Asia"
        elseif (event.target.region=="EAS") then
            myData.imageEas.fill.effect="filter.monotone"
            myData.imageEas.fill.effect.r,myData.imageEas.fill.effect.g,myData.imageEas.fill.effect.b=0.7,0,0
            regionName="Eastern Asia"
        elseif (event.target.region=="SAS") then
            myData.imageSas.fill.effect="filter.monotone"
            myData.imageSas.fill.effect.r,myData.imageSas.fill.effect.g,myData.imageSas.fill.effect.b=0.7,0,0
            regionName="Southern Asia"
        elseif (event.target.region=="SEA") then
            myData.imageSea.fill.effect="filter.monotone"
            myData.imageSea.fill.effect.r,myData.imageSea.fill.effect.g,myData.imageSea.fill.effect.b=0.7,0,0
            regionName="Southerneast Asia"
        elseif (event.target.region=="ANZ") then
            myData.imageAnz.fill.effect="filter.monotone"
            myData.imageAnz.fill.effect.r,myData.imageAnz.fill.effect.g,myData.imageAnz.fill.effect.b=0.7,0,0
            regionName="Australia & New Zeland"
        end
        regionN = event.target.regionN
        --local alert = native.showAlert( "EliteHax", "Do you want to place your crew datacenter in "..regionName, { "Yes", "No" }, datacenterQuestion )
        if (cwOverlay==false) then
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { 
                    text="Do you want to place your crew datacenter in "..regionName.."?",
                },
                isModal = true
            }
            cwOverlay=true
            composer.showOverlay( "relocationConfirmScene", sceneOverlayOptions) 
        end
        return true
    end
end

local function regionsNetworkListener( event )
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
    end
end
---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function dcLocationScene:create(event)
    group = self.view
    mgroup = display.newGroup()

    loginInfo = localToken()
    scanRx=true
    cwOverlay=false

    local mapHeight=display.contentWidth-240
    local mapWidth=mapHeight*1024/600
    local maskScaleY=mapHeight/600
    local maskScaleX=mapWidth/1024
    local mapX=display.contentWidth/2+fontSize(35)
    local mapY=display.actualContentHeight/2-fontSize(200)+topPadding()*2

    iconSize=200

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/crew_wars_rect.png",display.actualContentHeight-40, display.contentWidth-(display.actualContentHeight/15-5))
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

    --Underlying Map
    myData.worldMap = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.worldMap:translate( mapX, mapY )
    myData.worldMap.alpha=0.1
    myData.worldMap.rotation=90

    --North America
    myData.imageNam = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageNam:translate( mapX, mapY )
    local maskNam = graphics.newMask( "img/mask-nam.png" )
    myData.imageNam:setMask( maskNam )
    myData.imageNam.maskScaleX = maskScaleX
    myData.imageNam.maskScaleY = maskScaleY
    myData.imageNam.rotation=90
    myData.imageNam.region="NAM"
    myData.imageNam.regionN=1

    --Central America
    myData.imageCam = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageCam:translate( mapX, mapY )
    local maskCam = graphics.newMask( "img/mask-cam.png" )
    myData.imageCam:setMask( maskCam )
    myData.imageCam.maskScaleX = maskScaleX
    myData.imageCam.maskScaleY = maskScaleY
    myData.imageCam.rotation=90
    myData.imageCam.region="CAM"
    myData.imageCam.regionN=2

    --South America
    myData.imageSam = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageSam:translate( mapX, mapY )
    local maskSam = graphics.newMask( "img/mask-sam.png" )
    myData.imageSam:setMask( maskSam )
    myData.imageSam.maskScaleX = maskScaleX
    myData.imageSam.maskScaleY = maskScaleY
    myData.imageSam.rotation=90
    myData.imageSam.region="SAM"
    myData.imageSam.regionN=3

    --Northern Europe
    myData.imageNE = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageNE:translate( mapX, mapY )
    local maskNE = graphics.newMask( "img/mask-ne.png" )
    myData.imageNE:setMask( maskNE )
    myData.imageNE.maskScaleX = maskScaleX
    myData.imageNE.maskScaleY = maskScaleY
    myData.imageNE.rotation=90
    myData.imageNE.region="NE"
    myData.imageNE.regionN=4

    --Central Europe
    myData.imageCE = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageCE:translate( mapX, mapY )
    local maskCE = graphics.newMask( "img/mask-ce.png" )
    myData.imageCE:setMask( maskCE )
    myData.imageCE.maskScaleX = maskScaleX
    myData.imageCE.maskScaleY = maskScaleY
    myData.imageCE.rotation=90
    myData.imageCE.region="CE"
    myData.imageCE.regionN=5

    --Southern Europe
    myData.imageSE = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageSE:translate( mapX, mapY )
    local maskSE = graphics.newMask( "img/mask-se.png" )
    myData.imageSE:setMask( maskSE )
    myData.imageSE.maskScaleX = maskScaleX
    myData.imageSE.maskScaleY = maskScaleY
    myData.imageSE.rotation=90
    myData.imageSE.region="SE"
    myData.imageSE.regionN=6

    --Eastern Europe
    myData.imageEE = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageEE:translate( mapX, mapY )
    local maskEE = graphics.newMask( "img/mask-ee.png" )
    myData.imageEE:setMask( maskEE )
    myData.imageEE.maskScaleX = maskScaleX
    myData.imageEE.maskScaleY = maskScaleY
    myData.imageEE.rotation=90
    myData.imageEE.region="EE"
    myData.imageEE.regionN=7

    --Western Africa
    myData.imageWaf = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageWaf:translate( mapX, mapY )
    local maskWaf = graphics.newMask( "img/mask-waf.png" )
    myData.imageWaf:setMask( maskWaf )
    myData.imageWaf.maskScaleX = maskScaleX
    myData.imageWaf.maskScaleY = maskScaleY
    myData.imageWaf.rotation=90
    myData.imageWaf.region="WAF"
    myData.imageWaf.regionN=8

    --North Africa
    myData.imageNaf = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageNaf:translate( mapX, mapY )
    local maskNaf = graphics.newMask( "img/mask-naf.png" )
    myData.imageNaf:setMask( maskNaf )
    myData.imageNaf.maskScaleX = maskScaleX
    myData.imageNaf.maskScaleY = maskScaleY
    myData.imageNaf.rotation=90
    myData.imageNaf.region="NAF"
    myData.imageNaf.regionN=9

    --Middle Africa
    myData.imageMaf = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageMaf:translate( mapX, mapY )
    local maskMaf = graphics.newMask( "img/mask-maf.png" )
    myData.imageMaf:setMask( maskMaf )
    myData.imageMaf.maskScaleX = maskScaleX
    myData.imageMaf.maskScaleY = maskScaleY
    myData.imageMaf.rotation=90
    myData.imageMaf.region="MAF"
    myData.imageMaf.regionN=10

    --Eastern Africa
    myData.imageEaf = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageEaf:translate( mapX, mapY )
    local maskEaf = graphics.newMask( "img/mask-eaf.png" )
    myData.imageEaf:setMask( maskEaf )
    myData.imageEaf.maskScaleX = maskScaleX
    myData.imageEaf.maskScaleY = maskScaleY
    myData.imageEaf.rotation=90
    myData.imageEaf.region="EAF"
    myData.imageEaf.regionN=11

    --Southern Africa
    myData.imageSaf = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageSaf:translate( mapX, mapY )
    local maskSaf = graphics.newMask( "img/mask-saf.png" )
    myData.imageSaf:setMask( maskSaf )
    myData.imageSaf.maskScaleX = maskScaleX
    myData.imageSaf.maskScaleY = maskScaleY
    myData.imageSaf.rotation=90
    myData.imageSaf.region="SAF"
    myData.imageSaf.regionN=12

    --Western Asia
    myData.imageWas = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageWas:translate( mapX, mapY )
    local maskWas = graphics.newMask( "img/mask-was.png" )
    myData.imageWas:setMask( maskWas )
    myData.imageWas.maskScaleX = maskScaleX
    myData.imageWas.maskScaleY = maskScaleY
    myData.imageWas.rotation=90
    myData.imageWas.region="WAS"
    myData.imageWas.regionN=13

    --Central Asia
    myData.imageCas = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageCas:translate( mapX, mapY )
    local maskCas = graphics.newMask( "img/mask-cas.png" )
    myData.imageCas:setMask( maskCas )
    myData.imageCas.maskScaleX = maskScaleX
    myData.imageCas.maskScaleY = maskScaleY
    myData.imageCas.rotation=90
    myData.imageCas.region="CAS"
    myData.imageCas.regionN=14

    --Eastern Asia
    myData.imageEas = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageEas:translate( mapX, mapY )
    local maskEas = graphics.newMask( "img/mask-eas.png" )
    myData.imageEas:setMask( maskEas )
    myData.imageEas.maskScaleX = maskScaleX
    myData.imageEas.maskScaleY = maskScaleY
    myData.imageEas.rotation=90
    myData.imageEas.region="EAS"
    myData.imageEas.regionN=15

    --Southern Asia
    myData.imageSas = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageSas:translate( mapX, mapY )
    local maskSas = graphics.newMask( "img/mask-sas.png" )
    myData.imageSas:setMask( maskSas )
    myData.imageSas.maskScaleX = maskScaleX
    myData.imageSas.maskScaleY = maskScaleY
    myData.imageSas.rotation=90
    myData.imageSas.region="SAS"
    myData.imageSas.regionN=16

    --Southerneast Asia
    myData.imageSea = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageSea:translate( mapX, mapY )
    local maskSea = graphics.newMask( "img/mask-sea.png" )
    myData.imageSea:setMask( maskSea )
    myData.imageSea.maskScaleX = maskScaleX
    myData.imageSea.maskScaleY = maskScaleY
    myData.imageSea.rotation=90
    myData.imageSea.region="SEA"
    myData.imageSea.regionN=17

    --Australia and New Zeland
    myData.imageAnz = display.newImageRect( "img/world-map.png", mapWidth, mapHeight )
    myData.imageAnz:translate( mapX, mapY )
    local maskAnz = graphics.newMask( "img/mask-anz.png" )
    myData.imageAnz:setMask( maskAnz )
    myData.imageAnz.maskScaleX = maskScaleX
    myData.imageAnz.maskScaleY = maskScaleY
    myData.imageAnz.rotation=90
    myData.imageAnz.region="ANZ"
    myData.imageAnz.regionN=18

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

    local maskWorld = graphics.newMask( "img/world-map-mask.png" )
    mgroup:setMask( maskWorld )
    mgroup.maskX=mapX
    mgroup.maskY=mapY
    mgroup.maskScaleX = maskScaleY
    mgroup.maskScaleY = maskScaleX

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD   
    mgroup:insert(myData.worldMap) 
    mgroup:insert(myData.imageNam)
    mgroup:insert(myData.imageCam)
    mgroup:insert(myData.imageSam)
    mgroup:insert(myData.imageNE)
    mgroup:insert(myData.imageCE)
    mgroup:insert(myData.imageSE)
    mgroup:insert(myData.imageEE)
    mgroup:insert(myData.imageNaf)
    mgroup:insert(myData.imageWaf)
    mgroup:insert(myData.imageMaf)
    mgroup:insert(myData.imageEaf)
    mgroup:insert(myData.imageSaf)
    mgroup:insert(myData.imageWas)
    mgroup:insert(myData.imageCas)
    mgroup:insert(myData.imageEas)
    mgroup:insert(myData.imageSas)
    mgroup:insert(myData.imageSea)
    mgroup:insert(myData.imageAnz)
    group:insert(myData.background)
    group:insert(myData.top_background)
    group:insert(mgroup)
    group:insert(myData.playerTextCW)
    group:insert(myData.moneyTextCW)
    group:insert(myData.backButton)

    --  Button Listeners
    myData.imageNam:addEventListener("touch",mapClick)
    myData.imageCam:addEventListener("touch",mapClick)
    myData.imageSam:addEventListener("touch",mapClick)
    myData.imageNE:addEventListener("touch",mapClick)
    myData.imageCE:addEventListener("touch",mapClick)
    myData.imageSE:addEventListener("touch",mapClick)
    myData.imageEE:addEventListener("touch",mapClick)
    myData.imageNaf:addEventListener("touch",mapClick)
    myData.imageWaf:addEventListener("touch",mapClick)
    myData.imageMaf:addEventListener("touch",mapClick)
    myData.imageEaf:addEventListener("touch",mapClick)
    myData.imageSaf:addEventListener("touch",mapClick)
    myData.imageWas:addEventListener("touch",mapClick)
    myData.imageCas:addEventListener("touch",mapClick)
    myData.imageEas:addEventListener("touch",mapClick)
    myData.imageSas:addEventListener("touch",mapClick)
    myData.imageSea:addEventListener("touch",mapClick)
    myData.imageAnz:addEventListener("touch",mapClick)
    myData.backButton:addEventListener("tap",goBackmap)
end

-- Home Show
function dcLocationScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token)
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getRegions.php", "POST", regionsNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
dcLocationScene:addEventListener( "create", dcLocationScene )
dcLocationScene:addEventListener( "show", dcLocationScene )
---------------------------------------------------------------------------------

return dcLocationScene