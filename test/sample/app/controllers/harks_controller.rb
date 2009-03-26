class HarksController < ApplicationController
  def index
    Hark.create(:tidings => "Joy!") if Hark.count == 0
    render :text => Hark.find(:all).map{ |h| h.attributes }.to_yaml
  end
end
