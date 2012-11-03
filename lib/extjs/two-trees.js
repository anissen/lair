Ext.require(['*']);

var libraryTree, behaviorTree, propertyGrid;

Ext.onReady(function(){
    libraryTree = Ext.create('Ext.tree.Panel', {
        id: 'tree',
        //width: 250,
        height: 300,
        viewConfig: {
            plugins: {
                ptype: 'treeviewdragdrop',
                appendOnly: true
            }
        },
        root: {
            text: 'Root',
            expanded: true,
            children: [
                {
                    text: 'Sequence',
                    leaf: false
                },
                {
                    text: 'Selector',
                    leaf: false
                },
                {
                    text: 'Move to waypoint!',
                    leaf: true,
                    id: 'MoveToWaypointAction',
                    settings: {
                      waypoint: 'W1',
                      speed: 1.0
                    }
                },
                {
                    text: 'Is enemy spotted?',
                    leaf: true,
                    id: 'IsEnemySpottedCondition',
                    settings: {
                      viewDistance: 5.0
                    }
                }
            ]
        },
        rootVisible: false,
        renderTo: 'library-tree'
    });

    behaviorTree = Ext.create('Ext.tree.Panel', {
        id: 'tree2',
        //width: 250,
        height: 300,
        viewConfig: {
            plugins: {
                ptype: 'treeviewdragdrop',
                appendOnly: true
            }
        },
        root: {
            text: 'Root',
            expanded: true,
            children: []
        },
        listeners: {
          itemclick: function (view, rec, item, index, eventObj) {
            propertyGrid.setSource(rec.raw.settings);
          }
        },
        renderTo: 'behavior-tree'
    });

    propertyGrid = Ext.create('Ext.grid.property.Grid', {
        height: 300,
        renderTo: 'property-grid',
        source: {}
    });
});
