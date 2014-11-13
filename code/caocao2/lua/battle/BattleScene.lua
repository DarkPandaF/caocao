math.randomseed(os.time())
require("extern")
BattleScene = class("BattleScene", function ()
	return CCScene:create()
end)


function BattleScene:ctor()
   self:loadArmature()
   self:initBg()
   self:initButtonLayer()
   self:initPlayer()
   self:initTimer()
   
   self.soldierpool = {}
   self.enemypool   = {}
   
   --士兵列表,敌人列表
   self.soldierslist = {}
   self.enemylist = {}
   
   

end

--释放资源
function BattleScene:release()
    for i,v in ipairs(self.soldierpool) do
       v:release()
    end

    for i,v in ipairs(self.enemypool) do
       v:release()
    end

end

function BattleScene:loadArmature()
    local adm = CCArmatureDataManager:sharedArmatureDataManager()
    adm:addArmatureFileInfo(P("hero/caocao/caocao.ExportJson"))
    adm:addArmatureFileInfo(P("hero/caochong/caochong.ExportJson"))
    adm:addArmatureFileInfo(P("hero/zhangrang/zhangrang.ExportJson"))
    adm:addArmatureFileInfo(P("hero/commoneffect/commoneffect.ExportJson"))
end

function BattleScene:initBg()
    
    --初始化背景
    local layer1 = CCLayer:create()
    layer1:setContentSize(CCSize(2000,256))
    for i=1,8 do
        local sp =  CCSprite:create(P("battle/far_01_01.png"))
        sp:setAnchorPoint(ccp(0, 0))
        sp:setPosition((i-1)*sp:getContentSize().width,0)
        layer1:addChild(sp)
    end
    
   
    layer1:ignoreAnchorPointForPosition(false)
    layer1:setAnchorPoint(ccp(0, 1))
    layer1:setPosition(0,WINSIZE.height)
    self:addChild(layer1)
    self.layer1 = layer1

    local layer2 =  CCLayer:create()
    layer2:setContentSize(CCSize(2000,357))
    for i=1,3 do
        local sp = CCSprite:create(P("battle/middle_01_01.png"))
        sp:setAnchorPoint(ccp(0, 0))
        sp:setPosition((i-1)*sp:getContentSize().width,0)
        layer2:addChild(sp)
    end
    
    layer2:ignoreAnchorPointForPosition(false)
    layer2:setAnchorPoint(ccp(0, 1))
    layer2:setPosition(0,WINSIZE.height)
    self:addChild(layer2)
    self.layer2 = layer2
    
    local layer3 =  CCLayer:create()
    layer3:setContentSize(CCSize(2000,217))
    for i=1,5 do
        local sp = CCSprite:create(P("battle/near_01_01.png"))
        sp:setAnchorPoint(ccp(0, 0))
        sp:setPosition((i-1)*sp:getContentSize().width,0)
        layer3:addChild(sp)
    end
    layer3:ignoreAnchorPointForPosition(false)
    layer3:setAnchorPoint(ccp(0, 0))
    layer3:setPosition(0,216)
    self:addChild(layer3)
    
    
    --画格子
    local posy = 122/4
    for i=1,3 do
        local line =  ScutCxControl.ScutLineNode:lineWithPoint(ccp(0, i * posy),ccp(2000, i*posy),1,ccc4(255,255,0,255))
        layer3:addChild(line)  
    end 
    

    self.vpos = {
       [1] = 0.5 * posy ,
       [2] = 1.5 * posy ,
       [3] = 2.5 * posy,
       [4] = 3.5 * posy
    }


    local vsize = 20
    local vcount = math.modf(2000/vsize)
    self.vsize = vsize

    for i=1, vcount do
        local line =  ScutCxControl.ScutLineNode:lineWithPoint(ccp(i*vsize, 0),ccp(i*vsize, 122),1,ccc4(255,255,0,255))
        layer3:addChild(line) 
    end

    

    self.layer3 = layer3
end

function BattleScene:initPlayer()
    local armor = Player:create(self)
    armor:setScale(0.5)
    armor:setPosition(armor:getContentSize().width / 2 * armor:getScaleX() ,self.vpos[3])
    self.layer3:addChild(armor,4-3) 
    
    self.player = armor
    self:setViewpointCenter(self.player:getPosition())

    --坐标ID
    armor.gridindex = self:getGridNum(armor:getPositionX())
    self.player.fsm:doEvent("init")
end

function BattleScene:getCanMovepos(x)
   local pos = ccp(self.player:getPosition())
   local result = ccpAdd(pos, ccp(x, 0))
   local width =  self.player:getContentSize().width / 2 * self.player:getScaleX()
   if result.x >= width  and  result.x <= 2000 - width  then
   else 
      result = pos
   end
   return result   
