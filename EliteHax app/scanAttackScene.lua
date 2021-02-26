local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local scanAttackScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    if (event.phase=="ended") then
        if (attackerLine) then
            attackerLine:removeSelf()
            attackerLine = newLine
        end
        if (typewriterTimer) then 
            timer.cancel(typewriterTimer)
        end
        backSound()
        scanOverlay=false
        composer.hideOverlay( "fade", 100 )
    end
end

local function onAlert()
    if ( event.action == "clicked" ) then
        if  system.getInfo("platformName")=="Android" then
            native.requestExit()
        else
            os.exit() 
        end
    end
end

local typewriterFunction = function(event)
   myData.resultText.text = string.sub(text1, 1, event.count)
end

local function attackListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured... Err: 7", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured... Err: 8", { "Close" }, onAlert )
        end
        if (typewriterTimer) then 
            timer.cancel(typewriterTimer)
        end

        if (t.status == "WAIT") then
            loseSound()
            local minutes = math.floor( t.secs / 60 )
            local timeDisplay = string.format( "%02d", minutes )
            text1 = "Already attacked! Wait "..timeDisplay.."m before the next attack!"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        elseif (t.status == "BOT_LIMIT") then
            loseSound()
            text1 = "Too many Bot Malwares! Upgrade your C2C Server"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        elseif (t.status == "TOO_MANY_BOT") then
            loseSound()
            text1 = "Your target already has 50 Bot Malwares!"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        elseif (t.status == "BOT_ALREADY_INFECTED") then
            loseSound()
            text1 = "You already infected this target with a Bot Malware!"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        elseif (t.status == "BOT_3_ATTEMPTS") then
            loseSound()
            local minutes = math.floor( t.secs / 60 )
            local timeDisplay = string.format( "%02d", minutes )
            text1 = "Too many attempts! Wait "..timeDisplay.."m before trying again!"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        elseif (t.status == "RAT_LIMIT") then
            loseSound()
            text1 = "Too many RAT Malwares! Upgrade your C2C Server"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        elseif (t.status == "TOO_MANY_RAT") then
            loseSound()
            text1 = "Your target already has 50 RAT Malwares!"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        elseif (t.status == "RAT_ALREADY_INFECTED") then
            loseSound()
            text1 = "You already infected this target with a RAT Malware!"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        elseif (t.status == "RAT_3_ATTEMPTS") then
            loseSound()
            local minutes = math.floor( t.secs / 60 )
            local timeDisplay = string.format( "%02d", minutes )
            text1 = "Too many attempts! Wait "..timeDisplay.."m before trying again!"
            myData.resultText:setFillColor(0.7,0,0)
            typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            attackRx=true
        else
            if (t.type == "bot") then
                if (t.status == "WIN") then 
                    winSound()
                    text1 = "Bot Malware successfully added to your botnet! "
                    myData.resultText:setFillColor(0,0.7,0)
                else 
                    loseSound()
                    text1 = "Failed to infect the target with a Bot Malware " 
                    myData.resultText:setFillColor(0.7,0,0)
                end
                typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            elseif (t.type == "rat") then
                if (t.status == "WIN") then 
                    winSound()
                    text1 = "RAT Malware successfully installed!"
                    myData.resultText:setFillColor(0,0.7,0)
                else 
                    loseSound()
                    text1 = "Failed to infect the target with a RAT Malware " 
                    myData.resultText:setFillColor(0.7,0,0)
                end
                typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
            else
                if (t.type == "webs") then t.type = "Web Server" end
                if (t.type == "apps") then t.type = "Application Server" end
                if (t.type == "dbs") then t.type = "Database Server" end
                if (t.type == "money") then t.type = "Money Malware" end
                if (t.anon == 0) then 
                    t.anon = "No" 
                    myData.anontText.text="No"
                    myData.anontText:setFillColor(0.7,0,0)
                else 
                    t.anon = "Yes"
                    myData.anontText.text="Yes"
                    myData.anontText:setFillColor(0,0.7,0)
                end
                if (t.result == 1) then 
                    winSound()
                    text1 = t.type.." Attack Successful"
                    myData.resultText:setFillColor(0,0.7,0)
                    myData.moneytText.text = "+"..format_thousand(t.stolen_money)
                    myData.moneytText:setFillColor(0,0.7,0)
                    myData.reptText.text = "+"..t.rep_change
                    myData.reptText:setFillColor(0,0.7,0)
                else 
                    loseSound()
                    text1 = t.type.." Attack Failed"
                    myData.resultText:setFillColor(0.7,0,0)
                    myData.moneytText.text = "+0"
                    myData.moneytText:setFillColor(0.7,0,0)
                    myData.reptText.text = t.rep_change
                    myData.reptText:setFillColor(0.7,0,0)
                end
                typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
                
                if (t.new_money ~= "0") then myData.moneyTextTerminal.text = format_thousand(t.new_money) end

                if (manual == false) then
                    myData[fwid].atk=true
                    myData[fwid].txt:setFillColor( 0.84,0.15,0.15 )
                    myData[fwid].txtb:setStrokeColor( 0.84, 0.15, 0.15 )
                    myData[fwid].ip:setFillColor( 0.84,0.15,0.15 )
                end
            end
            attackRx=true
        end
    end
