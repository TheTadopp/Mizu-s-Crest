# ===========================================
# Flareon Crest Mod
# Effects:
# - 25% Speed boost
# - Self-inflict burn on battle entry
# - Burn heals 1/8 HP per turn instead of dealing damage
# - Normal-type STAB (stacks with original STAB)
# ===========================================

# ---- crestStats: Speed boost ----
class PokeBattle_Battler
  alias flareon_crest_crestStats crestStats
  def crestStats
    flareon_crest_crestStats
    if @crested == :FLAREON
      @speed *= 1.25
    end
  end
end

# ---- pbInitialize: Self-burn on entry ----
class PokeBattle_Battler
  alias flareon_crest_initialize pbInitialize
  def pbInitialize(pkmn, index, batonpass)
    flareon_crest_initialize(pkmn, index, batonpass)
    if @crested == :FLAREON
      self.status = :BURN
    end
  end
end

# ---- pbAbilitiesOnSwitchIn: Display burn message on entry ----
class PokeBattle_Battler
  alias flareon_crest_switchin pbAbilitiesOnSwitchIn
  def pbAbilitiesOnSwitchIn(onactive)
    flareon_crest_switchin(onactive)
    if onactive && @crested == :FLAREON && self.status == :BURN
      @battle.pbDisplay(_INTL("{1} is burning with passion!", self.pbThis))
    end
  end
end

# ---- Burn healing via pbContinueStatus flag ----
# When Flareon's burn tick fires, we flag it so the subsequent
# pbReduceHP call is intercepted and turned into healing instead.
class PokeBattle_Battler
  alias flareon_crest_continue_status pbContinueStatus
  def pbContinueStatus
    if self.status == :BURN && self.crested == :FLAREON
      @flareon_burn_tick = true
    end
    flareon_crest_continue_status
  end

  alias flareon_crest_reduce_hp pbReduceHP
  def pbReduceHP(amt, anim=false, emercheck=true)
    if @flareon_burn_tick && self.crested == :FLAREON
      @flareon_burn_tick = false
      hp = (self.totalhp / 8.0).floor
      pbRecoverHP(hp, true)
      @battle.pbDisplay(_INTL("{1} is healed by its burn!", self.pbThis))
      return 0
    end
    flareon_crest_reduce_hp(amt, anim, emercheck)
  end
end

# ---- pbCalcDamage: Normal-type STAB ----
class PokeBattle_Move
  alias flareon_crest_calc_damage pbCalcDamage
  def pbCalcDamage(attacker, opponent, options=0, hitnum: 0)
    damage = flareon_crest_calc_damage(attacker, opponent, options, hitnum: hitnum)
    if attacker.crested == :FLAREON
      type = pbType(attacker)
      if type == :NORMAL
        damage *= 1.5
      end
    end
    return damage
  end
end
