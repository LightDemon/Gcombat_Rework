AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('entities/base_wire_entity/init.lua')
include('shared.lua')
function ENT:Initialize()   
	self.ammomodel = "models/combatmodels/tankshell.mdl" --Model the shell fired will use
	self.reloaddelay = 2 --Amout of time to wait between reloads
	self.fire1 = "Fire AP round" --Name of the first fire input
	self.fire2 = "Fire HE round" --Name of second fire input
	self.armed = true
	self.vectorchange = Vector(0,0,-150)
	self.speed = 4000
	self.anglechange = Angle(90,0,0)
	self.damage1 = 1000 --Base damage of shell
	self.perice1 = 7 -- Base perice chance of shell
	self.damage2 = 2000
	self.perice2 = 4
	self.attacktype = 1 --Creating attack type check so the shell knows what to do
	self.smoking = false
	self.Entity:SetModel( "models/combatmodels/tank_gun.mdl" ) 	--Model the cannon will use
	math.randomseed(CurTime()) --It's sonic, Totally sonic.
	self.infire = false --Are we fireing?
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox    
	
	self.expl = {}
	self.expl[1] = "weapons/explode3.wav"
	self.expl[2] = "weapons/explode4.wav"
	self.expl[3] = "weapons/explode5.wav"
	
	self.effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
		effectdata:SetNormal( self:GetUp() )
	self.effect = "cannon_flare"
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
		phys:SetMass( 20 ) 
	end 
	
	self.Inputs = Wire_CreateInputs( self.Entity, { self.fire1 , self.fire2 } ) --Create our wire inputs
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire" }) --Create our wire outputs
	Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	
end   

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	local ent = ents.Create( "TANK_GUN" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

--[[function ENT:Think()
	if (self.reloadtime > CurTime()) then
		self.armed = false
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	else
		self.armed = true
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
	end
end]]--

function ENT:TriggerInput(iname, value)
	if (iname == self.fire1 and value == 1) then
		if (self.armed) then
			self.Entity:fireAPshell()
		end
		return true
	end
	if (iname == self.fire2 and value == 1) then
		if (self.armed) then
			self.Entity:fireHEshell()
		end
		return true
	end
end