---------------------------------------------------
-- (c)2025 Barkeater Beelz. All rights reserved. --
---------------------------------------------------

local RunService = game:GetService("RunService");
local ServerStorage = game:GetService("ServerStorage");

local RideScript = require(workspace.Sasquatch.SasquatchControlModule);
local launchPanel = script.Parent;

local uiUpdateTimer = 0;
local buttonLightTimer = 0;
local lightsOn = true;


-- Colors
local onGreen 	= Color3.new(0, 1, 0);
local offGreen 	= Color3.new(0, 0.3, 0);
local onRed 	= Color3.new(1, 0, 0);
local offRed 	= Color3.new(0.6, 0, 0);
local onYellow 	= Color3.new(1, 1, 0);
local offYellow = Color3.new(0.5, 0.5, 0);


-- Panel controls
local Controls = {
	EnterGate 	= launchPanel.EnterGate.Button,
	ExitGate 	= launchPanel.ExitGate.Button,
	Seats 		= launchPanel.Seats.Button,
	AutoBtn 	= launchPanel.AutoMode.Button,
	Automatic 	= launchPanel.AutoMode.AutoLight,
	Manual 		= launchPanel.AutoMode.ManualLight,

	Start 		= launchPanel.Start.Button,
	Launch 		= launchPanel.Launch.Button,
	Abort 		= launchPanel.Abort.Button,
	Status 		= script.Parent["Launch UI"].Status.SurfaceGui.TextLabel,
	
	
	MessageHost = launchPanel.Host.MessageHost,
	HostReply 	= launchPanel.Host.HostButton.Button
	
	-- HostRestraintsLight
	-- HostGatesLight
	
}; 

RunService.Heartbeat:Connect(function(dt) 

	local l, d = RideScript:RideStats();

	---------------------------------------------
	-- UI		

	uiUpdateTimer += dt;

	if uiUpdateTimer >= 0.25 then
		uiUpdateTimer -= 0.25;
		Controls.Status.Text = l.mode or "STATUS?";

	end


	-------------------------------------------
	-- Panel Buttons

	buttonLightTimer += dt;

	if buttonLightTimer >= 1 then
		buttonLightTimer -= 1;
		lightsOn = not lightsOn;

	end

	-- Safety lights
	Controls.EnterGate.Color = l.safety.enterGateClosed and onGreen or (lightsOn and onRed or offRed);
	Controls.ExitGate.Color = l.safety.exitGateClosed and onGreen or (lightsOn and onRed or offRed);
	Controls.Seats.Color = l.safety.restraintsLocked and onGreen or (lightsOn and onRed or offRed);
	
	if RideScript.Launch.AutoInLoop() then
		Controls.Automatic.Color = (lightsOn and l.autorun) and onGreen or offGreen;
		Controls.Manual.Color = offGreen;
	else
		Controls.Automatic.Color = l.autorun and onGreen or offGreen;
		Controls.Manual.Color = l.autorun and offGreen or onGreen;
	end
	
	
	
	
	
	
	------------------------------------------------------------------------------------------------




	-- Host/operator handshake
	
	if l.mode == "Waiting in station" and not l.autorun then
		
		if l.safety.activeHandshake then
			if l.safety.handshakeSuccess then 
				Controls.MessageHost.Color = onYellow;
				Controls.HostReply.Color = onYellow;
			else
				Controls.MessageHost.Color = onYellow;
				Controls.HostReply.Color = lightsOn and onYellow or offYellow;
			end
			
		elseif not l.safety.enterGateClosed or not l.safety.exitGateClosed or not l.safety.restraintsLocked then -- Not safe
			Controls.MessageHost.Color = offYellow;
			Controls.HostReply.Color = offYellow;
			
		else
			Controls.MessageHost.Color = lightsOn and onYellow or offYellow;
			Controls.HostReply.Color = offYellow;
		end
		
	else
		Controls.MessageHost.Color = offYellow;
		Controls.HostReply.Color = offYellow;
	end
	



	if l.mode == "Waiting in station" then

		Controls.Start.Color = l.safety.handshakeSuccess and (lightsOn and onGreen or offGreen) or offGreen;
		Controls.Launch.Color = offGreen;
		Controls.Abort.Color = offRed;
		Controls.AutoBtn.Color = onYellow;


	elseif l.mode == "Moving to start position" then
		Controls.Start.Color = not l.autorun and onGreen or offGreen;
		Controls.Launch.Color = offGreen;
		Controls.Abort.Color = lightsOn and onRed or offRed;
		Controls.AutoBtn.Color = offYellow;

	elseif l.mode == "Ready to start ride" then

		Controls.Start.Color = offGreen;
		Controls.Launch.Color = (lightsOn and not l.autorun) and onGreen or offGreen;
		Controls.Abort.Color = lightsOn and onRed or offRed;
		Controls.AutoBtn.Color = offYellow;

	elseif l.mode == "Riding" then

		Controls.Start.Color = offGreen;
		Controls.Launch.Color = offGreen;
		Controls.Abort.Color = offRed;
		Controls.AutoBtn.Color = offYellow;

	elseif l.mode == "Returning to station" then
		Controls.Start.Color = offGreen;
		Controls.Launch.Color = offGreen;
		Controls.Abort.Color = offRed;
		Controls.AutoBtn.Color = offYellow;

	end






end);