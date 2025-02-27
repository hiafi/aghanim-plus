aghsfort_dk_elder_dragon_form = {}

LinkLuaModifier( "modifier_aghsfort_dk_elder_dragon_form", "abilities/heroes/dragon_knight/elder_dragon_form", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_elder_dragon_form_corrosive", "abilities/heroes/dragon_knight/elder_dragon_form", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_elder_dragon_form_frost", "abilities/heroes/dragon_knight/elder_dragon_form", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_elder_dragon_form_attack", "abilities/heroes/dragon_knight/elder_dragon_form", LUA_MODIFIER_MOTION_NONE )

function aghsfort_dk_elder_dragon_form:GetIntrinsicModifierName()
	return "modifier_aghsfort_dk_elder_dragon_form_attack"
end

function aghsfort_dk_elder_dragon_form:OnSpellStart()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(
		caster, self, "modifier_aghsfort_dk_elder_dragon_form", { duration = duration }
	)

	if not self:GetCaster():HasAbility("aghsfort_dk_elder_dragon_form_fear") then return end

	local shard = self:GetCaster():FindAbilityByName("aghsfort_dk_elder_dragon_form_fear")
	local radius = shard:GetLevelSpecialValueFor("radius",1)
	local fear_duration = shard:GetLevelSpecialValueFor("duration",1)
	local breaths = shard:GetLevelSpecialValueFor("breaths",1)

	local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			caster,
			self,
			"modifier_aghsfort_ursa_enrage_fear",
			{ duration = fear_duration }
		)
	end

	if not caster:FindAbilityByName("aghsfort_dk_breathe_fire"):IsTrained() then return end

	local rotate_angle = 360 / breaths
	for i = 1,breaths do
		local left_qangle = QAngle(0,  i * rotate_angle, 0)
		local point = RotatePosition(caster:GetAbsOrigin(), left_qangle, caster:GetAbsOrigin() + caster:GetForwardVector() * 500)				

		caster:SetCursorPosition(point)
		caster:FindAbilityByName("aghsfort_dk_breathe_fire"):OnSpellStart()
	end
end


function aghsfort_dk_elder_dragon_form:Corrosive( target )
	target:AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_aghsfort_dk_elder_dragon_form_corrosive",
		{ duration = self:GetSpecialValueFor( "corrosive_breath_duration" ) }
	)
end

function aghsfort_dk_elder_dragon_form:Splash( target, damage )
	if self:GetCaster():HasModifier("modifier_aghsfort_dk_dragon_tail_attack") then
		return
		-- if we're casting dragon tail which is already AoE, we dont want the splash
	end

	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		target:GetOrigin(),
		nil,
		self:GetSpecialValueFor( "splash_radius" ),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- 
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		if enemy~=target then
			local damageTable = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = damage * self:GetSpecialValueFor( "splash_damage_percent" )/100,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self,
			}
			ApplyDamage(damageTable)

			self:Corrosive( enemy )
		end
	end
end

function aghsfort_dk_elder_dragon_form:Frost( target )
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),
		target:GetOrigin(),
		nil,
		self:GetSpecialValueFor( "frost_aoe" ),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		0,
		false
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_aghsfort_dk_elder_dragon_form_frost",
			{ duration = self:GetSpecialValueFor( "frost_duration" ) }
		)
	end
end

function aghsfort_dk_elder_dragon_form:OnProjectileHit( target, location )
	if not target then return end

	if self:GetCaster():HasAbility("aghsfort_dk_elder_dragon_form_attack") then
		self:GetCaster():PerformAttack(target, false, true, true, true, false, false, false)
	end
	return true
end


modifier_aghsfort_dk_elder_dragon_form = {}

modifier_aghsfort_dk_elder_dragon_form.effect_data = {
	[1] = {
		["projectile"] = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_corrosive.vpcf",
		["attack_sound"] = "Hero_DragonKnight.ElderDragonShoot1.Attack",
		["transform"] = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf",
		["scale"] = 0,
	},
	[2] = {
		["projectile"] = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf",
		["attack_sound"] = "Hero_DragonKnight.ElderDragonShoot2.Attack",
		["transform"] = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf",
		["scale"] = 10,
	},
	[3] = {
		["projectile"] = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_frost.vpcf",
		["attack_sound"] = "Hero_DragonKnight.ElderDragonShoot3.Attack",
		["transform"] = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf",
		["scale"] = 20,
	},
	[4] = {
		["projectile"] = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_frost.vpcf",
		["attack_sound"] = "Hero_DragonKnight.ElderDragonShoot3.Attack",
		["transform"] = "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf",
		["scale"] = 50,
	}
}

