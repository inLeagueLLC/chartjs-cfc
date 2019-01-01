# chartjs-cfc
CFC wrappers for ChartJS - easily draw bar charts, pie charts, line graphs, and scatter plots

**chartjs-cfc** makes it easier to use [ChartJS](https://github.com/chartjs/Chart.js) in your ColdFusion/Lucee projects. It supports bar graphs, horizontal bar graphs, line graphs, pie charts, and scatter plots and a limited set of ChartJS display options. It uses [patternomaly](https://github.com/ashiguruma/patternomaly) to automagically generate textures as well as colors for your charts.

## How to use it
Install ChartJS and patternomaly. Get them from npm or include from a CDN:
```
  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/patternomaly@1.3.2/dist/patternomaly.min.js"></script>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.3/Chart.bundle.min.js"></script>
```
Init a bar chart:
```
  <cfset myData = [
        [12,10,14,15,10],
        [20,9,23,16,18],
        [3,7,4,5,6]
  ]>
  <cfset dataLabels = [ "January","February","March","April","May" ]>
  <cfset datasetNames = [ "Boys","Girls","Adults" ]>
  <cfset myBarChart = new chartjs-cfc.BasicChart( data=myData, dataLabels=dataLabels, datasetNames=datasetNames )>
```
Output a `<div>` element containing the chart `<canvas>` and the `<script>` to draw it:
```
  #myBarChart.draw( title="Attendance by month for Boys, Girls, and Adults", width=75 )#
```
The `<div>` is relatively positioned and scales against its parent element.
`init()` and `draw()` accept a variety of arguments to customize chart type and appearance. See [examples](examples.cfm)

### Future improvements?
+ Add support for time scaling
+ Show point labels on scatter plots and provide more display options
+ Automatically add line dashing to multi-dataset line graphs
+ Automatically calculate range of axes
+ Generate aesthetically pleasing color palettes rather than picking from a list
