(function() {
  var MoveTask, Task, TaskStatus,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Task = require('./compositetask');

  TaskStatus = require('./taskstatus');

  MoveTask = (function(_super) {

    __extends(MoveTask, _super);

    function MoveTask(from, to, duration) {
      this.from = from;
      this.to = to;
      this.duration = duration;
    }

    MoveTask.prototype.execute = function() {
      return TaskStatus.SUCCESS;
    };

    return MoveTask;

  })(Task);

  module.exports = Sequence;

}).call(this);
