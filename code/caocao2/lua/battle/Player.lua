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
   ref.hp = 5000
   ref.attackRange = 10
   return ref
end

function Player:ctor()
    
    self.gridindex = 0

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
    
    self:CheckBullet()

    if self.fsm:getState() == "walkingleft" then
        local pos = self.scene:getCanMovepos(-2)
        self:setPosition(pos)
        self.scene:setViewpointCenter(pos.x,pos.y)

        local gridindex = self.scene:getGridNum(pos.x)
        if self.gridindex ~= gridindex then
           self.gridindex = gridindex
        end
    	return
    end

    if self.fsm:getState() == "walkingright"  then
        local pos = self.scene:getCanMovepos(2)
        self:setPosition(pos)
        self.scene:setViewpointCenter(pos.x,pos.y)
        
        local gridindex = self.scene:getGridNum(pos.x)
        if self.gridindex ~= gridindex then
           self.gridindex = gridindex
        end
       return 
    end
end


--最后释放内存
function Player:releaseData()
    self.bulletlist = self.bulletlist or {}
     for k,v in pairs(self.bulletlist) do
         v:release()
   end
end


function Player:FrameEventCallFun(bone,eventname,cid,oid)
    
    if eventname == "attack" then
       self:doKnifeAttack()
    end

    if eventname == "leftshoot" then
       self:doShootAttack()
    end

end

function Player:MovementEventCallFun(armature,moveevnettype,movementid)
   if moveevnettype == 1 or moveevnettype == 2 then
       if movementid == "attack"  then
          self.fsm:doEvent("stopattack")
       end
       
       if movementid == "shoot_rifle"  then
          self.fsm:doEvent("stopattack")
       end

       if movementid == "dead" then
          self:finish()
       end
   end
end

--获得刀砍对象
function Player:getKnifedTarget(rect)
    
    local target = nil
    local from  = self.gridindex
    local to    = from + self.attackRange 

    for i=from,to do
        local list = self.scene.enemylist[i]
        if list ~= nil then
           for k,v in pairs(list) do
               if v and not v:isDead() and v:boundingBox():intersectsRect(rect) then
                  target = v 
                  break
               end
           end       
        end
        if target then
           break
        end
    end
    return target  
end

--刀砍攻击
function Player:doKnifeAttack()
   local target = self:getKnifedTarget(self:boundingBox())
   if target then
      print("knife")
      target:subHp(300,2)
   end
end

--获得子弹
function Player:getBullet()
   self.bulletlist = self.bulletlist or {}
   local bullet = nil
   
   for k,v in pairs(self.bulletlist) do
       if not v:getParent() then
          bullet = v
       end
   end

   if not bullet then
      bullet = CCSprite:create(P("battle/bullet_caocao.png"))
      bullet:retain()
      table.insert(self.bulletlist, bullet)
   end
   return bullet
end

function Player:getShootPos()
   local bone = self.body:getBone("right_shootingpoint")
   local pos =  self.body:convertToWorldSpace(ccp(bone:getWorldInfo():getX() , bone:getWorldInfo():getY()))
   return self:getParent():convertToNodeSpace(pos)
end


function Player:doShootAttack()
    local bullet = self:getBullet()
    local pos = self:getShootPos()
    bullet:setPosition(pos)
    bullet.gridindex = 0
    self:getParent():addChild(bullet,self:getZOrder())
end


function Player:CheckBullet()
    self.bulletlist = self.bulletlist or {}
    for k,v in pairs(self.bulletlist) do
         if v:getParent() then
            local posx = v:getPositionX()
            posx  =  posx + 6
            v:setPositionX(posx)
            if  posx >= self:getParent():getContentSize().width then
                v:removeFromParentAndCleanup(false)
            else
                local gridindex = self.scene:getGridNum(posx)
                if gridindex ~= v.gridindex  then
                   v.gridindex = gridindex
                   self:doBulletAction(v)    
                end            
            end



         end 
    end
end

function Player:doBulletAction(bullet)
     
     local list = self.scene.enemypool
     if list ~= nil then
       for k,v in pairs(list) do
           if v and v:getParent() and not v:isDead() and v:boundingBox():containsPoint(ccp(bullet:getPosition())) then
              v:subHp(300,3)
              bullet:removeFromParentAndCleanup(false)  
              break
           end
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

function Player:isDead()
   return self.fsm:getState() == "dead"
end

--扣血
function Player:subHp(attackvalue)
    self.hp = self.hp - attackvalue
    if self.hp > 0 then
       self.scene:setPlayerHpPer(self.hp/5000 * 100)
       self:doEffect()
    else
       self.fsm:doEvent("kill")
    end
end

function Player:getEffectArmor()
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

function Player:doEffect()
    local effect = self:getEffectArmor()
    effect:getAnimation():play("attackedeffect",-1,-1,0)
    
    local bone = self.body:getBone("attackedpoint")
    effect:setPosition(bone:getWorldInfo():getX() , bone:getWorldInfo():getY()) 
    self.body:addChild(effect,100)
end

--效果
function Player:EffecttEventCallFun(armature,moveevnettype,movementid)
    if moveevnettype == 1 or moveevnettype == 2 then
       
       if movementid == "attackedeffect" then
          armature:removeFromParentAndCleanup(false)
       end 

    end
end

function Player:finish()
    self:releaseData()
    self:unscheduleUpdate()
    self.scene:endGame()

end