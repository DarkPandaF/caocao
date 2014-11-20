SoldierClose = class("SoldierClose", function(name)
    return Soldier.new(name)
	end)


function SoldierClose:create(name,scene)
	local ref = SoldierClose.new(name)
    ref:init()
    ref.scene = scene
	return ref
end

function SoldierClose:initState()
   
   self.hp = 1000
   self.attackRange = 3
   self.fsm:doEvent("init")
   self:scheduleUpdateWithPriorityLua(handler(self, self.update),10)
   self.body:getAnimation():registerMovementHandler(handler(self, self.MovementEventCallFun))
   self.body:getAnimation():regisetrFrameHandler(handler(self, self.FrameEventCallFun)) 
end 

function SoldierClose:FrameEventCallFun(bone,eventname,cid,oid)
    if eventname == "attack" then
       if self.target then
          local rect1 = self.target:boundingBox()
          local rect2 = self:boundingBox()
          if rect1:intersectsRect(rect2) then
             self.target:subHp(100)
          end
       end
    end
end