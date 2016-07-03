AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
--include('entities/base_wire_entity/init.lua')
include('shared.lua')

function ENT:Initialize()  

	self.exploded = false;
	self.armed = true;
	self.flightvector = self.Entity:GetUp() * self.speed
	self.Entity:SetModel( self.model );
	self.Entity:PhysicsInit( SOLID_VPHYSICS );      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS );        -- CHEESECAKE!    >:3        
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	self.Randomness = math.random(3,9)/10;
	self.AntiRandomness = 1-self.Randomness;
	self.CurrentVelocity = 400;
	self.phys = self.Entity:GetPhysicsObject();
	self.target = nil;
	self.lock = nil;
	self.hasdamagecase = true;
	
	
	if(self.phys:IsValid()) then
		self.phys:Wake();
		self.phys:SetMass(20);
		self.phys:EnableGravity(false);
		self.phys:EnableDrag(false);
		self.phys:EnableCollisions(false);
		self.phys:SetVelocity(self.Entity:GetUp()*self.CurrentVelocity);
	end

	self.Sound = CreateSound( self.Entity, Sound( "weapons/rpg/rocket1.wav" ) ) ;
 	self.Sound:Play();
	self.tracktime = CurTime() + self.ttime;
	self.timerRunning = false;
end   

function ENT:PhysicsUpdate(phys,deltatime)
	local time = CurTime();
	
	if((self.LastPhysicsUpdate or 0) + 0.07 >= time) then return end;
	
	self.LastPhysicsUpdate = time;
	
	if(self.fuel > 0)  then
		--print(self.CurrentVelocity)
		self.fuel = self.fuel-1; 
		local pos = self.Entity:GetPos();
		if(self.CurrentVelocity < self.speed) then
			self.CurrentVelocity = math.Clamp(self.CurrentVelocity+self.acell,0,self.speed);
		end;
		self.Direction = self.Entity:GetUp()*self.CurrentVelocity;
		--phys:SetVelocity(self.Direction);
		
		if(self.track and time > self.tracktime) then
			self.phys:EnableCollisions(true);
				
				--if not self.target or self.target == nil then
				self.target = self.Entity:FindNearestTarget(self.Entity:GetPos(),self.Entity:GetUp(), self.range, self.cone);
				--end
			
			if self.target and self.target != nil  then
				local dir = self.target:GetPos()-pos;
				local range = dir:Length();
				local normdir = dir:GetNormal();
				if(range > 350) then
					self.Direction = (dir:GetNormalized()*self.Randomness+self.Entity:GetVelocity():GetNormalized()*self.AntiRandomness)*self.CurrentVelocity;
					
				else
					self.Direction = dir*(self.CurrentVelocity);
					
					if(range < 100) then
						self:StartTouch(self.target);
					end;
				end;
				
						
				local t={
							secondstoarrive = 1,
							pos = pos+self.Direction,
							maxangular = 30000000,
							maxangulardamp = 100000000,
							maxspeed = 10000000,
							maxspeeddamp = 1000000,
							dampfactor = 0.2,
							teleportdistance = 0,
							angle = dir:Angle()+ self.parent.anglechange,
							deltatime = deltatime,
						}
						
					phys:ComputeShadowControl(t);
			else
				phys:SetVelocity(self.Direction);
			end;	
				
		else
			phys:SetVelocity(self.Direction);
		end;
	else
		self.Entity:Blow();	
	end;
end;

function ENT:StartTouch(ent)
	self.PhysicsUpdate = function() end;
	local vel = self.Entity:GetVelocity():GetNormalized()*140;
	local pos = self.Entity:GetPos();
	local tr = util.TraceLine({start=pos-vel,endpos=pos+vel,filter={self.Entity,owner}});
	
	if (ent:IsWorld() || ent:IsPlayer() || ent:IsNPC() || string.find(ent:GetClass(), "func_") == 1 || tr.HitSky) then
		self.Entity:Blow();	
		return
	end;
	
	self.attack = cbt_fragcone( self.Entity:GetPos(), self.Entity:GetVelocity():GetNormalized(), self.radius, 180, self.damage, self.perice);
	--position, radius, damage, pierce, trace
	
	self.Entity:Blow();
end

function ENT:PhysicsCollide(data)
	if(data and data.HitEntity and data.HitEntity:IsWorld()) then
		self:StartTouch(data.HitEntity);
	end
end

function ENT:Blow()

local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos());
		effectdata:SetStart(self.Entity:GetPos());
		util.Effect( "Explosion", effectdata );
		self.exploded = true;
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50);
		self.Entity:Remove();
end

function ENT:OnRemove()
	self.Sound:Stop();
	if self.FireTrail then
		self.FireTrail:Remove();
	end;
end

function ENT:FindNearestTarget(pos, dir,  range, cone)
	local lowrange = range;
    local nearestEnt;
	local entlist =  cbt_findincone(pos,dir,range,cone);
	for _, entity in pairs( entlist ) do
        local distance = pos:Distance( entity:GetPos() );
        if( entity and entity:IsValid() and entity != self.Entity and entity:GetClass() == "prop_physics" and distance <= lowrange ) then   
            nearestEnt = entity;
            lowrange = distance;        
        end;   
    end;
    return nearestEnt;
end

function ENT:gcbt_breakactions(damage, pierce)
	self.Entity:Blow();	
end