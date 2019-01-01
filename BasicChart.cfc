component accessors="true" {
  // encapsulates chart.js library to draw a responsive bar, scatter, or line chart

  property name="type" type="string"; // line,bar,horizontalBar,scatter
  property name="curveFit" type="string"; // choose cubic or linear curve
  property name="chartID" type="string"; // id of <canvas> element
  property name="data" type="array"; // 2d array [ [] ] of simple datasets or {x,y} values
  property name="colors" type="array"; // English or hexadecimal
  property name="dataLabels" type="array"; // has length of longest dataset
  property name="datasetNames" type="array"; // required for multi-dataset chart
  property name="dataLength" type="numeric"; // longest dataset

  public function init(
    required array data,
    required array dataLabels, // eg ["Jan","Feb","March",..]
    array datasetNames=[], // required for legend
    string type="bar", // bar, horizontalBar, line, scatter
    string curveFit="cubic", // linear,cubic
    string chartID="",
    array colors=["black"]
  ) {

    if ( !ListContains( "line,bar,horizontalBar,scatter", arguments.type ) ) throw(type="InvalidChartType",message="Valid types are line, bar, horizontalBar, and scatter.");

    // cast a simple dataset to array of arrays
    if (!IsArray(arguments.data[1])) arguments.data = [arguments.data];
    if ( (ArrayLen(arguments.data) GT 1) AND (ArrayLen(arguments.data) NEQ ArrayLen(arguments.datasetNames)) ) throw(type="MissingDatasetName",message="Multi-dataset charts need to receive a name for each dataset.");

    for (var arg in arguments) variables[arg] = arguments[arg];
    if (variables.chartID EQ "") variables.chartID = "chartJs_"&CreateUUID();

    variables.dataLength=0;
    for (var dataset in variables.data) {
      if (ArrayLen(dataset) GT variables.dataLength) variables.dataLength = ArrayLen(dataset);
    }

    if ( (ArrayLen(variables.data) GT 1) AND (ArrayLen(variables.colors) NEQ 1) AND (ArrayLen(variables.data) GT ArrayLen(arguments.colors)) ) throw(type="InvalidColorsArray",message="Number of colors must match data size.");
    if ( variables.dataLength GT ArrayLen(variables.dataLabels) ) throw(type="MissingLabels",message="A data point is missing a label.");

    if (ArrayLen(variables.data) GT ArrayLen(variables.colors)) {
      var c = variables.colors[1];
      for (var i=1;i<ArrayLen(variables.data);i++) variables.colors.append(c);
    }

    return this;
  }

  public string function draw (
      string title = "", // optionally label the whole chart
      numeric width = 100, // scales to percentage of parent element
      string containerClass = "chartJsContainer",
      boolean patternFill = true, // colorblindness accessibility (requires patternomaly)
      boolean stacked = false, // stack dataset bars vertically
      boolean showLine = true, // set false to only show points
      numeric borderWidth = 2, // also controls line thickness
      string borderColor = "black", // English or hexadecimal,
      string lineColor, // override to draw all lines this color
      string pointShape = "circle", // eg circle,triangle,rect,rectRounded,star
      numeric pointRadius = 8, // size of points
      numeric hoverPointRadius = 18, // size of hovered point
      array borderDash = [], // [on,off,on,off] numeric dash pattern
      numeric xMin,
      numeric xMax,
      numeric yMin,
      numeric yMax,
      string xLabel = "", // label the xAxis
      string xAxisPosition = "bottom",
      string yAxisPosition = "left",
      string yLabel = "", // label the yAxis
      string legendPosition = "bottom",
      boolean showLegend = true
    ) {

    var canvas = '<div class="#arguments.containerClass#" style="position:relative;height:#arguments.width#%;width:#arguments.width#%"><canvas id="#variables.chartID#"></canvas></div>';

    var script = '
      <script>
        var ctx = document.getElementById("#variables.chartID#").getContext("2d");
        var myChart = new Chart( ctx, {
          type: "#variables.type#",
          data: {
            labels: [#ListQualify( ArrayToList(variables.dataLabels), '"', ',', 'all' )#],
            datasets: [';
              for (var i=1; i<=ArrayLen(variables.data); i++) {
                script &= '{data: [';
                if (variables.type EQ 'scatter') {
                  var count = 0;
                  for (var d in variables.data[i]) {
                    script &= '{x:#d.x#, y:#d.y#}';
                    count ++;
                    if ( count NEQ ArrayLen(variables.data[i]) ) script &= ',';
                    else script &= '],';
                  }
                }
                else script &= ArrayToList(variables.data[i]) &'],';
                  if (variables.type EQ "line") {
                    if (variables.curveFit EQ "linear") script &= 'lineTension: 0,';
                    if (ArrayLen(arguments.borderDash)) script &= 'borderDash: ['&ArrayToList(arguments.borderDash)&'],';
                    script &= '
                      pointRadius: #arguments.pointRadius#,
                      pointHoverRadius: #arguments.hoverPointRadius#,
                      showLine: #( (arguments.showLine)? true : false )#,
                      fill: false,
                    ';
                  }
                  script &= '
                  backgroundColor: ';
                  if (arguments.patternFill) script &= 'pattern.generate(["#variables.colors[i]#"])[0],';
                  else script &= '"#variables.colors[i]#",';
                  script &= 'borderColor: "#( (variables.type NEQ 'line')? arguments.borderColor : ( StructKeyExists(arguments,"lineColor")? arguments.lineColor : variables.colors[i]) )#",
                  borderWidth: #( (variables.type NEQ 'line')? arguments.borderWidth : (arguments.borderWidth*2) )#';
                  if (ArrayLen(variables.datasetNames) EQ ArrayLen(variables.data)) script &= ', label: "#variables.datasetNames[i]#"';
                  script &= '},';
              }
              script = Left(script, len(script)-1);
              script &= '
            ]
          },
          options: {
            title: {
              text: "#arguments.title#",
              display: #( (Len(arguments.title) GT 0)? true : false )#
            },
            tooltips: {';
              if (variables.type EQ "line") script &= 'mode:"#( (arguments.showLine)? 'index' : 'nearest')#"';
            script &= '
            },
            legend: {
              position: "#arguments.legendPosition#",
              display: #( ( arguments.showLegend AND ArrayLen(variables.datasetNames) ) ? true : false )#
            },';
            if ( listcontains("line,scatter", variables.type) ) script &= 'elements: {
              point: {pointStyle:"#arguments.pointShape#"}
            },';
            script &= '
            scales:{
              xAxes:[{
                display: true,
                type: #( ListContains( "scatter,horizontalBar",variables.type )? '"linear"' : '"category"' )#,
                position: "#arguments.xAxisPosition#",
                stacked: #( (arguments.stacked)? true : false )#,
                ticks: {';
              if (StructKeyExists(arguments,"xMin")) script &= 'suggestedMin: #arguments.xMin#';
              if (StructKeyExists(arguments,"xMax")) {
                if (StructKeyExists(arguments,"xMin")) script &= ',';
                script &= 'suggestedMax: #arguments.xMax#';}
              script &= '}';
              if (Len(arguments.xLabel)) script &= ',scaleLabel: { display:true, labelString: "#arguments.xLabel#" }';
            script &= '}],
              yAxes:[{
                display: true,
                type: "#( variables.type EQ 'horizontalBar' )? "category" : "linear"#",
                stacked: #( (arguments.stacked)? true : false )#,
                position: "#arguments.yAxisPosition#",
                ticks: {';
                if (StructKeyExists(arguments,"yMin")) script &= 'suggestedMin: #arguments.yMin#';
                if (StructKeyExists(arguments,"yMax")) {
                  if (StructKeyExists(arguments,"yMin")) script &= ',';
                  script &= 'suggestedMax: #arguments.yMax#';}
                script &= '}';
                if (Len(arguments.yLabel)) script &= ',scaleLabel: { display:true, labelString: "#arguments.yLabel#" }';
              script &= '}]
            }
          }
        } );
      </script>
    ';

    return canvas&script;
  }
}