end

--获得网格ID
function BattleScene:getGridNum(x)
    local num = math.modf(x / self.vsize) 
    num = num + 1
    return num
end


function BattleScene:addEnemyToGrid(enemy,gridindex)
     self.enemylist[gridindex] =  self.enemylist[gridindex]  or {}
     table.insert(self.enemylist[gridindex],enemy)
  
end

function BattleScene:removeEnemyFromGrid(enemy,gridindex)
    local index = 0
    for k,v in pairs(self.enemylist[gridindex]) do
       if enemy == v then
          index = k
          break
       end
    end
    self.enemylist[gridindex][index] = nil
end

function BattleScene:addSoldierToGrid(soldier,gridindex)
    self.soldierslist[gridindex] = self.soldierslist[gridindex] or {}
    table.insert(self.soldierslist[gridindex],soldier)

end

function BattleScene:removeSoldierToGrid(soldier,gridindex)
    local index = 0
    for k,v in pairs(self.soldierslist[gridindex]) do
       if soldier == v then
          index = k
          break
       end
    end
    self.soldierslist[gridindex][index] = nil
end

--居中显示
function BattleScene:setViewpointCenter(x,y)
         
    local pos1 = ccp(self.layer1:getPosition())
    local pos2 = ccp(self.layer2:getPosition())
    local pos3 = ccp(self.layer3:getPosition())


    local lx = math.max(x, WINSIZE.width / 2)
    local ly = math.max(y, WINSIZE.height / 2)
    lx = math.min(lx, 2000 - WINSIZE.width / 2)
    ly = math.min(ly, 217 - 0)
    local actual = ccp(lx, ly)
    local center = ccp(WINSIZE.width / 2 , WINSIZE.height / 2)
    local viewPoint = ccpSub(center,actual)

    self.layer3:setPosition(ccp(viewPoint.x, pos3.y))
    local possub = ccpSub(pos3, ccp(self.layer3:getPosition()))
    
    if possub.x ~= 0 then
        self.layer2:setPosition(ccpSub(pos2,ccp(possub.x/2, 0)))
        self.layer1:setPosition(ccpSub(pos1,ccp(possub.x/3, 0)))       
    end 
end

--创建按钮层
function BattleScene:initButtonLayer()
   
   local btnlayer = CCSprite:create(P("battle/buttonlayer.png"))
   btnlayer:setAnchorPoint(ccp(0, 0))
   self:addChild(btnlayer)
   
   
   local soldier1 = SummonBtn:create(P("button/soldierbg.png"),P("button/soldierselect.png"),P("head/head001.png"),handler(self, self.onSummonSoldier),3)
   soldier1:setAnchorPoint(ccp(0, 1))
   soldier1:setPosition(18,btnlayer:getContentSize().height - 13)
   btnlayer:addChild(soldier1)
   
   local tmpsoldier = soldier1
   for i=1,4 do
      local soldier =  SummonBtn:create(P("button/soldierbg.png"),P("button/soldierselect.png"))
      soldier:setAnchorPoint(ccp(0, 1))
      soldier:setPosition(tmpsoldier:boundingBox():getMaxX(),tmpsoldier:boundingBox():getMaxY())
      btnlayer:addChild(soldier)
      tmpsoldier = soldier
   end


   local weaponbg = CCSprite:create(P("battle/weaponbg.png"))
   weaponbg:setAnchorPoint(ccp(1, 0))
   weaponbg:setPosition(btnlayer:getContentSize().width - 18,8)
   btnlayer:addChild(weaponbg)  
   
   local lweapon = SummonBtn:create(P("button/leftweapenbg.png"),P("button/soldierselect.png"),P("head/normalattack.png"),handler(self, self.onLeftHandClick))
   lweapon:setAnchorPoint(ccp(0, 1))
   lweapon:setPosition(20,weaponbg:getContentSize().height - 10)
   weaponbg:addChild(lweapon)

      
   local rweapon2 =  SummonBtn:create(P("button/rightweapenbg.png"),P("button/gunsel.png"))
   rweapon2:setAnchorPoint(ccp(1, 1))
   rweapon2:setPosition(weaponbg:getContentSize().width -15,lweapon:boundingBox():getMaxY())
   weaponbg:addChild(rweapon2)

   local rweapon1 =  SummonBtn:create(P("button/rightweapenbg.png"),P("button/gunsel.png"),P("head/gunattack1.png"),handler(self, self.onGunClick))
   rweapon1:setAnchorPoint(ccp(1, 1))
   rweapon1:setPosition(rweapon2:boundingBox():getMinX() - 3,rweapon2:boundingBox():getMaxY())
   weaponbg:addChild(rweapon1)

   
   local hllbbg = CCSprite:create(P("button/hlbg.png"))
   hllbbg:setAnchorPoint(ccp(0, 1))
   hllbbg:setPosition(weaponbg:boundingBox():getMinX(),btnlayer:getContentSize().height - 6)
   btnlayer:addChild(hllbbg)

   local hlbar = CCSprite:create(P("button/barbg.png"))
   hlbar:setAnchorPoint(ccp(1, 0.5))
   hlbar:setPosition(weaponbg:boundingBox():getMaxX(),hllbbg:boundingBox():getMidY())
   btnlayer:addChild(hlbar)


   local dylbbg =  CCSprite:create(P("button/dybg.png"))
   dylbbg:setAnchorPoint(ccp(0, 1))
   dylbbg:setPosition(hllbbg:boundingBox():getMinX(),hllbbg:boundingBox():getMinY())
   btnlayer:addChild(dylbbg)
   
   local dybar = CCSprite:create(P("button/barbg.png"))
   dybar:setAnchorPoint(ccp(1, 0.5))
   dybar:setPosition(weaponbg:boundingBox():getMaxX(),dylbbg:boundingBox():getMidY())
   btnlayer:addChild(dybar)
     

   local btnleft = UITouchButton.new(P("button/leftnormal.png"),P("button/leftpress.png"),handler(self, self.onLeft),handler(self, self.onStop)) 
   btnleft:setAnchorPoint(ccp(0.5, 0.5))
   btnleft:setPosition(160,weaponbg:boundingBox():getMidY())
   self:addChild(btnleft)
   
   local btnright = UITouchButton.new(P("button/rightnormal.png"),P("button/rightpress.png"),handler(self, self.onRight),handler(self, self.onStop)) 
   btnright:setAnchorPoint(ccp(0.5, 0.5))
   btnright:setPosition(500-160,weaponbg:boundingBox():getMidY())
   self:addChild(btnright)
