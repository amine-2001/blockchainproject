(function() {
    var supportedBrowsers = [
      "Chrome",
      "Firefox",
      "Safari",
      "Edge",
      "Opera"
    ];
  
    function loadFlutterApp() {
      var loader = document.createElement("script");
      loader.src = "main.dart.js";
      loader.defer = true;
      document.body.appendChild(loader);
    }
  
    if (supportedBrowsers.some(function(browser) {
      return navigator.userAgent.indexOf(browser) !== -1;
    })) {
      loadFlutterApp();
    } else {
      console.error("Unsupported browser.");
    }
  })();
  