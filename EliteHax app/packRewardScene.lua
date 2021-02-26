local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local packRewardScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    rewardOverlay=false
    backSound()
    composer.hideOverlay( "fade", 400 )
end

local function onAlert()
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function packRewardScene:create(event)
    sgroup = self.view
    params = event.params

    iconSize=200

    local rectSize=0
    if (params.type == "sp") then rectSize=fontSize(840)
    elseif (params.type == "mp") then rectSize=fontSize(990)
    elseif (params.type == "lp") then rectSize=fontSize(1140)
    elseif (params.type == "sm") then rectSize=fontSize(370)
    elseif (params.type == "mm") then rectSize=fontSize(370)
    elseif (params.type == "lm") then rectSize=fontSize(370)
    elseif (params.type == "so") then rectSize=fontSize(370)
    elseif (params.type == "mo") then rectSize=fontSize(370)
    elseif (params.type == "lo") then rectSize=fontSize(370) end

    if ((params.type=="sp") or (params.type=="mp") or (params.type=="lp")) then
        myData.rewardRect = display.newImageRect( "img/pack_reward.png",display.contentWidth-70,rectSize )
        myData.rewardRect.anchorX = 0.5
        myData.rewardRect.anchorY = 0.5
        myData.rewardRect.x, myData.rewardRect.y = display.contentWidth/2,display.actualContentHeight/2
        changeImgColor(myData.rewardRect)
        sgroup:insert(myData.rewardRect)

        -- Antivirus Rect
        myData.avRect = display.newImageRect( "img/terminal_antivirus.png",235,fontSize(120) )
        myData.avRect.anchorX = 0
        myData.avRect.anchorY = 0
        myData.avRect.x, myData.avRect.y = myData.rewardRect.x-myData.rewardRect.width/2+35, myData.rewardRect.y-myData.rewardRect.height/2+fontSize(140)
        myData.avtText = display.newText("+"..params.av,myData.avRect.x+myData.avRect.width/2+20,myData.avRect.y+myData.avRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.avtText.anchorX = 0.5
        myData.avtText.anchorY = 0.5 

        -- GPU Rect
        myData.gpuRect = display.newImageRect( "img/terminal_gpu.png",235,fontSize(120) )
        myData.gpuRect.anchorX = 0
        myData.gpuRect.anchorY = 0
        myData.gpuRect.x, myData.gpuRect.y = myData.avRect.x+myData.avRect.width, myData.avRect.y
        myData.gputText = display.newText("+"..params.gpu,myData.gpuRect.x+myData.gpuRect.width/2+20,myData.gpuRect.y+myData.gpuRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.gputText.anchorX = 0.5
        myData.gputText.anchorY = 0.5 

        -- Malware Rect
        myData.malwareRect = display.newImageRect( "img/terminal_malware.png",235,fontSize(120) )
        myData.malwareRect.anchorX = 0
        myData.malwareRect.anchorY = 0
        myData.malwareRect.x, myData.malwareRect.y = myData.gpuRect.x+myData.gpuRect.width, myData.avRect.y
        myData.malwaretText = display.newText("+"..params.malware,myData.malwareRect.x+myData.malwareRect.width/2+20,myData.malwareRect.y+myData.malwareRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.malwaretText.anchorX = 0.5
        myData.malwaretText.anchorY = 0.5 

        -- Exploit Rect
        myData.exploitRect = display.newImageRect( "img/terminal_exploit.png",235,fontSize(120) )
        myData.exploitRect.anchorX = 0
        myData.exploitRect.anchorY = 0
        myData.exploitRect.x, myData.exploitRect.y = myData.malwareRect.x+myData.malwareRect.width, myData.avRect.y
        myData.exploittText = display.newText("+"..params.exploit,myData.exploitRect.x+myData.exploitRect.width/2+20,myData.exploitRect.y+myData.exploitRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.exploittText.anchorX = 0.5
        myData.exploittText.anchorY = 0.5 

        -- IPS Rect
        myData.ipsRect = display.newImageRect( "img/terminal_ips.png",235,fontSize(120) )
        myData.ipsRect.anchorX = 0
        myData.ipsRect.anchorY = 0
        myData.ipsRect.x, myData.ipsRect.y = myData.rewardRect.x-myData.rewardRect.width/2+35, myData.avRect.y+myData.avRect.height
        myData.ipstText = display.newText("+"..params.ips,myData.ipsRect.x+myData.ipsRect.width/2+20,myData.ipsRect.y+myData.ipsRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.ipstText.anchorX = 0.5
        myData.ipstText.anchorY = 0.5 

        -- Web Server Rect
        myData.websRect = display.newImageRect( "img/terminal_webs.png",235,fontSize(120) )
        myData.websRect.anchorX = 0
        myData.websRect.anchorY = 0
        myData.websRect.x, myData.websRect.y = myData.ipsRect.x+myData.ipsRect.width, myData.ipsRect.y
        myData.webstText = display.newText("+"..params.webs,myData.websRect.x+myData.websRect.width/2+20,myData.websRect.y+myData.websRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.webstText.anchorX = 0.5
        myData.webstText.anchorY = 0.5 

        -- App Server Rect
        myData.appsRect = display.newImageRect( "img/terminal_apps.png",235,fontSize(120) )
        myData.appsRect.anchorX = 0
        myData.appsRect.anchorY = 0
        myData.appsRect.x, myData.appsRect.y = myData.websRect.x+myData.websRect.width, myData.ipsRect.y
        myData.appstText = display.newText("+"..params.apps,myData.appsRect.x+myData.appsRect.width/2+20,myData.appsRect.y+myData.appsRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.appstText.anchorX = 0.5
        myData.appstText.anchorY = 0.5 

        -- DB Server Rect
        myData.dbsRect = display.newImageRect( "img/terminal_dbs.png",235,fontSize(120) )
        myData.dbsRect.anchorX = 0
        myData.dbsRect.anchorY = 0
        myData.dbsRect.x, myData.dbsRect.y = myData.appsRect.x+myData.appsRect.width, myData.ipsRect.y
        myData.dbstText = display.newText("+"..params.dbs,myData.dbsRect.x+myData.dbsRect.width/2+20,myData.dbsRect.y+myData.dbsRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.dbstText.anchorX = 0.5
        myData.dbstText.anchorY = 0.5 

        -- Firewall Rect
        myData.fwRect = display.newImageRect( "img/terminal_firewall.png",235,fontSize(120) )
        myData.fwRect.anchorX = 0
        myData.fwRect.anchorY = 0
        myData.fwRect.x, myData.fwRect.y = myData.rewardRect.x-myData.rewardRect.width/2+35, myData.ipsRect.y+myData.ipsRect.height
        myData.fwtText = display.newText("+"..params.firewall,myData.fwRect.x+myData.fwRect.width/2+20,myData.fwRect.y+myData.fwRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.fwtText.anchorX = 0.5
        myData.fwtText.anchorY = 0.5 

        -- SIEM Rect
        myData.siemRect = display.newImageRect( "img/terminal_siem.png",235,fontSize(120) )
        myData.siemRect.anchorX = 0
        myData.siemRect.anchorY = 0
        myData.siemRect.x, myData.siemRect.y = myData.ipsRect.x+myData.ipsRect.width, myData.fwRect.y
        myData.siemtText = display.newText("+"..params.siem,myData.siemRect.x+myData.siemRect.width/2+20,myData.siemRect.y+myData.siemRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.siemtText.anchorX = 0.5
        myData.siemtText.anchorY = 0.5 

        -- Anon Rect
        myData.anonRect = display.newImageRect( "img/terminal_anonymizer.png",235,fontSize(120) )
        myData.anonRect.anchorX = 0
        myData.anonRect.anchorY = 0
        myData.anonRect.x, myData.anonRect.y = myData.websRect.x+myData.websRect.width, myData.fwRect.y
        myData.anontText = display.newText("+"..params.anon,myData.anonRect.x+myData.anonRect.width/2+20,myData.anonRect.y+myData.anonRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.anontText.anchorX = 0.5
        myData.anontText.anchorY = 0.5 

        -- Scan Rect
        myData.scannerRect = display.newImageRect( "img/terminal_scanner.png",235,fontSize(120) )
        myData.scannerRect.anchorX = 0
        myData.scannerRect.anchorY = 0
        myData.scannerRect.x, myData.scannerRect.y = myData.appsRect.x+myData.appsRect.width, myData.fwRect.y
        myData.scannertText = display.newText("+"..params.scan,myData.scannerRect.x+myData.scannerRect.width/2+20,myData.scannerRect.y+myData.scannerRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.scannertText.anchorX = 0.5
        myData.scannertText.anchorY = 0.5 

        -- Money Rect
        myData.moneyRect = display.newImageRect( "img/terminal_money.png",400,fontSize(120) )
        myData.moneyRect.anchorX = 0.5
        myData.moneyRect.anchorY = 0
        myData.moneyRect.x, myData.moneyRect.y = myData.rewardRect.x, myData.scannerRect.y+myData.scannerRect.height+10
        myData.moneytText = display.newText("+"..format_thousand(params.new_money),myData.moneyRect.x+20,myData.moneyRect.y+myData.moneyRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.moneytText.anchorX = 0.5
        myData.moneytText.anchorY = 0.5

        -- Overclock Rect
        myData.overclockRect = display.newImageRect( "img/reward_overclock.png",400,fontSize(120) )
        myData.overclockRect.anchorX = 0.5
        myData.overclockRect.anchorY = 0
        myData.overclockRect.x, myData.overclockRect.y = myData.rewardRect.x, myData.moneyRect.y+myData.moneyRect.height+10
        myData.overclocktText = display.newText("+"..format_thousand(params.overclock),myData.overclockRect.x+20,myData.overclockRect.y+myData.overclockRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.overclocktText.anchorX = 0.5
        myData.overclocktText.anchorY = 0.5  

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
        sgroup:insert(myData.fwRect)
        sgroup:insert(myData.fwtText)
        sgroup:insert(myData.siemRect)
        sgroup:insert(myData.siemtText)
        sgroup:insert(myData.anonRect)
        sgroup:insert(myData.anontText)
        sgroup:insert(myData.scannerRect)
        sgroup:insert(myData.scannertText)
        sgroup:insert(myData.moneyRect)
        sgroup:insert(myData.moneytText)
        sgroup:insert(myData.overclockRect)
        sgroup:insert(myData.overclocktText)
    elseif ((params.type=="sm") or (params.type=="mm") or (params.type=="lm")) then
        myData.rewardRect = display.newImageRect( "img/money_reward.png",display.contentWidth-70,rectSize )
        myData.rewardRect.anchorX = 0.5
        myData.rewardRect.anchorY = 0.5
        myData.rewardRect.x, myData.rewardRect.y = display.contentWidth/2,display.actualContentHeight/2
        sgroup:insert(myData.rewardRect)

        -- Money Rect
        myData.moneyRect = display.newImageRect( "img/terminal_money.png",500,fontSize(180) )
        myData.moneyRect.anchorX = 0.5
        myData.moneyRect.anchorY = 0
        myData.moneyRect.x, myData.moneyRect.y = myData.rewardRect.x, myData.rewardRect.y-myData.rewardRect.height/2+fontSize(110)
        myData.moneytText = display.newText("+"..format_thousand(params.new_money),myData.moneyRect.x+20,myData.moneyRect.y+myData.moneyRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.moneytText.anchorX = 0.5
        myData.moneytText.anchorY = 0.5 
        sgroup:insert(myData.moneyRect)
        sgroup:insert(myData.moneytText)
    elseif ((params.type=="so") or (params.type=="mo") or (params.type=="lo")) then
        myData.rewardRect = display.newImageRect( "img/money_reward.png",display.contentWidth-70,rectSize )
        myData.rewardRect.anchorX = 0.5
        myData.rewardRect.anchorY = 0.5
        myData.rewardRect.x, myData.rewardRect.y = display.contentWidth/2,display.actualContentHeight/2
        sgroup:insert(myData.rewardRect)

        -- Money Rect
        myData.moneyRect = display.newImageRect( "img/reward_overclock.png",570,fontSize(180) )
        myData.moneyRect.anchorX = 0.5
        myData.moneyRect.anchorY = 0
        myData.moneyRect.x, myData.moneyRect.y = myData.rewardRect.x, myData.rewardRect.y-myData.rewardRect.height/2+fontSize(110)
        myData.moneytText = display.newText("+"..format_thousand(params.new_overclock),myData.moneyRect.x+20,myData.moneyRect.y+myData.moneyRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.moneytText.anchorX = 0.5
        myData.moneytText.anchorY = 0.5 
        sgroup:insert(myData.moneyRect)
        sgroup:insert(myData.moneytText)
    end

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",iconSize/3.1,iconSize/3.1 )
    myData.closeBtn.anchorX = 1
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.rewardRect.width, myData.rewardRect.y-myData.rewardRect.height/2+fontSize(65)
    changeImgColor(myData.closeBtn)

    --  Show HUD    

    sgroup:insert(myData.closeBtn)

    if (params.type == "mp") or (params.type=="lp") then
        -- CC Rect
        myData.ccRect = display.newImageRect( "img/terminal_cryptocoins.png",400,fontSize(120) )
        myData.ccRect.anchorX = 0.5
        myData.ccRect.anchorY = 0
        myData.ccRect.x, myData.ccRect.y = myData.rewardRect.x, myData.overclockRect.y+myData.overclockRect.height+20
        myData.cctText = display.newText("+"..params.new_cc,myData.ccRect.x+20,myData.ccRect.y+myData.ccRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.cctText.anchorX = 0.5
        myData.cctText.anchorY = 0.5
        sgroup:insert(myData.ccRect)
        sgroup:insert(myData.cctText) 
    end

    if (params.type=="lp") then
        -- SP Rect
        myData.spRect = display.newImageRect( "img/terminal_sp.png",260,fontSize(120) )
        myData.spRect.anchorX = 0.5
        myData.spRect.anchorY = 0
        myData.spRect.x, myData.spRect.y = myData.rewardRect.x-myData.spRect.width-20, myData.ccRect.y+myData.ccRect.height+20
        changeImgColor(myData.spRect)
        myData.sptText = display.newText("+"..params.new_sp,myData.spRect.x+20,myData.spRect.y+myData.spRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.sptText.anchorX = 0.5
        myData.sptText.anchorY = 0.5
        sgroup:insert(myData.spRect)
        sgroup:insert(myData.sptText) 

        -- MP Rect
        myData.mpRect = display.newImageRect( "img/terminal_mp.png",260,fontSize(120) )
        myData.mpRect.anchorX = 0.5
        myData.mpRect.anchorY = 0
        myData.mpRect.x, myData.mpRect.y = myData.rewardRect.x, myData.ccRect.y+myData.ccRect.height+20
        changeImgColor(myData.mpRect)
        myData.mptText = display.newText("+"..params.new_mp,myData.mpRect.x+20,myData.mpRect.y+myData.mpRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.mptText.anchorX = 0.5
        myData.mptText.anchorY = 0.5
        sgroup:insert(myData.mpRect)
        sgroup:insert(myData.mptText) 

        -- LP Rect
        myData.lpRect = display.newImageRect( "img/terminal_lp.png",260,fontSize(120) )
        myData.lpRect.anchorX = 0.5
        myData.lpRect.anchorY = 0
        myData.lpRect.x, myData.lpRect.y = myData.mpRect.x+myData.mpRect.width+20, myData.ccRect.y+myData.ccRect.height+20
        changeImgColor(myData.lpRect)
        myData.lptText = display.newText("+"..params.new_lp,myData.lpRect.x+20,myData.lpRect.y+myData.lpRect.height/2+10 ,native.systemFont, fontSize(50))
        myData.lptText.anchorX = 0.5
        myData.lptText.anchorY = 0.5
        sgroup:insert(myData.lpRect)
        sgroup:insert(myData.lptText) 
    end

    --  Button Listeners
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function packRewardScene:show(event)
    local taskGroup = self.view
    if event.phase == "will" then
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
packRewardScene:addEventListener( "create", packRewardScene )
packRewardScene:addEventListener( "show", packRewardScene )
---------------------------------------------------------------------------------

return packRewardScene