'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "f393d3c16b631f36852323de8e583132",
"main.dart.js": "6bfb6ebda39ff36e40b078bc4106aab4",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "f0e1b75ee9b766dc9f7780eb88b82b15",
"assets/fonts/MaterialIcons-Regular.otf": "1e054782944039b97a74061f9389117f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/assets/images/phone_mockups.png": "42ac6a541274f930c6189af12d373b93",
"assets/assets/images/google_play_badge.png": "a543d8c2c0d1d744a1b6c6c5137c2093",
"assets/assets/images/app_store_badge.png": "e970e5d26d70c178b5aec7a245912a6c",
"assets/NOTICES": "a8672558fe31ab10dba2074c962ece4b",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "39cedbc273e8b51279467c6632c32a53",
"assets/AssetManifest.bin.json": "ea112aef280a2edd6953deb1009d4484",
"index.html": "ffd3adfe5376174005193021e3cab1dc",
"/": "ffd3adfe5376174005193021e3cab1dc",
"manifest.json": "8aa6ef9c4faa64b96b723d9c01dc3b9f",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.ico": "dc1effa72bd7174621c3e58e614d7b6d",
"icons/ms-icon-144x144.png": "76a8b2ea0cd2d250be7b26e640e73c81",
"icons/android-icon-72x72.png": "eec7f022f4c06498010d68da41f2ed41",
"icons/android-icon-36x36.png": "dbe2f4fe0382437bd11eeb7e12f9467d",
"icons/apple-icon-57x57.png": "5e1f483726a57b8f2e2c98a6887c3e55",
"icons/apple-icon-76x76.png": "fe0b49fa976e17d0b408d4a1348ee416",
"icons/apple-icon-180x180.png": "b58b813b0d7a7b206d15286c58882111",
"icons/favicon-16x16.png": "410c16a450ea8e6c8de3f13f82fdbd4e",
"icons/apple-icon-120x120.png": "13b260ace2f3b96b49d072e4f9f08d64",
"icons/apple-icon-144x144.png": "5d1cdbfff26c6fc8feaea136627ccab8",
"icons/apple-icon-114x114.png": "a1d9020c00d4b0a72af05f35dd735f14",
"icons/apple-icon-72x72.png": "eec7f022f4c06498010d68da41f2ed41",
"icons/apple-icon-precomposed.png": "8fcf5abfa5fa889ceae67dc386947491",
"icons/Icon-512.png": "d68be6b6afab3fcee897b37efc3a6ab9",
"icons/apple-icon.png": "8fcf5abfa5fa889ceae67dc386947491",
"icons/ms-icon-150x150.png": "7b5e93cbafc5cc12116f956d6528b6d7",
"icons/android-icon-96x96.png": "f05361da8aaf1472d1fccf47f02ef83b",
"icons/android-icon-192x192.png": "caa8a66116994986dc11f0274a7807d0",
"icons/favicon-32x32.png": "4bc537cf33ba5458b5774b9f94f543e1",
"icons/android-icon-48x48.png": "63ada98b159965cb663faa8349e9e78a",
"icons/apple-icon-60x60.png": "896f05c134db86bc37ce30c87021732b",
"icons/ms-icon-310x310.png": "0e5c8a3328dd2465f161496a4f91711e",
"icons/android-icon-144x144.png": "5d1cdbfff26c6fc8feaea136627ccab8",
"icons/apple-icon-152x152.png": "f3fee75004c96447f3325546f0b392ed",
"icons/ms-icon-70x70.png": "f85649bbb7699598655cd6906528f0dc",
"icons/favicon-96x96.png": "46a72313549bd0a1b4c95c697c817c81",
"favicon.png": "410c16a450ea8e6c8de3f13f82fdbd4e",
"version.json": "c9dd8a07983aaf892cb93655b9611ed7",
"flutter_bootstrap.js": "1e0545ebae3ed0344af3c58fe29b7309"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
