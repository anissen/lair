
class Agent
  constructor: ->
  init: (@x = 0, @y = 0, @color = 0, @rotation = 0, @size = 50, @text = 'Agent') ->
    #console.log 'Agent initialized'
  setBehavior: (@behavior) ->
  update: ->
    @behavior?.execute()


class Level
  constructor: ->
    @agents = []
  init: ->
    #console.log 'Level initialized'
  addAgent: (agent) ->
    @agents.push agent
  getAgent: (index) ->
    @agents[index]
  getWaypointPosition: (waypointId) ->
    @getMap().waypoints[waypointId]
  getMap: ->
    width: 10
    height: 10
    waypoints:
      'W1':
        x: 9
        y: 1
      'W2':
        x: 1
        y: 1
      'W3':
        x: 7
        y: 3
      'W4':
        x: 3
        y: 3
    tiles: [
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,1,1,1,1,1,1,1,0,0,0,0,0],
        [0,1,0,0,0,1,0,0,0,1,0,0,0,0,0],
        [0,1,0,1,1,1,1,1,0,1,1,1,1,1,2],
        [0,1,0,0,0,0,0,0,0,1,0,0,0,0,0],
        [0,1,1,1,1,1,1,1,1,1,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    ]
    start:
      x: 12
      y: 3
    goals: [
      (agent) =>
        goal = @getMap().waypoints['W4']
        ###
        these goals should be formulated as Tasks

        should probably return something like
        description: 'Spot the intruder', status: SUCCES/FAILURE/ERROR/RUNNING
        (where RUNNING means that the goal is persued, eg. assisted by a count/total)
        ###
        Math.round(agent.x - 0.5) is goal.x and Math.round(agent.y - 0.5) is goal.y
    ]


#level = new Level()
#loadMap level.getMap()

class Map
  constuctor: ->

  init: (@context, @level) ->
    @gridSize = 60
    @goalReached = false
    #console.log 'Map initialized'

  draw: ->
    @context.clearRect 0, 0, @context.canvas.width, @context.canvas.height
    @drawTiles()
    @drawWaypoints()
    @drawGrid()
    @drawAgent agent for agent in @level.agents

  update: ->
    return if @goalReached
    for agent in @level.agents
      agent.update()
      #if @level.getMap().goals[0](agent)
      #  @goalReached = true

  drawGrid: ->
    @context.fillStyle = "rgb(50, 150, 150)"
    @context.strokeStyle = "rgb(150, 150, 150)"
    x = @gridSize

    while x < @context.canvas.width
      @context.fillText Math.round(x / @gridSize), x + @gridSize / 2, 10
      @context.beginPath()
      @context.moveTo x, 0
      @context.lineTo x, @context.canvas.height
      @context.stroke()
      x += @gridSize
    y = @gridSize

    while y < @context.canvas.height
      @context.fillText Math.round(y / @gridSize), 10, y + @gridSize / 2
      @context.beginPath()
      @context.moveTo 0, y
      @context.lineTo @context.canvas.width, y
      @context.stroke()
      y += @gridSize

  drawAgent: (agent) ->
    pos = @getPoint agent
    @context.save()
    @context.translate pos.x, pos.y
    @context.save()

    rotDegrees = Math.floor(agent.rotation)
    rotRadians = rotDegrees * (Math.PI / 180)
    @context.rotate rotRadians

    colorIndex = Math.floor(agent.color)
    @context.fillStyle = "rgb(" + colorIndex + ", 0, " + (255 - colorIndex) + ")"
    @context.fillRect -agent.size / 2, -agent.size / 2, agent.size, agent.size

    @context.restore()

    @context.fillStyle = "rgb(" + (255 - colorIndex) + ", 255, " + colorIndex + ")"
    @context.textAlign = "center"
    @context.textBaseline = "middle"
    @context.fillText agent.text, 0, 0
    @context.restore()

  drawBlocks: ->
    blocks = @level.getMap().blocks
    for block in blocks
      @drawTile block, "rgb(30, 30, 30)"

  drawTiles: ->
    tiles = @level.getMap().tiles
    y = 0
    for tileRow in tiles
      x = 0
      for tileType in tileRow
        tile =
          x: x - 1
          y: y - 1
        switch tileType
          when 0
            tileColor = 'rgb(40, 40, 40)'
          when 1
            tileColor = 'rgb(220, 220, 220)'
          when 2
            tileColor = 'rgb(40, 80, 160)'
        @drawTile tile, tileColor
        x++
      y++

  drawStart: ->
    @drawTile @level.getMap().start, "rgb(130, 30, 130)"

  drawWaypoints: ->
    boxSize = 50
    waypoints = @level.getMap().waypoints
    for key of waypoints
      pos = @getPoint waypoints[key]

      @context.fillStyle = "rgb(240, 200, 50)"
      @context.beginPath()
      @context.arc pos.x, pos.y, boxSize / 2, 0, 2 * Math.PI, false
      @context.closePath()
      @context.fill()
      @context.strokeStyle = "rgb(120, 100, 25)"
      @context.stroke()

      @context.fillStyle = "rgb(120, 100, 25)"
      @context.textAlign = "center"
      @context.textBaseline = "middle"
      @context.fillText key, pos.x, pos.y

  drawTile: (obj, color) ->
    pos = @getPoint obj
    @context.save()
    @context.translate pos.x, pos.y
    @context.fillStyle = color
    @context.fillRect @gridSize / 2, @gridSize / 2, @gridSize, @gridSize
    @context.restore()

  getPoint: (obj) ->
    x: (obj.x + 0.5) * @gridSize
    y: (obj.y + 0.5) * @gridSize




window.Agent = Agent
window.Level = Level
window.Map = Map
