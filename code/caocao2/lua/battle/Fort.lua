Fort = class("Fort",function()
         return CCLayer:create()
	   end)

function Fort:ctor()
   
   local bg = CCSprite:create(P("head/radio_1.png"))
   bg:setAnchorPoint(ccp(0, 0))
   self:setContentSize(bg:getContentSize())
   self:addChild(bg)
   self.bg = bg
   self.state = 1
   
   self:ignoreAnchorPointForPosition(false)
end

function Fort:create(scene)
   local ref = Fort.new()
   ref:initState()
   ref.scene = scene
   return ref
end

function Fort:initState()
   self.hp = 100000
end

function Fort:isDead()
   return self.hp <= 0
end

function Fort:subHp(attackvalue,atttype)
    self.hp = self.hp - attackvalue
    local per = self.hp / 100000  * 100

    if per < 30 and  self.state ~= 2 then
       self:setBroken()
    end

    if self.hp <= 0 then
       
    end

end

function Fort:setBroken()
   local texture = CCTextureCache:sharedTextureCache():addImage(P("head/radio_1.png"))
   self.bg:setTexture(texture)
   self.state = 2
end



