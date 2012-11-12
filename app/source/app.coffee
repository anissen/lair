'use strict'

lairApp = angular.module('lairApp', []).config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/',
    templateUrl: 'views/main.html'
    controller: 'MainCtrl'
  ).otherwise redirectTo: '/'
])
