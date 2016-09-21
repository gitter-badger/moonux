-- My window example
xwindow = {}

-- Create a window
function xwindow.create(w,h)
	local screen = {}
	for i=1,w do
		table.insert(screen, {id=i})
		for i=1,h
		table.insert(screen[i], {px=i,data="", background=color.black, foreground=color.white})
		end
	end

	local self
	self.screen = screen
	self.width = w
	self.height = h
	self.term
	return self
end

-- Display the window
function xwindow.display(xw)
	term.clear()
	term.setCursorPos(1,1)
	for w=1,xw.width do
		for h=1,xw.height do
			term.setCursorPos(w,h)
			term.setTextColor(xw.foreground)
			term.setBackgroundColor(xw.background)
			term.write(xw.screen[w][h].data)
		end
	end
end

-- Return to the shell
function xwindow.clear(termobj)
	termobj.clear()
end