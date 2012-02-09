(function() {
  var root;
  root = typeof exports !== "undefined" && exports !== null ? exports : this;
  data_grid.get_options = function() {
    var options;
    options = {};
    options.filename = getURLParameter('file') || null;
    options.page = parseInt(getURLParameter('page')) || 1;
    options.limit = parseInt(getURLParameter('limit')) || 100;
    options.sort = getURLParameter('sort') || null;
    return options;
  };
  data_grid.create_view = function(id, data, options) {
    var filter_id_num, grid, grid_filters, grid_header, grid_titles, header, header_data, _i, _j, _len, _len2;
    grid = d3.select(id).append("table").attr("id", "data_grid_table");
    header_data = data_grid.header(data);
    grid_header = grid.append("thead");
    grid_titles = grid_header.append("tr");
    grid_filters = grid_header.append("tr").attr("class", "filters");
    for (_i = 0, _len = header_data.length; _i < _len; _i++) {
      header = header_data[_i];
      grid_titles.append("th").text(header);
    }
    filter_id_num = 0;
    for (_j = 0, _len2 = header_data.length; _j < _len2; _j++) {
      header = header_data[_j];
      grid_filters.append("td").append("input").attr("id", "filter_" + filter_id_num).attr("type", "text").style("width", "95%");
      filter_id_num += 1;
    }
    return data_grid.grid_body = grid.append("tbody");
  };
  data_grid.refresh_view = function(data, options) {
    var grid_row, grid_rows, header, header_data, _i, _len, _results;
    header_data = data_grid.header(data);
    grid_rows = data_grid.grid_body.selectAll("tr").remove();
    grid_rows = data_grid.grid_body.selectAll("tr").data(data);
    grid_row = grid_rows.enter().append("tr");
    _results = [];
    for (_i = 0, _len = header_data.length; _i < _len; _i++) {
      header = header_data[_i];
      _results.push(grid_row.append("td").text(function(d) {
        return d[header];
      }));
    }
    return _results;
  };
  data_grid.create_view_pagination = function(id, data, options) {
    var current_page, max_pages, min_pages, pages, pagination, _i, _results;
    min_pages = 1;
    max_pages = Math.ceil(data.length / options.limit);
    current_page = options.page;
    pagination = d3.select(id).attr("class", "data_grid_page_links");
    pages = pagination.selectAll("a").remove();
    pages = pagination.selectAll("a").data((function() {
      _results = [];
      for (var _i = min_pages; min_pages <= max_pages ? _i <= max_pages : _i >= max_pages; min_pages <= max_pages ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this));
    pages.enter().append("a").attr("id", function(d) {
      return "data_grid_page_link_" + d;
    }).attr("data-page", function(d) {
      return d;
    }).attr("href", "#").attr("class", function(d) {
      if (d === current_page) {
        return "data_grid_page_link current";
      } else {
        return "data_grid_page_link";
      }
    }).text(function(d) {
      return "" + d;
    }).on("click", function(d) {
      options.page = d;
      return data_grid.refresh(data, options);
    });
    return pages.exit().remove();
  };
  data_grid.sort = function(data, options) {
    if (!options.sort) {
      return;
    }
    return data;
  };
  data_grid.limit = function(data, options) {
    var current_page, limit_end, limit_start, max_pages;
    max_pages = Math.ceil(data.length / options.limit);
    current_page = Math.max(options.page, 0);
    current_page = Math.min(current_page, max_pages);
    limit_start = (current_page - 1) * options.limit;
    limit_end = Math.min(current_page * options.limit, data.length) - 1;
    return data.slice(limit_start, (limit_end + 1) || 9e9);
  };
  data_grid.header = function(data) {
    return d3.keys(data[0]);
  };
  data_grid.show = function(data, options) {
    d3.select("#data_grid").html("<div id=\"data_grid_pagination_top\"></div><div id=\"data_grid_data\"></div><div id=\"data_grid_pagination_bottom\"></div>");
    data_grid.create_view("#data_grid_data", data, options);
    return data_grid.refresh(data, options);
  };
  data_grid.refresh = function(data, options) {
    var page_data;
    console.log("refresh");
    console.log(options);
    data_grid.sort(data, options);
    data_grid.create_view_pagination("#data_grid_pagination_top", data, options);
    data_grid.create_view_pagination("#data_grid_pagination_bottom", data, options);
    page_data = data_grid.limit(data, options);
    return data_grid.refresh_view(page_data, options);
  };
  $(function() {
    var data_loaded, error_no_file, options;
    options = data_grid.get_options();
    data_loaded = function(data) {
      console.log("loaded");
      return data_grid.show(data, options);
    };
    error_no_file = function() {
      return d3.select("#data_grid").html("<h2 class=\"error\">ERROR: no file provided</h2>");
    };
    if (options.filename) {
      return d3.csv(options.filename, data_loaded);
    } else {
      return error_no_file();
    }
  });
}).call(this);
