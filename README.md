# Rotation profiles for [NerdPack](https://github.com/MrTheSoulz/NerdPack)

## Monk: WindWalker
Mostly follows simc rotation with addition of smart rushing jade wind 'dotting' of nearby enemies and extra-ordinary checks to ensure that Hit Combo is maintained 100% of the time.

### Class options

#### General
* **Automatic Res**: Attempts to automatically resurrect dead party/raid members when out of combattime
* **5 min DPS test**: Toggle this on to stop all combat and turn off rotation engine after 5 minutes of combat. The purpose of this is to conduct repeated DPS tests

#### Survival
* **Healthstone & Healing Tonic**: Automatically use the healthstone or healing potion when the characters health falls below the specified percentage
* **Effuse**: While in combat, the health percentage threshold to cast Effuse for self-healing
* **Healing Elixir**: While in combat, the health percentage threshold to cast Healing Elixir (if talent taken) for self-healing

#### Offensive
* **SEF usage**: Enable/Disable automatic Storm, Earth & Fire usage
* **Automatic CJL at range**: Enable/Disable automatic Crackling Jade Lightning casting while the target is out of melee range - will not cast until combat has been going for at least 4 seconds
* **Automatic Chi Wave at pull**: Enable/Disable automatic casting of Chi Wave at the start of combat, if the target is out of melee range.  The idea is to start combat with a Chi Wave during the pull as the character moves into melee position
* **Automatic Mark of the Crane Dotting**: Will cast Rising Sun Kick, Blackout Kick, or Tiger Palm against nearby enemies who don't already have the 'Mark of the Crane' debuff. The reason for this is to build stacks of Rushing Jade Wind for increased damage. See [this guide](http://www.walkingthewind.com/2016/08/20/spinning-crane-kick-theorycrafting/) for details
* **Automatic CJL in melee to maintain Hit Combo**: Will weave-in instant cast/cancel of Crackling Jade Lightning during rotation as needed to maintain hit Combo buff.  See [this guide](http://www.walkingthewind.com/2016/07/26/spotlight-hit-combo-and-mastery-1/) for details


### Simulationcraft comparison

pre-legion comparison with simc (2016-08-16):
![pre-legion comparison with simc](media/simc_20160816.png)

(simc engine settings):
```
threads=2
max_time=300
vary_combat_length=0.0
fixed_time=1
enemy_death_pct=30
optimal_raid=0
override.allow_potions=0
override.allow_food=0
override.allow_flasks=0
override.bloodlust=0
```

## Monk: Brewmaster

## Demon Hunter: Havoc
Mostly follows simc rotation

## Demon Hunter: Vengeance
Mostly follows simc rotation