end

local function exploitWebClick()
    if (attackRx == true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type=webs&target="..targetId.."&data="..string.urlEncode(generateNonce())
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."attackTarget.php", "POST", attackListener, params )
        attackRx=false
    end
end

local function exploitAppClick()
    if (attackRx == true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type=apps&target="..targetId.."&data="..string.urlEncode(generateNonce())
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."attackTarget.php", "POST", attackListener, params ) 
        attackRx=false  
    end        
end

local function exploitDbClick()
    if (attackRx == true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type=dbs&target="..targetId.."&data="..string.urlEncode(generateNonce())
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."attackTarget.php", "POST", attackListener, params )  
        attackRx=false
    end    
end

local function malwareMoneyClick()
    if (attackRx == true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type=money&target="..targetId.."&data="..string.urlEncode(generateNonce())
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."attackTarget.php", "POST", attackListener, params )
        attackRx=false
    end
end

local function malwareBotClick()
    if (attackRx == true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type=bot&target="..targetId.."&data="..string.urlEncode(generateNonce())
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."attackTarget.php", "POST", attackListener, params )
        attackRx=false 
    end
end

local function malwareRatClick()
    if (attackRx == true) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&type=rat&target="..targetId.."&data="..string.urlEncode(generateNonce())
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."attackTarget.php", "POST", attackListener, params )
        attackRx=false
    end    
end

