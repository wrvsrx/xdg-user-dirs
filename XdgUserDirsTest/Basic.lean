import XdgUserDirs
open System.Xdg.UserDirs.Internal

private def expandVars (env : Array (String × String)) (s : String) : IO String :=
  expandVarsIO (fun k => pure (env.find? (·.1 == k) |>.map (·.2))) s

private def getUserDirWithEnvs
    (userDirs defaults : List (String × String))
    (env : Array (String × String))
    (name : String) : IO (Option System.FilePath) :=
  getUserDirWithEnv userDirs defaults
    (fun k => pure (env.find? (·.1 == k) |>.map (·.2)))
    name

-- notComment.empty
/-- info: false -/
#guard_msgs in
#eval notComment ""

-- notComment.hashAtStart
/-- info: false -/
#guard_msgs in
#eval notComment "# comment"

-- notComment.hashAlone
/-- info: false -/
#guard_msgs in
#eval notComment "#"

-- notComment.validPair
/-- info: true -/
#guard_msgs in
#eval notComment "KEY=value"

-- notComment.leadingSpace
/-- info: true -/
#guard_msgs in
#eval notComment "  KEY=value"

-- notComment.xdgDesktopDirLine
/-- info: true -/
#guard_msgs in
#eval notComment "XDG_DESKTOP_DIR=\"$HOME/Desktop\""

-- stripQuotes.doubleQuoted
/-- info: "hello" -/
#guard_msgs in
#eval stripQuotes "\"hello\""

-- stripQuotes.singleQuoted
/-- info: "hello" -/
#guard_msgs in
#eval stripQuotes "'hello'"

-- stripQuotes.unquoted
/-- info: "hello" -/
#guard_msgs in
#eval stripQuotes "hello"

-- stripQuotes.empty
/-- info: "" -/
#guard_msgs in
#eval stripQuotes ""

-- stripQuotes.mismatchedQuotes
/-- info: "\"hello'" -/
#guard_msgs in
#eval stripQuotes "\"hello'"

-- stripQuotes.doubleAlone
/-- info: "\"" -/
#guard_msgs in
#eval stripQuotes "\""

-- stripQuotes.singleAlone
/-- info: "'" -/
#guard_msgs in
#eval stripQuotes "'"

-- stripQuotes.innerEqualsKept
/-- info: "a=b" -/
#guard_msgs in
#eval stripQuotes "\"a=b\""

-- stripQuotes.nestedQuotesKept
/-- info: "'inner'" -/
#guard_msgs in
#eval stripQuotes "\"'inner'\""

-- parsePair.simplePair
/-- info: some ("KEY", "value") -/
#guard_msgs in
#eval parsePair "KEY=value"

-- parsePair.quotedValue
/-- info: some ("KEY", "value") -/
#guard_msgs in
#eval parsePair "KEY=\"value\""

-- parsePair.valueContainsEquals
/-- info: some ("KEY", "a=b") -/
#guard_msgs in
#eval parsePair "KEY=a=b"

-- parsePair.emptyValue
/-- info: some ("KEY", "") -/
#guard_msgs in
#eval parsePair "KEY="

-- parsePair.noEquals
/-- info: none -/
#guard_msgs in
#eval parsePair "noequals"

-- parsePair.emptyLine
/-- info: none -/
#guard_msgs in
#eval parsePair ""

-- parsePair.xdgDirEntry
/-- info: some ("XDG_DESKTOP_DIR", "$HOME/Desktop") -/
#guard_msgs in
#eval parsePair "XDG_DESKTOP_DIR=\"$HOME/Desktop\""

-- expandVars.singleVar
/-- info: "/home/user" -/
#guard_msgs in
#eval expandVars #[("HOME", "/home/user"), ("XDG", "/xdg")] "$HOME"

-- expandVars.varWithPath
/-- info: "/home/user/Downloads" -/
#guard_msgs in
#eval expandVars #[("HOME", "/home/user"), ("XDG", "/xdg")] "$HOME/Downloads"

-- expandVars.twoVars
/-- info: "/home/user//xdg" -/
#guard_msgs in
#eval expandVars #[("HOME", "/home/user"), ("XDG", "/xdg")] "$HOME/$XDG"

-- expandVars.noVars
/-- info: "novar" -/
#guard_msgs in
#eval expandVars #[("HOME", "/home/user"), ("XDG", "/xdg")] "novar"

-- expandVars.unknownVar
/-- info: "" -/
#guard_msgs in
#eval expandVars #[("HOME", "/home/user"), ("XDG", "/xdg")] "$UNKNOWN"

