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


--初始化状态机
function Player:initStateMachine()
    local fsm = StateMachine.new()
   fsm:setupState({
      initial = {state ="idle",event = "init",defer = true},
      events = {
        {name = "walkleft",  from  = "idle",to = "walkingleft"},
        {name = "walkright",  from  ="idle",to = "walkingright"},
        {name = "stop",  from  = {"walkingleft","walkingright"},to = "idle"},
        {name = "kill",  from  = "*",to = "dead"},
      },
      callbacks = {
         onidle      = handler(self,self.onIdle),
         onwalkingleft   = handler(self,self.onWalkingLeft),
         onwalkingright  = handler(self,self.onWalkingRight),
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
