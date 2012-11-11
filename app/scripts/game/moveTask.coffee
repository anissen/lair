Task = require './compositetask'
TaskStatus = require './taskstatus'

class MoveTask extends Task
  constructor: (@from, @to, @duration) ->
  execute: ->
    # get time from Task
    # OR
    # create a new function that takes the time

    

    TaskStatus.SUCCESS

module.exports = Sequence