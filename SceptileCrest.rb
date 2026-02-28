# ===========================================
# Sceptile Crest Mod
# Effects:
# - Dragon STAB
# - Gains Dragon resistances (Fire, Water, Grass, Electric) but NOT weaknesses
# - Attack and SpAtk base stats are swapped
# - Unburden: +1 Speed on entry
# - Overgrow: +1 Attack on entry
# ===========================================

PBStuff::POKEMONTOCREST[:SCEPTILE] = :SCEPTILECREST

$cache.items[:SCEPTILECREST] = ItemData.new(:SCEPTILECREST, {
  name: "Sceptile Crest",
  desc: "A crest of ancient forest dragons. Grants Dragon resistances, swaps offensive stats, and empowers its abilities.",
  price: 0,
  crest: true,
  noUseInBattle: true,
  noUse: true,
})

TextureOverrides.registerTextureOverride(TextureOverrides::ICONS + "sceptilecrest", TextureOverrides::MODBASE + "sceptilecrest")


class PokeBattle_Battler
  alias :sceptile_crest_old_crestStats :crestStats
  def crestStats
    if @crested == :SCEPTILE
      @attack, @spatk = @spatk, @attack
    end
    sceptile_crest_old_crestStats
  end
end


class PokeBattle_Battler
  alias :sceptile_crest_old_switchin :pbAbilitiesOnSwitchIn
  def pbAbilitiesOnSwitchIn(onactive)
    sceptile_crest_old_switchin(onactive)
    if @crested == :SCEPTILE && onactive
      if self.ability == :UNBURDEN
        if self.pbCanIncreaseStatStage?(PBStats::SPEED, false)
          self.pbIncreaseStatBasic(PBStats::SPEED, 1)
          @battle.pbCommonAnimation("StatUp", self, nil)
          @battle.pbDisplay(_INTL("{1} blazes forth, unburdened and unstoppable!", self.pbThis))
        end
      elsif self.ability == :OVERGROW
        if self.pbCanIncreaseStatStage?(PBStats::ATTACK, false)
          self.pbIncreaseStatBasic(PBStats::ATTACK, 1)
          @battle.pbCommonAnimation("StatUp", self, nil)
          @battle.pbDisplay(_INTL("{1} drew strength from the earth itself!", self.pbThis))
        end
      end
    end
  end
end


class PokeBattle_Move
  alias :sceptile_crest_old_calc_damage :pbCalcDamage
  def pbCalcDamage(attacker, opponent, options=0, hitnum: 0)
    damage = sceptile_crest_old_calc_damage(attacker, opponent, options, hitnum: hitnum)
    if attacker.crested == :SCEPTILE && pbType(attacker) == :DRAGON
      damage *= 1.5
    end
    return damage
  end
end


class PokeBattle_Move
  alias :sceptile_crest_old_typemod :pbTypeModMessages
  def pbTypeModMessages(type, attacker, opponent)
    typemod = sceptile_crest_old_typemod(type, attacker, opponent)
    if opponent.crested == :SCEPTILE
      typemod /= 2 if [:FIRE, :WATER, :GRASS, :ELECTRIC].include?(type)
    end
    return typemod
  end
end
