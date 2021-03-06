angular.module('train').controller "train", ($scope, storage)->

  $scope.keys =
    accelerate: [87, 38] #w, up-arrow
    decelerate: [83, 40] #s, down-arrow
    brake:      [32, 27] #space, esc
    whistle:    [72] #h

  $scope.interval = 1
  $scope.range = 10 # distance from 0 we are allowed to go. Omnidirectional.

  $scope.speed = 0

  $scope.setSpeed = (speed) ->

    $scope.speed = speed

    # Fire off an event to Node.js to let it know that the speed changed.
    storage.emit 'train.speed',
      speed: $scope.speed

  $scope.onWhistle = ->
    storage.emit 'train.whistle', {}

  $scope.onChange = (amount) ->
    # Sanitize input a bit.
    amount = parseInt amount
    # Amount of 0 is a special case indicating braking action.
    if amount is 0
      console.log "Brakes!"
      newSpeed = 0
    else
      console.log "Current speed: #{ $scope.speed }. Attempting to change speed by #{ amount }."
      newSpeed = $scope.governor(parseInt($scope.speed) + parseInt(amount))
      console.log "Regulated to #{ newSpeed }"

    $scope.$apply ->
      $scope.setSpeed newSpeed

  $scope.governor = (attemptedSpeed) ->
    newSpeed = parseInt(attemptedSpeed)

    # Ensure we are within range, whether positive or negative.
    if Math.abs(attemptedSpeed) > $scope.range
      newSpeed = $scope.range
      # Remember if it's a negative value.
      newSpeed = if attemptedSpeed < 0 then (-1 * newSpeed) else newSpeed

    newSpeed

  storage.on 'train.speed', (data) =>
    console.log "SPEED UPDATE FROM SERVER!", data
    $scope.$apply ->
      $scope.speed = parseInt(data.speed)
