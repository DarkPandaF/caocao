--
-- Author: Your name
-- Date: 2014-11-10 10:32:49
--
Enemy = class("Enemy",function(name)
        return Soldier.new(name)
	 end)

function Enemy:create(name,index)
   local ref = Enemy.new(name)
   ref.cindex = index
   ref:init()
   return ref
end

function Enemy:init()
   self:initArmor()
   self:changeDisPlay()
   self:initStateMachine()
   self:scheduleUpdateWithPriorityLua(handler(self, self.update),10) 
end

function Enemy:changeDisPlay()
	
    local head = self.body:getBone("head")
    head:changeDisplayByIndex(self.cindex,true)  
    local dizzy = self.body:getBone("dizzy")
    dizzy:changeDisplayByIndex(self.cindex,true)
end

function Enemy:update(dt)

	if self.fsm:getState() == "walking" then
        local x = self:getPositionX()
        x = x - 1
        self:setPositionX(x)
        if x <= 0 then
           self:finish()
        end
    end

    if self.fsm:getState() == "idle" then
       self.fsm:doEvent("walk")
    end
end

function Enemy:initEnemyState(index)
   self:initState()
   self.cindex = index
   self:changeDisPlay()
end

function Enemy:onDead(event)
	  self:changeDisPlay()
    self.body:getAnimation():play("dead",-1,-1,0)
end