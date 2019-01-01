component accessors="true" {
  // encapsulates chart.js library to draw a responsive pie chart

  property name="chartID" type="string"; // id of <canvas> element
  property name="data" type="array"; // [ {labelA:1,labelB:2}, {labelA:3,labelB:4} ]
  property name="colors" type="array"; // English or hexadecimal
  property name="dataLabels" type="array";
  property name="datasetNames" type="array";


  public function init(
    required any data, // as {label1:val1,label2:val2} or an array of such structs
    array datasetNames=[], // required for multi-dataset chart
    string chartID="",
    array colors=[] // length should be size of dataset
  ) {

    for (var arg in arguments) if (arg NEQ "data") variables[arg] = arguments[arg];
    if (variables.chartID EQ "") variables.chartID = "pieChart_"&CreateUUID();

    // cast data to array
    variables.data = ( (IsArray(arguments.data))? arguments.data : [arguments.data] );
    for (var x in variables.data) if (!IsStruct(x)) throw(type="InvalidDataArgument",message="data must be a struct or an array of key-similar structs.");

    // validate dataset names
    if ( (ArrayLen(variables.data) GT 1) AND (ArrayLen(variables.datasetNames) LT ArrayLen(variables.data)) ) throw(type="MissingDatasetName",message="Multi-dataset charts need to receive a name for each dataset.");

    // set labels and validate
    variables.dataLabels = [];
    for (var i=1; i<=ArrayLen(variables.data); i++) {
      for (var category in variables.data[i]) {
        if (i EQ 1) variables.dataLabels.append(category);
        else {
          if (!variables.dataLabels.contains(category)) throw(type="InconsistentDataLabeling",message="Pie chart datasets must share the same category names.");
          if (ArrayLen(variables.dataLabels) NEQ ListLen(StructKeyList(variables.data[i]))) throw(type="InconsistentData",message="PieChart datasets must be of the same size and category names.");
        }
      }
    }

    // set and validate colors
    if ( !ArrayLen(variables.colors) ) variables.colors = generateColors( ListLen(StructKeyList(variables.data[1])) );
    if ( ArrayLen(variables.colors) LT ListLen(StructKeyList(variables.data[1])) ) throw(type="InvalidColorsArray",message="Number of colors must match data size.");

    return this;
  }

  public string function draw (
      string title = "", // optionally label the whole chart
      numeric width = 100, // scale to percentage of parent element
      string containerClass = "chartJsContainer",
      boolean patternFill = true, // colorblindness accessibility
      numeric cutoutPercentage = 30, // pie chart like a donut
      string borderColor = "black", // English or hexadecimal
      numeric borderWidth = 2,
      string legendPosition = "top"
    ) {

    var canvas = '<div class="#arguments.containerClass#" style="position:relative;height:#arguments.width#%;width:#arguments.width#%"><canvas id="#variables.chartID#"></canvas></div>';

    var script = '
      <script>
        var ctx = document.getElementById("#variables.chartID#").getContext("2d");
        var myChart = new Chart( ctx, {
          type: "pie",
          data: {
            labels: [#ListQualify( ArrayToList(variables.dataLabels), '"', ',', 'all' )#],
            datasets: [';
              for (var k=1; k<=ArrayLen(variables.data); k++) {
                var dataset = variables.data[k];
                script &= '
                  {
                    data: [';
                    for (var i=1; i<=ListLen(StructKeyList(dataset)); i++) script &= dataset[variables.dataLabels[i]] & ',';
                    script = Left(script, len(script)-1);
                    script &= '
                    ],
                    backgroundColor: ';
                    if (arguments.patternFill) script &= 'pattern.generate(';
                    script &= '[' & ListQualify( ArrayToList(variables.colors), '"', ',', 'all' ) & ']';
                    if (arguments.patternFill) script &= ')';
                    script &= ',borderColor: "#arguments.borderColor#",
                    borderWidth: #arguments.borderWidth#';
                    if (ArrayLen(variables.data) GT 1) script &= ',label: "#variables.datasetNames[k]#"';
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
            legend: {
              position: "#arguments.legendPosition#"
            },
            cutoutPercentage: #arguments.cutoutPercentage#';
            if (ArrayLen(variables.data) GT 1) script &= ',
            tooltips: {
              callbacks: {
                label: function(item,data){ return data.datasets[item.datasetIndex].label + ": " + data.labels[item.index] + ": " + data.datasets[item.datasetIndex].data[item.index]; }
              }
            }';
            script &= '
          }
        } );
      </script>
    ';

    return canvas&script;
  }

  public array function generateColors( numeric length=1 ){
    var colorStruct = {
      aqua: "##00ffff",
      azure: "##f0ffff",
      beige: "##f5f5dc",
      // black: "##000000",
      blue: "##0000ff",
      brown: "##a52a2a",
      cyan: "##00ffff",
      darkblue: "##00008b",
      darkcyan: "##008b8b",
      darkgrey: "##a9a9a9",
      darkgreen: "##006400",
      darkkhaki: "##bdb76b",
      darkmagenta: "##8b008b",
      darkolivegreen: "##556b2f",
      darkorange: "##ff8c00",
      darkorchid: "##9932cc",
      darkred: "##8b0000",
      darksalmon: "##e9967a",
      darkviolet: "##9400d3",
      fuchsia: "##ff00ff",
      gold: "##ffd700",
      green: "##008000",
      indigo: "##4b0082",
      khaki: "##f0e68c",
      lightblue: "##add8e6",
      lightcyan: "##e0ffff",
      lightgreen: "##90ee90",
      lightgrey: "##d3d3d3",
      lightpink: "##ffb6c1",
      lightyellow: "##ffffe0",
      lime: "##00ff00",
      magenta: "##ff00ff",
      maroon: "##800000",
      navy: "##000080",
      olive: "##808000",
      orange: "##ffa500",
      pink: "##ffc0cb",
      purple: "##800080",
      violet: "##800080",
      red: "##ff0000",
      silver: "##c0c0c0",
      // white: "##ffffff",
      yellow: "##ffff00"
    };
    var colorList = StructKeyList( colorStruct );
    if ( arguments.length GT ListLen(colorList) ) throw(type="OutOfColorsException",message="Tried to generate too many colors");

    var ret = [];
    var remain = [];
    // an array of color indices
    for (var i=1; i LTE ListLen(colorList); i++) remain.append(i);

    for (var i=1; i LTE arguments.length; i++) {
      var idxIdx = RandRange( 1, ArrayLen(remain) );
      var idx = remain[idxIdx];
      ret.append( colorStruct[ ListGetAt(colorList,idx) ] );
      ArrayDeleteAt( remain, idxIdx );
    }

    return ret;
  }

}




