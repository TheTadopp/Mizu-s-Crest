# ===========================================
# Furfrou Crest Mod
# Effects:
# - Natural Form (form 0): 20% Attack boost
# - 1.7x multiplier on Dark moves (stacks with original STAB)
# - Roar lowers switched-in Pokemon's Attack by 2 stages
# ===========================================

PBStuff::POKEMONTOCREST[:FURFROU] = :FURFROUCREST

$cache.items[:FURFROUCREST] = ItemData.new(:FURFROUCREST, {
  name: "Furfrou Crest",
  desc: "A regal crest for Furfrou. Boosts Attack, empowers Dark moves, and Roar intimidates switch-ins.",
  price: 0,
  crest: true,
  noUseInBattle: true,
  noUse: true,
})


class PokeBattle_Battler
  alias :furfrou_crest_old_crestStats :crestStats
  def crestStats
    if @crested == :FURFROU && @form == 0
      @attack = (@attack * 1.2).floor
    end
    furfrou_crest_old_crestStats
  end
end


class PokeBattle_Move_0EB
  alias :furfrou_crest_old_roar_effect :pbEffect
  def pbEffect(attacker, opponent, hitnum=0, alltargets=nil, showanimation=true)
    if attacker.crested == :FURFROU && attacker.form == 0 && @move == :ROAR
      @battle.furfrou_roar = opponent.index
    end
    furfrou_crest_old_roar_effect(attacker, opponent, hitnum, alltargets, showanimation)
  end
end


class PokeBattle_Battler
  alias :furfrou_crest_old_switchin :pbAbilitiesOnSwitchIn
  def pbAbilitiesOnSwitchIn(onactive)
    furfrou_crest_old_switchin(onactive)
    if onactive && @battle.respond_to?(:furfrou_roar) && @battle.furfrou_roar == @index
      @battle.furfrou_roar = nil
      if self.pbCanReduceStatStage?(PBStats::ATTACK, false)
        self.pbReduceStat(PBStats::ATTACK, 2, abilitymessage: false)
        @battle.pbDisplay(_INTL("The regal roar left {1} intimidated!", self.pbThis))
      end
    end
  end
end


class PokeBattle_Move
  alias :furfrou_crest_old_calc_damage :pbCalcDamage
  def pbCalcDamage(attacker, opponent, options=0, hitnum: 0)
    damage = furfrou_crest_old_calc_damage(attacker, opponent, options, hitnum: hitnum)
    if attacker.crested == :FURFROU && attacker.form == 0 && pbType(attacker) == :DARK
      damage *= 1.7
    end
    return damage
  end
end


class PokeBattle_Battle
  attr_accessor :furfrou_roar

  alias :furfrou_crest_old_battle_init :initialize
  def initialize(*args)
    furfrou_crest_old_battle_init(*args)
    @furfrou_roar = nil
  end
end
