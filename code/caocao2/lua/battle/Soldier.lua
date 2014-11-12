local StateMachine =  require("StateMachine")

Soldier = class("Soldier", function()
    return CCLayer:create()
    --return CCLayerColor:create(ccc4(255, 0, 0,175))
	end)

function Soldier:update(dt)
    
    if self.fsm:getState() == "walking" then
        local x = self:getPositionX()
        x = x + 1
        self:setPositionX(x)
        
        local gridindex = self.scene:getGridNum(x)
        if self.gridindex ~= gridindex then
           self.scene:removeSoldierToGrid(self,self.gridindex)
           self.gridindex = gridindex
           self.scene:addSoldierToGrid(self,self.gridindex)
           self.fsm:doEvent("stop")
        end

        if x >= self:getParent():getContentSize().width then
           self:finish()
        end
    end

    if self.fsm:getState() == "idle" then
       self:doLogic()
    end
end

function Soldier:ctor(name)
   self.name = name
end

function Soldier:finish()
    self:unscheduleUpdate()
    self.fsm:doEvent("reset")
    self:removeFromParentAndCleanup(false)
end
function Soldier:initArmor()
    local armor = CCArmature:create(self.name)
    armor:getAnimation():play("idle",-1,-1,1)
    self:setContentSize(armor:getContentSize())
    armor:setPosition(self:getContentSize().width/2,0)
    self:addChild(armor)
    self.body = armor 

    self.body:getAnimation():registerMovementHandler(handler(self, self.MovementEventCallFun))
    self.body:getAnimation():regisetrFrameHandler(handler(self, self.FrameEventCallFun))

    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(ccp(0.5, 0))
end
function Soldier:init()
   self:initArmor()
   self:initStateMachine()
end
--初始化状态
function Soldier:initState()
   
   self.hp = 1000
   self.attackRange = 5
   self.fsm:doEvent("init")
   self:scheduleUpdateWithPriorityLua(handler(self, self.update),10) 
end 

function Soldier:create(name,scene)
	local ref = Soldier.new(name)
  ref:init()
  ref.scene = scene
	return ref
end

function Soldier:initStateMachine()
   local fsm = StateMachine.new()
   fsm:setupState({
      initial = {state ="idle",event = "init",defer = true},
      events = {
        {name = "walk",  from = "idle",to = "walking"},
        {name = "stop",  from = "walking",to = "idle"},  
        {name = "attack",from = "idle",to = "attacking"},
        {name = "stopattack",from = "attacking",to = "idle"},
        {name = "kill",from = "*",to = "dead"},
        {name = "reset",from = "*",to = "none"}
      },
      callbacks = {
         onidle = handler(self,self.onIdle),
         onwalking = handler(self,self.onWalking),
         onattacking = handler(self, self.onAttacking),
         ondead = handler(self, self.onDead)
      }
    })
   self.fsm = fsm
end

--寻找目标
function Soldier:findTarget()
    
    local target = nil
    local from  = self.gridindex
    local to    = from + self.attackRange 

    for i=from,to do
        local list = self.scene.enemylist[i]
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

--扣除hp
function Soldier:subHp(attackvalue)
end

function Soldier:isCanAttack()
    
    if self.target then
       if self.target:isDead() then
          self.target = nil
       elseif self.target.gridindex - self.gridindex < 0 then
          self.target = nil
       elseif self.target.gridindex - self.gridindex > self.attackRange then
          self.target = nil
       end

    end
    return self.target ~= nil
end

function Soldier:doLogic()
   
   if self:isCanAttack() then
      print("attack")
      self.fsm:doEvent("attack")
      return
   end

   if not self.target then
      self.target = self:findTarget()
   end  

   if not self.target then
      self.fsm:doEvent("walk")
   end

end 


--是否死亡
function Soldier:isDead()
   return self.fsm:getState() == "dead" or self.fsm:getState() == "none"  
end

function Soldier:onIdle(event)
   self.body:getAnimation():play("idle",-1,-1,1)
end

function Soldier:onWalking(event)
   self.body:getAnimation():play("walk",-1,-1,1)
end

function Soldier:onAttacking(event)
   self.body:getAnimation():play("attack",-1,-1,0)
end

function Soldier:onDead(event)
    self.body:getAnimation():play("dead",-1,-1,0)
end

function Soldier:FrameEventCallFun(bone,eventname,cid,oid)
end

function Soldier:MovementEventCallFun(armature,moveevnettype,movementid)
   if moveevnettype == 1 or moveevnettype == 2 then
      if movementid == "attack" then
         self.fsm:doEvent("stopattack")   
      end
   end
end


