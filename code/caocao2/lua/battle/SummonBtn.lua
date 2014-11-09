
SummonBtn = class("SummonBtn",function(...)
                 return CCLayer:create()
	           end)

function SummonBtn:ctor(bgpic,selpic,headpic,func,cooltime)
    
    local bg = CCSprite:create(bgpic)
    bg:setAnchorPoint(ccp(0, 0))
    self:addChild(bg)
    self:setContentSize(bg:getContentSize())
    self.bg = bg
     
    local selbg = CCSprite:create(selpic)
    selbg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
    selbg:setVisible(false)
    bg:addChild(selbg)
    self.sel = false 
    self.selbg = selbg
    
    local pic = headpic or  P("icon/soliderlock.png")
    local headicon = CCSprite:create(pic)
    local ptimer = CCProgressTimer:create(headicon)
    ptimer:setType(0)
    ptimer:setReverseProgress(true)
    ptimer:setPercentage(100)
    ptimer:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
    bg:addChild(ptimer) 
    
    self.cooltimer = ptimer
    self.isincool = false

    self.lock = not headpic
    self.func = func or function()end
   
    self.cooltime = cooltime or 0

    self:ignoreAnchorPointForPosition(false)
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(handler(self, self.onTouch),false,100,true)             
end

function SummonBtn:create(bgpic,selpic,headpic,func,cooltime)
   local  ref = SummonBtn.new(bgpic,selpic,headpic,func,cooltime)
   return ref
end

function SummonBtn:isInTouch(x,y)
	local point = self:convertToNodeSpace(ccp(x, y))
    local r = self.bg:boundingBox()
	if r:containsPoint(point) then
		return true
	else
		return false
	end
end

function SummonBtn:onTouch(eventType, x, y)
    
    if self.lock or self.isincool  then
    	return false
    end

	self.isInWork = self.isInWork or false
	if eventType == "began" then  
       if self:isInTouch(x,y) then
       	  self:setSelected(true)
       	  self.isInWork = true
       	  return true
       end
    elseif eventType == "moved" then
        if  self.isInWork  then
        	if not self:isInTouch(x,y) then
               self:setSelected(false)
       	       self.isInWork = false
            end
        end
    elseif eventType == "ended" then
       if  self.isInWork  then
           self:setSelected(false)
       	   self.isInWork = false
       	   self:coolSummon()
       	   self.func()
       end
    elseif eventType == "cancelled" then
       if  self.isInWork  then
           self:setSelected(false)
       	   self.isInWork = false
       end
	end

end

function SummonBtn:setSelected(sel)
    if sel ~= self.sel then
    	self.sel = sel 
    	self.selbg:setVisible(sel)
    end
end

function SummonBtn:coolSummon()
	 
    if self.cooltime == 0 then
       return 
    end  

    self.isincool = true
    self.cooltimer:setPercentage(0)
    
    local function actonend()
       self.isincool = false
    end

    local action  =  CCSequence:createWithTwoActions(CCProgressTo:create(self.cooltime, 100),
    	                                             CCCallFunc:create(actonend)
    	                                             )
    self.cooltimer:runAction(action)

end