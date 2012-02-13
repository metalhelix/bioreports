
picnet = {}
picnet.ui = {}
picnet.ui.filter = {}

`/**
 * @constructor
 */
picnet.ui.filter.SearchEngine = function() {
  /**
   * @private
   * @type {Object.<number>}
   */
  this.precedences_ = {
    'or' :1,
    'and':2,
    'not':3
  };
};
 
/**  
 * @param {string} textToMatch
 * @param {Array.<string>} postFixTokens   
 * @param {boolean} exactMatch
 * @return {boolean}
 */
picnet.ui.filter.SearchEngine.prototype.doesTextMatchTokens = function (textToMatch, postFixTokens, exactMatch) {
    if (!postFixTokens) return true;
    textToMatch = exactMatch ? textToMatch : textToMatch.toLowerCase();
    var stackResult = [];
    var stackResult1;
    var stackResult2;
 
    for (var i = 0; i < postFixTokens.length; i++) {
        var token = postFixTokens[i];
        if (token !== 'and' && token !== 'or' && token !== 'not') {
            if (token.indexOf('>') === 0 || token.indexOf('<') === 0 || token.indexOf('=') === 0 || token.indexOf('!=') === 0) {
                stackResult.push(this.doesNumberMatchToken(token, textToMatch));
            } else {
                stackResult.push(exactMatch ? textToMatch === token : textToMatch.indexOf(token) >= 0);
            }
        }
        else {
 
            if (token === 'and') {
                stackResult1 = stackResult.pop();
                stackResult2 = stackResult.pop();
                stackResult.push(stackResult1 && stackResult2);
            }
            else if (token === 'or') {
                stackResult1 = stackResult.pop();
                stackResult2 = stackResult.pop();
 
                stackResult.push(stackResult1 || stackResult2);
            }
            else if (token === 'not') {
                stackResult1 = stackResult.pop();
                stackResult.push(!stackResult1);
            }               
        }
    }
    return stackResult.length === 1 && stackResult.pop();
};
 
/**  
 * @param {string} text
 * @return {Array.<string>}
 */
picnet.ui.filter.SearchEngine.prototype.parseSearchTokens = function(text) {
    if (!text) { return null; }     
    text = text.toLowerCase();
    var normalisedTokens = this.normaliseExpression(text);
    normalisedTokens = this.allowFriendlySearchTerms(normalisedTokens);
    var asPostFix = this.convertExpressionToPostFix(normalisedTokens);
    var postFixTokens = asPostFix.split('|');
    return postFixTokens;
};
     
/**
 * @private
 * @param {string} token
 * @param {string} text
 * @return {boolean}
 */
picnet.ui.filter.SearchEngine.prototype.doesNumberMatchToken = function(token, text) {
    var op,exp,actual = this.getNumberFrom(text);   
    if (token.indexOf('=') === 0) {
        op = '=';
        exp = parseFloat(token.substring(1));
    } else if (token.indexOf('!=') === 0) {
        op = '!=';
        exp = parseFloat(token.substring(2));
    } else if (token.indexOf('>=') === 0) {
        op = '>=';
        exp = parseFloat(token.substring(2));
    } else if (token.indexOf('>') === 0) {
        op = '>';
        exp = parseFloat(token.substring(1));
    } else if (token.indexOf('<=') === 0) {
        op = '<=';
        exp = parseFloat(token.substring(2));
    } else if (token.indexOf('<') === 0) {
        op = '<';
        exp = parseFloat(token.substring(1));
    } else {
        return true;
    }
 
    switch (op) {
        case '!=': return actual !== exp;
        case '=': return actual === exp;
        case '>=': return actual >= exp;
        case '>': return actual > exp;
        case '<=': return actual <= exp;
        case '<': return actual < exp;
    }
    throw new Error('Could not find a number operation: ' + op);
};
 
/** 
 * @private
 * @param {string} txt
 * @return {number}
 */
picnet.ui.filter.SearchEngine.prototype.getNumberFrom = function(txt) {
    if (txt.charAt(0) === '$') {
        txt = txt.substring(1);
    }
    return parseFloat(txt);
};
         
/**  
 * @private
 * @param {string} text
 * @return {!Array.<string>}
 */
picnet.ui.filter.SearchEngine.prototype.normaliseExpression = function(text) {
    var textTokens = this.getTokensFromExpression(text);
    var normalisedTokens = [];
 
    for (var i = 0; i < textTokens.length; i++) {
        var token = textTokens[i];
        token = this.normaliseTerm(normalisedTokens, token, '(');
        token = this.normaliseTerm(normalisedTokens, token, ')');
 
        if (token.length > 0) { normalisedTokens.push(token); }
    }
    return normalisedTokens;
};
 
/**
 * @private
 * @param {!Array.<string>} tokens
 * @param {string} token
 * @param {string} term
 */
picnet.ui.filter.SearchEngine.prototype.normaliseTerm = function(tokens, token, term) {
    var idx = token.indexOf(term);
    while (idx !== -1) {
        if (idx > 0) { tokens.push(token.substring(0, idx)); }
 
        tokens.push(term);
        token = token.substring(idx + 1);
        idx = token.indexOf(term);
    }
    return token;
};
 
/**
 * @private
 * @param {string} exp
 * @return {!Array.<string>}
 */
picnet.ui.filter.SearchEngine.prototype.getTokensFromExpression = function(exp) {       
    exp = exp.replace('>= ', '>=').replace('> ', '>').replace('<= ', '<=').replace('< ', '<').replace('!= ', '!=').replace('= ', '=');
    var regex = /([^"^\s]+)\s*|"([^"]+)"\s*/g;      
    var matches = [];
    var match = null;
    while (match = regex.exec(exp)) { matches.push(match[1] || match[2]); }
    return matches;
};
 
/**  
 * @private
 * @param {!Array.<string>} tokens
 * @return {!Array.<string>}
 */
picnet.ui.filter.SearchEngine.prototype.allowFriendlySearchTerms = function(tokens) {
    var newTokens = [];
    var lastToken;
 
    for (var i = 0; i < tokens.length; i++) {
        var token = tokens[i];
        if (!token || token.length === 0) { continue; }
        if (token.indexOf('-') === 0) {
            token = 'not';
            tokens[i] = tokens[i].substring(1);
            i--;
        }
        if (!lastToken) {
            newTokens.push(token);
        } else {
            if (lastToken !== '(' && lastToken !== 'not' && lastToken !== 'and' && lastToken !== 'or' && token !== 'and' && token !== 'or' && token !== ')') {
                newTokens.push('and');
            }
            newTokens.push(token);
        }
        lastToken = token;
    }
    return newTokens;
};
 
/**  
 * @private
 * @param {!Array.<string>} normalisedTokens
 * @return {string}
 */
picnet.ui.filter.SearchEngine.prototype.convertExpressionToPostFix = function(normalisedTokens) {
    var postFix = '';
    var stackOps = [];
    var stackOperator;
    for (var i = 0; i < normalisedTokens.length; i++) {
        var token = normalisedTokens[i];
        if (token.length === 0) continue;
        if (token !== 'and' && token !== 'or' && token !== 'not' && token !== '(' && token !== ')') {
            postFix = postFix + '|' + token;
        }
        else {
            if (stackOps.length === 0 || token === '(') {
                stackOps.push(token);
            }
            else {
                if (token === ')') {
                    stackOperator = stackOps.pop();
                    while (stackOperator !== '(' && stackOps.length > 0) {
                        postFix = postFix + '|' + stackOperator;
                        stackOperator = stackOps.pop();
                    }
                }
                else if (stackOps[stackOps.length - 1] === '(') {
                    stackOps.push(token);
                } else {
                    while (stackOps.length !== 0) {
                        if (stackOps[stackOps.length - 1] === '(') { break; }
                        if (this.precedences_[stackOps[stackOps.length - 1]] > this.precedences_[token]) {
                            stackOperator = stackOps.pop();
                            postFix = postFix + '|' + stackOperator;
                        }
                        else { break; }
                    }
                    stackOps.push(token);
                }
            }
        }
    }
    while (stackOps.length > 0) { postFix = postFix + '|' + stackOps.pop(); }
    return postFix.substring(1);
};

/**
 * @constructor
 * @param {string} id
 * @param {string} value
 * @param {number} idx
 * @param {string} type
 */
picnet.ui.filter.FilterState = function(id, value, idx, type) {
    /** 
     * @type {string}
     */
    this.id = id;
    /** 
     * @type {string}
     */
    this.value = value;
    /** 
     * @type {number}
     */
    this.idx = idx;
    /** 
     * @type {string}
     */
    this.type = type;   
};
 
/** 
 * @override
 * @return {string}
 */
picnet.ui.filter.FilterState.prototype.toString = function() { return 'id[' + this.id + '] value[' + this.value + '] idx[' + this.idx + '] type[' + this.type + ']'; };
`



