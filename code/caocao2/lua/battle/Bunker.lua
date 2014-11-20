
Bunker = class("Bunker", function()
                return CCLayer:create()
	           end) 

function Bunker:ctor()
    
    local bg = CCSprite:create(P("ballte/radio_1.png"))
    self:setContentSize(bg:getContentSize())
    bg:setAnchorPoint(ccp(0, 0))
    self:addChild(bg)
    
    self:ignoreAnchorPointForPosition(true) 
end

function Bunker:create()
	local ref = Bunker.new()
    ref.hp = 5000
	return ref
end

