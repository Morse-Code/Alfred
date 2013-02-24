-- Create Markdown link from front most tab in safari and append
-- to end of current FoldingText document as new list item.

-- UNCOMMENT FOR USE IN ALFRED
--on alfred_script(q)
on run
	set the date_stamp to (short date string of (current date))
	set parentText to ("- Links from Safari Tabs on ") & the date_stamp & " @linklist" & return
	set MDLink to ""
	tell application "Safari"
		set safariWindow to window 1
		try
			repeat with t in (tabs of safariWindow)
				set TabTitle to (name of t)
				set TabURL to (URL of t) as text
				set MDLink to (MDLink & ("	- [" & TabTitle & "]" & "(" & TabURL & ") ") & return)
			end repeat
		end try
	end tell
	
	-- Append MDLink to the end of parentText and add to end of current document
	-- in FoldingText.
	tell application "FoldingText"
		tell front document
			create nodes from text (parentText & MDLink)
		end tell
	end tell
	--UNCOMMENT FOR USE IN ALFRED
end run
--end alfred_script