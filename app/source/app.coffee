'use strict'

lairApp = angular.module('lairApp', []).config(['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when('/',
      templateUrl: 'views/home.html'
      controller: 'HomeCtrl'
    )
    .when('/lair',
      templateUrl: 'views/lair.html'
      controller: 'LairCtrl'
    )
    .otherwise redirectTo: '/'
])
