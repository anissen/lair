var Agent, Level, Map;

Agent = (function() {

  function Agent() {}

  Agent.prototype.init = function(x, y, color, rotation, size, text, type, imageSrc) {
    var tempImage;
    this.x = x != null ? x : 0;
    this.y = y != null ? y : 0;
    this.color = color != null ? color : 0;
    this.rotation = rotation != null ? rotation : 0;
    this.size = size != null ? size : 50;
    this.text = text != null ? text : 'Agent';
    this.type = type != null ? type : 'Robot';
    this.imageSrc = imageSrc != null ? imageSrc : 'terminator.png';
    tempImage = new Image();
    tempImage.src = 'images/' + this.imageSrc;
    this.image = new createjs.Bitmap(tempImage);
    this.image.scaleX = 0.015;
    return this.image.scaleY = 0.015;
  };

  Agent.prototype.setBehavior = function(behavior) {
    this.behavior = behavior;
  };

  Agent.prototype.update = function() {
    var _ref;
    if ((_ref = this.behavior) != null) {
      _ref.execute();
    }
    this.image.x = this.x + 0.2;
    return this.image.y = this.y + 0.1;
  };

  return Agent;

})();

Level = (function() {

  function Level() {
    this.agents = [];
  }

  Level.prototype.init = function() {};

  Level.prototype.addAgent = function(agent) {
    return this.agents.push(agent);
  };

  Level.prototype.getAgent = function(index) {
    return this.agents[index];
  };

  Level.prototype.getWaypointPosition = function(waypointId) {
    return this.getMap().waypoints[waypointId];
  };

  Level.prototype.getMap = function() {
    var _this = this;
    return {
      width: 18,
      height: 7,
      waypoints: {
        'W1': {
          x: 10,
          y: 1
        },
        'W2': {
          x: 1,
          y: 1
        },
        'W3': {
          x: 8,
          y: 3
        },
        'W4': {
          x: 3,
          y: 3
        }
      },
      tiles: [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 2, 0, 0], [0, 3, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]],
      start: {
        x: 16,
        y: 3
      },
      goals: [
        function(agent) {
          var goal;
          goal = _this.getMap().waypoints['W4'];
          /*
                  these goals should be formulated as Tasks
          
                  should probably return something like
                  description: 'Spot the intruder', status: SUCCES/FAILURE/ERROR/RUNNING
                  (where RUNNING means that the goal is persued, eg. assisted by a count/total)
          */

          return Math.round(agent.x - 0.5) === goal.x && Math.round(agent.y - 0.5) === goal.y;
        }
      ]
    };
  };

  return Level;

})();

Map = (function() {

  function Map() {}

  Map.prototype.constuctor = function() {};

  Map.prototype.init = function(context, level) {
    var agent, canvas, tile, tileMargin, tileType, tilesX, tilesY, x, y, _i, _j, _k, _len, _ref,
      _this = this;
    this.context = context;
    this.level = level;
    canvas = document.getElementById('canvas');
    this.stage = new createjs.Stage(canvas);
    createjs.Touch.enable(this.stage);
    this.stage.enableMouseOver(10);
    this.stage.mouseMoveOutside = true;
    createjs.Ticker.setFPS(30);
    this.tiles = [];
    tilesX = this.level.getMap().width;
    tilesY = this.level.getMap().height;
    tileMargin = 0.02;
    for (x = _i = 0; 0 <= tilesX ? _i < tilesX : _i > tilesX; x = 0 <= tilesX ? ++_i : --_i) {
      this.tiles.push(new Array(tilesY));
      for (y = _j = 0; 0 <= tilesY ? _j < tilesY : _j > tilesY; y = 0 <= tilesY ? ++_j : --_j) {
        tileType = this.level.getMap().tiles[y][x];
        tile = new createjs.Shape();
        this.stage.addChild(tile);
        tile.x = x;
        tile.y = y;
        tile.graphics.beginFill(createjs.Graphics.getRGB(tileType * 100, 0, y * 20)).drawRoundRect(tileMargin, tileMargin, 1 - tileMargin * 2, 1 - tileMargin * 2, 0.15);
        tile.alpha = 1.0;
        this.tiles[x][y] = tile;
      }
    }
    _ref = this.level.agents;
    for (_k = 0, _len = _ref.length; _k < _len; _k++) {
      agent = _ref[_k];
      this.stage.addChild(agent.image);
    }
    this.stage.onPress = function(evt) {
      var offset;
      offset = {
        x: _this.stage.x - evt.stageX,
        y: _this.stage.y - evt.stageY
      };
      return evt.onMouseMove = function(ev) {
        _this.stage.x = ev.stageX + offset.x;
        return _this.stage.y = ev.stageY + offset.y;
      };
    };
    this.stage.scaleX = 70;
    this.stage.scaleY = 70;
    this.stage.x = canvas.width / 2;
    this.stage.y = canvas.height / 2;
    this.stage.regX = 15.5;
    this.stage.regY = 3.5;
    this.stage.update();
    return createjs.Ticker.addListener(this);
    /*
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
    */

  };

  Map.prototype.tick = function() {
    var agent, _i, _len, _ref;
    _ref = this.level.agents;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      agent = _ref[_i];
      agent.update();
    }
    return this.stage.update();
  };

  return Map;

})();

window.Agent = Agent;

window.Level = Level;

window.Map = Map;
