
'use strict';

// Create map and attach id to element with id "mapid"
var map = L.map('mapid').setView([46.947922, 7.444608], 8);


var basemap = L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
	maxZoom: 18,
	attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, ' +
		'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
	id: 'mapbox/outdoors-v11',
	tileSize: 512,
	zoomOffset: -1
}).addTo(map)


var googleSat = L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',{
    maxZoom: 20,
    subdomains:['mt0','mt1','mt2','mt3'],
	layers: 'OSM-Overlay-WMS'
});
var mapLayer = L.tileLayer.swiss();

var satelliteLayer = L.tileLayer.swiss({
  layer: 'ch.swisstopo.swissimage',
  maxNativeZoom: 28
});

var topography = L.tileLayer.wms('http://ows.mundialis.de/services/service?', {
    layers: 'TOPO-WMS,OSM-Overlay-WMS'
});

var osmlayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
			attribution: 'Map data: &copy; <a href="https://openstreetmap.org">OpenStreetMap</a> contributors',
		})
		
// Add Swiss layer with default options
//var mapLayer = L.tileLayer.swiss().addTo(map);

// Center the map on Switzerland
map.fitSwitzerland();
 		
		
var baseMaps = {
  'Basemap': basemap,
  'Satellite Layer': googleSat,
  'Topography': topography,
  'OSM': osmlayer
};
 
	var popup = L.popup();

	function onMapClick(e) {
		popup
			.setLatLng(e.latlng)
			.setContent("You clicked the map at " + e.latlng.toString())
			.openOn(map);
	}

	map.on('click', onMapClick);
  
 L.control.layers(baseMaps).addTo(map);

