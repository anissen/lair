(function() {
  var CallbackTask, CanSeeAgentCondition, MovePathTask, Sequence, Task, TaskStatus, TweenAction, agent, agent1, agent2, agentStart, assignBehaviorToAgents, context, generateBehaviorTree, level, map, printTree, root, to, waypoint, waypointId, waypoints,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  CallbackTask = require('core/callbacktask');

  Sequence = require('core/sequence');

  Task = require('core/task');

  TaskStatus = require('core/taskstatus');

  TweenAction = (function(_super) {

    __extends(TweenAction, _super);

    function TweenAction(obj, to, easing, duration) {
      if (easing == null) {
        easing = TWEEN.Easing.Elastic.InOut;
      }
      if (duration == null) {
        duration = 5000;
      }
      this.onCompleted = __bind(this.onCompleted, this);

      this.status = null;
      this.tween = new TWEEN.Tween(obj).to(to, duration).easing(easing).onComplete(this.onCompleted);
    }

    TweenAction.prototype.onCompleted = function() {
      return this.status = TaskStatus.SUCCESS;
    };

    TweenAction.prototype.deactivate = function() {
      this.tween.stop();
      return this.status = TaskStatus.SUCCESS;
    };

    TweenAction.prototype.activate = function() {
      this.tween.start();
      return this.status = TaskStatus.RUNNING;
    };

    TweenAction.prototype.execute = function() {
      TWEEN.update();
      return this.status;
    };

    return TweenAction;

  })(Task);

  context = canvas.getContext('2d');

  level = new window.Level;

  map = new window.Map;

  level.init();

  waypoints = level.getMap().waypoints;

  agent = new window.Agent;

  root = new Sequence();

  for (waypointId in waypoints) {
    waypoint = waypoints[waypointId];
    to = {
      x: waypoint.x,
      y: waypoint.y,
      rotation: Math.floor(Math.random() * 5) * 90,
      color: Math.random() * 255
    };
    root.add(new TweenAction(agent, to, TWEEN.Easing.Quintic.InOut, 2000));
  }

  agentStart = level.getMap().start;

  agent.init(agentStart.x, agentStart.y);

  agent.type = 'Agent';

  agent.setBehavior(root);

  level.addAgent(agent);

  MovePathTask = (function(_super) {

    __extends(MovePathTask, _super);

    function MovePathTask(agent, waypoint) {
      var acceptableTiles;
      this.agent = agent;
      this.pathCallback = __bind(this.pathCallback, this);

      acceptableTiles = [1];
      this.easyStar = new EasyStar.js(acceptableTiles, this.pathCallback);
      this.easyStar.setGrid(level.getMap().tiles);
      this.waypointPos = level.getWaypointPosition(waypoint);
    }

    MovePathTask.prototype.execute = function() {
      var p, tweenStatus;
      if (this.path != null) {
        if (this.moveTween != null) {
          tweenStatus = this.moveTween.execute();
          if (tweenStatus !== TaskStatus.SUCCESS) {
            return tweenStatus;
          }
        }
        if (this.pathCount === this.path.length) {
          return TaskStatus.SUCCESS;
        }
        p = this.path[this.pathCount];
        this.pathCount++;
        to = {
          x: p.x,
          y: p.y,
          rotation: Math.floor(Math.random() * 2) * 90,
          color: Math.random() * 255,
          size: 40 + Math.random() * 10
        };
        this.moveTween = new TweenAction(this.agent, to, TWEEN.Easing.Quadratic.In, 200);
        this.moveTween.activate();
      }
      return TaskStatus.RUNNING;
    };

    MovePathTask.prototype.activate = function() {
      this.pathCount = 0;
      this.waitCount = 0;
      this.easyStar.setPath(this.agent.x, this.agent.y, this.waypointPos.x, this.waypointPos.y);
      return this.easyStar.calculate();
    };

    MovePathTask.prototype.deactivate = function() {};

    MovePathTask.prototype.pathCallback = function(path) {
      return this.path = path;
    };

    return MovePathTask;

  })(Task);

  CanSeeAgentCondition = (function(_super) {

    __extends(CanSeeAgentCondition, _super);

    function CanSeeAgentCondition(agent, agentToSee) {
      this.agent = agent;
      this.agentToSee = agentToSee;
    }

    CanSeeAgentCondition.prototype.execute = function() {
      var status;
      status = this.raytrace(this.agent.x, this.agent.y, this.agentToSee.x, this.agentToSee.y);
      return status;
    };

    CanSeeAgentCondition.prototype.raytrace = function(x0, y0, x1, y1) {
      var dx, dy, error, n, x, x_inc, y, y_inc;
      dx = Math.abs(x1 - x0);
      dy = Math.abs(y1 - y0);
      x = x0;
      y = y0;
      n = 1 + dx + dy;
      x_inc = x1 > x0 ? 1 : -1;
      y_inc = y1 > y0 ? 1 : -1;
      error = dx - dy;
      dx *= 2;
      dy *= 2;
      while (n > 0) {
        n--;
        if (this.blocked(x, y)) {
          return TaskStatus.FAILURE;
        }
        if (error > 0) {
          x += x_inc;
          error -= dy;
        } else {
          y += y_inc;
          error += dx;
        }
      }
      return TaskStatus.SUCCESS;
    };

    CanSeeAgentCondition.prototype.blocked = function(x, y) {
      return level.getMap().tiles[y][x] === 0;
    };

    return CanSeeAgentCondition;

  })(Task);

  agent1 = new window.Agent;

  agent1.init(14, 3);

  agent1.text = 'Agent 1';

  agent1.color = 100;

  level.addAgent(agent1);

  agent2 = new window.Agent;

  agent2.init(5, 3);

  agent2.text = 'Agent 2';

  level.addAgent(agent2);

  map.init(context, level);

  printTree = function(node, indent) {
    indent += "-";
    return $.each(node.childNodes, function(i, n) {
      console.log(indent + n.data.text);
      return printTree(n, indent);
    });
  };

  assignBehaviorToAgents = function(node) {
    return $.each(node.childNodes, function(i, n) {
      var behavior;
      agent = level.getAgent(n.raw.agentId);
      behavior = generateBehaviorTree(n, agent);
      return agent.setBehavior(behavior);
    });
  };

  generateBehaviorTree = function(node, agent) {
    var settings, treeNode;
    treeNode = void 0;
    settings = node.raw.settings;
    switch (node.raw.type) {
      case 'Agent' || 'SequenceComposite':
        treeNode = new Sequence();
        break;
      case 'MoveToWaypointAction':
        treeNode = new MovePathTask(agent, settings.waypoint);
        break;
      case 'CanSeeAgentCondition':
        treeNode = new CanSeeAgentCondition(agent, level.getAgent(settings.agentId));
        break;
      default:
        throw new Error('Unknown tree node type: "' + node.raw.type + '"');
    }
    $.each(node.childNodes, function(i, n) {
      return treeNode.add(generateBehaviorTree(n, agent));
    });
    return treeNode;
  };

  $(document).ready(function() {
    return $('#assign-behavior').on('click', function() {
      return assignBehaviorToAgents(behaviorTree.getRootNode());
    });
  });

}).call(this);
