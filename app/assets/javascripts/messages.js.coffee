# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.Message = {}

Message.toggle_form = (message_id) ->
  message_form = document.getElementById('message_form_'+message_id)
  toggle_button = document.getElementById('toggle_form_'+message_id)
  all_forms = document.getElementsByClassName('message_form')
  all_buttons = document.getElementsByClassName('toggle_form')

  if message_form.style.display == 'none'

    for m_form in all_forms
      m_form.style.display = 'none'
    
    for m_button in all_buttons
      m_button.style.display = 'inline-block'

    message_form.style.display = 'block'
    toggle_button.style.display = 'none'

  else
    message_form.style.display = 'none'
    toggle_button.style.display = 'inline-block'


Message.toggle_answers = (message_id) ->
  message_answers = document.getElementById('message_answers_'+message_id)
  toggle_button = document.getElementById('toggle_answers_'+message_id)
  all_answers = document.getElementsByClassName('message_answers')
  all_buttons = document.getElementsByClassName('toggle_answers')

  if message_answers.style.display == 'none'

    for m_answers in all_answers
      m_answers.style.display = 'none'

    for m_button in all_buttons
      m_button.textContent = 'View answers' unless m_button.textContent == 'No answers'

    message_answers.style.display = 'block'
    toggle_button.textContent = 'Hide answers'

  else
    message_answers.style.display = 'none'
    toggle_button.textContent = 'View answers'


$ ->
  $("button.toggle_form[data-message-id]").click ->
    message_id = $(this).data("message-id")
    Message.toggle_form(message_id)

$ ->
  $("button.toggle_answers[data-message-id]").click ->
    message_id = $(this).data("message-id")
    Message.toggle_answers(message_id)




