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

  $('a#copy-table').zclip({
    path:'/js/libs/ZeroClipboard.swf',
    copy:function(){
      var output = "";
      var valid_rows = $('.big_table tr').filter(function(index) {
        var row = $(this);
        return row.attr("filtermatch") != "false" && row.attr("class") != "filters";
      });
      valid_rows.each(function(index) {
        $(this).children().each(function(in2) {
          if(in2 != 0) 
        {
          output += "\t";
        }
          output += $(this).text();
        });
        output += "\n";
      });
      return output;
    }
  });

  $('a#copy_data_grid').zclip({
    path:'/js/libs/ZeroClipboard.swf',
    copy:function(){
      var output = "";
      var valid_rows = $('#data_grid_data tr');
      valid_rows.each(function(index) {
        $(this).children().each(function(in2) {
          if(in2 != 0) 
        {
          output += "\t";
        }
          output += $(this).text();
        });
        output += "\n";
      });
      return output;
    },
    afterCopy:function() {
      alert("Copied To Clipboard!\n\nPaste into Excel.");
    }
  });

  $('.big_table').tableFilter(options);
  
  $('.data_table').dataTable( {
    "bPaginate": false,
    "bSort": true,
    "aaSorting": []
  });

  $('.basic_table').dataTable( {
    "bPaginate": false,
    "bLengthChange": false,
    "bFilter": false,
    "bSort": true,
    "bInfo": false,
    "aaSorting": []
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


function getURLParameter(name) {
    return decodeURIComponent((RegExp('[?|&]' + name + '=' + '(.+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
}

function insertParam(key, value)
{
    key = escape(key); value = escape(value);

    var kvp = document.location.search.substr(1).split('&');

    var i=kvp.length; var x; while(i--) 
    {
        x = kvp[i].split('=');

        if (x[0]==key)
        {
                x[1] = value;
                kvp[i] = x.join('=');
                break;
        }
    }

    if(i<0) {kvp[kvp.length] = [key,value].join('=');}

    //this will reload the page, it's likely better to store this until finished
    document.location.search = kvp.join('&'); 
}

