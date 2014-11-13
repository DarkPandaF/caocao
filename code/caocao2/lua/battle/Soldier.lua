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
           
           self.target = self:findTarget()
           if self.target then
              self.fsm:doEvent("stop")
           end  

        end

        if x >= self:getParent():getContentSize().width then
           self:finish()
        end
    end

    if self.fsm:getState() == "idle" then
       print("dologic")
       self:doLogic()
    end
end

function Soldier:ctor(name)
   self.name = name
end

function Soldier:finish()
    
    self.scene:removeSoldierToGrid(self,self.gridindex)
    self.hpbg:setVisible(false)
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
   self:initHpBar()
   self:initStateMachine()
end

--初始化状态
function Soldier:initState()
   
   self.hp = 1000
   self.attackRange = 10
   self.fsm:doEvent("init")
   self:scheduleUpdateWithPriorityLua(handler(self, self.update),10)
   self.body:getAnimation():registerMovementHandler(handler(self, self.MovementEventCallFun))
   self.body:getAnimation():regisetrFrameHandler(handler(self, self.FrameEventCallFun)) 
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

function Soldier:initHpBar()
   
   local hpbg = CCSprite:create(P("battle/soldierbarbg.png"))
   hpbg:setPosition(self:getContentSize().width/2, self:getContentSize().height)
   self:addChild(hpbg)
   self.hpbg = hpbg

   local barsp = CCSprite:create(P("battle/soldierbargreen.png"))
   local hpbar   = CCProgressTimer:create(barsp)
   hpbar:setType(1)
   hpbar:setMidpoint(ccp(0, 0))
   hpbar:setBarChangeRate(ccp(1, 0))
   hpbar:setPercentage(80)
   hpbar:setAnchorPoint(ccp(0.5, 0.5))
   hpbar:setPosition(hpbg:getContentSize().width/2,hpbg:getContentSize().height/2)
   hpbg:addChild(hpbar)
   
   
   --进度条颜色 1 绿色 2红色
   self.barstate = 1

   self.barsp = barsp
   self.hpbar = hpbar
   
   self.hpbg:setVisible(false)
end

function Soldier:setHpPer(num)
   self.hpbg:setVisible(true)
   if num > 30 then
      if self.barstate == 2 then
         local texture = CCTextureCache:sharedTextureCache():addImage(P("battle/soldierbargreen.png"))
         self.barsp:setTexture(texture)
         self.barstate = 1
      end
   else
      if self.barstate == 1 then
         local texture = CCTextureCache:sharedTextureCache():addImage(P("battle/soldierbarred.png"))
         self.barsp:setTexture(texture)
         self.barstate = 2
      end
   end
   self.hpbar:setPercentage(num)
end

--扣除hp
function Soldier:subHp(attackvalue)
    self.hp = self.hp - attackvalue
    self:setHpPer(self.hp/1000 * 100)
    if self.hp <= 0 then
       self.fsm:doEvent("kill")
    else
       self:doEffect()
    end
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
    if eventname == "attack" then
       self:doShoot()
    end
end

function Soldier:MovementEventCallFun(armature,moveevnettype,movementid)
   if moveevnettype == 1 or moveevnettype == 2 then
      
      if movementid == "attack" then
         self.fsm:doEvent("stopattack")
         return   
      end
      
      if movementid == "dead" then
         self:finish()
         return
      end

   end
end


--效果
function Soldier:EffecttEventCallFun(armature,moveevnettype,movementid)
    if moveevnettype == 1 or moveevnettype == 2 then
       
       if movementid == "attackedeffect" then
          armature:removeFromParentAndCleanup(false)
       end 

    end
end

function Soldier:getEffectArmor()
   self.effectlist = self.effectlist or {}
   local armor = nil
   for i,v in ipairs(self.effectlist) do
       if not v:getParent() then
          armor = v
          break
       end
   end
   if not armor then
      armor = CCArmature:create("commoneffect")
      armor:getAnimation():registerMovementHandler(handler(self, self.EffecttEventCallFun))
      table.insert(self.effectlist,armor)
   end
   return armor
end

function Soldier:doEffect()
    local effect = self:getEffectArmor()
    effect:getAnimation():play("attackedeffect",-1,-1,0)
    
    local bone = self.body:getBone("attackedpoint")
    effect:setPosition(bone:getWorldInfo():getX() , bone:getWorldInfo():getY()) 
    self.body:addChild(effect,100)
end

function Soldier:getBullet()
   local buttet = CCSprite:create(P("battle/80001.png"))
   return buttet
end

function Soldier:doShoot()
   
    if not self.target then
       return 
    end
    
    local function playend(ref)
        if self.target then
           self.target:subHp(100)
        end
        ref:removeFromParentAndCleanup(true)
    end

    local buttet = self:getBullet()
    local shootpos =  self:getShootPos()
    local peakpos =   self:getPeakPos()
    local endpos =    self.target:getBeShootPos()
    
    print(shootpos.x,shootpos.y)
    print(peakpos.x,shootpos.y)
    print(endpos.x,endpos.y)
    --local time = ccpDistance(shootpos, endpos) /1000 * 0.15
    local time = 0.15

    local action   = CCSequence:createWithTwoActions(CCParabolyTo:create(time,shootpos,peakpos,endpos)
                                                     ,CCCallFuncN:create(playend))

    buttet:runAction(action)
    self:getParent():addChild(buttet,1000)

end

function Soldier:getShootPos()
   local bone = self.body:getBone("shootingpoint")
   local pos =  self.body:convertToWorldSpace(ccp(bone:getWorldInfo():getX() , bone:getWorldInfo():getY()))
   return self:getParent():convertToNodeSpace(pos)
end

function Soldier:getPeakPos()
   local bone = self.body:getBone("peak")
   local pos  = self.body:convertToWorldSpace(ccp(bone:getWorldInfo():getX() , bone:getWorldInfo():getY())) 
   return self:getParent():convertToNodeSpace(pos)  
end

function Soldier:getBeShootPos()
   local pos  = self:convertToWorldSpace(ccp(0,0))
   return self:getParent():convertToNodeSpace(pos)  
end

