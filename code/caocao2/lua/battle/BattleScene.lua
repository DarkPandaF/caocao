require("extern")
BattleScene = class("BattleScene", function ()
	return CCScene:create()
end)


function BattleScene:ctor()
   self:loadArmature()
   self:initBg()
   self:initPlayer()
   self:initBtn()
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
    layer3:setAnchorPoint(ccp(0, 1))
    layer3:setPosition(0,WINSIZE.height-257)
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


function BattleScene:onLeft()
    self.player.fsm:doEvent("walkleft")
end

function BattleScene:onRight()
    self.player.fsm:doEvent("walkright")
end

function BattleScene:onStop()
   self.player.fsm:doEvent("stop")
end 

function BattleScene:initBtn()
   
   local btnleft = UITouchButton.new(P("button/button_blue_nor.png"),P("button/button_blue_sel.png"),handler(self, self.onLeft),handler(self, self.onStop)) 
   btnleft:setAnchorPoint(ccp(0.5, 0.5))
   btnleft:setPosition(200,50)
   self:addChild(btnleft)
   
   local btnright = UITouchButton.new(P("button/button_red_nor.png"),P("button/button_red_sel.png"),handler(self, self.onRight),handler(self, self.onStop)) 
   btnright:setAnchorPoint(ccp(0.5,0.5))
   btnright:setPosition(400,50)
   self:addChild(btnright)

end