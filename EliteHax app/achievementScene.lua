local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local loadsave = require( "loadsave" )
local upgrades = require("upgradeName")
local achievementScene = composer.newScene()
local achievementTable = {}
local achievementCollected = nil
local expandedType=0
local expandedId=0
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

local function expandRow( event )
    local id=event.target.id
    local expanded=myData.achievementTableView._view._rows[id]._view.expandBtn.expanded
    local tempExpanded

    myData.achievementTableView:deleteAllRows()
    for count=1,22,1 do
        if (achievementTable[count].id==id) then
            if (expanded==false) then
                tapSound()
                rowHeight=fontSize(400)
                tempExpanded=true
                expandedId=count
                expandedType=achievementTable[count].type
            else
                backSound()
                tempExpanded=false
                expandedType=0
            end
        else
            rowHeight=fontSize(200)
            tempExpanded=false
        end
        local color=tableColor1
        if (count%2==0) then color=tableColor2 end
        myData.achievementTableView:insertRow(
        {
            isCategory = isCategory,
            rowHeight = rowHeight,
            rowColor = rowColor,
            lineColor = lineColor,
            params = { 
                id=achievementTable[count].id,
                current=achievementTable[count].current,
                name=achievementTable[count].name,   
                desc=achievementTable[count].desc,  
                desc2=achievementTable[count].desc2,
                next=achievementTable[count].next,
                reward=achievementTable[count].reward,
                img=achievementTable[count].img,
                type=achievementTable[count].type,
                color=color,
                expanded=tempExpanded
            }
        })   
    end
    if (myData.achievementTableView:getRowAtIndex(expandedId+2)==nil) then
        myData.achievementTableView:scrollToIndex( expandedId, 0 )
    end
end

local function collectAchievementEventListener( event )
    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        local t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured...", { "Close" }, onAlert )
        elseif (t.status == "OK") then
            rewardSound()
            --local alert = native.showAlert( "EliteHax", "Collected $"..format_thousand(t.collected), { "Close" }, rewardCollected )
            if (t.new_lvl>0) then
                local sceneOverlayOptions = 
                {
                    time = 0,
                    effect = "crossFade",
                    params = { },
                    isModal = true
                }
                composer.showOverlay( "newLvlScene", sceneOverlayOptions) 
            end
            achievementCollected()
        end 
   end
end

