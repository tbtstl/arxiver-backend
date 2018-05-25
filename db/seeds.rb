require 'net/http'
require 'uri'
require 'date'
# p "Fetching publications from arxiv.org..."
# url = URI.parse('http://export.arxiv.org/api/query?search_query=all:electron&start=0&max_results=1')
# res = Net::HTTP.get_response(url)
#
# p res.body

# uri = URI.parse('http://export.arxiv.org/oai2?verb=ListRecords&metadataPrefix=arXiv&from=2018-01-01&until=2018-01-02')
# res = Net::HTTP.get_response(uri)

def create_authors(authors)
  created = []
  authors.children.each do |author|
    name = ' '
    author.children.each do |attr|
      if attr.name == 'keyname'
        name += "#{attr.text.strip}"
      end
      if attr.name == 'forenames'
        name = "#{attr.text.strip}" + name
      end
    end

    @author = Author.find_or_create_by!(name: name)
    created.push @author
  end
  created
end

def create_categories(categories)
  created = []
  if categories.nil? or categories.empty?
    return created
  end

  categories = categories.strip.split

  categories.each do |category|
    name_mapping = Subject.key_to_friendly_name_map
    @subject = Subject.find_or_create_by!(name: name_mapping[category], key: category)
    created.push(@subject)
  end

  created
end

def create_publication(publication)
  title = ''
  abstract = ''
  pdf = ''
  arxiv_url = ''
  authors = []
  subjects = []

  publication.children.each do |c|
    if c.name == 'id'
      pdf = "https://arxiv.org/pdf/#{c.text.strip}.pdf"
      arxiv_url = "https://arxiv.org/abs/#{c.text.strip}"
    end
    if c.name == 'title'
      title = c.text.strip
    end
    if c.name == 'categories'
      subjects = create_categories c.text.strip
    end
    if c.name == 'authors'
      # Create authors
      authors = create_authors c
    end
    if c.name == 'abstract'
      abstract = c.text.strip
    end
  end

  @publication = Publication.find_or_create_by(title: title, abstract: abstract, pdf: pdf, arxiv_url: arxiv_url)
  @publication.authors = authors
  @publication.subjects = subjects
  @publication.save

  p "Publication #{@publication.title} saved"
end

step = 1
years = (2007..2018).to_a
months = (1..12).to_a
days = (1..31).step(step).to_a

seed_since_year = ENV["SEED_SINCE_YEAR"] ? ENV["SEED_SINCE_YEAR"].to_i : 2007
seed_since_month = ENV["SEED_SINCE_MONTH"] ? ENV["SEED_SINCE_MONTH"].to_i : 1
seed_since_day = ENV["SEED_SINCE_DAY"] ? ENV["SEED_SINCE_DAY"].to_i : 1


years.each do |year|
  months.each do |month|
    days.each do |day|
      # Skip until day of first results
      next if year < seed_since_year
      next if year <= seed_since_year && month < seed_since_month
      next if year == seed_since_year && month == seed_since_month && day < seed_since_day
      begin
        from = Date.new(year, month, day).iso8601
      rescue ArgumentError
        from = Date.new(year, month, -1).iso8601
      end
      begin
        to = Date.new(year, month, day+step).iso8601
      rescue ArgumentError
        to = Date.new(year, month, -1).iso8601
      end

      p "fetching #{from} until #{to}"
      uri = URI.parse("http://export.arxiv.org/oai2?verb=ListRecords&metadataPrefix=arXiv&from=#{from}&until=#{to}")

      res = Net::HTTP.get_response(uri)

      if res.code == '503'
        retry_after = res['Retry-After']

        if retry_after.nil?
          retry_after = 10
        end

        p "Got 503, sleeping for #{retry_after} seconds"
        sleep(retry_after.to_i)
        redo
      end

      @document = Nokogiri::XML(res.body)
      publications = @document.css('ListRecords > record > metadata > *')
      p "Found #{publications.length} publications"
      publications.each do |publication|
        create_publication publication
      end
    end
  end
end