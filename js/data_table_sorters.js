
// deal with
// scientific notation
// commas
// percent signs
jQuery.fn.dataTableExt.aTypes.unshift(
	function ( sData )
	{
    var sValidChars = "0123456789-,.%eE/";
    var aChar;

    for ( i = 0; i < sData.length; i++ )
		{
      aChar = sData.charAt(i);

      if(sValidChars.indexOf(aChar) == -1)
      {
        return null;
      }
    }
    return 'numeric-formatted';
  }
);


jQuery.fn.dataTableExt.oSort['numeric-formatted-asc'] = function(x,y){
 x = x.replace(/[^\d\-\.\/eE]/g,'');
 y = y.replace(/[^\d\-\.\/eE]/g,'');
 if(x.indexOf('/')>=0)x = eval(x);
 if(y.indexOf('/')>=0)y = eval(y);
 return x/1 - y/1;
}

jQuery.fn.dataTableExt.oSort['numeric-formatted-desc'] = function(x,y){
 x = x.replace(/[^\d\-\.\/eE]/g,'');
 y = y.replace(/[^\d\-\.\/eE]/g,'');
 if(x.indexOf('/')>=0)x = eval(x);
 if(y.indexOf('/')>=0)y = eval(y);
 return y/1 - x/1;
}

/* new sorting functions */
jQuery.fn.dataTableExt.oSort['scientific-asc']  = function(a,b) {
    var x = parseFloat(a);
    var y = parseFloat(b);
    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};
 
jQuery.fn.dataTableExt.oSort['scientific-desc']  = function(a,b) {
    var x = parseFloat(a);
    var y = parseFloat(b);
    return ((x < y) ? 1 : ((x > y) ?  -1 : 0));
};