class DataGrid
  constructor: () ->
    @filters = []
    @search  = new picnet.ui.filter.SearchEngine()
    @timer = null
    @column_displays = {}

  init_options: () =>
    options = {}
    options.filename = getURLParameter('file') || null
    options.page = parseInt(getURLParameter('page')) || 1
    options.limit = parseInt(getURLParameter('limit')) || 100
    options.sort = getURLParameter('sort') || null
    options.page_top = getURLParameter('page_top') == 'true'
    options.page_bottom = !(getURLParameter('page_bottom') == 'false')
    options.timer_interval = getURLParameter('timer_interval') || 800
    options.chart_display = !(getURLParameter('chart_display') == 'false')
    
    options

  get_options: () =>
    if !@options
      @options = this.init_options()
    @options

  # TODO: lots of column display stuff in our data_grid
  # move out to separate class?
  column_display: (column_id) =>
    @column_displays[column_id]

  set_column_display: (column_id, display_type) =>
    @column_displays[column_id] = display_type

  # TODO: hardcoding image paths not portable. 
  # investigate css only approach
  column_display_icon: (display_type) =>
    if display_type == "num"
      "/imgs/data_grid/eye.png"
    else
      "/imgs/data_grid/chart.png"

  change_column_display: (column_id) =>
    current_display = this.column_display(column_id)
    new_display = if current_display == "num" then "chart" else "num"
    grid_rows = @grid_body.selectAll("tr")
    column_extent = d3.extent(@filtered_data, (d) -> parseFloat(d3.values(d)[column_id]))
    w = d3.scale.linear().domain(column_extent).range(["2px", "30px"])
    grid_rows.each (d) ->
      raw_value = d3.values(d)[column_id]
      new_html = raw_value
      if current_display == "num"
        value = parseFloat(d3.values(d)[column_id])
        if value
          new_html = "<div title=\"#{raw_value}\"class=\"data_grid_bar\" style=\"width:#{w(value)};background-color:steelBlue;height:16px;\"></div>"
      d3.select(this).selectAll("td").filter((d,i) -> i == column_id).html(new_html)
    this.set_column_display(column_id, new_display)
    @display_controls.filter((d,i) -> i == column_id).attr("src", this.column_display_icon(current_display))
      
  create_view: (id, data, options) =>
    grid = d3.select(id).append("table")
      .attr("id", "data_grid_table")

    header_data = this.header(data)

    grid_header = grid.append("thead")
    grid_titles = grid_header.append("tr")
    grid_views = null
    if this.get_options().chart_display
      grid_views = grid_header.append("tr").attr("class", "grid_views")

    grid_filters = grid_header.append("tr").attr("class", "filters")

    grid_titles.selectAll("th")
      .data(header_data).enter()
      .append("th").attr("class", (d) =>
        "sortable"
      ).on("click", (d,i) => this.sort_decending(i)).text((d) -> d)

    if grid_views
      @display_controls = grid_views.selectAll("td")
        .data(header_data).enter()
      .append("td").attr("class", "data_grid_display_select").append("a")
        .attr("href", "#")
        .on("click", (d,i) => this.change_column_display(i))
        .append("img")
        .attr("src", this.column_display_icon("chart"))

      @display_controls.each((d,i) => this.set_column_display(i, "num"))

    @filters = grid_filters.selectAll("td")
      .data(header_data).enter()
    .append("td").append("input")
      .attr("id", (d,i) -> "filter_#{i}")
      .attr("type", "text")
      .style("width", "95%")
      .on("input", (d) => this.start_refresh_timer())

    @grid_body = grid.append("tbody")

  refresh_view: (data, options) =>
    header_data = this.header(data)

    @grid_body.selectAll("tr").remove()

    grid_rows = @grid_body.selectAll("tr")
      .data(data)

    grid_row = grid_rows.enter()
      .append("tr")

    for header in header_data
      grid_row.append("td")
        .text((d) -> d[header])

  # TODO: Looks Bad when lots of pages. fix
  create_view_pagination: (id, data, options) =>
    page_range = 20
    current_page = options.page
    min_pages = 1
    max_pages = if data.length == 0 then 1 else Math.ceil(data.length / options.limit)

    # min_pages = Math.max(min_all_pages, if current_page < page_range then 1 else Math.abs(current_page - 25) )
    # max_pages = Math.min(max_all_pages, current_page + page_range)

    pagination = d3.select(id).attr("class", "data_grid_page_links")

    pages = pagination.selectAll("a").remove()

    pages = pagination.selectAll("a")
      .data([min_pages..max_pages])

    pages.enter().append("a")
      .attr("id", (d) -> "data_grid_page_link_#{d}")
      .attr("data-page", (d) -> d)
      .attr("href", "#")
      .attr("class", (d) -> if d == current_page then "data_grid_page_link current" else "data_grid_page_link")
      .text((d) -> "#{d}")
      .on "click", (d) =>
        @options.page = d
        this.refresh()

    pages.exit().remove()

  # Currently does nothing. 
  # TODO: add sorting to columns
  sort: (data, options) =>
    return if !options.sort
    data

  sort_decending: (column_id) =>
    console.log("sort descending")

  # Given a filter element and the index of the
  # filter, this will return a FilterState
  # representing this filter
  filter_state_for: (filter, index) =>
    type = filter.type
    value = filter.value
    if !value
      null
    else
      new picnet.ui.filter.FilterState(filter.getAttribute('id'), value, index, type)

  # Returns Array of all FilterStates, one for each active filter
  # an filter is considered 'active' if its text is not empty 
  filter_states: () =>
    filter_states = []
    filter_index = 0
    # here, 'this' is the html element and 'filter' is the data associated with
    # the filter
    # TODO: best way to do this?
    @filters.each (filter) ->
      filter_state = DataGrid::filter_state_for(this, filter_index)
      filter_states.push filter_state if filter_state
      filter_index += 1
    filter_states


  # Performs filtering on input data
  # returns new filtered data
  filter: (data, options) =>
    filter_states = this.filter_states()
    # Just put tokens inside corresponding filter_state
    for filter_state in filter_states
      filter_state.tokens = @search.parseSearchTokens(filter_state.value)

    if filter_states and filter_states.length > 0
      data = data.filter (d) =>
        d_values = d3.values(d)
        keep = true
        for filter_state in filter_states
          unless @search.doesTextMatchTokens(d_values[filter_state.idx], filter_state.tokens, false)
            keep = false
            break
        keep
    data

  # Performs pagination on data.
  # Returns data for options.page
  limit:  (data, options) =>
    max_pages = Math.ceil(data.length / options.limit)
    current_page = Math.max(options.page, 0)
    current_page = Math.min(current_page, max_pages)
    limit_start = (current_page - 1) * options.limit
    limit_end = Math.min((current_page) * options.limit, data.length) - 1
    data[limit_start..limit_end]

  # Returns array of header values used in data
  header: (data) =>
    d3.keys(data[0])

  # Sets up initial DataGrid view
  # id is the html id of the element to insert DataGrid into
  # Example: "data_grid"
  # data is the Array of Objects to display
  show: (id,data) =>
    @original_data = data
    d3.select("##{id}").html("<div id=\"data_grid_pagination_top\"></div><div id=\"data_grid_data\"></div><div id=\"data_grid_pagination_bottom\"></div>")

    options = this.get_options()

    this.create_view("#data_grid_data", data, options)
    this.refresh()

  # Refreshes the display of the data given the current
  # options and filters set
  refresh: () =>
    options = this.get_options()
    data = @original_data
    @filtered_data = this.filter(data,options)
    this.sort(@filtered_data,options)
    if options.page_top
      this.create_view_pagination("#data_grid_pagination_top", @filtered_data, options)
    if options.page_bottom
      this.create_view_pagination("#data_grid_pagination_bottom", @filtered_data, options)
    page_data = this.limit(@filtered_data, options)
    this.refresh_view(page_data, options)

  start_refresh_timer: () =>
    if @timer
      clearTimeout(@timer)
    @timer = setTimeout(this.end_refresh_timer, this.get_options().timer_interval)

  end_refresh_timer: () =>
    @timer = null
    this.refresh()

root = exports ? this

$ ->
  data_grid = new DataGrid
  options = data_grid.get_options()

  data_loaded = (data) ->
    console.log("loaded")
    if data
      data_grid.show("data_grid",data)
    else
      error_bad_load()

  error_bad_load = () ->
    d3.select("#data_grid").html("<h2 class=\"error\">ERROR: #{options.filename} cannot be loaded</h2>")
  error_no_file = () ->
    d3.select("#data_grid").html("<h2 class=\"error\">ERROR: no file provided</h2>")

  error_bad_extension = () ->
    d3.select("#data_grid").html("<h2 class=\"error\">ERROR: #{options.filename} wrong extension. Can be .tsv or .csv</h2>")

  if options.filename
    ext = options.filename.split('.').pop()
    if(ext == "csv")
      d3.csv options.filename, data_loaded
    else if(ext == "tsv")
      d3.tsv options.filename, data_loaded
    else
      error_bad_extension()
  else
    error_no_file()