local function scanListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
        local alert = native.showAlert( "EliteHax", "Oops.. A network error occured... Err: 9", { "Close" }, onAlert )
    else
        print ( "RESPONSE: " .. event.response )
        t = json.decode( base64Decode(event.response) )

        if ( t == nil ) then
            print ("EMPTY T")
            local alert = native.showAlert( "EliteHax", "Oops.. A network error occured... Err: 10", { "Close" }, onAlert )
        end
        print(t.attacked)

        if (t.attacked=="Y") then
            myData.fw.txt:setFillColor( 0.84,0.15,0.15 )
            myData.fw.txtb:setStrokeColor( 0.84, 0.15, 0.15 )
            myData.fw.ip:setFillColor( 0.84,0.15,0.15 )
        end

        if (t.money ~= "?") then t.money = format_thousand(t.money) end 
        myData.targetName.text=t.user
        if (string.len(myData.targetName.text)>16) then
            myData.targetName.size = fontSize(36)
        end
        myData.crewtText.text=t.crew
        myData.fw.txt.text=t.firewall
        local digit = string.len(tostring(myData.fw.txt.text))
        myData.fw.ip.text=t.ip
        myData.fw.txtb.width=70+(30*digit)
        myData.anontText.text=t.anonChance.."%"
        myData.moneytText.text=t.money
        if (string.len(myData.moneytText.text)>12) then
            myData.moneytText.size = fontSize(44)
        end
        if (string.len(myData.moneytText.text)>14) then
            myData.moneytText.size = fontSize(42)
        end
        myData.reptText.text=t.rep_change
        myData.avtText.text=t.av
        myData.gputText.text=t.gpu
        myData.malwaretText.text=t.malware
        myData.exploittText.text=t.exploit
        myData.ipstText.text=t.ips
        myData.webstText.text=t.webs
        myData.appstText.text=t.apps
        myData.dbstText.text=t.dbs

        myData.webText.text=t.webChance.."%"
        if (t.webChance == "??") then myData.webText:setFillColor( 0.7,0,0 )
        elseif (tonumber(t.webChance) > 66) then myData.webText:setFillColor( 0,0.7,0 ) 
        elseif (tonumber(t.webChance) > 33) then myData.webText:setFillColor( 0.7,0.7,0 ) 
        else myData.webText:setFillColor( 0.7,0,0 ) end
        myData.appText.text=t.appChance.."%"
        if (t.appChance == "??") then myData.appText:setFillColor( 0.7,0,0 )
        elseif (tonumber(t.appChance) > 66) then myData.appText:setFillColor( 0,0.7,0 ) 
        elseif (tonumber(t.appChance) > 33) then myData.appText:setFillColor( 0.7,0.7,0 ) 
        else myData.appText:setFillColor( 0.7,0,0 ) end
        myData.dbText.text=t.dbChance.."%"
        if (t.dbChance == "??") then myData.dbText:setFillColor( 0.7,0,0 )
        elseif (tonumber(t.dbChance) > 66) then myData.dbText:setFillColor( 0,0.7,0 ) 
        elseif (tonumber(t.dbChance) > 33) then myData.dbText:setFillColor( 0.7,0.7,0 ) 
        else myData.dbText:setFillColor( 0.7,0,0 ) end
        myData.moneyText.text=t.moneyChance.."%"
        if (t.moneyChance == "??") then myData.moneyText:setFillColor( 0.7,0,0 )
        elseif (tonumber(t.moneyChance) > 66) then myData.moneyText:setFillColor( 0,0.7,0 ) 
        elseif (tonumber(t.moneyChance) > 33) then myData.moneyText:setFillColor( 0.7,.7,0 ) 
        else myData.moneyText:setFillColor( 0.7,0,0 ) end
        myData.botText.text=t.botChance.."%"
        if (t.botChance == "??") then myData.botText:setFillColor( 0.7,0,0 )
        elseif (tonumber(t.botChance) > 66) then myData.botText:setFillColor( 0,0.7,0 ) 
        elseif (tonumber(t.botChance) > 33) then myData.botText:setFillColor( 0.7,0.7,0 ) 
        else myData.botText:setFillColor( 0.7,0,0 ) end
        myData.ratText.text=t.ratChance.."%"
        if (t.ratChance == "??") then myData.ratText:setFillColor( 0.7,0,0 )
        elseif (tonumber(t.ratChance) > 66) then myData.ratText:setFillColor( 0,0.7,0 ) 
        elseif (tonumber(t.ratChance) > 33) then myData.ratText:setFillColor( 0.7,0.7,0 ) 
        else myData.ratText:setFillColor( 0.7,0,0 ) end
        scanRx=true
    end
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function scanAttackScene:create(event)
    sgroup = self.view
    params = event.params

    fwid = event.params.fw
    targetId = event.params.target
    manual = event.params.manual
    text1 = ""
    attackRx = true

    loginInfo = localToken()

    iconSize=200

    myData.scanRect = display.newImageRect( "img/terminal_scan.png",display.contentWidth-70,fontSize(1190) )
    myData.scanRect.anchorX = 0.5
    myData.scanRect.anchorY = 0
    myData.scanRect.x, myData.scanRect.y = display.contentWidth/2,myData.top_background.y+myData.top_background.height+fontSize(85)
    changeImgColor(myData.scanRect)

    myData.targetName = display.newText("",myData.scanRect.x+8,myData.scanRect.y+fontSize(50) ,native.systemFont, fontSize(40))
    myData.targetName.anchorX = 0.5
    myData.targetName.anchorY = 0.5

    --FW
    myData.fw = display.newImageRect( "img/firewall.png",iconSize/1.1,iconSize/1.1 )
    myData.fw.id="fw"
    myData.fw.anchorX = 0.5
    myData.fw.anchorY = 0.5
    myData.fw.x, myData.fw.y = display.contentWidth/2,myData.scanRect.y+fontSize(620)
    myData.fw.txtb = display.newRoundedRect(myData.fw.x,myData.fw.y,70,70,12)
    myData.fw.txtb.anchorX=0.5
    myData.fw.txtb.anchorY=0.5
    myData.fw.txtb.strokeWidth = 5
    myData.fw.txtb:setFillColor( 0,0,0 )
    myData.fw.txtb:setStrokeColor( 0,0.7,0 )
    myData.fw.txt = display.newText("",myData.fw.x,myData.fw.y ,native.systemFont, fontSize(72))
    myData.fw.txt:setFillColor( 0,0.7,0 )
    myData.fw.ip = display.newText("",myData.fw.x,myData.fw.y+myData.fw.height/2+20,native.systemFont, fontSize(40))
    myData.fw.ip:setFillColor( textColor1[1],textColor1[2],textColor1[3] )
    if (event.params.attacked == true) then
        myData.fw.txt:setFillColor( 0.84,0.15,0.15 )
        myData.fw.txtb:setStrokeColor( 0.84, 0.15, 0.15 )
        myData.fw.ip:setFillColor( 0.84,0.15,0.15 )
    end

    --Crew Rect
    myData.crewtRect = display.newImageRect( "img/terminal_crew.png",260,fontSize(110) )
    myData.crewtRect.anchorX = 0.5
    myData.crewtRect.anchorY = 0
    myData.crewtRect.x, myData.crewtRect.y = myData.scanRect.x, myData.fw.y-fontSize(230)
    changeImgColor(myData.crewtRect)
    myData.crewtText = display.newText("",myData.crewtRect.x,myData.crewtRect.y+myData.crewtRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.crewtText.anchorX = 0.5
    myData.crewtText.anchorY = 0.5 

    -- Web Server
    myData.webExploit = display.newImageRect( "img/web-server.png",iconSize/1.3,iconSize/1.3 )
    myData.webExploit.anchorX = 0
    myData.webExploit.anchorY = 0
    myData.webExploit.x, myData.webExploit.y = myData.scanRect.x*0.70-(iconSize/1.3), myData.fw.y-myData.fw.height/2-fontSize(150)
    myData.webText = display.newText("",myData.webExploit.x-10,myData.webExploit.y+myData.webExploit.height/2,native.systemFont, fontSize(58))
    myData.webText.anchorX = 1
    myData.webText.anchorY = 0.5

    -- App Server
    myData.appExploit = display.newImageRect( "img/application-server.png",iconSize/1.3,iconSize/1.3 )
    myData.appExploit.anchorX = 0
    myData.appExploit.anchorY = 0.5
    myData.appExploit.x, myData.appExploit.y = myData.scanRect.x*0.65-(iconSize/1.3), myData.fw.y+fontSize(20)
    myData.appText = display.newText("",myData.appExploit.x,myData.appExploit.y ,native.systemFont, fontSize(58))
    myData.appText.anchorX = 1
    myData.appText.anchorY = 0.5

    -- DB Server
    myData.dbExploit = display.newImageRect( "img/db-server.png",iconSize/1.3,iconSize/1.3 )
    myData.dbExploit.anchorX = 0
    myData.dbExploit.anchorY = 0
    myData.dbExploit.x, myData.dbExploit.y = myData.scanRect.x*0.75-(iconSize/1.3), myData.fw.y+fontSize(140)
    myData.dbText = display.newText("",myData.dbExploit.x,myData.dbExploit.y+myData.dbExploit.height/2,native.systemFont, fontSize(58))
    myData.dbText.anchorX = 1
    myData.dbText.anchorY = 0.5

    -- Money Malware
    myData.moneyMalware = display.newImageRect( "img/malware_money.png",iconSize/1.3,iconSize/1.3 )
    myData.moneyMalware.anchorX = 0
    myData.moneyMalware.anchorY = 0
    myData.moneyMalware.x, myData.moneyMalware.y = myData.scanRect.x*1.3, myData.fw.y-myData.fw.height/2-fontSize(150)
    myData.moneyText = display.newText("",myData.moneyMalware.x+myData.moneyMalware.width+20,myData.moneyMalware.y+myData.moneyMalware.height/2,native.systemFont, fontSize(58))
    myData.moneyText.anchorX = 0
    myData.moneyText.anchorY = 0.5

    -- Bot Malware
    myData.botMalware = display.newImageRect( "img/malware_botnet.png",iconSize/1.3,iconSize/1.3 )
    myData.botMalware.anchorX = 0
    myData.botMalware.anchorY = 0.5
    myData.botMalware.x, myData.botMalware.y = myData.scanRect.x*1.35, myData.fw.y+fontSize(20)
    myData.botText = display.newText("",myData.botMalware.x+myData.botMalware.width+20,myData.botMalware.y ,native.systemFont, fontSize(58))
    myData.botText.anchorX = 0
    myData.botText.anchorY = 0.5

    -- RAT Malware
    myData.ratMalware = display.newImageRect( "img/malware_rat.png",iconSize/1.3,iconSize/1.3 )
    myData.ratMalware.anchorX = 0
    myData.ratMalware.anchorY = 0
    myData.ratMalware.x, myData.ratMalware.y = myData.scanRect.x*1.25, myData.fw.y+fontSize(140)
    myData.ratText = display.newText("",myData.ratMalware.x+myData.ratMalware.width+20,myData.ratMalware.y+myData.ratMalware.height/2 ,native.systemFont, fontSize(58))
    myData.ratText.anchorX = 0
    myData.ratText.anchorY = 0.5

    -- Anonymous Rect
    myData.anonRect = display.newImageRect( "img/terminal_anon.png",420,fontSize(120) )
    myData.anonRect.anchorX = 0
    myData.anonRect.anchorY = 0
    myData.anonRect.x, myData.anonRect.y = myData.scanRect.x-myData.scanRect.width/2+40, myData.fw.y+fontSize(320)
    changeImgColor(myData.anonRect)
    myData.anontText = display.newText("",myData.anonRect.x+myData.anonRect.width/2,myData.anonRect.y+myData.anonRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.anontText.anchorX = 0.5
    myData.anontText.anchorY = 0.5 

    -- Money Rect
    myData.moneyRect = display.newImageRect( "img/terminal_money.png",420,fontSize(120) )
    myData.moneyRect.anchorX = 0.5
    myData.moneyRect.anchorY = 0
    myData.moneyRect.x, myData.moneyRect.y = myData.scanRect.x+myData.moneyRect.width/2+40, myData.fw.y+fontSize(320)
    changeImgColor(myData.moneyRect)
    myData.moneytText = display.newText("",myData.moneyRect.x+20,myData.moneyRect.y+myData.moneyRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.moneytText.anchorX = 0.5
    myData.moneytText.anchorY = 0.5 

    -- Reputation Rect
    myData.repRect = display.newImageRect( "img/terminal_rep.png",260,fontSize(120) )
    myData.repRect.anchorX = 1
    myData.repRect.anchorY = 0
    myData.repRect.x, myData.repRect.y = myData.scanRect.x+myData.scanRect.width/2-40, myData.fw.y+fontSize(320)
    changeImgColor(myData.repRect)
    myData.reptText = display.newText("",myData.repRect.x-myData.repRect.width/2,myData.repRect.y+myData.repRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.reptText.anchorX = 0.5
    myData.reptText.anchorY = 0.5 
    myData.repRect.alpha=0
    myData.reptText.alpha=0

    -- Antivirus Rect
    myData.avRect = display.newImageRect( "img/terminal_antivirus.png",235,fontSize(120) )
    myData.avRect.anchorX = 0
    myData.avRect.anchorY = 0
    myData.avRect.x, myData.avRect.y = myData.scanRect.x-myData.scanRect.width/2+35, myData.fw.y-fontSize(500)
    myData.avtText = display.newText("",myData.avRect.x+myData.avRect.width/2+20,myData.avRect.y+myData.avRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.avtText.anchorX = 0.5
    myData.avtText.anchorY = 0.5 

    -- GPU Rect
    myData.gpuRect = display.newImageRect( "img/terminal_gpu.png",235,fontSize(120) )
    myData.gpuRect.anchorX = 0
    myData.gpuRect.anchorY = 0
    myData.gpuRect.x, myData.gpuRect.y = myData.avRect.x+myData.avRect.width, myData.avRect.y
    myData.gputText = display.newText("",myData.gpuRect.x+myData.gpuRect.width/2+20,myData.gpuRect.y+myData.gpuRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.gputText.anchorX = 0.5
    myData.gputText.anchorY = 0.5 

    -- Malware Rect
    myData.malwareRect = display.newImageRect( "img/terminal_malware.png",235,fontSize(120) )
    myData.malwareRect.anchorX = 0
    myData.malwareRect.anchorY = 0
    myData.malwareRect.x, myData.malwareRect.y = myData.gpuRect.x+myData.gpuRect.width, myData.avRect.y
    myData.malwaretText = display.newText("",myData.malwareRect.x+myData.malwareRect.width/2+20,myData.malwareRect.y+myData.malwareRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.malwaretText.anchorX = 0.5
    myData.malwaretText.anchorY = 0.5 

    -- Exploit Rect
    myData.exploitRect = display.newImageRect( "img/terminal_exploit.png",235,fontSize(120) )
    myData.exploitRect.anchorX = 0
    myData.exploitRect.anchorY = 0
    myData.exploitRect.x, myData.exploitRect.y = myData.malwareRect.x+myData.malwareRect.width, myData.avRect.y
    myData.exploittText = display.newText("",myData.exploitRect.x+myData.exploitRect.width/2+20,myData.exploitRect.y+myData.exploitRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.exploittText.anchorX = 0.5
    myData.exploittText.anchorY = 0.5 

    -- IPS Rect
    myData.ipsRect = display.newImageRect( "img/terminal_ips.png",235,fontSize(120) )
    myData.ipsRect.anchorX = 0
    myData.ipsRect.anchorY = 0
    myData.ipsRect.x, myData.ipsRect.y = myData.scanRect.x-myData.scanRect.width/2+35, myData.avRect.y+myData.avRect.height
    myData.ipstText = display.newText("",myData.ipsRect.x+myData.ipsRect.width/2+20,myData.ipsRect.y+myData.ipsRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.ipstText.anchorX = 0.5
    myData.ipstText.anchorY = 0.5 

    -- Web Server Rect
    myData.websRect = display.newImageRect( "img/terminal_webs.png",235,fontSize(120) )
    myData.websRect.anchorX = 0
    myData.websRect.anchorY = 0
    myData.websRect.x, myData.websRect.y = myData.ipsRect.x+myData.ipsRect.width, myData.ipsRect.y
    myData.webstText = display.newText("",myData.websRect.x+myData.websRect.width/2+20,myData.websRect.y+myData.websRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.webstText.anchorX = 0.5
    myData.webstText.anchorY = 0.5 

    -- App Server Rect
    myData.appsRect = display.newImageRect( "img/terminal_apps.png",235,fontSize(120) )
    myData.appsRect.anchorX = 0
    myData.appsRect.anchorY = 0
    myData.appsRect.x, myData.appsRect.y = myData.websRect.x+myData.websRect.width, myData.ipsRect.y
    myData.appstText = display.newText("",myData.appsRect.x+myData.appsRect.width/2+20,myData.appsRect.y+myData.appsRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.appstText.anchorX = 0.5
    myData.appstText.anchorY = 0.5 

    -- DB Server Rect
    myData.dbsRect = display.newImageRect( "img/terminal_dbs.png",235,fontSize(120) )
    myData.dbsRect.anchorX = 0
    myData.dbsRect.anchorY = 0
    myData.dbsRect.x, myData.dbsRect.y = myData.appsRect.x+myData.appsRect.width, myData.ipsRect.y
    myData.dbstText = display.newText("",myData.dbsRect.x+myData.dbsRect.width/2+20,myData.dbsRect.y+myData.dbsRect.height/2+10 ,native.systemFont, fontSize(50))
    myData.dbstText.anchorX = 0.5
    myData.dbstText.anchorY = 0.5 

    -- Attack Result
    myData.resultRect = display.newImageRect( "img/terminal_result.png",myData.scanRect.width-55,fontSize(100) )
    myData.resultRect.anchorX = 0.5
    myData.resultRect.anchorY = 0
    myData.resultRect.x, myData.resultRect.y = myData.scanRect.x,myData.moneyRect.y+myData.moneyRect.height
    changeImgColor(myData.resultRect)
    myData.resultText = display.newText("",myData.resultRect.x,myData.resultRect.y+myData.resultRect.height/2+10 ,native.systemFont, fontSize(40))
    myData.resultText.anchorX = 0.5
    myData.resultText.anchorY = 0.5 

    -- Close Button
    -- myData.closeBtnAS = display.newImageRect( "img/x.png",iconSize/3.1,iconSize/3.1 )
    -- myData.closeBtnAS.anchorX = 1
    -- myData.closeBtnAS.anchorY = 0
    -- myData.closeBtnAS.x, myData.closeBtnAS.y = myData.scanRect.width, myData.scanRect.y+fontSize(55)
    -- myData.closeBtnAS.fill.effect="filter.hue"
    -- myData.closeBtnAS.fill.effect.angle=angleColor

    --Overlay Duplication
    myData.manualScanButtonAS = widget.newButton(
    {
        left = myData.manualInput.x+myData.manualInput.width+20,
        top = myData.manualInput.y-myData.manualInput.height/2-fontSize(10),
        width = display.contentWidth/4,
        height = fontSize(90),
        defaultFile = buttonColor400,
            -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Scan",
        labelColor = tableColor1,
        onEvent = manualScan
    })     
    myData.manualScanButtonAS.anchorX=0.5

    myData.targetListButtonAS = widget.newButton(
    {
        left = 35,
        top = myData.manualT.y+myData.manualT.height+30,
        width = display.contentWidth - 80,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Target List",
        labelColor = tableColor1,
        onEvent = targetListOpen
    }) 
    myData.targetListButtonAS.anchorX=0.5

    myData.closeBtnAS = widget.newButton(
    {
        left = 20,
        top = display.actualContentHeight - (display.actualContentHeight/15) + topPadding(),
        width = display.contentWidth - 40,
        height = display.actualContentHeight/15-5,
        defaultFile = buttonColor1080,
       -- overFile = "buttonOver.png",
        fontSize = fontSize(80),
        label = "Close",
        labelColor = tableColor1,
        onEvent = close
    })


    --  Show HUD    
    sgroup:insert(myData.scanRect)
    sgroup:insert(myData.targetName)
    sgroup:insert(myData.crewtRect)
    sgroup:insert(myData.crewtText)
    sgroup:insert(myData.fw)
    sgroup:insert(myData.fw.txtb)
    sgroup:insert(myData.fw.txt)
    sgroup:insert(myData.fw.ip)
    sgroup:insert(myData.webExploit)
    sgroup:insert(myData.webText)
    sgroup:insert(myData.appExploit)
    sgroup:insert(myData.appText)
    sgroup:insert(myData.dbExploit)
    sgroup:insert(myData.dbText)
    sgroup:insert(myData.moneyMalware)
    sgroup:insert(myData.moneyText)
    sgroup:insert(myData.botMalware)
    sgroup:insert(myData.botText)
    sgroup:insert(myData.ratMalware)
    sgroup:insert(myData.ratText)
    sgroup:insert(myData.moneyRect)
    sgroup:insert(myData.moneytText)
    sgroup:insert(myData.anonRect)
    sgroup:insert(myData.anontText)
    sgroup:insert(myData.repRect)
    sgroup:insert(myData.reptText)
    sgroup:insert(myData.avRect)
    sgroup:insert(myData.avtText)
    sgroup:insert(myData.gpuRect)
    sgroup:insert(myData.gputText)
    sgroup:insert(myData.malwareRect)
    sgroup:insert(myData.malwaretText)
    sgroup:insert(myData.exploitRect)
    sgroup:insert(myData.exploittText)
    sgroup:insert(myData.ipsRect)
    sgroup:insert(myData.ipstText)
    sgroup:insert(myData.websRect)
    sgroup:insert(myData.webstText)
    sgroup:insert(myData.appsRect)
    sgroup:insert(myData.appstText)
    sgroup:insert(myData.dbsRect)
    sgroup:insert(myData.dbstText)
    sgroup:insert(myData.resultRect)
    sgroup:insert(myData.resultText)
    sgroup:insert(myData.targetListButtonAS)
    sgroup:insert(myData.manualScanButtonAS)
    sgroup:insert(myData.closeBtnAS)

    --  Button Listeners
    myData.webExploit:addEventListener("tap", exploitWebClick)
    myData.appExploit:addEventListener("tap", exploitAppClick)
    myData.dbExploit:addEventListener("tap", exploitDbClick)
    myData.moneyMalware:addEventListener("tap", malwareMoneyClick)
    myData.botMalware:addEventListener("tap", malwareBotClick)
    myData.ratMalware:addEventListener("tap",malwareRatClick)
    myData.closeBtnAS:addEventListener("tap", close)

end

-- Home Show
function scanAttackScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
    if (targetId ~= "NO") then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&target="..targetId.."&data="..string.urlEncode(generateNonce())
        local params = {}
        params.headers = headers
        params.body = body
        network.request( host().."scanTarget.php", "POST", scanListener, params )
        scanRx=false
    else
        text1 = "Target not found!" 
        myData.resultText:setFillColor(0.7,0,0)
        myData.resultText.size=50
        typewriterTimer = timer.performWithDelay(2, typewriterFunction, string.len(text1)) 
        myData.webExploit.alpha=0
        myData.appExploit.alpha=0
        myData.dbExploit.alpha=0
        myData.moneyMalware.alpha=0
        myData.botMalware.alpha=0
        myData.ratMalware.alpha=0
        myData.fw.txtb.alpha=0
    end
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
scanAttackScene:addEventListener( "create", scanAttackScene )
scanAttackScene:addEventListener( "show", scanAttackScene )
---------------------------------------------------------------------------------

return scanAttackScene