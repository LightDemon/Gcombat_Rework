AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
--include('entities/base_wire_entity/init.lua')
include('shared.lua')

function ENT:Initialize()  

	self.exploded = false
	self.armed = true
	self.flightvector = self.Entity:GetUp() * self.speed
	--self.vectorchange = nil --self.cannon.vectorchange
	--self.damage1 =  nil --self.cannon.damage
	--self.perice1 = nil --self.cannon.perice
	--self.model = nil --self.cannon.ammomodel
	self.Entity:SetModel( self.model )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3        
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self.Randomness = math.random(3,9)/10;
	self.AntiRandomness = 1-self.Randomness;
	self.CurrentVelocity = 2000
	self.phys = self.Entity:GetPhysicsObject()
	self.target = nil
	self.lock = nil
	if(self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:SetMass(20)
		self.phys:EnableGravity(false);
		self.phys:EnableDrag(false);
		self.phys:EnableCollisions(false);
		self.phys:SetVelocity(self.Entity:GetPos()*self.Entity:GetUp()*2000);
	end

	self.Sound = CreateSound( self.Entity, Sound( "weapons/rpg/rocket1.wav" ) ) 
 	self.Sound:Play()
	self.tracktime = CurTime() + self.ttime
	self.timerRunning = false
end   

function ENT:PhysicsUpdate(phys,deltatime)
	local time = CurTime();
	if((self.LastPhysicsUpdate or 0) + 0.07 >= time) then return end;
	
	self.LastPhysicsUpdate = time;
	if(self.fuel > 0)  then
		self.fuel = self.fuel-1; 
		local pos = self.Entity:GetPos();
		if(self.CurrentVelocity < self.speed) then
			self.CurrentVelocity = math.Clamp(self.CurrentVelocity*self.acell,self.CurrentVelocity,self.speed);
		end
		self.Direction = self.Entity:GetUp()*self.CurrentVelocity;
		--phys:SetVelocity(self.Direction);
		
		if(self.track and time > self.tracktime) then
			self.phys:EnableCollisions(true);
			
				self.target = self.Entity:FindNearestTarget(self.Entity:GetPos(),self.Entity:GetUp(), self.range, self.cone)
				
			
			if self.target and self.target != nil  then
				print("Found Target")
				local dir = self.target:GetPos()-pos;
				local range = dir:Length();
				local normdir = dir:GetNormal();
				if(range > 250) then
					self.Direction = (normdir*self.Randomness+self.Entity:GetVelocity():GetNormalized()*self.AntiRandomness)*self.CurrentVelocity;
					--phys:SetVelocity(self.Direction);
					--phys:SetAngles(dir:Angle() + Angle(90,0,0))
				else
					self.Direction = normdir*(self.CurrentVelocity);
					--phys:SetVelocity(self.Direction);
					--phys:SetAngles(dir:Angle() + Angle(90,0,0))
					if(range < 100) then
						self:StartTouch(self.target)
					end
				end
				
					local angleTest = dir:Angle()
						
				local t={
							secondstoarrive = 2,
							pos = pos+self.Direction,
							maxangular = 3000,
							maxangulardamp = 10000,
							maxspeed = 100000,
							maxspeeddamp = 12000,
							dampfactor = .5,
							teleportdistance = 700000,
							angle = normdir:Angle():Normalize(),
							deltatime = deltatime,
						}
						
					phys:ComputeShadowControl(t);
			else
				phys:SetVelocity(self.Direction);
			end
					
			
				
		else
			phys:SetVelocity(self.Direction);
		end
	else
		self.Entity:Blow()	
	end

end

function ENT:StartTouch(ent)
	self.PhysicsUpdate = function() end
	local vel = self.Entity:GetVelocity():GetNormalized()*140
	local pos = self.Entity:GetPos()
	local tr = util.TraceLine({start=pos-vel,endpos=pos+vel,filter={self.Entity,owner}})
	if (ent:IsWorld() || ent:IsPlayer() || ent:IsNPC() || string.find(ent:GetClass(), "func_") == 1 || tr.HitSky) then
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetStart(self.Entity:GetPos())
		util.Effect( "Explosion", effectdata )
		self.exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
		self.Entity:Remove()
		return
	end
	
	
			
				self.attack = cbt_hcgexplode( self.Entity:GetPos(), self.radius, self.damage, self.perice, tr.HitPos)
						--position, radius, damage, pierce, trace
		
	
	
	if (self.attack == 0) then
		self.exploded = true
		brokedshell = ents.Create("prop_physics")
		brokedshell:SetPos(self.Entity:GetPos())
		brokedshell:SetAngles(self.Entity:GetAngles())
		brokedshell:SetKeyValue( "model", self.model )
		brokedshell:PhysicsInit( SOLID_VPHYSICS )
		brokedshell:SetMoveType( MOVETYPE_VPHYSICS )
		brokedshell:SetSolid( SOLID_VPHYSICS )
		brokedshell:Activate()
		brokedshell:Spawn()
		brokedshell:Fire("Kill", "", 10)
		local phys = brokedshell:GetPhysicsObject()  	
		if (phys:IsValid()) then  
			phys:SetVelocity(self.Direction * 10000)
		end
	elseif (self.attack == 1) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
	elseif (self.attack == 2) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, 150)
	end
	self.exploded = true
	self.Entity:Remove()
end

function ENT:PhysicsCollide(data)
	if(data and data.HitEntity and data.HitEntity:IsWorld()) then
		self:StartTouch(data.HitEntity);
	end
end

function ENT:Blow()

local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetStart(self.Entity:GetPos())
		util.Effect( "Explosion", effectdata )
		self.exploded = true
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
		self.Entity:Remove()

end

function ENT:OnRemove()
	if self.target and self.target:IsValid() then
		self.target:SetColor(255,255,255,255)
	end
	self.Sound:Stop()
	if self.FireTrail then
		self.FireTrail:Remove()
	end
end


function ENT:FindNearestTarget(pos, dir,  range, cone)
    print("Ran Find Target")
	local lowrange = range;
    local nearestEnt;
	local entlist =  cbt_findincone(pos,dir,range,cone)
	--local tableString = table.ToString(entlist)
	--print(tableString)
	
	for _, entity in pairs( entlist ) do
        print("Ran For Loop")
        local distance = pos:Distance( entity:GetPos() );
        if( entity and entity:IsValid() and entity != self.Entity and entity:GetClass() == "prop_physics" and distance <= lowrange ) then
            
            nearestEnt = entity;
            lowrange = distance;
			--print("entity found")
            
        end
        
    end
    
    return nearestEnt;
    
end