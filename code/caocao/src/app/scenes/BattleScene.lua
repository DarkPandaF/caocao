local BattleScene = class("BattleScene", function()
    return display.newScene("BattleScene")
end)

function BattleScene:ctor()
    self:getBackground()
end

function BattleScene:getBackground()
    
    local layer1 = display.newLayer()
    local sp1 = display.newSprite("far_01_01.png")
    print(math.fmod(2000,sp1:getContentSize().width))
    
    


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