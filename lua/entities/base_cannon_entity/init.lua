include('shared.lua')
function ENT:fireAPshell()
		local ent = ents.Create( "base_shell_entity" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 60)
		ent:SetAngles( self.Entity:GetAngles() )
		
		
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
		self.armed = false
		local function time()
			Wire_TriggerOutput(self.Entity, "Can Fire", 1)
			self.armed = true
		end
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
		timer.Simple(self.reloaddelay, time)
		
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:AddVelocity( self:GetUp() * -800 ) 
		end
		
		util.Effect( self.effect, effectdata )
		local maxtable = #self.expl
		self:EmitSound(self.expl[ math.random(1,maxtable) ] , 160, 130 ) 
end

function ENT:fireHEshell()
		local ent = ents.Create( "base_shell_entity" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 60)
		ent:SetAngles( self.Entity:GetAngles() )
		
		
		ent.vectorchange = self.vectorchange 
		ent.speed = self.speed
		ent.damage =  self.damage2
		ent.perice = self.perice2
		ent.model = self.ammomodel 
		ent.smoking = self.smoking
		ent.attacktype = 2
		ent.Owner = self.Owner
		if self.cont != nil then
			ent.cont = self.cont
		else
			ent.cont = 0
		end
		
		ent:Spawn()
		ent:Initialize()
		ent:Activate()
		self.armed = false
		local function time()
			Wire_TriggerOutput(self.Entity, "Can Fire", 1)
			self.armed = true
		end
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
		timer.Simple(self.reloaddelay, time)
		
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:AddVelocity( self:GetUp() * -800 ) 
		end
		
		
		util.Effect( self.effect, effectdata )
		local maxtable = #self.expl
		self:EmitSound(self.expl[ math.random(1,maxtable) ] , 160, 130 )
end
