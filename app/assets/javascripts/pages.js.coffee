# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@pages_menu = () ->
  console.log "pages layout"

@reset_ui = () ->
  $("#browser-menu-tab a.browser-subnav-item").removeClass("selected")