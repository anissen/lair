
CallbackTask = require('core/callbacktask')
Sequence = require('core/sequence')
Task = require('core/task')
CompositeTask = require('core/compositetask')
TaskStatus = require('core/taskstatus')

class Parallel extends CompositeTask
  execute: ->
    status = {}
    for task in @tasks
      taskStatus = task.execute()
      status[taskStatus]++

    return TaskStatus.ERROR if status[TaskStatus.ERROR] > 0
    return TaskStatus.SUCCESS if status[TaskStatus.SUCCESS] is @tasks.length
    return TaskStatus.RUNNING if status[TaskStatus.RUNNING] > 0
    return TaskStatus.FAILURE

class TweenAction extends Task
  constructor: (obj, to, easing = TWEEN.Easing.Elastic.InOut, duration = 5000) ->
    @status = null
    @tween = new TWEEN.Tween(obj)
      .to(to, duration)
      .easing(easing)
      .onComplete(@onCompleted)

  onCompleted: =>
    @status = TaskStatus.SUCCESS

  deactivate: ->
    @tween.stop()
    @status = TaskStatus.SUCCESS

  activate: ->
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
###
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

class MovePathTask extends Task
  constructor: (@agent, waypoint) ->
    acceptableTiles = [1]
    @easyStar = new EasyStar.js acceptableTiles, @pathCallback
    @easyStar.setGrid level.getMap().tiles
    @waypointPos = level.getWaypointPosition waypoint

  execute: ->
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
      @moveTween = new TweenAction @agent, to, TWEEN.Easing.Quadratic.InOut, 500
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
    status = @raytrace @agent.x, @agent.y, @agentToSee.x, @agentToSee.y
    return status

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
    return level.getMap().tiles[y][x] is 0


agent1 = new window.Agent
agent1.init level.getMap().start.x, level.getMap().start.y
level.addAgent agent1

map.init context, level

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
    when 'Agent'
      treeNode = new Sequence()
    when 'SequenceComposite'
      treeNode = new Sequence()
    when 'ParallelComposite'
      console.log 'Creating parallel'
      treeNode = new Parallel()
    when 'PrintAction'
      treeNode = new CallbackTask ->
        #console.log 'PrintAction:', settings.text
        $.pnotify
          title: 'PrintAction',
          text: settings.text,
          type: 'info',
          nonblock: true,
          nonblock_opacity: .4
        TaskStatus.SUCCESS
    when 'MoveToWaypointAction'
      treeNode = new MovePathTask agent, settings.waypoint
    when 'CanSeeAgentCondition'
      agentToSee = level.getAgent(settings.agentId)
      alert 'Invalid agentId' if not agentToSee?
      alert 'Agent to see is the agent itself' if agent is agentToSee
      treeNode = new CanSeeAgentCondition agent, agentToSee
    else
      throw new Error 'Unknown tree node type: "' + node.raw.type + '"'

  $.each node.childNodes, (i, n) ->
    treeNode.add generateBehaviorTree(n, agent)

  treeNode

$('#assign-behavior').on 'click', (evt) ->
  evt.preventDefault()
  assignBehaviorToAgents behaviorTree.getRootNode()


