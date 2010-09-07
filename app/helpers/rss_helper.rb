module RssHelper

  def subscribe_to(title, url, options = {})
    names = [options[:via]].flatten.compact
    
    names.in_groups_of(2).transpose.map do |group|
      group.map do |name|
        method = "subscribe_via_#{name}".to_sym
        respond_to?(method) ? send(method, title, url) : nil
      end.join(' ')
    end.compact.join('<br/>')
  end

  def feed_url(url)
    (url + '.rss').tap do |full_url|
      full_url << ( '?' + { :private => User.current.private_key }.to_query ) unless User.current.public?
    end
  end

  protected

    def subscribe_via_rss(title, url)
      subscribe_via :rss, url, "RSS: " + title
    end

    def subscribe_via_aol(title, url)
      subscribe_via :aol, "http://favorites.my.aol.com/ffclient/AddFeed?url=#{Rack::Utils.escape(url)}", "Add to myAOL"
    end

    def subscribe_via_bloglines(title, url)
      subscribe_via :bloglines, "http://www.bloglines.com/sub/#{Rack::Utils.escape(url)}", "Add to Bloglines"
    end

    def subscribe_via_google(title, url)
      subscribe_via :google, "http://fusion.google.com/add?source=atgs&feedurl=#{Rack::Utils.escape(url)}", "Add to Google"
    end

    def subscribe_via_newsgator(title, url)
      subscribe_via :newsgator, "http://www.newsgator.com/ngs/subscriber/subext.aspx?url=#{Rack::Utils.escape(url)}", "Subscribe in NewsGator Online"
    end

    def  subscribe_via_technorati(title, url)
      subscribe_via :technorati, "http://technorati.com/faves?add=#{Rack::Utils.escape(url)}", "Add to Technorati"
    end

    def subscribe_via_yahoo(title, url)
      subscribe_via :yahoo, "http://us.rd.yahoo.com/my/atm/#{Rack::Utils.escape(site_name)}/#{Rack::Utils.escape(title)}/*http://add.my.yahoo.com/rss?url=#{Rack::Utils.escape(url)}", "Add to My Yahoo!"
    end

    def subscribe_via(name, url, title)
      link_to image_tag("feeds/#{name}.gif", :alt => h(title)), url, :title => h(title)
    end

end
