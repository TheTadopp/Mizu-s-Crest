# ===========================================
# Flareon Crest Mod
# Effects:
# - 25% Speed boost
# - Self-inflict burn on battle entry
# - Burn heals 1/8 HP per turn instead of dealing damage
# - Normal-type STAB (stacks with original STAB)
# - Normal moves become Fire type
# - All moves scale off Attack stat instead of SpAtk
# ===========================================

PBStuff::POKEMONTOCREST[:FLAREON] = :FLAREONCREST

$cache.items[:FLAREONCREST] = ItemData.new(:FLAREONCREST, {
  name: "Flareon Crest",
  desc: "A crest burning with passion. Boosts Speed, grants Normal STAB, heals burn, and channels all power through physical Attack.",
  price: 0,
  crest: true,
  noUseInBattle: true,
  noUse: true,
})

TextureOverrides.registerTextureOverride(TextureOverrides::ICONS + "flareoncrest", TextureOverrides::MODBASE + "flareoncrest")


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
  alias :flareon_crest_old_pbType :pbType
  def pbType(attacker, type=@type)
    type = flareon_crest_old_pbType(attacker, type)
    if attacker.crested == :FLAREON && type == :NORMAL && (attacker.ability == :FLASHFIRE || attacker.ability == :GUTS)
      type = :FIRE
    end
    return type
  end
end


class PokeBattle_Move
  alias :flareon_crest_old_calc_damage :pbCalcDamage
  def pbCalcDamage(attacker, opponent, options=0, hitnum: 0)
    if attacker.crested == :FLAREON && attacker.ability == :FLASHFIRE
      # Swap spatk with attack so special moves use Attack stat
      orig_spatk = attacker.spatk
      orig_stages_spatk = attacker.stages[PBStats::SPATK]
      attacker.spatk = attacker.attack
      attacker.stages[PBStats::SPATK] = attacker.stages[PBStats::ATTACK]
      # Nullify burn so Attack debuff doesn't apply
      orig_status = attacker.status
      attacker.status = nil if attacker.status == :BURN
    end

    damage = flareon_crest_old_calc_damage(attacker, opponent, options, hitnum: hitnum)

    if attacker.crested == :FLAREON && attacker.ability == :FLASHFIRE
      attacker.spatk = orig_spatk
      attacker.stages[PBStats::SPATK] = orig_stages_spatk
      attacker.status = orig_status if defined?(orig_status)
    end

    return damage
  end
end
