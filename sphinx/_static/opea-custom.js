/* Extra acrn-specific javascript */

$(document).ready(function(){
   /* tweak logo link to the marketing site instead of doc site */
   $( ".icon-home" ).attr({href: "https://opea-project.github.io/latest/index.html", target: "_blank"});

   /* open external links in a new tab */
   $('a[class*=external]').attr({target: '_blank', rel: 'noopener'});

});
