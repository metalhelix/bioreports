$(document).ready(function() {

  $("#toc").tableOfContents(
    $("#main"),
    {
      startLevel: 2,
      depth: 3
    });

  var options = {
    additionalFilterTriggers: [$('#quickfind')],
    clearFiltersControls: [$('#cleanfilters')]
  };

  $('.big_table').tableFilter(options);
  
  $('.data_table').dataTable( {
    "bPaginate": false,
    "bSort": true
  });
  $('.basic_table').dataTable( {
    "bPaginate": false,
    "bLengthChange": false,
    "bFilter": false,
    "bSort": true,
    "bInfo": false
  });

  // wrap contents below h2's in div.section to 
  // allow for show/hide functionality
  $('h2').each(function(index) {
    $(this).nextUntil('h2').wrapAll('<div class="section" />');
  });

  // add show/hide toggle span to h2's
  $('#main h2').append("  <span class='header_accent'><a href='#' class='toggle'>hide</a></span>");
  // add same show/hide toggle to .section_toggle 
  $('.section_toggle').append("  <span class='header_accent'><a href='#' class='toggle'>show</a></span>");
  // add toggle functionality to a.toggle's
  $('a.toggle').click(function() 
    {
      var section = $(this).parent().parent().next(".section");
      section.slideToggle(300);
      var text = $(this).text() == "show" ? "hide" : "show";
      $(this).text(text);
      return false;
    });
});

