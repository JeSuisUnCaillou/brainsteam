# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


window.Threadhead = {}


Threadhead.scrollTo = (treenode_id) ->
  ele = $( "div#treenode_"+treenode_id )
  if ele != null
    $(window).scrollTop(ele.offset().top - 50).scrollLeft(ele.offset().left - 10);


$ ->
  $("button.scroll_to[data-treenode-id]").click ->
    treenode_id = $(this).data("treenode-id")
    Threadhead.scrollTo(treenode_id)


#window.onload( window.scrollTo(0);)
