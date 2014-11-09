require("extern")
BattleScene = class("BattleScene", function ()
	return CCScene:create()
end)


function BattleScene:ctor()
   self:loadArmature()
   self:initBg()
   self:initButtonLayer()
   self:initPlayer()
end

function BattleScene:loadArmature()
    local adm = CCArmatureDataManager:sharedArmatureDataManager()
    adm:addArmatureFileInfo(P("hero/caocao/caocao.ExportJson"))
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

    self.layer3 = layer3
end

function BattleScene:initPlayer()
    

    local armor = Player:create(self)
    armor:setScale(0.5)
    armor:setPosition(armor:getContentSize().width / 2 * armor:getScaleX() ,20)
    self.layer3:addChild(armor) 
    
    self.player = armor
    self:setViewpointCenter(self.player:getPosition())

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
   
   
   local soldier1 = SummonBtn:create(P("button/soldierbg.png"),P("button/soldierselect.png"),P("head/head001.png"),handler(self, self.onSummonSoldier))
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

   local leftweaponbg = CCSprite:create(P("button/leftweapenbg.png"))
   leftweaponbg:setAnchorPoint(ccp(0, 1))
   leftweaponbg:setPosition(20,weaponbg:getContentSize().height - 10)
   weaponbg:addChild(leftweaponbg)
   
   local lefthandbtn = UITouchButton.new(P("head/normalattack.png"),P("head/normalattack.png"),function()end,handler(self, self.onLeftHandClick))
   lefthandbtn:setAnchorPoint(ccp(0.5, 0.5))
   lefthandbtn:setPosition(leftweaponbg:getContentSize().width/2,leftweaponbg:getContentSize().height/2)
   leftweaponbg:addChild(lefthandbtn)
   
   local rweapon2 =  SummonBtn:create(P("button/rightweapenbg.png"),P("button/gunsel.png"))
   rweapon2:setAnchorPoint(ccp(1, 1))
   rweapon2:setPosition(weaponbg:getContentSize().width -15,leftweaponbg:boundingBox():getMaxY())
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

function BattleScene:onSummonSoldier()
    print("on summon")
end

function BattleScene:onLeft()
    self.player.fsm:doEvent("walkleft")
end

function BattleScene:onRight()
    self.player.fsm:doEvent("walkright")
end

function BattleScene:onStop()
   self.player.fsm:doEvent("stop")
end 

function BattleScene:onLeftHandClick()
  print("left hand")
end

function BattleScene:onGunClick()
  print("gun")
end