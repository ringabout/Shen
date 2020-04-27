import os, osproc, strformat, sets, strutils


const sysModule = ["arithmetics.nim.gcov", "sysstr.nim.gcov", 
                   "system.nim.gcov", "generated_not_to_break_here.gcov",
                   "memory.nim.gcov", "iterators_1.nim.gcov",
                   "comparisons.nim.gcov", "excpt.nim.gcov",
                   "gc.nim.gcov"].toHashSet
let dirs = "results"
let cacheDir = "cache"
discard existsOrCreateDir(dirs)

discard execCmdEx fmt"nim --debugger:native --nimcache:{dirs / cacheDir}  --verbosity:3 --passC:--coverage --passL:--coverage c all.nim"
discard execCmdEx "all.exe"

for file in walkFiles(dirs / cacheDir / "@m*.nim.c.gcno"):
  discard execCmdEx fmt"gcov {file}"
  # exec "gcov"


for path in walkFiles("*.gcov"):
  if existsFile(dirs / path):
    removeFile(dirs / path)
  
  if path in sysModule or path.startsWith("@m"):
    removeFile(path)
  else:
    moveFile(path, dirs / path)

removeDir(dirs / cacheDir)

# exec "gcov cache/@mall.nim.c.gcno"
# exec "gcov cache/@mhello.nim.c.gcno"
# exec "gcov cache/@mfunny.nim.c.gcno"
