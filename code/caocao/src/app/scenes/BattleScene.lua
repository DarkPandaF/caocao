local BattleScene = class("BattleScene", function()
    return display.newScene("BattleScene")
end)

function BattleScene:ctor()
    self:getBackground()
end

function BattleScene:getBackground()
    
    local layer1 = display.newLayer()
    layer1:setContentSize(cc.size(2000,256))
    for i=1,8 do
        local sp = display.newSprite("far_01_01.png")
        sp:setAnchorPoint(0,0)
        sp:setPosition((i-1)*sp:getContentSize().width,0)
        layer1:addChild(sp)
    end
    
   
    layer1:ignoreAnchorPointForPosition(false)
    layer1:setAnchorPoint(0,1)
    layer1:setPosition(0,display.height)
    self:addChild(layer1)

    local layer2 = display.newLayer()
    layer2:setContentSize(cc.size(2000,357))
    for i=1,3 do
        local sp = display.newSprite("middle_01_01.png")
        sp:setAnchorPoint(0,0)
        sp:setPosition((i-1)*sp:getContentSize().width,0)
        layer2:addChild(sp)
    end
    
    layer2:ignoreAnchorPointForPosition(false)
    layer2:setAnchorPoint(0,1)
    layer2:setPosition(0,display.height)
    self:addChild(layer2)
    
    local layer3 = display.newLayer()
    layer3:setContentSize(cc.size(2000,217))
    for i=1,5 do
        local sp = display.newSprite("near_01_01.png")
        sp:setAnchorPoint(0,0)
        sp:setPosition((i-1)*sp:getContentSize().width,0)
        layer3:addChild(sp)
    end
    layer3:ignoreAnchorPointForPosition(false)
    layer3:setAnchorPoint(0,1)
    layer3:setPosition(0,display.height-257)
    self:addChild(layer3)

    
    -- local sp1 = display.newTilesSprite("far_01_01.png",cc.rect(0,0,2000,256))
    -- sp1:setAnchorPoint(cc.p(0,1))
    -- sp1:setPosition(0,display.height)
    -- self:addChild(sp1)

    --local sp2 = display.newTilesSprite("middle_01_01.png",cc.rect(0,0,714*3,357))
    -- local sp2 = display.newTilesSprite("middle_01_01.png", cc.rect(0,0,714,357))
    -- sp2:setAnchorPoint(cc.p(0,1))
    -- sp2:setPosition(0,display.height)
    -- self:addChild(sp2)
    


end

function BattleScene:onEnter()
end

function BattleScene:onExit()
end

return BattleScene