end

function BattleScene:getPlayerState()
   return self.player.fsm
end


function BattleScene:getSoldier()
    
    local result = nil 
    for i,v in ipairs(self.soldierpool) do
       if v and not v:getParent() then
          result = v
          break
       end
    end 
    if not result then
       result = Soldier:create("caochong",self)
       result:retain()
       table.insert(self.soldierpool,result)
    end
    return result
end

function BattleScene:getEnemy()
    local result = nil 
    for i,v in ipairs(self.enemypool) do
       if v and not v:getParent() then
          result = v
          break
       end
    end 
    if not result then
       result = Enemy:create("zhangrang",0,self)
       result:retain()
       table.insert(self.enemypool,result)
    end
    return result
end

--召唤士兵
function BattleScene:onSummonSoldier()

    local soldier = self:getSoldier()
    local num = math.random(1,4)
    soldier:setPosition(0,self.vpos[num])
    
    soldier.gridindex = self:getGridNum(soldier:getPositionX())
    self:addSoldierToGrid(soldier, soldier.gridindex)
    
    soldier:initState()
    self.layer3:addChild(soldier,4-num)
end

--创建敌人
function BattleScene:createEnemy()

    self.enemyindex = self.enemyindex or 0 
    local enemy =  self:getEnemy()
    local num = math.random(1,4)
    enemy:setPosition(self.layer3:getContentSize().width,self.vpos[num])

    enemy.gridindex = self:getGridNum(enemy:getPositionX())
    self:addEnemyToGrid(enemy, enemy.gridindex)

    enemy:initEnemyState(self.enemyindex)
    self.layer3:addChild(enemy,4-num)
    self.enemyindex = (self.enemyindex + 1) % 10 
       
    -- if self.timerid ~= -1 then
    --     CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerid)
    --     self.timerid = -1
    --  end 
end

function BattleScene:initTimer()
   self.timerid =  CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(handler(self, self.createEnemy),5,false)
end

--左走
function BattleScene:onLeft()
    if self:getPlayerState():canDoEvent("walkleft") then
       self:getPlayerState():doEvent("walkleft")
    end
end

--右走
function BattleScene:onRight()
    if self:getPlayerState():canDoEvent("walkright") then
       self:getPlayerState():doEvent("walkright")
    end
end

--停止
function BattleScene:onStop()
   if self:getPlayerState():canDoEvent("stop") then
      self:getPlayerState():doEvent("stop")
   end
end 

--左手武器
function BattleScene:onLeftHandClick()
   if self:getPlayerState():canDoEvent("attack") then
      self:getPlayerState():doEvent("attack")
   end
end

--右手武器
function BattleScene:onGunClick()
   if self:getPlayerState():canDoEvent("shoot") then
      self:getPlayerState():doEvent("shoot")
   end
end



