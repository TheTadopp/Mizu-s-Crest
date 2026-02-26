# ===========================================
# Flareon Crest Mod
# Effects:
# - 25% Speed boost
# - Self-inflict burn on battle entry
# - Burn heals 1/8 HP per turn instead of dealing damage
# - Normal-type STAB (stacks with original STAB)
# ===========================================

PBStuff::POKEMONTOCREST[:FLAREON] = :FLAREONCREST

$cache.items[:FLAREONCREST] = ItemData.new(:FLAREONCREST, {
  name: "Flareon Crest",
  desc: "A crest burning with passion. Boosts Speed, grants Normal STAB, and heals burn damage.",
  price: 0,
  crest: true,
  noUseInBattle: true,
  noUse: true,
})


class PokeBattle_Battler
  alias :flareon_crest_old_crestStats :crestStats
  def crestStats
    if @crested == :FLAREON
      @speed = (@speed * 1.25).floor
    end
    flareon_crest_old_crestStats
  end
end


class PokeBattle_Battler
  alias :flareon_crest_old_initialize :pbInitialize
  def pbInitialize(pkmn, index, batonpass)
    flareon_crest_old_initialize(pkmn, index, batonpass)
    if @crested == :FLAREON
      self.status = :BURN
    end
  end
end


class PokeBattle_Battler
  alias :flareon_crest_old_switchin :pbAbilitiesOnSwitchIn
  def pbAbilitiesOnSwitchIn(onactive)
    flareon_crest_old_switchin(onactive)
    if onactive && @crested == :FLAREON && self.status == :BURN
      @battle.pbDisplay(_INTL("{1} is burning with passion!", self.pbThis))
    end
  end
end


class PokeBattle_Battler
  alias :flareon_crest_old_continue_status :pbContinueStatus
  def pbContinueStatus
    if self.status == :BURN && self.crested == :FLAREON
      @flareon_burn_tick = true
    end
    flareon_crest_old_continue_status
  end

  alias :flareon_crest_old_reduce_hp :pbReduceHP
  def pbReduceHP(amt, anim=false, emercheck=true)
    if @flareon_burn_tick && self.crested == :FLAREON
      @flareon_burn_tick = false
      hp = (self.totalhp / 8.0).floor
      pbRecoverHP(hp, true)
      @battle.pbDisplay(_INTL("{1} is healed by its burn!", self.pbThis))
      return 0
    end
    flareon_crest_old_reduce_hp(amt, anim, emercheck)
  end
end


class PokeBattle_Move
  alias :flareon_crest_old_calc_damage :pbCalcDamage
  def pbCalcDamage(attacker, opponent, options=0, hitnum: 0)
    damage = flareon_crest_old_calc_damage(attacker, opponent, options, hitnum: hitnum)
    if attacker.crested == :FLAREON && pbType(attacker) == :NORMAL
      damage *= 1.5
    end
    return damage
  end
end
