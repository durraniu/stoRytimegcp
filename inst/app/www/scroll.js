$(document).on("click", "#create_story", function() {
  $("html, body").animate({
    scrollTop: $("#main-story_card").offset().top
  }, 1000);
});

function scrollToCards() {
  document.getElementById('main-story_prompt').scrollIntoView({ behavior: 'smooth' });
}
