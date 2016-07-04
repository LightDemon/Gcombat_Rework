
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

DEFINE_BASECLASS( "base_wire_entity" )
include('shared.lua')

function ENT:Initialize()   

	self.ammomodel = "models/props_c17/canister01a.mdl"
	self.ammos = 6
	self.armed = true
	self.reloaddelay = 10
	self.Entity:SetModel( "models/props_c17/oildrum001.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     

	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
 
	self.fire1 = "Fire"
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire"} )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire"})
	
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "NEBELWERFER" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:firewerfer()

		local ent = ents.Create( "nwerfer_rocket" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 40)
		ent:SetAngles( self.Entity:GetAngles() + Angle(math.random(-5,5),math.random(-5,5),math.random(-5,5)) )
		ent:Spawn()
		ent:Activate()

end

function ENT:TriggerInput(iname, value)

	local function time()
			Wire_TriggerOutput(self.Entity, "Can Fire", 1)
			self.armed = true
	end
	
	local function workDamnIt()
		self.Entity:firewerfer()
	
	end

	if (iname == self.fire1 and value == 1) then
		if (self.armed) then
			self.armed = false
			if not timer.Exists("Fire") then
				timer.Create("Fire", .5, self.ammos, workDamnIt)
			else
				timer.Start("Fire")
			end
			
			Wire_TriggerOutput(self.Entity, "Can Fire", 0)
			timer.Simple(self.reloaddelay, time)
		end
	end
		
end