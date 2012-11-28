Ext.require ["*"]
libraryTree = undefined
behaviorTree = undefined
propertyGrid = undefined

Ext.onReady ->
  libraryTree = Ext.create("Ext.tree.Panel",
    id: "tree"
    height: 300
    viewConfig:
      plugins:
        ptype: "treeviewdragdrop"
        appendOnly: true

    root:
      text: "Root"
      expanded: true
      children: [
        ###
        text: "Sequence"
        leaf: false
        type: "SequenceComposite"
      ,
        text: "Sequence"
        leaf: false
        type: "SequenceComposite"
      ,
        text: "Selector"
        leaf: false
        type: "SelectorComposite"
      ,
        text: "Parallel"
        leaf: false
        type: "ParallelComposite"
      ,
        ###
        text: "Move to waypoint!"
        leaf: true
        type: "MoveToWaypointAction"
        settings:
          waypoint: "trash"
          speed: 1.0
      ,
        text: "Move to waypoint!"
        leaf: true
        type: "MoveToWaypointAction"
        settings:
          waypoint: "trash"
          speed: 1.0
      ,
        text: "Print!"
        leaf: true
        type: "PrintAction"
        settings:
          text: 'Hello World!'
      ]
      ###,
        text: "Move to waypoint!"
        leaf: true
        type: "MoveToWaypointAction"
        settings:
          waypoint: "W3"
          speed: 1.0
      ,
        text: "Move to waypoint!"
        leaf: true
        type: "MoveToWaypointAction"
        settings:
          waypoint: "W4"
          speed: 1.0
      ,
        text: "Can see agent?"
        leaf: true
        type: "CanSeeAgentCondition"
        settings:
          viewDistance: 5.0
          agentId: 0
      ,
        text: "Print!"
        leaf: true
        type: "PrintAction"
        settings:
          text: 'Hello World!'
      ,
        text: "Print!"
        leaf: true
        type: "PrintAction"
        settings:
          text: 'Hello Earth!'
      ]
      ###


    rootVisible: false
    renderTo: "library-tree"
  )

  behaviorTree = Ext.create("Ext.tree.Panel",
    id: "tree2"
    height: 300
    viewConfig:
      plugins:
        ptype: "treeviewdragdrop"
        appendOnly: true

    root:
      text: "Root"
      type: "SequenceComposite"
      expanded: true
      children: [
        text: "Agent 1"
        type: "Agent"
        agentId: 0
        allowDrag: false
        #icon: "http://www.iconfinder.com/ajax/download/png/?id=49398&s=16"
        ###
      ,
        text: "Agent 2"
        type: "Agent"
        agentId: 1
        allowDrag: false
        #icon: "http://www.iconfinder.com/ajax/download/png/?id=49398&s=16"
        ###
      ]

    listeners:
      itemclick: (view, rec, item, index, eventObj) ->
        propertyGrid.setSource rec.raw.settings

    renderTo: "behavior-tree"
  )

  propertyGrid = Ext.create("Ext.grid.property.Grid",
    height: 300
    renderTo: "property-grid"
    source: {}
  )

