class UrlsController < ApplicationController
  
  def new
    @url = Url.new
  end

  def create
    @url = Url.new(url_params)
    @url.generate_short_url
  
    if @url.save
      hash = {
        "url" => @url.original_url,
        "short" => "#{ENV["WEB_DOMAIN"]}/shorts/#{@url.short_url}",
        "slug" => @url.short_url
      }
      $redis.hset("id-#{@url.id}:#{@url.short_url}", hash)
      $redis.expire("id-#{@url.id}:#{@url.short_url}", 24 * 3600)
  
      redirect_to url_path(@url.short_url)
    else
      render 'new'
    end
  end
  
  def show
    short_url = params[:id]
    original_url = $redis.hget(short_url, "url")

    if original_url
      render 'show'
    else
      @url = Url.find_by(short_url: short_url)

      if @url
        # 更新 Redis 中的映射和過期時間
        $redis.hset('urls', @url.short_url, @url.original_url)
        $redis.expire('urls', 24 * 3600)

        render 'show'
      else
        render plain: '找不到短連結', status: 404
      end
    end
  end

  private

  def url_params
    params.require(:url).permit(:original_url)
  end
end
