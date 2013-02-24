-- Create Markdown link from front most tab in safari and append
-- to end of current FoldingText document as new list item.
--on alfred_script(q)
on run
	set MDLink to ""
	tell application "Safari"
		set safariWindow to window 1
		try
			repeat with t in (tabs of safariWindow)
				if t is visible then
					set TabTitle to (name of t)
					set TabURL to (URL of t) as text
					set MDLink to ("[" & TabTitle & "]" & "(" & TabURL & ")")
				end if
			end repeat
		end try
	end tell
	
	tell application "FoldingText"
		tell front document
			create nodes from text ("- " & MDLink)
		end tell
	end tell
end run
--end alfred_script