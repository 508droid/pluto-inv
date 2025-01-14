SWEP.PrintName = "M14"

SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/cod4/weapons/v_m14.mdl"
SWEP.WorldModel = "models/cod4/weapons/w_m14.mdl"

SWEP.Slot = 2

SWEP.UseHands = false
SWEP.HoldType = "ar2"

SWEP.Base = "weapon_ttt_cod4_base"

SWEP.Primary.Sound = "Weapon_CoD4_M14.Single"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo          = "357"
SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 1 / 6
SWEP.HeadshotMultiplier = 40 / SWEP.Primary.Damage

SWEP.Primary.RecoilTiming = 0.1

SWEP.Sights = true

sound.Add {
	name = "Weapon_CoD4_M14.Single",
	channel = CHAN_WEAPON,
	level = 80,
	volume = 0.5,
	sound = "cod4/weapons/m14/weap_m14_slst_5.ogg"
}

sound.Add {
	name = "Weapon_CoD4_M14.Chamber",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/m14/wpfoly_m14_reload_chamber_v1.ogg"
}

sound.Add {
	name = "Weapon_CoD4_M14.ClipIn",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/m14/wpfoly_m14_reload_clipin_v1.ogg"
}

sound.Add {
	name = "Weapon_CoD4_M14.ClipInTac",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/m14/wpfoly_m14_reload_clipin_tac_v1.ogg"
}

sound.Add {
	name = "Weapon_CoD4_M14.ClipOut",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/m14/wpfoly_m14_reload_clipout_v1.ogg"
}

sound.Add {
	name = "Weapon_CoD4_M14.Lift",
	channel = CHAN_ITEM,
	volume = 0.5,
	sound = "cod4/weapons/m14/wpfoly_m14_reload_lift_v1.ogg"
}

SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(-25, -4),
	Angle(-25, -3),
	Angle(-25, 4),
	Angle(-25, 2),
}

SWEP.Ironsights = {
	TimeTo = 0.1,
	TimeFrom = 0.15,
	SlowDown = 0.6,
	Zoom = 0.8,
}

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 1500,
	DamageDropoffRangeMax = 3500,
	DamageMinimumPercent = 0.8,
	Spread = Vector(0.01, 0.01),
}

SWEP.AutoSpawnable = true

SWEP.Ortho = {2, -4}
