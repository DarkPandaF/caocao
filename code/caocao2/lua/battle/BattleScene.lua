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
    local armor = CCArmature:create("caocao")
    armor:getAnimation():play("idle",-1,-1,1)
    armor:setPosition(100,10)
    armor:setScale(0.5)
    self.layer3:addChild(armor)

    self.player = armor
end

function BattleScene:onLeft() 
   self.player:setScaleX(-0.5)
   self.player:getAnimation():play("walk",-1,-1,1)
end

function BattleScene:onRight()
   self.player:setScale(0.5)
   self.player:getAnimation():play("walk",-1,-1,1)
end

function BattleScene:onStop()
   self.player:setScale(0.5)
   self.player:getAnimation():play("idle",-1,-1,1)
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