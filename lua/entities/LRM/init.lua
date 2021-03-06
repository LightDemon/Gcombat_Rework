AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
--include('entities/base_wire_entity/init.lua')
include('shared.lua')
function ENT:Initialize()   
	--self.ammomodel = "models/props_c17/canister01a.mdl" --Model the shell fired will use
	self.ammomodel = "models/aamissile.mdl"
	self.reloaddelay = 4 --Amout of time to wait between reloads
	self.fire1 = "Fire" --Name of the first fire input
	
	self.fuel = 500 --how long the missile flies
	self.acell = 300 -- how fast the missile accelrates after launch
	self.track = true --is this a missile or a rocket
	self.ttime = .2  --time to fly befor tracking starts
	self.cone = 45 --field of tracking vision from center of missile
	self.range = 4000 --max tracking distance
	self.armed = true
	self.vectorchange = Vector(0,0,-90)
	self.speed = 2000 --Max speed
	self.anglechange = Angle(90,0,0)
	self.damage = 1500 --Base damage of missile
	self.perice = 7 -- Base perice chance of missile
	self.radius = 1000 --stay over 100 because we explode when we reach 100 and you will do very little damage if you only have a range of 100
	self.attacktype = 1 --Creating attack type check so the shell knows what to do
	self.smoking = false --to smoke or not to smoke, that is a question.
	self.Entity:SetModel( "models/props_c17/canister_propane01a.mdl" ) 	--Model the cannon will use
	math.randomseed(CurTime()) --It's sonic, Totally sonic.
	self.infire = false --Are we fireing?
	self.TerrainAvoid = true
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- chessecacke    
	
	
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
		phys:SetMass( 20 ) 
	end 
	
	self.Inputs = Wire_CreateInputs( self.Entity, { self.fire1} ) --Create our wire inputs
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire" }) --Create our wire outputs
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	
end   

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "LRM" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:TriggerInput(iname, value)
	if (iname == self.fire1 and value == 1) then
		if (self.armed) then
			GC_FireMissile( self.vectorchange , self.speed , self.damage , self.perice , self.ammomodel , self.fuel , self.acell , self.Owner, self.Entity , 1, self.radius, self.range, self.cone, self.track, self.ttime )
			--GC_FireMissile( Vector , Speed , Damage , Perice , AmmoModel , Fuel , Acell, Own , Self , Type , Radius , Range , Cone , Track , Ttime)
			
		end
		return true
	end
	
end