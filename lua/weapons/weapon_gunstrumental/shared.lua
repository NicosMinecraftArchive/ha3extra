GUNSTRUMENTAL_NUM_VARS = 50
SWEP.GUNSTRUMENTAL_NUM_VARS = GUNSTRUMENTAL_NUM_VARS

if CLIENT then
	SWEP.PrintName			= "Gunstrumental"			
	SWEP.Author				= "Hurricaaane (Ha3)"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 5
	SWEP.IconLetter			= "b"
	CreateClientConVar("ha3_gunstrumental_pattern1", "D4F4G4......A4b4D5..G4........D4G4A4b4..G4..A4..F4..D4........", true, true)
	CreateClientConVar("ha3_gunstrumental_pattern2", "G4......A4b4D5..G4......g4......G4A4b4D5b4A4G4A4b4c5D5F5G5......", true, true)
	for i = 3, SWEP.GUNSTRUMENTAL_NUM_VARS do
		CreateClientConVar("ha3_gunstrumental_pattern" .. i, "", true, true)
	end
	
	for i = 1, SWEP.GUNSTRUMENTAL_NUM_VARS do
		CreateClientConVar("ha3_gunstrumental_harmonics" .. i, "", true, true)
	end
	
	CreateClientConVar("ha3_gunstrumental_offset", "0", true, true)
	CreateClientConVar("ha3_gunstrumental_volume", "50", true, true)
	CreateClientConVar("ha3_gunstrumental_tempo", "400", true, true)
	CreateClientConVar("ha3_gunstrumental_sound", "weapons/airboat/airboat_gun_lastshot1.wav", true, true)
	
	
	CreateClientConVar("ha3_gunstrumental_offsetharmonics", "0", true, true)
	CreateClientConVar("ha3_gunstrumental_soundharmonics", "weapons/airboat/airboat_gun_lastshot2.wav", true, true)
	
end

if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	SWEP.PrimaryPatternPos = 1
	SWEP.PrimaryPatternPosSave = 1
	
end

SWEP.Category			= "Misc :: Ha3"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_superphyscannon.mdl"
SWEP.WorldModel			= "models/weapons/w_superphyscannon.mdl"
SWEP.HoldType			= "pistol"

SWEP.Primary.ClipSize		= 0
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true

--SWEP.MainSound = Sound("weapons/airboat/airboat_gun_lastshot1.wav")

function SWEP:GetPrimaryDelay()
	return 1 / ( self.Owner:GetInfoNum("ha3_gunstrumental_tempo") / 60 ) /** (0.5 + 2 - math.Clamp(self.Owner:GetVelocity():Length() / 250, 0, 2)) */
end

function SWEP:GetSecondaryDelay()
	return 0.15
end

function SWEP:Initialize() 
	--self.Weapon:SetNextPrimaryFire( CurTime() + self:GetPrimaryDelay() )
	--self.Weapon:SetNextSecondaryFire( CurTime() + self:GetSecondaryDelay() )
	
end 

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:PrimaryAttack()
	
	--self.Weapon:ShootEffects()
	
	if SERVER then
		self.Weapon:SetNextPrimaryFire( CurTime() + self:GetPrimaryDelay() )
	
		do
			local couldShoot = self:PrimaryPattern( )
			
			if couldShoot then
				
				// TOGLO
				local num_bullets = 1
				local damage = 15
				local aimcone = 0
				
				local bullet = {}
				bullet.Num 		= num_bullets
				bullet.Src 		= self.Owner:GetShootPos()
				bullet.Dir 		= self.Owner:GetAimVector()
				bullet.Spread 	= Vector( aimcone, aimcone, 0 )
				bullet.Tracer	= 1
				bullet.TracerName = "ToolTracer"
				bullet.Force	= 1
				bullet.Damage	= damage
				bullet.AmmoType = "Pistol"
			 
				self.Owner:FireBullets( bullet )
				self.Weapon:ShootEffects()
			
			end
		end
		do
			local couldShoot = self:HarmonicsPattern( )
			
			if couldShoot then
				
				// TOGLO
				local num_bullets = 1
				local damage = 5
				local aimcone = 0
				
				local bullet = {}
				bullet.Num 		= num_bullets
				bullet.Src 		= self.Owner:GetShootPos()
				bullet.Dir 		= self.Owner:GetAimVector()
				bullet.Spread 	= Vector( aimcone, aimcone, 0 )
				bullet.Tracer	= 1
				bullet.TracerName = "none"
				bullet.Force	= 1
				bullet.Damage	= damage
				bullet.AmmoType = "Pistol"
			 
				self.Owner:FireBullets( bullet )
				self.Weapon:ShootEffects()
			
			end
		end
		
		self:IncrementPattern( )
		
	end
	
	return false
end

function SWEP:SecondaryAttack()
	if SERVER then self.PrimaryPatternPosSave = self.PrimaryPatternPos end
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self:GetSecondaryDelay() )
	
	
	
	return true
end

function SWEP:Reload()
	if SERVER then
		self.PrimaryPatternPos = self.PrimaryPatternPosSave
		self:PrimaryCursorStream( )
	end
	
	return false
end


function SWEP:PrimaryCursorStream( )
	self:SetDTInt(0, self.PrimaryPatternPos - 1)
