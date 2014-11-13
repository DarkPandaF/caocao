--
-- Author: Your name
-- Date: 2014-11-10 10:32:49
--
Enemy = class("Enemy",function(name)
        return Soldier.new(name)
	 end)

function Enemy:create(name,index,scene)
   local ref = Enemy.new(name)
   ref.cindex = index
   ref:init()
   ref.scene = scene
   return ref
end


function Enemy:finish()
    self.scene:removeEnemyFromGrid(self,self.gridindex)
    self.hpbg:setVisible(false)
    self:unscheduleUpdate()
    self.fsm:doEvent("reset")
    self:removeFromParentAndCleanup(false)
end

function Enemy:init()
   self:initArmor()
   self:initHpBar()
   self:changeDisPlay()
   self:initStateMachine()
 
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
        
        local gridindex = self.scene:getGridNum(x)
        if self.gridindex ~= gridindex then
           self.scene:removeEnemyFromGrid(self,self.gridindex)
           self.gridindex = gridindex
           self.scene:addEnemyToGrid(self,self.gridindex)
           
           self.target = self:findTarget()
           if self.target then
              self.fsm:doEvent("stop")
           end 

        end

        if x <= 0 then
           self:finish()
        end
    end

    if self.fsm:getState() == "idle" then
       self:doLogic()
    end
end

function Enemy:initEnemyState(index)
   
   self:initState()
   self.cindex = index
   self:changeDisPlay()
   self.hp = 1000
   self.attackRange = 3
end

function Enemy:onDead(event)
	  self:changeDisPlay()
    self.body:getAnimation():play("dead",-1,-1,0)
end

function Enemy:isCanAttack()
    
    if self.target then
       if self.target:isDead() then
          self.target = nil
       elseif self.gridindex  - self.target.gridindex < 0 then
          self.target = nil
       elseif self.gridindex - self.target.gridindex  > self.attackRange then
          self.target = nil
       end

    end
    return self.target ~= nil
end

function Enemy:findTarget()
    
    local target = nil
    local from  = self.gridindex - self.attackRange 
    local to    = self.gridindex 

    for i=from,to do
        
        if self.scene.player.gridindex == i then
           target = self.scene.player 
           break
        end
        local list = self.scene.soldierslist[i]
        if list ~= nil then
           table.foreach(list,function(i,v)
                          if v and not target and not v:isDead() then
                             target = v
                          end
                        end)      
        end
        if target then
           break
        end
    end
    return target
end

function Enemy:FrameEventCallFun(bone,eventname,cid,oid)
    
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