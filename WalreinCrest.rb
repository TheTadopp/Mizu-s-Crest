# ===========================================
# Walrein Crest Mod
# Effects:
# - On entry: SpDef and Def drop by 1.5x, SpAtk and Atk raise by 1.5x
# - Thick Fat now resists Fire by 1/8 instead of 1/2
# - Steel-type STAB (stacks with original STAB)
# ===========================================

PBStuff::POKEMONTOCREST[:WALREIN] = :WALREINCREST

$cache.items[:WALREINCREST] = ItemData.new(:WALREINCREST, {
  name: "Walrein Crest",
  desc: "A crest of icy ferocity. Trades defense for offense, sharpens Thick Fat, and grants Steel STAB.",
  price: 0,
  crest: true,
  noUseInBattle: true,
  noUse: true,
})

TextureOverrides.registerTextureOverride(TextureOverrides::ICONS + "walreincrest", TextureOverrides::MODBASE + "walreincrest")

class PokeBattle_Battler
  alias :walrein_crest_old_switchin :pbAbilitiesOnSwitchIn
  def pbAbilitiesOnSwitchIn(onactive)
    walrein_crest_old_switchin(onactive)
    if @crested == :WALREIN && onactive
      # Drop Def and SpDef by 1 stage each
      if self.pbCanReduceStatStage?(PBStats::DEFENSE, false)
        self.pbReduceStat(PBStats::DEFENSE, 1, abilitymessage: false)
      end
      if self.pbCanReduceStatStage?(PBStats::SPDEF, false)
        self.pbReduceStat(PBStats::SPDEF, 1, abilitymessage: false)
      end

      boosted = false
      if self.pbCanIncreaseStatStage?(PBStats::ATTACK, false)
        self.pbIncreaseStatBasic(PBStats::ATTACK, 1)
        boosted = true
      end
      if self.pbCanIncreaseStatStage?(PBStats::SPATK, false)
        self.pbIncreaseStatBasic(PBStats::SPATK, 1)
        boosted = true
      end
      if boosted
        @battle.pbCommonAnimation("StatUp", self, nil)
      end
      @battle.pbDisplay(_INTL("{1} trades defense for raw power!", self.pbThis))
    end
  end
end


class PokeBattle_Move
  alias :walrein_crest_old_calc_damage :pbCalcDamage
  def pbCalcDamage(attacker, opponent, options=0, hitnum: 0)
    damage = walrein_crest_old_calc_damage(attacker, opponent, options, hitnum: hitnum)

    # Steel STAB for Walrein Crest
    if attacker.crested == :WALREIN && pbType(attacker) == :STEEL
      damage *= 1.5
    end

    return damage
  end


  alias :walrein_crest_old_atkmult :pbCalcDamageMultipliers rescue nil
end


class PokeBattle_Move
  alias :walrein_crest_old_pbReduceHPDamage :pbReduceHPDamage
  def pbReduceHPDamage(damage, attacker, opponent)

    type = pbType(attacker)
    if opponent.crested == :WALREIN && opponent.ability == :THICKFAT && type == :FIRE && !opponent.moldbroken

      damage = walrein_crest_old_pbReduceHPDamage(damage, attacker, opponent)
      damage = (damage * 1.75).floor
      return damage
    end
    walrein_crest_old_pbReduceHPDamage(damage, attacker, opponent)
  end
end
