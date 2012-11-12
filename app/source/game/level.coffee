
class Agent
  constructor: ->
  init: (@x = 0, @y = 0, @color = 0, @rotation = 0, @size = 50, @text = 'Agent', @type = 'Robot', @imageSrc = 'terminator.png') ->
    @image = new createjs.Bitmap 'resources/images/' + @imageSrc
    @image.scaleX = 0.015
    @image.scaleY = 0.015

  setBehavior: (@behavior) ->
  update: ->
    @behavior?.execute()
    @image.x = @x + 0.2
    @image.y = @y + 0.1


class Level
  constructor: ->
    @agents = []
  init: ->

  addAgent: (agent) ->
    @agents.push agent
  getAgent: (index) ->
    @agents[index]
  getWaypointPosition: (waypointId) ->
    @getMap().waypoints[waypointId]
  getMap: ->
    width: 18
    height: 7
    waypoints:
      'W1':
        x: 10
        y: 1
      'W2':
        x: 1
        y: 1
      'W3':
        x: 8
        y: 3
      'W4':
        x: 3
        y: 3
    tiles: [
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],
        [0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0],
        [0,0,0,1,1,1,1,1,1,0,1,1,1,1,1,2,0,0],
        [0,3,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
        [0,1,1,1,0,1,1,1,1,1,1,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    ]
    start:
      x: 16
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


class Map
  constuctor: ->

  init: (@context, @level) ->
    canvas = document.getElementById 'canvas'
    @stage = new createjs.Stage canvas

    # enable touch interactions if supported on the current device:
    createjs.Touch.enable @stage

    # enabled mouse over / out events
    @stage.enableMouseOver 10
    @stage.mouseMoveOutside = true # keep tracking the mouse even when it leaves the canvas

    createjs.Ticker.setFPS 30

    @tiles = []
    tilesX = @level.getMap().width
    tilesY = @level.getMap().height
    tileMargin = 0.02

    for x in [0...tilesX]
      @tiles.push new Array(tilesY)
      for y in [0...tilesY]
        tileType = @level.getMap().tiles[y][x]
        tile = new createjs.Shape()
        @stage.addChild tile
        tile.x = x
        tile.y = y
        tile.graphics.beginFill(createjs.Graphics.getRGB(tileType * 100,0,y*20)).drawRoundRect(tileMargin, tileMargin, 1 - tileMargin * 2, 1 - tileMargin * 2, 0.15)
        tile.alpha = 1.0
        @tiles[x][y] = tile


    for agent in @level.agents
      @stage.addChild agent.image

    @stage.onPress = (evt) =>
      offset =
        x: @stage.x - evt.stageX
        y: @stage.y - evt.stageY

      evt.onMouseMove = (ev) =>
        @stage.x = ev.stageX + offset.x
        @stage.y = ev.stageY + offset.y

    @stage.scaleX = 70
    @stage.scaleY = 70
    @stage.x = canvas.width / 2
    @stage.y = canvas.height / 2
    @stage.regX = 15.5
    @stage.regY = 3.5
    @stage.update()

    createjs.Ticker.addListener this

    ###
    highlightTile = (x, y) ->
      createjs.Tween.get(@tiles[x][y])
        .to({rotation: 180}, 1000, createjs.Ease.cubicInOut)
        .to({rotation: 0}, 1000, createjs.Ease.cubicInOut)

    tween = createjs.Tween.get(@stage)
              .wait(1000)
              .to({scaleX: 200, scaleY: 200, regX: 1.5, regY: 4.5}, 3000, createjs.Ease.cubicInOut)
              .call(highlightTile, [1,4], this)
              .wait(2000)
              .to({regX: 5.5, regY: 1.5}, 2000, createjs.Ease.cubicInOut)
              .to({regX: 15.5, regY: 3.5}, 2000, createjs.Ease.cubicInOut)
              .wait(1000)
              .to({scaleX: 70, scaleY: 70, rotation: 360}, 5000, createjs.Ease.elasticOut)
    ###

  tick: ->
    for agent in @level.agents
      agent.update()

    @stage.update()

window.Agent = Agent
window.Level = Level
window.Map = Map