function modifier_aghsfort_dk_elder_dragon_form:IsHidden() 	return false end
function modifier_aghsfort_dk_elder_dragon_form:IsDebuff() 	return false end
function modifier_aghsfort_dk_elder_dragon_form:IsPurgable() 	return false end

function modifier_aghsfort_dk_elder_dragon_form:OnCreated( kv )
	self.parent = self:GetParent()

	self.level = self:GetAbility():GetLevel()
	if self.parent:HasScepter() then
		self.level = self.level + 1
	end
	self.bonus_ms = self:GetAbility():GetSpecialValueFor( "bonus_movement_speed" )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_attack_damage" )
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "bonus_attack_range" )

	local range_bonus = self:GetAbility():GetCaster():FindAbilityByName("special_bonus_aghsfort_dk_elder_dragon_form+bonus_attack_range"):GetSpecialValueFor("value")
	if range_bonus ~= nil then
		self.bonus_range = self.bonus_range + range_bonus
	end
	print(self.bonus_range)

	self.magic_resist = 0

	self.corrosive_duration = self:GetAbility():GetSpecialValueFor( "corrosive_breath_duration" )
	
	self.splash_radius = self:GetAbility():GetSpecialValueFor( "splash_radius" )
	self.splash_pct = self:GetAbility():GetSpecialValueFor( "splash_damage_percent" )/100
	
	self.frost_radius = self:GetAbility():GetSpecialValueFor( "frost_aoe" )
	self.frost_duration = self:GetAbility():GetSpecialValueFor( "frost_duration" )

	if self.level==4 then
		self.bonus_range = self.bonus_range + 100
		self.splash_pct = self.splash_pct * 1.5
		self.magic_resist = 30
	end

	if not IsServer() then return end

	self.parent:SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )

	self:StartIntervalThink( 0.03 )
	self.projectile = self.effect_data[self.level].projectile
	self.attack_sound = self.effect_data[self.level].attack_sound
	self.scale = self.effect_data[self.level].scale

	self:PlayEffects()

	EmitSoundOn( "Hero_DragonKnight.ElderDragonForm", self.parent )
end

function modifier_aghsfort_dk_elder_dragon_form:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_aghsfort_dk_elder_dragon_form:OnDestroy()
	if not IsServer() then return end

	self.parent:SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )

	self:PlayEffects()

	EmitSoundOn( "Hero_DragonKnight.ElderDragonForm.Revert", self.parent )
end

function modifier_aghsfort_dk_elder_dragon_form:OnIntervalThink()
	self.parent:SetSkin( self.level-1 )
end

function modifier_aghsfort_dk_elder_dragon_form:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierBaseAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierAttackRangeBonus()
	return self.bonus_range
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierModelChange()
	return "models/heroes/dragon_knight/dragon_knight_dragon.vmdl"
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierModelScale()
	return self.scale
end

function modifier_aghsfort_dk_elder_dragon_form:GetAttackSound()
	return self.attack_sound
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierProjectileName()
	return self.projectile
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierProjectileSpeedBonus()
	return 900
end

function modifier_aghsfort_dk_elder_dragon_form:GetModifierProcAttack_Feedback( params )
	if params.target:GetTeamNumber()==self.parent:GetTeamNumber() then return end

	if self.level==1 then
		self:GetAbility():Corrosive( params.target )
	elseif self.level==2 then
		self:GetAbility():Corrosive( params.target )
		self:GetAbility():Splash( params.target, params.damage )
	elseif self.level==3 then
		self:GetAbility():Corrosive( params.target )
		self:GetAbility():Splash( params.target, params.damage )
		self:GetAbility():Frost( params.target )
	else
		self:GetAbility():Corrosive( params.target )
		self:GetAbility():Splash( params.target, params.damage )
		self:GetAbility():Frost( params.target )
	end

	EmitSoundOn( "Hero_DragonKnight.ProjectileImpact", params.target )
