
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
level.addAgent agent


# ---- agent #2 ----
agent2 = new window.Agent
root2 = new Sequence()
for waypointId, waypoint of waypoints
  to =
    x: waypoint.x
    y: waypoint.y
    rotation: Math.floor(Math.random() * 5) * 90
    color: Math.random() * 255
  root2.add new TweenAction agent2, to, TWEEN.Easing.Elastic.InOut, 4000

agent2.init 8, 8
agent2.setBehavior root2
level.addAgent agent2


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



run = ->
  #root.execute()
  map.update()
  map.draw()
  requestAnimationFrame(run)

run()


