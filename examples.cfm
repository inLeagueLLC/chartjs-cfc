<cfoutput>

  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/patternomaly@1.3.2/dist/patternomaly.min.js"></script>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.3/Chart.bundle.min.js"></script>


    <cfset testData = [57,56,7,15,90,32,70]>
    <cfset dataLabels = ["A","B","C","D","E","F","G"]>

    <cfset testLineChart = new BasicChart(
      data = [testData],
      dataLabels = dataLabels,
      dataSetNames = ["Cool Data"],
      type = "line",
      curveFit = "linear"
    )>

    <cfset testBar2 = new BasicChart(
      data=[ testData ],
      dataLabels=dataLabels
    )>

    <cfset testPieChart = new PieChart(
      data = {"A":43,"B":30,"C":22,"D":59}
    )>

    <cfset testPie2 = new PieChart(
      data = [
        {"First":44,"Second":22,"Third":85},
        {"First":20,"Second":17,"Third":15}
      ],
      datasetNames = ["CompetitionA Refs","CompetitionB Refs"]
    )>

    <cfset testBar = new BasicChart(
      data = [
        [12,10,14,15,10],
        [20,9,23,16,18],
        [3,7,4,5,6]
      ],
      dataLabels = ["January","February","March","April","May"],
      datasetNames=["Boys","Girls","Adults"],
      colors=["blue","pink","green"]
    )>

    <cfset horizontalBar = new BasicChart(
      type="horizontalBar",
      data=[ [55,22,30] ],
      dataLabels=["A","B","C"]
    )>

    <cfset scatterPlot = new BasicChart(
      type="scatter",
      data=[
        {x:33,y:4},
        {x:10,y:67},
        {x:10,y:72},
        {x:22,y:5},
        {x:17,y:80}
      ],
      dataLabels=["A","B","C","D","E"] // TODO: this is required but not displayed anywhere
    )>

<h2>scatter plot</h2>
    #scatterPlot.draw(
      title="Look at this scatter plot",
      xMin=0,
      xMax=50,
      xLabel="Seconds",
      yLabel="Score",
      yMin=0,
      yMax=100,
      borderColor="purple",
      borderWidth=10,
      pointShape="triangle",
      width=77
    )#

<h2>line chart</h2>
    #testLineChart.draw(
      title = "My Test Chart",
      width = 77,
      lineColor="red"
    )#

<h2>horizontal bar chart</h2>
    #horizontalBar.draw(
      title = "A horizontal bar chart",
      width = 77
    )#

<h2>pie chart</h2>
    #testPieChart.draw(
      title = "Look at this Pie Chart",
      width = 77
    )#

<h2>pie chart 2</h2>
    #testPie2.draw(
      title = "Ref Positions by Competition",
      width = 77,
      cutoutPercentage = 10
    )#

<h2>bar chart</h2>
    #testBar.draw(
      title = "Attendance by Type and Month",
      stacked = true,
      width = 77
    )#

<h2>bar chart 2</h2>
    #testBar2.draw()#

</cfoutput>