local function collectAchievement( event )
    if ((event.phase == "ended") and (collected==0)) then
        collected=1
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type="..event.target.type
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."collectAchievement.php", "POST", collectAchievementEventListener, params )
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

    local limit=false
    if (((params.type=="internet") or (params.type=="cpu") or (params.type=="ram") or (params.type=="c2c") or (params.type=="hdd") or (params.type=="fan")) and (params.next>10)) then 
        limit=true 
        params.next=10
    elseif (((params.type=="attack_w") or (params.type=="gpu") or (params.type=="firewall") or (params.type=="ips") or (params.type=="av") or (params.type=="malware") or (params.type=="exploit") or (params.type=="siem") or (params.type=="anon") or (params.type=="webs") or (params.type=="apps") or (params.type=="dbs") or (params.type=="scan")) and (params.next>10000)) then 
        limit=true 
        params.next=10000
    elseif ((params.type=="missions") and (params.next>5000)) then        limit=true 
        params.next=5000
        params.current=5000
    elseif ((params.type=="max_activity") and (params.next>60)) then 
        limit=true 
        params.next=60
        params.current=60
    elseif ((params.type=="loyal") and (params.next>365)) then
        limit=true
        params.next=365
        params.current=365
    elseif ((params.type=="videos") and (params.next>1000)) then
        limit=true
        params.next=1000
        params.current=1000
    end
    local desc=params.desc..params.next..params.desc2

    row.achieveImage = display.newImageRect(row, params.img, iconSize/1.3, iconSize/1.3)
    row.achieveImage.x = (iconSize/2)
    row.achieveImage.y = (iconSize/2)

    row.rowLvls = display.newText( row, params.name.." ("..params.current.."/"..params.next..")", 0, 0, native.systemFont, fontSize(47) )
    row.rowLvls.anchorX = 0
    row.rowLvls.anchorY = 0
    row.rowLvls.x = row.achieveImage.x+row.achieveImage.width/2+20
    row.rowLvls.y = fontSize(40)
    row.rowLvls:setTextColor( 0, 0, 0 )

    row.expandBtn = display.newImageRect( "img/expand.png",iconSize/2.5, iconSize/2.5)
    row.expandBtn.anchorX = 0.5
    row.expandBtn.anchorY = 0
    row.expandBtn:translate(row.width-iconSize/3,fontSize(20))
    changeImgColor(row.expandBtn)
    row.expandBtn.id=params.id
    row.expandBtn.expanded=params.expanded
    if (params.expanded==true) then 
        row.expandBtn:rotate(180)
        row.expandBtn.y=row.expandBtn.y+row.expandBtn.height
    end
    row.expandBtn:addEventListener("tap",expandRow)

    local options = {
        width = 64,
        height = 64,
        numFrames = 6,
        sheetContentWidth = 384,
        sheetContentHeight = 64
    }
    local progressSheet = graphics.newImageSheet( progressColor, options )
    row.progressView = widget.newProgressView(
        {
            sheet = progressSheet,
            fillOuterLeftFrame = 1,
            fillOuterMiddleFrame = 2,
            fillOuterRightFrame = 3,
            fillOuterWidth = 30,
            fillOuterHeight = 30,
            fillInnerLeftFrame = 4,
            fillInnerMiddleFrame = 5,
            fillInnerRightFrame = 6,
            fillWidth = 30,
            fillHeight = 30,
            left = iconSize,
            top = row.rowLvls.y+row.rowLvls.height+fontSize(30),
            width = row.width-iconSize*1.2,
            isAnimated = true
        }
    )

    local percent=params.current/params.next
    row.progressView:setProgress( percent )
    row:insert(row.rowLvls)
    row:insert(row.achieveImage)
    row:insert(row.progressView)
    row:insert(row.expandBtn)

    if (params.expanded==true) then
        row.rowDesc = display.newText( row, "Reward: "..params.reward.." XP\nDescription:\n"..desc, 0, 0, native.systemFont, fontSize(47) )
        row.rowDesc.anchorX = 0
        row.rowDesc.anchorY = 0
        row.rowDesc.x = 40
        row.rowDesc.y = row.progressView.y+row.progressView.height+fontSize(20)
        row.rowDesc:setTextColor( 0, 0, 0 )
        row:insert(row.rowDesc)

        if ((percent==1) and (limit==false)) then
            row.collectButton = widget.newButton(
            {
                left = row.width-fontSize(320),
                top = row.progressView.y+row.progressView.height,
                width = fontSize(300),
                height = display.actualContentHeight/15-5,
                defaultFile = buttonColor400,
               -- overFile = "buttonOver.png",
                fontSize = fontSize(60),
                label = "Collect",
                labelColor = tableColor1,
                onEvent = collectAchievement
            })
            row.collectButton.id=params.id
            row.collectButton.type=params.type
            row.collectButton:addEventListener("tap",collectAchievement)
            row:insert(row.collectButton)
        end
    end
end

local function onRowTouch( event )

end

