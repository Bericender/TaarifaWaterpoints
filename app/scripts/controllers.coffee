'use strict'

angular.module('taarifaWaterpointsApp')
  .controller 'MainCtrl', ($scope, Waterpoint) ->
    Waterpoint.query (waterpoints) ->
      $scope.waterpoints = waterpoints._items
  .controller 'MapCtrl', ($scope, Map) ->
    $scope.map = Map
  .controller 'WaterpointCreateCtrl', ($scope, Waterpoint, FacilityForm, flash) ->
    $scope.formTemplate = FacilityForm 'wpf001'
    # FIXME: Should not hardcode the facility code here
    $scope.form =
      facility_code: "wpf001"
    $scope.save = () ->
      Waterpoint.save $scope.form, (waterpoint) ->
        if waterpoint._status == 'OK'
          console.log "Successfully created waterpoint", waterpoint
          flash.success = 'Waterpoint successfully created!'
        if waterpoint._status == 'ERR'
          console.log "Failed to create waterpoint", waterpoint
          for field, message of waterpoint._issues
            flash.error = "#{field}: #{message}"
  .controller 'WaterpointEditCtrl', ($scope, $http, $routeParams, Waterpoint, FacilityForm, flash) ->
    Waterpoint.get id: $routeParams.id, (waterpoint) ->
      $scope.form = waterpoint
    $scope.formTemplate = FacilityForm 'wpf001'
    $scope.save = () ->
      etag = $scope.form._etag
      # We need to remove these special attributes since they are not defined
      # in the schema and the data will not validate and the update be rejected
      for attr in ['_created', '_etag', '_id', '_links', '_updated']
        $scope.form[attr] = undefined
      $http.put('/api/waterpoints/'+$routeParams.id,
                $scope.form,
                headers: {'If-Match': etag})
        .success (data, status, headers, config) ->
          console.log data, status, headers, config
          if status == 200 and data._status == 'OK'
            flash.success = 'Waterpoint successfully saved!'
          if status == 200 and data._status == 'ERR'
            for field, message of data._issues
              flash.error = "#{field}: #{message}"
  .controller 'RequestCreateCtrl', ($scope, $location, Request, RequestForm, flash) ->
    $scope.formTemplate = RequestForm 'wps001', $location.search()
    # FIXME: Should not hardcode the service code here
    $scope.form = {}
    $scope.save = () ->
      form =
        service_code: "wps001"
        attribute: $scope.form
      Request.save form, (request) ->
        if request._status == 'OK'
          console.log "Successfully created request", request
          flash.success = 'Request successfully created!'
        if request._status == 'ERR'
          console.log "Failed to create request", request
          for field, message of request._issues.attribute
            flash.error = "#{field}: #{message}"
  .controller 'DashboardCtrl', ($scope, $http) ->
    $http.get('/api/waterpoints/values/region').success (data, status, headers, config) ->
      $scope.regions = data
    $http.get('/api/waterpoints/values/district').success (data, status, headers, config) ->
      $scope.districts = data
    $http.get('/api/waterpoints/values/ward').success (data, status, headers, config) ->
      $scope.wards = data
    $scope.getStatus = () ->
      $http.get('/api/waterpoints/status', params: $scope.params).success (data, status, headers, config) ->
        $scope.status = data
    $scope.getStatus()
