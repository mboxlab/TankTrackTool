tanktracktool = {}

if SERVER then

	AddCSLuaFile("tanktracktool/util.lua")
	AddCSLuaFile("tanktracktool/netvar.lua")
	AddCSLuaFile("tanktracktool/property.lua")

	AddCSLuaFile("tanktracktool/client/render/mode.lua")
	AddCSLuaFile("tanktracktool/client/render/effects.lua")
	AddCSLuaFile("tanktracktool/client/render/autotracks.lua")

	AddCSLuaFile("tanktracktool/client/derma/editor/editor.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/node.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/node_category.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/array.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/bitfield.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/checkbox.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/color.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/combo.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/generic.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/instance.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/number.lua")
	AddCSLuaFile("tanktracktool/client/derma/editor/controls/vector.lua")

	include("tanktracktool/netvar.lua")
	include("tanktracktool/property.lua")

end

if CLIENT then

	include("tanktracktool/util.lua")
	include("tanktracktool/netvar.lua")
	include("tanktracktool/property.lua")

	include("tanktracktool/client/render/mode.lua")
	include("tanktracktool/client/render/effects.lua")
	include("tanktracktool/client/render/autotracks.lua")

	include("tanktracktool/client/derma/editor/editor.lua")
	include("tanktracktool/client/derma/editor/node.lua")
	include("tanktracktool/client/derma/editor/node_category.lua")
	include("tanktracktool/client/derma/editor/controls/array.lua")
	include("tanktracktool/client/derma/editor/controls/bitfield.lua")
	include("tanktracktool/client/derma/editor/controls/checkbox.lua")
	include("tanktracktool/client/derma/editor/controls/color.lua")
	include("tanktracktool/client/derma/editor/controls/combo.lua")
	include("tanktracktool/client/derma/editor/controls/generic.lua")
	include("tanktracktool/client/derma/editor/controls/instance.lua")
	include("tanktracktool/client/derma/editor/controls/number.lua")
	include("tanktracktool/client/derma/editor/controls/vector.lua")
	hook.Add("InitPostEntity", "Meteor.TankTool.optimize", function()

		local eyePos = Vector()

		hook.Add("RenderScene", "Meteor.TankTool.optimize", function(vec)
			eyePos = vec
		end)

		local limit = 3200000
		local ents = {"sent_tanktracks_legacy", "sent_tanktracks_auto", "sent_suspension_shock", "sent_suspension_spring", "sent_point_beam"}
		for _, key in ipairs(ents) do
			local ENT = scripted_ents.GetStored(key)

			if ENT then
				ENT = ENT["t"]
				ENT._Think, ENT._Draw = ENT._Think or ENT.Think, ENT._Draw or ENT.Draw
				ENT.Distance, ENT.GetNextThink = 0, 0

				ENT.Think = function(self)
					local is_faggot = self.GetNextThink > CurTime()

					if is_faggot then
						return
					else
						self.Distance = eyePos:DistToSqr(self:GetPos())

						if self.Distance > limit then
							self.GetNextThink = CurTime() + 1

							return
						end
					end

					return ENT._Think(self)
				end

				ENT.Draw = function(self)
					if self.Distance > limit then
						return
					end

					return ENT._Draw(self)
				end

				scripted_ents.Register(ENT, key)
			end
		end
	end)

end

do
	local flags = {edit = 2, data = 4, link = 8, ents = 16}
	local bits = 0
	local note = 0

	tanktracktool.loud_edit = flags.edit
	tanktracktool.loud_data = flags.data
	tanktracktool.loud_link = flags.link
	tanktracktool.loud_ents = flags.ents

	local c0 = Color(255, 255, 0)
	local c1 = Color(255, 255, 255)

	function tanktracktool.note(...)
		note = (note + 1) % 64000
		local msg = table.concat({...}, "\n")
		MsgC(c0, string.format("tanktracktool[%d]", note), "\n", c1, msg, "\n")
	end

	function tanktracktool.loud(flag)
		return bit.band(bits, flag) == flag
	end

	local function setFlag(flag)
		if not (bit.band(bits, flag) == flag) then
			bits = bit.bor(bits, flag)
		end
	end

	local function unsetFlag(flag)
		if bit.band(bits, flag) == flag then
			bits = bit.band(bits, bit.bnot(flag))
		end
	end

	concommand.Add("tanktracktool_loud", function(ply, cmd, args)
		if not args then
			bits = 0
			return
		end

		bits = 0
		note = 0

		local valid
		for k, v in pairs(args) do
			if flags[v] then
				setFlag(flags[v])
				valid = true
			end
		end

		if not valid then
			bits = 0
		end
	end)
end
