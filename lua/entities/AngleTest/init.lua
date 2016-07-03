AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()  
	self.Entity:SetModel( "models/aamissile.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3        
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	self.phys = self.Entity:GetPhysicsObject()
	if(self.phys:IsValid()) then
		self.phys:Wake()
		self.phys:SetMass(20)
		self.phys:EnableGravity(false);
		self.phys:EnableDrag(false);
		self.phys:EnableCollisions(false);
		
	end
	self.target = nil
	self.ShadowParams = {}
end   

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "AngleTest" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:PhysicsUpdate(phys,deltatime)
	local time = CurTime();
	if((self.LastPhysicsUpdate or 0) + 0.07 >= time) then return end;
	
	
	self.LastPhysicsUpdate = time;

	if not self.target or self.target == nil then
		self.target = self.Entity:FindNearestTarget(self.Entity:GetPos(),self.Entity:GetUp(), 2000, 360)
	end
	
	if self.target and self.target != nil then
		local pos = self.Entity:GetPos()
		local targetpos = self.target:GetPos()
		local vector2 = targetpos - pos
		local normdir = vector2:GetNormal()
		local angle = vector2:Angle() +Angle(90,0,0)
		print(vector2)
		print(normdir)
		print(angle)
		

		self.ShadowParams.secondstoarrive = 1 // How long it takes to move to pos and rotate accordingly - only if it could move as fast as it want - damping and max speed/angular will make this invalid ( Cannot be 0! Will give errors if you do )
			self.ShadowParams.pos = pos  // Where you want to move to
			self.ShadowParams.angle = angle // Angle you want to move to
			self.ShadowParams.maxangular = 5000 //What should be the maximal angular force applied
			self.ShadowParams.maxangulardamp = 10000 // At which force/speed should it start damping the rotation
			self.ShadowParams.maxspeed = 1000000 // Maximal linear force applied
			self.ShadowParams.maxspeeddamp = 10000// Maximal linear force/speed before damping
			self.ShadowParams.dampfactor = 0.8 // The percentage it should damp the linear/angular force if it reaches it's max amount
			self.ShadowParams.teleportdistance = 0 // If it's further away than this it'll teleport ( Set to 0 to not teleport )
			self.ShadowParams.deltatime = deltatime // The deltatime it should use - just use the PhysicsSimulate one

	
		phys:ComputeShadowControl( self.ShadowParams )
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
			print("entity found")
            
        end
        
    end
    
    return nearestEnt;
    
end


function ENT:OnRemove()
	self.target = nil
end