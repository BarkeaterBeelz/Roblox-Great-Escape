---------------------------------------------------
-- (c)2025 Barkeater Beelz. All rights reserved. --
---------------------------------------------------

local _file = {
	name 	= "SasquatchControlModule",
	version = "1.0",
	date 	= "2025/3/25"
}

local RunService 	= game:GetService("RunService");
local SoundService 	= game:GetService("SoundService").RideSounds.Sasquatch;
local TweenService 	= game:GetService("TweenService");

local Ride = script.Parent;

local ModeEnum = {
	InStation 		= "Waiting in station",
	MovingToStart 	= "Moving to start position",
	ReadyToStart 	= "Ready to start ride",
	Riding 			= "Riding",
	Returning 		= "Returning to station"
};

local Sounds = {
	visual 			= SoundService.VisualSound,
	clear 			= SoundService.ClearSound,
	exit 			= SoundService.ExitSound,
	launch 			= SoundService.LaunchSound
};

-------------------------------------
-- LAUNCH SIDE VARIABLES
local LaunchSide = {
	Ride 			= Ride.LaunchSide,
	mode 			= ModeEnum.InStation,
	autorun 		= false,
	seats 			= {}, -- autofill
		
	times 			= {
		prepTime 	= 10,
		flightTime 	= 3.5,
		fallTime 	= 4,
		bounceTime 	= 3,
		returnTime 	= 12,
		fallOffset 	= 20
	},
	
	blocks 			= {
		Station 	= Ride.Points:WaitForChild("LaunchStationPoint"),
		Start 		= Ride.Points:WaitForChild("LaunchStartPoint"),
		Top 		= Ride.Points:WaitForChild("LaunchHighPoint")
	},
	
	safety = {
		restraintsLocked 	= true,
		enterGateClosed 	= true,
		exitGateClosed 		= true,
		gates 				= { 
			Enter 			= Ride.Gates.LaunchEntranceGate, 
			Exit 			= Ride.Gates.LaunchExitGate 
		},
		
		-- Operator safety check
		activeHandshake 	= false,
		handshakeSuccess 	= false,
		handshakeTimer 		= 0,
	}
};
	
