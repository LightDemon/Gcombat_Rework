AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include('shared.lua')
function ENT:Initialize()   
	self.ammomodel = "models/props_combine/breenglobe.mdl" --Model the shell fired will use
	self.reloaddelay = 4 --Amout of time to wait between reloads
	self.fire1 = "Fire" --Name of the first fire input
	self.fire2 = "Fire HE round" --Name of second fire input
	self.cont1 = 0
	self.cont2 = 0
	self.armed = true
	self.vectorchange = Vector(0,0,-200)
	self.speed = 11000
	self.anglechange = Angle(90,0,0)
	self.damage1 = 1000 --Base damage of shell
	self.perice1 = 7 -- Base perice chance of shell
	self.damage2 = 2000
	self.perice2 = 5
	self.radius1 = 0
	self.radius2 = 300
	self.attacktype = 1 --Creating attack type check so the shell knows what to do
	self.smoking = false
	self.Entity:SetModel( "models/props_trainstation/trashcan_indoor001b.mdl" ) 	--Model the cannon will use
	math.randomseed(CurTime()) --It's sonic, Totally sonic.
	self.infire = false --Are we fireing?
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox    
	
	self.expl = {}
	self.expl[1] = "weapons/explode3.wav"
	self.expl[2] = "weapons/explode4.wav"
	self.expl[3] = "weapons/explode5.wav"
	
	local data = EffectData()
		data:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 30)
		data:SetNormal( self:GetUp() )
	local effect = "cannon_flare"
          
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
	local ent = ents.Create( "MORTAR" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:TriggerInput(iname, value)
	if (iname == self.fire1 and value == 1) then
		if (self.armed) then
			GC_FireShell( self.vectorchange , self.speed , self.damage2 , self.perice2 , self.ammomodel , self.smoking , self.Owner, self.Entity , 2, self.cont2, self.radius2 )
			local data = EffectData()
				data:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
				data:SetNormal( self:GetUp() )
			local effect = "cannon_flare"
			util.Effect(effect, data )
		end
		return true
	end
end