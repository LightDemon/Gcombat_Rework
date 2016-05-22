
COMBATDAMAGEENGINE = 1

gcombat = {}

function gcombat.registerent( ent, health, armor )
	local h = ent:GetPhysicsObject():GetMass() * 4
	ent.cbt = {};
	ent.cbt.health = health or math.Clamp( h, 1, 4000 )
	ent.cbt.armor = armor or 8
	ent.cbt.maxhealth = health or math.Clamp( h, 1, 4000 )
end

function gcombat.validate( ent )

	if (ent:GetPhysicsObject():IsValid() and !ent:IsPlayer() and ent:GetClass() != "wreckedstuff" and !ent:IsWorld() and !ent:IsWeapon() and string.find(ent:GetClass(), "func_") != 1 and !ent:IsNPC() ) then
		if ent.cbt then return true else gcombat.registerent(ent) end
		return true
	end
	return false
end

function gcombat.devhit( entity, damage, pierce, src, dest)
	local valid = gcombat.validate(entity)
	if valid then
		local armornum = pierce + math.random(0, 6)
		local work = normal
		local damnit = hitnormal
		if armornum < entity.cbt.armor then return 0 end
		--if trace != nil then
		--local angle = work:DotProduct(damnit)
			--if angle > -0.87 then
				--	return 0 
			--end
		--end
		if ((entity.cbt.health) < damage) then
			if (entity.hasdamagecase == true) then
				entity:gcbt_breakactions(damage, pierce)
				return 1
			else
				return 2
			end
		else
			entity.cbt.health = entity.cbt.health - damage
			return 1
		end
	end
end

cbt_dealdevhit = gcombat.devhit

--cbt_dealhcghit deals a hollow charge style hit to the object.
function gcombat.hcghit( entity, damage, pierce, src, dest )

	local attack = gcombat.devhit( entity, damage, pierce, src, dest )
	
	
	
	if attack == 2 then
		 local tmp = entity:GetModel()
		local wreck = ents.Create( "wreckedstuff" )
		wreck:SetModel( entity:GetModel() )
		wreck:SetAngles( entity:GetAngles() )
		wreck:SetPos( entity:GetPos() )
		wreck:Spawn()
		wreck:Activate()
		entity:Remove()
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "Explosion", effectdata1 )
		
	elseif attack == 1 then

		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "HelicopterMegaBomb", effectdata1 )

	elseif attack == 0 then

		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "RPGShotDown", effectdata1 )
		
	end

return attack
end

cbt_dealhcghit = gcombat.hcghit

--cbt_dealnrghit deals an energy weapon hit to the object.
function gcombat.nrghit( entity, damage, pierce, src, dest)

	local attack = cbt_dealdevhit( entity, damage, pierce )

	if attack == 2 then

		local wreck = ents.Create( "wreckedstuff" )
		wreck:SetModel( entity:GetModel() )
		wreck:SetAngles( entity:GetAngles() )
		wreck:SetPos( entity:GetPos() )
		wreck:Spawn()
		wreck:Activate()
		wreck.deathtype = 1
		entity:Remove()
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "cball_bounce", effectdata1 )

	elseif attack == 1 then

		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		util.Effect( "ener_succeed", effectdata1 )
		
	elseif attack == 0 then
		
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		util.Effect( "ener_fail", effectdata1 )

	end

return attack

end

cbt_dealnrghit = gcombat.nrghit

--this is how you do explosions, and is in here more as an example than anything else.
function gcombat.hcgexplode( position, radius, damage, pierce, trace)

	local targets = ents.FindInSphere( position, radius)
	local tooclose = ents.FindInSphere( position, 5)
	
	for _,i in pairs(targets) do
		
		
		
		local tracedata = {}
		tracedata.start = position
		tracedata.endpos = i:LocalToWorld( i:OBBCenter( ) )
		--tracedata.filter = tooclose
		tracedata.mask = MASK_SOLID
		local trace = util.TraceLine(tracedata) 
		
		
		
		if trace.Entity == i then
			local hitat = trace.HitPos
			cbt_dealhcghit( i, damage, pierce, hitat, hitat, trace)
		end
	end
	
	
end

cbt_hcgexplode = gcombat.hcgexplode

function gcombat.nrgexplode( position, radius, damage, pierce)

	local targets = ents.FindInSphere( position, radius)
	
	for _,i in pairs(targets) do
		local hitat = i:NearestPoint( position )
		cbt_dealnrghit( i, damage, pierce, hitat, hitat)

	end
end

cbt_nrgexplode = gcombat.nrgexplode

--this is new, lol. It is what you should be using to heat things up.
function gcombat.applyheat(ent, temp)
	--nothing. this is kept here so that everything that used to use heat doesn't break.
end

cbt_applyheat = gcombat.applyheat

--Use this function to emit area heat. Input 0 to the fourth argument to have it heat up the prop emitting it as well.
function gcombat.emitheat( position, radius, temp, own)
	--nothing. this is kept here so that everything that used to use heat doesn't break.
