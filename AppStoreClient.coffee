###*
get itunes data 
###
String::replaceAll = (org, dest) ->
  @split(org).join dest
  
module.exports = class AppStoreClient 

  # API = "http://itunes.apple.com/search?"
  API = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?"
  ANDROID_URL = "http://play.google.com/store/search?q=tsuyoshi+hyuga"
  URL=API#"http://coecorsproxy.appspot.com/"

  ###*
  xmlからタイトル配列を取得
  @param  Titanium.XML.Document xml
  @return String[]
  ###
  getKeywordToXML = (xml)->
    arr = []
    
    title = ""
    try
      doc = xml.documentElement
      items = doc.getElementsByTagName("entry")
      for i in [0...items.length]
        obj = {}
        element = items.item(i)
        obj.trackName = element.getElementsByTagName("im:name").item(0).textContent 
        obj.artistName = element.getElementsByTagName("im:artist").item(0).textContent 
        tmpurl = null
        for j in [0...element.getElementsByTagName("im:image").length]
          tmpurl = element.getElementsByTagName("im:image").item(j).textContent 
        obj.artworkUrl100 = tmpurl
        for j in [0...element.getElementsByTagName("link").length]
          type = element.getElementsByTagName("link").item(j).getAttribute("type") 
          obj.previewUrl = element.getElementsByTagName("link").item(j).getAttribute("href") if type is "audio/x-m4a"
        
        #リンク
        obj.trackViewUrl = element.getElementsByTagName("id").item(0).textContent
          
        arr.push obj
      arr
    catch error
      null

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
  
  getClientObject = (errorcallback)->
        onerror: errorcallback
        onreadystatechange :(e)->
          unless ENV_PRODUCTION then Ti.API.debug "onreadystatechange "
          
        onsendstream:(e)->
          unless ENV_PRODUCTION then Ti.API.debug "onsendstream "
        ondatastream:(e)->
          unless ENV_PRODUCTION then Ti.API.debug "ondatastream"
        timeout: 5000 # in milliseconds
  
  ###*
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  ###
  @getItunesRssData:(callback,errorcallback,obj)->
    country = obj?.country ? require("AppStoreClient/AppStoreClient").getTzOff()
    url = "https://itunes.apple.com/"+country.toLowerCase()+"/rss/topsongs/limit=300/explicit=true/xml"
    unless ENV_PRODUCTION then Ti.API.debug "url=#{url}"
    client_object = getClientObject errorcallback
    client_object.onload = ->
      callback getKeywordToXML @responseXML

    client = Ti.Network.createHTTPClient client_object

    client.open "GET", url

    client.send()
  
  ###*
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  ###
  @getItunesData:(callback,errorcallback,obj)->
      unless ENV_PRODUCTION then Ti.API.debug "obj=#{obj}"

      cur = require("AppStoreClient/AppStoreClient").getTzOff()
      IOS_URL = unless obj? then API+"term=tsuyoshi+hyuga&country=#{cur}&media=software&entity=software"
      else
        obj.country ?= cur
        API+setParameter obj
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
          callback data,json.resultCount

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
