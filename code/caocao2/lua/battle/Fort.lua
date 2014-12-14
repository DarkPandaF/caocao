Fort = class("Fort")

function Fort:ctor(layer,pos)
   
   self.layer = layer
   self.pos = pos

   local pic1 = CCSprite:create(P("icon/speak_normal01.png"))
   pic1:setPosition(pos)
   layer:addChild(pic1,4)
   self.pic1 = pic1
   self.size = pic1:getContentSize()

   local pic2 = CCSprite:create(P("icon/speak_normal02.png"))
   pic2:setPosition(pos)
   layer:addChild(pic2,3)
   self.pic2 = pic2

   local pic3 = CCSprite:create(P("icon/speak_normal03.png"))
   pic3:setPosition(pos)
   layer:addChild(pic3,2)
   self.pic3 = pic3

   self.state = 1   
end

function Fort:getPosition()
  return self.pos.x,self.pos.y
end

function Fort:create(scene,layer,pos)
   local ref = Fort.new(layer,pos)
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
    
    self.scene:setBossHpPer(per)   
    if per < 30 and  self.state ~= 2 then
       self:setBroken()
    end

    if self.hp <= 0 then
    
    else
       self:beAttacked()
    end
end

function Fort:setBroken()
   local texture1 = CCTextureCache:sharedTextureCache():addImage(P("icon/speak_broken01.png"))
   self.pic1:setTexture(texture1)
   local texture2 = CCTextureCache:sharedTextureCache():addImage(P("icon/speak_broken02.png"))
   self.pic2:setTexture(texture2)
   local texture3 = CCTextureCache:sharedTextureCache():addImage(P("icon/speak_broken03.png"))
   self.pic3:setTexture(texture3)
   self.state = 2
end

function Fort:beAttacked()
   
   self.pic1:setColor(ccc3(255, 255, 255))
   local action = CCSequence:createWithTwoActions(CCTintTo:create(0.1,255,0,0),CCTintTo:create(0.01, 255, 255, 255))
   self.pic1:runAction(action)

   self.pic2:setColor(ccc3(255, 255, 255))
   local action = CCSequence:createWithTwoActions(CCTintTo:create(0.1,255,0,0),CCTintTo:create(0.01, 255, 255, 255))
   self.pic2:runAction(action)

   self.pic3:setColor(ccc3(255, 255, 255))
   local action = CCSequence:createWithTwoActions(CCTintTo:create(0.1,255,0,0),CCTintTo:create(0.01, 255, 255, 255))
   self.pic3:runAction(action)
   
end

function Fort:getBeShootPos()
   return self.pos
end

function Fort:boundingBox()
   return CCRect(self.pos.x - self.size.width/2,self.pos.y-self.size.height/2,self.size.width,self.size.width)
end