LaunchSide.tweens = {
	prepTweenInfo 	= TweenInfo.new(LaunchSide.times.prepTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	flightTweenInfo = TweenInfo.new(LaunchSide.times.flightTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
	fallTweenInfo	= TweenInfo.new(LaunchSide.times.fallTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
	bounceTweenInfo	= TweenInfo.new(LaunchSide.times.fallTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
	returnTweenInfo	= TweenInfo.new(LaunchSide.times.returnTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
};

for i, seat in ipairs(LaunchSide.Ride.Frame.Seats:GetDescendants()) do
	if seat:IsA("Seat") then
		
		seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			if seat.Occupant ~= nil then
				print(seat.Occupant.Name .. " sat");
				seat.Occupant.JumpPower = LaunchSide.safety.restraintsLocked and 0 or 50;
				
			end
		end);
		
		table.insert(LaunchSide.seats, seat);
	end
end

-------------------------------------
-- DROP SIDE VARIABLES
local DropSide = {
	Ride = Ride.DropSide,
	mode = ModeEnum.InStation,
	autorun = false,
	seats = {}, -- autofill
	
	times = {
		prepTime 		= 10,
		flightTime 		= 3.5,
		fallTime 		= 4,
		bounceTime 		= 3,
		returnTime 		= 12,
		fallOffset 		= 20
	},
	
	blocks = {
		--Station = Ride.Points:WaitForChild("DropStationPoint"),
		--Start 	= Ride.Points:WaitForChild("DropStartPoint"),
		--Top 	= Ride.Points:WaitForChild("DropHighPoint")
	},
	
	safety = {
		restraintsLocked = true;
	}
};
	



--for i, seat in ipairs(DropSide.Ride.Frame.Seats:GetChildren()) do
--	if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
--		table.insert(DropSide.seats, seat);
--	end
--end

-----------------------------------------------------------------------------------------------------------------



local function IsAtTarget(pos, target)
	local d = (pos.Position - target.Position).magnitude;
	return d < 0.1;
end

local function LaunchRun() 
	LaunchSide.mode = ModeEnum.Riding;
	
	-- play sound
	Sounds.launch:Play();
	wait(14);--------------------------------
	
	TweenService:Create(LaunchSide.Ride.PrimaryPart, LaunchSide.tweens.flightTweenInfo, { CFrame = LaunchSide.blocks.Top.CFrame }):Play();
	wait(LaunchSide.times.flightTime);
	
	TweenService:Create(LaunchSide.Ride.PrimaryPart, LaunchSide.tweens.fallTweenInfo, { CFrame = LaunchSide.blocks.Start.CFrame + Vector3.new(0, LaunchSide.times.fallOffset, 0) }):Play();
	wait(LaunchSide.times.fallTime);	
	
	TweenService:Create(LaunchSide.Ride.PrimaryPart, LaunchSide.tweens.bounceTweenInfo, { CFrame = LaunchSide.blocks.Start.CFrame + Vector3.new(0, LaunchSide.times.fallOffset * 3.5, 0) }):Play();
	wait(LaunchSide.times.bounceTime * 2.5);	
	
	
	LaunchSide.mode = ModeEnum.Returning;
	
	TweenService:Create(LaunchSide.Ride.PrimaryPart, LaunchSide.tweens.returnTweenInfo, { CFrame = LaunchSide.blocks.Station.CFrame }):Play();	
	if LaunchSide.autorun then Sounds.exit:Play(); end
	wait(LaunchSide.times.returnTime);
end



local launchAutoInLoop = false;


local function LaunchLoop()
	
	-- Open entrance gate
	LaunchSide.safety.enterGateClosed = false;
	Ride.Gates.LaunchEntranceGate.Post.HingeConstraint.AngularVelocity = 1;
	Ride.Gates.LaunchEntranceGate.Wall.CanCollide = false;
	wait(6);
	
	LaunchSide.safety.exitGateClosed = false;
	Ride.Gates.LaunchExitGate.Post.HingeConstraint.AngularVelocity = 1;
	Ride.Gates.LaunchExitGate.Wall.CanCollide = false;
	
	
	
	
	
	LaunchSide.safety.restraintsLocked = false;
	
	wait(6); -- waiting for boarding----------------------------------------------------------------
	print("[SASQUATCH] Launch: (Auto) Closing gates.")
	LaunchSide.safety.enterGateClosed = true;
	LaunchSide.safety.exitGateClosed = true;
	
	wait(3); -- pause for gates
	print("[SASQUATCH] Launch: (Auto) Restraints locked.")
	LaunchSide.safety.restraintsLocked = true;
	
	wait(2)
	print("[SASQUATCH] Launch: (Auto) Starting ride...")
	Sounds.visual:Play();
	wait(5);
	Sounds.clear:Play();
	wait(3);
	
	
	LaunchSide.mode = ModeEnum.MovingToStart;
	TweenService:Create(LaunchSide.Ride.PrimaryPart, LaunchSide.tweens.prepTweenInfo, { CFrame = LaunchSide.blocks.Start.CFrame }):Play();
	wait(LaunchSide.times.prepTime);
	
	print("[SASQUATCH] Launch: (Auto) Launching!")
	LaunchRun();
	
	print("[SASQUATCH] Launch: (Auto) Gates open, restraints unlocked.")
	LaunchSide.safety.enterGateClosed = false;
	LaunchSide.safety.exitGateClosed = false;
	LaunchSide.safety.restraintsLocked = false;
	
	print("[SASQUATCH] Launch: (Auto) Ride complete.")
	wait(2);
	
	launchAutoInLoop = false;	
end


local LaunchAutoRun;

RunService.Heartbeat:Connect(function(dt) 
	
	-- Launch side
	local cfLaunch = LaunchSide.Ride.PrimaryPart.CFrame;
	
	
	if LaunchSide.mode == ModeEnum.MovingToStart then	-- MOVING TO LAUNCH			
		if IsAtTarget(cfLaunch, LaunchSide.blocks.Start) then LaunchSide.mode = ModeEnum.ReadyToStart; end
		
	elseif LaunchSide.mode == ModeEnum.Returning then	-- RETURNING
		if IsAtTarget(cfLaunch, LaunchSide.blocks.Station) then LaunchSide.mode = ModeEnum.InStation; end
	end
	
	
	
	
	
	-- Host/operator handshake
	
	if LaunchSide.safety.activeHandshake then
		LaunchSide.safety.handshakeTimer += dt;
		
		if LaunchSide.safety.handshakeTimer >= 10 then
			LaunchSide.safety.handshakeTimer = 0;
			LaunchSide.safety.handshakeSuccess = false;
			LaunchSide.safety.activeHandshake = false;
			print("[SASQUATCH] Launch: Safety handshake timer expired.");
		end
	end
	
	
	
	
	-- Automatic mode
	
	if LaunchSide.autorun then
		
		-- Start loop
		if not launchAutoInLoop then
			launchAutoInLoop = true;
			
			local verify = coroutine.create(function() 
				wait(5);
				if LaunchSide.autorun then
					print("[SASQUATCH] Launch: (Auto) Starting automatic mode.");
					LaunchAutoRun = coroutine.create(LaunchLoop);
					local success, result = coroutine.resume(LaunchAutoRun);
				else
					launchAutoInLoop = false;
				end
			end);
			
			local success, result = coroutine.resume(verify);
			
		end
	end
	
	
	-- Gates
	Ride.Gates.LaunchEntranceGate.Post.HingeConstraint.AngularVelocity = LaunchSide.safety.enterGateClosed and -1 or 1;
	Ride.Gates.LaunchExitGate.Post.HingeConstraint.AngularVelocity = LaunchSide.safety.exitGateClosed and -1 or 1;
	
	
	
	
end);


local BeelzquatchControlModule = {};

function BeelzquatchControlModule:RideStats()
	return LaunchSide, DropSide;
end



function BeelzquatchControlModule:PlayAudio(audio) 
	if audio then
		audio:Play();
	end
end

function BeelzquatchControlModule:StopAudio(audio)
	if audio then
		audio:Stop();
	end
end




--------------------------------------
-- LAUNCH CONTROLS

BeelzquatchControlModule.Launch = {
	
	AutoInLoop = function ()
		return launchAutoInLoop;
	end,
	
	ToggleAuto = function() 		
		LaunchSide.autorun = not LaunchSide.autorun;
		
		print("[SASQUATCH] Launch: Automatic mode ".. (LaunchSide.autorun and "enabled." or "disabled."));
		return LaunchSide.autorun;
	end,
	
	ToggleEnterGate = function() 
		if LaunchSide.mode ~= "Waiting in station" or launchAutoInLoop then
			print("[SASQUATCH] Launch: ** Unsafe to unlock gate! **");
			return;
		end
		
		local closed = not LaunchSide.safety.enterGateClosed;
		LaunchSide.safety.enterGateClosed = closed;
		Ride.Gates.LaunchEntranceGate.Wall.CanCollide = closed;
				
		print("[SASQUATCH] Launch: Enter gate ".. (closed and "closed." or "opened."));
	end,
	
	ToggleExitGate = function() 
		
		if LaunchSide.mode ~= "Waiting in station" or launchAutoInLoop then
			print("[SASQUATCH] Launch: ** Unsafe to unlock gate! **");
			return;
		end
		
		local closed = not LaunchSide.safety.exitGateClosed;
		LaunchSide.safety.exitGateClosed = closed;
		Ride.Gates.LaunchExitGate.Wall.CanCollide = closed;
				
		print("[SASQUATCH] Launch: Exit gate ".. (closed and "closed." or "opened."));
	end,
	
	ToggleRestraints = function() 
		if launchAutoInLoop then return end
		
		if LaunchSide.mode ~= "Waiting in station" and not launchAutoInLoop then
			print("[SASQUATCH] Launch: ** Unsafe to open restraints! **");
			return;
		end
		
		-- Toggle Lock
		LaunchSide.safety.restraintsLocked = not LaunchSide.safety.restraintsLocked;
		
		for i, seat in ipairs(LaunchSide.seats) do
			if seat.Occupant and seat.Occupant:IsA("Humanoid") then
				seat.Occupant.JumpPower = LaunchSide.safety.restraintsLocked and 0 or 50;
			end
		end
		
		
		print("[SASQUATCH] Launch: Restraints " .. (LaunchSide.safety.restraintsLocked and "locked." or "unlocked."));
	end,
	
	StartRide = function() 
		if launchAutoInLoop or LaunchSide.mode ~= ModeEnum.InStation then return end
		
		-- Check if safe 
		if not LaunchSide.safety.enterGateClosed or not LaunchSide.safety.exitGateClosed then print("[SASQUATCH] Launch: ** Unsafe, gates are open! **"); return; end
		if not LaunchSide.safety.restraintsLocked then print("[SASQUATCH] Launch: ** Unsafe, restraints unlocked! **"); return; end
		if not LaunchSide.safety.handshakeSuccess then print("[SASQUATCH] Launch: ** Unsafe, handshake required! **"); return; end
			
		-- Start
		print("[SASQUATCH] Launch: Ride starting.");
		LaunchSide.mode = ModeEnum.MovingToStart;
		TweenService:Create(LaunchSide.Ride.PrimaryPart, LaunchSide.tweens.prepTweenInfo, { CFrame = LaunchSide.blocks.Start.CFrame }):Play();
		
	end,
	
	LaunchRide = function()
		if launchAutoInLoop then return end
		
		if LaunchSide.mode == ModeEnum.ReadyToStart then
			print("[SASQUATCH] Launch: Launching!");
			LaunchRun();		
			print("[SASQUATCH] Launch: Ride complete!");	
		end
	end,
	
	AbortRide = function() 
		if LaunchSide.mode ~= ModeEnum.InStation and LaunchSide.mode ~= ModeEnum.Riding then
			print("[SASQUATCH] Launch: Launch aborted!!!");
			TweenService:Create(LaunchSide.Ride.PrimaryPart, LaunchSide.tweens.prepTweenInfo, { CFrame = LaunchSide.blocks.Station.CFrame }):Play();	
			LaunchSide.mode = ModeEnum.Returning;	
			
			-- cancel auto
			LaunchSide.autorun = false;
			launchAutoInLoop = false;
			coroutine.close(LaunchAutoRun);
			LaunchAutoRun = nil;
			
		end
	end,
	
	
	
	
	-- Start safety handshake
	MessageHost = function()
		if launchAutoInLoop then return end
		
		if LaunchSide.mode == "Waiting in station" then
			LaunchSide.safety.activeHandshake = true;
			LaunchSide.safety.handshakeTimer = 0;
			print("[SASQUATCH] Launch: Safety handshake initiated.");
		end	
	end,
	
	-- Acknowledge handshake
	HostReply = function()
		if LaunchSide.safety.activeHandshake then
			LaunchSide.safety.handshakeSuccess = true;
			LaunchSide.safety.handshakeTimer = 0;
			print("[SASQUATCH] Launch: Safety handshake successful! Ready to start ride.");
		end
	end,
	
	
	
	
};








return BeelzquatchControlModule;
