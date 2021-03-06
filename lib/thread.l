--[[
	mnx-sr12 : Moonux Satellite Rewrite 12
	Made by thecrimulo

	NAME:        /lib/thread.l
	CATEGORY:    library
	SET:         Native Libraries RW12
	VERSION:     12:alpha0
	DESCRIPTION: 
		This library is loaded first and used on
		the thread manager (/vit/mgr/thread.mgr)
]]--

local thread = {}

local started = {}
local running = {}
local last_uid = 0

function thread.new(task, file, uid)
	uid = uid or last_uid + 1
	last_uid = last_uid + 1

	local self = {}
	self.uid = uid
	self.task = task
	self.thread = coroutine.create(task)
	self.file = file
	self.filter = nil
	self.error = nil
	self.dead = false
	self.status = "suspended"
	self.queue = {}
	self.resume = function(...)
		local fst = ...
		if self.filter == nil or fst == self.filter then
			ok, err = coroutine.resume(self.thread, ...)
			if ok then
				self.filter = err
				self.status = coroutine.status(self.thread)
				if self.status == "dead" then self.dead = true end
			else
				self.status = coroutine.status(self.thread)
				if self.status == "dead" then self.dead = true end
				return err
			end
		end
	end
	started[self.uid] = self
	self.next = started
	return self
end

function thread.queue(process, event, parameters)
	process.queue[#process.queue+1] = {event = event, parameters = parameters}
	return true
end
 
function thread.kill(process)
	process.dead = true
	process.status = "dead"
	thread.queue(process, "sig:terminate", {})
end

function thread.killAll(tasklist)
	if not flag.STATE_SHUTDOWN or not flag.STATE_RESTART then return false end
	for uid, task in pairs(tasklist) do
			thread.kill(task)
	end
end

function thread.runAll(tasklist)
	evt = {}
	while true do
		evt = {os.pullEvent()}
		for uid, task in pairs(tasklist) do
			if task.dead then table.remove(tasklist, uid)
			else task.resume(unpack(evt)) end
		end
	end
end