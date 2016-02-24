-- Gunpowder Tower class (Dark + Earth)
-- Splash damage tower that does 30/150/750 damage with 1500 range and 0.66 attack speed with 100/200 AoE.
-- Upon impact the projectile splits into four more projectiles that scatter in a diagonal pattern (100 range from center, so one top, one bottom, one on each side)
-- around the impact point. Additional projectiles have same damage/AoE.

GunpowderTower = createClass({
        tower = nil,
        towerClass = "",

        constructor = function(self, tower, towerClass)
            self.tower = tower    
            self.towerClass = towerClass or self.towerClass    
        end
    },
    {
        className = "GunpowderTower"    
    },
nil)    

function GunpowderTower:OnAttackLanded(keys) 
    local target = keys.target    
    local origin = target:GetAbsOrigin()
    local particle = ParticleManager:CreateParticle("particles/custom/towers/gunpowder/shrapnel.vpcf", PATTACH_CUSTOMORIGIN, self.tower)    
    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, Vector(self.splashAOE, 1, 1))
    Timers:CreateTimer(1.3, function() ParticleManager:DestroyParticle(particle, true) end)
      
    keys.caster:EmitSound("Gunpower.Explosion")

    local damage = ApplyAbilityDamageFromModifiers(self.splashDamage[self.tower:GetLevel()], self.tower)    
    DamageEntitiesInArea(target:GetOrigin(), self.splashAOE, self.tower, damage)

    --spawn random explosions around the initial point, after a small delay
    local rotate_pos = origin + Vector(1,0,0) * 100
    Timers:CreateTimer(0.3, function()
        for i = 1, 4 do          
            local pos = RotatePosition(origin, QAngle(0, 90*i, 0), rotate_pos)

            if IsValidEntity(self.tower) then
                local damage = ApplyAbilityDamageFromModifiers(self.splashDamage[self.tower:GetLevel()], self.tower)    
                DamageEntitiesInArea(pos, self.splashAOE, self.tower, damage)
            end
        end
    end)
end

function GunpowderTower:OnCreated()
  self.ability = AddAbility(self.tower, "gunpowder_tower_shrapnade", self.tower:GetLevel())     
  self.splashDamage = GetAbilitySpecialValue("gunpowder_tower_shrapnade", "damage")    
  self.splashAOE = GetAbilitySpecialValue("gunpowder_tower_shrapnade", "splash_aoe")    
  self.projOrigin = self.tower:GetAttachmentOrigin(self.tower:ScriptLookupAttachment("attach_attack1"))    
end


RegisterTowerClass(GunpowderTower, GunpowderTower.className)    