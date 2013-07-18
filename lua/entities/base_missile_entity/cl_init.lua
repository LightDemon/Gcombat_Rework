 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 function ENT:Draw()      
 --self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering.        
	--self.Entity:DrawModel()       // Draw the model.  
local roll = math.Rand(-90,90)
local normal = (self.Entity:GetForward() * -1):GetNormalized();
local partical = ParticleEmitter( self.Entity:GetPos())
local fx = partical:Add("sprites/heatwave",self.Entity:GetPos()+(self.Entity:GetUp()*-1)*60);
			fx:SetVelocity(normal*2);
			fx:SetDieTime(0.2);
			fx:SetStartAlpha(255);
			fx:SetEndAlpha(255);
			fx:SetStartSize(30);
			fx:SetEndSize(10);
			fx:SetColor(255,255,255);
			fx:SetRoll(roll);
	

	
			local fx2 = partical:Add("effects/fire_cloud1",self.Entity:GetPos()+(self.Entity:GetUp()*-1)*60);
			fx2:SetVelocity(normal*2);
			fx2:SetDieTime(0.1);
			fx2:SetStartAlpha(255);
			fx2:SetEndAlpha(255);
			fx2:SetStartSize(40);
			fx2:SetEndSize(5);
			fx2:SetColor(math.Rand(235,255),math.Rand(235,255),195);
			fx2:SetRoll(roll);
			partical:Finish()
			self.Entity:DrawModel() 
	
 end  