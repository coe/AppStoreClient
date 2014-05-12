###*
get itunes data 
###
String::replaceAll = (org, dest) ->
  @split(org).join dest
  
module.exports = class AppStoreClient 

  API = "http://itunes.apple.com/search?"
  ANDROID_URL = "http://play.google.com/store/search?q=tsuyoshi+hyuga"
  URL=API#"http://coecorsproxy.appspot.com/"

  getParameter=(str) ->
    dec = decodeURIComponent
    par = {} #new Array()
    itm = undefined
    return par  if typeof (str) is "undefined"
    str = str.split("?")[1]  if str.indexOf("?", 0) > -1
    str = str.split("&")
    i = 0
  
    while str.length > i
      itm = str[i].split("=")
      #Ti.App.Const.warn? "itm0 = #{itm[0]}"
      #Ti.App.Const.warn? "itm1 = #{itm[1]}"
      key = (if typeof (itm[1]) is "undefined" then true else dec(itm[1]))  unless itm[0] is ""
      #Ti.App.Const.warn? "key = #{key}"
      par[itm[0]] = key
      #Ti.App.Const.warn? par
      i++
    par
    
  setParameter=(par) ->
    enc = encodeURIComponent
    str = ""
    amp = ""
    return ""  unless par
    for i of par
      str = str + amp + i + "=" + enc(par[i])
      amp = "&"
    str

  constructor: ->
    # body...}

  COUNTRY = [
    "GB"
    "IT"
    "FI"
    "RU"
    "AE"
    "PK"
    "BD"
    "ID"
    "PH"
    "JP"
    "AU"
    "NC"
    "NZ"
    "TO"
    "TO"
    "US"
    "US"
    "US"
    "US"
    "US"
    "CL"
    "BR"
    "BR"
    "GL"
  ]
  ###*
  get timezone
  ###
  @getTzOff : ->
    if Ti.Locale.getCurrentCountry() isnt "" then return Ti.Locale.getCurrentCountry()
    date = new Date()
    COUNTRY[(date.getHours() - date.getUTCHours() + 24) % 24]
  
  ###*
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  ###
  @getItunesData:(callback,errorcallback,obj)->
      unless ENV_PRODUCTION then Ti.API.debug "obj=#{obj}"

      cur = require("AppStoreClient/AppStoreClient").getTzOff()
      IOS_URL = unless obj? then "http://itunes.apple.com/search?term=tsuyoshi+hyuga&country=#{cur}&media=software&entity=software"
      else
        obj.country ?= cur
        "http://itunes.apple.com/search?"+setParameter obj
      url = IOS_URL#"https://itunes.apple.com/search?term=tsuyoshi+hyuga&country=#{Ti.Locale.getCurrentCountry()}&media=software&entity=software"
      unless ENV_PRODUCTION then Ti.API.debug "url=#{url}"
      client = Ti.Network.createHTTPClient(
        
        # function called when the response data is available
        onload: (e)->#getItunesData #(e) ->
          unless ENV_PRODUCTION then Ti.API.debug "getItunesData"
          json = JSON.parse @responseText
          data = json.results
#           
          # #TODO データのうち、無料のものを抽出 underscoreで
          # data = _.filter data,(obj)->
            # obj.price is 0
          # #TODO データを、アップデート日付順にソート underscoreで
          # data = _.sortBy(data, (item) ->
            # Number(item.releaseDate)
          # )
          # #TODO 自分のアプリIDは除外 bundleId
          # data = _.filter data,(obj)->
            # obj.bundleId isnt Ti.App.id
          callback data

        onerror: errorcallback
        onreadystatechange :(e)->
          unless ENV_PRODUCTION then Ti.API.debug "onreadystatechange "
          
        onsendstream:(e)->
          unless ENV_PRODUCTION then Ti.API.debug "onsendstream "
        ondatastream:(e)->
          unless ENV_PRODUCTION then Ti.API.debug "ondatastream"
        timeout: 5000 # in milliseconds
      )
      
      client.open "GET", url

      client.send()
