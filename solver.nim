include prelude
import std/[algorithm, deques, monotimes]

const
  WIDTH = 8
  HEIGHT = 8

type
  Square = range[0..(WIDTH+2)*(HEIGHT+2)-1]
  State = seq[Square]
  Level = object
    width: int
    height: int
    walls: set[Square]
    start: State
    goal: State
  Solution = seq[State]
  Step = ref object
    previous: Step
    state: State

func `&`(x, y: int): Square = y * (WIDTH + 2) + x

func parse(repr: string): Level =
  var repr = repr.replace(";", "\n")
  if 'x' notin repr: repr = repr.replace('X', '#')
  let rows = repr.splitLines
  result.height = rows.len
  result.width = rows.mapIt(it.len).max div 2
  if result.height > HEIGHT or result.width > WIDTH:
    raise newException(RangeDefect, "Level too large, recompile solver width bigger dimension consts.")
  var start, goal: Table[int, Square]
  for x in 0..result.width+1:
    result.walls.incl x & 0
    result.walls.incl x & result.height+1
  for y in 0..result.height+1:
    result.walls.incl 0 & y
    result.walls.incl result.width+1 & y
  for y, row in rows:
    for x in 0..<(row.len div 2):
      let square = x+1 & y+1
      let data = row[2*x .. 2*x + 1]
      if '#' in data:
        result.walls.incl square
      for c in 'A'..'Z':
        if c in data:
          start[c.ord - 'A'.ord] = square
      for c in 'a'..'z':
        if c in data:
          goal[c.ord - 'a'.ord] = square
  if start.keys.toSeq.toHashSet != goal.keys.toSeq.toHashSet:
    raise newException(Defect, "Start and goal markers don't match.")
  for x in start.keys.toSeq.sorted:
    result.start &= start[x]
    result.goal &= goal[x]

func `$`(level: Level): string =
  for y in 1..level.height:
    if y > 1: result &= "\n"
    for x in 1..level.width:
      var temp = ""
      if x&y in level.walls: temp = "#"
      if x&y in level.start: temp &= chr(ord('A') + level.start.find x&y)
      if x&y in level.goal: temp &= chr(ord('a') + level.goal.find x&y)
      if temp == "": temp = " "
      if temp.len == 1: temp &= temp
      result &= temp

iterator neighbours(level: Level, state: State): State =
  for i, s0 in state:
    var result = state
    for d in [-WIDTH-2, -1, 1, WIDTH+2]:
      var s1 = s0 + d
      while s1 notin level.walls and s1 notin state:
        s1 += d
      result[i] = s1 - d
      yield result

func toSolution(step: Step): Solution =
  if step == nil: return @[]
  return toSolution(step.previous) & step.state

func visualize(level: Level, state: State): string =
  var copy = level
  copy.start = state
  $copy

func visualize(level: Level, solution: Solution): string =
  for x in solution:
    result &= visualize(level, x) & "\n---------------------\n"

func solve(level: Level): Solution =
  var seen: HashSet[State]
  var queue = [Step(previous: nil, state: level.start)].toDeque
  while true:
    let step = queue.popFirst
    if step.state == level.goal:
      return step.toSolution
    for neighbour in neighbours(level, step.state):
      if neighbour notin seen:
        seen.incl neighbour
        queue.addLast Step(state: neighbour, previous: step)

proc runSolver(level: Level) =
  let start = getMonoTime()
  let solution = solve level
  echo &"Solution ({solution.len-1} moves) found in {getMonoTime()-start}."
  echo visualize(level, solution)

runSolver parse """X . . X . . ;. . b . . . ;X X c X . . ;. . . aC B A"""
