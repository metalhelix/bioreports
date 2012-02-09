
root = exports ? this

data_grid.get_options = () ->
  options = {}
  options.filename = getURLParameter('file') || null
  options.page = parseInt(getURLParameter('page')) || 1
  options.limit = parseInt(getURLParameter('limit')) || 100
  options.sort = getURLParameter('sort') || null
  options

data_grid.view = (id, data, options) ->
  grid = d3.select(id).append("table")
    .attr("id", "data_grid_table")

  header_data = data_grid.header(data)

  grid_header = grid.append("thead")
  grid_titles = grid_header.append("tr")
  grid_filters = grid_header.append("tr").attr("class", "filters")

  for header in header_data
    grid_titles.append("th").text(header)

  filter_id_num = 0
  for header in header_data
    grid_filters.append("td")
      .append("input")
        .attr("id", "filter_#{filter_id_num}")
        .attr("type", "text")
        .style("width", "95%")
    filter_id_num += 1

  grid_body = grid.append("tbody")

  grid_rows = grid_body.selectAll("tr")
    .data(data)

  grid_row = grid_rows.enter()
    .append("tr")

  for header in header_data
    grid_row.append("td")
      .text((d) -> d[header])

data_grid.view_pagination = (id, data, options) ->
  min_pages = 1
  max_pages = Math.ceil(data.length / options.limit)
  current_page = options.page
  pagination = d3.select(id).attr("class", "data_grid_page_links")

  pagination.selectAll("a")
    .data([min_pages..max_pages]).enter()
  .append("a")
    .attr("id", (d) -> "data_grid_page_link_#{d}")
    .attr("data-page", (d) -> d)
    .attr("href", "#")
    .attr("class", (d) -> if d == current_page then "data_grid_page_link current" else "data_grid_page_link")
    .text((d) -> "#{d}")
    .on("click", (d) -> insertParam("page", d))


data_grid.sort = (data, options) ->
  return if !options.sort
  data.sort (a,b) ->
    console.log(a[2])

data_grid.limit = (data, options) ->
  max_pages = Math.ceil(data.length / options.limit)
  current_page = Math.max(options.page, 0)
  current_page = Math.min(current_page, max_pages)
  limit_start = (current_page - 1) * options.limit
  limit_end = Math.min((current_page) * options.limit, data.length) - 1
  console.log("#{limit_start} - #{limit_end}")
  data[limit_start..limit_end]

data_grid.header = (data) ->
  d3.keys(data[0])

data_grid.show = (data, options) ->
  d3.select("#data_grid").html("<div id=\"data_grid_pagination_top\"></div><div id=\"data_grid_data\"></div><div id=\"data_grid_pagination_bottom\"></div>")

  data_grid.view_pagination("#data_grid_pagination_top", data, options)
  data_grid.view_pagination("#data_grid_pagination_bottom", data, options)
  data_grid.sort(data,options)
  page_data = data_grid.limit(data,options)
  data_grid.view("#data_grid_data", page_data, options)

$ ->
  options = data_grid.get_options()

  show_grid = (data) ->
    data_grid.show(data,options)

  error_no_file = () ->
    d3.select("#data_grid").html("<h2 class=\"error\">ERROR: no file provided</h2>")

  if options.filename
    d3.csv options.filename, show_grid
  else
    error_no_file()

