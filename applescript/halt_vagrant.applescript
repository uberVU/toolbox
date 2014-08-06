set close_vagrant to "z puppet; vagrant halt -f;"

-- close vagrant
tell application "iTerm"
	activate
	set myterm to (make new terminal)
	tell myterm
		launch session "Default"
		set mysession to current session
	end tell

	tell mysession
		write text close_vagrant
	end tell
end tell
