# require 'net/http'
# require 'uri'
# p "Fetching publications from arxiv.org..."
# url = URI.parse('http://export.arxiv.org/api/query?search_query=all:electron&start=0&max_results=1')
# res = Net::HTTP.get_response(url)
#
# p res.body
