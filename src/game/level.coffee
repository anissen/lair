
class Agent
  constructor: ->
  init: (@x = 0, @y = 0, @color = 0, @rotation = 0, @size = 50, @text = 'Agent') ->
    console.log 'Agent initialized'
  setBehavior: (@behavior) ->
  update: ->
    @behavior?.execute()


class Level
  constructor: ->
    @agents = []
  init: ->
    console.log 'Level initialized'
  addAgent: (agent) ->
    @agents.push agent
  getMap: ->
    width: 10
    height: 10
    waypoints:
      'W1':
        x: 2
        y: 2
      'W2':
        x: 7
        y: 4
      'W3':
        x: 9
        y: 7
      'some waypoint':
        x: 12
        y: 1
    blocks: [
      { x: 1, y: 4 }
      { x: 6, y: 2 }
    ]
    goals: [
      (agent) => 
        goal = @getMap().waypoints['W2']
        ###
        these goals should be formulated as Tasks

        should probably return something like
        description: 'Spot the intruder', status: SUCCES/FAILURE/ERROR/RUNNING 
        (where RUNNING means that the goal is persued, eg. assisted by a count/total)
        ###
        Math.round(agent.x) is goal.x and Math.round(agent.y) is goal.y
    ]


#level = new Level()
#loadMap level.getMap()

class Map
  constuctor: ->

  init: (@context, @level) ->
    @gridSize = 75
    console.log 'Map initialized'
  
  draw: ->
    @context.clearRect 0, 0, @context.canvas.width, @context.canvas.height
    @drawGrid()
    #drawBlocks @context
    @drawWaypoints()
    @drawAgent agent for agent in @level.agents

  update: ->
    for agent in @level.agents
      agent.update()
      agent.text = @level.getMap().goals[0](agent)

  shadow: ->
    @context.shadowColor = "#999"
    @context.shadowBlur = 5
    @context.shadowOffsetX = 3
    @context.shadowOffsetY = 3
  
  noShadow: ->
    @context.shadowBlur = 0
    @context.shadowOffsetX = 0
    @context.shadowOffsetY = 0

  drawGrid: ->
    @noShadow @context
    @context.fillStyle = "rgb(150, 150, 150)"
    @context.strokeStyle = "rgb(50, 50, 50)"
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
    
    @shadow()
    colorIndex = Math.floor(agent.color)
    @context.fillStyle = "rgb(" + colorIndex + ", 0, " + (255 - colorIndex) + ")"
    @context.fillRect -agent.size / 2, -agent.size / 2, agent.size, agent.size
    
    @context.restore()

    @noShadow()
    @context.fillStyle = "rgb(" + (255 - colorIndex) + ", 255, " + colorIndex + ")"
    @context.textAlign = "center"
    @context.textBaseline = "middle"
    @context.fillText agent.text, 0, 0
    @context.restore()

  drawWaypoints: ->
    boxSize = 50
    waypoints = @level.getMap().waypoints
    for key of waypoints
      pos = @getPoint waypoints[key]

      @shadow()
      @context.fillStyle = "rgb(240, 200, 50)"
      @context.beginPath()
      @context.arc pos.x, pos.y, boxSize / 2, 0, 2 * Math.PI, false
      @context.closePath()
      @context.fill()
      @context.strokeStyle = "rgb(120, 100, 25)"
      @context.stroke()

      @noShadow()
      @context.fillStyle = "rgb(120, 100, 25)"
      @context.textAlign = "center"
      @context.textBaseline = "middle"
      @context.fillText key, pos.x, pos.y

  getPoint: (obj) ->
    x: (obj.x + 0.5) * @gridSize
    y: (obj.y + 0.5) * @gridSize 


window.Agent = Agent
window.Level = Level
window.Map = Map
