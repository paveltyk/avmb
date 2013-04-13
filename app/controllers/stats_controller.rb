class StatsController < ApplicationController
  expose(:data) { Blurb.stats }
end
