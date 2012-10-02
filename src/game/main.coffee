
CallbackTask = require('core/callbacktask')
Sequence = require('core/sequence')
Task = require('core/task')
TaskStatus = require('core/taskstatus')

class TweenAction extends Task
  constructor: (obj, to, easing = TWEEN.Easing.Elastic.InOut, duration = 5000) ->
    #console.log 'TweenAction initialized'
    @status = null
    @tween = new TWEEN.Tween(obj)
      .to(to, duration)
      .easing(easing)
      #.onUpdate(@onUpdate)
      .onComplete(@onCompleted)

  #onUpdate: =>
  #  update()

  onCompleted: =>
    #console.log 'TweenTask COMPLETED'
    @status = TaskStatus.SUCCESS

  deactivate: ->
    #console.log 'TweenTask DEACTIVATED'
    @tween.stop()
    @status = TaskStatus.SUCCESS

  activate: ->
    #console.log 'TweenTask ACTIVATED'
    @tween.start()
    @status = TaskStatus.RUNNING

  execute: ->
    TWEEN.update()
    @status


context = canvas.getContext '2d'

level = new window.Level
map = new window.Map

level.init()
map.init context, level

waypoints = level.getMap().waypoints


# ---- agent #1 ----

agent = new window.Agent
root = new Sequence()
for waypointId, waypoint of waypoints
  to =
    x: waypoint.x
    y: waypoint.y
    rotation: Math.floor(Math.random() * 5) * 90
    color: Math.random() * 255
  root.add new TweenAction agent, to, TWEEN.Easing.Quintic.InOut, 2000

agentStart = level.getMap().start
agent.init agentStart.x, agentStart.y
agent.setBehavior root
#level.addAgent agent


###
acceptableTiles = [1]
callback = (path) ->
  if not path?
    console.log "Path was not found."
  else
    console.log "Path was found:"
    console.log path

easyStar = new EasyStar.js acceptableTiles, callback

easyStar.setGrid level.getMap().tiles

startX = 12
startY = 3
endX = 2
endY = 5
easyStar.setPath startX, startY, endX, endY

easyStar.calculate()
###


class MovePathTask extends Task
  constructor: (@agent, startX, startY, endX, endY) ->
    acceptableTiles = [1]
    easyStar = new EasyStar.js acceptableTiles, @pathCallback
    easyStar.setGrid level.getMap().tiles
    easyStar.setPath startX, startY, endX, endY
    easyStar.calculate()

    @pathCount = 0
    @waitCount = 0

  execute: ->
    ###
    var tween = createjs.Tween.get(player)
    .to({x:playerX*TILE_SIZE,y:playerY*TILE_SIZE},100, createjs.Ease.easeNone)
    .call(function() { path.shift(); movePlayerTo(path); })
    ###

    if path?
      @waitCount++
      if @waitCount is 50
        @waitCount = 0
        if @pathCount is path.length
          return TaskStatus.SUCCESS

        p = path[@pathCount]
        console.log p.x, p.y
        @agent.x = p.x
        @agent.y = p.y
        @pathCount++

    return TaskStatus.RUNNING

  activate: ->

  deactivate: ->

  pathCallback: (path) ->
    if not path?
      console.log "Path was not found."
    else
      console.log "Path was found: ", path
      @path = path
      ###
      @tweenAction = new TweenAction @agent, {x: @agent.x, y: @agent.y}, TWEEN.Easing.Quintic.InOut, 2000

      for p in path
        console.log p
        @tweenAction.tween.chain(new TWEEN.Tween(@agent).to({x: p.x, y: p.y}, 2000).easing(TWEEN.Easing.Quintic.InOut))
      ###


# ---- agent #2 ----
agent2 = new window.Agent
root2 = new Sequence()
###
for waypointId, waypoint of waypoints
  to =
    x: waypoint.x
    y: waypoint.y
    rotation: Math.floor(Math.random() * 5) * 90
    color: Math.random() * 255
  root2.add new TweenAction agent2, to, TWEEN.Easing.Elastic.InOut, 4000
###
root2.add new MovePathTask agent2, 12, 3, 2, 5

agent2.init 13, 3
agent2.setBehavior root2
level.addAgent agent2

run = ->
  #root.execute()
  map.update()
  map.draw()
  requestAnimationFrame(run)

run()


