Ext.require(['*']);

var libraryTree, behaviorTree;

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
                    text: 'MoveToWaypoint!',
                    leaf: true,
                    data: 'Blah'
                },
                {
                    text: 'IsEnemySpotted?',
                    leaf: true
                }
            ]
        },
        rootVisible: false,
        renderTo: 'library-tree' //document.body
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
        renderTo: 'behavior-tree' //document.body
    });
});
