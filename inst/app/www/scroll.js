$(document).on("click", "#create_story", function() {
  $("html, body").animate({
    scrollTop: $("#story_card").offset().top
  }, 1000);
});

function scrollToCards() {
  document.getElementById('story_card').scrollIntoView({ behavior: 'smooth' });
}
