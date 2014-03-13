# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.Message = {}

Message.toggle_form = (message_id) ->
  message_form = document.getElementById('message_form_'+message_id)
  toggle_button = document.getElementById('toggle_'+message_id)

  if message_form.style.display == 'none'
    message_form.style.display = 'block'
    toggle_button.style.display = 'none'
  else
    message_form.style.display = 'none'
    toggle_button.style.display = 'inline-block'

$ ->
  $("a[data-message-id]").click ->
    message_id =$(this).data("message-id")
    Message.toggle_form(message_id)
