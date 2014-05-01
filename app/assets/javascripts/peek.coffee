#= require peek/vendor/jquery.tipsy

requestId = null
pastResults = []
seenIds = []
currentIndex = 0

getRequestId = ->
  if requestId? then requestId else $('#peek').data('request-id')

peekEnabled = ->
  $('#peek').length

gotNewResults = (results) ->
  if seenIds.indexOf(results.id) < 0
    pastResults.push(results)
    seenIds.push(results.id)
    updatePerformanceBar(pastResults.length - 1)

prevResult = ->
  if currentIndex > 0
    updatePerformanceBar(currentIndex - 1)

nextResult = ->
  if currentIndex < pastResults.length - 1
    updatePerformanceBar(currentIndex + 1)

showRequestParams = ->
  $("#peek-request .params").show

hideRequestParams = ->
  $("#peek-request .params").hide

updatePerformanceBar = (index) ->
  currentIndex = index
  results = pastResults[index]
  for key of results.data
    for label of results.data[key]
      $("[data-defer-to=#{key}-#{label}]").text results.data[key][label]
  $("#peek-count").text( (index + 1) + " of " + pastResults.length )
  if results.request && results.request.params
    routeText = results.request.params.controller.split("/").reverse()[0] + "#" + results.request.params.action
    $("#peek-request .route").text( routeText )
    $("#peek-request .params").text( $.param(results.request.params) )
  $(document).trigger 'peek:render', [getRequestId(), results]

initializeTipsy = ->
  $('#peek .peek-tooltip, #peek .tooltip').each ->
    el = $(this)
    gravity = if el.hasClass('rightwards') || el.hasClass('leftwards')
      $.fn.tipsy.autoWE
    else
      $.fn.tipsy.autoNS

    el.tipsy
      gravity: gravity

toggleBar = (event) ->
  return if $(event.target).is ':input'

  if event.which == 96 && !event.metaKey
    wrapper = $('#peek')
    if wrapper.hasClass 'disabled'
      wrapper.removeClass 'disabled'
      document.cookie = "peek=true; path=/";
    else
      wrapper.addClass 'disabled'
      document.cookie = "peek=false; path=/";

fetchRequestResults = ->
  $.ajax '/peek/results',
    data:
      request_id: getRequestId()
    success: (data, textStatus, xhr) ->
      gotNewResults data
    error: (xhr, textStatus, error) ->
      # Swallow the error

$(document).on 'keypress', toggleBar

$(document).on 'peek:update', initializeTipsy
$(document).on 'peek:update', fetchRequestResults

# Fire the event for our own listeners.
$(document).on 'pjax:end', (event, xhr, options) ->
  if xhr?
    requestId = xhr.getResponseHeader 'X-Request-Id'

  if peekEnabled()
    $(this).trigger 'peek:update'

# Also listen to turbolinks page change event
$(document).on 'page:change', ->
  if peekEnabled()
    $(this).trigger 'peek:update'

$ ->
  if peekEnabled()
    $(this).trigger 'peek:update'

    $("#peek-prev").on 'click', prevResult
    $("#peek-next").on 'click', nextResult  