end


function modifier_aghsfort_dk_elder_dragon_form:PlayEffects()
	local particle_cast = self.effect_data[self.level].transform

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

modifier_aghsfort_dk_elder_dragon_form_corrosive = {}

function modifier_aghsfort_dk_elder_dragon_form_corrosive:IsHidden() 		return false end
function modifier_aghsfort_dk_elder_dragon_form_corrosive:IsDebuff() 		return true end
function modifier_aghsfort_dk_elder_dragon_form_corrosive:IsStunDebuff() 	return false end
function modifier_aghsfort_dk_elder_dragon_form_corrosive:IsPurgable() 	return false end

function modifier_aghsfort_dk_elder_dragon_form_corrosive:OnCreated( kv )
	local damage = self:GetAbility():GetSpecialValueFor( "corrosive_breath_damage" )

	local level = self:GetAbility():GetLevel()
	if self:GetCaster():HasScepter() then
		level = level + 1
	end
	if level==4 then
		damage = damage*1.5
	end

	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(),
	}

	if not IsServer() then return end
	self:StartIntervalThink( 1 )
end

function modifier_aghsfort_dk_elder_dragon_form_corrosive:OnRefresh( kv )
	local damage = self:GetAbility():GetSpecialValueFor( "corrosive_breath_damage" )

	local level = self:GetAbility():GetLevel()
	if self:GetCaster():HasScepter() then
		level = level + 1
	end
	if level==4 then
		damage = damage*1.5
	end

	self.damageTable.damage = damage
end

function modifier_aghsfort_dk_elder_dragon_form_corrosive:OnIntervalThink()
	ApplyDamage(self.damageTable)
end

function modifier_aghsfort_dk_elder_dragon_form_corrosive:GetEffectName()
	return "particles/units/heroes/hero_dragon_knight/dragon_knight_corrosion_debuff.vpcf"
end

function modifier_aghsfort_dk_elder_dragon_form_corrosive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


modifier_aghsfort_dk_elder_dragon_form_frost = {}

function modifier_aghsfort_dk_elder_dragon_form_frost:IsHidden() 		return false end
function modifier_aghsfort_dk_elder_dragon_form_frost:IsDebuff() 		return true end
function modifier_aghsfort_dk_elder_dragon_form_frost:IsStunDebuff() 	return false end
function modifier_aghsfort_dk_elder_dragon_form_frost:IsPurgable() 	return false end

function modifier_aghsfort_dk_elder_dragon_form_frost:OnCreated( kv )
	self.frost_as = self:GetAbility():GetSpecialValueFor( "frost_bonus_attack_speed" )
	self.frost_ms = self:GetAbility():GetSpecialValueFor( "frost_bonus_movement_speed" )

	local level = self:GetAbility():GetLevel()
	if self:GetCaster():HasScepter() then
		level = level + 1
	end
	if level==4 then
		self.frost_as = self.frost_as*1.5
		self.frost_ms = self.frost_ms*1.5
	end

end

function modifier_aghsfort_dk_elder_dragon_form_frost:OnRefresh( kv )
	self.frost_as = self:GetAbility():GetSpecialValueFor( "frost_bonus_attack_speed" )
	self.frost_ms = self:GetAbility():GetSpecialValueFor( "frost_bonus_movement_speed" )	
end

function modifier_aghsfort_dk_elder_dragon_form_frost:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_aghsfort_dk_elder_dragon_form_frost:GetModifierMoveSpeedBonus_Percentage()
	return self.frost_ms
end
function modifier_aghsfort_dk_elder_dragon_form_frost:GetModifierAttackSpeedBonus_Constant()
	return self.frost_as
end

function modifier_aghsfort_dk_elder_dragon_form_frost:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost.vpcf"
end


---------------------

modifier_aghsfort_dk_elder_dragon_form_attack	= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,		
	RemoveOnDeath  			= function(self) return false end,		
})

