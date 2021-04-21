
// Create a request variable and assign a new XMLHttpRequest object to it.
var request = new XMLHttpRequest()
request.withCredetialts = true;
// Open a new connection, using the GET request on the URL endpoint
request.open('GET', 'https://cors-anywhere.herokuapp.com/https://kf.kobotoolbox.org/api/v2/assets/a4TGhiJNRfASUqYXknMQnk/data/?format=json', user = 'caro_bro', password = 'VP1_2021')
request.setRequestHeader('Access-Control-Allow-Origin', 'https://kf.kobotoolbox.org/api/v2/assets/a4TGhiJNRfASUqYXknMQnk/data/?format=json');

request.onload = function() {
    // Begin accessing JSON data here
    var data;
    data = JSON.parse(this.response),
        gotData(data)
    return data;
};


request.getResponseHeader('Content-Type')

// Send request
request.send()
console.log(request)

var rebbau_data;
var lat = 0;
var lon = 0;

function gotData(data) {
    rebbau_data = data;
    results = rebbau_data["results"];
    console.log(results)

    for (var i in results) {
        lat = results[i]["_geolocation"][0]
        lon = results[i]["_geolocation"][1]
        typ = results[i]["Wein_Typ"]
        datum = results[i]["Datum"]
        krank = results[i]["group_dx9qs74/Krank_Typ"]
		//console.log(lat,lon)
        L.marker([lat, lon]).addTo(map)
            .bindPopup("Weintyp: " + typ + "<br>" + "Datum: " + datum + "<br>" + "Krankheit: " + krank);
        //.openPopup();
    }

}