end

function SWEP:IncrementPattern( )
	local pattern = ""
	for i = 1, self.GUNSTRUMENTAL_NUM_VARS do
		pattern = pattern .. self.Owner:GetInfo("ha3_gunstrumental_pattern" .. i)
	end
	local patternLength = string.len( pattern )
	
	self.PrimaryPatternPos = self.PrimaryPatternPos + 1
	
	if self.PrimaryPatternPos >= (1 + patternLength / 2) then
		self.PrimaryPatternPos = 1
		
	end
	self:PrimaryCursorStream( )
	
end

function SWEP:PrimaryPattern( )
	local pattern = ""
	for i = 1, self.GUNSTRUMENTAL_NUM_VARS do
		pattern = pattern .. self.Owner:GetInfo("ha3_gunstrumental_pattern" .. i)
	end
	local offs    = self.Owner:GetInfoNum("ha3_gunstrumental_offset")
	
	local patternLength = string.len( pattern )
	local patternIsValid = (patternLength >= 2) and ((patternLength % 2) == 0)
	
	if not patternIsValid then return false end
	
	local sNote = string.sub( pattern, self.PrimaryPatternPos * 2 - 1, self.PrimaryPatternPos * 2)
	local pitch = self:GetTonePitch( sNote, offs )
	
	if pitch then
		self.Weapon:EmitSound( self.Owner:GetInfo("ha3_gunstrumental_sound"), self.Owner:GetInfoNum("ha3_gunstrumental_volume"), pitch )
	end
	
	return pitch ~= nil
	
end

function SWEP:HarmonicsPattern( )
	local pattern = ""
	for i = 1, self.GUNSTRUMENTAL_NUM_VARS do
		pattern = pattern .. self.Owner:GetInfo("ha3_gunstrumental_harmonics" .. i)
	end
	local offs    = self.Owner:GetInfoNum("ha3_gunstrumental_offsetharmonics")
	
	local patternLength = string.len( pattern )
	local patternIsValid = (patternLength >= 2) and ((patternLength % 2) == 0)
	
	if not patternIsValid then return false end
	
	local sNote = string.sub( pattern, self.PrimaryPatternPos * 2 - 1, self.PrimaryPatternPos * 2)
	local pitch = self:GetTonePitch( sNote, offs )
	
	if pitch then
		self.Weapon:EmitSound( self.Owner:GetInfo("ha3_gunstrumental_soundharmonics"), self.Owner:GetInfoNum("ha3_gunstrumental_volume"), pitch )
	end
	
	return pitch ~= nil
	
end

function SWEP:GetTonePitch( sNote, optiOffs )
	--print( sNote )
	if string.len( tostring(sNote) ) ~= 2 then return end
	
	local PNI = string.sub( sNote, 1, 1 )
	local PNILOW = string.lower( PNI )
	if not ( ("a" <= PNILOW) and (PNILOW <= "g") ) then return end
	-- C D F G A filter
	
	local OST = string.sub( sNote, 2, 2 )
	if not ( ("0" <= OST) and (OST <= "9") ) then return end
	
	local ISOC = PNILOW ~= PNI
	OST = tonumber( OST )
	
	--local PUSE = ( string.byte(PNILOW) - string.byte("a") - 2 ) % 7
	local PUSE = ( string.byte(PNILOW) - 97 - 2 ) % 7
	
	local PNUM = -9 + ( 12 * ( OST - 4 ) ) + PUSE * 2 + ((PUSE >= 3) and -1 or 0) + (ISOC and 1 or 0) + (optiOffs or 0)
	
	return 2 ^ ( PNUM / 12 ) * 100
	
end


function SWEP:DrawPatternSlider( sConVar, iPixelsFromTop )
	local pattern = ""
	for i = 1, self.GUNSTRUMENTAL_NUM_VARS do
		pattern = pattern .. GetConVarString(sConVar .. i)
	end
	
	local patternLength = string.len( pattern )
	
	local pos = self:GetDTInt(0) + 1
	--local sNote = string.sub( pattern, pos * 2 - 1, pos * 2)
	
	--local posTrim = patternLength - 1 - pos * 2
	/*local posTrim = ((pos-2) * 2 + patternLength / 2) % patternLength + 1
	local left = string.Left( pattern, posTrim )
	local right = string.Right( pattern, patternLength - posTrim )
	--print(left, " x " ,right)
	
	local centeredString = right .. left*/
	
	local massivecopy = (patternLength < 40) and (pattern .. pattern .. pattern) or (string.rep("  ", 32) .. pattern .. string.rep("  ", 32))
	
	
	local centeredString = string.sub( massivecopy, 64 + pos * 2 - 1 - 2*16, 64 + pos * 2  + 2*16)
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	draw.SimpleText(centeredString, "ConsoleText", ScrW() / 2, iPixelsFromTop+16, Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	surface.DrawCircle( ScrW() / 2, iPixelsFromTop+14, 8, Color( 255, 255, 255, 255 ) )
end

function SWEP:DrawHUD()
	self:DrawPatternSlider( "ha3_gunstrumental_pattern", 0)
	self:DrawPatternSlider( "ha3_gunstrumental_harmonics", 20)
	
end
