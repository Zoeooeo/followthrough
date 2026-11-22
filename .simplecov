SimpleCov.start "rails" do
  enable_coverage :branch
  merge_timeout 3600
  add_filter "/spec/"
  add_filter "/features/"
end
