fs                 = require 'fs'
os                 = require 'os'
yml                = require 'js-yaml'
{EventEmitter}     = require 'events'
MessageFormat      = require 'messageformat'

require.extensions['.yml'] = (module, filename)->
  module.exports = yml.safeLoad fs.readFileSync filename

USER_CONFIG_PATH   = "#{process.env.HOME}/.wolves"

BASE = if fs.existsSync USER_CONFIG_PATH then USER_CONFIG_PATH else '../config'
CONFIG             = require BASE + '/config.yml'
CONFIG.IRC         = require BASE + '/irc.yml'

Wolves = {Village: {}}

# Monkey Patches
Number::plural = (singular, plural='')->
  (if @valueOf() is 1 then singular else plural).replace /%d/g, @valueOf()

utils =
  duration: (duration='1s', base=0) ->

    # You can add new units here
    units = s: 1, m: 60, h: 3600

    keys = ///#{Object.keys units}///
    format = "(\\d+)([#{keys}])"

    times = duration.match ///#{format}///gi
    times.forEach (time)->
      [value, unit] = time.match(///#{format}///)[1..]
      base += units[unit] * value

    base * 1000

  time: (format) ->
    [_, hours, _, mins, ampm] = format.match /(\d+)([\.\:](\d+))?(am|pm)/
    hours = 12 + + hours if ampm is 'pm'
    mins or= 0
    [+hours, +mins]

  wait: (time, fn, context)->
    setTimeout fn.bind(context), time

  repeat: (time, fn, context)->
    setInterval fn.bind(context), time

  cancel: (timer)->
    clearTimeout timer

  stop: (timer)->
    clearInterval timer

  translations: (locale)->
    messages = require "./locales/#{locale}/i18n.json"
    mf = new MessageFormat locale, @localePlurals[locale]
    (text, params={})->
      message = mf.compile messages[text]?.value or text
      message params

  # When you add a locale, you should add the plural version of it.

  localePlurals:
    en: (n)-> if n is 1 then 'one' else 'other'
    tr: (n)-> if n is 1 then 'one' else 'other'
