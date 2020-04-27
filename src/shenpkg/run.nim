import os, osproc, strformat, sets, strutils, parseopt


const sysModule = ["arithmetics.nim.gcov", "sysstr.nim.gcov", 
                   "system.nim.gcov", "generated_not_to_break_here.gcov",
                   "memory.nim.gcov", "iterators_1.nim.gcov",
                   "comparisons.nim.gcov", "excpt.nim.gcov",
                   "gc.nim.gcov"].toHashSet
let dirs = "results"
let cacheDir = "cache"
discard existsOrCreateDir(dirs)


proc parseCov*(filePath: string) =
  var filePath = filePath
  let nimFilePath = filePath.addFileExt("nim")

  when defined(windows):
    filePath = filePath.addFileExt("exe")

  discard execCmdEx fmt"nim --debugger:native --nimcache:{dirs / cacheDir} " & 
                    fmt"--passC:--coverage --passL:--coverage c {nimFilePath}"
  discard execCmdEx filePath

  for file in walkFiles(dirs / cacheDir / "@m*.nim.c.gcno"):
    discard execCmdEx fmt"gcov {file}"


  for path in walkFiles("*.gcov"):
    if existsFile(dirs / path):
      removeFile(dirs / path)
    
    if path in sysModule or path.startsWith("@m"):
      removeFile(path)
    else:
      moveFile(path, dirs / path)

  removeDir(dirs / cacheDir)

proc dispatch*() =
  var
    op = initOptParser()
    path: string

  while true:
    op.next()
    case op.kind
    of {cmdLongOption, cmdShortOption}:
      case op.key
      of "help", "h":
        stdout.write("This is help.")
      else:
        discard
    of cmdArgument:
      path = op.key
    of cmdEnd:
      break

  if path.len != 0:
    let file = path.splitFile
    parseCov(file.dir / file.name)

when isMainModule:
  dispatch()
