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
      #TypeError: 'null' is not an object (evaluating 'element.getElementsByTagName("im:name").item(0).textContent')
      alert error

  ###*
  xmlからタイトル配列を取得
  @param  Titanium.XML.Document xml
  @return String[]
  ###
  getKeywordToXMLMobile = (xml)->
    arr = []
    
    title = ""
    doc = xml.documentElement
    items = doc.getElementsByTagName("entry")
    for i in [0...items.length]
      obj = {}
      element = items.item(i)
      obj.trackName = element.getElementsByTagNameNS("http://itunes.apple.com/rss","name").item(0).textContent 
      obj.artistName = element.getElementsByTagNameNS("http://itunes.apple.com/rss","artist").item(0).textContent 
      tmpurl = null
      for j in [0...element.getElementsByTagNameNS("http://itunes.apple.com/rss","image").length]
        tmpurl = element.getElementsByTagNameNS("http://itunes.apple.com/rss","image").item(j).textContent 
      obj.artworkUrl100 = tmpurl
      for j in [0...element.getElementsByTagName("link").length]
        type = element.getElementsByTagName("link").item(j).getAttribute("type") 
        obj.previewUrl = element.getElementsByTagName("link").item(j).getAttribute("href") if type is "audio/x-m4a"
      
      #リンク
      obj.trackViewUrl = element.getElementsByTagName("id").item(0).textContent
        
      arr.push obj
    arr


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
    limit = obj?.limit ? 200
    url = "https://itunes.apple.com/"+country.toLowerCase()+"/rss/topsongs/limit=#{limit}/explicit=true/xml"
    unless ENV_PRODUCTION then Ti.API.debug "url=#{url}"
    client_object = getClientObject errorcallback
    client_object.onload = ->
      if OS_MOBILEWEB then callback getKeywordToXMLMobile @responseXML
      else callback getKeywordToXML @responseXML

    client = Ti.Network.createHTTPClient client_object

    client.open "GET", url

    client.send()

  ###*
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  ###
  @getItunesDataPublicYQL:(callback,errorcallback,obj)->

      url = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D%22https%3A%2F%2Fitunes.apple.com%2Fjp%2Frss%2Ftopsongs%2Flimit%3D300%2Fxml%22&format=json&diagnostics=true&callback="
      unless ENV_PRODUCTION then Ti.API.debug "url=#{url}"
      client = Ti.Network.createHTTPClient(
        
        # function called when the response data is available
        onload: (e)->#getItunesData #(e) ->
          unless ENV_PRODUCTION then Ti.API.debug "getItunesData #{@responseText}"
          json = JSON.parse @responseText
          data = json.results

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

  ###*
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  ###
  @getItunesRssDataYql:(callback,errorcallback,obj)->
    country = obj?.country ? require("AppStoreClient/AppStoreClient").getTzOff()
    limit = obj?.limit ? 200
    url = "https://itunes.apple.com/"+country.toLowerCase()+"/rss/topsongs/limit=#{limit}/explicit=true/xml"
    
    mojiretu = 'select * from xml where url="'+url+'"'
    unless ENV_PRODUCTION then Ti.API.debug "url=#{url} moji=#{mojiretu} yql = #{Ti.Yahoo.yql}"
    Ti.Yahoo.yql mojiretu, (e) ->
      unless ENV_PRODUCTION then Ti.API.debug "じっこう"
      if e.success and e.data?
        arr = e.data?.feed?.entry ? []
        objs = for item in arr
          obj = {}
          obj.trackName = item.name
          obj.artistName = item.artist?.content ? ""
          tmpurl = null
          tmpsizemax = 0
          for image in item.image
            nowsize = image.height - 0
            if tmpsizemax < nowsize
              tmpsizemax = nowsize
              obj.artworkUrl100 = image.content
          for link in item.link
            obj.previewUrl = link.href if link.assetType is "preview"
          
          #購入リンク
          obj.trackViewUrl = item.id?.content
          obj
        callback objs
      else errorcallback e
      return 

  
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
