
/**
get itunes data
*/

var AppStoreClient, ENV_PRODUCTION;

ENV_PRODUCTION = false;

String.prototype.replaceAll = function(org, dest) {
  return this.split(org).join(dest);
};

module.exports = AppStoreClient = (function() {
  var ANDROID_URL, API, COUNTRY, URL, getClientObject, getKeywordToXML, getKeywordToXMLMobile, getParameter, setParameter;

  API = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?";

  ANDROID_URL = "http://play.google.com/store/search?q=tsuyoshi+hyuga";

  URL = API;

  /**
  xmlからタイトル配列を取得
  @param  Titanium.XML.Document xml
  @return String[]
  */

  getKeywordToXML = function(xml) {
    var arr, doc, element, i, items, j, obj, title, tmpurl, type, _ref, _ref2, _ref3;
    arr = [];
    title = "";
    try {
      doc = xml.documentElement;
      items = doc.getElementsByTagName("entry");
      for (i = 0, _ref = items.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        obj = {};
        element = items.item(i);
        obj.trackName = element.getElementsByTagName("im:name").item(0).textContent;
        obj.artistName = element.getElementsByTagName("im:artist").item(0).textContent;
        tmpurl = null;
        for (j = 0, _ref2 = element.getElementsByTagName("im:image").length; 0 <= _ref2 ? j < _ref2 : j > _ref2; 0 <= _ref2 ? j++ : j--) {
          tmpurl = element.getElementsByTagName("im:image").item(j).textContent;
        }
        obj.artworkUrl100 = tmpurl;
        for (j = 0, _ref3 = element.getElementsByTagName("link").length; 0 <= _ref3 ? j < _ref3 : j > _ref3; 0 <= _ref3 ? j++ : j--) {
          type = element.getElementsByTagName("link").item(j).getAttribute("type");
          if (type === "audio/x-m4a") {
            obj.previewUrl = element.getElementsByTagName("link").item(j).getAttribute("href");
          }
        }
        obj.trackViewUrl = element.getElementsByTagName("id").item(0).textContent;
        arr.push(obj);
      }
      return arr;
    } catch (error) {
      return alert(error);
    }
  };

  /**
  xmlからタイトル配列を取得
  @param  Titanium.XML.Document xml
  @return String[]
  */

  getKeywordToXMLMobile = function(xml) {
    var arr, doc, element, i, items, j, obj, title, tmpurl, type, _ref, _ref2, _ref3;
    arr = [];
    title = "";
    doc = xml.documentElement;
    items = doc.getElementsByTagName("entry");
    for (i = 0, _ref = items.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      obj = {};
      element = items.item(i);
      obj.trackName = element.getElementsByTagNameNS("http://itunes.apple.com/rss", "name").item(0).textContent;
      obj.artistName = element.getElementsByTagNameNS("http://itunes.apple.com/rss", "artist").item(0).textContent;
      tmpurl = null;
      for (j = 0, _ref2 = element.getElementsByTagNameNS("http://itunes.apple.com/rss", "image").length; 0 <= _ref2 ? j < _ref2 : j > _ref2; 0 <= _ref2 ? j++ : j--) {
        tmpurl = element.getElementsByTagNameNS("http://itunes.apple.com/rss", "image").item(j).textContent;
      }
      obj.artworkUrl100 = tmpurl;
      for (j = 0, _ref3 = element.getElementsByTagName("link").length; 0 <= _ref3 ? j < _ref3 : j > _ref3; 0 <= _ref3 ? j++ : j--) {
        type = element.getElementsByTagName("link").item(j).getAttribute("type");
        if (type === "audio/x-m4a") {
          obj.previewUrl = element.getElementsByTagName("link").item(j).getAttribute("href");
        }
      }
      obj.trackViewUrl = element.getElementsByTagName("id").item(0).textContent;
      arr.push(obj);
    }
    return arr;
  };

  getParameter = function(str) {
    var dec, i, itm, key, par;
    dec = decodeURIComponent;
    par = {};
    itm = void 0;
    if (typeof str === "undefined") return par;
    if (str.indexOf("?", 0) > -1) str = str.split("?")[1];
    str = str.split("&");
    i = 0;
    while (str.length > i) {
      itm = str[i].split("=");
      if (itm[0] !== "") {
        key = (typeof itm[1] === "undefined" ? true : dec(itm[1]));
      }
      par[itm[0]] = key;
      i++;
    }
    return par;
  };

  setParameter = function(par) {
    var amp, enc, i, str;
    enc = encodeURIComponent;
    str = "";
    amp = "";
    if (!par) return "";
    for (i in par) {
      str = str + amp + i + "=" + enc(par[i]);
      amp = "&";
    }
    return str;
  };

  function AppStoreClient() {}

  COUNTRY = ["GB", "IT", "FI", "RU", "AE", "PK", "BD", "ID", "PH", "JP", "AU", "NC", "NZ", "TO", "TO", "US", "US", "US", "US", "US", "CL", "BR", "BR", "GL"];

  /**
  get timezone
  */

  AppStoreClient.getTzOff = function() {
    var date;
    if (Ti.Locale.getCurrentCountry() !== "") return Ti.Locale.getCurrentCountry();
    date = new Date();
    return COUNTRY[(date.getHours() - date.getUTCHours() + 24) % 24];
  };

  getClientObject = function(errorcallback) {
    return {
      onerror: errorcallback,
      onreadystatechange: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("onreadystatechange ");
      },
      onsendstream: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("onsendstream ");
      },
      ondatastream: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("ondatastream");
      },
      timeout: 5000
    };
  };

  /**
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  */

  AppStoreClient.getItunesRssData = function(callback, errorcallback, obj) {
    var client, client_object, country, limit, url, _ref, _ref2;
    country = (_ref = obj != null ? obj.country : void 0) != null ? _ref : require("AAppStoreClient").getTzOff();
    limit = (_ref2 = obj != null ? obj.limit : void 0) != null ? _ref2 : 200;
    url = "https://itunes.apple.com/" + country.toLowerCase() + ("/rss/topsongs/limit=" + limit + "/explicit=true/xml");
    if (!ENV_PRODUCTION) Ti.API.debug("url=" + url);
    client_object = getClientObject(errorcallback);
    client_object.onload = function() {
      if (OS_MOBILEWEB) {
        return callback(getKeywordToXMLMobile(this.responseXML));
      } else {
        return callback(getKeywordToXML(this.responseXML));
      }
    };
    client = Ti.Network.createHTTPClient(client_object);
    client.open("GET", url);
    return client.send();
  };

  /**
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  */

  AppStoreClient.getItunesDataPublicYQL = function(callback, errorcallback, obj) {
    var client, url;
    url = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20xml%20where%20url%3D%22https%3A%2F%2Fitunes.apple.com%2Fjp%2Frss%2Ftopsongs%2Flimit%3D300%2Fxml%22&format=json&diagnostics=true&callback=";
    if (!ENV_PRODUCTION) Ti.API.debug("url=" + url);
    client = Ti.Network.createHTTPClient({
      onload: function(e) {
        var data, json;
        if (!ENV_PRODUCTION) Ti.API.debug("getItunesData " + this.responseText);
        json = JSON.parse(this.responseText);
        data = json.results;
        return callback(data, json.resultCount);
      },
      onerror: errorcallback,
      onreadystatechange: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("onreadystatechange ");
      },
      onsendstream: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("onsendstream ");
      },
      ondatastream: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("ondatastream");
      },
      timeout: 5000
    });
    client.open("GET", url);
    return client.send();
  };

  /**
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  */

  AppStoreClient.getItunesRssDataYql = function(callback, errorcallback, obj) {
    var country, limit, mojiretu, url, _ref, _ref2;
    country = (_ref = obj != null ? obj.country : void 0) != null ? _ref : require("AppStoreClient").getTzOff();
    limit = (_ref2 = obj != null ? obj.limit : void 0) != null ? _ref2 : 200;
    url = "https://itunes.apple.com/" + country.toLowerCase() + ("/rss/topsongs/limit=" + limit + "/explicit=true/xml");
    mojiretu = 'select * from xml where url="' + url + '"';
    if (!ENV_PRODUCTION) {
      Ti.API.debug("url=" + url + " moji=" + mojiretu + " yql = " + Ti.Yahoo.yql);
    }
    return Ti.Yahoo.yql(mojiretu, function(e) {
      var arr, image, item, link, nowsize, objs, tmpsizemax, tmpurl, _ref3, _ref4, _ref5;
      if (!ENV_PRODUCTION) Ti.API.debug("じっこう");
      if (e.success && (e.data != null)) {
        arr = (_ref3 = (_ref4 = e.data) != null ? (_ref5 = _ref4.feed) != null ? _ref5.entry : void 0 : void 0) != null ? _ref3 : [];
        objs = (function() {
          var _i, _j, _k, _len, _len2, _len3, _ref10, _ref6, _ref7, _ref8, _ref9, _results;
          _results = [];
          for (_i = 0, _len = arr.length; _i < _len; _i++) {
            item = arr[_i];
            obj = {};
            obj.trackName = item.name;
            obj.artistName = (_ref6 = (_ref7 = item.artist) != null ? _ref7.content : void 0) != null ? _ref6 : "";
            tmpurl = null;
            tmpsizemax = 0;
            _ref8 = item.image;
            for (_j = 0, _len2 = _ref8.length; _j < _len2; _j++) {
              image = _ref8[_j];
              nowsize = image.height - 0;
              if (tmpsizemax < nowsize) {
                tmpsizemax = nowsize;
                obj.artworkUrl100 = image.content;
              }
            }
            _ref9 = item.link;
            for (_k = 0, _len3 = _ref9.length; _k < _len3; _k++) {
              link = _ref9[_k];
              if (link.assetType === "preview") obj.previewUrl = link.href;
            }
            obj.trackViewUrl = (_ref10 = item.id) != null ? _ref10.content : void 0;
            _results.push(obj);
          }
          return _results;
        })();
        callback(objs);
      } else {
        errorcallback(e);
      }
    });
  };

  /**
  get data
  @param {function} callback
  @param {function} errorcallback
  @param {object} callback
  */

  AppStoreClient.getItunesData = function(callback, errorcallback, obj) {
    var IOS_URL, client, cur, url, _ref;
    if (!ENV_PRODUCTION) Ti.API.debug("obj=" + obj);
    cur = require("AppStoreClient").getTzOff();
    IOS_URL = obj == null ? API + ("term=tsuyoshi+hyuga&country=" + cur + "&media=software&entity=software") : ((_ref = obj.country) != null ? _ref : obj.country = cur, API + setParameter(obj));
    url = IOS_URL;
    if (!ENV_PRODUCTION) Ti.API.debug("url=" + url);
    client = Ti.Network.createHTTPClient({
      onload: function(e) {
        var data, json;
        if (!ENV_PRODUCTION) Ti.API.debug("getItunesData");
        json = JSON.parse(this.responseText);
        data = json.results;
        return callback(data, json.resultCount);
      },
      onerror: errorcallback,
      onreadystatechange: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("onreadystatechange ");
      },
      onsendstream: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("onsendstream ");
      },
      ondatastream: function(e) {
        if (!ENV_PRODUCTION) return Ti.API.debug("ondatastream");
      },
      timeout: 5000
    });
    client.open("GET", url);
    return client.send();
  };

  /**
  checkAndroid
  @param {function(object)} callback successで判定
  */

  AppStoreClient.checkAndroid = function(bundleId, callback) {
    var android_url, client, obj, url;
    obj = {};
    obj.success = false;
    android_url = "https://play.google.com/store/apps/details?id=";
    url = android_url + bundleId;
    client = Ti.Network.createHTTPClient({
      onload: function(e) {
        if (!ENV_PRODUCTION) Ti.API.debug("onload " + url);
        obj.success = true;
        obj.client = this;
        return callback(obj);
      },
      onerror: function(e) {
        if (!ENV_PRODUCTION) Ti.API.debug("onerror " + url);
        obj.success = false;
        obj.client = this;
        return callback(obj);
      },
      onreadystatechange: function(e) {
        if (!ENV_PRODUCTION) {
          return Ti.API.debug("onreadystatechange " + (e != null ? e.status : void 0));
        }
      },
      onsendstream: function(e) {
        if (!ENV_PRODUCTION) {
          return Ti.API.debug("onsendstream " + (e != null ? e.status : void 0));
        }
      },
      ondatastream: function(e) {
        if (!ENV_PRODUCTION) {
          return Ti.API.debug("ondatastream " + (e != null ? e.status : void 0));
        }
      },
      timeout: 5000
    });
    client.open("GET", url);
    return client.send();
  };

  return AppStoreClient;

})();
