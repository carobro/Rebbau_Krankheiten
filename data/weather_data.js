


// --------------------
//Niederschlagsdaten
// ---------------------
var request = new XMLHttpRequest()
request.withCredetialts = true;
// Open a new connection, using the GET request on the URL endpoint
request.open('GET', 'https://data.geo.admin.ch/ch.meteoschweiz.messwerte-niederschlag-10min/ch.meteoschweiz.messwerte-niederschlag-10min_de.json')

var test;
var data_arr = new Array;
request.onload = function() {
    // Begin accessing JSON data here
    var data_nied = " ";
    data_nied = JSON.parse(this.response)
	saveData(data_nied)
        data_arr.push(data_nied)
		return data_nied;
};
request.getResponseHeader('Content-Type')
// Send request
request.send()


var data_new = {};
function saveData(data_nied){
		data_new = data_nied;
		console.log(data_new)
		gotData3(data_new);
		return data_new;
}

var rainLayer = new L.LayerGroup();
function gotData3(data) {
	console.log(data)
	weather_data = data;
    results = weather_data["features"];
    console.log(results)
	for (var i in results) {
        geom = results[i]["geometry"]["coordinates"]
        lat = geom[0] - 2000000
		lon = geom[1] - 1000000
		lat_conv = CHtoWGSlat(lat,lon)
		lon_conv = CHtoWGSlng(lat,lon)
		prop = results[i]["properties"]
		name = prop["station_name"]
		time = prop["reference_ts"]
		value = prop["value"]
		unit = prop["unit"]
		

		
        L.marker([lat_conv,lon_conv],{icon: redIcon}).addTo(rainLayer)
            .bindPopup("Station: " + name + "<br>" + "Datum: " + time + "<br>" + "Niederschlag: " + value + " " + unit);
        //.openPopup();
    }
}


// ___________________________________________________________________
var greenIcon = L.icon({
    iconUrl: 'weather-station-wind.png',
	iconSize: [20, 20], // size of the icon
	})
	
var redIcon = L.icon({
    iconUrl: 'weather-station-wind_red.png',
	iconSize: [20, 20], // size of the icon
	})
	
	// -------------------
// Lufttemperatur Data
// --------------------
// Create a request variable and assign a new XMLHttpRequest object to it.
var request = new XMLHttpRequest()
request.withCredetialts = true;
// Open a new connection, using the GET request on the URL endpoint
request.open('GET', 'https://data.geo.admin.ch/ch.meteoschweiz.messwerte-lufttemperatur-10min/ch.meteoschweiz.messwerte-lufttemperatur-10min_de.json')

request.onload = function() {
    // Begin accessing JSON data here
    var data = 0
    data = JSON.parse(this.response),
        gotData2(data)
    return data;
};
request.getResponseHeader('Content-Type')
// Send request
request.send()
console.log(request)

var weather_data;
var lat = 0;
var lon = 0;
var tempData = new L.LayerGroup();

function gotData2(data) {
    weather_data = data;
    results = weather_data["features"];
    console.log(results)
	for (var i in results) {
        geom = results[i]["geometry"]["coordinates"]
        lat = geom[0] - 2000000
		lon = geom[1] - 1000000
		lat_conv = CHtoWGSlat(lat,lon)
		lon_conv = CHtoWGSlng(lat,lon)
		prop = results[i]["properties"]
		name = prop["station_name"]
		time = prop["reference_ts"]
		value = prop["value"]
		unit = prop["unit"]
		
        L.marker([lat_conv,lon_conv],{icon: greenIcon}).addTo(tempData)
            .bindPopup("Station: " + name + "<br>" + "Datum: " + time + "<br>" + "Temperatur: " + value + " " + unit);
        //.openPopup();
    }
}


var baseMaps = {
};
var overlayMaps = {
	'Messstationen Niederschlag (aktuell)': rainLayer,
	'Messstationen Temperatur (aktuell)': tempData
};


L.control.layers(baseMaps, overlayMaps).addTo(map);


//Quelle: https://github.com/ValentinMinder/Swisstopo-WGS84-LV03/blob/master/scripts/js/wgs84_ch1903.js
// Convert CH y/x to WGS lat
	function CHtoWGSlat(y, x) {
		// Converts military to civil and to unit = 1000km
		// Auxiliary values (% Bern)
		var y_aux = (y - 600000)/1000000;
		var x_aux = (x - 200000)/1000000;

		// Process lat
		var lat = 16.9023892 +
			3.238272 * x_aux -
			0.270978 * Math.pow(y_aux, 2) -
			0.002528 * Math.pow(x_aux, 2) -
			0.0447	 * Math.pow(y_aux, 2) * x_aux -
			0.0140	 * Math.pow(x_aux, 3);

		// Unit 10000" to 1 " and converts seconds to degrees (dec)
		lat = lat * 100 / 36;

		return lat;
	}

	// Convert CH y/x to WGS lng
	function CHtoWGSlng(y, x) {
		// Converts military to civil and	to unit = 1000km
		// Auxiliary values (% Bern)
		var y_aux = (y - 600000)/1000000;
		var x_aux = (x - 200000)/1000000;

		// Process lng
		var lng = 2.6779094 +
			4.728982 * y_aux +
			0.791484 * y_aux * x_aux +
			0.1306	 * y_aux * Math.pow(x_aux, 2) -
			0.0436	 * Math.pow(y_aux, 3);

		// Unit 10000" to 1 " and converts seconds to degrees (dec)
		lng = lng * 100 / 36;

		return lng;
	}