-- expandVars.loneDollar
/-- info: "price: $" -/
#guard_msgs in
#eval expandVars #[("HOME", "/home/user"), ("XDG", "/xdg")] "price: $"

-- expandVars.dollarBeforeSep
/-- info: "$/path" -/
#guard_msgs in
#eval expandVars #[("HOME", "/home/user"), ("XDG", "/xdg")] "$/path"

-- expandVars.emptyString
/-- info: "" -/
#guard_msgs in
#eval expandVars #[("HOME", "/home/user"), ("XDG", "/xdg")] ""

-- pairToXdgPair.desktopEntry
/-- info: some ("DESKTOP", "$HOME/Desktop") -/
#guard_msgs in
#eval pairToXdgPair ("XDG_DESKTOP_DIR", "$HOME/Desktop")

-- pairToXdgPair.downloadEntry
/-- info: some ("DOWNLOAD", "$HOME/Downloads") -/
#guard_msgs in
#eval pairToXdgPair ("XDG_DOWNLOAD_DIR", "$HOME/Downloads")

-- pairToXdgPair.absoluteValue
/-- info: some ("MUSIC", "/mnt/music") -/
#guard_msgs in
#eval pairToXdgPair ("XDG_MUSIC_DIR", "/mnt/music")

-- pairToXdgPair.noXdgPrefix
/-- info: none -/
#guard_msgs in
#eval pairToXdgPair ("DESKTOP", "Desktop")

-- pairToXdgPair.tooFewParts
/-- info: none -/
#guard_msgs in
#eval pairToXdgPair ("XDG_DIR", "foo")

-- pairToXdgPair.tooManyParts
/-- info: none -/
#guard_msgs in
#eval pairToXdgPair ("XDG_EXTRA_DESKTOP_DIR", "foo")

-- pairToXdgPair.missingDirSuffix
/-- info: none -/
#guard_msgs in
#eval pairToXdgPair ("XDG_DESKTOP_path", "foo")

-- readPairs.skipsCommentsAndBlanksReadsFourPairs
/-- info: [("KEY1", "val1"), ("KEY2", "val2"), ("KEY3", "val3"), ("KEY4", "a=b")] -/
#guard_msgs in
#eval do
  let tmp : System.FilePath := ⟨"/tmp/xdg_lean_test_pairs"⟩
  IO.FS.writeFile tmp "# comment\n\nKEY1=val1\nKEY2=\"val2\"\nKEY3='val3'\nKEY4=a=b\n"
  let pairs ← readPairs tmp
  IO.FS.removeFile tmp
  return pairs

-- readPairs.missingFileReturnsEmpty
/-- info: [] -/
#guard_msgs in
#eval readPairs ⟨"/tmp/xdg_lean_no_such_file_abc123"⟩

-- getUserDirWithEnvs.userEntryTakesPrecedence
/-- info: some (FilePath.mk "/home/user/Desktop") -/
#guard_msgs in
#eval getUserDirWithEnvs
  [("DESKTOP", "$HOME/Desktop"), ("DOWNLOAD", "/mnt/downloads")]
  [("DESKTOP", "Desktop"), ("DOCUMENTS", "$HOME/Documents")]
  #[("HOME", "/home/user")]
  "DESKTOP"

-- getUserDirWithEnvs.absoluteValueReturnedAsIs
/-- info: some (FilePath.mk "/mnt/downloads") -/
#guard_msgs in
#eval getUserDirWithEnvs
  [("DESKTOP", "$HOME/Desktop"), ("DOWNLOAD", "/mnt/downloads")]
  [("DESKTOP", "Desktop"), ("DOCUMENTS", "$HOME/Documents")]
  #[("HOME", "/home/user")]
  "DOWNLOAD"

-- getUserDirWithEnvs.fallsBackToDefault
/-- info: some (FilePath.mk "/home/user/Documents") -/
#guard_msgs in
#eval getUserDirWithEnvs
  [("DESKTOP", "$HOME/Desktop"), ("DOWNLOAD", "/mnt/downloads")]
  [("DESKTOP", "Desktop"), ("DOCUMENTS", "$HOME/Documents")]
  #[("HOME", "/home/user")]
  "DOCUMENTS"

-- getUserDirWithEnvs.returnsNoneWhenAbsentFromBoth
/-- info: none -/
#guard_msgs in
#eval getUserDirWithEnvs
  [("DESKTOP", "$HOME/Desktop"), ("DOWNLOAD", "/mnt/downloads")]
  [("DESKTOP", "Desktop"), ("DOCUMENTS", "$HOME/Documents")]
  #[("HOME", "/home/user")]
  "VIDEOS"