end

cbt_emitheat = gcombat.emitheat

--This allows you to set a prop's armor.
function gcombat.modifyarmor( entity, armor )
	
	local index = entity.cbt.index
	local core = entity.cbt.core
	core.ppt[index].armor = def

end

cbt_modifyarmor = gcombat.modifyarmor

function gcombat.repair(entity, amount)
	if entity != nil then
		if entity:IsValid()  then
			if not entity:IsWorld() and not entity:IsPlayer() then
				if entity.cbt != nil then
					entity.cbt.health = math.Clamp(entity.cbt.health + amount , 10 , entity.cbt.maxhealth)
				end
			end	
		end
	end
end 

cbt_repair = gcombat.repair

function gcombat.repairarea(pos, area, amount)
	local targets = ents.FindInSphere( pos, area)

	for _,v in pairs(targets) do
		
		cbt_repair( v.Entity, amount)
	end
end 

cbt_repairarea = gcombat.repairarea

--The built in FindinCone is bugged
function gcombat.findincone(pos, dir, dist, ang) 
    local ent = ents.GetAll() 
	local coneEnts = {}
    for k,v in pairs (ent) do 
        local targetVec = (v:GetPos() - pos):GetNormal()
		local angle = math.abs(math.acos(dir:DotProduct(targetVec)))
		local range = pos:Distance(v:GetPos())
        if math.deg(angle) <= ang or range <= dist then 
            table.insert(coneEnts, v) 
        end 
    end 
	
	local tableString = table.ToString(coneEnts)
	
	
    return coneEnts 
end 

cbt_findincone = gcombat.findincone

--do damage in a cone
function gcombat.fragcone( position, direction, distance, angle, damage, pierce)

	local targets = cbt_findincone( position, direction, distance, angle)
	--local tooclose = FindinCone2( position, direction, 5, angle)
	
	for _,i in pairs(targets) do
			local hitat = i:GetPos()
			cbt_dealhcghit( i, damage, pierce, hitat, hitat)
		
	end
	
	
end

cbt_fragcone = gcombat.fragcone

--finds the angle that the shell hit the prop.
function gcombat.hitangle( Normal, HitNormal)
	local angle = Normal:DotProduct(HitNormal)
	PrintMessage( HUD_PRINTCONSOLE, "angle " .. angle )
	return angle
end

cbt_hitangle = gcombat.hitangle

function GC_FireShell( Vector , Speed , Damage , Perice , AmmoModel , Smoking , Own , Self , Type, Count, Radius)
		local ent = ents.Create( "base_shell_entity" )
		ent:SetPos( Self:GetPos() +  Self:GetUp() * 60)
		ent:SetAngles( Self:GetAngles() )
		
		
		ent.vectorchange = Vector 
		ent.speed = Speed
		ent.damage =  Damage 
		ent.perice = Perice
		ent.model = AmmoModel
		ent.smoking = Smoking
		ent.attacktype = Type
		ent.Owner = Own
		ent.cont = Count
		ent.radius = Radius
		
		ent:Spawn()
		ent:Initialize()
		ent:Activate()
		Self.armed = false
		local function time()
			Wire_TriggerOutput(Self, "Can Fire", 1)
			Self.armed = true
		end
		Wire_TriggerOutput(Self, "Can Fire", 0)
		timer.Simple(Self.reloaddelay, time)
		
		local phys = Self:GetPhysicsObject()  	
			if (phys:IsValid()) then  		
				phys:AddVelocity( Self:GetUp() * -800 ) 
			end
		
				
				local maxtable = #Self.expl
				Self:EmitSound(Self.expl[ math.random(1,maxtable) ] , 160, 130 ) 		
end

function GC_FireMissile( vector2 , Speed , Damage , Perice , AmmoModel , Fuel , Acell, Own , Self , Type , Radius , Range , Cone , Track , Ttime)
		local ent = ents.Create( "base_missile_entity" )
		ent:SetPos( Self:GetPos())
		ent:SetAngles( Self:GetAngles() )
		
		
		ent.vectorchange = vector2 
		ent.speed = Speed
		ent.damage =  Damage 
		ent.perice = Perice
		ent.model = AmmoModel
		ent.fuel = Fuel
		ent.acell = Acell
		ent.Owner = Own
		ent.attacktype = Type
		ent.radius = Radius
		ent.range = Range
		ent.cone = Cone
		ent.track = Track
		ent.ttime = Ttime
		
		
		
		ent:Spawn()
		ent:Initialize()
		ent:Activate()
		Self.armed = false
		local function time()
			Wire_TriggerOutput(Self, "Can Fire", 1)
			Self.armed = true
		end
		Wire_TriggerOutput(Self, "Can Fire", 0)
		timer.Simple(Self.reloaddelay, time)
		
		local phys = Self:GetPhysicsObject()  	
			if (phys:IsValid()) then  		
				phys:AddVelocity( Self:GetUp() * -800 ) 
			end				
end



