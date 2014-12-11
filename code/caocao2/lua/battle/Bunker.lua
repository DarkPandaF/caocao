
Bunker = class("Bunker") 

function Bunker:ctor(layer,pos)
   
   self.layer = layer

   local pic1 = CCSprite:create(P("icon/speak_normal01.png"))
   pic1:setPosition(pos)
   layer:addChild(pic1,4)
   self.pic1 = pic1

   local pic2 = CCSprite:create(P("icon/speak_normal02.png"))
   pic2:setPosition(pos)
   layer:addChild(pic2,3)
   self.pic2 = pic2

   local pic3 = CCSprite:create(P("icon/speak_normal03.png"))
   pic3:setPosition(pos)
   layer:addChild(pic3,2)
   self.pic3 = pic3

end

function Bunker:create(layer)
	local ref = Bunker.new(layer,pos)
    ref.hp = 5000
	return ref
end

