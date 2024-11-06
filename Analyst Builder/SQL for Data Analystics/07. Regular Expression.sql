-- 07. SQL for Data Analytics: Regular Expression

-- Tables:
SELECT * FROM Project
SELECT * FROM ProjectRole
SELECT * FROM ProjectTask
SELECT * FROM ProjectTool
SELECT * FROM ProjectUser
SELECT * FROM ProjectVendor

SELECT * FROM RFI
SELECT * FROM WbsCode
SELECT * FROM Submittal
SELECT * FROM WorkOrderContract
SELECT * FROM Correspondence

-- Regular Expression Introduction:
	-- Also called Regex
	-- Sequence of characters, used to search and locate characters that match a provided pattern
	-- Similar to the LIKE statement, but more specific/complex

-- Regular Expression Metacharacters:
	-- '.'	Any single character
	-- '^'	Start of a string
	-- '$'	End of a string
	-- '*'	Zero or more repetitions
	-- '+'	One or more repetitions
	-- '?'	Zero or one repetition
	-- '[]'	 Character class (e.g., [a-z])
	-- '\'	 Escape special characters
	-- '()'	 Grouping or capture group
	-- '{}'	 Quantifier (e.g., {2,5})

 -- LIKE Wild Cards:
	-- '%'	  Any sequence of characters (zero or more)
	-- '_'	  Any single character
	-- '[]'	  Any single character within the brackets (e.g., [a-z] matches any lowercase letter)
	-- '[^]'  Any single character not within the brackets (e.g., [^a-z] excludes lowercase letters)