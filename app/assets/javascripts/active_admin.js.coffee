
#= require active_admin/base

#= require jquery-ui
#= require jquery_ujs
#= require jquery.scrollto/jquery.scrollTo
#= require jquery-contextmenu/dist/jquery.contextMenu
#= require js-cookie/src/js.cookie
#= require best_in_place
#= require best_in_place.purr
#= require chosen-jquery
#= require moment/moment
#= require fullcalendar/dist/fullcalendar
#= require_tree ./fullcalendar_engine
#= require_tree ./active_admin
#= require jquery-ui-touch-punch/jquery.ui.touch-punch.min
#= require jquery.ui.touch/jquery.ui.touch
#= require spin.js/spin

#  require jquery-ui/position
# require jqueryui-timepicker-addon/dist/jquery-ui-timepicker-addon
# require jqueryui-timepicker-addon/dist/i18n/jquery-ui-timepicker-fr
# require chosen # not yet..

$(document).ready ->
  jQuery(".best_in_place").best_in_place();
