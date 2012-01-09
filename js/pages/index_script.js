$(document).ready(function () {

  var w = 900;
  var h = 300;
  var padding = 20;
  var format = d3.time.format("%Y-%m-%d %H:%M");

  var vis = d3.select("#vis")
    .append("svg")
    .attr("id", "vis-svg")
    .attr("width", w + padding * 2)
    .attr("height", h + padding * 2)
    .append("g")
    .attr("transform", "translate(" + padding + "," + padding + ")");


  d3.json('/reports.json', function(data) {
    
    // console.log(data);

    data.forEach(function(r) {
      // console.log(r.id););
      // console.log(r.date);
      // console.log(format.parse(r.date).getDay());
    });

    var max_date = d3.max(data, function(d) { return format.parse(d.date); });
    var min_date = d3.min(data, function(d) { return format.parse(d.date); });
    // min_date = min_date.setDate(min_date.getDate() - 5);
    var diff_date = max_date - min_date;

    max_date = max_date.setTime(max_date.getTime() + diff_date / 4);
    min_date = min_date.setTime(min_date.getTime() - diff_date / 4);



    var time_scale = d3.time.scale().domain([min_date, max_date]).range([0, w]);
    var time_tick_format = time_scale.tickFormat(10);

    var color = d3.scale.category10();

    var y_scale = d3.scale.ordinal().range([0 + padding * 2, h - padding]);

    var time_ticks_g = vis.append("g");

    var time_ticks = time_ticks_g.selectAll(".time_rule")
      .data(time_scale.ticks(10))
      .enter().append("g")
      .attr("class", "time_rule")
      .attr("transform", function(d) { return "translate(" + time_scale(d) + ", 0)";});

    time_ticks.append("line")
      .attr("y1", -5)
      .attr("y2", h - 10)
      .attr("stroke", "#ddd");

    time_ticks.append("text")
      .attr("y", h)
      .attr("text-anchor", "middle")
      .text(function(d){return time_tick_format(d)});

    var reports_g = vis.append("g");

    var reports = reports_g.selectAll(".report_group")
      .data(data)
      .enter().append("g")
      .attr("class", "report_group")
      .attr("transform", function(d) { return "translate(" + time_scale(format.parse(d.date)) + ", " + padding + ")";});

    reports.append("circle")
      .attr("y", function(d) { return y_scale(d.analyst); })
      .attr("r", 4)
      .attr("fill", function(d) { return color(d.analyst); });
  });

});