---------------------------------------------------------------------------------
local function achievementNetworkListener( event )
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

        myData.playerTextAchievement.text=t.user
        if (string.len(t.user)>15) then myData.playerTextAchievement.size = fontSize(42) end
        myData.moneyTextAchievement.text = format_thousand(t.money)

        rowColor = {
            default = { 0, 0, 0, 0 }
        }
        lineColor = { 
            default = { 1, 1, 0.17 }
        }

        myData.achievementTableView:deleteAllRows()
        achievementTable = {}

        --Internet
        local value = {
            id=t.internet_p+1,
            current=t.internet_c,
            name="Internet Upgrade",
            desc="Reach level ",
            desc2=" Internet upgrade",
            reward=20,
            img=upgrades['internet'].img,
            type="internet",
            color=tableColor1,
            next=t.internet_a
        }
        achievementTable[value.id]=value

        --CPU
        local value = {
            id=t.cpu_p+1,
            current=t.cpu_c,
            name="CPU Upgrade",
            desc="Reach level ",
            desc2=" CPU upgrade",
            reward=20,
            img=upgrades['cpu'].img,
            type="cpu",
            color=tableColor2,
            next=t.cpu_a
        }
        achievementTable[value.id]=value

        --RAM
        local value = {
            id=t.ram_p+1,
            current=t.ram_c,
            name="RAM Upgrade",
            desc="Reach level ",
            desc2=" RAM upgrade",
            reward=20,
            img=upgrades['ram'].img,
            type="ram",
            color=tableColor1,
            next=t.ram_a
        }
        achievementTable[value.id]=value

        --C2C
        local value = {
            id=t.c2c_p+1,
            current=t.c2c_c,
            name="C&C Upgrade",
            desc="Reach level ",
            desc2=" C&C upgrade",
            reward=20,
            img=upgrades['c2c'].img,
            type="c2c",
            color=tableColor2,
            next=t.c2c_a
        }
        achievementTable[value.id]=value

        --HDD
        local value = {
            id=t.hdd_p+1,
            current=t.hdd_c,
            name="Encrypted Disk Upgrade",
            desc="Reach level ",
            desc2=" Encrypted Disk upgrade",
            reward=20,
            img=upgrades['hdd'].img,
            type="hdd",
            color=tableColor1,
            next=t.hdd_a
        }
        achievementTable[value.id]=value

        --Fan
        local value = {
            id=t.fan_p+1,
            current=t.fan_c,
            name="Cooling System Upgrade",
            desc="Reach level ",
            desc2=" Cooling System upgrade",
            reward=20,
            img=upgrades['fan'].img,
            type="fan",
            color=tableColor2,
            next=t.fan_a
        }
        achievementTable[value.id]=value

        --GPU
        local value = {
            id=t.gpu_p+1,
            current=t.gpu_c,
            name="GPU Upgrade",
            desc="Reach level ",
            desc2=" GPU upgrade",
            reward=20,
            img=upgrades['gpu'].img,
            type="gpu",
            color=tableColor1,
            next=t.gpu_a
        }
        achievementTable[value.id]=value

        --firewall
        local value = {
            id=t.firewall_p+1,
            current=t.firewall_c,
            name="Firewall Upgrade",
            desc="Reach level ",
            desc2=" Firewall upgrade",
            reward=20,
            img=upgrades['firewall'].img,
            type="firewall",
            color=tableColor2,
            next=t.firewall_a
        }
        achievementTable[value.id]=value

        --ips
        local value = {
            id=t.ips_p+1,
            current=t.ips_c,
            name="IPS Upgrade",
            desc="Reach level ",
            desc2=" IPS upgrade",
            reward=20,
            img=upgrades['ips'].img,
            type="ips",
            color=tableColor1,
            next=t.ips_a
        }
        achievementTable[value.id]=value

        --av
        local value = {
            id=t.av_p+1,
            current=t.av_c,
            name="Antivirus Upgrade",
            desc="Reach level ",
            desc2=" Antivirus upgrade",
            reward=20,
            img=upgrades['av'].img,
            type="av",
            color=tableColor2,
            next=t.av_a
        }
        achievementTable[value.id]=value

        --malware
        local value = {
            id=t.malware_p+1,
            current=t.malware_c,
            name="Malware Upgrade",
            desc="Reach level ",
            desc2=" Malware Framework upgrade",
            reward=20,
            img=upgrades['malware'].img,
            type="malware",
            color=tableColor1,
            next=t.malware_a
        }
        achievementTable[value.id]=value

        --exploit
        local value = {
            id=t.exploit_p+1,
            current=t.exploit_c,
            name="Exploit Upgrade",
            desc="Reach level ",
            desc2=" Exploit Framework upgrade",
            reward=20,
            img=upgrades['exploit'].img,
            type="exploit",
            color=tableColor2,
            next=t.exploit_a
        }
        achievementTable[value.id]=value

        --SIEM
        local value = {
            id=t.siem_p+1,
            current=t.siem_c,
            name="SIEM Upgrade",
            desc="Reach level ",
            desc2=" SIEM upgrade",
            reward=20,
            img="img/siem.png",
            type="siem",
            color=tableColor1,
            next=t.siem_a
        }
        achievementTable[value.id]=value

        --anon
        local value = {
            id=t.anon_p+1,
            current=t.anon_c,
            name="Anonymizer Upgrade",
            desc="Reach level ",
            desc2=" Anonymizer upgrade",
            reward=20,
            img="img/anon.png",
            type="anon",
            color=tableColor2,
            next=t.anon_a
        }
        achievementTable[value.id]=value

        --webs
        local value = {
            id=t.webs_p+1,
            current=t.webs_c,
            name="Web Server Upgrade",
            desc="Reach level ",
            desc2=" Web Server ipgrade",
            reward=20,
            img="img/web-server.png",
            type="webs",
            color=tableColor1,
            next=t.webs_a
        }
        achievementTable[value.id]=value

        --apps
        local value = {
            id=t.apps_p+1,
            current=t.apps_c,
            name="App Server Upgrade",
            desc="Reach level ",
            desc2=" Application Server upgrade",
            reward=20,
            img="img/application-server.png",
            type="apps",
            color=tableColor2,
            next=t.apps_a
        }
        achievementTable[value.id]=value

        --dbs
        local value = {
            id=t.dbs_p+1,
            current=t.dbs_c,
            name="DB Server Upgrade",
            desc="Reach level ",
            desc2=" Database Server upgrade",
            reward=20,
            img="img/db-server.png",
            type="dbs",
            color=tableColor1,
            next=t.dbs_a
        }
        achievementTable[value.id]=value

        --scan
        local value = {
            id=t.scan_p+1,
            current=t.scan_c,
            name="Scanner Upgrade",
            desc="Reach level ",
            desc2=" Scanner upgrade",
            reward=20,
            img="img/scan.png",
            type="scan",
            color=tableColor2,
            next=t.scan_a
        }
        achievementTable[value.id]=value

        --Attacks Won
        local value = {
            id=t.attack_w_p+1,
            current=t.attack_w_c,
            name="Attacks Won",
            desc="Reach ",
            desc2=" Attacks Won",
            reward=20,
            img="img/attacks.png" ,
            type="attack_w",
            color=tableColor1,
            next=t.attack_w_a
        }
        achievementTable[value.id]=value

        --Missions
        local value = {
            id=t.missions_p+1,
            current=t.missions_c,
            name="Missions Collected",
            desc="Reach ",
            desc2=" Missions Collected",
            reward=20,
            img="img/mission.png",
            type="missions",
            color=tableColor2,
            next=t.missions_a
        }
        achievementTable[value.id]=value

        --Logins
        local value = {
            id=t.logins_p+1,
            current=t.logins_c,
            name="Login Streak",
            desc="Reach ",
            desc2=" consecutive logins",
            reward=20,
            img="img/login.png",
            type="max_activity",
            color=tableColor1,
            next=t.logins_a
        }
        achievementTable[value.id]=value

        --Loyal
        local value = {
            id=t.loyal_p+1,
            current=t.loyal_c,
            name="Loyalty",
            desc="Play for ",
            desc2=" days",
            reward=50,
            img="img/loyal.png",
            type="loyal",
            color=tableColor2,
            next=t.loyal_a
        }
        achievementTable[value.id]=value

        for count=1,22,1 do
            local tempExpanded=false
            local rowHeight=fontSize(190)
            if (expandedType==achievementTable[count].type) then 
                expandedId=count
                tempExpanded=true 
                rowHeight=fontSize(390)
            end
            local color=tableColor1
            if (count%2==0) then color=tableColor2 end
            myData.achievementTableView:insertRow(
            {
                isCategory = isCategory,
                rowHeight = rowHeight,
                rowColor = rowColor,
                lineColor = lineColor,
                params = { 
                    id=achievementTable[count].id,
                    current=achievementTable[count].current,
                    name=achievementTable[count].name,   
                    desc=achievementTable[count].desc,  
                    desc2=achievementTable[count].desc2,
                    next=achievementTable[count].next,
                    reward=achievementTable[count].reward,
                    img=achievementTable[count].img,
                    type=achievementTable[count].type,
                    color=color,
                    expanded=tempExpanded
                }  -- Include custom data in the row
            })   
        end
        collected=0
   end
