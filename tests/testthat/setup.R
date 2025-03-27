library(httptest2)
set_redactor(function (x) {
   gsub_response(x, "api\\.cloudflare\\.com/client/v4/accounts/[0-9a-f]+/ai/run/@cf/meta/", "api/")
})
