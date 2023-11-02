class ShortsController < ApplicationController
  def show
    short_url = params[:short_url]
    original_url = $redis.hget('urls', short_url)

    if original_url
      redirect_to original_url
    else
      @url = Url.find_by(short_url: short_url)

      if @url
        redirect_to @url.original_url, allow_other_host: true
      else
        flash[:error] = '短網址不存在'
        redirect_to root_path
      end
    end
  end
end
