# ===========================================
# Maractus Crest Mod
# Effects:
# - Sets sun on entry
# - Poisons attacker when hit by a physical move
# - If ability is Chlorophyll: raises SpAtk, SpDef, and Def by 1 on entry
#   (in addition to Chlorophyll's normal Speed boost in sun)
# ===========================================

PBStuff::POKEMONTOCREST[:MARACTUS] = :MARACTUSCREST

$cache.items[:MARACTUSCREST] = ItemData.new(:MARACTUSCREST, {
  name: "Maractus Crest",
  desc: "A crest blooming with desert heat. Sets sun, poisons on contact, and empowers Chlorophyll.",
  price: 0,
  crest: true,
  noUseInBattle: true,
  noUse: true,
})

TextureOverrides.registerTextureOverride(TextureOverrides::ICONS + "maractuscrest", TextureOverrides::MODBASE + "maractuscrest")


class PokeBattle_Battler
  alias :maractus_crest_old_switchin :pbAbilitiesOnSwitchIn
  def pbAbilitiesOnSwitchIn(onactive)
    maractus_crest_old_switchin(onactive)
    if @crested == :MARACTUS && onactive
      # Set sun
      if !@battle.state.effects[:HeavyRain] &&
         !@battle.state.effects[:HarshSunlight] &&
         @battle.weather != :SUNNYDAY &&
         !(@battle.weather == :STRONGWINDS && @battle.pbCheckGlobalAbility(:DELTASTREAM))
        rainbowhold = 0
        if @battle.weather == :RAINDANCE
          rainbowhold = 5
          rainbowhold = 8 if self.hasWorkingItem(:HEATROCK)
        end
        @battle.weather = :SUNNYDAY
        @battle.weatherduration = 5
        @battle.weatherduration = 8 if self.hasWorkingItem(:HEATROCK)
        @battle.pbCommonAnimation("Sunny", nil, nil)
        @battle.pbDisplay(_INTL("{1}'s Crest intensified the sun's rays!", pbThis))
      end

      if self.ability == :CHLOROPHYLL
        boosted = false
        if self.pbCanIncreaseStatStage?(PBStats::SPATK, false)
          self.pbIncreaseStatBasic(PBStats::SPATK, 1)
          boosted = true
        end
        if self.pbCanIncreaseStatStage?(PBStats::SPDEF, false)
          self.pbIncreaseStatBasic(PBStats::SPDEF, 1)
          boosted = true
        end
        if self.pbCanIncreaseStatStage?(PBStats::DEFENSE, false)
          self.pbIncreaseStatBasic(PBStats::DEFENSE, 1)
          boosted = true
        end
        if boosted
          @battle.pbCommonAnimation("StatUp", self, nil)
          @battle.pbDisplay(_INTL("{1}'s Chlorophyll was supercharged by the crest!", pbThis))
        end
      end
    end
  end
end

class PokeBattle_Move
  alias :maractus_crest_old_pbEffect :pbEffect
  def pbEffect(attacker, opponent, hitnum=0, alltargets=nil, showanimation=true)
    result = maractus_crest_old_pbEffect(attacker, opponent, hitnum, alltargets, showanimation)
    if opponent.crested == :MARACTUS &&
       pbIsPhysical?(pbType(attacker)) &&
       !attacker.isFainted? &&
       attacker.pbCanPoison?(false) &&
       pbIsContact?(attacker) &&
       attacker.ability != :MAGICGUARD &&
       !(attacker.ability == :WONDERGUARD && @battle.FE == :COLOSSEUM)
      attacker.pbPoison(opponent)
      @battle.pbDisplay(_INTL("{1}'s spikes poisoned {2}!", opponent.pbThis, attacker.pbThis(true)))
    end
    return result
  end
end