function modifier_aghsfort_dk_elder_dragon_form_attack:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_aghsfort_dk_elder_dragon_form_attack:OnCreated()
	if not IsServer() or not self:GetCaster():HasAbility("aghsfort_dk_elder_dragon_form_attack") then return end

	self.radius = self:GetParent():FindAbilityByName("aghsfort_dk_elder_dragon_form_attack"):GetLevelSpecialValueFor("radius",1)
	self.attack_count = self:GetParent():FindAbilityByName("aghsfort_dk_elder_dragon_form_attack"):GetLevelSpecialValueFor("attack",1)

	self.current_attack = 0
end

function modifier_aghsfort_dk_elder_dragon_form_attack:OnAttackLanded(params)
	if not IsServer()  or not params.target or not self:GetCaster():HasAbility("aghsfort_dk_elder_dragon_form_attack") or params.attacker ~= self:GetParent() or params.no_attack_cooldown then return end

	if not self.radius or not self.attack_count or not self.current_attack then
		self:OnCreated()
	end

	if self:GetParent():HasModifier("modifier_aghsfort_dk_elder_dragon_form") then
		local mod = self:GetParent():FindModifierByName("modifier_aghsfort_dk_elder_dragon_form")
		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), params.target:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )
		
		if #enemies > 1 then
			local new_target = nil

			for _,enemy in pairs(enemies) do
				if enemy ~= params.target then
					new_target = enemy
				end
			end

			if new_target then
				local info = {
					Target = new_target,
					Source = params.target,
					Ability = self:GetAbility(),
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
					EffectName = mod.projectile,
					iMoveSpeed = 900,
					bDodgeable = true,
				}
				ProjectileManager:CreateTrackingProjectile(info)
			end
		end
	else
		if self.current_attack >= self.attack_count then
			self.current_attack = 0
			local level = self:GetAbility():GetLevel()
			if level==1 then
				self:GetAbility():Corrosive( params.target )
			elseif level==2 then
				self:GetAbility():Corrosive( params.target )
				self:GetAbility():Splash( params.target, params.damage )
			elseif level==3 then
				self:GetAbility():Corrosive( params.target )
				self:GetAbility():Splash( params.target, params.damage )
				self:GetAbility():Frost( params.target )
			end
			
			local particle = ParticleManager:CreateParticle( "particles/econ/items/invoker/glorious_inspiration/invoker_forge_spirit_death_esl_explode.vpcf", PATTACH_POINT_FOLLOW, params.target )
			ParticleManager:SetParticleControlEnt( particle, 3, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true )
			EmitSoundOn( "Hero_DragonKnight.ProjectileImpact", params.target )
		else
			self.current_attack = self.current_attack + 1
		end
	end
end


function modifier_aghsfort_dk_elder_dragon_form_attack:OnTakeDamage(params)
	if not IsServer() then return end
	if params.unit == self:GetParent() and params.attacker and params.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and self:GetCaster():HasAbility("aghsfort_dk_elder_dragon_form_cdr") then
		if not self:GetAbility():IsCooldownReady() then
			local cd = self:GetAbility():GetCooldownTimeRemaining()
			local reduction = self:GetCaster():FindAbilityByName("aghsfort_dk_elder_dragon_form_cdr"):GetLevelSpecialValueFor("cdr",1)
			cd = math.max(0, cd - reduction)
			self:GetAbility():EndCooldown()
			self:GetAbility():StartCooldown(cd)			
		end

		if self:GetAbility():IsCooldownReady() then
			if params.damage >= self:GetParent():GetHealth() then
				local heal = self:GetParent():GetMaxHealth() / 100 * self:GetCaster():FindAbilityByName("aghsfort_dk_elder_dragon_form_cdr"):GetLevelSpecialValueFor("heal",1)
				self:GetParent():Heal(heal, self:GetAbility())
				self:GetAbility():OnSpellStart()
				self:GetAbility():StartCooldown(self:GetAbility():GetEffectiveCooldown(self:GetAbility():GetLevel()))
				
				local particle = ParticleManager:CreateParticle( "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_fireblast.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
				ParticleManager:SetParticleControlEnt( particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
				ParticleManager:ReleaseParticleIndex(particle)

				EmitSoundOn( "DOTA_Item.PhoenixAsh.Cast", self:GetParent() )
			end
		end
	end
end
