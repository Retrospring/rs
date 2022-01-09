import 'core-js/stable'
import 'regenerator-runtime/runtime'

import '../legacy/jquery'
import {} from 'jquery-ujs'
import 'popper.js'
import 'bootstrap'
import 'particleground/jquery.particleground.min'
import 'jquery.growl'
import 'sweetalert'
import Cookies from 'js-cookie'

require('nprogress/nprogress.css')
require('jquery.growl/stylesheets/jquery.growl.css')

# this file is generated by Rails
import I18n from '../legacy/i18n'
import '../legacy/memes'
import '../legacy/notifications'
import '../legacy/pagination'
import '../legacy/locale-box'
import '../legacy/util'

window.translate = (scope, options) ->
  # for some reason I18n errors when calling it by assign proxy, so we got to wrap it
  I18n.translate(scope, options)

window.showNotification = (text, success=true) ->
  args =
    title: translate((if success then 'frontend.success.title' else 'frontend.error.title'))
    message: text
  if success
    $.growl.notice args
  else
    $.growl.error args

I18n.defaultLocale = 'en';
I18n.locale = Cookies.get('hl') || 'en';

$(document).on "click", "button#create-account", ->
  Turbolinks.visit "/sign_up"

_ready = ->
  if document.getElementById('particles')?
    jumbo         = $ '.j2-jumbo'
    bodyColorOrig = jumbo.css 'background-color'
    bodyColor     = doppler 0.25, bodyColorOrig
    console.log bodyColor, bodyColorOrig
    particleground document.getElementById('particles'),
      dotColor: bodyColor
      lineColor: bodyColor
      density: 23000

  $(".announcement").each ->
    aId = $(this)[0].dataset.announcementId
    unless (window.localStorage.getItem("announcement#{aId}"))
      $(this).toggleClass("d-none")

  $(document).on "click", ".announcement button.close", (evt) ->
    announcement = event.target.closest(".announcement")
    aId = announcement.dataset.announcementId
    window.localStorage.setItem("announcement#{aId}", true)


$(document).ready _ready
$(document).on 'turbolinks:load', _ready

$(document).on 'turbolinks:render', ->
  $('.dropdown-toggle').dropdown()
  $('[data-toggle="tooltip"]').tooltip()