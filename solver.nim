include prelude
import algorithm

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

func `&`(x, y: int): Square = y * WIDTH + x

func parse(repr: string): Level =
  let rows = repr.splitLines
  let height = rows.len
  let width = rows.mapIt(it.len).max div 2
  if height + 2 > HEIGHT or width + 2 > WIDTH:
    raise newException(RangeDefect, "Level too large, recompile solver width bigger dimension consts.")
  var start, goal: Table[int, Square]
  for x in 0..<WIDTH:
    result.walls.incl x & 0
    result.walls.incl x & HEIGHT-1
  for y in 0..<HEIGHT:
    result.walls.incl 0 & y
    result.walls.incl WIDTH-1 & y
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

echo parse """##aa
AA  """
