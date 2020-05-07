SWEP.Base				= "tfa_gun_base"
SWEP.Category				= "TFA CS:O"
SWEP.Author				= "Kamikaze"
SWEP.PrintName				= "Barret .50 Cal"
SWEP.Slot				= 2

SWEP.Primary.Sound 			= Sound "M95.Fire"
SWEP.Primary.Damage		= 65
SWEP.Primary.Automatic			= false
SWEP.Primary.Delay				= 60 / 30

SWEP.HeadshotMultiplier = 2.5

SWEP.Primary.RecoilTiming  = 0.09
SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(-75),
}

SWEP.Primary.ClipSize			= 5
SWEP.Primary.DefaultClip			= 55

SWEP.AmmoEnt               = "item_ammo_357_ttt"

SWEP.ViewModel			= "models/weapons/tfa_cso/c_m95.mdl"
SWEP.ViewModelFOV			= 80
SWEP.ViewModelFlip			= true
SWEP.UseHands = true

SWEP.WorldModel			= "models/weapons/tfa_cso/w_m95.mdl"

SWEP.HoldType 				= "ar2"

SWEP.Offset = {
	Pos = {
		Up = -5.5,
		Right = 1.25,
		Forward = 9,
	},
	Ang = {
		Up = -90,
		Right = 0,
		Forward = 170
	},
	Scale = 1.2
}

SWEP.HasScope = true


SWEP.Ironsights = {
	Pos = Vector(0, 0, -10),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.1,
	TimeFrom = 0.1,
	SlowDown = 0.3,
	Zoom = 0.35,
}

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 5300,
	DamageDropoffRangeMax = 6500,
	DamageMinimumPercent = 0.1,
}

SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(-70),
}

SWEP.Ortho = {-4, 2.5, angle = Angle(30, 180, -60)}