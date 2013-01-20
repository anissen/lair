
class Agent
  constructor: ->
  init: (@x = 0, @y = 0, @text = 'Agent', @type = 'Robot', @imageSrc = 'terminator.png') ->
    @image = new createjs.Bitmap 'resources/images/' + @imageSrc
    @image.scaleX = 0.015
    @image.scaleY = 0.015

  setBehavior: (@behavior) ->
  update: ->
    @behavior?.execute()
    @image.x = @x + 0.2
    @image.y = @y + 0.1

class Trash
  constructor: ->
  init: (@x, @y) ->
    @image = new createjs.Bitmap 'resources/images/trash.png'
    @image.scaleX = 0.015
    @image.scaleY = 0.015
    @image.x = @x + 0.25
    @image.y = @y + 0.25
  pickUp: ->
    notPickedUp = @image.visible
    @image.visible = false
    return notPickedUp

class Dumpster
  constructor: ->
  init: (@x, @y) ->
    @image = new createjs.Bitmap 'resources/images/trashcan-empty.png'
    @image.scaleX = 0.006
    @image.scaleY = 0.006
    @image.x = @x + 0.1
    @image.y = @y + 0.1
  dumpTrash: ->
    @trashDumped = true

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
  isGoalAccomplished: (map) ->
    map.dumpster?.trashDumped?
  getMap: ->
    width: 18
    height: 7
    waypoints:
      'trash':
        x: 1
        y: 1
        info: 'Oh noes, trash!'
      'dumpster':
        x: 3
        y: 1
        info: 'Luckily we have a dumpster'
    objects:[
      type: 'trash'
      x: 1
      y: 1
    ,
      type: 'dumpster'
      x: 3
      y: 1
    ]
    tasks: [
      name: 'MoveToWaypointAction'
      settings:
        waypoint: 'trash'
    ,
      name: 'PickUpTrashAction'
    ,
      name: 'MoveToWaypointAction'
      settings:
        waypoint: 'dumpster'
    ,
      name: 'DumpTrashAction'
    ,
      name: 'PrintAction'
      settings:
        text: 'Hello'
    ]
    tiles: [
        [0,0,0,0,0,0],
        [0,1,0,1,1,1],
        [0,1,0,0,1,0],
        [0,1,1,1,1,0],
        [0,0,0,0,0,0]
    ]
    start:
      x: 5
      y: 1


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

    map = @level.getMap()
    @tiles = []
    tilesX = map.tiles[0].length
    tilesY = map.tiles.length
    tileMargin = 0.02

    for x in [0...tilesX]
      @tiles.push new Array(tilesY)
      for y in [0...tilesY]
        tileType = map.tiles[y][x]
        tile = new createjs.Shape()
        @stage.addChild tile
        tile.x = x
        tile.y = y
        tile.graphics.beginFill(createjs.Graphics.getRGB(tileType * 100,0,y*20)).drawRoundRect(tileMargin, tileMargin, 1 - tileMargin * 2, 1 - tileMargin * 2, 0.15)
        tile.alpha = 1.0
        @tiles[x][y] = tile

    for obj in map.objects
      switch obj.type
        when 'trash'
          @trash = object = new Trash()
        when 'dumpster'
          @dumpster = object = new Dumpster()

      object.init obj.x, obj.y
      @stage.addChild object.image


    for key, pos of map.waypoints
      @tiles[pos.x][pos.y].graphics.beginFill(createjs.Graphics.getRGB(0,130,y*20)).drawRoundRect(tileMargin, tileMargin, 1 - tileMargin * 2, 1 - tileMargin * 2, 0.15)
      ###
      waypoint = new createjs.Bitmap 'resources/images/waypoint.png'
      waypoint.scaleX = 0.012
      waypoint.scaleY = 0.012
      waypoint.x = pos.x + 0.1
      waypoint.y = pos.y
      waypoint.alpha = 0.6
      @stage.addChild waypoint
      ###


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
    @stage.regX = tilesX / 2
    @stage.regY = tilesY / 2
    @stage.update()

    createjs.Ticker.addListener this

    ###
    trashInfo = map.waypoints['trash']
    dumpsterInfo = map.waypoints['dumpster']
    tween = createjs.Tween.get(@stage)
              .wait(1000)

              .to({scaleX: 300, scaleY: 300, regX: map.start.x + 0.5, regY: map.start.y + 0.5}, 1000, createjs.Ease.cubicInOut)
              .call(@showTileInfo, [map.start.x + 0.5, map.start.y + 0.5, 'This is you'], this)
              .wait(2000)

              .to({regX: trashInfo.x + 0.5, regY: trashInfo.y + 0.5}, 1000, createjs.Ease.cubicInOut)
              .call(@showTileInfo, [trashInfo.x + 0.5, trashInfo.y + 0.5, trashInfo.info], this)
              .wait(2000)

              .to({regX: dumpsterInfo.x + 0.5, regY: dumpsterInfo.y + 0.5}, 1000, createjs.Ease.cubicInOut)
              .call(@showTileInfo, [dumpsterInfo.x + 0.5, dumpsterInfo.y + 0.5, dumpsterInfo.info], this)
              .wait(2000)

              .to({scaleX: 100, scaleY: 100}, 1000, createjs.Ease.cubicInOut)
              .call(@showTileInfo, [dumpsterInfo.x + 0.5, dumpsterInfo.y + 0.5, 'Go dump the trash in the dumpster!'], this)
    ###

  showTileInfo: (x, y, info) ->
    infoBox = new createjs.Text info, null, 'white'
    infoBox.x = x
    infoBox.y = y + 0.4
    infoBox.alpha = 0
    infoBox.textAlign = 'center'
    infoBox.scaleX = (1 / @stage.scaleX) * 3
    infoBox.scaleY = (1 / @stage.scaleY) * 3
    @stage.addChild infoBox
    createjs.Tween.get(infoBox)
      .to({alpha: 100}, 750, createjs.Ease.cubicInOut)
      .wait(500)
      .to({alpha: 0}, 750, createjs.Ease.cubicInOut)

  tick: ->
    for agent in @level.agents
      agent.update()

    @stage.update()

    if not @won and @level.isGoalAccomplished(this)
      @won = true
      @showTileInfo 3, 3, 'Congratulations, you win!'

window.Agent = Agent
window.Level = Level
window.Map = Map
