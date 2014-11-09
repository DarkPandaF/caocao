require "extern"

UITouchButton = class("UITouchButton", function( ... )
	return CCLayer:create()
end)

function UITouchButton:ctor(pic1,pic2,funcpress,funcrelease)
	self.picunsel = pic1
	self.picsel = pic2
	self.funcpress = funcpress
	self.funcrelease = funcrelease
    local sp = CCSprite:create(self.picunsel)
    sp:setAnchorPoint(ccp(0, 0))
    self:addChild(sp)
    self:setContentSize(sp:getContentSize())
    self.sp = sp
    self.isSel = false
    
    self:ignoreAnchorPointForPosition(false)
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(handler(self, self.onTouch),false,100,true)

end

function UITouchButton:onTouch(eventType, x, y)
	
	self.isInWork = self.isInWork or false
	if eventType == "began" then
       
       if self:isInTouch(x,y) then
       	  self:setSelected(true)
       	  self.isInWork = true
       	  self.funcpress()
       	  return true
       end
    elseif eventType == "moved" then
        if  self.isInWork  then
        	if not self:isInTouch(x,y) then
               self:setSelected(false)
       	       self.isInWork = false
       	       self.funcrelease()
            end
        end
    elseif eventType == "ended" then
       if  self.isInWork  then
           self:setSelected(false)
       	   self.isInWork = false
       	   self.funcrelease()
       end

    elseif eventType == "cancelled" then
       if  self.isInWork  then
           self:setSelected(false)
       	   self.isInWork = false
       	   self.funcrelease()
       end
	end
end

function UITouchButton:isInTouch(x,y)
	local point = self:convertToNodeSpace(ccp(x, y))
    local r = self.sp:boundingBox()
	if r:containsPoint(point) then
		return true
	else
		return false
	end
end

function UITouchButton:setSelected(sel)
	if sel ~= self.isSel then
	   self.isSel = sel
       local texture = nil
       if sel then
          texture = CCTextureCache:sharedTextureCache():addImage(self.picsel)
       else
       	  texture = CCTextureCache:sharedTextureCache():addImage(self.picunsel)
       end
       self.sp:setTexture(texture)
	end
end


