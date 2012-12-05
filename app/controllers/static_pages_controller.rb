class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def scrape
  	#xpath for a living social deal:
  	#/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div[@id='cities-content-id']/ul[@class='unstyled cities-items']/li[@class='ls-item deal']

  	#LIVINGSOCIAL
	agent = Mechanize.new
	page = agent.get('http://www.livingsocial.com/cities/4-los-angeles')
	response = page.content
	doc = Hpricot(response)
	deals=(doc/"/html/body[@class='external www external-www cities cities-show full-width']/div[@class='container main-content']/div[@class='row']/div[@class='span12 content']/div[@id='cities-content-id']/ul[@class='unstyled cities-items']/li[@class='ls-item deal ']")
	
  end
end
