local StateMachine =  require("StateMachine")

--玩家类
Player = class("Player", function()
    return CCLayer:create()
    --return CCLayerColor:create(ccc4(255, 0, 0,175))
	end)

function Player:create(scene)
   local ref = Player.new()
   ref:initStateMachine()
   ref.scene = scene
   return ref
end

function Player:ctor()
    
    local armor = CCArmature:create("caocao")
    armor:getAnimation():play("idle",-1,-1,1)
    self:setContentSize(armor:getContentSize())
    armor:setPosition(self:getContentSize().width/2,0)
    self:addChild(armor)
    self.body = armor

    self.body:getAnimation():registerMovementHandler(handler(self, self.MovementEventCallFun))
    self.body:getAnimation():regisetrFrameHandler(handler(self, self.FrameEventCallFun))
    
    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(ccp(0.5, 0))
    self:scheduleUpdateWithPriorityLua(handler(self, self.update),10)   
end

function Player:update(dt)
    
    if self.fsm:getState() == "walkingleft" then
        local pos = self.scene:getCanMovepos(-2)
        self:setPosition(pos)
        self.scene:setViewpointCenter(pos.x,pos.y)
    	return
    end

    if self.fsm:getState() == "walkingright"  then
        local pos = self.scene:getCanMovepos(2)
        self:setPosition(pos)
        self.scene:setViewpointCenter(pos.x,pos.y)
       return 
    end
end


function Player:FrameEventCallFun(bone,eventname,cid,oid)
   print("hello:"..eventname)
end

function Player:MovementEventCallFun(armature,moveevnettype,movementid)
   if moveevnettype == 1 or moveevnettype == 2 then
       if movementid == "attack"  then
          self.fsm:doEvent("stopattack")
       end
       
       if movementid == "shoot_rifle"  then
          self.fsm:doEvent("stopattack")
       end

   end
end

--初始化状态机
function Player:initStateMachine()
    local fsm = StateMachine.new()
   fsm:setupState({
      initial = {state ="idle",event = "init",defer = true},
      events = {
        {name = "walkleft",  from  = "idle",to = "walkingleft"},
        {name = "walkright",  from  ="idle",to = "walkingright"},
        {name = "stop",  from  = {"walkingleft","walkingright"},to = "idle"},
        {name = "attack",from = "idle",to = "attacking"},
        {name = "stopattack",from = {"attacking","shooting"},to = "idle"},
        {name = "shoot",from="idle",to="shooting"},
        {name = "kill",  from  = "*",to = "dead"},
      },
      callbacks = {
         onidle      = handler(self,self.onIdle),
         onwalkingleft   = handler(self,self.onWalkingLeft),
         onwalkingright  = handler(self,self.onWalkingRight),
         onattacking = handler(self, self.onAttacking),
         onshooting = handler(self, self.onShooting),
         ondead = handler(self, self.onDead)
      }
    })
   self.fsm = fsm
end


function Player:onIdle(event)
   self.body:setScale(1)
   self.body:getAnimation():play("idle",-1,-1,1)
end

function Player:onWalkingLeft(event)
   self.body:setScaleX(-1)
   self.body:getAnimation():play("walk",-1,-1,1)
end

function Player:onWalkingRight(event)
   self.body:setScaleX(1)
   self.body:getAnimation():play("walk",-1,-1,1)
end

function Player:onDead(event)
   self.body:getAnimation():play("dead",-1,-1,0)
end

function Player:onAttacking(event)
   self.body:getAnimation():play("attack",-1,-1,0)
end

function Player:onShooting(event)
   self.body:getAnimation():play("shoot_rifle",-1,-1,0)
end

