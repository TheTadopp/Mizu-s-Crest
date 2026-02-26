# ===========================================
# Furfrou Crest Mod
# Effects:
# - Natural Form (form 0): 20% Attack boost
# - 1.7x multiplier on Dark moves (stacks with original STAB)
# - Roar lowers switched-in Pokemon's Attack by 2 stages
# ===========================================

# ---- crestStats: Attack boost ----
class PokeBattle_Battler
  alias furfrou_crest_crestStats crestStats
  def crestStats
    furfrou_crest_crestStats
    if @crested == :FURFROU && @form == 0
      @attack *= 1.2
    end
  end
end

# ---- Roar: set flag when Furfrou uses it ----
class PokeBattle_Move_0EB
  alias furfrou_crest_roar_effect pbEffect
  def pbEffect(attacker, opponent, hitnum=0, alltargets=nil, showanimation=true)
    if attacker.crested == :FURFROU && attacker.form == 0 && @move == :ROAR
      @battle.furfrou_roar = opponent.index
    end
    furfrou_crest_roar_effect(attacker, opponent, hitnum, alltargets, showanimation)
  end
end

# ---- Switch-in: apply Attack drop if flag is set ----
class PokeBattle_Battler
  alias furfrou_crest_switchin pbAbilitiesOnSwitchIn
  def pbAbilitiesOnSwitchIn(onactive)
    furfrou_crest_switchin(onactive)
    if onactive && @battle.respond_to?(:furfrou_roar) && @battle.furfrou_roar == @index
      @battle.furfrou_roar = nil
      if self.pbCanReduceStatStage?(PBStats::ATTACK, false)
        self.pbReduceStat(PBStats::ATTACK, 2, abilitymessage: false)
        @battle.pbDisplay(_INTL("The regal roar left {1} intimidated!", self.pbThis))
      end
    end
  end
end

# ---- pbCalcDamage: Dark STAB multiplier ----
class PokeBattle_Move
  alias furfrou_crest_calc_damage pbCalcDamage
  def pbCalcDamage(attacker, opponent, options=0, hitnum: 0)
    damage = furfrou_crest_calc_damage(attacker, opponent, options, hitnum: hitnum)
    # Apply 1.7x Dark STAB for Furfrou Crest (Natural Form only)
    if attacker.crested == :FURFROU && attacker.form == 0
      type = pbType(attacker)
      if type == :DARK
        damage *= 1.7
      end
    end
    return damage
  end
end

# ---- PokeBattle_Battle: add furfrou_roar attribute ----
class PokeBattle_Battle
  attr_accessor :furfrou_roar

  alias furfrou_crest_battle_init initialize
  def initialize(*args)
    furfrou_crest_battle_init(*args)
    @furfrou_roar = nil
  end
end
