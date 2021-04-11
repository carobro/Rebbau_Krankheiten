
// Create a request variable and assign a new XMLHttpRequest object to it.
var request = new XMLHttpRequest()

// Open a new connection, using the GET request on the URL endpoint
request.open('GET', 'https://kf.kobotoolbox.org/api/v2/assets/a4TGhiJNRfASUqYXknMQnk/data/?format=json', username='caro_bro', password='VP1_2021')


request.onload = function() {
  // Begin accessing JSON data here
  var data;
  data = JSON.parse(this.response),
  gotData(data)  
  return data;
};
// Send request
request.send()


var rebbau_data;
var lat = 0;
var lon = 0;

function gotData(data){
	rebbau_data = data;
	results = rebbau_data["results"];
	console.log(results)
	
	for(var i in results){
		console.log(results[i])
		lat=results[i]["_geolocation"][0]
		lon=results[i]["_geolocation"][1]
		typ=results[i]["Wein_Typ"]
		datum=results[i]["Datum"]
		krank=results[i]["group_dx9qs74/Krank_Typ"]
			L.marker([lat, lon]).addTo(map)
			.bindPopup("Weintyp: "+typ +"<br>" +"Datum: " +datum + "<br>" + "Krankheit: "+krank);
			//.openPopup();
	}
	
}

  
