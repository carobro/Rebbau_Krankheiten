# Visualisierung der SenseBox Daten mit d3.js
In der HTML-Datei befindet sich meine Visulaisierung mit folgenden Eigenschaften:
1. Die Visualisierung soll mindestens zwei svg beinhalten, die nebeneinander stehen
   - Ein SVG-Element, das eine Punktedichtekarte zeigt
   - Ein SVG-Element, das die Entwicklung eines Phänomens zeigt
2. Daten sollen entweder als json oder als csv von Github gelesen werden
3. Basis für die Punktdichtekarte soll eine TopoJson Datei sein
   - Shapefile - Stadtteile von Münster 
4. Das Liniendiagramm soll min. 10 Werten und den Zeitpunkt der Messung enhalten

## Aufgabe 2.
- Zwei Pros der neuen Visualisierung im Vergleich zu der Mapbox Vis.
- Zwei Contras der neuen Visualisierung im Vergleich zu der Mapbox Vis.

| Pro                               | Contra                                 | 
|-----------------------------------|----------------------------------------|
| 1. Animiert                       | 1. nicht unbedingt benutzerfreundlicher|
| 2. Sehr frei in der Gestaltung    | 2. zeitaufwendiger                     |

## Probleme:

- Ich habe es nicht hinbekommen die Messwerte auf der y-Achse dazustellen.
Deshalb ist dort immer nur eine gerade Linie zu sehen.