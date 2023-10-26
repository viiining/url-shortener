class UrlsController < ApplicationController
  
  def new
    @url = Url.new
  end

  def create
    @url = Url.new(url_params)
    @url.short_url = SecureRandom.hex(4)

    if @url.save
      # 將短連結存入Redis Hash
      $redis.hset('urls', @url.short_url, @url.original_url)
      redirect_to @url, notice: '短連結已經建立'
    else
      render 'new'
    end
  end

  def show
    short_url = params[:id]
    original_url = $redis.hget('urls', short_url)

    if original_url
      redirect_to original_url
    else
      @url = Url.find_by_short_url(short_url)

      if @url
        $redis.hset('urls', @url.short_url, @url.original_url)

        $redis.expire('urls', 24 * 3600)

        redirect_to @url.original_url
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
