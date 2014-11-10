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
    end

    if self.fsm:getState() == "idle" then
       self.fsm:doEvent("walk")
    end
end

function Soldier:ctor(name)
   self.name = name
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
   self:scheduleUpdateWithPriorityLua(handler(self, self.update),10) 
end

function Soldier:create(name)
	local ref = Soldier.new(name)
  ref:init()
	return ref
end

function Soldier:FrameEventCallFun(bone,eventname,cid,oid)
   print("hello:"..eventname)
end

function Soldier:MovementEventCallFun(armature,moveevnettype,movementid)
   if moveevnettype == 1 or moveevnettype == 2 then

   end
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
        {name = "kill",from = "*",to = "dead"}
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