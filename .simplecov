SimpleCov.start "rails" do
  enable_coverage :branch
  add_filter "/spec/"
  add_filter "/features/"
end
