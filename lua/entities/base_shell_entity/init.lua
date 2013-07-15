AddCSLuaFile( "shared.lua" )
AddCSLuaFile("cl_init.lua")
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
	
	self.Phys = self.Entity:GetPhysicsObject()
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:Wake()
		self.Phys:EnableGravity(true)
        self.Phys:EnableDrag(true)
        self.Phys:EnableCollisions(true)
	end

	if (self.smoking == false) then
		self.smoking = true
	
		self.FireTrail = ents.Create("env_fire_trail")
		self.FireTrail:SetKeyValue("spawnrate","3")
		self.FireTrail:SetKeyValue("firesprite","sprites/firetrail.spr" )
		self.FireTrail:SetPos(self.Entity:GetPos())
		self.FireTrail:SetParent(self.Entity)
		self.FireTrail:Spawn()
		self.FireTrail:Activate()
	end 
end   

function ENT:PhysicsUpdate( phys )
	local time = CurTime();
        if((self.LastPhysicsUpdate or 0) + 0.07 >= time) then return end;
        self.LastPhysicsUpdate = time;
		self.flightvector = self.flightvector + self.vectorchange
		self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
		local t={
            secondstoarrive = 1,
            pos = self.Entity:GetPos() + self.flightvector,
            maxangular = 50000,
            maxangulardamp = 100,
            maxspeed = 100000000,
            maxspeeddamp = 100,
            dampfactor = 0.2,
            teleportdistance = 70000,
            angle = self.Entity:GetAngles(),
            deltatime = deltatime,
                        }
                        phys:ComputeShadowControl(t);				
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
		self.Entity:Remove()
		return
	end
	
	if tr.Normal:DotProduct(tr.HitNormal) > -0.87 and math.random(1,3) > 2 then 
		self.attack = 0 
		else
			if self.attacktype == 1 then
				self.attack = cbt_dealhcghit( ent, self.damage1, self.perice, tr.HitPos, tr.HitPos)
			elseif self.attacktype == 2 then
				self.attack = cbt_hcgexplode( self.Entity:GetPos(), self.radius, self.damage2,  self.perice2, tr.HitPos)
		end
	end
	
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
			phys:SetVelocity(self.flightvector * 10000)
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

function ENT:OnRemove()
	if self.cont > 0 then
		local ent = ents.Create( "base_shell_entity" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 60)
		ent:SetAngles( self.Entity:GetAngles() )
		
		ent.cont = self.cont - 1
		ent.vectorchange = self.vectorchange 
		ent.speed = self.speed
		ent.damage =  self.damage1 
		ent.perice = self.perice1 
		ent.model = self.ammomodel 
		ent.smoking = self.smoking
		ent.attacktype = 1
		ent.Owner = self.Owner
		
		ent:Spawn()
		ent:Initialize()
		ent:Activate()
	end
	
	if self.FireTrail then
		self.FireTrail:Remove()
	end
end