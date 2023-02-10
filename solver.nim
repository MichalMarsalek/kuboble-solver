include prelude
import algorithm, deques

const
  WIDTH = 9
  HEIGHT = 9

type
  Square = range[0..(WIDTH*HEIGHT-1)]
  State = seq[Square]
  Level = object
    walls: set[Square]
    start: State
    goal: State
  Solution = seq[State]
  Step = ref object
    previous: Step
    state: State

func `&`(x, y: int): Square = y * WIDTH + x

func parse(repr: string): Level =
  let rows = repr.splitLines
  let height = rows.len
  let width = rows.mapIt(it.len).max div 2
  if height + 2 > HEIGHT or width + 2 > WIDTH:
    raise newException(RangeDefect, "Level too large, recompile solver width bigger dimension consts.")
  var start, goal: Table[int, Square]
  for x in 0..<width+2:
    result.walls.incl x & 0
    result.walls.incl x & height+1
  for y in 0..<height+2:
    result.walls.incl 0 & y
    result.walls.incl width+1 & y
  for y, row in rows:
    for x in 0..<(row.len div 2):
      let square = x+1 & y+1
      let data = row[2*x .. 2*x + 1]
      if '#' in data:
        result.walls.incl square
      for c in 'a'..'z':
        if c in data:
          start[c.ord - 'a'.ord] = square
      for c in 'A'..'Z':
        if c in data:
          goal[c.ord - 'A'.ord] = square
  if start.keys.toSeq.toHashSet != goal.keys.toSeq.toHashSet:
    raise newException(Defect, "Start and goal markers don't match.")
  for x in start.keys.toSeq.sorted:
    result.start &= start[x]
    result.goal &= goal[x]

func `$`(level: Level): string =
  for y in 1..<HEIGHT-1:
    if y > 1: result &= "\n"
    for x in 1..<WIDTH-1:
      var temp = ""
      if x&y in level.walls: temp = "#"
      if x&y in level.start: temp &= chr(ord('a') + level.start.find x&y)
      if x&y in level.goal: temp &= chr(ord('A') + level.goal.find x&y)
      if temp == "": temp = " "
      if temp.len == 1: temp &= temp
      result &= temp

iterator neighbours(level: Level, state: State): State =
  for i, s0 in state:
    var result = state
    for d in [-WIDTH, -1, 1, WIDTH]:
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
    result &= visualize(level, x) & "\n"

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

func visualizeSolution(level: Level): string =
  level.visualize level.solve

let level = parse """##aa  
AA  
"""

echo visualizeSolution level
