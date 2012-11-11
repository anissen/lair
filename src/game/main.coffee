
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
agent.type = 'Agent'
agent.setBehavior root
level.addAgent agent


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
  constructor: (@agent, waypoint) ->
    acceptableTiles = [1]
    @easyStar = new EasyStar.js acceptableTiles, @pathCallback
    @easyStar.setGrid level.getMap().tiles
    @waypointPos = level.getWaypointPosition waypoint

  execute: ->
    ###
    if @path?
      @waitCount++
      if @waitCount is 50
        @waitCount = 0
        if @pathCount is @path.length
          @pathCount = 0
          return TaskStatus.SUCCESS

        p = @path[@pathCount]
        @agent.x = p.x
        @agent.y = p.y

        @pathCount++
    ###

    if @path?
      if @moveTween?
        tweenStatus = @moveTween.execute()
        return tweenStatus if tweenStatus isnt TaskStatus.SUCCESS

      if @pathCount is @path.length
        return TaskStatus.SUCCESS

      p = @path[@pathCount]
      @pathCount++
      to =
        x: p.x
        y: p.y
        rotation: Math.floor(Math.random() * 2) * 90
        color: Math.random() * 255
        size: 40 + Math.random() * 10
      @moveTween = new TweenAction @agent, to, TWEEN.Easing.Quadratic.In, 200
      @moveTween.activate()

    return TaskStatus.RUNNING

  activate: ->
    @pathCount = 0
    @waitCount = 0
    @easyStar.setPath @agent.x, @agent.y, @waypointPos.x, @waypointPos.y
    @easyStar.calculate()

  deactivate: ->

  pathCallback: (path) =>
    @path = path


class CanSeeAgentCondition extends Task
  constructor: (@agent, @agentToSee) ->
  execute: ->
    #lineOfSight =
    #  x: @agent.x + (@agent.x - @agentToSee.x)
    #  y: @agent.y + (@agent.y - @agentToSee.y)
    status = @raytrace @agent.x, @agent.y, @agentToSee.x, @agentToSee.y
    #console.log 'CanSeeAgentCondition: ' + status
    return status
    #return TaskStatus.SUCCESS

  raytrace: (x0, y0, x1, y1) ->
    dx = Math.abs(x1 - x0)
    dy = Math.abs(y1 - y0)
    x = x0
    y = y0
    n = 1 + dx + dy
    x_inc = if x1 > x0 then 1 else -1
    y_inc = if y1 > y0 then 1 else -1
    error = dx - dy
    dx *= 2
    dy *= 2

    while n > 0
      n--
      if @blocked(x, y)
        return TaskStatus.FAILURE

      if error > 0
        x += x_inc
        error -= dy
      else
        y += y_inc
        error += dx

    return TaskStatus.SUCCESS

  blocked: (x, y) ->
    #map.addDebugLine @agent.x, @agent.y, x, y, 'rgb(0,0,255)'
    return level.getMap().tiles[y][x] is 0

# ---- agent #2 ----
###
agent2 = new window.Agent
root2 = new Sequence()
for waypointId, waypoint of waypoints
  to =
    x: waypoint.x
    y: waypoint.y
    rotation: Math.floor(Math.random() * 5) * 90
    color: Math.random() * 255
  root2.add new TweenAction agent2, to, TWEEN.Easing.Elastic.InOut, 4000
root2.add new MovePathTask agent2, 12, 3, 2, 5

agent2.init 13, 3
agent2.setBehavior root2
level.addAgent agent2
###


agent1 = new window.Agent
agent1.init 14, 3
agent1.text = 'Agent 1'
agent1.color = 100
level.addAgent agent1

agent2 = new window.Agent
agent2.init 5, 3
agent2.text = 'Agent 2'
level.addAgent agent2

map.init context, level

###
run = ->
  #root.execute()
  map.update()
  map.draw()
  requestAnimationFrame run

run()
###

printTree = (node, indent) ->
  indent += "-"
  $.each node.childNodes, (i, n) ->
    console.log indent + n.data.text
    printTree n, indent

assignBehaviorToAgents = (node) ->
  $.each node.childNodes, (i, n) ->
    agent = level.getAgent n.raw.agentId
    behavior = generateBehaviorTree n, agent
    agent.setBehavior behavior

generateBehaviorTree = (node, agent) ->
  treeNode = undefined
  settings = node.raw.settings

  switch node.raw.type
    when 'Agent' or 'SequenceComposite'
      treeNode = new Sequence()
    when 'MoveToWaypointAction'
      treeNode = new MovePathTask agent, settings.waypoint
    when 'CanSeeAgentCondition'
      treeNode = new CanSeeAgentCondition agent, level.getAgent(settings.agentId)
    else
      throw new Error 'Unknown tree node type: "' + node.raw.type + '"'

  $.each node.childNodes, (i, n) ->
    treeNode.add generateBehaviorTree(n, agent)

  treeNode

$(document).ready ->
  $('#assign-behavior').on 'click', ->
    assignBehaviorToAgents behaviorTree.getRootNode()


