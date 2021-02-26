local widget = require( "widget" )
local composer = require( "composer" )
local json = require ("json")
local myData = require ("mydata")
local playerDetailsScene = composer.newScene()
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> GENERAL FUNCTIONS
---------------------------------------------------------------------------------
local close = function(event)
    backSound()
    detailsOverlay=false
    composer.hideOverlay( "fade",0 )
end

local function onAlert()
end

local function getRowY(rows,row)
    local rowsDiff=90*rows
    local badgeSize=210
    local badgeRow1=myData.playerStats.y+myData.playerStats.height-fontSize(rowsDiff)+badgeSize/2
    local badgeRow2=myData.playerStats.y+myData.playerStats.height-fontSize(rowsDiff)+badgeSize
    local badgeRow3=myData.playerStats.y+myData.playerStats.height-fontSize(rowsDiff)+badgeSize*2
    if (rows==1) then 
        return badgeRow1
    else
        if (row==1) then
            return badgeRow2
        else
            return badgeRow3
        end
    end
end

local function updateBadgeDesc(event)
    tapSound()
    myData.badgeDescription.text=event.target.name
end

local function playerDetailsNetworkListener( event )

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

        local rows=t.rows
        if (rows>0) then
            addHeight=240*rows
            myData.playerRect.height=myData.playerRect.height+addHeight+fontSize(50)
            pdgroup.y=pdgroup.y-(addHeight/2)-fontSize(25)
            myData.playerRect.y=myData.playerRect.y+(addHeight/2)+fontSize(25)
        end

        local playerSkin
        print("SKIN: "..t.skin)
        if (t.skin=="green") then 
            playerSkin={0,0.7,0} 
            playerTone=greenTone
        elseif (t.skin=="blue") then
            playerSkin={0,0.29,0.5}
            playerTone=blueTone
        elseif (t.skin=="red") then
            playerSkin={0.7,0,0}
            playerTone=redTone
        elseif (t.skin=="yellow") then
            playerSkin={0.8,0.8,0.2}
            playerTone=yellowTone 
        elseif (t.skin=="purple") then
            playerSkin={0.64,0.28,0.64}
            playerTone=purpleTone
        elseif (t.skin=="orange") then
            playerSkin={0.8,0.4,0}
            playerTone=orangeTone
        elseif (t.skin=="silver") then
            playerSkin={0.66,0.66,0.66}
            playerTone=silverTone
        elseif (t.skin=="aqua") then
            playerSkin={0.08,0.78,0.72}
            playerTone=aquaTone
        else
            playerSkin={0,0.7,0} 
            playerTone=greenTone
        end      

        local playerPic
        if (t.pic=="0") then
            playerPic= { type="image", filename="img/profile_pic.png" }
        elseif (t.pic=="1") then
            playerPic={ type="image", filename="img/profile_pic_black.png" }
        elseif (t.pic=="2") then
            playerPic={ type="image", filename="img/profile_pic_gray.png" }
        elseif (t.pic=="3") then
            playerPic={ type="image", filename="img/profile_pic_ghost.png" }
        elseif (t.pic=="4") then
            playerPic={ type="image", filename="img/profile_pic_pirate.png" }
        elseif (t.pic=="5") then
            playerPic={ type="image", filename="img/profile_pic_ninja.png" }
        elseif (t.pic=="6") then
            playerPic={ type="image", filename="img/profile_pic_anon.png" }
        elseif (t.pic=="7") then
            playerPic={ type="image", filename="img/profile_pic_cyborg.png" }
        elseif (t.pic=="8") then
            playerPic={ type="image", filename="img/profile_pic_wolf.png" }
        elseif (t.pic=="9") then
            playerPic={ type="image", filename="img/profile_pic_tiger.png" }
        elseif (t.pic=="10") then
            playerPic={ type="image", filename="img/profile_pic_santa.png" }
        elseif (t.pic=="11") then
            playerPic={ type="image", filename="img/profile_pic_gas_mask.png" }
        else
            playerPic= { type="image", filename="img/profile_pic.png" }
        end
        if (t.contact=="N") then
            playerContact= { type="image", filename="img/player_msg_add.png" }
            myData.addBtn.fill=playerContact
            myData.addBtn.active=true
        end

        if (((my_gc_role==1) or (my_gc_role==2)) and (t.gc_role==0)) then
            myData.addBtn.x=myData.addBtn.x+90
            myData.addBtn.width=myData.addBtn.width*0.85
            myData.addBtn.height=myData.addBtn.height*0.85
            changeImgColor(myData.addBtn)
            myData.banBtn.fill.effect="filter.monotone"
            myData.banBtn.fill.effect.r,myData.banBtn.fill.effect.g,myData.banBtn.fill.effect.b=playerTone.r,playerTone.g,playerTone.b
            myData.banBtn.alpha=1
        end

        --Details
        myData.playerRect:setStrokeColor(playerSkin[1],playerSkin[2],playerSkin[3])
        myData.playerImg.fill=playerPic
        myData.closeBtn.fill.effect="filter.monotone"
        myData.closeBtn.fill.effect.r,myData.closeBtn.fill.effect.g,myData.closeBtn.fill.effect.b=playerTone.r,playerTone.g,playerTone.b
        myData.addBtn.fill.effect="filter.monotone"
        myData.addBtn.fill.effect.r,myData.addBtn.fill.effect.g,myData.addBtn.fill.effect.b=playerTone.r,playerTone.g,playerTone.b
        myData.playerName.text = t.username
        if (string.len(t.username)>15) then myData.playerName.size = fontSize(60) end
        if (t.tag~="") then
            myData.playerTag.text = "("..t.tag..")\nLevel "..t.lvl
        else
            myData.playerTag.text = "\nLevel "..t.lvl
        end
        myData.playerStats.text = "Rank: "..format_thousand(t.rank).."\nScore: "..format_thousand(t.score).."\nRep: "..format_thousand(t.rep).."\n"
        if (t.tournament_best==1) then
            myData.playerStats.text=myData.playerStats.text.."\nTournaments Won: "..t.tournament_won
        elseif (t.tournament_best==0) then
            myData.playerStats.text=myData.playerStats.text
        else
            myData.playerStats.text=myData.playerStats.text.."\nBest Tournaments Rank: "..t.tournament_best
        end

        local badgeSize=200

        --Badges
        local badgeColumn=0
        local badgeRow=getRowY(rows,1)

        if (t.betaBadge>0) then
            if (t.betaBadge==1) then
                myData.betaBadge = display.newImageRect( "img/badge_beta_bronze.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.betaBadge.anchorX = 0
                myData.betaBadge.anchorY = 0
                myData.betaBadge.x, myData.betaBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.betaBadge.name="Beta Tester - 1 Month"
                pdgroup:insert(myData.betaBadge)
            elseif (t.betaBadge==2) then
                myData.betaBadge = display.newImageRect( "img/badge_beta_silver.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.betaBadge.anchorX = 0
                myData.betaBadge.anchorY = 0
                myData.betaBadge.x, myData.betaBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.betaBadge.name="Beta Tester - 3 Months"
                pdgroup:insert(myData.betaBadge)
            elseif (t.betaBadge==3) then
                myData.betaBadge = display.newImageRect( "img/badge_beta_gold.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.betaBadge.anchorX = 0
                myData.betaBadge.anchorY = 0
                myData.betaBadge.x, myData.betaBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.betaBadge.name="Beta Tester - 5 Months"
                pdgroup:insert(myData.betaBadge)
            end
            myData.betaBadge:addEventListener("tap",updateBadgeDesc)
            badgeColumn=badgeColumn+1
        end

        if (t.loyalBadge>0) then
            if (t.loyalBadge==1) then
                myData.loyalBadge = display.newImageRect( "img/badge_loyal_bronze.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.loyalBadge.anchorX = 0
                myData.loyalBadge.anchorY = 0
                myData.loyalBadge.x, myData.loyalBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.loyalBadge.name="Loyal - 3 Months"
                pdgroup:insert(myData.loyalBadge)
            elseif (t.loyalBadge==2) then
                myData.loyalBadge = display.newImageRect( "img/badge_loyal_silver.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.loyalBadge.anchorX = 0
                myData.loyalBadge.anchorY = 0
                myData.loyalBadge.x, myData.loyalBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.loyalBadge.name="Loyal - 6 Months"
                pdgroup:insert(myData.loyalBadge)
            elseif (t.loyalBadge==3) then
                myData.loyalBadge = display.newImageRect( "img/badge_loyal_gold.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.loyalBadge.anchorX = 0
                myData.loyalBadge.anchorY = 0
                myData.loyalBadge.x, myData.loyalBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.loyalBadge.name="Loyal - 1 Year"
                pdgroup:insert(myData.loyalBadge)
            end
            myData.loyalBadge:addEventListener("tap",updateBadgeDesc)
            badgeColumn=badgeColumn+1
        end

        if (t.addictedBadge>0) then
            if (t.addictedBadge==1) then
                myData.addictedBadge = display.newImageRect( "img/badge_login_bronze.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.addictedBadge.anchorX = 0
                myData.addictedBadge.anchorY = 0
                myData.addictedBadge.x, myData.addictedBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.addictedBadge.name="Addicted - 30 Days"
                pdgroup:insert(myData.addictedBadge)
            elseif (t.addictedBadge==2) then
                myData.addictedBadge = display.newImageRect( "img/badge_login_silver.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.addictedBadge.anchorX = 0
                myData.addictedBadge.anchorY = 0
                myData.addictedBadge.x, myData.addictedBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.addictedBadge.name="Addicted - 60 Days"
                pdgroup:insert(myData.addictedBadge)
            elseif (t.addictedBadge==3) then
                myData.addictedBadge = display.newImageRect( "img/badge_login_gold.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.addictedBadge.anchorX = 0
                myData.addictedBadge.anchorY = 0
                myData.addictedBadge.x, myData.addictedBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.addictedBadge.name="Addicted - 100 Days"
                pdgroup:insert(myData.addictedBadge)
            end
            myData.addictedBadge:addEventListener("tap",updateBadgeDesc)
            badgeColumn=badgeColumn+1
        end

        if (t.attackerBadge>0) then
            if (t.attackerBadge==1) then
                myData.attackerBadge = display.newImageRect( "img/badge_attacker_bronze.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.attackerBadge.anchorX = 0
                myData.attackerBadge.anchorY = 0
                myData.attackerBadge.x, myData.attackerBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.attackerBadge.name="Attacker - 10k Won"
                pdgroup:insert(myData.attackerBadge)
            elseif (t.attackerBadge==2) then
                myData.attackerBadge = display.newImageRect( "img/badge_attacker_silver.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.attackerBadge.anchorX = 0
                myData.attackerBadge.anchorY = 0
                myData.attackerBadge.x, myData.attackerBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.attackerBadge.name="Attacker - 25k Won"
                pdgroup:insert(myData.attackerBadge)
            elseif (t.attackerBadge==3) then
                myData.attackerBadge = display.newImageRect( "img/badge_attacker_gold.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.attackerBadge.anchorX = 0
                myData.attackerBadge.anchorY = 0
                myData.attackerBadge.x, myData.attackerBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.attackerBadge.name="Attacker - 50k Won"
                pdgroup:insert(myData.attackerBadge)
            end
            myData.attackerBadge:addEventListener("tap",updateBadgeDesc)
            badgeColumn=badgeColumn+1
            if (badgeColumn==4) then 
                badgeColumn=0
                badgeRow=getRowY(rows,2)
            end
        end

        if (t.tournamentBadge>0) then
            if (t.tournamentBadge==1) then
                myData.tournamentBadge = display.newImageRect( "img/badge_tournament_bronze.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.tournamentBadge.anchorX = 0
                myData.tournamentBadge.anchorY = 0
                myData.tournamentBadge.x, myData.tournamentBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.tournamentBadge.name="Tournament Legend - 25 Won"
                pdgroup:insert(myData.tournamentBadge)
            elseif (t.tournamentBadge==2) then
                myData.tournamentBadge = display.newImageRect( "img/badge_tournament_silver.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.tournamentBadge.anchorX = 0
                myData.tournamentBadge.anchorY = 0
                myData.tournamentBadge.x, myData.tournamentBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.tournamentBadge.name="Tournament Legend - 50 Won"
                pdgroup:insert(myData.tournamentBadge)
            elseif (t.tournamentBadge==3) then
                myData.tournamentBadge = display.newImageRect( "img/badge_tournament_gold.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.tournamentBadge.anchorX = 0
                myData.tournamentBadge.anchorY = 0
                myData.tournamentBadge.x, myData.tournamentBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.tournamentBadge.name="Tournament Legend - 100 Won"
                pdgroup:insert(myData.tournamentBadge)
            end
            myData.tournamentBadge:addEventListener("tap",updateBadgeDesc)
            badgeColumn=badgeColumn+1
            if (badgeColumn==4) then 
                badgeColumn=0
                badgeRow=getRowY(rows,2)
            end
        end

        if (t.missionBadge>0) then
            if (t.missionBadge==1) then
                myData.missionBadge = display.newImageRect( "img/badge_mission_bronze.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.missionBadge.anchorX = 0
                myData.missionBadge.anchorY = 0
                myData.missionBadge.x, myData.missionBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.missionBadge.name="Mission Collector - 100 Missions"
                pdgroup:insert(myData.missionBadge)
            elseif (t.missionBadge==2) then
                myData.missionBadge = display.newImageRect( "img/badge_mission_silver.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.missionBadge.anchorX = 0
                myData.missionBadge.anchorY = 0
                myData.missionBadge.x, myData.missionBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.missionBadge.name="Mission Collector - 500 Missions"
                pdgroup:insert(myData.missionBadge)
            elseif (t.missionBadge==3) then
                myData.missionBadge = display.newImageRect( "img/badge_mission_gold.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.missionBadge.anchorX = 0
                myData.missionBadge.anchorY = 0
                myData.missionBadge.x, myData.missionBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.missionBadge.name="Mission Collector - 1000 Missions"
                pdgroup:insert(myData.missionBadge)
            end
            myData.missionBadge:addEventListener("tap",updateBadgeDesc)
            badgeColumn=badgeColumn+1
            if (badgeColumn==4) then 
                badgeColumn=0
                badgeRow=getRowY(rows,2)
            end
        end

        if (t.supporterBadge>0) then
            if (t.supporterBadge==1) then
                myData.supporterBadge = display.newImageRect( "img/badge_supporter_bronze.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.supporterBadge.anchorX = 0
                myData.supporterBadge.anchorY = 0
                myData.supporterBadge.x, myData.supporterBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.supporterBadge.name="Bronze Supporter"
                pdgroup:insert(myData.supporterBadge)
            elseif (t.supporterBadge==2) then
                myData.supporterBadge = display.newImageRect( "img/badge_supporter_silver.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.supporterBadge.anchorX = 0
                myData.supporterBadge.anchorY = 0
                myData.supporterBadge.x, myData.supporterBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.supporterBadge.name="Silver Supporter"
                pdgroup:insert(myData.supporterBadge)

                myData.supporterSign = display.newImageRect( "img/supporter_silver.png", fontSize(300),fontSize(70))
                myData.supporterSign.anchorX = 0.5
                myData.supporterSign.anchorY = 0
                myData.supporterSign.x, myData.supporterSign.y = myData.playerImg.x+myData.playerImg.width/2,myData.playerImg.y+myData.playerImg.height-10
                pdgroup:insert(myData.supporterSign)
            elseif (t.supporterBadge==3) then
                myData.supporterBadge = display.newImageRect( "img/badge_supporter_gold.png",fontSize(badgeSize),fontSize(badgeSize) )
                myData.supporterBadge.anchorX = 0
                myData.supporterBadge.anchorY = 0
                myData.supporterBadge.x, myData.supporterBadge.y = myData.playerRect.x+(badgeSize*badgeColumn)+70+(30*badgeColumn),badgeRow
                myData.supporterBadge.name="Gold Supporter"
                pdgroup:insert(myData.supporterBadge)

                myData.supporterSign = display.newImageRect( "img/supporter_gold.png", fontSize(300),fontSize(70))
                myData.supporterSign.anchorX = 0.5
                myData.supporterSign.anchorY = 0
                myData.supporterSign.x, myData.supporterSign.y = myData.playerImg.x+myData.playerImg.width/2,myData.playerImg.y+myData.playerImg.height-10
                pdgroup:insert(myData.supporterSign)
            end
            myData.supporterBadge:addEventListener("tap",updateBadgeDesc)
            badgeColumn=badgeColumn+1
            if (badgeColumn==4) then 
                badgeColumn=0
                badgeRow=getRowY(rows,2)
            end
        end

        myData.badgeDescription=display.newText( "", 0, 0, native.systemFont, fontSize(50) )
        myData.badgeDescription.anchorX=0.5
        myData.badgeDescription.anchorY=0
        myData.badgeDescription.x =  display.contentWidth/2
        myData.badgeDescription.y = badgeRow+badgeSize+fontSize(20)
        myData.badgeDescription:setTextColor( 0.9, 0.9, 0.9 )
        pdgroup:insert(myData.badgeDescription)

    end
end

local function sendMsgRequestListener( event )
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

        if (t.status == "AS") then
            local alert = native.showAlert( "EliteHax", "Request already sent!", { "Close" } )
        end

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Request sent!", { "Close" } )    
        end
    end
end

local function sendRequest(event)
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&username="..string.urlEncode(params.id)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."sendMsgRequest.php", "POST", sendMsgRequestListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function sendMsgRequest(event)
    if (myData.addBtn.active==false) then
        backSound()
        local alert = native.showAlert( "EliteHax", params.id.." is already on your contact list", { "Close" } )
    else
        tapSound()
        local alert = native.showAlert( "EliteHax", "Do you want to send a contact request to "..params.id.."?", { "Yes", "No"}, sendRequest )
    end
end

local function banListener( event )
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

        if (t.status == "OK") then
            local alert = native.showAlert( "EliteHax", "Banned!", { "Close" } )    
        end
    end
end

local function ban(event)
    local i = event.index
    if ( i == 1 ) then
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&username="..string.urlEncode(params.id)
        local params = {}
        params.headers = headers
        params.body = body
        tapSound()
        network.request( host().."ban.php", "POST", banListener, params )
    elseif ( i == 2 ) then
        backSound()
    end
end

local function banConfirm(event)
    tapSound()
    local alert = native.showAlert( "EliteHax", "Do you want to ban "..params.id.."?", { "Yes", "No"}, ban )
end

---------------------------------------------------------------------------------
--> SCENE EVENTS
---------------------------------------------------------------------------------
--  Scene Creation
function playerDetailsScene:create(event)
    pdgroup = self.view
    params = event.params

    my_gc_role = params.my_gc_role

    loginInfo = localToken()

    diconSize=250

    myData.playerRect = display.newRoundedRect( 40, display.actualContentHeight/2, display.contentWidth-70, display.actualContentHeight /2.25, 12 )
    myData.playerRect.anchorX = 0
    myData.playerRect.anchorY = 0.5
    myData.playerRect.strokeWidth = 5
    myData.playerRect:setFillColor( 0,0,0 )
    myData.playerRect:setStrokeColor( strokeColor1[1], strokeColor1[2], strokeColor1[3] )

    -- Player Image
    myData.playerImg = display.newImageRect( "img/profile_pic.png",fontSize(300),fontSize(300) )
    myData.playerImg.anchorX = 0
    myData.playerImg.anchorY = 0
    myData.playerImg.x, myData.playerImg.y = myData.playerRect.x+20,myData.playerRect.y+-myData.playerRect.height/2+fontSize(80)

    -- player Name
    myData.playerName = display.newText( "", 0, 0, native.systemFont, fontSize(70) )
    myData.playerName.anchorX=0
    myData.playerName.anchorY=0
    myData.playerName.x =  myData.playerImg.x+myData.playerImg.width+30
    myData.playerName.y = myData.playerRect.y-myData.playerRect.height/2+fontSize(110)
    myData.playerName:setTextColor( 0.9, 0.9, 0.9 )

    -- player Tag
    myData.playerTag = display.newText( "", 0, 0, native.systemFont, fontSize(70) )
    myData.playerTag.anchorX=0
    myData.playerTag.anchorY=0
    myData.playerTag.x =  myData.playerName.x
    myData.playerTag.y = myData.playerName.y+myData.playerName.height+fontSize(15)
    myData.playerTag:setTextColor( 0.9, 0.9, 0.9 )

    -- player Desc
    myData.playerDesc = display.newText( "", 0, 0, native.systemFont, fontSize(60) )
    myData.playerDesc.anchorX=0.5
    myData.playerDesc.anchorY=0
    myData.playerDesc.x =  display.contentWidth/2
    myData.playerDesc.y = myData.playerTag.y+myData.playerTag.height+fontSize(50)
    myData.playerDesc:setTextColor( 0.9, 0.9, 0.9 )

    -- player Stats
    myData.playerStats = display.newText( "", 0, 0, native.systemFont, fontSize(58) )
    myData.playerStats.anchorX=0
    myData.playerStats.anchorY=0
    myData.playerStats.x =  80
    myData.playerStats.y = myData.playerDesc.y+myData.playerDesc.height+fontSize(50)
    myData.playerStats:setTextColor( 0.9, 0.9, 0.9 )

    -- Add Button
    myData.addBtn = display.newImageRect( "img/player_msg_added.png",300,200 )
    myData.addBtn.anchorX = 0
    myData.addBtn.anchorY = 0
    myData.addBtn.x, myData.addBtn.y = myData.playerTag.x+300, myData.playerStats.y+fontSize(40)
    myData.addBtn.active=false

    -- Ban Button
    myData.banBtn = display.newImageRect( "img/ban.png",255,170 )
    myData.banBtn.anchorX = 0
    myData.banBtn.anchorY = 0
    myData.banBtn.x, myData.banBtn.y = myData.playerTag.x+130, myData.playerStats.y+fontSize(40)
    myData.banBtn.alpha=0
    myData.banBtn.active=false

    -- Close Button
    myData.closeBtn = display.newImageRect( "img/x.png",diconSize/2.5,diconSize/2.5 )
    myData.closeBtn.anchorX = 1
    myData.closeBtn.anchorY = 0
    myData.closeBtn.x, myData.closeBtn.y = myData.playerRect.width+20, myData.playerRect.y-myData.playerRect.height/2+20
    changeImgColor(myData.closeBtn)

    --  Show HUD    
    pdgroup:insert(myData.playerRect)
    pdgroup:insert(myData.playerImg)
    pdgroup:insert(myData.playerName)
    pdgroup:insert(myData.playerTag)
    pdgroup:insert(myData.playerDesc)
    pdgroup:insert(myData.playerStats)
    pdgroup:insert(myData.addBtn)
    pdgroup:insert(myData.banBtn)
    pdgroup:insert(myData.closeBtn)

    --  Button Listeners
    myData.addBtn:addEventListener("tap", sendMsgRequest)
    myData.banBtn:addEventListener("tap", banConfirm)
    myData.closeBtn:addEventListener("tap", close)

end

-- Home Show
function playerDetailsScene:show(event)
    local taskpdgroup = self.view
    if event.phase == "will" then
        -- Called when the scene is still off screen (but is about to come on screen).
        local headers = {}
        local body = "id="..string.urlEncode(loginInfo.token).."&player_id="..string.urlEncode(params.id)
        local params = {}
        params.headers = headers
        params.body = body
        print(body)
        network.request( host().."getPlayerDetails.php", "POST", playerDetailsNetworkListener, params )
    end

    if event.phase == "did" then
        --      
    end
end
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--> Listener setup
---------------------------------------------------------------------------------
playerDetailsScene:addEventListener( "create", playerDetailsScene )
playerDetailsScene:addEventListener( "show", playerDetailsScene )
---------------------------------------------------------------------------------

return playerDetailsScene