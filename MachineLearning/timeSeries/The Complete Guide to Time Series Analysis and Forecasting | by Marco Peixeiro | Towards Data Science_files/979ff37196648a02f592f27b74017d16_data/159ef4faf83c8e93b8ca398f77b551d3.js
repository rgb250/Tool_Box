document.write('<link rel="stylesheet" href="https://github.githubassets.com/assets/gist-embed-24bb8e840bfabd0d17bac31daf27f75b.css">')
document.write('<div id=\"gist97638840\" class=\"gist\">\n    <div class=\"gist-file\">\n      <div class=\"gist-data\">\n        <div class=\"js-gist-file-update-container js-task-list-container file-box\">\n  <div id=\"file-comparison_stock-py\" class=\"file my-2\">\n    \n\n  <div itemprop=\"text\" class=\"Box-body p-0 blob-wrapper data type-python  \">\n      \n<table class=\"highlight tab-size js-file-line-container\" data-tab-size=\"8\" data-paste-markdown-skip>\n      <tr>\n        <td id=\"file-comparison_stock-py-L1\" class=\"blob-num js-line-number\" data-line-number=\"1\"><\/td>\n        <td id=\"file-comparison_stock-py-LC1\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-c># Make a dataframe containing actual and predicted prices<\/span><\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L2\" class=\"blob-num js-line-number\" data-line-number=\"2\"><\/td>\n        <td id=\"file-comparison_stock-py-LC2\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>comparison<\/span> <span class=pl-c1>=<\/span> <span class=pl-s1>pd<\/span>.<span class=pl-v>DataFrame<\/span>({<span class=pl-s>&#39;actual&#39;<\/span>: [<span class=pl-c1>18.93<\/span>, <span class=pl-c1>19.23<\/span>, <span class=pl-c1>19.08<\/span>, <span class=pl-c1>19.17<\/span>, <span class=pl-c1>19.11<\/span>, <span class=pl-c1>19.12<\/span>],<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L3\" class=\"blob-num js-line-number\" data-line-number=\"3\"><\/td>\n        <td id=\"file-comparison_stock-py-LC3\" class=\"blob-code blob-code-inner js-file-line\">                          <span class=pl-s>&#39;predicted&#39;<\/span>: [<span class=pl-c1>18.96<\/span>, <span class=pl-c1>18.97<\/span>, <span class=pl-c1>18.96<\/span>, <span class=pl-c1>18.92<\/span>, <span class=pl-c1>18.94<\/span>, <span class=pl-c1>18.92<\/span>]}, <\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L4\" class=\"blob-num js-line-number\" data-line-number=\"4\"><\/td>\n        <td id=\"file-comparison_stock-py-LC4\" class=\"blob-code blob-code-inner js-file-line\">                          <span class=pl-s1>index<\/span> <span class=pl-c1>=<\/span> <span class=pl-s1>pd<\/span>.<span class=pl-en>date_range<\/span>(<span class=pl-s1>start<\/span><span class=pl-c1>=<\/span><span class=pl-s>&#39;2018-06-05&#39;<\/span>, <span class=pl-s1>periods<\/span><span class=pl-c1>=<\/span><span class=pl-c1>6<\/span>,))<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L5\" class=\"blob-num js-line-number\" data-line-number=\"5\"><\/td>\n        <td id=\"file-comparison_stock-py-LC5\" class=\"blob-code blob-code-inner js-file-line\">\n<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L6\" class=\"blob-num js-line-number\" data-line-number=\"6\"><\/td>\n        <td id=\"file-comparison_stock-py-LC6\" class=\"blob-code blob-code-inner js-file-line\">\n<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L7\" class=\"blob-num js-line-number\" data-line-number=\"7\"><\/td>\n        <td id=\"file-comparison_stock-py-LC7\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-c>#Plot predicted vs actual price<\/span><\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L8\" class=\"blob-num js-line-number\" data-line-number=\"8\"><\/td>\n        <td id=\"file-comparison_stock-py-LC8\" class=\"blob-code blob-code-inner js-file-line\">\n<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L9\" class=\"blob-num js-line-number\" data-line-number=\"9\"><\/td>\n        <td id=\"file-comparison_stock-py-LC9\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>figure<\/span>(<span class=pl-s1>figsize<\/span><span class=pl-c1>=<\/span>(<span class=pl-c1>17<\/span>, <span class=pl-c1>8<\/span>))<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L10\" class=\"blob-num js-line-number\" data-line-number=\"10\"><\/td>\n        <td id=\"file-comparison_stock-py-LC10\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>plot<\/span>(<span class=pl-s1>comparison<\/span>.<span class=pl-s1>actual<\/span>)<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L11\" class=\"blob-num js-line-number\" data-line-number=\"11\"><\/td>\n        <td id=\"file-comparison_stock-py-LC11\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>plot<\/span>(<span class=pl-s1>comparison<\/span>.<span class=pl-s1>predicted<\/span>)<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L12\" class=\"blob-num js-line-number\" data-line-number=\"12\"><\/td>\n        <td id=\"file-comparison_stock-py-LC12\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>title<\/span>(<span class=pl-s>&#39;Predicted closing price of New Germany Fund Inc (GF)&#39;<\/span>)<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L13\" class=\"blob-num js-line-number\" data-line-number=\"13\"><\/td>\n        <td id=\"file-comparison_stock-py-LC13\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>ylabel<\/span>(<span class=pl-s>&#39;Closing price (\$)&#39;<\/span>)<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L14\" class=\"blob-num js-line-number\" data-line-number=\"14\"><\/td>\n        <td id=\"file-comparison_stock-py-LC14\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>xlabel<\/span>(<span class=pl-s>&#39;Trading day&#39;<\/span>)<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L15\" class=\"blob-num js-line-number\" data-line-number=\"15\"><\/td>\n        <td id=\"file-comparison_stock-py-LC15\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>legend<\/span>(<span class=pl-s1>loc<\/span><span class=pl-c1>=<\/span><span class=pl-s>&#39;best&#39;<\/span>)<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L16\" class=\"blob-num js-line-number\" data-line-number=\"16\"><\/td>\n        <td id=\"file-comparison_stock-py-LC16\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>grid<\/span>(<span class=pl-c1>False<\/span>)<\/td>\n      <\/tr>\n      <tr>\n        <td id=\"file-comparison_stock-py-L17\" class=\"blob-num js-line-number\" data-line-number=\"17\"><\/td>\n        <td id=\"file-comparison_stock-py-LC17\" class=\"blob-code blob-code-inner js-file-line\"><span class=pl-s1>plt<\/span>.<span class=pl-en>show<\/span>()<\/td>\n      <\/tr>\n<\/table>\n\n\n  <\/div>\n\n  <\/div>\n<\/div>\n\n      <\/div>\n      <div class=\"gist-meta\">\n        <a href=\"https://gist.github.com/marcopeix/159ef4faf83c8e93b8ca398f77b551d3/raw/57400cb2980736c4d9bd84a283d33231f3eeddd1/comparison_stock.py\" style=\"float:right\">view raw<\/a>\n        <a href=\"https://gist.github.com/marcopeix/159ef4faf83c8e93b8ca398f77b551d3#file-comparison_stock-py\">comparison_stock.py<\/a>\n        hosted with &#10084; by <a href=\"https://github.com\">GitHub<\/a>\n      <\/div>\n    <\/div>\n<\/div>\n')