end

achievementCollected = function(event)
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token).."&sort="..sorting
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getAchievements.php", "POST", achievementNetworkListener, params )
end

function goBackAchievement(event)
    if (tutOverlay==false) then
        backSound()
        composer.removeScene( "achievementScene" )
        composer.gotoScene("homeScene", {effect = "fade", time = 300})
    end
end

local function sortAchievement(event)
    sorting=event.target.next
    if (event.target.next=="levelA") then
        event.target.next="levelD"
    elseif (event.target.next=="levelD") then
        event.target.next="levelA"
    elseif (event.target.next=="completeD") then
        event.target.next="completeA"
    elseif (event.target.next=="completeA") then
        event.target.next="completeD"
    end
    local headers = {}
    local body = "id="..string.urlEncode(loginInfo.token).."&sort="..sorting
    local params = {}
    params.headers = headers
    params.body = body
    network.request( host().."getAchievements.php", "POST", achievementNetworkListener, params )
    myData.achievementSortL._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    myData.achievementSortC._view._label:setFillColor(tableColor1['default'][1],tableColor1['default'][2],tableColor1['default'][3],1)
    event.target._view._label._labelColor=tableColor3
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function achievementScene:create(event)
    group = self.view

    loginInfo = localToken()

    iconSize=fontSize(200)
    collected=0
    sorting="levelA"

    --Top Money/Name Background
    myData.top_background = display.newImageRect( "img/top_background.png",display.contentWidth-40, fontSize(100))
    myData.top_background.anchorX = 0.5
    myData.top_background.anchorY = 0
    myData.top_background:translate(display.contentWidth/2,5+topPadding())
    changeImgColor(myData.top_background)

    --Money
    myData.moneyTextAchievement = display.newText("",115,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.moneyTextAchievement.anchorX = 0
    myData.moneyTextAchievement.anchorY = 0.5
    myData.moneyTextAchievement:setFillColor( 0.9,0.9,0.9 )

    --Player Name
    myData.playerTextAchievement = display.newText("",display.contentWidth-250,myData.top_background.y+myData.top_background.height/2,native.systemFont, fontSize(48))
    myData.playerTextAchievement.anchorX = 0.5
    myData.playerTextAchievement.anchorY = 0.5
    myData.playerTextAchievement:setFillColor( 0.9,0.9,0.9 )

    myData.Achievement_rect = display.newImageRect( "img/achievement_rect.png",display.contentWidth-20, fontSize(1660))
    myData.Achievement_rect.anchorX = 0.5
    myData.Achievement_rect.anchorY = 0
    myData.Achievement_rect:translate(display.contentWidth/2,myData.top_background.y+myData.top_background.height+10)
    changeImgColor(myData.Achievement_rect)

    myData.achievementSortL = widget.newButton(
    {
        left = 40,
        top = myData.Achievement_rect.y+fontSize(110),
        width = 500,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Level",
        labelColor = tableColor3,
        onRelease = sortAchievement
    })
    myData.achievementSortL.next="levelA"

    myData.achievementSortC = widget.newButton(
    {
        left = myData.achievementSortL.x+myData.achievementSortL.width/2,
        top = myData.Achievement_rect.y+fontSize(110),
        width = 500,
        height = fontSize(70),
        defaultFile = buttonColor400,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(55),
        label = "Completion",
        labelColor = tableColor1,
        onRelease = sortAchievement
    })
    myData.achievementSortC.next="completeD"

    -- Create the widget
    myData.achievementTableView = widget.newTableView(
        {
            left = 20,
            top = myData.achievementSortL.y+myData.achievementSortL.height/2,
            height = myData.Achievement_rect.height-fontSize(205),
            width = display.contentWidth-80,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener,
            hideBackground = true
        }
    )
    myData.achievementTableView.anchorX=0.5
    myData.achievementTableView.x=display.contentWidth/2

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
        onEvent = goBackAchievement
    })

    -- Background
    myData.background = display.newImage("img/background.jpg")
    myData.background:scale(4,8)
    myData.background.alpha = 0.3
    changeImgColor(myData.background)

    --  Show HUD    
    group:insert(myData.background)
    group:insert(myData.backButton)
    group:insert(myData.top_background)
    group:insert(myData.moneyTextAchievement)
    group:insert(myData.playerTextAchievement)
    group:insert(myData.Achievement_rect)
    group:insert(myData.achievementSortL)
    group:insert(myData.achievementSortC)
    group:insert(myData.achievementTableView)

    --  Button Listeners
    myData.backButton:addEventListener("tap",goBackAchievement)
end

-- Home Show
function achievementScene:show(event)
    local logGroup = self.view
    if event.phase == "will" then
        local tutCompleted = loadsave.loadTable( "achievementTutorialStatus.json" )  
        if (tutCompleted == nil) or (tutCompleted.tutAchievement ~= true) then
            tutOverlay = true
            local sceneOverlayOptions = 
            {
                time = 0,
                effect = "crossFade",
                params = { },
                isModal = true
            }
            composer.showOverlay( "achievementTutScene", sceneOverlayOptions) 
        else
            tutOverlay = false
        end
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&sort="..sorting
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."getAchievements.php", "POST", achievementNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
achievementScene:addEventListener( "create", achievementScene )
achievementScene:addEventListener( "show", achievementScene )
---------------------------------------------------------------------------------

return achievementScene